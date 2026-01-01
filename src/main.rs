use winit::event_loop::{ControlFlow, EventLoop};
use crate::systems::apica::ApicaSystem;
use crate::utils::rights::APICA_MAIN_MENU;

pub mod nodes;
pub mod systems;
pub mod utils;

fn main() {
    let event_loop = EventLoop::new().unwrap();
    event_loop.set_control_flow(ControlFlow::Poll);

    let mut apica_system = ApicaSystem::init();
    apica_system.load_app(APICA_MAIN_MENU);
    event_loop.run_app(&mut apica_system).expect("Failed to run event-loop");
}
