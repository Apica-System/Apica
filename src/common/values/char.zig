const std = @import("std");
const val = @import("value.zig");

pub const ValueChar = struct {
    value: ?u32,

    pub fn init_empty() ValueChar {
        return ValueChar{ .value = null };
    }

    pub fn init_with(value: ?u32) ValueChar {
        return ValueChar{ .value = value };
    }

    pub fn show(self: *const ValueChar, end: u8) void {
        if (self.value) |value| {
            const bytes: [4]u8 = @bitCast(value);
            std.debug.print("{s}{c}", .{ bytes, end });
        } else {
            std.debug.print("null{c}", .{end});
        }
    }

    pub fn is_null(self: *const ValueChar) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueChar) ?u32 {
        return self.value;
    }

    pub fn copy(self: *const ValueChar) ValueChar {
        return ValueChar.init_with(self.value);
    }

    pub fn increment(self: *ValueChar) val.Value {
        const result = self.copy();
        self.value.? += 1;

        return val.Value{ .Char = result };
    }

    pub fn decrement(self: *ValueChar) val.Value {
        const result = self.copy();
        self.value.? -= 1;

        return val.Value{ .Char = result };
    }

    pub fn convert(self: *const ValueChar, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(value != 0) },
                val.ValueKind.String => {
                    const buffer: [4]u8 = @bitCast(value);
                    return val.Value{ .String = val.ValueString.init_with(&buffer) };
                },

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

    pub fn auto_convert(self: *const ValueChar, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_with(value) },
                val.ValueKind.Char => return val.Value{ .Char = self.copy() },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_empty() },
                val.ValueKind.Char => return val.Value{ .Char = ValueChar.init_empty() },

                else => return null,
            }
        }
    }
};
