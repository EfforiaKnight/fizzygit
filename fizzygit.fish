function fizzygit
    function __diff_so_fancy
        # use diff-so-fancy if available
        type -qf diff-so-fancy; and echo '|diff-so-fancy'
    end

    function __fzf_fizzycmd
        set -q FZF_TMUX; or set FZF_TMUX 0
        set -q FIZZY_TMUX_HEIGHT; or set FIZZY_TMUX_HEIGHT 80%
        set -q FIZZY_CMD_OPTS; or set FIZZY_CMD_OPTS "\
            --border \
            --ansi \
            --cycle \
            --reverse \
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
        set -l fancy (__diff_so_fancy)

        set -l gitshow "git show --color=always "
        set -l grepsha "echo {} |grep -o '[a-f0-9]\{7\}' |head -1"

        set -l cmd "$grepsha |xargs -I {} $gitshow {} $fancy"
        set -l gitlog "git log --graph --color=always --pretty=format:'%Cred%h%Creset -%C(auto)%d% %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

        if [ $FZF_TMUX -eq 1 ]
            set show "$grepsha |xargs -I {} tmux split-window -p 100 -c '#{pane_current_path}' '$gitshow'{}'$fancy |less -R'"
        else
            set show "$grepsha |xargs -I {} $gitshow {} $fancy |less -R"
        end

        eval "$gitlog |" (__fzf_fizzycmd) ' -e +s --tiebreak=index --bind="enter:execute($show)" --preview="$cmd"'
    end
end
