use crate::nodes::node::Node;

pub struct NodeAdd {
    left: Node,
    right: Node,
}

impl NodeAdd {
    pub fn init(left: Node, right: Node) -> NodeAdd {
        NodeAdd { left, right }
    }
    
    pub fn get_left(&self) -> &Node {
        &self.left
    }
    
    pub fn get_right(&self) -> &Node {
        &self.right
    }
}