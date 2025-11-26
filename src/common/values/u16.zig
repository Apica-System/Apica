const std = @import("std");
const val = @import("value.zig");

pub const ValueU16 = struct {
    value: ?u16,

    pub fn init_empty() ValueU16 {
        return ValueU16{ .value = null };
    }

    pub fn init_with(value: ?u16) ValueU16 {
        return ValueU16{ .value = value };
    }

    pub fn show(self: *const ValueU16, end: u8) void {
        std.debug.print("{?}{c}", .{ self.value, end });
    }

    pub fn get_repr_type(_: *const ValueU16) []const u8 {
        return "u16";
    }

    pub fn is_null(self: *const ValueU16) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueU16) ?u16 {
        return self.value;
    }

    pub fn copy(self: *const ValueU16) ValueU16 {
        return ValueU16.init_with(self.value);
    }

    pub fn increment(self: *ValueU16) val.Value {
        const result = self.copy();
        self.value.? += 1;

        return val.Value{ .U16 = result };
    }

    pub fn decrement(self: *ValueU16) val.Value {
        const result = self.copy();
        self.value.? -= 1;

        return val.Value{ .U16 = result };
    }

    pub fn convert(self: *const ValueU16, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.String => {
                    var buffer: [6]u8 = [_]u8{ 0, 0, 0, 0, 0, 0 };
                    _ = std.fmt.bufPrint(&buffer, "{}", .{value}) catch {};

                    return val.Value{ .String = val.ValueString.init_with(&buffer, false) };
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

    pub fn auto_convert(self: *const ValueU16, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.U8 => return val.Value{ .U8 = val.ValueU8.init_with(@truncate(value)) },
                val.ValueKind.U16 => return val.Value{ .U16 = self.copy() },
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_with(value) },
                val.ValueKind.U64 => return val.Value{ .U64 = val.ValueU64.init_with(value) },
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(value != 0) },
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_with(value) },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.U8 => return val.Value{ .U8 = val.ValueU8.init_empty() },
                val.ValueKind.U16 => return val.Value{ .U16 = ValueU16.init_empty() },
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_empty() },
                val.ValueKind.U64 => return val.Value{ .U64 = val.ValueU64.init_empty() },
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_empty() },

                else => return null,
            }
        }
    }
};
