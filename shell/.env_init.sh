# basic environment setup

# local bin
export PATH=$PATH:~/.local/bin

# hugging face china mirror
export HF_ENDPOINT=https://hf-mirror.com

# zim
# export ZIM_HOME=$HOME/.config/zim/.zim
# export ZDOTDIR=$HOME
source $HOME/.config/zim/conf/setup_zim.zsh

# c/cpp tool chain
# export CXXFLAGS="-stdlib=libc++"
# export LDFLAGS="-stdlib=libc++"

case $(uname) in
Darwin) ;;
Linux)
  # locale
  export LANGUAGE=en_US.UTF-8
  export LC_ALL=en_US.UTF-8

  # cuda toolkit
  export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}
  export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

  # java toolkit
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
  export SBT_OPTS="-Dsbt.override.build.repos=true"
  ;;
esac

# fzf
source <(fzf --zsh)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$($HOME/miniconda3/bin/conda shell.zsh hook 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

function get_conda_nev() {
  echo -n $CONDA_DEFAULT_ENV
}

# tmux
if [[ -n "$TMUX" ]]; then
  export flavor='conda'
  source $HOME/.tmux/plugins/tmux-conda-inherit/conda-inherit.sh
fi

# zoxide
eval "$(zoxide init --cmd cd zsh)"

case $(hostname) in
ryukk-ubuntu101)
  # rvfpga
  export CATAPULT_SDK_TOPDIR=/opt/imgtec/catapult-sdk_2024.3.0
  function set_rvfpga_env() {
    source ~/catapult-sdk_examples/2024.3.0/set_sdk_path.sh
  }
  export RVfpgaEL2NexysA7DDRPath=/home/ryukk/Projects/RVfpga_NexysA7-DDR

  # vivado
  source ~/tools/Xilinx/Vivado/2022.2/settings64.sh

  # ysyx
  export NEMU_HOME=/home/ryukk/Projects/ysyx/ysyx-workbench/nemu
  export AM_HOME=/home/ryukk/Projects/ysyx/ysyx-workbench/abstract-machine
  export NPC_HOME=/home/ryukk/Projects/ysyx/ysyx-workbench/npc
  export NVBOARD_HOME=/home/ryukk/Projects/ysyx/ysyx-workbench/nvboard

  # polyhedral
  export isl_home=/home/ryukk/Projects/PolyHedral/Tools/barvinok/isl
  export PYTHONPATH="$isl_home/interface:$PYTHONPATH"
  export LD_LIBRARY_PATH=/opt/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

  # # PIM
  # source ~/PIM/upmem/upmem_env.sh

  # triton
  export TRITON_HOME=~/Triton/triton
  export PYTHONPATH="$TRITON_HOME/python:$PYTHONPATH"
  ;;
*) ;;
esac
