#pragma once

#include "utils/rights.hpp"
#include "elements.hpp"

#include <string>
#include <SDL3/SDL.h>

namespace systems {
    class ApicaSystem final {
    public:
        static ApicaSystem &getInstance();

        common::elements::Element *quitApp();
        void forceQuitApp();

        void loadApp(const std::string &name);
        
        utils::ApicaMode getMode();
        void setQuitFinished();

        bool isRunning() const;
        void update();
    private:
        utils::ApicaRight right;
        utils::ApicaMode mode;
        SDL_Thread *evaluator_thread;

        ApicaSystem();

        ApicaSystem(ApicaSystem&) = delete;
        void operator=(const ApicaSystem&) = delete;
    };
}