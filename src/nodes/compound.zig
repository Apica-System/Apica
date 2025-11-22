const std = @import("std");
const nd = @import("node.zig");

pub const NodeCompound = struct {
    nodes: std.ArrayList(*nd.Node),

    pub fn init(nodes: std.ArrayList(*nd.Node)) NodeCompound {
        return NodeCompound{ .nodes = nodes };
    }

    pub fn get_nodes(self: *const NodeCompound) std.ArrayList(*nd.Node) {
        return self.nodes;
    }
};
