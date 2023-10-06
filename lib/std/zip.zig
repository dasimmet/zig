//! Very basic ZIP file implementation
//! Enough to use to download and extract ZIP files for the package manager.
//! Spec: https://pkware.cachefly.net/webdocs/APPNOTE/APPNOTE-6.3.10.TXT

// TODO zip64 support

pub const CompressionMethod = enum(u16) {
    store = 0,
    shrink = 1,
    reduce_1 = 2,
    reduce_2 = 3,
    reduce_3 = 4,
    reduce_4 = 5,
    implode = 6,
    reserved_1 = 7,
    deflate = 8,
    deflate64 = 9,
    pkware_implode = 10,
    reserved_2 = 11,
    bzip2 = 12,
    reserved_3 = 13,
    lzma = 14,
    reserved_4 = 15,
    ibm_zos_zmpsc = 16,
    reserved_5 = 17,
    ibm_terse = 18,
    ibm_lz77_z = 19,
    zstd_deprecated = 20,
    zstd = 93,
    mp3 = 94,
    xz = 95,
    jpeg = 96,
    wavpack = 97,
    ppmd_version_i_rev1 = 98,
    aex_encryption_marker = 99,
};

pub const LocalFileHeader = struct {
    const SIG: u32 = @as(u32, 0x04034b50);
    version_needed_to_extract: u16,
    general_purpose_bit_flag: std.bit_set.IntegerBitSet(16),
    compression_method: CompressionMethod,
    last_mod_file_time: u16,
    last_mod_file_date: u16,
    crc32: u32,
    compressed_size: u32,
    uncompressed_size: u32,
    file_name_length: u16,
    extra_field_length: u16,
    file_name: []const u8,

    // Caller owns the LocalFileHeader and must call deinit
    pub fn read(allocator: std.mem.Allocator, reader: anytype) !LocalFileHeader {
        const sig = try reader.readIntLittle(u32);
        if (sig != SIG) {
            return error.InvalidLocalFileHeaderSig;
        }
        var result = .{
            .version_needed_to_extract = try reader.readIntLittle(u16),
            .general_purpose_bit_flag = @as(std.bit_set.IntegerBitSet(16), @bitCast(try reader.readIntLittle(u16))),
            .compression_method = @as(CompressionMethod, @enumFromInt(try reader.readIntLittle(u16))),
            .last_mod_file_time = try reader.readIntLittle(u16),
            .last_mod_file_date = try reader.readIntLittle(u16),
            .crc32 = try reader.readIntLittle(u32),
            .compressed_size = try reader.readIntLittle(u32),
            .uncompressed_size = try reader.readIntLittle(u32),
            .file_name_length = try reader.readIntLittle(u16),
            .extra_field_length = try reader.readIntLittle(u16),
            .file_name = "",
        };
        var file_name = try allocator.alloc(u8, result.file_name_length);
        errdefer allocator.free(file_name);
        try reader.readNoEof(&file_name);
        result.file_name = file_name;
        // skip the extra field it's not interesting yet.
        try reader.skipBytes(result.extra_field_length, result.extra_field_length);
        return result;
    }

    pub fn deinit(self: *LocalFileHeader, allocator: std.mem.Allocator) void {
        allocator.free(self.file_name);
    }

    pub fn is_dir(self: *LocalFileHeader) bool {
        // This is what the java stdlib does, I don't know if there's a better way
        return std.mem.endsWith(u8, self.file_name, "/");
    }

    pub fn extract(self: *LocalFileHeader, allocator: std.mem.Allocator, reader: anytype, writer: anytype) !void {
        if (self.general_purpose_bit_flag.isSet(0)) return error.EncryptionNotSupported;

        // TODO support data descriptor segment
        // Bit 3: If this bit is set, the fields crc-32, compressed
        //    size and uncompressed size are set to zero in the
        //    local header.  The correct values are put in the
        //    data descriptor immediately following the compressed
        //    data.
        if (self.general_purpose_bit_flag.isSet(3)) return error.DataDescriptorNotSupported;

        if (self.is_dir()) {
            if (self.compressed_size != 0) {
                // directories can't have a size, this is very likely wrong.
                return error.InvalidFileName;
            }
            return; // Do nothing here, we'll automatically create directories that have files in (but we'll skip empty directories)
        }

        var lr = std.io.limitedReader(reader, self.compressed_size);
        var limited_reader = lr.reader();
        switch (self.compression_method) {
            .store => {
                try pumpAndCheck(limited_reader, writer, self.uncompressed_size, self.crc32);
            },
            .deflate => {
                var decomp = try std.compress.deflate.decompressor(allocator, limited_reader, null);
                defer decomp.deinit();
                var decomp_reader = decomp.reader();
                try pumpAndCheck(decomp_reader, writer, self.uncompressed_size, self.crc32);
            },
            .lzma => {
                var decomp = try std.compress.lzma.decompress(allocator, limited_reader);
                defer decomp.deinit();
                var decomp_reader = decomp.reader();
                try pumpAndCheck(decomp_reader, writer, self.uncompressed_size, self.crc32);
            },
            else => {
                return error.CompressionMethodNotSupported;
            },
        }
    }
};

/// Copy from reader to writer, checking the size and CRC32 checksum at the end.
fn pumpAndCheck(reader: anytype, writer: anytype, expected_size_written: usize, expected_crc32: u32) !void {
    // TODO is it interesting to customize this buffer size?
    var buf = [_]u8{0} ** 1024;
    var crc32 = std.hash.Crc32.init();
    var written: usize = 0;
    while (true) {
        const read = try reader.read(&buf);
        if (read == 0) break;
        const write = buf[0..read];
        try writer.writeAll(write);

        crc32.update(write);
        written += read;
    }
    if (written != expected_size_written) return error.WrongUncompressedSize;
    if (crc32.final() != expected_crc32) return error.WrongChecksum;
}

pub const Options = struct {
    allocator: std.mem.Allocator,
    // TODO support dignostics
};

/// It does a forwards-only pass of the ZIP file an extracts the content to dir.
/// Note that it does _not_ check the central directory (perhaps it should?)
pub fn pipeToFileSystem(dir: std.fs.Dir, reader: anytype, options: Options) !void {
    const allocator = options.allocator;
    while (true) {
        var lfh = LocalFileHeader.read(allocator, reader) catch |e| switch (e) {
            // TODO is there a better way to determine when we've finished reading the files?
            error.InvalidSignature => return, // done
            else => return e,
        };
        defer lfh.deinit(allocator);
        if (std.fs.path.dirname(lfh.file_name)) |dn| {
            try dir.makePath(dn);
        }
        if (!lfh.is_dir()) {
            // TODO support file metadata
            var f = try dir.createFile(lfh.file_name, .{});
            defer f.close();
            var writer = f.writer();
            try lfh.extract(allocator, reader, writer);
        }
    }
}

const std = @import("std.zig");
