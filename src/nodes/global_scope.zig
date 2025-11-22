const nd = @import("node.zig");

pub const NodeGlobalScope = struct {
    statement: *nd.Node,

    pub fn init(statement: *nd.Node) NodeGlobalScope {
        return NodeGlobalScope{ .statement = statement };
    }

    pub fn get_statement(self: *const NodeGlobalScope) *nd.Node {
        return self.statement;
    }
};
