use crate::nodes::node::Node;

pub struct NodeGlobalScope {
    statement: Node,
}

impl NodeGlobalScope {
    pub fn init(statement: Node) -> NodeGlobalScope {
        NodeGlobalScope { statement }
    }
    
    pub fn get_statement(&self) -> &Node {
        &self.statement
    }
}