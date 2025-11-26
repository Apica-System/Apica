const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Apica",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const os = target.result.os.tag;
    switch (os) {
        .linux => {
            exe.linkSystemLibrary("glfw");
            exe.linkSystemLibrary("vulkan");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("pthread");
            exe.linkSystemLibrary("X11");
            exe.linkLibC();
        },
        .windows => {
            exe.linkSystemLibrary("glfw3");
            exe.linkSystemLibrary("vulkan-1");
            exe.linkSystemLibrary("user32");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("shell32");
        },
        .macos => {
            exe.linkSystemLibrary("glfw");
            exe.linkSystemLibrary("MoltenVK");
            exe.linkFramework("Cocoa");
            exe.linkFramework("QuartzCore");
            exe.linkLibC();
        },
        else => {},
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
