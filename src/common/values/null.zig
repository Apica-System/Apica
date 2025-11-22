const std = @import("std");
const val = @import("value.zig");

pub const ValueNull = struct {
    pub fn init_empty() ValueNull {
        return ValueNull{};
    }

    pub fn show(_: *const ValueNull, end: u8) void {
        std.debug.print("null{c}", .{end});
    }

    pub fn is_null(_: *const ValueNull) bool {
        return true;
    }

    pub fn copy(_: *const ValueNull) ValueNull {
        return ValueNull{};
    }

    pub fn convert(_: *const ValueNull, _: val.ValueKind) ?val.Value {
        return null; // All automatically
    }

    pub fn auto_convert(_: *const ValueNull, to: val.ValueKind) ?val.Value {
        switch (to) {
            val.ValueKind.Null => return val.Value{ .Null = ValueNull.init_empty() },
            val.ValueKind.ElementPointer => return null,
            val.ValueKind.U32 => return val.Value{ .U32 = val.ValueU32.init_empty() },
            val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },
            val.ValueKind.Char => return val.Value{ .Char = val.ValueChar.init_empty() },
            val.ValueKind.String => return val.Value{ .String = val.ValueString.init_empty() },
        }
    }
};
