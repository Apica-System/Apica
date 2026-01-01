use apica_common::values::value::Value;

pub struct NodeLiteral {
    value: Value,
}

impl NodeLiteral {
    pub fn init(value: Value) -> NodeLiteral {
        NodeLiteral { value }
    }
    
    pub fn get_value(&self) -> &Value {
        &self.value
    }
}