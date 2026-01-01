use bitflags::bitflags;

bitflags! {
    pub struct ApicaRight : u8 {
        const MainMenuRight =   0b0000_0100;
        const AppRight =        0b0000_0010;
        const ModRight =        0b0000_0001;

        const MainMenu =        0b0000_0111;
        const App =             0b0000_0011;
        const Mod =             0b0000_0001;
    }
}

#[derive(PartialEq)]
pub enum ApicaMode {
    SpecialQuit,

    Init, Update, Quit
}

pub const APICA_MAIN_MENU: &str = "APICA_MENU";