#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeGreaterEquals final : public Node {
    public:
        NodeGreaterEquals(Node *left, Node *right);
        ~NodeGreaterEquals();

        common::elements::Element *evaluate(uint8_t modifier) override;
            
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *left;
        Node *right;
    };
}