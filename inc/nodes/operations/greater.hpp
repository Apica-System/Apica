#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeGreater final : public Node {
    public:
        NodeGreater(Node *left, Node *right);
        ~NodeGreater();

        common::elements::Element *evaluate(uint8_t modifier) override;
            
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *left;
        Node *right;
    };
}