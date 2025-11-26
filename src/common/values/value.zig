const std = @import("std");
const bytecode = @import("../bytecodes.zig");

pub const ValueNull = @import("null.zig").ValueNull;
pub const ValueElementPointer = @import("element_pointer.zig").ValueElementPointer;
pub const ValueAny = @import("any.zig").ValueAny;
pub const ValueU8 = @import("u8.zig").ValueU8;
pub const ValueU16 = @import("u16.zig").ValueU16;
pub const ValueU32 = @import("u32.zig").ValueU32;
pub const ValueU64 = @import("u64.zig").ValueU64;
pub const ValueF32 = @import("f32.zig").ValueF32;
pub const ValueF64 = @import("f64.zig").ValueF64;
pub const ValueBool = @import("bool.zig").ValueBool;
pub const ValueChar = @import("char.zig").ValueChar;
pub const ValueString = @import("string.zig").ValueString;
pub const ValueError = @import("error.zig").ValueError;

pub const ValueKind = enum(u8) {
    Null = 0,
    ElementPointer,
    Any,

    //I8,
    //I16,
    //I32,
    //I64,
    U8,
    U16,
    U32,
    U64,
    F32,
    F64,
    Bool,
    Char,
    String,
    Error,
    //Type,
};

pub fn value_kind_to_string(kind: ValueKind) []const u8 {
    switch (kind) {
        ValueKind.Null => return "null",
        ValueKind.ElementPointer => return "elt-pointer",
        ValueKind.Any => return "any",
        ValueKind.U8 => return "u8",
        ValueKind.U16 => return "u16",
        ValueKind.U32 => return "u32",
        ValueKind.U64 => return "u64",
        ValueKind.F32 => return "f32",
        ValueKind.F64 => return "f64",
        ValueKind.Bool => return "bool",
        ValueKind.Char => return "char",
        ValueKind.String => return "string",
        ValueKind.Error => return "error",
    }
}

pub fn type_bytecode_to_kind(code: bytecode.ApicaTypeBytecode) ?ValueKind {
    switch (code) {
        bytecode.ApicaTypeBytecode.Any => return ValueKind.Any,
        bytecode.ApicaTypeBytecode.U8 => return ValueKind.U8,
        bytecode.ApicaTypeBytecode.U16 => return ValueKind.U16,
        bytecode.ApicaTypeBytecode.U32 => return ValueKind.U32,
        bytecode.ApicaTypeBytecode.U64 => return ValueKind.U64,
        bytecode.ApicaTypeBytecode.F32 => return ValueKind.F32,
        bytecode.ApicaTypeBytecode.F64 => return ValueKind.F64,
        bytecode.ApicaTypeBytecode.Bool => return ValueKind.Bool,
        bytecode.ApicaTypeBytecode.Char => return ValueKind.Char,
        bytecode.ApicaTypeBytecode.String => return ValueKind.String,
        bytecode.ApicaTypeBytecode.Error => return ValueKind.Error,

        else => return null,
    }
}

pub const Value = union(ValueKind) {
    Null: ValueNull,
    ElementPointer: ValueElementPointer,
    Any: ValueAny,
    U8: ValueU8,
    U16: ValueU16,
    U32: ValueU32,
    U64: ValueU64,
    F32: ValueF32,
    F64: ValueF64,
    Bool: ValueBool,
    Char: ValueChar,
    String: ValueString,
    Error: ValueError,

    pub fn get_kind(self: *const Value) ValueKind {
        switch (self.*) {
            .Null => return ValueKind.Null,
            .ElementPointer => return ValueKind.ElementPointer,
            .Any => return ValueKind.Any,
            .U8 => return ValueKind.U8,
            .U16 => return ValueKind.U16,
            .U32 => return ValueKind.U32,
            .U64 => return ValueKind.U64,
            .F32 => return ValueKind.F32,
            .F64 => return ValueKind.F64,
            .Bool => return ValueKind.Bool,
            .Char => return ValueKind.Char,
            .String => return ValueKind.String,
            .Error => return ValueKind.Error,
        }
    }

    pub fn show(self: *const Value, end: u8) void {
        switch (self.*) {
            .Null => self.Null.show(end),
            .ElementPointer => self.ElementPointer.show(end),
            .Any => self.Any.show(end),
            .U8 => self.U8.show(end),
            .U16 => self.U16.show(end),
            .U32 => self.U32.show(end),
            .U64 => self.U64.show(end),
            .F32 => self.F32.show(end),
            .F64 => self.F64.show(end),
            .Bool => self.Bool.show(end),
            .Char => self.Char.show(end),
            .String => self.String.show(end),
            .Error => self.Error.show(end),
        }
    }

    pub fn is_null(self: *const Value) bool {
        switch (self.*) {
            .Null => return self.Null.is_null(),
            .ElementPointer => return self.ElementPointer.is_null(),
            .Any => return self.Any.is_null(),
            .U8 => return self.U8.is_null(),
            .U16 => return self.U16.is_null(),
            .U32 => return self.U32.is_null(),
            .U64 => return self.U64.is_null(),
            .F32 => return self.F32.is_null(),
            .F64 => return self.F64.is_null(),
            .Bool => return self.Bool.is_null(),
            .Char => return self.Char.is_null(),
            .String => return self.String.is_null(),
            .Error => return self.Error.is_null(),
        }
    }

    pub fn get_repr_type(self: *const Value) []const u8 {
        switch (self.*) {
            .Null => return self.Null.get_repr_type(),
            .ElementPointer => return self.ElementPointer.get_repr_type(),
            .Any => return self.Any.get_repr_type(),
            .U8 => return self.U8.get_repr_type(),
            .U16 => return self.U16.get_repr_type(),
            .U32 => return self.U32.get_repr_type(),
            .U64 => return self.U64.get_repr_type(),
            .F32 => return self.F32.get_repr_type(),
            .F64 => return self.F64.get_repr_type(),
            .Bool => return self.Bool.get_repr_type(),
            .Char => return self.Char.get_repr_type(),
            .String => return self.String.get_repr_type(),
            .Error => return self.Error.get_repr_type(),
        }
    }

    pub fn delete(self: *const Value) void {
        switch (self.*) {
            .Any => self.Any.delete(),
            .String => self.String.delete(),
            .Error => self.Error.delete(),

            else => {},
        }
    }

    pub fn create_error(name: []const u8, details: []const u8) Value {
        return Value{
            .Error = ValueError.init_with(
                name,
                details,
                0b00,
            ),
        };
    }

    pub fn create_detailed_error(name: []const u8, parts: []const []const u8) Value {
        var details: std.ArrayList(u8) = .empty;
        defer details.deinit(std.heap.smp_allocator);

        for (parts) |part| {
            details.appendSlice(std.heap.smp_allocator, part) catch {
                return create_error("AllocationError", "Failed to allocate space to create an AllocationError");
            };
        }

        const details_string = details.toOwnedSlice(std.heap.smp_allocator) catch {
            return create_error("AllocationError", "Failed to allocate space to create an AllocationError");
        };

        return Value{
            .Error = ValueError.init_with(
                name,
                details_string,
                0b10,
            ),
        };
    }

    pub fn unary_operation_error(op: []const u8, operand: []const u8) Value {
        return create_detailed_error("OperationError", &.{ "Unary operator `", op, "` is not defined for type <", operand, ">" });
    }

    pub fn binary_operation_error(op: []const u8, left: []const u8, right: []const u8) Value {
        return create_detailed_error("OperationError", &.{ "Binary operator `", op, "` is not defined for types <", left, "> and <", right, ">" });
    }

    pub fn null_operation_error(op: []const u8, is_binary: bool) Value {
        if (is_binary) {
            return create_detailed_error("NullOperationError", &.{ "Cannot perform binary operator `", op, "` to a null value" });
        } else {
            return create_detailed_error("NullOperationError", &.{ "Cannot perform unary operator `", op, "` to a null value" });
        }
    }

    pub fn constant_error() Value {
        return create_error(
            "ConstantError",
            "Cannot assign to a constant",
        );
    }

    pub fn increment(self: *Value) ?Value {
        switch (self.*) {
            .ElementPointer => return self.ElementPointer.increment(),
            .Any => return self.Any.increment(),
            .U8 => return self.U8.increment(),
            .U16 => return self.U16.increment(),
            .U32 => return self.U32.increment(),
            .U64 => return self.U64.increment(),
            .F32 => return self.F32.increment(),
            .F64 => return self.F64.increment(),
            .Char => return self.Char.increment(),

            else => return null,
        }
    }

    pub fn decrement(self: *Value) ?Value {
        switch (self.*) {
            .ElementPointer => return self.ElementPointer.decrement(),
            .Any => return self.Any.decrement(),
            .U8 => return self.U8.decrement(),
            .U16 => return self.U16.decrement(),
            .U32 => return self.U32.decrement(),
            .U64 => return self.U64.decrement(),
            .F32 => return self.F32.decrement(),
            .F64 => return self.F64.decrement(),
            .Char => return self.Char.decrement(),

            else => return null,
        }
    }

    pub fn convert(self: *const Value, to: ValueKind) ?Value {
        if (self.auto_convert(to)) |result| {
            return result;
        }

        switch (self.*) {
            .Null => return self.Null.convert(to),
            .ElementPointer => return self.ElementPointer.convert(to),
            .Any => return self.Any.convert(to),
            .U8 => return self.U8.convert(to),
            .U16 => return self.U16.convert(to),
            .U32 => return self.U32.convert(to),
            .U64 => return self.U64.convert(to),
            .F32 => return self.F32.convert(to),
            .F64 => return self.F64.convert(to),
            .Bool => return self.Bool.convert(to),
            .Char => return self.Char.convert(to),
            .String => return self.String.convert(to),
            .Error => return self.Error.convert(to),
        }
    }

    pub fn auto_convert(self: *const Value, to: ValueKind) ?Value {
        switch (self.*) {
            .Null => return self.Null.auto_convert(to),
            .ElementPointer => return self.ElementPointer.auto_convert(to),
            .Any => return self.Any.auto_convert(to),
            .U8 => return self.U8.auto_convert(to),
            .U16 => return self.U16.auto_convert(to),
            .U32 => return self.U32.auto_convert(to),
            .U64 => return self.U64.auto_convert(to),
            .F32 => return self.F32.auto_convert(to),
            .F64 => return self.F64.auto_convert(to),
            .Bool => return self.Bool.auto_convert(to),
            .Char => return self.Char.auto_convert(to),
            .String => return self.String.auto_convert(to),
            .Error => return self.Error.auto_convert(to),
        }
    }
};
