pub const ApicaRight = enum(u8) {
    MainMenu_Right = 0b00000100,
    App_Right = 0b00000010,
    Mod_Right = 0b00000001,

    MainMenu = 0b00000111,
    App = 0b00000011,
};

pub const ApicaMode = enum(u8) {
    SpecialQuit = 0,

    Init,
    Update,
    Quit,
};
