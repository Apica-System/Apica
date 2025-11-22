const val = @import("values/value.zig");

pub const ElementModifier = enum(u8) {
    None = 0b00000000,
    Error = 0b00000001,
    Const = 0b00000010,
};

pub const Element = struct {
    value: val.Value,
    modifier: u8,

    pub fn init(value: val.Value, modifier: u8) Element {
        return Element{ .value = value, .modifier = modifier };
    }

    pub fn create_null() Element {
        return Element.init(val.Value{ .Null = val.ValueNull.init_empty() }, @intFromEnum(ElementModifier.None));
    }

    pub fn create_error() Element {
        return Element.init(val.Value{ .Null = val.ValueNull.init_empty() }, @intFromEnum(ElementModifier.Error));
    }

    pub fn get_value(self: *const Element) val.Value {
        return self.value;
    }

    pub fn get_value_pointer(self: *Element) *val.Value {
        return &self.value;
    }

    pub fn get_modifier(self: *const Element) u8 {
        return self.modifier;
    }

    pub fn add_modifier(self: *Element, modifier: ElementModifier) void {
        self.modifier |= @intFromEnum(modifier);
    }

    pub fn increment(self: *Element) Element {
        if (self.modifier & @intFromEnum(ElementModifier.Const) != 0) {
            return Element.create_error();
        }

        if (self.value.is_null()) {
            return Element.create_error();
        }

        if (self.value.increment()) |result| {
            return Element.init(result, @intFromEnum(ElementModifier.None));
        } else {
            return Element.create_error();
        }
    }

    pub fn decrement(self: *Element) Element {
        if (self.modifier & @intFromEnum(ElementModifier.Const) != 0) {
            return Element.create_error();
        }

        if (self.value.is_null()) {
            return Element.create_error();
        }

        if (self.value.decrement()) |result| {
            return Element.init(result, @intFromEnum(ElementModifier.None));
        } else {
            return Element.create_error();
        }
    }

    pub fn convert(self: *const Element, to: val.ValueKind) Element {
        if (self.value.convert(to)) |result| {
            return Element.init(result, @intFromEnum(ElementModifier.None));
        } else {
            return Element.create_error();
        }
    }

    pub fn auto_convert(self: *const Element, to: val.ValueKind) Element {
        if (self.value.auto_convert(to)) |result| {
            return Element.init(result, @intFromEnum(ElementModifier.None));
        } else {
            return Element.create_error();
        }
    }
};
