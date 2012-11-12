#############################################
[[ $- != *i* ]] && return # non-interactive #
#############################################

function screenify () {
	local OLDUMASK="$(umask -p)"; umask 077
	[ -O "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && \
		echo -n "$SSH_AUTH_SOCK" > "$(mktemp /tmp/screen-agent-passin.XXXXXXXXXX)"
	export SSH_AUTH_SOCK="$(mktemp -d /tmp/ssh-XXXXXXXXXX)"
	export SSH_AUTH_SOCK="$(mktemp "${SSH_AUTH_SOCK}/agent.XXXXX")"
	eval "$OLDUMASK"

	if [ x"$TERM" == x"screen" ]; then
		screen -RRU -e '^Ss' && exec clear
	else
		screen -xRRU -e '^Aa' && exec clear
	
	fi
}

if [ -n "$STY" ]; then
	function agentify () {
		for BASHRC_SCREENAGENT in /tmp/screen-agent-passin.*; do
			[ -O "$BASHRC_SCREENAGENT" ] || continue
			ln -snf "$(<"$BASHRC_SCREENAGENT")" "$SSH_AUTH_SOCK"
		done
		for BASHRC_SCREENAGENT in /tmp/ssh-*/agent.*; do
			[ -O "$BASHRC_SCREENAGENT" ] || continue
			[ ! -S "$BASHRC_SCREENAGENT" ] || continue
			[ ! -L "$BASHRC_SCREENAGENT" ] || continue
			[ -f "$BASHRC_SCREENAGENT" ] || continue
			rm -f "$BASHRC_SCREENAGENT" &>/dev/null
			rmdir "${BASHRC_SCREENAGENT%/*}" &>/dev/null
			# We reattached and a poor file never got converted to
			# a link.
		done
	}
	agentify
fi

rm -f /tmp/screen-agent-passin.* &>/dev/null

# Screenify if I am permitted, I am myself, I am SSHed or in a non-graphical session, I am not locally screened, and screen exists.
[ ! -f "$HOME"/.noscreen ] && \
[ -n "$BASHRC_AM_OWNER" ] && \
[ -n "$SSH_CONNECTION" -o -z "$DISPLAY" ] && \
[ -z "$STY" ] && \
[ -x "/usr/bin/screen" ] && \
	screenify

# vim: set ft=sh noet : 
