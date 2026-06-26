#pragma once

#include "bytecodes.hpp"
#include <cstdio>
#include <optional>
#include <string>

namespace utils {
    std::optional<uint8_t> readU8(FILE *file);
    std::optional<uint16_t> readU16(FILE *file);
    std::optional<uint32_t> readU32(FILE *file);
    std::optional<uint64_t> readU64(FILE *file);

    std::optional<std::string> readString(FILE *file);

    std::optional<common::bytecodes::ApicaBytecode> readBytecode(FILE *file);
    std::optional<common::bytecodes::ApicaSpecificationBytecode> readSpecificationBytecode(FILE *file);
    std::optional<common::bytecodes::ApicaEntrypointBytecode> readEntryBytecode(FILE *file);
    std::optional<common::bytecodes::ApicaBuiltinFunctionBytecode> readBuiltinFuncBytecode(FILE *file);
    std::optional<common::bytecodes::ApicaTypeBytecode> readTypeBytecode(FILE *file);
}