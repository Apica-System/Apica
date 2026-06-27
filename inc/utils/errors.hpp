#pragma once

#include <string_view>

namespace utils {
    // Reader's errors
    inline constexpr std::string_view RDR_ERROR_INCORRECT_APB_FILE = "Failed to find or open APB file named -> ";
    inline constexpr std::string_view RDR_ERROR_READ_U8 = "Failed to read a 8-bit word";
    inline constexpr std::string_view RDR_ERROR_READ_U16 = "Failed to read a 16-bit word";
    inline constexpr std::string_view RDR_ERROR_READ_U32 = "Failed to read a 32-bit word";
    inline constexpr std::string_view RDR_ERROR_READ_U64 = "Failed to read a 64-bit word";
    inline constexpr std::string_view RDR_ERROR_READ_STRING = "Failed to read a string";
    inline constexpr std::string_view RDR_ERROR_READ_BYTECODE = "Failed to read a Apica Bytecode";
    inline constexpr std::string_view RDR_ERROR_READ_ENTRY_BYTECODE = "Failed to read a Apica Entrypoint Bytecode";
    inline constexpr std::string_view RDR_ERROR_READ_SPEC_BYTECODE = "Failed to read a Apica Specification Bytecode";
    inline constexpr std::string_view RDR_ERROR_READ_BUILTIN_FUNC_BYTECODE = "Failed to read a Apica Builtin Function Bytecode";
    inline constexpr std::string_view RDR_ERROR_READ_TYPE_BYTECODE = "Failed to read a Apica Type Bytecode";
    inline constexpr std::string_view RDR_ERROR_UNKNOWN_BYTECODE = "An unknown Apica Bytecode was found -> ";
    inline constexpr std::string_view RDR_ERROR_UNKNOWN_SPEC_BYTECODE = "An unknown Apica Specification Bytecode was found -> ";
    inline constexpr std::string_view RDR_ERROR_UNKNOWN_TYPE_BYTECODE = "An unknown Apica Type Bytecode was found -> ";


    // Evaluator's errors
    inline constexpr std::string_view EVL_ERROR_GET_ENTRYPOINT = "Failed to access to an entrypoint and evaluate it -> ";
    inline constexpr std::string_view EVL_ERROR_CORRUPTED_BREAK = "An incorrect use of break-statement outside a loop was found";
    inline constexpr std::string_view EVL_ERROR_CORRUPTED_CONTINUE = "An incorrect use of continue-statement outside a loop was found";
    inline constexpr std::string_view EVL_ERROR_CORRUPTED_RETURN = "An incorrect use of return-statement outside a function was found";
    inline constexpr std::string_view EVL_ERROR_TOO_BIG_ID = "A too big element id was passed to the EvaluatorSystem -> ";
    inline constexpr std::string_view EVL_ERROR_LAUNCH_THREAD = "Failed to launch a secondary thread to run the EvaluatorSystem on";
    inline constexpr std::string_view EVL_ERROR_NO_ID_COUNT = "No id count was found in the APB file";


    // Window's errors
    inline constexpr std::string_view WDW_ERROR_CREATE_WINDOW = "Failed to create a SDL window";
}