#pragma once

#include "utils/rights.hpp"
#include <string>
#include "elements.hpp"

namespace systems {
    class ApicaSystem final {
    public:
        static ApicaSystem &getInstance();

        bool isRunning() const;
        common::elements::Element *quitApp();
        void loadApp(const std::string &name);

        void update();
    private:
        utils::ApicaRight right;
        utils::ApicaMode mode;

        ApicaSystem();

        ApicaSystem(ApicaSystem &other) = delete;
        void operator=(const ApicaSystem &) = delete;
    };
}