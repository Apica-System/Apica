#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeIf final : public Node {
    public:
        NodeIf(Node *condition, Node *body);
        ~NodeIf();

        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *condition;
        Node *body;
    };
}