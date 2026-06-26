#pragma once

#include <cstdint>
#include <vector>
#include "elements.hpp"

namespace systems {
    enum EvaluatorModifier : uint8_t {
        EM_None =       0b00000000,
        EM_Global =     0b00000001,
        EM_CopyCall =   0b00000010
    };
    
    class EvaluatorSystem final {
    public:
        static EvaluatorSystem &getInstance();

        void reset(uint64_t id_count);
        bool evaluate(common::bytecodes::ApicaEntrypointBytecode entry_bytecode);

        void setElement(uint64_t id, common::elements::Element *element);
        std::optional<common::elements::Element*> getElement(uint64_t id);
    private:
        std::vector<common::elements::Element*> elements;

        EvaluatorSystem();
        ~EvaluatorSystem();

        EvaluatorSystem(EvaluatorSystem &other) = delete;
        void operator=(const EvaluatorSystem &) = delete;
    };
}