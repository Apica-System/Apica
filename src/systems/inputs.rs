use std::collections::HashMap;
use apica_common::bytecodes::ApicaTypeBytecode;
use apica_common::element::Element;
use apica_common::values::value::Value;
use winit::event::KeyEvent;
use winit::keyboard::{KeyCode, PhysicalKey};
use winit::platform::scancode::PhysicalKeyExtScancode;

#[derive(PartialEq)]
pub enum KeyState {
    Released,
    JustPressed,
    Pressed,
}

pub struct InputsSystem {
    keys: HashMap<PhysicalKey, KeyState>,
}

impl InputsSystem {
    pub fn init() -> InputsSystem {
        InputsSystem {
            keys: HashMap::from([
                (PhysicalKey::Code(KeyCode::KeyA), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyZ), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyE), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyR), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyT), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyY), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyU), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyI), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyO), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyP), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyQ), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyS), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyD), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyF), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyG), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyH), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyJ), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyK), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyL), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyM), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyW), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyX), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyC), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyV), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyB), KeyState::Released),
                (PhysicalKey::Code(KeyCode::KeyN), KeyState::Released),
            ]),
        }
    }

    pub fn handle_key_event(&mut self, key: &KeyEvent) {
        println!("Key {:?}: {:?}", key.text, key.physical_key.to_scancode());
        if let Some(state) = self.keys.get_mut(&key.physical_key) {
            if key.state.is_pressed() {
                *state = if *state == KeyState::JustPressed { KeyState::Pressed } else { KeyState::JustPressed };
            } else {
                *state = KeyState::Released;
            }
        }
    }

    pub fn system_is_key_released(&self, key: &PhysicalKey) -> bool {
        if let Some(key_state) = self.keys.get(key) {
            return *key_state == KeyState::Released;
        }

        false
    }

    pub fn system_is_key_just_pressed(&self, key: &PhysicalKey) -> bool {
        if let Some(key_state) = self.keys.get(key) {
            return *key_state == KeyState::JustPressed;
        }

        false
    }

    pub fn system_is_key_pressed(&self, key: &PhysicalKey) -> bool {
        if let Some(key_state) = self.keys.get(key) {
            return *key_state == KeyState::Pressed;
        }

        false
    }

    pub fn is_key_just_pressed(&self, parameters: Vec<Element>) -> Option<bool> {
        if parameters.is_empty() {
            return None;
        }

        let key = parameters.first().unwrap().auto_convert(ApicaTypeBytecode::U32);
        if key.is_error_or_controller() {
            return None;
        }

        if let Value::U32(scancode) = key.get_value() {
           if let Some(code) = scancode.get_value() {
               return Some(self.system_is_key_just_pressed(&PhysicalKey::from_scancode(code)));
           }
        }

        None
    }

    pub fn is_key_pressed(&self, parameters: Vec<Element>) -> Option<bool> {
        if parameters.is_empty() {
            return None;
        }

        let key = parameters.first().unwrap().auto_convert(ApicaTypeBytecode::U32);
        if key.is_error_or_controller() {
            return None;
        }

        if let Value::U32(scancode) = key.get_value() {
            if let Some(code) = scancode.get_value() {
                return Some(self.system_is_key_pressed(&PhysicalKey::from_scancode(code)));
            }
        }

        None
    }
}