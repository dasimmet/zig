const std = @import("std");

pub fn build(b: *std.Build) void {
    const test_step = b.step("test", "Test it");
    b.default_step = test_step;

    const dep1 = b.dependency("other", .{});

    const dep2 = b.dependencyFromBuildZig(@import("other"), .{});

    const this_dep = b.dependencyFromBuildZig(@This(), .{});

    std.debug.assert(this_dep.builder == b);

    std.debug.assert(dep1.module("add") == dep2.module("add"));
}
