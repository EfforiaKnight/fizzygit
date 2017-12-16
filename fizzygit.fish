function fizzygit
    # use diff-so-fancy if available
    type -qf diff-so-fancy; and set fancy '|diff-so-fancy'

    function __fzf_fizzycmd
        set -q FZF_TMUX; or set FZF_TMUX 0
        set -q FIZZY_TMUX_HEIGHT; or set FIZZY_TMUX_HEIGHT 80%
        set -q FIZZY_CMD_OPTS; or set FIZZY_CMD_OPTS "\
            --border \
            --ansi \
            --cycle \
            --reverse \
            --multi \
            --bind='alt-v:page-up' \
            --bind='ctrl-v:page-down' \
            --bind='alt-k:preview-up,alt-p:preview-up' \
            --bind='alt-j:preview-down,alt-n:preview-down' \
            --bind='alt-a:select-all' \
            --bind='ctrl-r:toggle-all' \
            --bind='ctrl-s:toggle-sort' \
            --bind='?:toggle-preview' \
            --bind='alt-w:toggle-preview-wrap' \
            --preview-window='right:60%'"

        if [ $FZF_TMUX -eq 1 ]
            echo "fzf-tmux -d$FIZZY_TMUX_HEIGHT $FIZZY_CMD_OPTS"
        else
            echo "fzf --height $FIZZY_TMUX_HEIGHT $FIZZY_CMD_OPTS"
        end
    end

    function inside_work_tree
        git rev-parse --is-inside-work-tree >/dev/null
    end

    function glo
        inside_work_tree; or return 1
        set -l tmux_less "tmux split-window -p 100 -c '#{pane_current_path}' 'git show a83f057 | less -R'"
        set -l cmd "echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I {} git show --color=always {} $fancy"
        set -l cmd "echo {} |grep -o '[a-f0-9]\{7\}' |head -1 |xargs -I {} git show --color=always {} $fancy"
        set -l gitlog "git log --graph --color=always --pretty=format:'%Cred%h%Creset -%C(auto)%d% %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

        eval "$gitlog |" (__fzf_fizzycmd)' -e +s --tiebreak=index --bind="enter:execute($tmux_less)" --preview="$cmd"'
    end
end
