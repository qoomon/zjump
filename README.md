# zsh-jumper

## requirements

* [fzf](https://github.com/junegunn/fzf)

## ussage
select from directory history
* j   

select from parent directories
* j .. 

select from sub directories

* j . 


## as cd replacement
add following to your '$HOME/.zshrc'
alias cd='jump::cd'

### commands

select from directory history
  * cd :

select from parent directories
  * cd ...

select from sub directories
  * cd .
