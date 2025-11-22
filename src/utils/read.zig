const std = @import("std");
const bytecode = @import("../common/bytecodes.zig");

pub fn read_u8(file: std.fs.File) ?u8 {
    var buffer: [1]u8 = undefined;
    const n = file.read(&buffer) catch {
        return null;
    };

    return if (n == 1) buffer[0] else null;
}

pub fn read_u16(file: std.fs.File) ?u16 {
    var buffer: [2]u8 = undefined;
    const n = file.read(&buffer) catch {
        return null;
    };

    if (n != 2) {
        return null;
    }

    return std.mem.readInt(u16, &buffer, .little);
}

pub fn read_u32(file: std.fs.File) ?u32 {
    var buffer: [4]u8 = undefined;
    const n = file.read(&buffer) catch {
        return null;
    };

    if (n != 4) {
        return null;
    }

    return std.mem.readInt(u32, &buffer, .little);
}

pub fn read_u64(file: std.fs.File) ?u64 {
    var buffer: [8]u8 = undefined;
    const n = file.read(&buffer) catch {
        return null;
    };

    if (n != 8) {
        return null;
    }

    return std.mem.readInt(u64, &buffer, .little);
}

pub fn read_f32(file: std.fs.File) ?f32 {
    return @bitCast(read_u32(file));
}

pub fn read_f64(file: std.fs.File) ?f64 {
    return @bitCast(read_u64(file));
}

pub fn read_string(file: std.fs.File, allocator: std.mem.Allocator) ?[]const u8 {
    var buffer: std.ArrayList(u8) = .empty;

    var c = read_u8(file);
    while (c != null and c != '\x00') {
        buffer.append(allocator, c.?) catch {
            // Skip
        };

        c = read_u8(file);
    }

    const result = buffer.toOwnedSlice(allocator) catch {
        return null;
    };

    return result;
}

pub fn read_bytecode(file: std.fs.File) ?bytecode.ApicaBytecode {
    if (read_u64(file)) |res| {
        return std.enums.fromInt(bytecode.ApicaBytecode, res);
    }
    return null;
}

pub fn read_entry_bytecode(file: std.fs.File) ?bytecode.ApicaEntrypointBytecode {
    if (read_u64(file)) |res| {
        return std.enums.fromInt(bytecode.ApicaEntrypointBytecode, res);
    }
    return null;
}

pub fn read_builtin_func_bytecode(file: std.fs.File) ?bytecode.ApicaBuiltinFuncCallBytecode {
    if (read_u64(file)) |res| {
        return std.enums.fromInt(bytecode.ApicaBuiltinFuncCallBytecode, res);
    }
    return null;
}

pub fn read_type_bytecode(file: std.fs.File) ?bytecode.ApicaTypeBytecode {
    if (read_u64(file)) |res| {
        return std.enums.fromInt(bytecode.ApicaTypeBytecode, res);
    }
    return null;
}
