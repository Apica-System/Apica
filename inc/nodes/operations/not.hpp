#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeNot final : public Node {
    public:
        NodeNot(Node *operand);
        ~NodeNot();

        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *operand;
    };
}