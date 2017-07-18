autoload -Uz chpwd_recent_dirs cdr
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':chpwd:*' recent-dirs-file ${ZDOTDIR:-$HOME}/.chpwd-recent-dirs
zstyle ':chpwd:*' recent-dirs-max 1024

function j {
  # check for fzf installed
  if ! type fzf >/dev/null; then
    echo "couldn't find fzf installation" >&2
    return 1
  fi
  
  local cmd="$1"
  case "$cmd" in
    '..') # parent folder selection
      shift;
      local dir_query=$@
      
      local pwd_list=('/' '/'${^${(s:/:)PWD%/*}})
      local indexed_pwd_list=()
      for pwd_part_index in {1..${#pwd_list}}; do
          indexed_pwd_list[$pwd_part_index]="$pwd_part_index $pwd_list[$pwd_part_index]"
      done
      
      local pwd_index
      zle && zle kill-buffer && zle -R
      pwd_index=$(echo ${(F)indexed_pwd_list} | fzf --tac --height 10 --reverse --query "$dir_query" --exact --select-1 --exit-0 --with-nth=2..) \
        && pwd_index=${${=pwd_index}[@]:0:1}
      if [[ $status == 1 ]]; then
        echo "no directory matches" >&2
        return 1
      elif [[ $status == 130 ]]; then
        return 0
      fi

      local dir=${${(j::)pwd_list:0:$pwd_index}//#\/\//\/} # remove double
      builtin cd $dir
      ;;
    '.') # subfolder selection
      shift;
      local dir_query=$@
      
      local dir
      dir=$(find . -mindepth 1 -type d 2>&1 | grep -v 'find:.*Permission denied' | sed 's|^\./\(.*\)|\1|' | fzf --tac --height 10 --reverse --query "$dir_query" --exact --select-1 --exit-0)
      if [[ $status == 1 ]]; then
        echo "no directory matches" >&2
        return 1
      elif [[ $status == 130 ]]; then
        return 0
      fi
      
      builtin cd $dir
      ;;
    *) # historyfolder selection
      local dir_query=$@
      
      local dir
      dir=$((for entry (${(f)"$(cdr -l)"}) echo ${${${=entry}[@]:1}/#'~'/$HOME}) | fzf  --height 10 --reverse --query "$dir_query" --exact --select-1 --exit-0) \
        && dir=${dir/#'~'/$HOME}
      if [[ $status == 1 ]]; then
        echo "no directory matches" >&2
        return 1
      elif [[ $status == 130 ]]; then
        return 0
      fi
      
      builtin cd $dir
      ;;
  esac
  
  
}
