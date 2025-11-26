const std = @import("std");
const val = @import("value.zig");

pub const ValueF32 = struct {
    value: ?f32,

    pub fn init_empty() ValueF32 {
        return ValueF32{ .value = null };
    }

    pub fn init_with(value: ?f32) ValueF32 {
        return ValueF32{ .value = value };
    }

    pub fn show(self: *const ValueF32, end: u8) void {
        std.debug.print("{?}{c}", .{ self.value, end });
    }

    pub fn get_repr_type(_: *const ValueF32) []const u8 {
        return "f32";
    }

    pub fn is_null(self: *const ValueF32) bool {
        return self.value == null;
    }

    pub fn get_value(self: *const ValueF32) ?f32 {
        return self.value;
    }

    pub fn copy(self: *const ValueF32) ValueF32 {
        return ValueF32.init_with(self.value);
    }

    pub fn increment(self: *ValueF32) val.Value {
        const result = self.copy();
        self.value.? += 1;

        return val.Value{ .F32 = result };
    }

    pub fn decrement(self: *ValueF32) val.Value {
        const result = self.copy();
        self.value.? -= 1;

        return val.Value{ .F32 = result };
    }

    pub fn convert(_: *const ValueF32, _: val.ValueKind) ?val.Value {
        return null;
    }

    pub fn auto_convert(_: *const ValueF32, _: val.ValueKind) ?val.Value {
        return null;
    }
};
