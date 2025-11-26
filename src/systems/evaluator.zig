const std = @import("std");
const nd = @import("../nodes/node.zig");
const ApicaSystem = @import("apica.zig").ApicaSystem;
const Context = @import("../utils/context.zig").Context;
const elt = @import("../common/element.zig");
const val = @import("../common/values/value.zig");
const bytecode = @import("../common/bytecodes.zig");

const EvaluatorModifier = enum(u8) {
    None = 0b00000000,
    Global = 0b00000001,
};

pub const EvaluatorSystem = struct {
    apica: *ApicaSystem,
    context: *Context,

    pub fn init(apica: *ApicaSystem) ?EvaluatorSystem {
        if (Context.init(null)) |context| {
            return EvaluatorSystem{ .apica = apica, .context = context };
        }
        return null;
    }

    pub fn destroy(self: *EvaluatorSystem) void {
        self.context.destroy();
    }

    pub fn clear_data(self: *EvaluatorSystem) bool {
        self.context.destroy();
        if (Context.init(null)) |context| {
            self.context = context;
            return true;
        }

        return false;
    }

    pub fn evaluate(self: *EvaluatorSystem, root: nd.NodeCompound) void {
        const result = self.evaluate_compound(root, @intFromEnum(EvaluatorModifier.None));
        if (result.get_modifier() & @intFromEnum(elt.ElementModifier.Error) != 0) {
            const name = result.get_value().Error.get_name().?;
            if (result.get_value().Error.get_details()) |details| {
                self.apica.get_logger().__logn_error(&.{ name, ": ", details });
            } else {
                self.apica.get_logger().__logn_error(&.{name});
            }
        } else if (result.get_modifier() & @intFromEnum(elt.ElementModifier.Controller) != 0) {
            switch (result.get_value().U8.get_value().?) {
                0 => self.apica.get_logger().__logn_error(&.{"ControllerError: A corrupted return statement was evaluated"}),
                1 => self.apica.get_logger().__logn_error(&.{"ControllerError: A corrupted break statement was evaluated"}),
                2 => self.apica.get_logger().__logn_error(&.{"ControllerError: A corrupted continue statement was evaluated"}),

                else => {},
            }
        }

        result.delete();
    }

    pub fn evaluate_node(self: *EvaluatorSystem, node: *nd.Node, mode: u8) elt.Element {
        switch (node.get_kind()) {
            nd.NodeKind.Compound => return self.evaluate_compound(node.Compound, mode),
            nd.NodeKind.BuiltinFuncCall => return self.evaluate_builtin_func_call(node.BuiltinFuncCall, mode),
            nd.NodeKind.Literal => return self.evaluate_literal(node.Literal),
            nd.NodeKind.GlobalScope => return self.evaluate_global_scope(node.GlobalScope, mode),
            nd.NodeKind.VarConstCall => return self.evaluate_var_const_call(node.VarConstCall, mode),
            nd.NodeKind.VarDecl => return self.evaluate_var_decl(node.VarDecl, mode),
            nd.NodeKind.ConstDecl => return self.evaluate_const_decl(node.ConstDecl, mode),
            nd.NodeKind.Increment => return self.evaluate_increment(node.Increment, mode),
            nd.NodeKind.Decrement => return self.evaluate_decrement(node.Decrement, mode),
            nd.NodeKind.Break => return self.evaluate_break(node.Break),
            nd.NodeKind.Continue => return self.evaluate_continue(node.Continue),
            nd.NodeKind.If => return self.evaluate_if(node.If, mode),
            nd.NodeKind.IfElse => return self.evaluate_if_else(node.IfElse, mode),
            nd.NodeKind.QuestionOperation => return self.evaluate_question_operation(node.QuestionOperation, mode),
            nd.NodeKind.While => return self.evaluate_while(node.While, mode),
        }
    }

    pub fn evaluate_compound(self: *EvaluatorSystem, compound: nd.NodeCompound, mode: u8) elt.Element {
        const new_context = Context.init(self.context);
        if (new_context == null) {
            return elt.Element.create_error(val.Value.create_error(
                "AllocationError",
                "Failed to allocate space to create a new context for the evaluator",
            ));
        }

        const old_context = self.context;
        self.context = new_context.?;

        for (compound.get_nodes().items) |node| {
            const result = self.evaluate_node(node, mode);
            if (result.is_error_or_controller()) {
                return result;
            }

            result.delete();
        }

        self.context.unset_parent();
        self.context.destroy();
        self.context = old_context;
        return elt.Element.create_null();
    }

    pub fn evaluate_builtin_func_call(self: *EvaluatorSystem, builtin: nd.NodeBuiltinFuncCall, mode: u8) elt.Element {
        var parameters: std.ArrayList(elt.Element) = .empty;
        defer {
            for (parameters.items) |param| {
                param.delete();
            }
            parameters.deinit(std.heap.page_allocator);
        }

        for (builtin.get_parameters().items) |node| {
            const result = self.evaluate_node(node, mode);
            if (result.is_error_or_controller()) {
                return result;
            }

            parameters.append(std.heap.page_allocator, result) catch {
                result.delete();
                return elt.Element.create_error(val.Value.create_detailed_error(
                    "AllocationError",
                    &.{ "Failed to allocate space to build the parameters list of builtin func -> ", @tagName(builtin.get_func_bytecode()) },
                ));
            };
        }

        switch (builtin.get_func_bytecode()) {
            bytecode.ApicaBuiltinFuncCallBytecode.LogInfo => self.apica.get_logger().log_info(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LognInfo => self.apica.get_logger().logn_info(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LogSuccess => self.apica.get_logger().log_success(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LognSuccess => self.apica.get_logger().logn_success(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LogWarning => self.apica.get_logger().log_warning(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LognWarning => self.apica.get_logger().logn_warning(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LogError => self.apica.get_logger().log_error(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.LognError => self.apica.get_logger().logn_error(parameters),
            bytecode.ApicaBuiltinFuncCallBytecode.Quit => self.apica.quit_app(),

            else => {
                return elt.Element.create_error(val.Value.create_detailed_error(
                    "AllocationError",
                    &.{ "An undefined builtin func-call was found -> ", @tagName(builtin.get_func_bytecode()) },
                ));
            },
        }

        return elt.Element.create_null();
    }

    pub fn evaluate_literal(_: *EvaluatorSystem, literal: nd.NodeLiteral) elt.Element {
        return elt.Element.init(literal.get_value(), @intFromEnum(elt.ElementModifier.None));
    }

    pub fn evaluate_global_scope(self: *EvaluatorSystem, global: nd.NodeGlobalScope, mode: u8) elt.Element {
        return self.evaluate_node(global.get_statement(), mode | @intFromEnum(EvaluatorModifier.Global));
    }

    pub fn evaluate_var_const_call(self: *EvaluatorSystem, vc_call: nd.NodeVarConstCall, mode: u8) elt.Element {
        if (self.context.get_element(vc_call.get_name(), mode & @intFromEnum(EvaluatorModifier.Global) != 0)) |call| {
            return elt.Element.init(
                val.Value{ .ElementPointer = val.ValueElementPointer.init_with(call) },
                call.get_modifier(),
            );
        }

        return elt.Element.create_error(val.Value.create_detailed_error(
            "AccessError",
            &.{ "Cannot find a reference to a var/const -> ", vc_call.get_name() },
        ));
    }

    pub fn evaluate_var_decl(self: *EvaluatorSystem, var_decl: nd.NodeVarDecl, mode: u8) elt.Element {
        const vkind = val.type_bytecode_to_kind(var_decl.get_vtype()) orelse return elt.Element.create_error(val.Value.create_detailed_error(
            "VarConstError",
            &.{ "An unexpected variable type was found -> ", @tagName(var_decl.get_vtype()) },
        ));

        const expr_res = self.evaluate_node(var_decl.get_expression(), mode & ~@intFromEnum(EvaluatorModifier.Global)).check_auto_convert(vkind);
        if (expr_res.is_error_or_controller()) {
            return expr_res;
        }

        const add_result = self.context.set_element(var_decl.get_name(), expr_res, mode & @intFromEnum(EvaluatorModifier.Global) != 0);
        if (add_result == 1) {
            expr_res.delete();
            return elt.Element.create_error(val.Value.create_detailed_error(
                "VarConstError",
                &.{ "A var/const with this name already exists -> ", var_decl.get_name() },
            ));
        } else if (add_result == 2) {
            expr_res.delete();
            return elt.Element.create_error(val.Value.create_detailed_error(
                "VarConstError",
                &.{ "Failed to allocate space to store the variable -> ", var_decl.get_name() },
            ));
        }

        return elt.Element.create_null();
    }

    pub fn evaluate_const_decl(self: *EvaluatorSystem, const_decl: nd.NodeConstDecl, mode: u8) elt.Element {
        const vkind = val.type_bytecode_to_kind(const_decl.get_vtype()) orelse return elt.Element.create_error(val.Value.create_detailed_error(
            "VarConstError",
            &.{ "Failed to allocate space to store the constant -> ", @tagName(const_decl.get_vtype()) },
        ));

        const expr_res = self.evaluate_node(const_decl.get_expression(), mode & ~@intFromEnum(EvaluatorModifier.Global)).check_auto_convert(vkind);
        if (expr_res.is_error_or_controller()) {
            return expr_res;
        }

        const add_result = self.context.set_element(const_decl.get_name(), expr_res, mode & @intFromEnum(EvaluatorModifier.Global) != 0);
        if (add_result == 1) {
            expr_res.delete();
            return elt.Element.create_error(val.Value.create_detailed_error(
                "VarConstError",
                &.{ "A var/const with this name already exists -> ", const_decl.get_name() },
            ));
        } else if (add_result == 2) {
            expr_res.delete();
            return elt.Element.create_error(val.Value.create_detailed_error(
                "VarConstError",
                &.{ "Failed to allocate space to store the constant -> ", const_decl.get_name() },
            ));
        }

        return elt.Element.create_null();
    }

    pub fn evaluate_increment(self: *EvaluatorSystem, incr: nd.NodeIncrement, mode: u8) elt.Element {
        var operand = self.evaluate_node(incr.get_operand(), mode);
        if (operand.get_modifier() & @intFromEnum(elt.ElementModifier.Error) != 0) {
            return operand;
        }

        const result = operand.increment();
        operand.delete();
        return result;
    }

    pub fn evaluate_decrement(self: *EvaluatorSystem, decr: nd.NodeDecrement, mode: u8) elt.Element {
        var operand = self.evaluate_node(decr.get_operand(), mode);
        if (operand.get_modifier() & @intFromEnum(elt.ElementModifier.Error) != 0) {
            return operand;
        }

        const result = operand.decrement();
        operand.delete();
        return result;
    }

    pub fn evaluate_break(_: *EvaluatorSystem, _: nd.NodeBreak) elt.Element {
        return elt.Element.init(
            val.Value{ .U8 = val.ValueU8.init_with(1) },
            @intFromEnum(elt.ElementModifier.Controller),
        );
    }

    pub fn evaluate_continue(_: *EvaluatorSystem, _: nd.NodeContinue) elt.Element {
        return elt.Element.init(
            val.Value{ .U8 = val.ValueU8.init_with(2) },
            @intFromEnum(elt.ElementModifier.Controller),
        );
    }

    pub fn evaluate_question_operation(self: *EvaluatorSystem, question: nd.NodeQuestionOperation, mode: u8) elt.Element {
        const result = self.evaluate_node(question.condition, mode).check_convert(val.ValueKind.Bool);
        if (result.is_error_or_controller()) {
            return result;
        }
        defer result.delete();

        if (result.get_value().Bool.get_value() == true) {
            return self.evaluate_node(question.first, mode);
        } else {
            return self.evaluate_node(question.second, mode);
        }
    }

    pub fn evaluate_if(self: *EvaluatorSystem, if_stat: nd.NodeIf, mode: u8) elt.Element {
        const condition = self.evaluate_node(if_stat.get_condition(), mode).check_convert(val.ValueKind.Bool);
        if (condition.is_error_or_controller()) {
            return condition;
        }
        defer condition.delete();

        if (condition.get_value().Bool.get_value() == true) {
            const result = self.evaluate_node(if_stat.get_body(), mode);
            if (result.is_error_or_controller()) {
                return result;
            }

            result.delete();
        }

        return elt.Element.create_null();
    }

    pub fn evaluate_if_else(self: *EvaluatorSystem, if_else: nd.NodeIfElse, mode: u8) elt.Element {
        const condition = self.evaluate_node(if_else.get_condition(), mode).check_convert(val.ValueKind.Bool);
        if (condition.is_error_or_controller()) {
            return condition;
        }
        defer condition.delete();

        if (condition.get_value().Bool.get_value() == true) {
            const result = self.evaluate_node(if_else.get_if_body(), mode);
            if (result.is_error_or_controller()) {
                return result;
            }

            result.delete();
        } else {
            const result = self.evaluate_node(if_else.get_else_body(), mode);
            if (result.is_error_or_controller()) {
                return result;
            }

            result.delete();
        }

        return elt.Element.create_null();
    }

    pub fn evaluate_while(self: *EvaluatorSystem, _while: nd.NodeWhile, mode: u8) elt.Element {
        while (true) {
            const condition = self.evaluate_node(_while.get_condition(), mode).check_convert(val.ValueKind.Bool);
            if (condition.is_error_or_controller()) {
                return condition;
            }
            defer condition.delete();

            if (condition.get_value().Bool.get_value() != true) break;

            const result = self.evaluate_node(_while.get_body(), mode);
            if (result.get_modifier() & @intFromEnum(elt.ElementModifier.Error) != 0) {
                return result;
            } else if (result.get_modifier() & @intFromEnum(elt.ElementModifier.Controller) != 0) {
                if (result.get_value().U8.get_value().? == 0) {
                    return result;
                } else if (result.get_value().U8.get_value().? == 1) {
                    result.delete();
                    return elt.Element.create_null();
                }
            }

            result.delete();
        }

        return elt.Element.create_null();
    }
};
