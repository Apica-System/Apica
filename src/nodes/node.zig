const std = @import("std");
const ApicaSystem = @import("../systems/apica.zig").ApicaSystem;

pub const NodeCompound = @import("compound.zig").NodeCompound;
pub const NodeLiteral = @import("literal.zig").NodeLiteral;
pub const NodeBuiltinFuncCall = @import("builtin_func_call.zig").NodeBuiltinFuncCall;
pub const NodeGlobalScope = @import("global_scope.zig").NodeGlobalScope;
pub const NodeVarConstCall = @import("var_const_call.zig").NodeVarConstCall;
pub const NodeVarDecl = @import("var_decl.zig").NodeVarDecl;
pub const NodeConstDecl = @import("const_decl.zig").NodeConstDecl;
pub const NodeIncrement = @import("increment.zig").NodeIncrement;
pub const NodeDecrement = @import("decrement.zig").NodeDecrement;
pub const NodeQuestionOperation = @import("question_operation.zig").NodeQuestionOperation;
pub const NodeIf = @import("if.zig").NodeIf;
pub const NodeIfElse = @import("if_else.zig").NodeIfElse;
pub const NodeWhile = @import("while.zig").NodeWhile;
pub const NodeBreak = @import("break.zig").NodeBreak;
pub const NodeContinue = @import("continue.zig").NodeContinue;

pub const NodeKind = enum(u8) {
    Compound,
    Literal,
    BuiltinFuncCall,
    GlobalScope,
    VarConstCall,
    VarDecl,
    ConstDecl,

    Increment,
    Decrement,
    QuestionOperation,

    If,
    IfElse,
    While,

    Break,
    Continue,
};

pub const Node = union(NodeKind) {
    Compound: NodeCompound,
    Literal: NodeLiteral,
    BuiltinFuncCall: NodeBuiltinFuncCall,
    GlobalScope: NodeGlobalScope,
    VarConstCall: NodeVarConstCall,
    VarDecl: NodeVarDecl,
    ConstDecl: NodeConstDecl,
    Increment: NodeIncrement,
    Decrement: NodeDecrement,
    QuestionOperation: NodeQuestionOperation,
    If: NodeIf,
    IfElse: NodeIfElse,
    While: NodeWhile,
    Break: NodeBreak,
    Continue: NodeContinue,

    pub fn get_kind(self: *const Node) NodeKind {
        switch (self.*) {
            .Compound => return NodeKind.Compound,
            .Literal => return NodeKind.Literal,
            .BuiltinFuncCall => return NodeKind.BuiltinFuncCall,
            .GlobalScope => return NodeKind.GlobalScope,
            .VarConstCall => return NodeKind.VarConstCall,
            .VarDecl => return NodeKind.VarDecl,
            .ConstDecl => return NodeKind.ConstDecl,
            .Increment => return NodeKind.Increment,
            .Decrement => return NodeKind.Decrement,
            .QuestionOperation => return NodeKind.QuestionOperation,
            .If => return NodeKind.If,
            .IfElse => return NodeKind.IfElse,
            .While => return NodeKind.While,
            .Break => return NodeKind.Break,
            .Continue => return NodeKind.Continue,
        }
    }

    pub fn allocate_new(allocator: std.mem.Allocator) ?*Node {
        const node = allocator.create(Node) catch {
            return null;
        };

        return node;
    }
};
