use apica_common::bytecodes::ApicaEntrypointBytecode;
use apica_common::values::value::Value;
use winit::application::ApplicationHandler;
use winit::event::WindowEvent;
use winit::event_loop::ActiveEventLoop;
use winit::window::{Window, WindowId};
use crate::systems::evaluator::EvaluatorSystem;
use crate::systems::inputs::InputsSystem;
use crate::systems::logger::LoggerSystem;
use crate::systems::reader::BytecodeReaderSystem;
use crate::systems::rights::RightSystem;
use crate::systems::window::WindowSystem;
use crate::utils::rights::{ApicaMode, ApicaRight, APICA_MAIN_MENU};

pub struct ApicaSystem {
    rights: RightSystem,
    reader: BytecodeReaderSystem,
    logger: LoggerSystem,
    evaluator: EvaluatorSystem,
    window: WindowSystem,
    inputs: InputsSystem,
}

impl ApicaSystem {
    pub fn init() -> ApicaSystem {
        ApicaSystem{
            rights: RightSystem::init(),
            reader: BytecodeReaderSystem::init(),
            logger: LoggerSystem::init(true),
            evaluator: EvaluatorSystem::init(),
            window: WindowSystem::init(),
            inputs: InputsSystem::init(),
        }
    }

    pub fn is_running(&self) -> bool {
        self.rights.is_running()
    }

    pub fn quit_app(&mut self) {
        self.rights.quit_app();
    }

    pub fn load_app(&mut self, app_name: &str) {
        if !self.rights.has_right(ApicaRight::AppRight) {
            return;
        }

        self.evaluator.clear_data();
        self.logger.create_file_for(app_name);
        self.reader.read_app(app_name, &mut self.logger);

        let title = if let Some(value) = self.reader.get_data("title") && let Value::String(title) = value {
            title.get_value().as_ref().unwrap()
        } else {
            "???"
        };
        self.window.system_set_title(title);
    }

    pub fn update_system(&mut self) {
        match self.rights.get_mode() {
            ApicaMode::SpecialQuit => {},

            ApicaMode::SpecialInit => {
                self.rights.set_mode(ApicaMode::Init);
                self.load_app(APICA_MAIN_MENU)
            },

            ApicaMode::Init => {
                if let Some(init_node) = self.reader.get_entry_node(ApicaEntrypointBytecode::Init) {
                    self.evaluator.evaluate(init_node, &mut self.logger, &mut self.rights, &mut self.window, &mut self.inputs);
                } else {
                    self.logger.system_logn_error("Failed to load the init entrypoint of the app".to_string());
                }

                self.rights.set_mode(ApicaMode::Update);
            },

            ApicaMode::Update => {
                if let Some(update_node) = self.reader.get_entry_node(ApicaEntrypointBytecode::Update) {
                    self.evaluator.evaluate(update_node, &mut self.logger, &mut self.rights, &mut self.window, &mut self.inputs);
                } else {
                    self.rights.set_mode(ApicaMode::Quit);
                    self.logger.system_logn_error("Failed to load the update entrypoint of the app".to_string());
                }
            },

            ApicaMode::Quit => {
                if let Some(quit_node) = self.reader.get_entry_node(ApicaEntrypointBytecode::Quit) {
                    self.evaluator.evaluate(quit_node, &mut self.logger, &mut self.rights, &mut self.window, &mut self.inputs);
                } else {
                    self.logger.system_logn_error("Failed to load the quit entrypoint of the app".to_string());
                }

                if self.rights.has_right(ApicaRight::MainMenuRight) {
                    self.rights.set_mode(ApicaMode::SpecialQuit);
                } else if self.rights.has_right(ApicaRight::AppRight) {
                    self.rights.set_mode(ApicaMode::Init);
                    self.rights.set_right(ApicaRight::MainMenu);
                    self.load_app(APICA_MAIN_MENU);
                }
            },
        }
    }
}

impl ApplicationHandler for ApicaSystem {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        let attributes = Window::default_attributes()
            .with_title("Apica");

        let window = event_loop.create_window(attributes).unwrap();
        self.window.set_window(window);
    }

    fn window_event(&mut self, _event_loop: &ActiveEventLoop, _window_id: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => {
                self.rights.quit_app();
            },

            WindowEvent::KeyboardInput { event, .. } => {
                self.inputs.handle_key_event(&event);
            },

            _ => {},
        }
    }

    fn about_to_wait(&mut self, event_loop: &ActiveEventLoop) {
        self.update_system();
        if !self.is_running() {
            event_loop.exit();
        }
    }
}