#pragma once

#include <cstdint>

namespace nodes {
    enum NodeKind {
        Compound,

        Literal, BuiltinFuncCall, GlobalScope,
        VarConstCall, VarDeclaration, ConstDeclaration,

        Add, Increment, 
        Subtract, Decrement,
        Not,
        TernaryOperation,
        Convert,

        If, IfElse,
        While,

        Break, Continue, BlankReturn
    };
}