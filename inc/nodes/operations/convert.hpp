#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeConvert final : public Node {
    public:
        NodeConvert(Node *left, common::bytecodes::ApicaTypeBytecode right);
        ~NodeConvert();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        Node *left;
        common::bytecodes::ApicaTypeBytecode right;
    };
}