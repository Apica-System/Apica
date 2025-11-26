const std = @import("std");
const Element = @import("../common/element.zig").Element;

pub const Context = struct {
    data: std.StringHashMap(Element),
    parent: ?*Context,

    pub fn init(parent: ?*Context) ?*Context {
        const context = std.heap.page_allocator.create(Context) catch {
            return null;
        };

        context.* = Context{
            .data = undefined,
            .parent = parent,
        };

        context.data = std.StringHashMap(Element).init(std.heap.smp_allocator);

        return context;
    }

    pub fn destroy(self: *Context) void {
        if (self.parent) |parent| {
            parent.destroy();
        }

        var iterator = self.data.valueIterator();
        while (iterator.next()) |element| {
            element.delete();
        }

        self.data.deinit();
        std.heap.page_allocator.destroy(self);
    }

    pub fn unset_parent(self: *Context) void {
        if (self.parent != null) {
            self.parent = null;
        }
    }

    pub fn get_element(self: *const Context, name: []const u8, is_global: bool) ?*Element {
        if (is_global) {
            var context = self;
            while (context.parent) |parent| {
                context = parent;
            }

            if (context.data.getPtr(name)) |element| {
                return element;
            }

            return null;
        } else {
            if (self.data.getPtr(name)) |element| {
                return element;
            }

            if (self.parent) |parent| {
                return parent.get_element(name, is_global);
            }

            return null;
        }
    }

    pub fn set_element(self: *Context, name: []const u8, element: Element, is_global: bool) u8 {
        var context = self;
        if (is_global) {
            while (context.parent) |parent| {
                context = parent;
            }
        }

        if (context.data.contains(name)) {
            return 1;
        }

        context.data.put(name, element) catch {
            return 2;
        };

        return 0;
    }
};
