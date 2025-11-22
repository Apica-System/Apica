pub const ValueNull = @import("null.zig").ValueNull;
pub const ValueElementPointer = @import("element_pointer.zig").ValueElementPointer;
pub const ValueU32 = @import("u32.zig").ValueU32;
pub const ValueBool = @import("bool.zig").ValueBool;
pub const ValueChar = @import("char.zig").ValueChar;
pub const ValueString = @import("string.zig").ValueString;

pub const ValueKind = enum(u8) {
    Null = 0,
    ElementPointer,

    //I8,
    //I16,
    //I32,
    //I64,
    //U8,
    //U16,
    U32,
    //U64,
    //F32,
    //F64,
    Bool,
    Char,
    String,
    //Error,
    //Type,
};

pub const Value = union(ValueKind) {
    Null: ValueNull,
    ElementPointer: ValueElementPointer,
    U32: ValueU32,
    Bool: ValueBool,
    Char: ValueChar,
    String: ValueString,

    pub fn get_kind(self: *const Value) ValueKind {
        switch (self.*) {
            .Null => return ValueKind.Null,
            .ElementPointer => return ValueKind.ElementPointer,
            .U32 => return ValueKind.U32,
            .Bool => return ValueKind.Bool,
            .Char => return ValueKind.Char,
            .String => return ValueKind.String,
        }
    }

    pub fn show(self: *const Value, end: u8) void {
        switch (self.*) {
            .Null => self.Null.show(end),
            .ElementPointer => self.ElementPointer.show(end),
            .U32 => self.U32.show(end),
            .Bool => self.Bool.show(end),
            .Char => self.Char.show(end),
            .String => self.String.show(end),
        }
    }

    pub fn is_null(self: *const Value) bool {
        switch (self.*) {
            .Null => return self.Null.is_null(),
            .ElementPointer => return self.ElementPointer.is_null(),
            .U32 => return self.U32.is_null(),
            .Bool => return self.Bool.is_null(),
            .Char => return self.Char.is_null(),
            .String => return self.String.is_null(),
        }
    }

    pub fn increment(self: *Value) ?Value {
        switch (self.*) {
            .ElementPointer => return self.ElementPointer.increment(),
            .U32 => return self.U32.increment(),
            .Char => return self.Char.increment(),

            else => return null,
        }
    }

    pub fn decrement(self: *Value) ?Value {
        switch (self.*) {
            .ElementPointer => return self.ElementPointer.decrement(),
            .U32 => return self.U32.decrement(),
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
            .U32 => return self.U32.convert(to),
            .Bool => return self.Bool.convert(to),
            .Char => return self.Char.convert(to),
            .String => return self.String.convert(to),
        }
    }

    pub fn auto_convert(self: *const Value, to: ValueKind) ?Value {
        switch (self.*) {
            .Null => return self.Null.auto_convert(to),
            .ElementPointer => return self.ElementPointer.auto_convert(to),
            .U32 => return self.U32.auto_convert(to),
            .Bool => return self.Bool.auto_convert(to),
            .Char => return self.Char.auto_convert(to),
            .String => return self.String.auto_convert(to),
        }
    }
};
