const std = @import("std");
const Io = std.Io;

gpa: std.mem.Allocator,
file: struct {
    const Fd = union(enum) {
        Dir: Io.Dir,
        File: Io.File,
    };
    idx: std.AutoArrayHashMapUnmanaged(Fd, void),
    stat: std.ArrayList(Io.File.Stat),
},

pub fn init() @This() {
    return .{
        .gpa = std.testing.allocator,
        .file = .{
            .idx = .empty,
            .stat = .empty,
        },
    };
}

pub fn deinit(self: @This()) void {
    _ = self;
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
    _ = sub_path;
    _ = options;
    const dir_gop = t.file.idx.getOrPut(t.gpa, .{ .Dir = dir }) catch unreachable;
    if (dir.handle == Io.Dir.cwd().handle) {
        t.file.stat.append(t.gpa, .{}) catch unreachable;
    } else {
        std.debug.assert(dir_gop.found_existing);
    }
    const new_fd: Io.File = .{};
    const file_gop = t.file.idx.getOrPut(t.gpa, .{ .File = new_fd }) catch unreachable;
    std.debug.assert(file_gop.index == t.file.stat.le)
    @panic("TODO implement dirMakeOpenPath");
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
    _ = t;
    _ = dir;
    _ = sub_path;
    _ = flags;
    @panic("TODO implement dirCreateFile");
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
    @panic("TODO implement fileClose");
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
    while (true) {
        _ = t;
        // try t.checkCancel();
        _ = file;
        _ = buffer;
        _ = offset;
        @panic("TODO implement fileWritePositional");
    }
}

fn fileReadStreaming(userdata: ?*anyopaque, file: Io.File, data: [][]u8) Io.File.Reader.Error!usize {
    _ = userdata;
    _ = file;
    _ = data;
    @panic("TODO implement fileReadStreaming");
}

fn fileReadPositional(userdata: ?*anyopaque, file: Io.File, data: [][]u8, offset: u64) Io.File.ReadPositionalError!usize {
    _ = userdata;
    _ = file;
    _ = data;
    _ = offset;
    @panic("TODO implement fileReadPositional");
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
