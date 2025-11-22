pub const NodeVarConstCall = struct {
    name: []const u8,

    pub fn init(name: []const u8) NodeVarConstCall {
        return NodeVarConstCall{ .name = name };
    }

    pub fn get_name(self: *const NodeVarConstCall) []const u8 {
        return self.name;
    }
};
