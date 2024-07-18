use anyhow::Result;
use base64::{engine::general_purpose::STANDARD, Engine as _};
use crypto::{rc4::Rc4, symmetriccipher::SynchronousStreamCipher};

pub async fn rc4_encrypt_to_base64(key: &str, input: &str) -> Result<String> {
    let mut rc4 = Rc4::new(key.as_bytes());
    let mut result = vec![0u8; input.len()];
    rc4.process(input.as_bytes(), &mut result);
    Ok(STANDARD.encode(&result))
}

pub async fn rc4_decrypt_from_base64(key: &str, input: &str) -> Result<String> {
    let mut rc4 = Rc4::new(key.as_bytes());
    let input_bytes = STANDARD.decode(input)?;
    let mut result = vec![0u8; input_bytes.len()];
    rc4.process(&input_bytes, &mut result);
    Ok(String::from_utf8(result)?)
}
