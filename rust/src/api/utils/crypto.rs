use anyhow::Result;
use base64::{engine::general_purpose::STANDARD, Engine as _};
pub async fn rc4_encrypt_to_base64(key: &str, input: &str) -> Result<String> {
    let key_bytes = key.as_bytes();
    let input_bytes = input.as_bytes().to_vec();
    let mut rc4 = rc4::Cipher::new(key_bytes)?;
    let mut output_bytes: Vec<u8> = std::iter::repeat(0).take(input_bytes.len()).collect();
    rc4.xor(&input_bytes, &mut output_bytes);
    let encrypted_base64 = STANDARD.encode(&output_bytes);
    Ok(encrypted_base64)
}

pub async fn rc4_decrypt_from_base64(key: &str, input: &str) -> Result<String> {
    let input_bytes = STANDARD
        .decode(input)
        .map_err(|e| anyhow::anyhow!("Base64 decode error: {:?}", e))?;
    let mut rc4 = rc4::Cipher::new(key.as_bytes())?;
    let mut output_bytes: Vec<u8> = std::iter::repeat(0).take(input_bytes.len()).collect();
    rc4.xor(&input_bytes, &mut output_bytes);
    let decrypted_string = String::from_utf8(output_bytes)
        .map_err(|e| anyhow::anyhow!("UTF-8 conversion error: {:?}", e))?;
    Ok(decrypted_string)
}
