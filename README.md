# zsh-jumper

## requirements

* [fzf](https://github.com/junegunn/fzf)

## ussage

| cmd    |                                |
|---     |---                             |
| `j`    | select from directory history  |
| `j ..` | select from parent directories |
| `j .`  | select from sub directories    |


## as cd replacement

add following to your '$HOME/.zshrc'
alias cd='jump::cd'

| cmd     |                                |
|---      |---                             |
| `j :`   | select from directory history  |
| `j ...` | select from parent directories |
| `j .`   | select from sub directories    |
