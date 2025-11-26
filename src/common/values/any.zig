const std = @import("std");
const val = @import("value.zig");

pub const ValueAny = struct {
    value: ?*val.Value,

    pub fn init_empty() ValueAny {
        return ValueAny{ .value = null };
    }

    pub fn init_with(value: ?*val.Value) ValueAny {
        return ValueAny{ .value = value };
    }

    pub fn show(self: *const ValueAny, end: u8) void {
        std.debug.print("any<", .{});
        if (self.value) |value| {
            value.show('\x00');
            std.debug.print(">{c}", .{end});
        } else {
            std.debug.print("null>{c}", .{end});
        }
    }

    pub fn is_null(self: *const ValueAny) bool {
        return self.value == null;
    }

    pub fn get_repr_type(self: *const ValueAny) []const u8 {
        if (self.value) |value| {
            return value.get_repr_type();
        } else {
            return "any<null>";
        }
    }

    pub fn delete(self: *const ValueAny) void {
        if (self.value) |value| {
            value.delete();
            std.heap.smp_allocator.destroy(value);
        }
    }

    pub fn get_value(self: *const ValueAny) ?*val.Value {
        return self.value;
    }

    pub fn increment(self: *ValueAny) ?val.Value {
        return self.value.?.increment();
    }

    pub fn decrement(self: *ValueAny) ?val.Value {
        return self.value.?.decrement();
    }

    pub fn convert(self: *const ValueAny, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            return value.convert(to);
        }

        return null;
    }

    pub fn auto_convert(self: *const ValueAny, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            return value.auto_convert(to);
        }

        return null;
    }
};
