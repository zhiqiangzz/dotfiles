# Linux environment (port of shell/zsh/env/os/Linux.zsh).

path_prepend_if_dir /usr/local/cuda/bin

if test -d /usr/local/cuda/lib64
    # LD_LIBRARY_PATH is colon-delimited; fish treats *PATH vars as lists.
    if set -q LD_LIBRARY_PATH
        set -gx LD_LIBRARY_PATH /usr/local/cuda/lib64 $LD_LIBRARY_PATH
    else
        set -gx LD_LIBRARY_PATH /usr/local/cuda/lib64
    end
end

if test -d /usr/lib/jvm/java-17-openjdk
    set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
end

set -gx SBT_OPTS "-Dsbt.override.build.repos=true"
