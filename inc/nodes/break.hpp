#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeBreak final : public Node {
    public:
        NodeBreak();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;

    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    };
}