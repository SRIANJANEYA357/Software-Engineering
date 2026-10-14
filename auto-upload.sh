
#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

branch=$(git branch --show-current)
last_hash=""
stable_count=0

echo "Automatic GitHub upload started."
echo "Checking for changes every 10 seconds."
echo "Press Ctrl+C in Git Bash to stop."

while true; do
    git add -A

    if ! git diff --cached --quiet; then
        current_hash=$(git diff --cached --binary | sha256sum | awk '{print $1}')

        if [[ "$current_hash" == "$last_hash" ]]; then
            stable_count=$((stable_count + 1))
        else
            stable_count=0
            last_hash="$current_hash"
        fi

        if (( stable_count >= 2 )); then
            if git commit -m "Auto-sync changes $(date '+%Y-%m-%d %H:%M:%S')"; then
                git push origin "$branch"
            fi

            last_hash=""
            stable_count=0
        fi
    else
        last_hash=""
        stable_count=0
    fi

    sleep 10
done
