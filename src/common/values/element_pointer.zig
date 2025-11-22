const std = @import("std");
const val = @import("value.zig");
const Element = @import("../element.zig").Element;

pub const ValueElementPointer = struct {
    pointer: *Element,

    pub fn init_with(pointer: *Element) ValueElementPointer {
        return ValueElementPointer{ .pointer = pointer };
    }

    pub fn show(_: *const ValueElementPointer, end: u8) void {
        std.debug.print("sp-pointer<>{c}", .{end});
    }

    pub fn get_pointer(self: *const ValueElementPointer) *Element {
        return self.pointer;
    }

    pub fn is_null(self: *const ValueElementPointer) bool {
        return self.pointer.get_value().is_null();
    }

    pub fn increment(self: *ValueElementPointer) ?val.Value {
        return self.pointer.get_value_pointer().increment();
    }

    pub fn decrement(self: *ValueElementPointer) ?val.Value {
        return self.pointer.get_value_pointer().decrement();
    }

    pub fn convert(self: *const ValueElementPointer, to: val.ValueKind) ?val.Value {
        return self.pointer.get_value().convert(to);
    }

    pub fn auto_convert(self: *const ValueElementPointer, to: val.ValueKind) ?val.Value {
        return self.pointer.get_value().auto_convert(to);
    }
};
