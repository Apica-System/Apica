#pragma once

#include "VM/reader.hpp"
#include <SDL3/SDL.h>

namespace VM {
    enum EvaluatorModifier : uint8_t {
        EM_None =       0b00000000,
        EM_Global =     0b00000001,
        EM_CopyCall =   0b00000010
    };

    class VMEvaluator final {
    public:
        static VMEvaluator &getInstance();

        bool readApp(const std::string &app_name);
        void cancel();
        bool isRunning() const;

        static int SDLCALL loop(void *userdata);

        void setElement(uint64_t id, common::elements::Element *element);
        std::optional<common::elements::Element*> getElement(uint64_t id);
    private:
        VMReader reader;
        bool running;
        std::vector<common::elements::Element*> elements;

        VMEvaluator();
        ~VMEvaluator();

        bool evaluate(common::bytecodes::ApicaEntrypointBytecode entry_bytecode);
        void clear();

        void applySpecs(const std::string &app_name);

        VMEvaluator(VMEvaluator&) = delete;
        void operator=(const VMEvaluator&) = delete;
    };
}