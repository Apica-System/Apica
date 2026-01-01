use crate::nodes::_break::NodeBreak;
use crate::nodes::_continue::NodeContinue;
use crate::nodes::_if::NodeIf;
use crate::nodes::_while::NodeWhile;
use crate::nodes::add::NodeAdd;
use crate::nodes::blank_return::NodeBlankReturn;
use crate::nodes::builtin_func_call::NodeBuiltinFuncCall;
use crate::nodes::compound::NodeCompound;
use crate::nodes::const_decl::NodeConstDecl;
use crate::nodes::decrement::NodeDecrement;
use crate::nodes::global_scope::NodeGlobalScope;
use crate::nodes::if_else::NodeIfElse;
use crate::nodes::increment::NodeIncrement;
use crate::nodes::literal::NodeLiteral;
use crate::nodes::not::NodeNot;
use crate::nodes::ternary_op::NodeTernaryOp;
use crate::nodes::var_const_call::NodeVarConstCall;
use crate::nodes::var_decl::NodeVarDecl;

pub enum Node {
    Compound(NodeCompound),
    Literal(NodeLiteral),
    BuiltinFuncCall(NodeBuiltinFuncCall),
    GlobalScope(Box<NodeGlobalScope>),
    VarConstCall(NodeVarConstCall),
    VarDecl(Box<NodeVarDecl>),
    ConstDecl(Box<NodeConstDecl>),

    Add(Box<NodeAdd>),
    Increment(Box<NodeIncrement>),
    Decrement(Box<NodeDecrement>),
    Not(Box<NodeNot>),
    TernaryOp(Box<NodeTernaryOp>),

    If(Box<NodeIf>),
    IfElse(Box<NodeIfElse>),
    While(Box<NodeWhile>),

    Break(NodeBreak),
    Continue(NodeContinue),
    BlankReturn(NodeBlankReturn),
}