if status is-interactive
    # Commands to run in interactive sessions can go here
end
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
starship init fish | source

function ls --description 'Use eza instead of ls'
    eza -h \
        --icons \
        --group-directories-first \
        --git \
        --header \
        --time-style=long-iso \
        $argv
end

function y --description 'Use yazi as y'
    yazi
end

alias bb 'brew bundle --global'
