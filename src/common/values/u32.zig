const std = @import("std");
const val = @import("value.zig");

pub const ValueU32 = struct {
    value: ?u32,

    pub fn init_empty() ValueU32 {
        return ValueU32{ .value = null };
    }

    pub fn init_with(value: ?u32) ValueU32 {
        return ValueU32{ .value = value };
    }

    pub fn show(self: *const ValueU32, end: u8) void {
        std.debug.print("{?}{c}", .{ self.value, end });
    }

    pub fn is_null(self: *const ValueU32) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueU32) ?u32 {
        return self.value;
    }

    pub fn copy(self: *const ValueU32) ValueU32 {
        return ValueU32.init_with(self.value);
    }

    pub fn increment(self: *ValueU32) val.Value {
        const result = self.copy();
        self.value.? += 1;

        return val.Value{ .U32 = result };
    }

    pub fn decrement(self: *ValueU32) val.Value {
        const result = self.copy();
        self.value.? -= 1;

        return val.Value{ .U32 = result };
    }

    pub fn convert(self: *const ValueU32, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.String => {
                    var buffer: [11]u8 = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
                    _ = std.fmt.bufPrint(&buffer, "{}", .{value}) catch {};
                    return val.Value{ .String = val.ValueString.init_with(&buffer) };
                },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.String => return val.Value{ .String = val.ValueString.init_empty() },

                else => return null,
            }
        }
    }

    pub fn auto_convert(self: *const ValueU32, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.U32 => return val.Value{ .U32 = self.copy() },
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(value != 0) },
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_with(value) },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.U32 => return val.Value{ .U32 = ValueU32.init_empty() },
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_empty() },

                else => return null,
            }
        }
    }
};
