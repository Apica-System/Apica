use crate::nodes::node::Node;

pub struct NodeTernaryOp {
    condition: Node,
    true_expr: Node,
    false_expr: Node,
}

impl NodeTernaryOp {
    pub fn init(condition: Node, true_expr: Node, false_expr: Node) -> NodeTernaryOp {
        NodeTernaryOp { condition, true_expr, false_expr, }
    }
    
    pub fn get_condition(&self) -> &Node {
        &self.condition
    }
    
    pub fn get_true_expr(&self) -> &Node {
        &self.true_expr
    }
    
    pub fn get_false_expr(&self) -> &Node {
        &self.false_expr
    }
}