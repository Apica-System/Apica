use apica_common::bytecodes::ApicaTypeBytecode;
use apica_common::element::Element;
use apica_common::values::value::Value;
use winit::window::Window;

pub struct WindowSystem {
    window: Option<Window>,
}

impl WindowSystem {
    pub fn init() -> WindowSystem {
        WindowSystem { window: None }
    }

    pub fn set_window(&mut self, window: Window) {
        self.window = Some(window);
    }

    pub fn system_set_title(&self, title: &str) {
        if let Some(window) = &self.window {
            window.set_title(title);
        }
    }

    pub fn set_title(&self, parameters: Vec<Element>) -> bool {
        if parameters.is_empty() {
            return false;
        }

        let title_element = parameters.first().unwrap().auto_convert(ApicaTypeBytecode::String);
        if let Value::String(title) = title_element.get_value() {
            self.system_set_title(title.get_value().as_ref().unwrap_or(&"null".to_string()));
        }

        true
    }
}