const std = @import("std");

pub fn chars_length_utf8(c: u8) u8 {
    if (c < 0x80) return 1;
    if (c < 0xe0) return 2;
    if (c < 0xf0) return 3;
    return 4;
}

pub fn char_is_id_part(c: u8) u8 {
    if (c < 0x80) {
        if (c == '_' or (c >= '0' and c <= '9') or (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z')) {
            return 1;
        }

        return 0;
    } else if (c < 0xe0) {
        return 2;
    } else if (c < 0xf0)
        return 3;

    return 4;
}

pub fn char_is_binary(c: u8) bool {
    return c == '0' or c == '1';
}

pub fn char_is_octal(c: u8) bool {
    return c >= '0' and c <= '7';
}

pub fn char_is_hexa(c: u8) bool {
    return (c >= '0' and c <= '9') or (c >= 'A' and c <= 'F') or (c >= 'a' and c <= 'f');
}

pub fn hexa_to_value(c: u8) u8 {
    if (c < 'A') return c - '0';
    if (c < 'a') return 10 + c - 'A';
    return 10 + c - 'a';
}

pub fn repeat_char(c: u8, count: usize, allocator: std.mem.Allocator) []u8 {
    const buffer = allocator.alloc(u8, count) catch {
        return "";
    };

    @memset(buffer, c);
    return buffer;
}

pub fn create_new_indent(old_indent: []const u8, allocator: std.mem.Allocator) []const u8 {
    var new_indent = allocator.alloc(u8, old_indent.len + 2) catch {
        return "";
    };

    @memcpy(new_indent[0..old_indent.len], old_indent);
    new_indent[old_indent.len] = ' ';
    new_indent[old_indent.len + 1] = ' ';

    return new_indent;
}
