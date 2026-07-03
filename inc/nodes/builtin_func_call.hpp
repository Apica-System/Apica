#pragma once

#include "nodes/node.hpp"
#include <vector>

namespace nodes {
    class NodeBuiltinFuncCall final : public Node {
    public:
        NodeBuiltinFuncCall(common::bytecodes::ApicaBuiltinFunctionBytecode func_bytecode, const std::vector<Node*> &parameters);
        ~NodeBuiltinFuncCall();

        common::elements::Element *evaluate(uint8_t modifier) override;

    #ifdef __APICA_DEBUG__
        void show(std::string &indent) const override;
    #endif
    private:
        common::bytecodes::ApicaBuiltinFunctionBytecode func_bytecode;
        std::vector<Node*> parameters;
    };
}