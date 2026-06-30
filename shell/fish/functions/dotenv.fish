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

# Auto-load ./.env when entering a directory that contains one (a lightweight,
# direnv-style hook). Unlike direnv it never executes shell code — it only sets
# KEY=VALUE pairs — but be aware any directory's .env can still inject env vars
# (e.g. PATH). Set `dotenv_autoload false` to disable. Loads once per directory
# entry (guarded against firing on every prompt redraw / repeated cd).
function _dotenv_autoload --on-variable PWD
    status is-interactive; or return
    test "$dotenv_autoload" = false; and return
    test -f .env; or return

    set -l stamp "$PWD/.env"
    test "$stamp" = "$__dotenv_last_loaded"; and return
    set -g __dotenv_last_loaded "$stamp"
    dotenv .env
end
