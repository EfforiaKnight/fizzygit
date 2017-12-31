# _**fizzygit**_

`fizzygit` is a utility tool for git taking advantage of fuzzy finder [fzf].

## Install
With [fisherman]

```
fisher EfforiaKnight/fizzygit
```

Add following block to your `config.fish`
``` sh
if type -q fizzygit
    fizzygit
end
```
### Optional
* Install [diff-so-fancy] will give you better quality of diff output.

## Notes
* Required fish version: `>=2.4.0`
* Compatible fzf versions: `>0.11.3`

## Configuration
Variable `FZF_TMUX` - runs a tmux-friendly version of fzf instead
```
set -U FZF_TMUX 1
```

## Commands
#### gl
Pretty `git log` inside fzf
![ga](https://github.com/EfforiaKnight/fizzygit/blob/master/Screenshot_gl.png)

| Keys             | Action                |
| ---------------- | --------------------- |
| `<Enter>`        | Fullscreen preview    |
| `<C-j/n><C-k/p>` | Selection down/up     |
| `<?>`            | Toogle preview window |
| `<A-w>`          | Toggle preview wrap   |
| `<A-j><C-k>`     | Preview down/up       |

#### gd
`git diff` inside fzf
![gd](https://github.com/EfforiaKnight/fizzygit/blob/master/Screenshot_gd.png)

| Keys             | Action                |
| ---------------- | --------------------- |
| `<Enter>`        | Fullscreen preview    |
| `<C-j/n><C-k/p>` | Selection down/up     |
| `<?>`            | Toogle preview window |
| `<A-w>`          | Toggle preview wrap   |
| `<A-j><C-k>`     | Preview down/up       |

#### ga
Interactive `git add` inside fzf
![gd](https://github.com/EfforiaKnight/fizzygit/blob/master/Screenshot_ga.png)

| Keys             | Action                           |
| ---------------- | -------------------------------- |
| `<Enter>`        | Fullscreen preview               |
| `<C-j/n><C-k/p>` | Selection down/up                |
| `<?>`            | Toogle preview window            |
| `<A-w>`          | Toggle preview wrap              |
| `<A-j><C-k>`     | Preview down/up                  |
| `<Tab>`          | Mark/Unmark(and move down)       |
| `<C-r>`          | Reverse selection                |
| `<A-Enter>`      | `git add` selected files         |
| `<C-p>`          | `git add --patch` selected files |
| `<A-r>`          | `git reset HEAD` selected files  |

## Known issue
* Fullscreen preview doesn't work in `ga` when not in `tmux` mode.

[fzf]:https://github.com/junegunn/fzf
[fisherman]: https://github.com/fisherman/fisherman
[tmux]: https://tmux.github.io/
[diff-so-fancy]: https://github.com/so-fancy/diff-so-fancy
