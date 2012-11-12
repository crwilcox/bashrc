#############################################
[[ $- != *i* ]] && return # non-interactive #
#############################################

#    OS Specific Aliases    #
if [[ "$MACHTYPE" = *linux* ]]; then
	alias ls="ls -F --color=auto"
	alias ll="ls -AFlh --color=auto"
	alias getmyldap='ldapsearch -xZZLLL -s base -b uid='"$USER"',ou=People,o=ENGR -WD uid='"$USER"',ou=People,o=ENGR'
	#alias grep="grep --exclude-dir '.svn'"
fi

#    OS Specific Aliases    #
if [[ "$MACHTYPE" = *solaris* ]]; then
	alias ls="ls -F"
	alias ll="ls -AFlh"
fi

#    Standard Aliases    #
alias mumble="ssh -X wilcox@best-mumble.cs.wisc.edu"
alias king="ssh -X wilcox@best-king.cs.wisc.edu"
alias cae="ssh -X cwilcox@best-tux.cae.wisc.edu"
alias e='$EDITOR'
alias edit='$EDITOR'
alias cpl="clear;pwd;ll"
alias toggle="pushd;cpl"
alias prwd='readlink -e .'
alias crwd='cd "$(readlink -e .)"'
[ -f "$HOME/bin/sshkey" ] || alias sshkey='ssh-add -c'
function forgethost () { sed -i "${1}d" "$HOME/.ssh/known_hosts"; }
function makebackup () { local I; for I in "$@"; do D="$(date +%Y%m%d-%H%M%S)"; cp -avi "$I" "$I"."$D"; chmod a-w "$I"."$D"; done }
function indent_pipe () { sed -r 's/^/\t/' 1>&2 2>&1 | sed -r 's/^/\t/' 1>&2 2>&1 ; }

function reagent () {
	local SHELLPID="$$"
	eval "$(ssh-agent "$@")" >/dev/null
	(
		(
			while [ -O /proc/"$SHELLPID" ]; do
				sleep 1
			done
			kill "$SSH_AGENT_PID"
		) &
		disown %%
	)
}

# vim: set ft=sh noet : 
