#pragma once

#include "utils/rights.hpp"
#include "elements.hpp"

#include <string>
#include <vector>
#include <SDL3/SDL.h>

namespace systems {
    class ApicaSystem final {
    public:
        static ApicaSystem &getInstance();

        common::elements::Element *quitApp(const std::vector<common::elements::Element*> &parameters);
        common::elements::Element *loadApp(const std::vector<common::elements::Element*> &parameters);
        
        void forceQuitApp();
        void systemLoadApp(const std::string &name);
        
        utils::ApicaMode getMode();
        void setQuitFinished();

        bool isRunning() const;
        void update();
    private:
        utils::ApicaRight right;
        utils::ApicaMode mode;
        SDL_Thread *evaluator_thread;
        std::optional<std::string> next_app;

        ApicaSystem();

        ApicaSystem(ApicaSystem&) = delete;
        void operator=(const ApicaSystem&) = delete;
    };
}