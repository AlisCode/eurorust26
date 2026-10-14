use reqwest::{Client, Method, StatusCode};
use serde::Serialize;
use thiserror::Error;

#[derive(Debug, Serialize)]
struct CarInstructionHttp {
    pub speed: f32,
    pub flip: bool,
}

pub enum CarInstruction {
    Forward,
    Backward,
    Left,
    Right,
    Stop,
}

pub struct CarController {
    client: Client,
    auth: String,
}

impl Default for CarController {
    fn default() -> Self {
        CarController::new()
    }
}

#[derive(Debug, Error)]
pub enum CarControllerError {
    #[error("HTTP error: {0}")]
    HTTP(reqwest::Error),
    #[error("Expected success sending instruction, got {0}")]
    NotSucess(StatusCode),
}

impl CarController {
    pub fn new() -> Self {
        CarController {
            client: Client::default(),
            auth: "119172".to_owned(),
        }
    }

    pub async fn send_instruction(&self, instr: CarInstruction) -> Result<(), CarControllerError> {
        let instr = match instr {
            CarInstruction::Forward => CarInstructionHttp { speed: 1., flip: false },
            CarInstruction::Backward => CarInstructionHttp { speed: -1., flip: false },
            CarInstruction::Left => CarInstructionHttp { speed: -1., flip: true },
            CarInstruction::Right => CarInstructionHttp { speed: 1., flip: true },
            CarInstruction::Stop => CarInstructionHttp { speed: 0., flip: false },
        };

        let response = self.client.request(Method::PUT, "http://hackathon-4-car.local:5000")
            .header("Authorization", &self.auth)
            .json(&instr)
            .send()
            .await
            .map_err(CarControllerError::HTTP)?;

        let status_code = response.status();
        if !status_code.is_success() {
            return Err(CarControllerError::NotSucess(status_code));
        }

        Ok(())
    }
}

