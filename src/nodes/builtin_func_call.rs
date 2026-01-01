use apica_common::bytecodes::ApicaBuiltinFunctionBytecode;
use crate::nodes::node::Node;

pub struct NodeBuiltinFuncCall {
    func_bytecode: ApicaBuiltinFunctionBytecode,
    parameters: Vec<Node>,
}

impl NodeBuiltinFuncCall {
    pub fn init(func_bytecode: ApicaBuiltinFunctionBytecode, parameters: Vec<Node>) -> NodeBuiltinFuncCall {
        NodeBuiltinFuncCall { func_bytecode, parameters }
    }
    
    pub fn get_function_bytecode(&self) -> &ApicaBuiltinFunctionBytecode {
        &self.func_bytecode
    }
    
    pub fn get_parameters(&self) -> &Vec<Node> {
        &self.parameters
    }
}