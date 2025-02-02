/// an os-dependent abstraction on ipc
const builtin = @import("builtin");
const std = @import("std.zig");
const windows = std.os.windows;
const posix = std.posix;

pub const PipeError = switch (builtin.os.tag) {
    .windows => error{
        OutOfMemory,
    },
    else => posix.PipeError,
};

pub const Handle = switch (builtin.os.tag) {
    .windows => windows.HANDLE,
    else => posix.fd_t,
};

pub const Pipe = [2]Handle;

pub inline fn pipe() PipeError!Pipe {
    return switch (builtin.os.tag) {
        .windows => pipeWindows(),
        else => posix.pipe2(.{ .NONBLOCK = true, .CLOEXEC = true }),
    };
}

var pipe_name_counter = std.atomic.Value(u32).init(1);

pub fn pipeWindows() PipeError!Pipe {
    const named_pipe_tpl = "\\\\.\\pipe\\LOCAL\\zig-ipc-{d}-{d}";
    const named_pipe_bufsize = named_pipe_tpl.len + (20 - 3) * 2;

    const acc: Pipe = .{
        undefined,
        undefined,
    };
    for (acc) |*acc_pipe| {
        var pipe_path_buf: [named_pipe_bufsize]u8 = undefined;
        var pipe_path_buf_w: [named_pipe_bufsize]u16 = undefined;
        const pipe_path = std.fmt.bufPrintZ(
            &pipe_path_buf,
            named_pipe_tpl,
            .{
                windows.kernel32.GetCurrentProcessId(),
                pipe_name_counter.fetchAdd(1, .monotonic),
            },
        ) catch unreachable;

        const pipe_path_w_len = std.unicode.utf8ToUtf16Le(
            &pipe_path_buf_w,
            pipe_path,
        ) catch unreachable;
        pipe_path_buf_w[pipe_path_w_len] = 0;
        const pipe_path_w = pipe_path_buf_w[0..pipe_path_w_len :0];

        const security_attributes = windows.SECURITY_ATTRIBUTES{
            .nLength = @sizeOf(windows.SECURITY_ATTRIBUTES),
            .bInheritHandle = windows.FALSE,
            .lpSecurityDescriptor = null,
        };

        acc_pipe.* = windows.kernel32.CreateNamedPipeW(
            pipe_path_w.ptr,
            windows.PIPE_ACCESS_OUTBOUND |
                windows.exp.FILE_FLAG_FIRST_PIPE_INSTANCE |
                windows.FILE_FLAG_OVERLAPPED,
            windows.PIPE_TYPE_BYTE,
            1,
            4096,
            4096,
            0,
            &security_attributes,
        );
    }
    return acc;
}
