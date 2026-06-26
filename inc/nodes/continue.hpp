#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeContinue final : public Node {
    public:
        NodeContinue();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    };
}