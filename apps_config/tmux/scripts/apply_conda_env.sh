#!/usr/bin/env bash
# Step 1: Read process each line that starts with 'pane'
reserve_file="$HOME/.tmux/resurrect/conda_env_reservation.txt"

# Ensure reserve file exists (it will be created if it doesn't)
if [ -f "$reserve_file" ]; then
  # Step 2: Parse ~/.tmux/resurrect/reserve_conda_env.txt and activate conda environments in tmux panes
  while IFS= read -r line; do
    read -r session_window_pane conda_env_name <<<"$(echo "$line" | awk '{print $1, $2}')"
    # Activate the conda environment in the respective tmux pane
    tmux send-keys -t "$session_window_pane" "conda activate $conda_env_name" C-m
  done <"$reserve_file"
fi
