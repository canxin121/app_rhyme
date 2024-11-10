pub fn url_encode_special_chars(input: &str) -> String {
    let special_chars = [
        ('\\', "%5C"),
        ('/', "%2F"),
        (':', "%3A"),
        ('*', "%2A"),
        ('?', "%3F"),
        ('"', "%22"),
        ('<', "%3C"),
        ('>', "%3E"),
        ('|', "%7C"),
    ];

    let mut encoded = String::new();

    for c in input.chars() {
        match special_chars.iter().find(|&&(sc, _)| sc == c) {
            Some(&(_, code)) => encoded.push_str(code),
            None => encoded.push(c),
        }
    }

    encoded
}
