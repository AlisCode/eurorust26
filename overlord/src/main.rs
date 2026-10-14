use tracing::info;
use tracing_subscriber;

mod control;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();
    info!("starting control loop");

    control::control().await;
}
