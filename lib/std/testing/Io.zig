const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;

gpa: std.mem.Allocator,
rand: std.Random.DefaultPrng,
file: struct {
    const Handle = enum(usize) { _ };
    const File = struct {
        parent: ?Handle,
        stat: Io.File.Stat,
        path: std.ArrayList(u8),
        content: std.ArrayList(u8),
    };
    handle: std.ArrayList(?Handle),
    file: std.MultiArrayList(File),

    fn getHandle(self: @This(), fh: Io.File.Handle) *?Handle {
        if (fh == Io.Dir.cwd().handle) {
            return &self.handle.items[0];
        }
        const fhu: usize = @intCast(fh);
        return &self.handle.items[fhu];
    }

    fn getField(self: @This(), fh: Io.File.Handle, field: anytype) *@FieldType(File, @tagName(field)) {
        if (fh == Io.Dir.cwd().handle) {
            return &self.file.items(field)[0];
        }
        const fhu: usize = @intCast(fh);
        if (self.handle.items.len < fhu) @panic("FileHandleNotFound");
        if (self.handle.items[fhu]) |fnum| {
            return &self.file.items(field)[@intFromEnum(fnum)];
        }
        @panic("FileHandleClosed");
    }

    fn get(self: @This(), fh: Io.File.Handle) struct { Handle, File } {
        if (fh == Io.Dir.cwd().handle) {
            return .{ @enumFromInt(0), self.file.get(0) };
        }
        const fhu: usize = @intCast(fh);
        if (self.handle.items.len < fhu) @panic("FileHandleNotFound");
        if (self.handle.items[fhu]) |fnum| {
            return .{ fnum, self.file.get(@intFromEnum(fnum)) };
        }
        @panic("FileHandleClosed");
    }

    fn newHandle(self: *@This(), gpa: std.mem.Allocator, idx: Handle) Io.File.Handle {
        self.handle.append(gpa, idx) catch @panic("OOM");
        return @intCast(self.handle.items.len - 1);
    }
},

pub fn init() @This() {
    var self: @This() = .{
        .gpa = std.testing.allocator,
        .rand = .init(std.testing.random_seed),
        .file = .{
            .handle = .empty,
            .file = .empty,
        },
    };
    self.file.handle.append(self.gpa, @enumFromInt(0)) catch @panic("OOM");
    self.file.file.append(self.gpa, .{
        .content = .empty,
        .path = .initBuffer(self.gpa.dupe(u8, "~") catch @panic("OOM")),
        .parent = null,
        .stat = .{
            .size = 0,
            .mode = 0o777,
            .kind = .directory,
            .inode = self.rand.random().int(@FieldType(Io.File.Stat, "inode")),
            .mtime = .zero,
            .ctime = .zero,
            .atime = .zero,
        },
    }) catch @panic("OOM");
    return self;
}

pub fn deinit(self: *@This()) void {
    for (self.file.handle.items, 0..) |fh, i| {
        if (i == 0) continue;
        assert(fh == null);
    }
    self.file.handle.deinit(self.gpa);
    for (self.file.file.items(.path), 0..) |*path, i| {
        path.deinit(self.gpa);
        self.file.file.items(.content)[i].deinit(self.gpa);
    }
    self.file.file.deinit(self.gpa);
}

pub fn io(t: *@This()) Io {
    return .{
        .userdata = t,
        .vtable = &.{
            .async = async,
            .concurrent = concurrent,
            .await = await,
            .cancel = cancel,
            .cancelRequested = cancelRequested,
            .groupAsync = groupAsync,
            .groupWait = groupWait,
            .groupCancel = groupCancel,
            .select = select,
            .mutexLock = mutexLock,
            .mutexLockUncancelable = mutexLockUncancelable,
            .mutexUnlock = mutexUnlock,
            .conditionWait = conditionWait,
            .conditionWaitUncancelable = conditionWaitUncancelable,
            .conditionWake = conditionWake,
            .dirMake = dirMake,
            .dirMakePath = dirMakePath,
            .dirMakeOpenPath = dirMakeOpenPath,
            .dirStat = dirStat,
            .dirStatPath = dirStatPath,
            .dirAccess = dirAccess,
            .dirCreateFile = dirCreateFile,
            .dirOpenFile = dirOpenFile,
            .dirOpenDir = dirOpenDir,
            .dirClose = dirClose,
            .fileStat = fileStat,
            .fileClose = fileClose,
            .fileWriteStreaming = fileWriteStreaming,
            .fileWritePositional = fileWritePositional,
            .fileReadStreaming = fileReadStreaming,
            .fileReadPositional = fileReadPositional,
            .fileSeekBy = fileSeekBy,
            .fileSeekTo = fileSeekTo,
            .openSelfExe = openSelfExe,
            .now = now,
            .sleep = sleep,
            .netListenIp = netListenIp,
            .netAccept = netAccept,
            .netBindIp = netBindIp,
            .netConnectIp = netConnectIp,
            .netListenUnix = netListenUnix,
            .netConnectUnix = netConnectUnix,
            .netSend = netSend,
            .netReceive = netReceive,
            .netRead = netRead,
            .netWrite = netWrite,
            .netClose = netClose,
            .netInterfaceNameResolve = netInterfaceNameResolve,
            .netInterfaceName = netInterfaceName,
            .netLookup = netLookup,
        },
    };
}

fn cancelRequested(userdata: ?*anyopaque) bool {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    return false;
}

fn checkCancel(t: *@This()) error{Canceled}!void {
    if (cancelRequested(t)) return error.Canceled;
}

fn concurrent(
    /// Corresponds to `Io.userdata`.
    userdata: ?*anyopaque,
    result_len: usize,
    result_alignment: std.mem.Alignment,
    /// Copied and then passed to `start`.
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (context: *const anyopaque, result: *anyopaque) void,
) Io.ConcurrentError!*std.Io.AnyFuture {
    _ = userdata;
    _ = result_len;
    _ = context;
    _ = context_alignment;
    _ = result_alignment;
    _ = start;
    return error.ConcurrencyUnavailable;
}

fn async(
    userdata: ?*anyopaque,
    result: []u8,
    result_alignment: std.mem.Alignment,
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (context: *const anyopaque, result: *anyopaque) void,
) ?*Io.AnyFuture {
    _ = userdata;
    _ = result;
    _ = result_alignment;
    _ = context;
    _ = context_alignment;
    _ = start;
    @panic("TODO implement async");
}

fn await(
    userdata: ?*anyopaque,
    any_future: *std.Io.AnyFuture,
    result: []u8,
    result_alignment: std.mem.Alignment,
) void {
    _ = userdata;
    _ = any_future;
    _ = result;
    _ = result_alignment;
    @panic("TODO implement await");
}

fn cancel(
    userdata: ?*anyopaque,
    any_future: *Io.AnyFuture,
    result: []u8,
    result_alignment: std.mem.Alignment,
) void {
    _ = userdata;
    _ = any_future;
    _ = result;
    _ = result_alignment;
    @panic("TODO implement cancel");
}

fn groupAsync(
    userdata: ?*anyopaque,
    group: *Io.Group,
    context: []const u8,
    context_alignment: std.mem.Alignment,
    start: *const fn (*Io.Group, context: *const anyopaque) void,
) void {
    _ = userdata;
    _ = group;
    _ = context;
    _ = context_alignment;
    _ = start;
    @panic("TODO implement groupAsync");
}

fn groupWait(userdata: ?*anyopaque, group: *Io.Group, token: *anyopaque) void {
    _ = userdata;
    _ = group;
    _ = token;
    @panic("TODO implement groupWait");
}

fn groupCancel(userdata: ?*anyopaque, group: *Io.Group, token: *anyopaque) void {
    _ = userdata;
    _ = group;
    _ = token;
    @panic("TODO implement groupCancel");
}

fn select(userdata: ?*anyopaque, futures: []const *Io.AnyFuture) Io.Cancelable!usize {
    _ = userdata;
    _ = futures;
    @panic("TODO implement select");
}

fn mutexLock(userdata: ?*anyopaque, prev_state: Io.Mutex.State, mutex: *Io.Mutex) Io.Cancelable!void {
    _ = userdata;
    _ = prev_state;
    _ = mutex;
    @panic("TODO implement mutexLock");
}

fn mutexLockUncancelable(userdata: ?*anyopaque, prev_state: Io.Mutex.State, mutex: *Io.Mutex) void {
    _ = userdata;
    _ = prev_state;
    _ = mutex;
    @panic("TODO implement mutexUnlockUncancelable");
}

fn mutexUnlock(userdata: ?*anyopaque, prev_state: Io.Mutex.State, mutex: *Io.Mutex) void {
    _ = userdata;
    _ = prev_state;
    _ = mutex;
    @panic("TODO implement mutexUnlock");
}

fn conditionWaitUncancelable(userdata: ?*anyopaque, cond: *Io.Condition, mutex: *Io.Mutex) void {
    _ = userdata;
    _ = cond;
    _ = mutex;
    @panic("TODO implement conditionWaitUncancelable");
}

fn conditionWait(userdata: ?*anyopaque, cond: *Io.Condition, mutex: *Io.Mutex) Io.Cancelable!void {
    _ = userdata;
    _ = cond;
    _ = mutex;
    @panic("TODO implement conditionWait");
}

fn conditionWake(userdata: ?*anyopaque, cond: *Io.Condition, wake: Io.Condition.Wake) void {
    _ = userdata;
    _ = cond;
    _ = wake;
    @panic("TODO implement conditionWake");
}

fn dirMake(userdata: ?*anyopaque, dir: Io.Dir, sub_path: []const u8, mode: Io.Dir.Mode) Io.Dir.MakeError!void {
    _ = userdata;
    _ = dir;
    _ = sub_path;
    _ = mode;
    @panic("TODO implement dirMake");
}

fn dirMakeOpenPath(
    userdata: ?*anyopaque,
    dir: Io.Dir,
    sub_path: []const u8,
    options: Io.Dir.OpenOptions,
) Io.Dir.MakeOpenPathError!Io.Dir {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = options;
    const dir_entry = t.file.get(dir.handle);
    for (t.file.file.items(.parent), t.file.file.items(.path), 0..) |parent, path, i| {
        if (parent == dir_entry[1].parent and std.mem.eql(u8, path.items, sub_path)) {
            assert(t.file.file.items(.stat)[i].kind == .directory);
            return .{ .handle = t.file.newHandle(t.gpa, @enumFromInt(i)) };
        }
    }
    t.file.file.append(t.gpa, .{
        .content = .empty,
        .parent = dir_entry[0],
        .path = .initBuffer(t.gpa.dupe(u8, sub_path) catch @panic("OOM")),
        .stat = .{
            .size = 0,
            .mode = 0o777,
            .kind = .directory,
            .inode = t.rand.random().int(@FieldType(Io.File.Stat, "inode")),
            .mtime = .zero,
            .ctime = .zero,
            .atime = .zero,
        },
    }) catch @panic("OOM");
    return .{ .handle = t.file.newHandle(t.gpa, @enumFromInt(t.file.file.len - 1)) };
}

fn dirMakePath(userdata: ?*anyopaque, dir: Io.Dir, sub_path: []const u8, mode: Io.Dir.Mode) Io.Dir.MakeError!void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = dir;
    _ = sub_path;
    _ = mode;
    @panic("TODO implement dirMakePath");
}

fn dirStat(userdata: ?*anyopaque, dir: Io.Dir) Io.Dir.StatError!Io.Dir.Stat {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = dir;
    @panic("TODO implement dirStat");
}

fn dirStatPath(
    userdata: ?*anyopaque,
    dir: Io.Dir,
    sub_path: []const u8,
    options: Io.Dir.StatPathOptions,
) Io.Dir.StatPathError!Io.File.Stat {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = dir;
    _ = sub_path;
    _ = options;
    @panic("TODO implement dirStatPath");
}

fn dirAccess(
    userdata: ?*anyopaque,
    dir: Io.Dir,
    sub_path: []const u8,
    options: Io.Dir.AccessOptions,
) Io.Dir.AccessError!void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = dir;
    _ = sub_path;
    _ = options;
    @panic("TODO implement dirAccess");
}

fn dirCreateFile(
    userdata: ?*anyopaque,
    dir: Io.Dir,
    sub_path: []const u8,
    flags: Io.File.CreateFlags,
) Io.File.OpenError!Io.File {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    const dir_entry = t.file.get(dir.handle);
    for (t.file.file.items(.parent), t.file.file.items(.path), 0..) |parent, path, i| {
        if (parent == dir_entry[1].parent and std.mem.eql(u8, path.items, sub_path)) {
            assert(t.file.file.items(.stat)[i].kind == .file);
            return .{ .handle = t.file.newHandle(t.gpa, @enumFromInt(i)) };
        }
    }
    t.file.file.append(t.gpa, .{
        .content = .empty,
        .parent = dir_entry[0],
        .path = .initBuffer(t.gpa.dupe(u8, sub_path) catch @panic("OOM")),
        .stat = .{
            .size = 0,
            .mode = flags.mode,
            .kind = .file,
            .inode = t.rand.random().int(@FieldType(Io.File.Stat, "inode")),
            .mtime = .zero,
            .ctime = .zero,
            .atime = .zero,
        },
    }) catch @panic("OOM");
    return .{ .handle = t.file.newHandle(t.gpa, @enumFromInt(t.file.file.len - 1)) };
}

fn dirOpenFile(
    userdata: ?*anyopaque,
    dir: Io.Dir,
    sub_path: []const u8,
    flags: Io.File.OpenFlags,
) Io.File.OpenError!Io.File {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = dir;
    _ = sub_path;
    _ = flags;
    @panic("TODO implement dirOpenFile");
}

fn dirOpenDir(
    userdata: ?*anyopaque,
    dir: Io.Dir,
    sub_path: []const u8,
    options: Io.Dir.OpenOptions,
) Io.Dir.OpenError!Io.Dir {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = dir;
    _ = sub_path;
    _ = options;
    @panic("TODO implement dirOpenFile");
}

fn dirClose(userdata: ?*anyopaque, dir: Io.Dir) void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    t.file.getHandle(dir.handle).* = null;
}

fn fileStat(userdata: ?*anyopaque, file: Io.File) Io.File.StatError!Io.File.Stat {
    _ = userdata;
    _ = file;
    @panic("TODO implement fileStat");
}

fn fileClose(userdata: ?*anyopaque, file: Io.File) void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    t.file.getHandle(file.handle).* = null;
}

fn fileWriteStreaming(userdata: ?*anyopaque, file: Io.File, buffer: [][]const u8) Io.File.WriteStreamingError!usize {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    while (true) {
        _ = t;
        // try t.checkCancel();
        _ = file;
        _ = buffer;
        @panic("TODO implement fileWriteStreaming");
    }
}

fn fileWritePositional(
    userdata: ?*anyopaque,
    file: Io.File,
    buffer: [][]const u8,
    offset: u64,
) Io.File.WritePositionalError!usize {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    var acc: usize = 0;
    const content: *std.ArrayList(u8) = t.file.getField(file.handle, .content);
    for (buffer) |buf| {
        const end = offset + acc + buf.len;
        if (end > content.items.len)
            content.resize(t.gpa, end) catch @panic("OOM");
        @memcpy(content.items[offset + acc .. end], buf);
        acc += buf.len;
    }
    return acc;
}

fn fileReadStreaming(userdata: ?*anyopaque, file: Io.File, data: [][]u8) Io.File.Reader.Error!usize {
    _ = userdata;
    _ = file;
    _ = data;
    @panic("TODO implement fileReadStreaming");
}

fn fileReadPositional(userdata: ?*anyopaque, file: Io.File, data: [][]u8, offset: u64) Io.File.ReadPositionalError!usize {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    try t.checkCancel();
    const content = t.file.getField(file.handle, .content);
    const slice = content.items;
    var acc: usize = offset;
    for (data) |d| {
        const end = offset + d.len;
        assert(end <= slice.len);
        @memcpy(d, slice[acc..end]);
        acc = end;
    }
    return acc - offset;
}

fn fileSeekBy(userdata: ?*anyopaque, file: Io.File, offset: i64) Io.File.SeekError!void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    try t.checkCancel();

    _ = file;
    _ = offset;
    @panic("TODO implement fileSeekBy");
}

fn fileSeekTo(userdata: ?*anyopaque, file: Io.File, offset: u64) Io.File.SeekError!void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    try t.checkCancel();
    _ = file;
    _ = offset;
    @panic("TODO implement fileSeekTo");
}

fn openSelfExe(userdata: ?*anyopaque, flags: Io.File.OpenFlags) Io.File.OpenSelfExeError!Io.File {
    _ = userdata;
    _ = flags;
    @panic("TODO implement openSelfExe");
}

fn now(userdata: ?*anyopaque, clock: Io.Clock) Io.Clock.Error!Io.Timestamp {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = clock;
    @panic("TODO implement now");
}

fn sleep(userdata: ?*anyopaque, timeout: Io.Timeout) Io.SleepError!void {
    _ = userdata;
    _ = timeout;
    @panic("TODO implement sleep");
}

fn netListenIp(
    userdata: ?*anyopaque,
    address: Io.net.IpAddress,
    options: Io.net.IpAddress.ListenOptions,
) Io.net.IpAddress.ListenError!Io.net.Server {
    _ = userdata;
    _ = address;
    _ = options;
    @panic("TODO implement netListenIp");
}

fn netAccept(userdata: ?*anyopaque, listen_fd: Io.net.Socket.Handle) Io.net.Server.AcceptError!Io.net.Stream {
    _ = userdata;
    _ = listen_fd;
    @panic("TODO implement netAccept");
}

fn netBindIp(
    userdata: ?*anyopaque,
    address: *const Io.net.IpAddress,
    options: Io.net.IpAddress.BindOptions,
) Io.net.IpAddress.BindError!Io.net.Socket {
    _ = userdata;
    _ = address;
    _ = options;
    @panic("TODO implement netBindIp");
}

fn netConnectIp(
    userdata: ?*anyopaque,
    address: *const Io.net.IpAddress,
    options: Io.net.IpAddress.ConnectOptions,
) Io.net.IpAddress.ConnectError!Io.net.Stream {
    _ = userdata;
    _ = address;
    _ = options;
    @panic("TODO implement netConnectIp");
}

fn netListenUnix(
    userdata: ?*anyopaque,
    address: *const Io.net.UnixAddress,
    options: Io.net.UnixAddress.ListenOptions,
) Io.net.UnixAddress.ListenError!Io.net.Socket.Handle {
    _ = userdata;
    _ = address;
    _ = options;
    return error.AddressFamilyUnsupported;
}

fn netConnectUnix(
    userdata: ?*anyopaque,
    address: *const Io.net.UnixAddress,
) Io.net.UnixAddress.ConnectError!Io.net.Socket.Handle {
    _ = userdata;
    _ = address;
    return error.AddressFamilyUnsupported;
}

fn netSend(
    userdata: ?*anyopaque,
    handle: Io.net.Socket.Handle,
    messages: []Io.net.OutgoingMessage,
    flags: Io.net.SendFlags,
) struct { ?Io.net.Socket.SendError, usize } {
    _ = userdata;
    _ = handle;
    _ = messages;
    _ = flags;
    return .{ error.NetworkDown, 0 };
}

fn netReceive(
    userdata: ?*anyopaque,
    handle: Io.net.Socket.Handle,
    message_buffer: []Io.net.IncomingMessage,
    data_buffer: []u8,
    flags: Io.net.ReceiveFlags,
    timeout: Io.Timeout,
) struct { ?Io.net.Socket.ReceiveTimeoutError, usize } {
    _ = userdata;
    _ = handle;
    _ = message_buffer;
    _ = data_buffer;
    _ = flags;
    _ = timeout;
    @panic("TODO implement netReceive");
}

fn netRead(userdata: ?*anyopaque, fd: Io.net.Socket.Handle, data: [][]u8) Io.net.Stream.Reader.Error!usize {
    _ = userdata;
    _ = fd;
    _ = data;
    return error.NetworkDown;
}

fn netWrite(
    userdata: ?*anyopaque,
    fd: Io.net.Socket.Handle,
    header: []const u8,
    data: []const []const u8,
    splat: usize,
) Io.net.Stream.Writer.Error!usize {
    _ = userdata;
    _ = fd;
    _ = header;
    _ = data;
    _ = splat;
    return error.NetworkDown;
}

fn netClose(userdata: ?*anyopaque, handle: Io.net.Socket.Handle) void {
    _ = userdata;
    _ = handle;
    @panic("TODO implement netClose");
}

fn netInterfaceNameResolve(
    userdata: ?*anyopaque,
    name: *const Io.net.Interface.Name,
) Io.net.Interface.Name.ResolveError!Io.net.Interface {
    _ = userdata;
    _ = name;
    @panic("TODO implement netInterfaceNameResolve");
}

fn netInterfaceName(
    userdata: ?*anyopaque,
    interface: Io.net.Interface,
) Io.net.Interface.NameError!Io.net.Interface.Name {
    _ = userdata;
    _ = interface;
    @panic("TODO implement netInterfaceName");
}

fn netLookup(
    userdata: ?*anyopaque,
    host_name: Io.net.HostName,
    resolved: *Io.Queue(Io.net.HostName.LookupResult),
    options: Io.net.HostName.LookupOptions,
) void {
    _ = host_name;
    _ = options;
    _ = resolved;
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    @panic("TODO implement netLookup");
}

test "file io interface" {
    const content = "All your base are belong to us!";
    var testio: @This() = .init();
    defer testio.deinit();
    const io_instance = testio.io();

    const test_dir = try std.Io.Dir.cwd().makeOpenPath(io_instance, "test", .{});
    defer test_dir.close(io_instance);

    const fd = try test_dir.createFile(io_instance, "my_open_file", .{ .read = true });
    defer fd.close(io_instance);

    var content_array: [1][]const u8 = .{content};
    _ = try fd.writePositional(io_instance, &content_array, 0);

    var fd_reader = fd.reader(io_instance, &.{});
    try fd_reader.seekTo(0);
    var result: [content.len]u8 = undefined;
    var result_array: [1][]u8 = .{&result};
    const result_size = try fd.readPositional(io_instance, &result_array, 0);
    try std.testing.expectEqual(result_size, content.len);
    try std.testing.expectEqualSlices(u8, content, &result);

    std.log.info("testing my interface: {any}", .{fd});
}
