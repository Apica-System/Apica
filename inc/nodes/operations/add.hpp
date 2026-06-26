#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeAdd final : public Node {
    public:
        NodeAdd(Node *left, Node *right);
        ~NodeAdd();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
            
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *left;
        Node *right;
    };
}