const nd = @import("node.zig");

pub const NodeWhile = struct {
    condition: *nd.Node,
    body: *nd.Node,

    pub fn init(condition: *nd.Node, body: *nd.Node) NodeWhile {
        return NodeWhile{ .condition = condition, .body = body };
    }

    pub fn get_condition(self: *const NodeWhile) *nd.Node {
        return self.condition;
    }

    pub fn get_body(self: *const NodeWhile) *nd.Node {
        return self.body;
    }
};
