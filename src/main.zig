const std = @import("std");
const ApicaSystem = @import("systems/apica.zig").ApicaSystem;
const GL = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn main() u8 {
    if (GL.glfwInit() == 0) {
        return 10;
    }
    defer GL.glfwTerminate();

    // Initialize the main allocator
    //var gpa = std.heap.DebugAllocator(.{}){};
    const main_allocator = std.heap.page_allocator; //gpa.allocator();

    // Initialize Apica system and run it
    if (ApicaSystem.init(main_allocator)) |apica_system| {
        defer apica_system.destroy();
        apica_system.load_app("APICA_MENU");

        while (apica_system.is_running()) {
            apica_system.update_system();
        }

        return 0;
    }

    return 1;
}
