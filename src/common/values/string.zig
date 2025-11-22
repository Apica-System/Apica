const std = @import("std");
const val = @import("value.zig");

pub const ValueString = struct {
    value: ?[]const u8,

    pub fn init_empty() ValueString {
        return ValueString{ .value = null };
    }

    pub fn init_with(value: ?[]const u8) ValueString {
        return ValueString{ .value = value };
    }

    pub fn show(self: *const ValueString, end: u8) void {
        std.debug.print("{?s}{c}", .{ self.value, end });
    }

    pub fn is_null(self: *const ValueString) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueString) ?[]const u8 {
        return self.value;
    }

    pub fn copy(self: *const ValueString) ValueString {
        return ValueString.init_with(self.value);
    }

    pub fn convert(self: *const ValueString, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(value.len != 0) },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },

                else => return null,
            }
        }
    }

    pub fn auto_convert(self: *const ValueString, to: val.ValueKind) ?val.Value {
        if (self.value) |_| {
            switch (to) {
                val.ValueKind.String => return val.Value{ .String = self.copy() },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.String => return val.Value{ .String = ValueString.init_empty() },

                else => return null,
            }
        }
    }
};
