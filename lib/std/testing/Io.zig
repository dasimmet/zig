const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;

gpa: std.mem.Allocator,
rand: std.Random.DefaultPrng,
file: struct {
    idx: std.AutoArrayHashMapUnmanaged(Io.File.Handle, void),
    parent: std.ArrayList(?Io.File.Handle),
    stat: std.ArrayList(Io.File.Stat),
    path: std.ArrayList(std.ArrayList(u8)),
    content: std.ArrayList(std.ArrayList(u8)),
},

pub fn init() @This() {
    return .{
        .gpa = std.testing.allocator,
        .rand = .init(std.testing.random_seed),
        .file = .{
            .idx = .empty,
            .parent = .empty,
            .stat = .empty,
            .path = .empty,
            .content = .empty,
        },
    };
}

pub fn deinit(self: *@This()) void {
    self.file.stat.deinit(self.gpa);
    self.file.parent.deinit(self.gpa);
    self.file.idx.deinit(self.gpa);
    for (self.file.path.items) |*path| {
        path.deinit(self.gpa);
    }
    self.file.path.deinit(self.gpa);
    for (self.file.content.items) |*content| {
        content.deinit(self.gpa);
    }
    self.file.content.deinit(self.gpa);
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
    const dir_gop = t.file.idx.getOrPut(t.gpa, dir.handle) catch unreachable;
    if (dir.handle == Io.Dir.cwd().handle) {
        if (!dir_gop.found_existing) {
            t.file.stat.append(t.gpa, .{
                .size = 0,
                .mode = 0o777,
                .kind = .directory,
                .inode = t.rand.random().int(@FieldType(Io.File.Stat, "inode")),
                .mtime = .zero,
                .ctime = .zero,
                .atime = .zero,
            }) catch unreachable;
            var cwd_path = std.ArrayList(u8).initCapacity(t.gpa, 1) catch unreachable;
            cwd_path.appendBounded('~') catch unreachable;
            t.file.path.append(t.gpa, cwd_path) catch unreachable;
            t.file.parent.append(t.gpa, null) catch unreachable;
            t.file.content.append(t.gpa, .empty) catch unreachable;
        }
    } else {
        assert(dir_gop.found_existing);
    }
    for (t.file.parent.items, t.file.path.items, 0..) |parent, path, i| {
        if (parent == dir_gop.key_ptr.* and std.mem.eql(u8, path.items, sub_path)) return .{ .handle = t.file.idx.keys()[i] };
    }
    const new_fd: Io.Dir = .{ .handle = t.rand.random().int(Io.File.Handle) };
    const file_gop = t.file.idx.getOrPut(t.gpa, new_fd.handle) catch unreachable;
    assert(file_gop.index == t.file.stat.items.len);
    assert(file_gop.index == t.file.path.items.len);
    assert(file_gop.index == t.file.parent.items.len);
    assert(file_gop.index == t.file.content.items.len);
    t.file.stat.append(t.gpa, .{
        .size = 0,
        .mode = 0o777,
        .kind = .directory,
        .inode = t.rand.random().int(@FieldType(Io.File.Stat, "inode")),
        .mtime = .zero,
        .ctime = .zero,
        .atime = .zero,
    }) catch unreachable;
    var path = std.ArrayList(u8).initCapacity(t.gpa, sub_path.len) catch unreachable;
    path.appendSliceBounded(sub_path) catch unreachable;
    t.file.path.append(t.gpa, path) catch unreachable;
    t.file.parent.append(t.gpa, dir_gop.key_ptr.*) catch unreachable;
    t.file.content.append(t.gpa, .empty) catch unreachable;
    return new_fd;
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
    const dir_gop = t.file.idx.getOrPut(t.gpa, dir.handle) catch @panic("OOM");
    assert(dir_gop.found_existing);
    for (t.file.parent.items, t.file.path.items, 0..) |parent, path, i| {
        if (parent == dir_gop.key_ptr.* and std.mem.eql(u8, path.items, sub_path)) {
            assert(t.file.stat.items[i].kind == .file);
            return .{ .handle = t.file.idx.keys()[i] };
        }
    }
    const new_fd: Io.File = .{ .handle = t.rand.random().int(Io.File.Handle) };
    const file_gop = t.file.idx.getOrPut(t.gpa, new_fd.handle) catch @panic("OOM");
    assert(file_gop.index == t.file.stat.items.len);
    assert(file_gop.index == t.file.path.items.len);
    assert(file_gop.index == t.file.parent.items.len);
    assert(file_gop.index == t.file.content.items.len);
    t.file.stat.append(t.gpa, .{
        .size = 0,
        .mode = flags.mode,
        .kind = .file,
        .inode = t.rand.random().int(@FieldType(Io.File.Stat, "inode")),
        .mtime = .zero,
        .ctime = .zero,
        .atime = .zero,
    }) catch unreachable;
    var path = std.ArrayList(u8).initCapacity(t.gpa, sub_path.len) catch @panic("OOM");
    path.appendSliceBounded(sub_path) catch @panic("OOM");
    t.file.path.append(t.gpa, path) catch @panic("OOM");
    t.file.parent.append(t.gpa, dir_gop.key_ptr.*) catch @panic("OOM");
    t.file.content.append(t.gpa, .empty) catch @panic("OOM");
    return new_fd;
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
    _ = t;
    _ = dir;
    @panic("TODO implement dirClose");
}

fn fileStat(userdata: ?*anyopaque, file: Io.File) Io.File.StatError!Io.File.Stat {
    _ = userdata;
    _ = file;
    @panic("TODO implement fileStat");
}

fn fileClose(userdata: ?*anyopaque, file: Io.File) void {
    const t: *@This() = @ptrCast(@alignCast(userdata));
    _ = t;
    _ = file;
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
    const file_gop = t.file.idx.getOrPut(t.gpa, file.handle) catch @panic("OOM");
    assert(file_gop.found_existing);
    const content = &t.file.content.items[file_gop.index];
    var acc: usize = 0;
    for (buffer) |buf| {
        content.insertSlice(t.gpa, offset + acc, buf) catch @panic("OOM");
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
    const file_gop = t.file.idx.getOrPut(t.gpa, file.handle) catch @panic("OOM");
    assert(file_gop.found_existing);
    const slice = t.file.content.items[file_gop.index].items;
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
