use std::collections::HashMap;
use std::fs::File;
use apica_common::bytecodes::{ApicaBytecode, ApicaEntrypointBytecode, ApicaTypeBytecode};
use apica_common::values::bool::ValueBool;
use apica_common::values::null::ValueNull;
use apica_common::values::string::ValueString;
use apica_common::values::u32::ValueU32;
use apica_common::values::u8::ValueU8;
use apica_common::values::value::Value;
use crate::nodes::_break::NodeBreak;
use crate::nodes::_continue::NodeContinue;
use crate::nodes::_if::NodeIf;
use crate::nodes::_while::NodeWhile;
use crate::nodes::add::NodeAdd;
use crate::nodes::blank_return::NodeBlankReturn;
use crate::nodes::builtin_func_call::NodeBuiltinFuncCall;
use crate::nodes::compound::NodeCompound;
use crate::nodes::const_decl::NodeConstDecl;
use crate::nodes::decrement::NodeDecrement;
use crate::nodes::global_scope::NodeGlobalScope;
use crate::nodes::if_else::NodeIfElse;
use crate::nodes::increment::NodeIncrement;
use crate::nodes::literal::NodeLiteral;
use crate::nodes::node::Node;
use crate::nodes::not::NodeNot;
use crate::nodes::ternary_op::NodeTernaryOp;
use crate::nodes::var_const_call::NodeVarConstCall;
use crate::nodes::var_decl::NodeVarDecl;
use crate::systems::logger::LoggerSystem;
use crate::utils::read;

pub struct BytecodeReaderSystem {
    bytecode_nodes: HashMap<u64, NodeCompound>,
}

impl BytecodeReaderSystem {
    pub fn init() -> BytecodeReaderSystem {
        BytecodeReaderSystem { bytecode_nodes: HashMap::new() }
    }

    pub fn clear_nodes(&mut self) {
        self.bytecode_nodes.clear();
    }

    pub fn get_entry_node(&self, entry: ApicaEntrypointBytecode) -> Option<&NodeCompound> {
        self.bytecode_nodes.get(&(entry as u64))
    }

    pub fn read_app(&mut self, app_name: &str, logger: &mut LoggerSystem) {
        self.clear_nodes();
        let filepath = format!("apps/{app_name}/{app_name}.apb");
        if let Ok(mut input_file) = File::open(filepath) {
            let mut code = read::read_bytecode(&mut input_file);
            while let Some(bytecode) = &code && *bytecode != ApicaBytecode::EndOfFile {
                if *bytecode == ApicaBytecode::Entrypoint {
                    self.read_entrypoint(&mut input_file, logger);
                }

                code = read::read_bytecode(&mut input_file);
            }
        } else {
            logger.system_logn_error(format!("Failed to find or open APB file named -> {app_name}"));
        }
    }

    fn read_entrypoint(&mut self, input_file: &mut File, logger: &mut LoggerSystem) {
        let entry_code = match read::read_entry_bytecode(input_file) {
            Some(code) => code,
            None => {
                logger.system_logn_error("An unknown Apica Entrypoint Bytecode was found".to_string());
                return;
            }
        };

        let mut nodes = vec![];
        let mut actual_code = read::read_bytecode(input_file);
        while let Some(actual_bytecode) = &actual_code && *actual_bytecode != ApicaBytecode::EndOfBlock {
            if let Some(node) = self.read_node(input_file, *actual_bytecode, logger) {
                nodes.push(node);
            }

            actual_code = read::read_bytecode(input_file);
        }

        let _ = self.bytecode_nodes.insert(entry_code as u64, NodeCompound::init(nodes));
        logger.system_logn_success(format!("Entry {:?} was read successfully", entry_code));
    }

    fn read_node(&mut self, input_file: &mut File, code: ApicaBytecode, logger: &mut LoggerSystem) -> Option<Node> {
        match code {
            ApicaBytecode::Compound => Some(self.read_compound(input_file, logger)),
            ApicaBytecode::BuiltinFuncCall => self.read_builtin_func_call(input_file, logger),
            ApicaBytecode::Literal => self.read_literal(input_file, logger),
            ApicaBytecode::Global => self.read_global_scope(input_file, logger),
            ApicaBytecode::VarConstCall => self.read_var_const_call(input_file, logger),
            ApicaBytecode::VarDecl => self.read_var_const_decl(input_file, false, logger),
            ApicaBytecode::ConstDecl => self.read_var_const_decl(input_file, true, logger),
            ApicaBytecode::Add => self.read_add(input_file, logger),
            ApicaBytecode::Increment => self.read_increment(input_file, logger),
            ApicaBytecode::Decrement => self.read_decrement(input_file, logger),
            ApicaBytecode::Not => self.read_not(input_file, logger),
            ApicaBytecode::Break => Some(self.read_break()),
            ApicaBytecode::Continue => Some(self.read_continue()),
            ApicaBytecode::BlankReturn => Some(self.read_blank_return()),
            ApicaBytecode::QuestionOperation => self.read_question_operation(input_file, logger),
            ApicaBytecode::If => self.read_if(input_file, logger),
            ApicaBytecode::IfElse => self.read_if_else(input_file, logger),
            ApicaBytecode::While => self.read_while(input_file, logger),

            _ => {
                logger.system_logn_error(format!("An unexpected Apica Bytecode was found -> {:?}", code));
                None
            },
        }
    }

    fn read_compound(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Node {
        let mut nodes = vec![];
        let mut actual_code = read::read_bytecode(input_file);
        while let Some(actual_bytecode) = &actual_code && *actual_bytecode != ApicaBytecode::EndOfBlock {
            if let Some(node) = self.read_node(input_file, *actual_bytecode, logger) {
                nodes.push(node);
            }

            actual_code = read::read_bytecode(input_file);
        }

        Node::Compound(NodeCompound::init(nodes))
    }

    fn read_builtin_func_call(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let func_bytecode = match read::read_builtin_func_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Builtin Func Bytecode was found".to_string());
                return None;
            }
        };

        let mut parameters = vec![];
        let mut actual_code = read::read_bytecode(input_file);
        while let Some(actual_bytecode) = &actual_code && *actual_bytecode != ApicaBytecode::EndOfBlock {
            if let Some(node) = self.read_node(input_file, *actual_bytecode, logger) {
                parameters.push(node);
            }

            actual_code = read::read_bytecode(input_file);
        }

        Some(Node::BuiltinFuncCall(NodeBuiltinFuncCall::init(func_bytecode, parameters)))
    }

    fn read_literal(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let type_bytecode = match read::read_type_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Type Bytecode was found for `literal-type`".to_string());
                return None;
            }
        };

        match type_bytecode {
            ApicaTypeBytecode::Null => Some(Node::Literal(NodeLiteral::init(
                Value::Null(ValueNull::init())
            ))),

            ApicaTypeBytecode::U8 => {
                let integer = match read::read_u8(input_file) {
                    Some(value) => value,
                    None => return None,
                };

                Some(Node::Literal(NodeLiteral::init(
                    Value::U8(ValueU8::init_with(integer))
                )))
            },

            ApicaTypeBytecode::U32 => {
                let integer = match read::read_u32(input_file) {
                    Some(value) => value,
                    None => return None,
                };

                Some(Node::Literal(NodeLiteral::init(
                    Value::U32(ValueU32::init_with(integer))
                )))
            },

            ApicaTypeBytecode::Bool => {
                let boolean = match read::read_u8(input_file) {
                    Some(value) => value != 0,
                    None => return None,
                };

                Some(Node::Literal(NodeLiteral::init(
                    Value::Bool(ValueBool::init_with(boolean))
                )))
            },

            ApicaTypeBytecode::String => {
                let string = match read::read_string(input_file) {
                    Some(value) => value,
                    None => return None,
                };

                Some(Node::Literal(NodeLiteral::init(
                    Value::String(ValueString::init_with(string))
                )))
            },

            _ => {
                logger.system_logn_error(format!("An unexpected Apica Type Bytecode was found -> {:?}", type_bytecode));
                None
            }
        }
    }

    fn read_global_scope(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let mut statements = vec![];
        let mut actual_code = read::read_bytecode(input_file);
        while let Some(actual_bytecode) = &actual_code && *actual_bytecode != ApicaBytecode::EndOfBlock {
            if let Some(node) = self.read_node(input_file, *actual_bytecode, logger) {
                statements.push(node);
            }

            actual_code = read::read_bytecode(input_file);
        }

        let compound = Node::Compound(NodeCompound::init(statements));
        Some(Node::GlobalScope(Box::new(NodeGlobalScope::init(compound))))
    }

    fn read_var_const_call(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let vc_name = match read::read_string(input_file) {
            Some(value) => value,
            None => {
                logger.system_logn_error("Unable to read var/const name call".to_string());
                return None;
            },
        };

        Some(Node::VarConstCall(NodeVarConstCall::init(vc_name)))
    }

    fn read_var_const_decl(&mut self, input_file: &mut File, is_const: bool, logger: &mut LoggerSystem) -> Option<Node> {
        let name = match read::read_string(input_file) {
            Some(value) => value,
            None => {
                logger.system_logn_error("Unable to read var/const name declaration".to_string());
                return None;
            },
        };

        let vc_type = match read::read_type_bytecode(input_file) {
            Some(value) => value,
            None => {
                logger.system_logn_error("An unknown Apica Type Bytecode was found for `vc-decl-type`".to_string());
                return None;
            },
        };

        let expr_bytecode = match read::read_bytecode(input_file) {
            Some(value) => value,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `vc-decl-expr`".to_string());
                return None;
            },
        };

        let expression = match self.read_node(input_file, expr_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        if is_const {
            Some(Node::ConstDecl(Box::new(NodeConstDecl::init(name, vc_type, expression))))
        } else {
            Some(Node::VarDecl(Box::new(NodeVarDecl::init(name, vc_type, expression))))
        }
    }

    fn read_add(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let left_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => return None,
        };

        let left = match self.read_node(input_file, left_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let right_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => return None,
        };

        let right = match self.read_node(input_file, right_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::Add(Box::new(NodeAdd::init(left, right))))
    }

    fn read_increment(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let op_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `incr-operand`".to_string());
                return None;
            },
        };

        let operand = match self.read_node(input_file, op_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::Increment(Box::new(NodeIncrement::init(operand))))
    }

    fn read_decrement(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let op_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `decr-operand`".to_string());
                return None;
            },
        };

        let operand = match self.read_node(input_file, op_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::Decrement(Box::new(NodeDecrement::init(operand))))
    }

    fn read_not(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let op_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error(String::from("An unknown Apica Bytecode was found for `not-operand`"));
                return None;
            },
        };

        let operand = match self.read_node(input_file, op_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::Not(Box::new(NodeNot::init(operand))))
    }

    fn read_break(&self) -> Node {
        Node::Break(NodeBreak::init())
    }

    fn read_continue(&self) -> Node {
        Node::Continue(NodeContinue::init())
    }

    fn read_blank_return(&self) -> Node {
        Node::BlankReturn(NodeBlankReturn::init())
    }

    fn read_question_operation(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let condition_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `?-cnd`".to_string());
                return None;
            },
        };

        let condition = match self.read_node(input_file, condition_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let true_statement_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `?-true-statement`".to_string());
                return None;
            },
        };

        let true_statement = match self.read_node(input_file, true_statement_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let false_statement_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `?-false-statement`".to_string());
                return None;
            },
        };

        let false_statement = match self.read_node(input_file, false_statement_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::TernaryOp(Box::new(NodeTernaryOp::init(condition, true_statement, false_statement))))
    }

    fn read_if(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let condition_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `if-cnd`".to_string());
                return None;
            },
        };

        let condition = match self.read_node(input_file, condition_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let body_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `if-body`".to_string());
                return None;
            },
        };

        let body = match self.read_node(input_file, body_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::If(Box::new(NodeIf::init(condition, body))))
    }

    fn read_if_else(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let condition_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `if-cnd`".to_string());
                return None;
            },
        };

        let condition = match self.read_node(input_file, condition_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let if_body_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `if-body`".to_string());
                return None;
            },
        };

        let if_body = match self.read_node(input_file, if_body_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let else_body_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `else-body`".to_string());
                return None;
            },
        };

        let else_body = match self.read_node(input_file, else_body_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::IfElse(Box::new(NodeIfElse::init(condition, if_body, else_body))))
    }

    fn read_while(&mut self, input_file: &mut File, logger: &mut LoggerSystem) -> Option<Node> {
        let condition_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `while-cnd`".to_string());
                return None;
            },
        };

        let condition = match self.read_node(input_file, condition_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        let body_bytecode = match read::read_bytecode(input_file) {
            Some(bytecode) => bytecode,
            None => {
                logger.system_logn_error("An unknown Apica Bytecode was found for `while-body`".to_string());
                return None;
            },
        };

        let body = match self.read_node(input_file, body_bytecode, logger) {
            Some(node) => node,
            None => return None,
        };

        Some(Node::While(Box::new(NodeWhile::init(condition, body))))
    }
}