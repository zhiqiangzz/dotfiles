# Load KEY=VALUE pairs from a dotenv file into the global, exported environment.
# Usage:
#   dotenv            # load ./.env from the current directory
#   dotenv path/to/.env
#
# Handles blank lines, "# comment" lines, an optional leading `export `, and a
# single layer of surrounding single/double quotes around the value.
function dotenv --description 'Load environment variables from a .env file'
    set -l file $argv[1]
    test -z "$file"; and set file ./.env

    if not test -f "$file"
        echo "dotenv: $file not found" >&2
        return 1
    end

    set -l count 0
    while read -l line
        # Drop an optional leading `export `.
        set -l clean (string replace -r '^\s*export\s+' '' -- $line)
        # Skip blank lines and comments.
        string match -qr '^\s*(#|$)' -- $clean; and continue
        # Require a key=value shape.
        string match -q '*=*' -- $clean; or continue

        set -l parts (string split -m1 '=' -- $clean)
        set -l key (string trim -- $parts[1])
        set -l value (string trim -- $parts[2])
        test -z "$key"; and continue

        # Strip one layer of surrounding quotes, if present.
        set value (string replace -r '^"(.*)"$' '$1' -- $value)
        set value (string replace -r "^'(.*)'\$" '$1' -- $value)

        set -gx $key $value
        set count (math $count + 1)
    end <"$file"

    echo "dotenv: loaded $count var(s) from $file"
end
