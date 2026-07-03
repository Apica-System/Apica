#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeLiteral final : public Node {
    public:
        NodeLiteral(common::values::Value *value);
        ~NodeLiteral();

        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        common::values::Value *value;
    };
}