use crate::nodes::node::Node;

pub struct NodeIf {
    condition: Node,
    body: Node,
}

impl NodeIf {
    pub fn init(condition: Node, body: Node) -> NodeIf {
        NodeIf { condition, body }
    }
    
    pub fn get_condition(&self) -> &Node {
        &self.condition
    }
    
    pub fn get_body(&self) -> &Node {
        &self.body
    }
}