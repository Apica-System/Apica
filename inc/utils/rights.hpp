#pragma once

#include <cstdint>

namespace utils {
    enum ApicaRight : uint8_t {
        APR_MainMenuRight =  0b00000100,
        APR_AppRight =       0b00000010,
        APR_ModRight =       0b00000001,

        APR_MAIN_MENU =      APR_MainMenuRight | APR_AppRight | APR_ModRight,
        APR_APP =            APR_AppRight | APR_ModRight,
        APR_MOD =            APR_ModRight
    };

    enum ApicaMode : uint8_t {
        APM_SpecialQuit, APM_SpecialInit,

        APM_Init, APM_Update, APM_Quit
    };
}