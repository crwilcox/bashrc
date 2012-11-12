[ x"$TERM" == x"screen.linux" ] && export TERM=screen

[ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin"


BASHRC_EDITORS=(vim vi nano pico)
BASHRC_ASKPASS=(x11-ssh-askpass ssh-askpass-fullscreen ssh-askpass)

unset EDITOR
IFS=':' read -a BASHRC_ARRAYPATH <<<"$PATH"
for BASHRC_EDITOR in "${BASHRC_EDITORS[@]}"; do
	for BASHRC_BINDIR in "${BASHRC_ARRAYPATH[@]}"; do
		if [ -x "$BASHRC_BINDIR/$BASHRC_EDITOR" ]; then
			export EDITOR="$BASHRC_EDITOR"
			break 2
		fi
	done
done

unset SSH_ASKPASS
IFS=':' read -a BASHRC_ARRAYPATH <<<"$PATH"
for BASHRC_ASKPASS in "${BASHRC_ASKPASS[@]}"; do
	for BASHRC_BINDIR in "${BASHRC_ARRAYPATH[@]}"; do
		if [ -x "$BASHRC_BINDIR/$BASHRC_ASKPASS" ]; then
			export SSH_ASKPASS="$BASHRC_BINDIR/$BASHRC_ASKPASS"
			break 2
		fi
	done
done

if [ "$UID" -eq 0 ]; then
	umask 0022
else
	umask 0026
fi

#############################################
[[ $- != *i* ]] && return # non-interactive #
#############################################

stty stop undef
stty start undef

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'

shopt -s histverify
HISTIGNORE='&' # Do not save repeated lines many times.

# vim: set ft=sh noet : 
