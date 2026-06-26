#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeWhile final : public Node {
    public:
        NodeWhile(Node *condition, Node *body);
        ~NodeWhile();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *condition;
        Node *body;
    };
}