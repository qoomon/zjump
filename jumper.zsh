autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

type compdef >/dev/null && compdef _cd j # set default completion
function j {
  # check for fzf installed
  if ! type fzf >/dev/null; then
    echo "couldn't find fzf installation" >&2
    return 1
  fi
  
  local cmd="$1"
  case "$cmd" in
    '...') # parent folder selection
      shift;
      local pwd_list=('/' ${(s:/:)PWD%/*})
      local indexed_pwd_list=()
      for pwd_part_index in {1..${#pwd_list}}; do
          indexed_pwd_list[$pwd_part_index]="$pwd_part_index $pwd_list[$pwd_part_index]"
      done
      local pwd_index
      pwd_index="$(echo "${(F)indexed_pwd_list}" | fzf --tac --height 10 --reverse --prompt='  ' --exact --with-nth=2.. | awk '{print $1}')"
      if [[ $status == 1 ]]; then
        echo "no directory matches" >&2
        return 1
      elif [[ $status == 130 ]]; then
        return 0
      fi
      
      local dir_list=(${pwd_list:0:$pwd_index})
      local dir="${(j:/:)dir_list}"
      builtin cd $dir
      ;;
    '.') # subfolder selection
      shift;
      local dir_query="$*"
      local dir
      dir=$(find . -mindepth 1 -type d 2>&1 | grep -v 'find:.*Permission denied' | sed 's|^\./\(.*\)|\1|' | fzf --tac --height 10 --reverse --prompt='  ' --query "$dir_query" --exact --select-1 --exit-0)
      if [[ $status == 1 ]]; then
        echo "no directory matches" >&2
        return 1
      elif [[ $status == 130 ]]; then
        return 0
      fi
      
      builtin cd $dir
      ;;
    ':') # historyfolder selection
      shift;
      local dir_query="$@"
      local dir
      dir="$(cdr -l | while read -r line; do echo "${${=line}[@]:1}"; done | fzf  --height 10 --reverse  --prompt='  ' --query "$dir_query" --exact --select-1 --exit-0)"
      if [[ $status == 1 ]]; then
        echo "no directory matches" >&2
        return 1
      elif [[ $status == 130 ]]; then
        return 0
      fi
      
      dir=${dir/#'~'/$HOME}
      builtin cd $dir
      ;;
    *)
      builtin cd $@ >/dev/null # suppress stdout
      ;;  
  esac
  
  
}
