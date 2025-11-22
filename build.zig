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

    exe.addIncludePath(b.path("libs/glfw3/include"));
    exe.addIncludePath(b.path("libs/glad/include"));
    exe.root_module.addCSourceFile(.{ .file = b.path("src/glad.c"), .flags = &.{"-std=c99"} });

    switch (target.result.os.tag) {
        .windows => {
            exe.addLibraryPath(b.path("libs/glfw3/lib"));
            exe.linkSystemLibrary("glfw3");
            exe.linkSystemLibrary("opengl32");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("user32");
            exe.linkSystemLibrary("kernel32");
        },
        .linux => {
            exe.linkSystemLibrary("glfw");
            exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("X11");
            exe.linkSystemLibrary("pthread");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
        },
        .macos => {
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            exe.linkFramework("CoreVideo");
            exe.linkSystemLibrary("glfw");
            exe.linkFramework("OpenGL");
        },
        else => {},
    }

    //const zglfw = b.dependency("zglfw", .{});
    //exe.root_module.addImport("zglfw", zglfw.module("root"));

    //if (target.result.os.tag != .emscripten) {
    //    exe.linkLibrary(zglfw.artifact("glfw"));
    //}

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
