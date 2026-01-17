use winit::event_loop::{ControlFlow, EventLoop};
use crate::systems::apica::ApicaSystem;

pub mod nodes;
pub mod systems;
pub mod utils;

fn main() {
    let event_loop = EventLoop::new().unwrap();
    event_loop.set_control_flow(ControlFlow::Poll);

    let mut apica_system = ApicaSystem::init();
    event_loop.run_app(&mut apica_system).expect("Failed to run event-loop");
}
