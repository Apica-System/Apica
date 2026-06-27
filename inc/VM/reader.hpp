#pragma once

#include "bytecodes.hpp"
#include "values/value.hpp"
#include "nodes/compound.hpp"
#include <unordered_map>

namespace VM {
    class VMReader final {
    public:
        VMReader();
        ~VMReader();

        std::optional<nodes::NodeCompound*> getEntryNode(common::bytecodes::ApicaEntrypointBytecode entry_bytecode) const;
        std::optional<common::values::Value*> getSpecification(common::bytecodes::ApicaSpecificationBytecode spec_bytecode) const;

        bool readApp(const std::string &app_name);
    private:
        std::unordered_map<common::bytecodes::ApicaSpecificationBytecode, common::values::Value*> specifications;
        std::unordered_map<common::bytecodes::ApicaEntrypointBytecode, nodes::NodeCompound*> entrypoints;

        void clear();

        bool readSpecification(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode);
        bool readDataString(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode);
        bool readDataBool(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode);
        bool readDataU32(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode);
        bool readDataU64(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode);

        bool readEntrypoint(FILE *file);
        std::optional<nodes::Node*> readNode(FILE *file, common::bytecodes::ApicaBytecode bytecode);
        std::optional<nodes::Node*> readCompound(FILE *file);
        std::optional<nodes::Node*> readBuiltinFuncCall(FILE *file);
        std::optional<nodes::Node*> readLiteral(FILE *file);
        
        std::optional<nodes::Node*> readVarConstCall(FILE *file);
        std::optional<nodes::Node*> readVarConstDecl(FILE *file, bool is_const);
        
        std::optional<nodes::Node*> readBinary(FILE *file, common::bytecodes::ApicaBytecode operation);
        std::optional<nodes::Node*> readUnary(FILE *file, common::bytecodes::ApicaBytecode operation);
        
        std::optional<nodes::Node*> readIf(FILE *file, bool has_else);
        std::optional<nodes::Node*> readWhile(FILE *file);
    };
}