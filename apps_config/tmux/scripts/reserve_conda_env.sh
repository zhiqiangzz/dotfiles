#!/usr/bin/env bash
# Step 1: Read ~/.tmux/resurrect/last and process each line that starts with 'pane'
config_home=$HOME/.tmux/resurrect
last_file=$(readlink "$config_home/last")

reserve_file="${last_file/tmux_resurrect/conda_env}"
# Ensure reserve file exists (it will be created if it doesn't)
if [ -f "$reserve_file" ]; then
    truncate -s 0 "$reserve_file"
else
    touch "$reserve_file"
fi

reserve_file_sl="$config_home/conda_env_reservation.txt"
if [ -f "$reserve_file" ]; then
    rm -f "$reserve_file_sl"
fi
ln -sf "$reserve_file" "$reserve_file_sl"

# Step 2: Parse each line that starts with "pane"
grep "^pane" "$last_file" | while read -r line; do
     # Step 3: Extract session name, window index, and pane index
     read -r session_name window_index pane_index <<<"$(echo "$line" | awk '{print $2, $3, $6}')"
 
     # # Step 4: Save the conda environment to the reserve file (with session, window, and pane info)
     tmux send-keys -t "${session_name}":"${window_index}"."${pane_index}" \
         "echo ${session_name}:${window_index}.${pane_index} \$CONDA_DEFAULT_ENV >>$reserve_file_sl" C-m
done
