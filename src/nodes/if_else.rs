use crate::nodes::node::Node;

pub struct NodeIfElse {
    condition: Node,
    if_body: Node,
    else_body: Node,
}

impl NodeIfElse {
    pub fn init(condition: Node, if_body: Node, else_body: Node) -> NodeIfElse {
        NodeIfElse { condition, if_body, else_body }
    }
    
    pub fn get_condition(&self) -> &Node {
        &self.condition
    }
    
    pub fn get_if_body(&self) -> &Node {
        &self.if_body
    }
    
    pub fn get_else_body(&self) -> &Node {
        &self.else_body
    }
}