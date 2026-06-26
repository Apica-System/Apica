#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeVarConstCall final : public Node {
    public:
        NodeVarConstCall(uint64_t id);

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        uint64_t id;
    };
}