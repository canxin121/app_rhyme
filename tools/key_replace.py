import os


def main():
    # Grab environment variables
    secret_key = os.environ.get("SOME_SECRET_KEY")
    target_string = os.environ.get("SOME_REPLACE_KEY")

    # Ensure all variables are present
    if not all([secret_key, "lib/types/plugin.dart", target_string]):
        raise EnvironmentError("Missing one or more required environment variables.")

    # Read the contents of the target file
    with open("lib/types/plugin.dart", "r", encoding="utf-8") as file:
        file_data = file.read()

    # Replace the target string with the secret key
    new_data = file_data.replace(target_string, secret_key)

    # Write the new data back to the file
    with open("lib/types/plugin.dart", "w", encoding="utf-8") as file:
        file.write(new_data)


if __name__ == "__main__":
    main()
