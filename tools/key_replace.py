import os


def main():
    secret_key = os.environ.get("SOME_SECRET_KEY")
    target_string = os.environ.get("SOME_REPLACE_KEY")
    print(len(secret_key), len(target_string))

    if not all([secret_key, "lib/types/plugin.dart", target_string]):
        raise EnvironmentError("Missing one or more required environment variables.")

    with open("lib/types/plugin.dart", "r", encoding="utf-8") as file:
        file_data = file.read()

    new_data = file_data.replace(target_string, secret_key)

    with open("lib/types/plugin.dart", "w", encoding="utf-8") as file:
        file.write(new_data)


if __name__ == "__main__":
    main()
