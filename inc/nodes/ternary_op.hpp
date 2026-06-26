#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeTernaryOperation final : public Node {
    public:
        NodeTernaryOperation(Node *condition, Node *true_expr, Node *false_expr);
        ~NodeTernaryOperation();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *condition;
        Node *true_expression;
        Node *false_expression;
    };
}