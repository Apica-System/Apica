const std = @import("std");
const val = @import("value.zig");

pub const ValueBool = struct {
    value: ?bool,

    pub fn init_empty() ValueBool {
        return ValueBool{ .value = null };
    }

    pub fn init_with(value: ?bool) ValueBool {
        return ValueBool{ .value = value };
    }

    pub fn show(self: *const ValueBool, end: u8) void {
        std.debug.print("{?}{c}", .{ self.value, end });
    }

    pub fn is_null(self: *const ValueBool) bool {
        return self.value == null;
    }

    pub fn get_repr_type(_: *const ValueBool) []const u8 {
        return "bool";
    }

    pub fn get_value(self: *const ValueBool) ?bool {
        return self.value;
    }

    pub fn copy(self: *const ValueBool) ValueBool {
        return ValueBool.init_with(self.value);
    }

    pub fn convert(self: *const ValueBool, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_with(if (value) 1 else 0) },
                val.ValueKind.String => return val.Value{ .String = val.ValueString.init_with(if (value) "true" else "false", false) },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_empty() },
                val.ValueKind.String => return val.Value{ .String = val.ValueString.init_empty() },

                else => return null,
            }
        }
    }

    pub fn auto_convert(self: *const ValueBool, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.U8 => return val.Value{ .U8 = val.ValueU8.init_with(if (value) 1 else 0) },
                val.ValueKind.U16 => return val.Value{ .U16 = val.ValueU16.init_with(if (value) 1 else 0) },
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_with(if (value) 1 else 0) },
                val.ValueKind.U64 => return val.Value{ .U64 = val.ValueU64.init_with(if (value) 1 else 0) },
                val.ValueKind.Bool => return val.Value{ .Bool = self.copy() },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.U8 => return val.Value{ .U8 = val.ValueU8.init_empty() },
                val.ValueKind.U16 => return val.Value{ .U16 = val.ValueU16.init_empty() },
                val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_empty() },
                val.ValueKind.U64 => return val.Value{ .U64 = val.ValueU64.init_empty() },
                val.ValueKind.Bool => return val.Value{ .Bool = ValueBool.init_empty() },

                else => return null,
            }
        }
    }
};
