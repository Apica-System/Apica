const nd = @import("node.zig");

pub const NodeQuestionOperation = struct {
    condition: *nd.Node,
    first: *nd.Node,
    second: *nd.Node,

    pub fn init(condition: *nd.Node, first: *nd.Node, second: *nd.Node) NodeQuestionOperation {
        return NodeQuestionOperation{
            .condition = condition,
            .first = first,
            .second = second,
        };
    }

    pub fn get_condition(self: *const NodeQuestionOperation) *nd.Node {
        return self.condition;
    }

    pub fn get_first_statement(self: *const NodeQuestionOperation) *nd.Node {
        return self.first;
    }

    pub fn get_second_statement(self: *const NodeQuestionOperation) *nd.Node {
        return self.second;
    }
};
