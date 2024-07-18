import os


def replace_string_in_file(file_path, target_string, replacement_string):
    with open(file_path, "r", encoding="utf-8") as file:
        file_data = file.read()

    new_data = file_data.replace(target_string, replacement_string)

    with open(file_path, "w", encoding="utf-8") as file:
        file.write(new_data)


if __name__ == "__main__":
    secret_key = os.getenv("SOME_SECRET_KEY")
    target_file = os.getenv("SOME_REPLACE_FILE")
    target_string = os.getenv("SOME_REPLACE_KEY")
    if not secret_key:
        raise ValueError("Environment variable SOME_SECRET_KEY is not set")
    if not target_string:
        raise ValueError("Environment variable SOME_REPLACE_KEY is not set")
    if not target_file:
        raise ValueError("Environment variable SOME_REPLACE_FILE is not set")
    replace_string_in_file(target_file, target_string, secret_key)
