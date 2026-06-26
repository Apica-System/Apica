#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeVarDeclaration final : public Node {
    public:
        NodeVarDeclaration(uint64_t id, common::bytecodes::ApicaTypeBytecode type, Node *expression);
        ~NodeVarDeclaration();

        NodeKind getKind() const override;
        common::elements::Element *evaluate(uint8_t modifier) override;
    
    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        uint64_t id;
        common::bytecodes::ApicaTypeBytecode value_type;
        Node *expression;
    };
}