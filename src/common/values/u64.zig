const std = @import("std");
const val = @import("value.zig");

pub const ValueU64 = struct {
    value: ?u64,

    pub fn init_empty() ValueU64 {
        return ValueU64{ .value = null };
    }

    pub fn init_with(value: ?u64) ValueU64 {
        return ValueU64{ .value = value };
    }

    pub fn show(self: *const ValueU64, end: u8) void {
        std.debug.print("{?}{c}", .{ self.value, end });
    }

    pub fn get_repr_type(_: *const ValueU64) []const u8 {
        return "u64";
    }

    pub fn is_null(self: *const ValueU64) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueU64) ?u64 {
        return self.value;
    }

    pub fn copy(self: *const ValueU64) ValueU64 {
        return ValueU64.init_with(self.value);
    }

    pub fn increment(self: *ValueU64) val.Value {
        const result = self.copy();
        self.value.? += 1;

        return val.Value{ .U64 = result };
    }

    pub fn decrement(self: *ValueU64) val.Value {
        const result = self.copy();
        self.value.? -= 1;

        return val.Value{ .U64 = result };
    }

    pub fn convert(self: *const ValueU64, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.String => {
                    var buffer: [21]u8 = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
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

    pub fn auto_convert(self: *const ValueU64, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.U8 => return val.Value{ .U8 = val.ValueU8.init_with(@truncate(value)) },
                val.ValueKind.U16 => return val.Value{ .U16 = val.ValueU16.init_with(@truncate(value)) },
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_with(@truncate(value)) },
                val.ValueKind.U64 => return val.Value{ .U64 = self.copy() },
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(value != 0) },
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_with(@truncate(value)) },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.U8 => return val.Value{ .U8 = val.ValueU8.init_empty() },
                val.ValueKind.U16 => return val.Value{ .U16 = val.ValueU16.init_empty() },
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_empty() },
                val.ValueKind.U64 => return val.Value{ .U64 = ValueU64.init_empty() },
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_empty() },

                else => return null,
            }
        }
    }
};
