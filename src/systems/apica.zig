const std = @import("std");
const ApicaRight = @import("../utils/enums.zig").ApicaRight;
const ApicaMode = @import("../utils/enums.zig").ApicaMode;
const bytecode = @import("../common/bytecodes.zig");
const version = @import("../utils/version.zig");

const BytecodeReaderSystem = @import("reader.zig").BytecodeReaderSystem;
const LoggerSystem = @import("logger.zig").LoggerSystem;
const EvaluatorSystem = @import("evaluator.zig").EvaluatorSystem;

pub const ApicaSystem = struct {
    arena: std.heap.ArenaAllocator,
    allocator: std.mem.Allocator,

    actual_mode: ApicaMode,
    actual_right: u8,

    reader: BytecodeReaderSystem,
    logger: LoggerSystem,
    evaluator: EvaluatorSystem,

    pub fn init(main_allocator: std.mem.Allocator) ?*ApicaSystem {
        var self = std.heap.page_allocator.create(ApicaSystem) catch {
            return null;
        };

        self.* = ApicaSystem{
            .arena = std.heap.ArenaAllocator.init(main_allocator),
            .allocator = undefined,
            .actual_mode = ApicaMode.Init,
            .actual_right = @intFromEnum(ApicaRight.MainMenu),

            .reader = undefined,
            .logger = undefined,
            .evaluator = undefined,
        };

        self.allocator = self.arena.allocator();
        self.reader = BytecodeReaderSystem.init(self);
        self.logger = LoggerSystem.init(self, true);

        if (EvaluatorSystem.init(self)) |evaluator| {
            self.evaluator = evaluator;
        } else {
            return null;
        }

        return self;
    }

    pub fn destroy(self: *ApicaSystem) void {
        self.logger.destroy();
        self.reader.destroy();
        self.evaluator.destroy();

        self.arena.deinit();
        std.heap.page_allocator.destroy(self);
    }

    pub fn get_allocator(self: *const ApicaSystem) std.mem.Allocator {
        return self.allocator;
    }

    pub fn get_logger(self: *const ApicaSystem) LoggerSystem {
        return self.logger;
    }

    pub fn is_running(self: *const ApicaSystem) bool {
        return self.actual_mode != ApicaMode.SpecialQuit;
    }

    pub fn quit_app(self: *ApicaSystem) void {
        if (self.actual_right & @intFromEnum(ApicaRight.App_Right) == 0) {
            return;
        }

        self.actual_mode = ApicaMode.Quit;
    }

    pub fn load_app(self: *ApicaSystem, app_name: []const u8) void {
        if (self.actual_right & @intFromEnum(ApicaRight.App_Right) == 0) {
            return;
        }

        if (!self.evaluator.clear_data()) {
            self.actual_mode = ApicaMode.SpecialQuit;
            return;
        }

        if (self.arena.queryCapacity() > 0) {
            _ = self.arena.reset(.retain_capacity);
            self.allocator = self.arena.allocator();
        }

        self.logger.create_file_for(app_name);
        self.reader.read_app(app_name);
    }

    pub fn update_system(self: *ApicaSystem) void {
        switch (self.actual_mode) {
            ApicaMode.Init => {
                const init_node = self.reader.get_entry_node(bytecode.ApicaEntrypointBytecode.Init);
                if (init_node) |r_init| {
                    self.evaluator.evaluate(r_init);
                } else {
                    self.logger.__logn_error(&.{"Failed to load the init entrypoint of the app"});
                }

                self.actual_mode = ApicaMode.Update;
            },

            ApicaMode.Update => {
                const update_node = self.reader.get_entry_node(bytecode.ApicaEntrypointBytecode.Update);
                if (update_node) |r_update| {
                    self.evaluator.evaluate(r_update);
                } else {
                    self.logger.__logn_error(&.{"Failed to load the update entrypoint of the app"});
                    self.actual_mode = ApicaMode.Quit;
                }
            },

            ApicaMode.Quit => {
                const quit_node = self.reader.get_entry_node(bytecode.ApicaEntrypointBytecode.Quit);
                if (quit_node) |r_quit| {
                    self.evaluator.evaluate(r_quit);
                } else {
                    self.logger.__logn_error(&.{"Failed to load the quit entrypoint of the app"});
                }

                switch (self.actual_right) {
                    @intFromEnum(ApicaRight.MainMenu) => self.actual_mode = ApicaMode.SpecialQuit,
                    @intFromEnum(ApicaRight.App) => {
                        self.actual_mode = ApicaMode.Init;
                        self.actual_right = @intFromEnum(ApicaRight.MainMenu);
                        self.load_app("APICA_MENU");
                    },

                    else => {},
                }
            },

            ApicaMode.SpecialQuit => {},
        }
    }

    pub fn get_apica_version_major(_: *ApicaSystem) u64 {
        return version.VERSION_MAJOR;
    }

    pub fn get_apica_version_minor(_: *ApicaSystem) u64 {
        return version.VERSION_MINOR;
    }
};
