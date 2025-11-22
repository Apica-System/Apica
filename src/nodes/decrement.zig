const nd = @import("node.zig");

pub const NodeDecrement = struct {
    operand: *nd.Node,

    pub fn init(operand: *nd.Node) NodeDecrement {
        return NodeDecrement{ .operand = operand };
    }

    pub fn get_operand(self: *const NodeDecrement) *nd.Node {
        return self.operand;
    }
};
