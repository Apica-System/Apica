use apica_common::bytecodes::ApicaTypeBytecode;
use crate::nodes::node::Node;

pub struct NodeVarDecl {
    name: String,
    value_kind: ApicaTypeBytecode,
    expression: Node,
}

impl NodeVarDecl {
    pub fn init(name: String, value_kind: ApicaTypeBytecode, expression: Node) -> NodeVarDecl {
        NodeVarDecl { name, value_kind, expression }
    }
    
    pub fn get_name(&self) -> &String {
        &self.name
    }
    
    pub fn get_value_kind(&self) -> &ApicaTypeBytecode {
        &self.value_kind
    }
    
    pub fn get_expression(&self) -> &Node {
        &self.expression
    }
}