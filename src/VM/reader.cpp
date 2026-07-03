#include "VM/reader.hpp"

#include "systems/logger.hpp"

#include "utils/errors.hpp"
#include "utils/read.hpp"
#include "utils/constants.hpp"

#include "values/string.hpp"
#include "values/bool.hpp"
#include "values/u32.hpp"
#include "values/u64.hpp"
#include "values/null.hpp"

#include "nodes/builtin_func_call.hpp"
#include "nodes/literal.hpp"
#include "nodes/var_const_call.hpp"
#include "nodes/var_decl.hpp"
#include "nodes/const_decl.hpp"
#include "nodes/if.hpp"
#include "nodes/if_else.hpp"
#include "nodes/while.hpp"

#include "nodes/operations/add.hpp"
#include "nodes/operations/subtract.hpp"
#include "nodes/operations/increment.hpp"
#include "nodes/operations/decrement.hpp"
#include "nodes/operations/not.hpp"
#include "nodes/operations/less.hpp"
#include "nodes/operations/less_equals.hpp"
#include "nodes/operations/greater.hpp"
#include "nodes/operations/greater_equals.hpp"

using namespace VM;

void VMReader::clear() {
    for (auto &entry : this->entrypoints) {
        if (entry.second) delete entry.second;
    }

    for (auto &spec : this->specifications) {
        if (spec.second) delete spec.second;
    }

    this->entrypoints.clear();
    this->specifications.clear();
}

std::optional<nodes::NodeCompound*> VMReader::getEntryNode(common::bytecodes::ApicaEntrypointBytecode entry_bytecode) const {
    auto entry = this->entrypoints.find(entry_bytecode);
    if (entry == this->entrypoints.end())
        return std::nullopt;
    
    return entry->second;
}

std::optional<common::values::Value*> VMReader::getSpecification(common::bytecodes::ApicaSpecificationBytecode spec_bytecode) const {
    auto spec = this->specifications.find(spec_bytecode);
    if (spec == this->specifications.end())
        return std::nullopt;
    
    return spec->second;
}

bool VMReader::readApp(const std::string &app_name) {
    this->clear();
    std::string filepath(utils::APP_PATH);
    filepath += app_name;
    filepath += '/';
    filepath += app_name;
    filepath += ".apb";

    FILE *input_file = fopen(filepath.c_str(), "rb");
    if (!input_file) {
        std::string error_message(utils::RDR_ERROR_INCORRECT_APB_FILE);
        error_message += app_name;
        systems::LoggerSystem::getInstance().systemLognError(error_message);
        return false;
    }

    std::optional<common::bytecodes::ApicaSpecificationBytecode> spec_bytecode;
    while ((spec_bytecode = utils::readSpecificationBytecode(input_file))) {
        if (spec_bytecode.value() == common::bytecodes::ApicaSpecificationBytecode::EndOfSpecification)
            break;

        if (!this->readSpecification(input_file, spec_bytecode.value())) {
            fclose(input_file);
            return false;
        }
    }

    if (!spec_bytecode) {
        fclose(input_file);
        return false;
    }

    std::optional<common::bytecodes::ApicaBytecode> bytecode;
    while ((bytecode = utils::readBytecode(input_file))) {
        if (bytecode.value() != common::bytecodes::ApicaBytecode::Entrypoint)
            break;
        
        if (!this->readEntrypoint(input_file)) {
            fclose(input_file);
            return false;
        }
    }

    if (!bytecode || bytecode.value() != common::bytecodes::ApicaBytecode::EndOfFile) {
        fclose(input_file);
        return false;
    }

    fclose(input_file);
    return true;
}

VMReader::VMReader() {

}

VMReader::~VMReader() {
    this->clear();
}

bool VMReader::readSpecification(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode) {
    switch (spec_bytecode) {
        case common::bytecodes::ApicaSpecificationBytecode::Title: 
            return this->readDataString(file, spec_bytecode);
        
        case common::bytecodes::ApicaSpecificationBytecode::Id: 
            return this->readDataString(file, spec_bytecode);
        
        case common::bytecodes::ApicaSpecificationBytecode::Version: 
            return this->readDataString(file, spec_bytecode);
        
        case common::bytecodes::ApicaSpecificationBytecode::LoggerActivation:
            return this->readDataBool(file, spec_bytecode);
        
        case common::bytecodes::ApicaSpecificationBytecode::WindowWidth:
            return this->readDataU32(file, spec_bytecode);
        
        case common::bytecodes::ApicaSpecificationBytecode::WindowHeight:
            return this->readDataU32(file, spec_bytecode);
        
        case common::bytecodes::ApicaSpecificationBytecode::IdCount:
            return this->readDataU64(file, spec_bytecode);

        default: {
            std::string error_message(utils::RDR_ERROR_UNKNOWN_SPEC_BYTECODE);
            error_message += std::to_string(spec_bytecode);

            systems::LoggerSystem::getInstance().systemLognError(error_message);
            return false;
        }
    }
}

bool VMReader::readDataString(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode) {
    std::optional<std::string> data = utils::readString(file);
    if (!data) return false;

    this->specifications[spec_bytecode] = new common::values::ValueString(data.value());
    return true;
}

bool VMReader::readDataBool(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode) {
    std::optional<uint8_t> data = utils::readU8(file);
    if (!data) return false;

    this->specifications[spec_bytecode] = new common::values::ValueBool(data.value());
    return true;
}

bool VMReader::readDataU32(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode) {
    std::optional<uint32_t> data = utils::readU32(file);
    if (!data) return false;

    this->specifications[spec_bytecode] = new common::values::ValueU32(data.value());
    return true;
}

bool VMReader::readDataU64(FILE *file, common::bytecodes::ApicaSpecificationBytecode spec_bytecode) {
    std::optional<uint64_t> data = utils::readU64(file);
    if (!data) return false;

    this->specifications[spec_bytecode] = new common::values::ValueU64(data.value());
    return true;
}

bool VMReader::readEntrypoint(FILE *file) {
    std::optional<common::bytecodes::ApicaEntrypointBytecode> entry_bytecode = utils::readEntryBytecode(file);
    if (!entry_bytecode)
        return false;

    std::optional<uint64_t> entry_size = utils::readU64(file);
    std::vector<nodes::Node*> nodes;
    nodes.reserve(entry_size.value_or(0));

    std::optional<common::bytecodes::ApicaBytecode> bytecode;
    while ((bytecode = utils::readBytecode(file))) {
        if (bytecode.value() == common::bytecodes::ApicaBytecode::EndOfBlock)
            break;

        std::optional<nodes::Node*> node = this->readNode(file, bytecode.value());
        if (!node) {
            for (nodes::Node *node : nodes) delete node;
            return false;
        }
        
        nodes.push_back(node.value());
    }

    if (!bytecode) {
        for (nodes::Node *node : nodes) delete node;
        return false;
    }

    this->entrypoints[entry_bytecode.value()] = new nodes::NodeCompound(nodes);
    systems::LoggerSystem::getInstance().systemLognSuccess("An entrypoint was read successfully");
    return true;
}

std::optional<nodes::Node*> VMReader::readNode(FILE *file, common::bytecodes::ApicaBytecode bytecode) {
    switch (bytecode) {
        case common::bytecodes::ApicaBytecode::Compound: return this->readCompound(file);
        case common::bytecodes::ApicaBytecode::BuiltinFuncCall: return this->readBuiltinFuncCall(file);
        case common::bytecodes::ApicaBytecode::Literal: return this->readLiteral(file);
        case common::bytecodes::ApicaBytecode::VarConstCall: return this->readVarConstCall(file);
        case common::bytecodes::ApicaBytecode::VarDecl: return this->readVarConstDecl(file, false);
        case common::bytecodes::ApicaBytecode::ConstDecl: return this->readVarConstDecl(file, true);
        
        case common::bytecodes::ApicaBytecode::Add: case common::bytecodes::ApicaBytecode::Subtract:
        case common::bytecodes::ApicaBytecode::LessThan: case common::bytecodes::ApicaBytecode::LessOrEquals:
        case common::bytecodes::ApicaBytecode::GreaterThan: case common::bytecodes::ApicaBytecode::GreaterOrEquals:
            return this->readBinary(file, bytecode);

        case common::bytecodes::ApicaBytecode::Increment: case common::bytecodes::ApicaBytecode::Decrement:
        case common::bytecodes::ApicaBytecode::Not:
            return this->readUnary(file, bytecode);
        
        case common::bytecodes::ApicaBytecode::If: return this->readIf(file, false);
        case common::bytecodes::ApicaBytecode::IfElse: return this->readIf(file, true);
        case common::bytecodes::ApicaBytecode::While: return this->readWhile(file);

        default: {
            std::string error_message(utils::RDR_ERROR_UNKNOWN_BYTECODE);
            error_message += std::to_string(bytecode);

            systems::LoggerSystem::getInstance().systemLognError(error_message);
            return std::nullopt;
        }
    }
}

std::optional<nodes::Node*> VMReader::readCompound(FILE *file) {
    std::optional<uint64_t> compound_size = utils::readU64(file);
    if (!compound_size) return std::nullopt;
    
    std::vector<nodes::Node*> nodes;
    nodes.reserve(compound_size.value());

    std::optional<common::bytecodes::ApicaBytecode> bytecode;
    while ((bytecode = utils::readBytecode(file))) {
        if (bytecode.value() == common::bytecodes::ApicaBytecode::EndOfBlock)
            break;
        
        std::optional<nodes::Node*> node = this->readNode(file, bytecode.value());
        if (!node) {
            for (nodes::Node *node : nodes) delete node;
            return std::nullopt;
        }
        
        nodes.push_back(node.value());
    }

    if (!bytecode) {
        for (nodes::Node *node : nodes) delete node;
        return std::nullopt;
    }

    return new nodes::NodeCompound(nodes);
}

std::optional<nodes::Node*> VMReader::readBuiltinFuncCall(FILE *file) {
    std::optional<common::bytecodes::ApicaBuiltinFunctionBytecode> func_bytecode = utils::readBuiltinFuncBytecode(file);
    if (!func_bytecode) return std::nullopt;

    std::optional<uint64_t> parameters_size = utils::readU64(file);
    if (!parameters_size) return std::nullopt;

    std::vector<nodes::Node*> parameters;
    parameters.reserve(parameters_size.value());

    std::optional<common::bytecodes::ApicaBytecode> bytecode;
    while ((bytecode = utils::readBytecode(file))) {
        if (bytecode.value() == common::bytecodes::ApicaBytecode::EndOfBlock)
            break;
        
        std::optional<nodes::Node*> param = this->readNode(file, bytecode.value());
        if (!param) {
            for (nodes::Node *node : parameters) delete node;
            return std::nullopt;
        }

        parameters.push_back(param.value());
    }

    if (!bytecode) {
        for (nodes::Node *node : parameters) delete node;
        return std::nullopt;
    }

    return new nodes::NodeBuiltinFuncCall(func_bytecode.value(), parameters);
}

std::optional<nodes::Node*> VMReader::readLiteral(FILE *file) {
    std::optional<common::bytecodes::ApicaTypeBytecode> type_bytecode = utils::readTypeBytecode(file);
    if (!type_bytecode) return std::nullopt;

    switch (type_bytecode.value()) {
        case common::bytecodes::ApicaTypeBytecode::Null:
            return new nodes::NodeLiteral(new common::values::ValueNull());
        
        case common::bytecodes::ApicaTypeBytecode::U32: {
            std::optional<uint32_t> u32 = utils::readU32(file);
            if (!u32) return std::nullopt;
            return new nodes::NodeLiteral(new common::values::ValueU32(u32.value()));
        }

        case common::bytecodes::ApicaTypeBytecode::Bool: {
            std::optional<uint8_t> boolean = utils::readU8(file);
            if (!boolean) return std::nullopt;
            return new nodes::NodeLiteral(new common::values::ValueBool(boolean.value()));
        }

        case common::bytecodes::ApicaTypeBytecode::String: {
            std::optional<std::string> str = utils::readString(file);
            if (!str) return std::nullopt;
            return new nodes::NodeLiteral(new common::values::ValueString(str.value()));
        }

        default: {
            std::string error_message(utils::RDR_ERROR_UNKNOWN_TYPE_BYTECODE);
            error_message += std::to_string(type_bytecode.value());

            systems::LoggerSystem::getInstance().systemLognError(error_message);
            return std::nullopt;
        }
    }
}

std::optional<nodes::Node*> VMReader::readVarConstCall(FILE *file) {
    std::optional<uint64_t> id = utils::readU64(file);
    if (!id) return std::nullopt;

    return new nodes::NodeVarConstCall(id.value());
}

std::optional<nodes::Node*> VMReader::readVarConstDecl(FILE *file, bool is_const) {
    std::optional<uint64_t> id = utils::readU64(file);
    if (!id) return std::nullopt;

    std::optional<common::bytecodes::ApicaTypeBytecode> type = utils::readTypeBytecode(file);
    if (!type) return std::nullopt;

    std::optional<common::bytecodes::ApicaBytecode> bytecode = utils::readBytecode(file);
    if (!bytecode) return std::nullopt;

    std::optional<nodes::Node*> expression = this->readNode(file, bytecode.value());
    if (!expression) return std::nullopt;

    if (is_const) {
        return new nodes::NodeConstDeclaration(id.value(), type.value(), expression.value());
    } else {
        return new nodes::NodeVarDeclaration(id.value(), type.value(), expression.value());
    }
}

std::optional<nodes::Node*> VMReader::readBinary(FILE *file, common::bytecodes::ApicaBytecode operation) {
    std::optional<common::bytecodes::ApicaBytecode> bytecode = utils::readBytecode(file);
    if (!bytecode) return std::nullopt;

    std::optional<nodes::Node*> left = this->readNode(file, bytecode.value());
    if (!left) return std::nullopt;

    bytecode = utils::readBytecode(file);
    if (!bytecode) {
        delete left.value();
        return std::nullopt;
    }

    std::optional<nodes::Node*> right = this->readNode(file, bytecode.value());
    if (!right) {
        delete left.value();
        return std::nullopt;
    }

    switch (operation) {
        case common::bytecodes::ApicaBytecode::Add:
            return new nodes::NodeAdd(left.value(), right.value());
        
        case common::bytecodes::ApicaBytecode::Subtract:
            return new nodes::NodeSubtract(left.value(), right.value());
        
        case common::bytecodes::ApicaBytecode::LessThan:
            return new nodes::NodeLess(left.value(), right.value());
        
        case common::bytecodes::ApicaBytecode::LessOrEquals:
            return new nodes::NodeLessEquals(left.value(), right.value());
        
        case common::bytecodes::ApicaBytecode::GreaterThan:
            return new nodes::NodeGreater(left.value(), right.value());
        
        case common::bytecodes::ApicaBytecode::GreaterOrEquals:
            return new nodes::NodeGreaterEquals(left.value(), right.value());

        default: {
            delete left.value();
            delete right.value();
            return std::nullopt;
        }
    }
}

std::optional<nodes::Node*> VMReader::readUnary(FILE *file, common::bytecodes::ApicaBytecode operation) {
    std::optional<common::bytecodes::ApicaBytecode> bytecode = utils::readBytecode(file);
    if (!bytecode) return std::nullopt;

    std::optional<nodes::Node*> operand = this->readNode(file, bytecode.value());
    if (!operand) return std::nullopt;

    switch (operation) {
        case common::bytecodes::ApicaBytecode::Increment:
            return new nodes::NodeIncrement(operand.value());
        
        case common::bytecodes::ApicaBytecode::Decrement:
            return new nodes::NodeDecrement(operand.value());
        
        case common::bytecodes::ApicaBytecode::Not:
            return new nodes::NodeNot(operand.value());

        default: {
            delete operand.value();
            return std::nullopt;
        }
    }
}

std::optional<nodes::Node*> VMReader::readIf(FILE *file, bool has_else) {
    std::optional<common::bytecodes::ApicaBytecode> bytecode = utils::readBytecode(file);
    if (!bytecode) return std::nullopt;

    std::optional<nodes::Node*> condition = this->readNode(file, bytecode.value());
    if (!condition) return std::nullopt;

    bytecode = utils::readBytecode(file);
    if (!bytecode) {
        delete condition.value();
        return std::nullopt;
    }

    std::optional<nodes::Node*> if_body = this->readNode(file, bytecode.value());
    if (!if_body) {
        delete condition.value();
        return std::nullopt;
    }

    if (!has_else)
        return new nodes::NodeIf(condition.value(), if_body.value());
    
    bytecode = utils::readBytecode(file);
    if (!bytecode) {
        delete condition.value();
        delete if_body.value();
        return std::nullopt;
    }

    std::optional<nodes::Node*> else_body = this->readNode(file, bytecode.value());
    if (!else_body) {
        delete condition.value();
        delete if_body.value();
        return std::nullopt;
    }

    return new nodes::NodeIfElse(condition.value(), if_body.value(), else_body.value());
}

std::optional<nodes::Node*> VMReader::readWhile(FILE *file) {
    std::optional<common::bytecodes::ApicaBytecode> bytecode = utils::readBytecode(file);
    if (!bytecode) return std::nullopt;

    std::optional<nodes::Node*> condition = this->readNode(file, bytecode.value());
    if (!condition) return std::nullopt;

    bytecode = utils::readBytecode(file);
    if (!bytecode) {
        delete condition.value();
        return std::nullopt;
    }

    std::optional<nodes::Node*> body = this->readNode(file, bytecode.value());
    if (!body) {
        delete condition.value();
        return std::nullopt;
    }

    return new nodes::NodeWhile(condition.value(), body.value());
}