const std = @import("std");
const ApicaSystem = @import("systems/apica.zig").ApicaSystem;

pub fn main() u8 {
    // Initialize the main allocator
    const main_allocator = std.heap.page_allocator;

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
