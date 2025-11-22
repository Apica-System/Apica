const nd = @import("node.zig");
const val = @import("../common/values/value.zig");

pub const NodeLiteral = struct {
    value: val.Value,

    pub fn init(value: val.Value) NodeLiteral {
        return NodeLiteral{ .value = value };
    }

    pub fn get_value(self: *const NodeLiteral) val.Value {
        return self.value;
    }
};
