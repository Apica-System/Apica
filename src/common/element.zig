const val = @import("values/value.zig");

pub const ElementModifier = enum(u8) {
    None = 0b00000000,
    Error = 0b00000001,
    Const = 0b00000010,
    Controller = 0b00000100,
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

    pub fn create_error(value: val.Value) Element {
        return Element.init(value, @intFromEnum(ElementModifier.Error));
    }

    pub fn is_error_or_controller(self: *const Element) bool {
        return (self.modifier & @intFromEnum(ElementModifier.Error) != 0) or (self.modifier & @intFromEnum(ElementModifier.Controller) != 0);
    }

    pub fn check_convert(self: *const Element, to: val.ValueKind) Element {
        if (self.value.get_kind() == to) {
            return self.*;
        }

        const converted = self.convert(to);
        self.delete();
        return converted;
    }

    pub fn check_auto_convert(self: *const Element, to: val.ValueKind) Element {
        if (self.value.get_kind() == to) {
            return self.*;
        }

        const converted = self.auto_convert(to);
        self.delete();
        return converted;
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

    pub fn delete(self: *const Element) void {
        self.value.delete();
    }

    pub fn increment(self: *Element) Element {
        if (self.modifier & @intFromEnum(ElementModifier.Const) != 0) {
            return Element.create_error(val.Value.constant_error());
        }

        if (self.value.is_null()) {
            return Element.create_error(val.Value.null_operation_error("++", false));
        }

        if (self.value.increment()) |result| {
            if (result.get_kind() == val.ValueKind.Error) {
                return Element.create_error(result);
            } else {
                return Element.init(result, @intFromEnum(ElementModifier.None));
            }
        } else {
            return Element.create_error(val.Value.unary_operation_error("++", self.value.get_repr_type()));
        }
    }

    pub fn decrement(self: *Element) Element {
        if (self.modifier & @intFromEnum(ElementModifier.Const) != 0) {
            return Element.create_error(val.Value.constant_error());
        }

        if (self.value.is_null()) {
            return Element.create_error(val.Value.null_operation_error("++", false));
        }

        if (self.value.decrement()) |result| {
            if (result.get_kind() == val.ValueKind.Error) {
                return Element.create_error(result);
            } else {
                return Element.init(result, @intFromEnum(ElementModifier.None));
            }
        } else {
            return Element.create_error(val.Value.unary_operation_error("--", self.value.get_repr_type()));
        }
    }

    pub fn convert(self: *const Element, to: val.ValueKind) Element {
        if (self.value.convert(to)) |result| {
            if (result.get_kind() == val.ValueKind.Error) {
                return Element.create_error(result);
            } else {
                return Element.init(result, @intFromEnum(ElementModifier.None));
            }
        } else {
            return Element.create_error(val.Value.binary_operation_error("as", self.value.get_repr_type(), val.value_kind_to_string(to)));
        }
    }

    pub fn auto_convert(self: *const Element, to: val.ValueKind) Element {
        if (self.value.auto_convert(to)) |result| {
            if (result.get_kind() == val.ValueKind.Error and !result.is_null()) {
                return Element.create_error(result);
            } else {
                return Element.init(result, @intFromEnum(ElementModifier.None));
            }
        } else {
            return Element.create_error(val.Value.binary_operation_error("auto-as", self.value.get_repr_type(), val.value_kind_to_string(to)));
        }
    }
};
