pub struct NodeVarConstCall {
    name: String,
}

impl NodeVarConstCall {
    pub fn init(name: String) -> NodeVarConstCall {
        NodeVarConstCall { name }
    }
    
    pub fn get_name(&self) -> &String {
        &self.name
    }
}