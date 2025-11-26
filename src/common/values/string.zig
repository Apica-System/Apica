const std = @import("std");
const val = @import("value.zig");

pub const ValueString = struct {
    value: ?[]const u8,
    allocated: bool,

    pub fn init_empty() ValueString {
        return ValueString{ .value = null, .allocated = false };
    }

    pub fn init_with(value: ?[]const u8, allocated: bool) ValueString {
        return ValueString{ .value = value, .allocated = allocated };
    }

    pub fn show(self: *const ValueString, end: u8) void {
        std.debug.print("{?s}{c}", .{ self.value, end });
    }

    pub fn is_null(self: *const ValueString) bool {
        return self.value == null;
    }

    pub fn get_repr_type(_: *const ValueString) []const u8 {
        return "string";
    }

    pub fn delete(self: *const ValueString) void {
        if (self.value) |value| {
            if (self.allocated) std.heap.smp_allocator.free(value);
        }
    }

    pub fn get_value(self: *const ValueString) ?[]const u8 {
        return self.value;
    }

    pub fn copy(self: *const ValueString) ?ValueString {
        if (self.allocated and self.value != null) {
            const buffer = std.heap.smp_allocator.alloc(u8, self.value.?.len) catch {
                return null;
            };

            _ = std.fmt.bufPrint(buffer, "{s}", .{self.value.?}) catch {
                return null;
            };

            return ValueString.init_with(buffer, true);
        } else {
            return ValueString.init_with(self.value, false);
        }
    }

    pub fn convert(self: *const ValueString, to: val.ValueKind) ?val.Value {
        if (self.value) |value| {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_with(value.len != 0) },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.Bool => return val.Value{ .Bool = val.ValueBool.init_empty() },

                else => return null,
            }
        }
    }

    pub fn auto_convert(self: *const ValueString, to: val.ValueKind) ?val.Value {
        if (self.value) |_| {
            switch (to) {
                val.ValueKind.String => {
                    const str_copy = self.copy();
                    if (str_copy) |string| {
                        return val.Value{ .String = string };
                    }

                    return val.Value.create_error(
                        "AllocationError",
                        "Failed to allocate space to copy a string",
                    );
                },

                else => return null,
            }
        } else {
            switch (to) {
                val.ValueKind.String => return val.Value{ .String = ValueString.init_empty() },

                else => return null,
            }
        }
    }
};
