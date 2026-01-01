use crate::nodes::node::Node;

pub struct NodeWhile {
    condition: Node,
    body: Node,
}

impl NodeWhile {
    pub fn init(condition: Node, body: Node) -> NodeWhile {
        NodeWhile { condition, body }
    }
    
    pub fn get_condition(&self) -> &Node {
        &self.condition
    }
    
    pub fn get_body(&self) -> &Node {
        &self.body
    }
}