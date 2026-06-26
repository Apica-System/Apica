#include "utils/read.hpp"
#include "utils/errors.hpp"
#include "systems/logger.hpp"

std::optional<uint8_t> utils::readU8(FILE *file) {
    int result = fgetc(file);
    if (result == EOF) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_U8));
        return std::nullopt;
    }
    
    return static_cast<uint8_t>(result);
}

std::optional<uint16_t> utils::readU16(FILE *file) {
    uint16_t result;
    if (fread(&result, sizeof(uint16_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_U16));
        return std::nullopt;
    }
    
    return result;
}

std::optional<uint32_t> utils::readU32(FILE *file) {
    uint32_t result;
    if (fread(&result, sizeof(uint32_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_U32));
        return std::nullopt;
    }
    
    return result;
}

std::optional<uint64_t> utils::readU64(FILE *file) {
    uint64_t result;
    if (fread(&result, sizeof(uint64_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_U64));
        return std::nullopt;
    }
    
    return result;
}

std::optional<std::string> utils::readString(FILE *file) {
    std::string result;
    int c = fgetc(file);
    while (c != '\0') {
        if (c == EOF) {
            systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_STRING));
            return std::nullopt;
        }

        result += static_cast<char>(c);
        c = fgetc(file);
    }

    return result;
}

std::optional<common::bytecodes::ApicaBytecode> utils::readBytecode(FILE *file) {
    uint64_t result;
    if (fread(&result, sizeof(uint64_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_BYTECODE));
        return std::nullopt;
    }
    
    if (result > common::bytecodes::ApicaBytecode::BYTECODE_LAST) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_BYTECODE));
        return std::nullopt;
    }
    
    return static_cast<common::bytecodes::ApicaBytecode>(result);
}

std::optional<common::bytecodes::ApicaSpecificationBytecode> utils::readSpecificationBytecode(FILE *file) {
    uint64_t result;
    if (fread(&result, sizeof(uint64_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_SPEC_BYTECODE));
        return std::nullopt;
    }
    
    if (result > common::bytecodes::ApicaSpecificationBytecode::SPECIFICATION_LAST) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_SPEC_BYTECODE));
        return std::nullopt;
    }
    
    return static_cast<common::bytecodes::ApicaSpecificationBytecode>(result);
}

std::optional<common::bytecodes::ApicaEntrypointBytecode> utils::readEntryBytecode(FILE *file) {
    uint64_t result;
    if (fread(&result, sizeof(uint64_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_ENTRY_BYTECODE));
        return std::nullopt;
    }
    
    if (result > common::bytecodes::ApicaEntrypointBytecode::ENTRYPOINT_LAST) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_ENTRY_BYTECODE));
        return std::nullopt;
    }
    
    return static_cast<common::bytecodes::ApicaEntrypointBytecode>(result);
}

std::optional<common::bytecodes::ApicaBuiltinFunctionBytecode> utils::readBuiltinFuncBytecode(FILE *file) {
    uint64_t result;
    if (fread(&result, sizeof(uint64_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_BUILTIN_FUNC_BYTECODE));
        return std::nullopt;
    }

    if (result > common::bytecodes::ApicaBuiltinFunctionBytecode::BUILTIN_FUNC_LAST) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_BUILTIN_FUNC_BYTECODE));
        return std::nullopt;
    }

    return static_cast<common::bytecodes::ApicaBuiltinFunctionBytecode>(result);
}

std::optional<common::bytecodes::ApicaTypeBytecode> utils::readTypeBytecode(FILE *file) {
    uint64_t result;
    if (fread(&result, sizeof(uint64_t), 1, file) != 1) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_TYPE_BYTECODE));
        return std::nullopt;
    }

    if (result > common::bytecodes::ApicaTypeBytecode::TYPE_LAST) {
        systems::LoggerSystem::getInstance().systemLognError(std::string(utils::RDR_ERROR_READ_TYPE_BYTECODE));
        return std::nullopt;
    }

    return static_cast<common::bytecodes::ApicaTypeBytecode>(result);
}