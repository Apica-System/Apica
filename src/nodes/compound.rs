use crate::nodes::node::Node;

pub struct NodeCompound {
    nodes: Vec<Node>,
}

impl NodeCompound {
    pub fn init(nodes: Vec<Node>) -> NodeCompound {
        NodeCompound { nodes }
    }

    pub fn get_nodes(&self) -> &Vec<Node> {
        &self.nodes
    }
}