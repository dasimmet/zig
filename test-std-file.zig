const std = @import("std");

test "test-readPositional" {
    var threaded = std.Io.Threaded.init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();
    const cwd = std.Io.Dir.cwd();

    const fd = try cwd.createFile(io, "test_file.zig", .{
        .read = true,
    });
    defer fd.close(io);
    _ = try fd.writePositional(io, &.{"asdf"}, 0);

    var buf: [4]u8 = undefined;
    const bufs: []const []u8 = &.{&buf};
    _ = try fd.readPositional(io, bufs, 0);
}
