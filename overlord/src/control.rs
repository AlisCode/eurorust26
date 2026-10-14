use std::time::Duration;
use tracing::{info, instrument};

const CONTROL_LOOP_FREQ: Duration = Duration::from_millis(100);

#[instrument]
pub async fn control() {
    loop {
        // TODO: Get world state
        // TODO: Strategize
        // TODO: Act
        info!("sleeping 100ms");
        tokio::time::sleep(CONTROL_LOOP_FREQ).await;
    }
}
