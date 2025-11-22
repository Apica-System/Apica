const std = @import("std");
const elt = @import("../common/element.zig");
const val = @import("../common/values/value.zig");
const date = @import("../utils/date.zig");
const ApicaSystem = @import("apica.zig").ApicaSystem;

pub const LoggerSystem = struct {
    apica: *ApicaSystem,
    actual_file: ?std.fs.File,
    actual_date: [10]u8,

    pub fn init(apica: *ApicaSystem, activate: bool) LoggerSystem {
        var buffer: [10]u8 = [10]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        if (activate) {
            date.get_actual_date(&buffer);
        }

        if (buffer[0] != 0) {
            var filepath: [15]u8 = undefined;
            _ = std.fmt.bufPrint(&filepath, "logs/{s}", .{buffer}) catch {};
            std.fs.cwd().makeDir(&filepath) catch {};
        }

        return LoggerSystem{ .apica = apica, .actual_file = null, .actual_date = buffer };
    }

    pub fn destroy(self: *LoggerSystem) void {
        if (self.actual_file) |file| {
            file.close();
        }
    }

    pub fn create_file_for(self: *LoggerSystem, app_name: []const u8) void {
        if (self.actual_date[0] == '\x00') {
            return;
        }

        if (self.actual_file) |file| {
            file.close();
            self.actual_file = null;
        }

        const filepath: []u8 = std.fmt.allocPrint(self.apica.get_allocator(), "logs/{s}/{s}.log", .{ self.actual_date, app_name }) catch {
            return;
        };

        self.actual_file = std.fs.cwd().createFile(filepath, .{}) catch null;
    }

    pub fn __logn_error(self: *const LoggerSystem, err_parts: []const []const u8) void {
        if (self.actual_file) |file| {
            file.writeAll("\x1b[31mAPC_ERR: ") catch {};
            for (err_parts) |part| {
                file.writeAll(part) catch {};
            }
            file.writeAll("\x1b[0m\n") catch {};
        }
    }

    fn log_parameters(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element), start: []const u8, end: []const u8) void {
        if (self.actual_file) |file| {
            file.writeAll(start) catch {};

            for (parameters.items) |param| {
                const converted = param.convert(val.ValueKind.String).get_value().String;

                if (converted.get_value()) |string| {
                    var length: usize = 0;
                    while (length < string.len and string[length] != 0) : (length += 1) {}

                    file.writeAll(string[0..length]) catch {};
                } else {
                    file.writeAll("null") catch {};
                }
            }

            file.writeAll(end) catch {};
        }
    }

    pub fn log_info(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[37mINF: ", "\x1b[0m");
    }

    pub fn logn_info(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[37mINF: ", "\x1b[0m\n");
    }

    pub fn log_success(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[32mSUC: ", "\x1b[0m");
    }

    pub fn logn_success(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[32mSUC: ", "\x1b[0m\n");
    }

    pub fn log_warning(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[33mWRN: ", "\x1b[0m");
    }

    pub fn logn_warning(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[33mWRN: ", "\x1b[0m\n");
    }

    pub fn log_error(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[31mERR: ", "\x1b[0m");
    }

    pub fn logn_error(self: *const LoggerSystem, parameters: std.ArrayList(elt.Element)) void {
        self.log_parameters(parameters, "\x1b[31mERR: ", "\x1b[0m\n");
    }
};
