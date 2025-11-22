const nd = @import("node.zig");

pub const NodeIfElse = struct {
    condition: *nd.Node,
    if_body: *nd.Node,
    else_body: *nd.Node,

    pub fn init(condition: *nd.Node, if_body: *nd.Node, else_body: *nd.Node) NodeIfElse {
        return NodeIfElse{ .condition = condition, .if_body = if_body, .else_body = else_body };
    }

    pub fn get_condition(self: *const NodeIfElse) *nd.Node {
        return self.condition;
    }

    pub fn get_if_body(self: *const NodeIfElse) *nd.Node {
        return self.if_body;
    }

    pub fn get_else_body(self: *const NodeIfElse) *nd.Node {
        return self.else_body;
    }
};
