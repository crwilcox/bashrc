[ -d ~/.bashrc.d ] || mkdir ~/.bashrc.d || return

#USED TO GIVE DIFFERENT PROMPT COLORS TO SUDO ACCOUNTS, ETC
#Leave blank for primary/owner (green), set to something if you want the nonprimary color (yellow)
BASHRC_NONPRIMARY_USER=

#LIST ANY SOURCES OF FILES HERE. SPACE DELIMITED. 
BASHRC_SOURCES=(~/.bashrc.d)

#PROTECTED means protected from having random files end up there...
#IF A FILE IS HERE AND NOT IN ALLOWABLE, IT WILL BE NUKED
BASHRC_PROTECTED_MATCH=("$HOME/.bashrc.d/*") 

#THESE ARE THE FILES ALLOWABLE
# 00.preinit.*.sh CHANGES BASED ON LOCATION... USED TO HOLD DEFAULT BASHRC SETTINGS
# "$HOME/.bashrc.d/00.preinit.CAE.sh"   and 	"$HOME/.bashrc.d/00.preinit.CS.sh" are examples
BASHRC_ALLOWABLE_MATCH=(
	"$HOME/.bashrc.d/00.preinit.lucidlynx.sh"
	"$HOME/.bashrc.d/00.preinit.CAE.sh"
	"$HOME/.bashrc.d/00.preinit.CS.sh"
	"$HOME/.bashrc.d/10.environment.sh"
	"$HOME/.bashrc.d/11.prompt.sh"
	"$HOME/.bashrc.d/15.aliases.sh"
	"$HOME/.bashrc.d/50.profile.sh"
	"$HOME/.bashrc.d/80.ssh-agent.sh"
	"$HOME/.bashrc.d/85.screenify.sh"
	"$HOME/.bashrc.d/99.go.sh"
	"$HOME/.bashrc.d/*.sh.local"		
	"$HOME/.bashrc.d/*.local.sh"
) 
  
# a list of files that will never be loaded (may contain wildcards) example $HOME/.bashrc.d/00.thisfile.sh.local
BASHRC_IGNORE_MATCH=(
	"$HOME/.bashrc.d/00.preinit.lucidlynx.sh"
	"$HOME/.bashrc.d/*.hyde.local.sh"
	"$HOME/.bashrc.d/00.preinit.CAE.sh"
	"$HOME/.bashrc.d/*CAE.local.sh"
#	"$HOME/.bashrc.d/00.preinit.CS.sh"
	"$HOME/.bashrc.d/*CS.local.sh"
	) 

BASHRC_NOTIFY_UNKNOWN=1
BASHRC_DELETE_UNKNOWN=1
BASHRC_IGNORE_UNKNOWN=2


# --- HANDLE ANCIENT HOSTS ---

if [ -O "$HOME/.bashrc.local" ]; then
	. "$HOME/.bashrc.local"
	return
fi


# --- MERGE SOURCES ---

declare -a BASHRC_FILES
for BASHRC_SOURCE in "${BASHRC_SOURCES[@]}"; do 
	for BASHRC_FILE in "${BASHRC_SOURCE}/"[0-9][0-9]*.sh*; do
		[ -f "$BASHRC_FILE" ] || continue

		# --- FILE VERIFICATION ---

		BASHRC_FILE_OK=1
		for BASHRC_PROTECTED in "${BASHRC_PROTECTED_MATCH[@]}"; do
			if [[ "$BASHRC_FILE" = $BASHRC_PROTECTED ]]; then
				BASHRC_FILE_OK=
			fi
		done
		for BASHRC_ALLOWABLE in "${BASHRC_ALLOWABLE_MATCH[@]}"; do
			if [[ "$BASHRC_FILE" = $BASHRC_ALLOWABLE ]]; then
				BASHRC_FILE_OK=1
			fi
		done
		if [ -z "$BASHRC_FILE_OK" ]; then
			if [ -n "$BASHRC_NOTIFY_UNKNOWN" ]; then
				echo "Found unknown file \"${BASHRC_FILE}\""
			fi
			if [ -n "$BASHRC_DELETE_UNKNOWN" ]; then
				rm -f -- "$BASHRC_FILE"
				if [ -f "$BASHRC_FILE" ]; then
					echo "WARNING: Failed to delete \"$BASHRC_FILE\""
					ls -ldFh -- "$BASHRC_FILE"
				fi
			fi
			if [ -n "$BASHRC_IGNORE_UNKNOWN" ]; then
				continue
			fi
		fi

		# --- SORTED FILE INSERTION ---

		BASHRC_NEW_FILE="$BASHRC_FILE"
		for BASHRC_I in "${!BASHRC_FILES[@]}"; do
			BASHRC_F="${BASHRC_FILES[$BASHRC_I]}"
			if [ "$BASHRC_NEW_FILE" = "$BASHRC_F" ]; then
				continue 2
			fi
			if [[ "${BASHRC_NEW_FILE##*/}" < "${BASHRC_F##*/}" ]]; then
				BASHRC_FILES[${BASHRC_I}]="$BASHRC_NEW_FILE"
				BASHRC_NEW_FILE="$BASHRC_F"
			fi
		done
		BASHRC_FILES+=("$BASHRC_NEW_FILE")
	done
done
unset BASHRC_NOTIFY_UNKNOWN BASHRC_IGNORE_UNKNOWN BASHRC_DELETE_UNKNOWN
unset BASHRC_PROTECTED BASHRC_ALLOWABLE BASHRC_FILE_OK
unset BASHRC_F BASHRC_I
unset BASHRC_NEW_FILE
unset BASHRC_SOURCE BASHRC_FILE


# --- RUN SCRIPTS ---

if [ -O "$HOME/.bashrc" ]; then
	BASHRC_AM_OWNER=1
else
	BASHRC_AM_OWNER=
fi

for BASHRC_FILE in "${BASHRC_FILES[@]}"; do
	for BASHRC_IGNORE in "${BASHRC_IGNORE_MATCH[@]}"; do
		if [[ "$BASHRC_FILE" = $BASHRC_IGNORE ]]; then
			continue 2
		fi
	done
	. "$BASHRC_FILE"
done

unset "${!BASHRC_@}" &>/dev/null
unset "${!bashrc_@}" &>/dev/null
