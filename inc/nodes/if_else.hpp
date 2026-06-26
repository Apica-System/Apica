#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeIfElse final : public Node {
    public:
        NodeIfElse(Node *condition, Node *if_body, Node *else_body);
        ~NodeIfElse();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *condition;
        Node *if_body;
        Node *else_body;
    };
}