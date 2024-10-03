// use music_api::CLIENT;
// use reqwest;

// pub async fn paste_content(content: String) -> anyhow::Result<String> {
//     let params = [("content", content.as_str())];
//     let res = CLIENT
//         .post("https://dpaste.com/api/")
//         .form(&params)
//         .send()
//         .await?;
//     Ok(format!("{}.txt", res.text().await?.trim_end()))
// }

// pub async fn get_paste_content(url: String) -> anyhow::Result<String> {
//     Ok(reqwest::get(url).await?.text().await?)
// }

// #[tokio::test]
// async fn test_post() {
//     let content = include_str!("test_paste.txt");
//     let url = paste_content(content.to_string()).await.unwrap();
//     let get_content = get_paste_content(url).await.unwrap();
//     assert!(content == get_content)
// }
