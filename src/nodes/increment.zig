const nd = @import("node.zig");

pub const NodeIncrement = struct {
    operand: *nd.Node,

    pub fn init(operand: *nd.Node) NodeIncrement {
        return NodeIncrement{ .operand = operand };
    }

    pub fn get_operand(self: *const NodeIncrement) *nd.Node {
        return self.operand;
    }
};
