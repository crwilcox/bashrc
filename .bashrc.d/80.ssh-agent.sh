#######################################################
[ -n "$BASHRC_AM_OWNER" ] || return # I am not myself #
#######################################################
[[ $- != *i* ]] && return # non-interactive #
#############################################

# There is already a valid socket.
[ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && [ -O "$SSH_AUTH_SOCK" ] && return

# Do not create agents within screens automatically.
[ -n "$STY" ] && return

exec ssh-agent $SHELL

# vim: set ft=sh noet : 
