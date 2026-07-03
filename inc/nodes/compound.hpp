#pragma once

#include "nodes/node.hpp"
#include <vector>

namespace nodes {
    class NodeCompound final : public Node {
    public:
        NodeCompound(const std::vector<Node*> &nodes);
        ~NodeCompound();

        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        std::vector<Node*> nodes;
    };
}