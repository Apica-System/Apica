const std = @import("std");
const nd = @import("node.zig");
const bytecode = @import("../common/bytecodes.zig");

pub const NodeBuiltinFuncCall = struct {
    func_bytecode: bytecode.ApicaBuiltinFuncCallBytecode,
    parameters: std.ArrayList(*nd.Node),

    pub fn init(func_bytecode: bytecode.ApicaBuiltinFuncCallBytecode, params: std.ArrayList(*nd.Node)) NodeBuiltinFuncCall {
        return NodeBuiltinFuncCall{ .func_bytecode = func_bytecode, .parameters = params };
    }

    pub fn get_func_bytecode(self: *const NodeBuiltinFuncCall) bytecode.ApicaBuiltinFuncCallBytecode {
        return self.func_bytecode;
    }

    pub fn get_parameters(self: *const NodeBuiltinFuncCall) std.ArrayList(*nd.Node) {
        return self.parameters;
    }
};
