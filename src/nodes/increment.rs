use crate::nodes::node::Node;

pub struct NodeIncrement {
    operand: Node,
}

impl NodeIncrement {
    pub fn init(operand: Node) -> NodeIncrement {
        NodeIncrement { operand }
    }
    
    pub fn get_operand(&self) -> &Node {
        &self.operand
    }
}