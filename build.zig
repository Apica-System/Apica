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
            exe.addLibraryPath(b.path("/usr/lib/x86_64-linux-gnu"));
            exe.linkSystemLibrary("glfw");
            exe.linkSystemLibrary("vulkan");
            exe.linkSystemLibrary("X11");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("pthread");
            exe.linkLibC();
        },

        .windows => {
            const envMap = std.process.getEnvMap(std.heap.page_allocator) catch @panic("Allocation error");
            const vulkan_sdk = envMap.get("VULKAN_SDK") orelse
                @panic("Install Vulkan SDK and set VULKAN_SDK env var");

            exe.addIncludePath(b.path(b.pathJoin(&.{ vulkan_sdk, "Include" })));
            exe.addLibraryPath(b.path(b.pathJoin(&.{ vulkan_sdk, "Lib" })));
            exe.linkSystemLibrary("glfw3");

            exe.addIncludePath(b.path("libs/glfw/include"));
            exe.addLibraryPath(b.path("libs/glfw/lib"));
            exe.linkSystemLibrary("vulkan-1");

            exe.linkSystemLibrary("user32");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("shell32");
        },

        .macos => {
            exe.addIncludePath(b.path("/usr/local/include"));
            exe.addLibraryPath(b.path("/usr/local/lib"));
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
