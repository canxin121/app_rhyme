use anyhow::Result;
use base64::{engine::general_purpose::STANDARD, Engine as _};
use rc4::cipher::generic_array::typenum::U6;
use rc4::{Key, KeyInit, Rc4, StreamCipher};

pub async fn rc4_encrypt_to_base64(key: &str, input: &str) -> Result<String> {
    let key_bytes = key.as_bytes();
    let mut input_bytes = input.as_bytes().to_vec();

    let rc4_key: &rc4::cipher::generic_array::GenericArray<u8, U6> = Key::from_slice(key_bytes);
    let mut rc4 = Rc4::new(&rc4_key);

    rc4.apply_keystream(&mut input_bytes);

    let encrypted_base64 = STANDARD.encode(&input_bytes);

    Ok(encrypted_base64)
}

pub async fn rc4_decrypt_from_base64(key: &str, input: &str) -> Result<String> {
    let mut input_bytes = STANDARD
        .decode(input)
        .map_err(|e| anyhow::anyhow!("Base64 decode error: {:?}", e))?;

    let key_bytes = key.as_bytes();

    let rc4_key: &rc4::cipher::generic_array::GenericArray<u8, U6> = Key::from_slice(key_bytes);
    let mut rc4 = Rc4::new(&rc4_key);

    rc4.apply_keystream(&mut input_bytes);

    let decrypted_string = String::from_utf8(input_bytes)
        .map_err(|e| anyhow::anyhow!("UTF-8 conversion error: {:?}", e))?;

    Ok(decrypted_string)
}

#[tokio::test]
async fn test() {
    let key = "Secret";
    let input = "Attack at dawn";
    let encrypted = rc4_encrypt_to_base64(key, input).await.unwrap();
    let decrypted = rc4_decrypt_from_base64(key, &encrypted).await.unwrap();
    assert_eq!(input, decrypted);
}
