const nd = @import("node.zig");

pub const NodeIf = struct {
    condition: *nd.Node,
    body: *nd.Node,

    pub fn init(condition: *nd.Node, body: *nd.Node) NodeIf {
        return NodeIf{ .condition = condition, .body = body };
    }

    pub fn get_condition(self: *const NodeIf) *nd.Node {
        return self.condition;
    }

    pub fn get_body(self: *const NodeIf) *nd.Node {
        return self.body;
    }
};
