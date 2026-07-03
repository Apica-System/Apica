#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeLess final : public Node {
    public:
        NodeLess(Node *left, Node *right);
        ~NodeLess();

        common::elements::Element *evaluate(uint8_t modifier) override;
            
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *left;
        Node *right;
    };
}