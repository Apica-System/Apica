use crate::nodes::node::Node;

pub struct NodeDecrement {
    operand: Node,
}

impl NodeDecrement {
    pub fn init(operand: Node) -> NodeDecrement {
        NodeDecrement { operand }
    }
    
    pub fn get_operand(&self) -> &Node {
        &self.operand
    }
}