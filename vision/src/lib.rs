//! Computer vision for tracking cars in the arena.

use reqwest::header;
use tracing::Instrument;



#[derive(Debug)]
struct Camera {
    client: reqwest::Client,
    url: String,
}

impl Camera {
    pub fn new(url: String, token: &str) -> Self {
        let mut headers = reqwest::header::HeaderMap::new();
        headers.insert("Authorization", header::HeaderValue::from_str(token).expect("malformed auth"));
        let client = reqwest::Client::builder()
            .default_headers(headers)
            .build()
            .expect("did not expect client build to fail");

        Self { client, url }
    }

    pub async fn fetch_frame(&self) -> Self {
        self.client.get(self.url)

    }
}

// struct FrameFetcher {
//     client: reqwest::Client,
// }

// impl FrameFetcher {
//     pub async fn new(token: ) -> Self {

//     }

//     #[instrument]
//     async fn get_frame(url: &str) {

//     }
// }
