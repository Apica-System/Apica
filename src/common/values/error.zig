const std = @import("std");
const val = @import("value.zig");

pub const ValueError = struct {
    name: ?[]const u8,
    details: ?[]const u8,

    pub fn init_empty() ValueError {
        return ValueError{ .name = null, .details = null };
    }

    pub fn init_with(name: ?[]const u8, details: ?[]const u8) ValueError {
        return ValueError{ .name = name, .details = details };
    }

    pub fn show(self: *const ValueError, end: u8) void {
        std.debug.print("error<{?s}: {?s}>{c}", .{ self.name, self.details, end });
    }

    pub fn is_null(self: *const ValueError) bool {
        return self.name == null;
    }

    pub fn get_name(self: *const ValueError) ?[]const u8 {
        return self.name;
    }

    pub fn get_details(self: *const ValueError) ?[]const u8 {
        return self.details;
    }

    pub fn copy(self: *const ValueError) ValueError {
        return ValueError.init_with(self.name, self.details);
    }

    pub fn convert(self: *const ValueError, to: val.ValueKind) ?val.Value {
        if (self.name) |name| {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(true) },
                val.ValueKind.String => {},

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },
                val.ValueKind.String => return val.Value{ .String = val.ValueString.init_empty() },

                else => return null,
            }
        }
    }

    pub fn auto_convert(self: *const ValueError, _: val.ValueKind) ?val.Value {
        return null;
    }
};
