use std::collections::HashMap;

use music_api::search_factory::CLIENT;
use reqwest::header::HeaderMap;

pub async fn send_request(
    method: &str,
    headers: HashMap<String, String>,
    url: &str,
    payload: &str,
) -> String {
    let method = method.to_uppercase();
    let headers: HeaderMap = (&headers).try_into().unwrap_or_default();

    let response = match method.as_str() {
        "GET" => send(method, url, headers, None).await,
        "POST" | "PUT" | "PATCH" => send(method, url, headers, Some(payload.to_string())).await,
        "DELETE" => send(method, url, headers, None).await,
        _ => return "".to_string(),
    };

    response.unwrap_or(String::with_capacity(0))
}

async fn send(
    method: String,
    url: &str,
    headers: HeaderMap,
    body: Option<String>,
) -> Result<String, anyhow::Error> {
    let client = &CLIENT;
    let request = client.request(method.parse()?, url).headers(headers);

    let request = if let Some(body) = body {
        request.body(body)
    } else {
        request
    };

    let response = request.send().await?;
    Ok(response.text().await?)
}
