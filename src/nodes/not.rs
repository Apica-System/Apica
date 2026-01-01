use crate::nodes::node::Node;

pub struct NodeNot {
    operand: Node,
}

impl NodeNot {
    pub fn init(operand: Node) -> NodeNot {
        NodeNot { operand }
    }
    
    pub fn get_operand(&self) -> &Node {
        &self.operand
    }
}