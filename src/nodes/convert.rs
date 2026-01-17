use apica_common::bytecodes::ApicaTypeBytecode;
use crate::nodes::node::Node;

pub struct NodeConvert {
    left: Node,
    right: ApicaTypeBytecode,
}

impl NodeConvert {
    pub fn init(left: Node, right: ApicaTypeBytecode) -> NodeConvert {
        NodeConvert { left, right }
    }
    
    pub fn get_left(&self) -> &Node {
        &self.left
    }
    
    pub fn get_right(&self) -> ApicaTypeBytecode {
        self.right
    }
}