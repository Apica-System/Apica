#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeSubtract final : public Node {
    public:
        NodeSubtract(Node *left, Node *right);
        ~NodeSubtract();

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