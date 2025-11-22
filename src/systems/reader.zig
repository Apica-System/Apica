const std = @import("std");
const val = @import("../common/values/value.zig");
const bytecode = @import("../common/bytecodes.zig");
const nd = @import("../nodes/node.zig");
const read = @import("../utils/read.zig");
const ApicaSystem = @import("apica.zig").ApicaSystem;

pub const BytecodeReaderSystem = struct {
    apica: *ApicaSystem,
    bytecode_nodes: std.AutoHashMap(bytecode.ApicaEntrypointBytecode, nd.NodeCompound),

    pub fn init(apica: *ApicaSystem) BytecodeReaderSystem {
        return BytecodeReaderSystem{ .apica = apica, .bytecode_nodes = std.AutoHashMap(bytecode.ApicaEntrypointBytecode, nd.NodeCompound).init(apica.get_allocator()) };
    }

    pub fn destroy(self: *BytecodeReaderSystem) void {
        self.clear_bytecode();
    }

    pub fn clear_bytecode(self: *BytecodeReaderSystem) void {
        _ = self.bytecode_nodes.remove(bytecode.ApicaEntrypointBytecode.Init);
        _ = self.bytecode_nodes.remove(bytecode.ApicaEntrypointBytecode.Update);
        _ = self.bytecode_nodes.remove(bytecode.ApicaEntrypointBytecode.Quit);
    }

    pub fn get_entry_node(self: *const BytecodeReaderSystem, entry: bytecode.ApicaEntrypointBytecode) ?nd.NodeCompound {
        return self.bytecode_nodes.get(entry);
    }

    pub fn read_app(self: *BytecodeReaderSystem, app_name: []const u8) void {
        self.clear_bytecode();
        const filepath: []u8 = std.fmt.allocPrint(self.apica.get_allocator(), "apps/{s}/{s}.apb", .{ app_name, app_name }) catch {
            self.apica.get_logger().__logn_error(&.{"Failed to allocate space to build the APB filepath"});
            return;
        };

        var input_file = std.fs.cwd().openFile(filepath, .{}) catch {
            self.apica.get_logger().__logn_error(&.{ "Failed to find or open the APB file named `", filepath, "`" });
            return;
        };
        defer input_file.close();

        var code = read.read_bytecode(input_file);
        while (code != null and code != bytecode.ApicaBytecode.EndOfFile) {
            if (code.? == bytecode.ApicaBytecode.Entrypoint) {
                self.read_entrypoint(input_file);
            }

            code = read.read_bytecode(input_file);
        }
    }

    pub fn read_entrypoint(self: *BytecodeReaderSystem, input_file: std.fs.File) void {
        const entry_code = read.read_entry_bytecode(input_file) orelse {
            self.apica.get_logger().__logn_error(&.{"An unknown Apica Entrypoint Bytecode was found"});
            return;
        };

        var nodes: std.ArrayList(*nd.Node) = .empty;
        var actual_code = read.read_bytecode(input_file);
        while (actual_code != null and actual_code != bytecode.ApicaBytecode.EndOfBlock) {
            if (self.read_node(input_file, actual_code.?)) |node| {
                nodes.append(self.apica.get_allocator(), node) catch {
                    _ = self.log_allocate_error();
                    return;
                };
            }

            actual_code = read.read_bytecode(input_file);
        }

        self.bytecode_nodes.put(entry_code, nd.NodeCompound.init(nodes)) catch {
            _ = self.log_allocate_error();
            return;
        };
    }

    pub fn read_node(self: *BytecodeReaderSystem, input_file: std.fs.File, code: bytecode.ApicaBytecode) ?*nd.Node {
        switch (code) {
            bytecode.ApicaBytecode.Compound => return self.read_compound(input_file),
            bytecode.ApicaBytecode.BuiltinFuncCall => return self.read_builtin_func_call(input_file),
            bytecode.ApicaBytecode.Literal => return self.read_literal(input_file),
            bytecode.ApicaBytecode.Global => return self.read_global_scope(input_file),
            bytecode.ApicaBytecode.VarConstCall => return self.read_var_const_call(input_file),
            bytecode.ApicaBytecode.VarDecl => return self.read_var_decl(input_file),
            bytecode.ApicaBytecode.ConstDecl => return self.read_const_decl(input_file),
            bytecode.ApicaBytecode.Increment => return self.read_increment(input_file),
            bytecode.ApicaBytecode.Decrement => return self.read_decrement(input_file),
            bytecode.ApicaBytecode.If => return self.read_if(input_file),
            bytecode.ApicaBytecode.IfElse => return self.read_if_else(input_file),

            else => {
                self.apica.get_logger().__logn_error(&.{ "An unexpected Apica Bytecode was found -> ", @tagName(code) });
                return null;
            },
        }
    }

    pub fn read_compound(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        var nodes: std.ArrayList(*nd.Node) = .empty;
        var actual_code = read.read_bytecode(input_file);
        while (actual_code != null and actual_code != bytecode.ApicaBytecode.EndOfBlock) {
            if (self.read_node(input_file, actual_code.?)) |node| {
                nodes.append(self.apica.get_allocator(), node) catch {
                    return self.log_allocate_error();
                };
            }

            actual_code = read.read_bytecode(input_file);
        }

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .Compound = nd.NodeCompound.init(nodes),
        };
        return result;
    }

    pub fn read_builtin_func_call(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const func_bytecode = read.read_builtin_func_bytecode(input_file) orelse {
            self.apica.get_logger().__logn_error(&.{"An unknown Apica Builtin Func Bytecode was found"});
            return null;
        };

        var parameters: std.ArrayList(*nd.Node) = .empty;
        var actual_code = read.read_bytecode(input_file);
        while (actual_code != null and actual_code != bytecode.ApicaBytecode.EndOfBlock) {
            if (self.read_node(input_file, actual_code.?)) |node| {
                parameters.append(self.apica.get_allocator(), node) catch {
                    return self.log_allocate_error();
                };
            }

            actual_code = read.read_bytecode(input_file);
        }

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .BuiltinFuncCall = nd.NodeBuiltinFuncCall.init(func_bytecode, parameters),
        };
        return result;
    }

    pub fn read_literal(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const type_code = read.read_type_bytecode(input_file);
        if (type_code) |r_type_code| {
            switch (r_type_code) {
                bytecode.ApicaTypeBytecode.Null => {
                    const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
                    result.* = nd.Node{ .Literal = nd.NodeLiteral.init(val.Value{
                        .Null = val.ValueNull.init_empty(),
                    }) };
                    return result;
                },

                bytecode.ApicaTypeBytecode.U32 => {
                    const integer = read.read_u32(input_file) orelse return null;
                    const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return null;
                    result.* = nd.Node{
                        .Literal = nd.NodeLiteral.init(val.Value{ .U32 = val.ValueU32.init_with(integer) }),
                    };
                    return result;
                },

                bytecode.ApicaTypeBytecode.String => {
                    const string = read.read_string(input_file, self.apica.get_allocator()) orelse return self.log_allocate_error();
                    const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return null;
                    result.* = nd.Node{
                        .Literal = nd.NodeLiteral.init(val.Value{ .String = val.ValueString.init_with(string) }),
                    };
                    return result;
                },

                else => {
                    self.apica.get_logger().__logn_error(&.{ "An unexpected Apica Type Bytecode was found -> ", @tagName(r_type_code) });
                    return null;
                },
            }
        } else {
            return self.log_unknown_type_bytecode();
        }
    }

    pub fn read_global_scope(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        var statements: std.ArrayList(*nd.Node) = .empty;
        var actual_code = read.read_bytecode(input_file);
        while (actual_code != null and actual_code != bytecode.ApicaBytecode.EndOfBlock) {
            if (self.read_node(input_file, actual_code.?)) |statement| {
                statements.append(self.apica.get_allocator(), statement) catch {
                    return self.log_allocate_error();
                };
            }

            actual_code = read.read_bytecode(input_file);
        }

        const compound = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        compound.* = nd.Node{
            .Compound = nd.NodeCompound.init(statements),
        };

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .GlobalScope = nd.NodeGlobalScope.init(compound),
        };
        return result;
    }

    pub fn read_var_const_call(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const vc_name = read.read_string(input_file, self.apica.get_allocator()) orelse return self.log_allocate_error();
        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .VarConstCall = nd.NodeVarConstCall.init(vc_name),
        };
        return result;
    }

    pub fn read_var_decl(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const name = read.read_string(input_file, self.apica.get_allocator()) orelse return self.log_allocate_error();
        const v_type = read.read_type_bytecode(input_file) orelse return self.log_unknown_type_bytecode();
        const expr_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const expression = self.read_node(input_file, expr_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .VarDecl = nd.NodeVarDecl.init(name, v_type, expression),
        };
        return result;
    }

    pub fn read_const_decl(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const name = read.read_string(input_file, self.apica.get_allocator()) orelse return self.log_allocate_error();
        const c_type = read.read_type_bytecode(input_file) orelse return self.log_unknown_type_bytecode();
        const expr_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const expression = self.read_node(input_file, expr_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .ConstDecl = nd.NodeConstDecl.init(name, c_type, expression),
        };
        return result;
    }

    pub fn read_increment(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const op_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const operand = self.read_node(input_file, op_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .Increment = nd.NodeIncrement.init(operand),
        };
        return result;
    }

    pub fn read_decrement(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const op_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const operand = self.read_node(input_file, op_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .Decrement = nd.NodeDecrement.init(operand),
        };
        return result;
    }

    pub fn read_question_operation(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const condition_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const condition = self.read_node(input_file, condition_bytecode) orelse return null;

        const first_stat_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const first_statement = self.read_node(input_file, first_stat_bytecode) orelse return null;

        const second_stat_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const second_statement = self.read_node(input_file, second_stat_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .QuestionOperation = nd.NodeQuestionOperation.init(condition, first_statement, second_statement),
        };
        return result;
    }

    pub fn read_if(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const cnd_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const condition = self.read_node(input_file, cnd_bytecode) orelse return null;

        const body_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const body = self.read_node(input_file, body_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .If = nd.NodeIf.init(condition, body),
        };
        return result;
    }

    pub fn read_if_else(self: *BytecodeReaderSystem, input_file: std.fs.File) ?*nd.Node {
        const cnd_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const condition = self.read_node(input_file, cnd_bytecode) orelse return null;

        const if_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const if_body = self.read_node(input_file, if_bytecode) orelse return null;

        const else_bytecode = read.read_bytecode(input_file) orelse return self.log_unknown_bytecode();
        const else_body = self.read_node(input_file, else_bytecode) orelse return null;

        const result = nd.Node.allocate_new(self.apica.get_allocator()) orelse return self.log_allocate_error();
        result.* = nd.Node{
            .IfElse = nd.NodeIfElse.init(condition, if_body, else_body),
        };
        return result;
    }

    fn log_allocate_error(self: *BytecodeReaderSystem) ?*nd.Node {
        self.apica.get_logger().__logn_error(&.{"Failed to allocate space to build the execution tree"});
        return null;
    }

    fn log_unknown_bytecode(self: *BytecodeReaderSystem) ?*nd.Node {
        self.apica.get_logger().__logn_error(&.{"An unknown Apica Bytecode was found"});
        return null;
    }

    fn log_unknown_type_bytecode(self: *BytecodeReaderSystem) ?*nd.Node {
        self.apica.get_logger().__logn_error(&.{"An unknown Apica Type Bytecode was found"});
        return null;
    }
};
