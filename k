#!/usr/bin/env fish

function usage
    echo 'usage: k [options] <command>'
    echo
    echo 'options:'
    echo '  -h | --help  Show this help'
    echo
    echo 'commands:'
    echo '  add'
    echo '  remove | rm'
    echo '  list | ls'
    exit 1
end

function add -a profile
    test -n "$profile"
    or usage
    ln -fs ~/bin/kubectl.wrapper ~/bin/kubectl.$profile
    echo "complete -c kubectl.$profile -w kubectl" >~/.config/fish/completions/kubectl.$profile.fish
end

function remove -a profile
    test -n "$profile"
    or usage
    set profile $argv[1]
    rm ~/bin/kubectl.$profile
    rm -f ~/.config/fish/completions/kubectl.$profile.fish
end

function list
    begin
        cd ~/bin
        ls kubectl.*
    end | grep -v kubectl.wrapper | sed 's|^kubectl\.||'
end

function parse -a cmd
    test -n "$cmd"
    or usage

    switch $cmd
        case add
            add $argv[2..-1]
        case remove rm
            remove $argv[2..-1]
        case ls list
            list
        case '*'
            usage
    end
end

parse $argv
