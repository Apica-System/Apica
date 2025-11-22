const nd = @import("node.zig");
const bytecode = @import("../common/bytecodes.zig");

pub const NodeConstDecl = struct {
    name: []const u8,
    vtype: bytecode.ApicaTypeBytecode,
    expression: *nd.Node,

    pub fn init(name: []const u8, vtype: bytecode.ApicaTypeBytecode, expr: *nd.Node) NodeConstDecl {
        return NodeConstDecl{ .name = name, .vtype = vtype, .expression = expr };
    }

    pub fn get_name(self: *const NodeConstDecl) []const u8 {
        return self.name;
    }

    pub fn get_vtype(self: *const NodeConstDecl) bytecode.ApicaTypeBytecode {
        return self.vtype;
    }

    pub fn get_expression(self: *const NodeConstDecl) *nd.Node {
        return self.expression;
    }
};
