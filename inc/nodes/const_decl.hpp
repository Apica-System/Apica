#pragma once

#include "nodes/node.hpp"

namespace nodes {
    class NodeConstDeclaration final : public Node {
    public:
        NodeConstDeclaration(uint64_t id, common::bytecodes::ApicaTypeBytecode type, Node *expression);
        ~NodeConstDeclaration();

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