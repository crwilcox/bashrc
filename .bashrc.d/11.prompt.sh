#############################################
[[ $- != *i* ]] && return # non-interactive #
#############################################

if [ "$UID" -eq 0 ]; then
	#give red name if root
	export PS1='\[\033[01;31m\]\h\[\033[01;34m\] \w \$\[\033[00m\] '
elif [ -n "$BASHRC_AM_OWNER" ] && [ -z "$BASHRC_NONPRIMARY_USER" ]; then
	#give green name if not flagged as a nonprimary user
	export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
else
	#give yellow name
	export PS1='\[\033[01;33m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
fi

function title_generator () {
		local PROMPT_CHAR='$'
		local USER_BIT="${USER}@"
		local PATH_BIT="${PWD/#$HOME/~}"
		local COMMAND_BIT=''
		if [ "$UID" -eq 0 ]; then
			PROMPT_CHAR='#'
			USER_BIT=''
			# '/' = '': PATH_BIT="${PWD##*/}"
		fi
		[ -n "$*" ] && COMMAND_BIT=" $*"
		echo -nE "${USER_BIT}${HOSTNAME%%.*} ${PATH_BIT} ${PROMPT_CHAR}${COMMAND_BIT}"
}

function get_current_history_command () {
	local COMMAND="$(history 1)"
	COMMAND="${COMMAND#*[0-9]  }"

	local -a COMMAND_ARRAY
	read -a COMMAND_ARRAY <<<"$COMMAND"
	if [ "${COMMAND_ARRAY[0]}" = "fg" ]; then
		JOB="$(jobs "${COMMAND_ARRAY[1]}" 2>/dev/null)"
		JOB="${JOB#*                 }"
		if [ "$?" -eq 0 ]; then
			echo -nE "$JOB"
			return
		fi
	fi
	echo -nE "${COMMAND_ARRAY[*]}"
}

if [ "$TERM" == screen ]; then
	# So our parent screen displays only the hostname, before screenifying display it.
	# The prompt will soon fix it.
	echo -ne "\ek${HOSTNAME%%.*}\e\\"

	function prompt_command () {
		local TITLE="$(title_generator)"
		TITLE="${TITLE//\\/\\\\}"
		echo -ne "\ek${TITLE:0:250}\e\\"
		echo -ne "\033]0;${TITLE:0:250}\007"
	}
	function preexec_command () {
		COMMAND="$(get_current_history_command)"
		local TITLE="$(title_generator "$COMMAND")"
		TITLE="${TITLE//\\/\\\\}"
		echo -ne "\ek${TITLE:0:250}\e\\"
		echo -ne "\033]0;${TITLE:0:250}\007"
	}
elif [ "$TERM" == xterm -o "$TERM" == xterm-color ]; then
	function prompt_command () {
		local TITLE="$(title_generator)"
		TITLE="${TITLE//\\/\\\\}"
		echo -ne "\033]0;${TITLE:0:250}\007"
	}
	function preexec_command () {
		COMMAND="$(get_current_history_command)"
		local TITLE="$(title_generator "$COMMAND")"
		TITLE="${TITLE//\\/\\\\}"
		echo -ne "\033]0;${TITLE:0:250}\007"
	}
fi


# Set up prompt_command and preexec_command execution.

function preexec_prompt_command () {
	PREEXEC_INTERACTIVE=
	declare -Ff prompt_command &>/dev/null && prompt_command
	PREEXEC_INTERACTIVE=1
}
function preexec_preexec_command () {
	local INTERACTIVE_COMMAND="$BASH_COMMAND"
	[ -n "$COMP_LINE" ] && return 0 # We are running a completion routine.
	[ -z "$PREEXEC_INTERACTIVE" ] && return 0 # We have already executed this time.
	[ -t 1 ] || return 0 # STDOUT is not a terminal.
	PREEXEC_INTERACTIVE=
	[ "$INTERACTIVE_COMMAND" == "preexec_prompt_command" ] && return 0 # A double-prompt is trying to trick us.
	declare -Ff preexec_command &>/dev/null && preexec_command
	return 0
}
set -o functrace &>/dev/null
shopt -s extdebug &>/dev/null
PROMPT_COMMAND=preexec_prompt_command
trap preexec_preexec_command DEBUG

# vim: set ft=sh noet : 
