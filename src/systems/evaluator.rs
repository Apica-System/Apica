use apica_common::bytecodes::{ApicaBuiltinFunctionBytecode, ApicaTypeBytecode};
use apica_common::context::Context;
use apica_common::element::{Element, ElementModifier};
use apica_common::values::bool::ValueBool;
use apica_common::values::error::ValueError;
use apica_common::values::pointer::ValuePointer;
use apica_common::values::u8::ValueU8;
use apica_common::values::value::Value;
use bitflags::bitflags;
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
use crate::systems::inputs::InputsSystem;
use crate::systems::logger::LoggerSystem;
use crate::systems::rights::RightSystem;
use crate::systems::window::WindowSystem;

bitflags! {
    #[derive(Copy, Clone)]
    pub struct EvaluatorModifier : u8 {
        const None =        0b0000_0000;
        const Global =      0b0000_0001;
        const CopyCall =    0b0000_0010;
    }
}

pub struct EvaluatorSystem {
    context: Context,
}

impl EvaluatorSystem {
    pub fn init() -> EvaluatorSystem {
        EvaluatorSystem { context: Context::init() }
    }

    pub fn clear_data(&mut self) {
        self.context = Context::init();
    }

    pub fn evaluate(&mut self, root: &NodeCompound, 
                    logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                    inputs: &mut InputsSystem) {
        let result = self.evaluate_compound(root, EvaluatorModifier::None, logger, rights, window, inputs);
        if result.get_modifier().contains(ElementModifier::Error) {
            if let Value::Error(value_error) = result.get_value() {
                if let Some(name) = value_error.get_name() {
                    if let Some(details) = value_error.get_details() {
                        logger.system_logn_error(format!("{name}: {details}"));
                    } else {
                        logger.system_logn_error(format!("{name}"));
                    }
                }
            }
        } else if result.get_modifier().contains(ElementModifier::Controller) {
            if let Value::U8(value) = result.get_value() {
                if let Some(value_u8) = value.get_value() {
                    match value_u8 {
                        0 => logger.system_logn_error(String::from("ControllerError: A corrupted return statement was evaluated")),
                        1 => logger.system_logn_error(String::from("ControllerError: A corrupted break statement was evaluated")),
                        2 => logger.system_logn_error(String::from("ControllerError: A corrupted continue statement was evaluated")),

                        _ => {},
                    }
                } else {
                    logger.system_logn_error(String::from("ControllerError: A corrupted return statement was evaluated"));
                }
            }
        }
    }

    fn evaluate_node(&mut self, node: &Node, mode: EvaluatorModifier,
                     logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                     inputs: &mut InputsSystem) -> Element {
        match node {
            Node::Compound(compound) => self.evaluate_compound(compound, mode, logger, rights, window, inputs),
            Node::BuiltinFuncCall(builtin) => self.evaluate_builtin_func_call(builtin, mode, logger, rights, window, inputs),
            Node::Literal(literal) => self.evaluate_literal(literal),
            Node::GlobalScope(global_scope) => self.evaluate_global_scope(global_scope, mode, logger, rights, window, inputs),
            Node::VarConstCall(vc_call) => self.evaluate_var_const_call(vc_call, mode),
            Node::VarDecl(var_decl) => self.evaluate_var_decl(var_decl, mode, logger, rights, window, inputs),
            Node::ConstDecl(const_decl) => self.evaluate_const_decl(const_decl, mode, logger, rights, window, inputs),
            Node::Add(add) => self.evaluate_add(add, mode, logger, rights, window, inputs),
            Node::Increment(increment) => self.evaluate_increment(increment, mode, logger, rights, window, inputs),
            Node::Decrement(decrement) => self.evaluate_decrement(decrement, mode, logger, rights, window, inputs),
            Node::Not(not) => self.evaluate_not(not, mode, logger, rights, window, inputs),
            Node::TernaryOp(ternary) => self.evaluate_ternary_operation(ternary, mode, logger, rights, window, inputs),
            Node::If(_if) => self.evaluate_if(_if, mode, logger, rights, window, inputs),
            Node::IfElse(if_else) => self.evaluate_if_else(if_else, mode, logger, rights, window, inputs),
            Node::While(_while) => self.evaluate_while(_while, mode, logger, rights, window, inputs),
            Node::Break(_break) => self.evaluate_break(_break),
            Node::Continue(_continue) => self.evaluate_continue(_continue),
            Node::BlankReturn(blank_return) => self.evaluate_blank_return(blank_return),
        }
    }

    fn evaluate_compound(&mut self, root: &NodeCompound, mode: EvaluatorModifier,
                         logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                         inputs: &mut InputsSystem) -> Element {
        self.context.push_scope();

        for node in root.get_nodes() {
            let result = self.evaluate_node(node, mode, logger, rights, window, inputs);
            if result.is_error_or_controller() {
                return result;
            }
        }

        self.context.pop_scope();
        Element::create_null()
    }

    fn evaluate_builtin_func_call(&mut self, builtin: &NodeBuiltinFuncCall, mode: EvaluatorModifier,
                                  logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                                  inputs: &mut InputsSystem) -> Element {
        let mut parameters = vec![];

        let new_mode = mode | EvaluatorModifier::CopyCall;
        for node in builtin.get_parameters() {
            let result = self.evaluate_node(node, new_mode, logger, rights, window, inputs);
            if result.is_error_or_controller() {
                return result;
            }

            parameters.push(result);
        }

        match builtin.get_function_bytecode() {
            ApicaBuiltinFunctionBytecode::LogInfo => {
                logger.log_info(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LognInfo => {
                logger.logn_info(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LogSuccess => {
                logger.log_success(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LognSuccess => {
                logger.logn_success(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LogWarning => {
                logger.log_warning(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LognWarning => {
                logger.logn_warning(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LogError => {
                logger.log_error(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::LognError => {
                logger.logn_error(parameters);
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::Quit => {
                rights.quit_app();
                Element::create_null()
            },

            ApicaBuiltinFunctionBytecode::SetTitle => {
                if !window.set_title(parameters) {
                    Element::create_error(Value::Error(ValueError::init_with(
                        String::from("ArgumentError"),
                        Some(String::from("Incorrect arguments passed to the function `SetTitle`"))
                    )))
                } else {
                    Element::create_null()
                }
            },

            ApicaBuiltinFunctionBytecode::SetResizable => {
                if !window.set_resizable(parameters) {
                    Element::create_error(Value::Error(ValueError::init_with(
                        String::from("ArgumentError"),
                        Some(String::from("Incorrect arguments passed to the function `SetResizable`"))
                    )))
                } else {
                    Element::create_null()
                }
            },

            ApicaBuiltinFunctionBytecode::IsKeyReleased => {
                if let Some(state) = inputs.is_key_released(parameters) {
                    Element::init(ElementModifier::None, Value::Bool(ValueBool::init_with(state)))
                } else {
                    Element::create_error(Value::Error(ValueError::init_with(
                        String::from("ArgumentError"),
                        Some(String::from("Incorrect arguments passed to the function `IsKeyJustPressed`"))
                    )))
                }
            },
            
            ApicaBuiltinFunctionBytecode::IsKeyJustPressed => {
                if let Some(state) = inputs.is_key_just_pressed(parameters) {
                    Element::init(ElementModifier::None, Value::Bool(ValueBool::init_with(state)))
                } else {
                    Element::create_error(Value::Error(ValueError::init_with(
                        String::from("ArgumentError"),
                        Some(String::from("Incorrect arguments passed to the function `IsKeyJustPressed`"))
                    )))
                }
            },

            ApicaBuiltinFunctionBytecode::IsKeyPressed => {
                if let Some(state) = inputs.is_key_pressed(parameters) {
                    Element::init(ElementModifier::None, Value::Bool(ValueBool::init_with(state)))
                } else {
                    Element::create_error(Value::Error(ValueError::init_with(
                        String::from("ArgumentError"),
                        Some(String::from("Incorrect arguments passed to the function `IsKeyPressed`"))
                    )))
                }
            },

            _ => Element::create_error(Value::Error(ValueError::init_with(
                String::from("AccessError"),
                Some(format!("An undefined builtin func-call was found -> {:?}", builtin.get_function_bytecode())),
            ))),
        }
    }

    fn evaluate_literal(&mut self, literal: &NodeLiteral) -> Element {
        let value = literal.get_value().auto_convert(literal.get_value().get_kind()).unwrap();
        Element::init(ElementModifier::None, value)
    }

    fn evaluate_global_scope(&mut self, global: &NodeGlobalScope, mode: EvaluatorModifier,
                             logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                             inputs: &mut InputsSystem) -> Element {
        self.evaluate_node(global.get_statement(), mode | EvaluatorModifier::Global, logger, rights, window, inputs)
    }

    fn evaluate_var_const_call(&mut self, vc_call: &NodeVarConstCall, mode: EvaluatorModifier) -> Element {
        if let Some(vc_element) = self.context.get_element(vc_call.get_name(), mode.contains(EvaluatorModifier::Global)) {
            if mode.contains(EvaluatorModifier::CopyCall) {
                vc_element.auto_convert(vc_element.get_value().get_kind())
            } else {
                Element::init(vc_element.get_modifier(), Value::Pointer(
                    ValuePointer::init_with(vc_call.get_name().clone(), mode.contains(EvaluatorModifier::Global)),
                ))
            }
        } else {
            Element::create_error(Value::Error(ValueError::init_with(
                String::from("AccessError"),
                Some(format!("Cannot find a reference to a var/const -> {}", vc_call.get_name())),
            )))   
        }
    }

    fn evaluate_var_decl(&mut self, var_decl: &NodeVarDecl, mode: EvaluatorModifier,
                         logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                         inputs: &mut InputsSystem) -> Element {
        let result = self.evaluate_node(var_decl.get_expression(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(*var_decl.get_value_kind());
        if result.is_error_or_controller() {
            return result;
        }

        if self.context.set_element(var_decl.get_name().clone(), result, mode.contains(EvaluatorModifier::Global)) {
            Element::create_null()
        } else {
            Element::create_error(Value::Error(ValueError::init_with(
                String::from("DeclarationError"),
                Some(format!("An element with this name already exists -> {}", var_decl.get_name())),
            )))
        }
    }

    fn evaluate_const_decl(&mut self, const_decl: &NodeConstDecl, mode: EvaluatorModifier,
                           logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                           inputs: &mut InputsSystem) -> Element {
        let result = self.evaluate_node(const_decl.get_expression(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(*const_decl.get_value_kind());
        if result.is_error_or_controller() {
            return result;
        }

        if self.context.set_element(const_decl.get_name().clone(), result, mode.contains(EvaluatorModifier::Global)) {
            Element::create_null()
        } else {
            Element::create_error(Value::Error(ValueError::init_with(
                String::from("DeclarationError"),
                Some(format!("An element with this name already exists -> {}", const_decl.get_name())),
            )))
        }
    }

    fn evaluate_add(&mut self, add: &NodeAdd, mode: EvaluatorModifier, 
                    logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                    inputs: &mut InputsSystem) -> Element {
        let left = self.evaluate_node(add.get_left(), mode | EvaluatorModifier::CopyCall, logger, rights, window, inputs);
        if left.is_error_or_controller() {
            return left;
        }
        
        let right = self.evaluate_node(add.get_right(), mode | EvaluatorModifier::CopyCall, logger, rights, window, inputs);
        if right.is_error_or_controller() {
            return right;
        }
        
        left.add(&right)
    }
    
    fn evaluate_increment(&mut self, increment: &NodeIncrement, mode: EvaluatorModifier,
                          logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                          inputs: &mut InputsSystem) -> Element {
        let mut operand = self.evaluate_node(increment.get_operand(), mode - EvaluatorModifier::CopyCall, logger, rights, window, inputs);
        if operand.is_error_or_controller() {
            return operand;
        }

        if operand.get_modifier().contains(ElementModifier::Const) {
            return Element::create_error(Value::Error(ValueError::init_with(
                String::from("ConstError"),
                Some(String::from("Cannot perform a `right ++` unary operation to a constant"))
            )));
        }

        if let Value::Pointer(pointer) = operand.get_value() {
            if let Some(operand_pointer) = self.context.get_element_mut(pointer.get_pointer(), pointer.is_global()) {
                operand_pointer.increment()
            } else {
                Element::create_error(Value::Error(ValueError::init_with(
                    String::from("AccessError"),
                    Some(format!("Cannot find the value of a var/const -> {}", pointer.get_pointer())),
                )))
            }
        } else {
            operand.increment()
        }
    }

    fn evaluate_decrement(&mut self, decrement: &NodeDecrement, mode: EvaluatorModifier,
                          logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                          inputs: &mut InputsSystem) -> Element {
        let mut operand = self.evaluate_node(decrement.get_operand(), mode - EvaluatorModifier::CopyCall, logger, rights, window, inputs);
        if operand.is_error_or_controller() {
            return operand;
        }

        if operand.get_modifier().contains(ElementModifier::Const) {
            return Element::create_error(Value::Error(ValueError::init_with(
                String::from("ConstError"),
                Some(String::from("Cannot perform a `right ++` unary operation to a constant"))
            )));
        }

        if let Value::Pointer(pointer) = operand.get_value() {
            if let Some(operand_pointer) = self.context.get_element_mut(pointer.get_pointer(), pointer.is_global()) {
                operand_pointer.decrement()
            } else {
                Element::create_error(Value::Error(ValueError::init_with(
                    String::from("AccessError"),
                    Some(format!("Cannot find the value of a var/const -> {}", pointer.get_pointer())),
                )))
            }
        } else {
            operand.decrement()
        }
    }

    fn evaluate_not(&mut self, not: &NodeNot, mode: EvaluatorModifier,
                    logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                    inputs: &mut InputsSystem) -> Element {
        let mut operand = self.evaluate_node(not.get_operand(), mode - EvaluatorModifier::CopyCall, logger, rights, window, inputs);
        if operand.is_error_or_controller() {
            return operand;
        }

        if let Value::Pointer(pointer) = operand.get_value() {
            if let Some(operand_pointer) = self.context.get_element_mut(pointer.get_pointer(), pointer.is_global()) {
                operand_pointer.not()
            } else {
                Element::create_error(Value::Error(ValueError::init_with(
                    String::from("AccessError"),
                    Some(format!("Cannot find the value of a var/const -> {}", pointer.get_pointer())),
                )))
            }
        } else {
            operand.not()
        }
    }

    fn evaluate_ternary_operation(&mut self, ternary: &NodeTernaryOp, mode: EvaluatorModifier,
                                  logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                                  inputs: &mut InputsSystem) -> Element {
        let condition_result = self.evaluate_node(ternary.get_condition(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(ApicaTypeBytecode::Bool);
        if condition_result.is_error_or_controller() {
            return condition_result;
        }

        if let Value::Bool(result) = condition_result.get_value() {
            if let Some(value) = result.get_value() && value {
                self.evaluate_node(ternary.get_true_expr(), mode, logger, rights, window, inputs)
            } else {
                self.evaluate_node(ternary.get_false_expr(), mode, logger, rights, window, inputs)
            }
        } else {
            condition_result
        }
    }

    fn evaluate_if(&mut self, _if: &NodeIf, mode: EvaluatorModifier,
                   logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                   inputs: &mut InputsSystem) -> Element {
        let condition_result = self.evaluate_node(_if.get_condition(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(ApicaTypeBytecode::Bool);
        if condition_result.is_error_or_controller() {
            return condition_result;
        }

        if let Value::Bool(result) = condition_result.get_value() {
            if let Some(value) = result.get_value() && value {
                let body_result = self.evaluate_node(_if.get_body(), mode, logger, rights, window, inputs);
                if body_result.is_error_or_controller() {
                    return body_result;
                }
            }

            Element::create_null()
        } else {
            condition_result
        }
    }

    fn evaluate_if_else(&mut self, if_else: &NodeIfElse, mode: EvaluatorModifier,
                        logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                        inputs: &mut InputsSystem) -> Element {
        let condition_result = self.evaluate_node(if_else.get_condition(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(ApicaTypeBytecode::Bool);
        if condition_result.is_error_or_controller() {
            return condition_result;
        }

        if let Value::Bool(result) = condition_result.get_value() {
            if let Some(value) = result.get_value() && value {
                let body_result = self.evaluate_node(if_else.get_if_body(), mode, logger, rights, window, inputs);
                if body_result.is_error_or_controller() {
                    return body_result;
                }
            } else {
                let body_result = self.evaluate_node(if_else.get_else_body(), mode, logger, rights, window, inputs);
                if body_result.is_error_or_controller() {
                    return body_result;
                }
            }

            Element::create_null()
        } else {
            condition_result
        }
    }

    fn evaluate_while(&mut self, _while: &NodeWhile, mode: EvaluatorModifier,
                      logger: &mut LoggerSystem, rights: &mut RightSystem, window: &mut WindowSystem, 
                      inputs: &mut InputsSystem) -> Element {
        let mut condition_result = self.evaluate_node(_while.get_condition(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(ApicaTypeBytecode::Bool);
        if condition_result.is_error_or_controller() {
            return condition_result;
        }

        while let Value::Bool(result) = condition_result.get_value() && let Some(value) = result.get_value() && value {
            self.evaluate_node(_while.get_body(), mode, logger, rights, window, inputs);
            condition_result = self.evaluate_node(_while.get_condition(), EvaluatorModifier::CopyCall, logger, rights, window, inputs).check_convert(ApicaTypeBytecode::Bool);
        }

        if condition_result.is_error_or_controller() {
            return condition_result;
        }

        Element::create_null()
    }

    fn evaluate_break(&self, _break: &NodeBreak) -> Element {
        Element::init(
            ElementModifier::Controller,
            Value::U8(ValueU8::init_with(1))
        )
    }

    fn evaluate_continue(&self, _continue: &NodeContinue) -> Element {
        Element::init(
            ElementModifier::Controller,
            Value::U8(ValueU8::init_with(2))
        )
    }

    fn evaluate_blank_return(&self, _blank_return: &NodeBlankReturn) -> Element {
        Element::init(
            ElementModifier::Controller,
            Value::U8(ValueU8::init_with(0))
        )
    }
}