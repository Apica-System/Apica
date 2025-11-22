const nd = @import("node.zig");
const bytecode = @import("../common/bytecodes.zig");

pub const NodeVarDecl = struct {
    name: []const u8,
    vtype: bytecode.ApicaTypeBytecode,
    expression: *nd.Node,

    pub fn init(name: []const u8, vtype: bytecode.ApicaTypeBytecode, expr: *nd.Node) NodeVarDecl {
        return NodeVarDecl{ .name = name, .vtype = vtype, .expression = expr };
    }

    pub fn get_name(self: *const NodeVarDecl) []const u8 {
        return self.name;
    }

    pub fn get_vtype(self: *const NodeVarDecl) bytecode.ApicaTypeBytecode {
        return self.vtype;
    }

    pub fn get_expression(self: *const NodeVarDecl) *nd.Node {
        return self.expression;
    }
};
