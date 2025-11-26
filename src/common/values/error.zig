const std = @import("std");
const val = @import("value.zig");

pub const ValueError = struct {
    name: ?[]const u8,
    details: ?[]const u8,
    allocated: u2,

    pub fn init_empty() ValueError {
        return ValueError{ .name = null, .details = null, .allocated = 0b00 };
    }

    pub fn init_with(name: ?[]const u8, details: ?[]const u8, allocated: u2) ValueError {
        return ValueError{ .name = name, .details = details, .allocated = allocated };
    }

    pub fn show(self: *const ValueError, end: u8) void {
        std.debug.print("error<{?s}: {?s}>{c}", .{ self.name, self.details, end });
    }

    pub fn delete(self: *const ValueError) void {
        if (self.allocated & 0b01 != 0) {
            if (self.name) |name| std.heap.smp_allocator.free(name);
        }

        if (self.allocated & 0b10 != 0) {
            if (self.details) |details| std.heap.smp_allocator.free(details);
        }
    }

    pub fn is_null(self: *const ValueError) bool {
        return self.name == null;
    }

    pub fn get_repr_type(_: *const ValueError) []const u8 {
        return "error";
    }

    pub fn get_name(self: *const ValueError) ?[]const u8 {
        return self.name;
    }

    pub fn get_details(self: *const ValueError) ?[]const u8 {
        return self.details;
    }

    pub fn copy(self: *const ValueError) ValueError {
        return ValueError.init_with(self.name, self.details);
    }

    pub fn convert(self: *const ValueError, to: val.ValueKind) ?val.Value {
        if (self.name) |name| {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(true) },
                val.ValueKind.String => {
                    var buffer: std.ArrayList(u8) = .empty;
                    defer buffer.deinit(std.heap.smp_allocator);

                    buffer.appendSlice(std.heap.smp_allocator, name) catch return ValueError.error_to_string_allocation_error();
                    if (self.details) |details| {
                        buffer.appendSlice(std.heap.smp_allocator, ": ") catch return ValueError.error_to_string_allocation_error();
                        buffer.appendSlice(std.heap.smp_allocator, details) catch return ValueError.error_to_string_allocation_error();
                    }

                    const string = buffer.toOwnedSlice(std.heap.smp_allocator) catch return ValueError.error_to_string_allocation_error();
                    return val.Value{ .String = val.ValueString.init_with(string, true) };
                },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },
                val.ValueKind.String => return val.Value{ .String = val.ValueString.init_empty() },

                else => return null,
            }
        }
    }

    pub fn auto_convert(_: *const ValueError, _: val.ValueKind) ?val.Value {
        return null;
    }

    fn error_to_string_allocation_error() val.Value {
        return val.Value.create_error("AllocationError", "Failed to allocate space to convert <error> to <string>");
    }
};
