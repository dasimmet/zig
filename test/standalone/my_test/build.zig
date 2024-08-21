const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    inline for (.{
        .{ target, optimize },
        .{ b.host, optimize },
        .{ b.host, .Debug },
        .{ b.host, .ReleaseFast },
        .{ b.host, .ReleaseSmall },
        .{ b.host, .ReleaseSafe },
    }) |args| {
        const run = myBuildInterfaceFn(b, .{
            .target = args[0],
            .optimize = args[1],
        });
        b.default_step.dependOn(&run.step);
    }
}

pub const BuildOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

pub fn myBuildInterfaceFn(b: *std.Build, opt: BuildOptions) *std.Build.Step.Run {
    const this_dep = b.dependencyFromBuildZig(@This(), .{});
    const exe = b.addExecutable(.{
        .name = "main_zig_from_this_dep",
        .root_source_file = this_dep.path("main.zig"),
        .target = opt.target,
        .optimize = opt.optimize,
    });
    return b.addRunArtifact(exe);
}
