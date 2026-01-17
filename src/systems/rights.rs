use crate::utils::rights::{ApicaMode, ApicaRight};

pub struct RightSystem {
    mode: ApicaMode,
    right: ApicaRight,
}

impl RightSystem {
    pub fn init() -> RightSystem {
        RightSystem { mode: ApicaMode::SpecialInit, right: ApicaRight::MainMenu }
    }
    
    pub fn get_mode(&self) -> &ApicaMode {
        &self.mode
    }
    
    pub fn set_mode(&mut self, mode: ApicaMode) {
        self.mode = mode;
    }
    
    pub fn set_right(&mut self, right: ApicaRight) {
        self.right = right;
    }
    
    pub fn add_right(&mut self, right: ApicaRight) {
        self.right |= right;
    }
    
    pub fn is_running(&self) -> bool {
        self.mode != ApicaMode::SpecialQuit
    }
    
    pub fn has_right(&self, right: ApicaRight) -> bool {
        self.right.contains(right)
    }
    
    pub fn quit_app(&mut self) {
        if !self.right.contains(ApicaRight::AppRight) {
            return;
        }

        self.mode = ApicaMode::Quit;
    }
}