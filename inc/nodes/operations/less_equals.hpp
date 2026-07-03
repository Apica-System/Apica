#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeLessEquals final : public Node {
    public:
        NodeLessEquals(Node *left, Node *right);
        ~NodeLessEquals();

        common::elements::Element *evaluate(uint8_t modifier) override;
            
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *left;
        Node *right;
    };
}