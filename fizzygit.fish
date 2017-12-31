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

    function gl -d "Pretty git log with fzf"
        inside_work_tree; or return 1
        set -l fancy (__diff_so_fancy)

        set -l gitshow "git show --color=always "
        set -l grepsha "echo {} |grep -o '[a-f0-9]\{7\}' |head -1"

        set -l prevshow "$grepsha |xargs -I {} $gitshow {} $fancy"
        set -l gitlog "git log --all \
            --graph \
            --color=always \
            --pretty=format:'%Cred%h%Creset -%C(auto)%d% %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' \
            $argv"

        if [ $FZF_TMUX -eq 1 ]
            set -q FZF_TMUX_SPLIT_W; or set FZF_TMUX_SPLIT_W \
                "tmux split-window -p 100 -c '#{pane_current_path}'"
            set show "$grepsha \
                |xargs -I {} $FZF_TMUX_SPLIT_W '$gitshow'{}'$fancy \
                |less -R'"
        else
            set show "$prevshow |less -R"
        end

        eval "$gitlog |" (__fzf_fizzycmd) ' \
            --no-sort --exact \
            --tiebreak=index \
            --bind="enter:execute($show)" \
            --preview="$prevshow"'
    end

    function gd -d "Git diff with fzf"
        inside_work_tree; or return 1
        set -l fancy (__diff_so_fancy)

        set -l gitdiff "git diff --color=always -- "

        set -l prevshow "$gitdiff {} $fancy"
        set -l gitls "git ls-files --modified"

        if [ $FZF_TMUX -eq 1 ]
            set -q FZF_TMUX_SPLIT_W; or set FZF_TMUX_SPLIT_W \
                "tmux split-window -p 100 -c '#{pane_current_path}'"
            set show "$FZF_TMUX_SPLIT_W '$gitdiff'{}'$fancy |less -R'"
        else
            set show "$prevshow |less -R"
        end

        eval "$gitls |" (__fzf_fizzycmd) ' -0 \
            --exact \
            --bind="enter:execute($show)" \
            --preview="$prevshow"'
    end

    function ga -d "Git add with fzf"
        inside_work_tree; or return 1
        set -l fancy (__diff_so_fancy)

        set -l gitdiff "git diff --color=always -- "

        set -l prevshow "$gitdiff {-1} $fancy"
        set -l gitstatus git -c color.status=always status --short \
            # \| grep 31m \
            \| awk '\'{printf "[%10s]", $1; $1=""; print $0}\''

        set -l header "alt-enter:add, alt-r:reset, ctrl-p: patch mode"

        if [ $FZF_TMUX -eq 1 ]
            set -q FZF_TMUX_SPLIT_W; or set FZF_TMUX_SPLIT_W \
                "tmux split-window -p 100 -c '#{pane_current_path}'"
            set show "$FZF_TMUX_SPLIT_W '$gitdiff'{-1}'$fancy |less -R'"
        else
            set show "$prevshow |less -R"
        end

        #FIXME: without tmux doesn't work,need to figure out how to pipe to less
        while set -l out (eval "$gitstatus |" (__fzf_fizzycmd) ' -0 \
                --multi --exact \
                --header="$header" \
                --query="$query" \
                --print-query \
                --bind="alt-enter:accept" \
                --bind="ctrl-p:accept" \
                --expect="ctrl-p" \
                --bind="alt-r:accept" \
                --expect="alt-r" \
                --bind="enter:execute($show)" \
                --preview="$prevshow"')
            set -l query $out[1]
            set -l key $out[2]
            set -l files (string match -a -r '(?<=\]\s)[\w]+\.?[\w]*' "$out[3..-1]")

            switch "$key"
                case "ctrl-p"
                    git add -p "$files"
                case "alt-r"
                    git reset HEAD "$files" > /dev/null 2>&1
                case "*"
                    git add "$files" > /dev/null 2>&1
            end
        end
    end
end
