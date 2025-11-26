const std = @import("std");
const val = @import("value.zig");

pub const ValueF64 = struct {
    value: ?f64,

    pub fn init_empty() ValueF64 {
        return ValueF64{ .value = null };
    }

    pub fn init_with(value: ?f64) ValueF64 {
        return ValueF64{ .value = value };
    }

    pub fn show(self: *const ValueF64, end: u8) void {
        std.debug.print("{?}{c}", .{ self.value, end });
    }

    pub fn get_repr_type(_: *const ValueF64) []const u8 {
        return "f64";
    }

    pub fn is_null(self: *const ValueF64) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueF64) ?f64 {
        return self.value;
    }

    pub fn copy(self: *const ValueF64) ValueF64 {
        return ValueF64.init_with(self.value);
    }

    pub fn increment(self: *ValueF64) val.Value {
        const result = self.copy();
        self.value.? += 1;

        return val.Value{ .F64 = result };
    }

    pub fn decrement(self: *ValueF64) val.Value {
        const result = self.copy();
        self.value.? -= 1;

        return val.Value{ .F64 = result };
    }

    pub fn convert(_: *const ValueF64, _: val.ValueKind) ?val.Value {
        return null;
    }

    pub fn auto_convert(_: *const ValueF64, _: val.ValueKind) ?val.Value {
        return null;
    }
};
