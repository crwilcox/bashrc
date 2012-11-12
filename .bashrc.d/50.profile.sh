#######################################################
[ -n "$BASHRC_AM_OWNER" ] || return # I am not myself #
#######################################################

BASHRC_PROFILE_OLDPWD="$PWD"
cd "$HOME"

[ -O ~/.lesshst ] || rm -f ~/.lesshst 2>/dev/null
[ -O ~/.viminfo ] || rm -f ~/.viminfo 2>/dev/null
[ -O ~/.bash_history ] || rm -f ~/.bash_history 2>/dev/null

# And lest root end up owning them...
for BASHRC_I in ~/.viminfo ~/.lesshst ~/.bash_history; do
	[ -f "$BASHRC_I" ] || touch "$BASHRC_I"
done

[ -L ~/.profile ] && rm ~/.profile
[ -L ~/.bash_profile ] || ln -snf .bashrc .bash_profile

[ -L ~/.mysql_history ] || ln -snf /dev/null ~/.mysql_history

cd "$BASHRC_PROFILE_OLDPWD"
#############################################
[[ $- != *i* ]] && return # non-interactive #
#############################################

[ -f ~/.profile_initialized ] && [ ~/.profile_initialized -nt "${BASH_SOURCE[0]}" ] && return
cd "$HOME"

[ -d ~/.bashrc.d/.bashrc.d ] && rm -rf ~/.bashrc.d/.bashrc.d 2>/dev/null

function bashrc_install_file() {
	if [ -f "$1".localized ]; then
		echo "Profile Generation: $1 Localized."
		return
	fi
	echo "Profile Generation: $1 Installing."
	rm -- "$1" &>/dev/null
	[ -e "$1" ] && return
	cat >| "$1" || return
	if [ -O "$1".append ]; then
		echo "Profile Generation: $1 Appending."
		cat "$1".append >> "$1" || return
	fi
	echo "Profile Generation: $1 Done."
}
#THIS BLOCK IS FOR VIMRC... PLACE THE FILE CONTENTS HERE
#Color themes for VIM: blue, darkblue, default, delek, desert, 
#						elflord, evening, koehler, morning, murphy,
#						pablo, peachpuff, ron, shine, slate, torte, zellner
umask 0022
bashrc_install_file .vimrc <<'EOF'
syntax on
color koehler
nmap <silent> <C-N> :silent noh<LF>
set clipboard=autoselect,exclude:cons\|linux\|screen\|xterm
set formatoptions+=cql

"SETUP TABBING FOR FILETYPES
set sw=4 ts=4 noet
filetype plugin indent on
autocmd FileType python set ts=4 formatoptions-=t
let python_highlight_space_errors = 1
set modeline

filetype plugin indent on
autocmd FileType java set tw=80 cindent ts=4 sw=4
autocmd FileType python set ts=4 sw=4 tw=80 formatoptions-=t
autocmd FileType cfengine set ts=4 sw=4 commentstring=#%s
let python_highlight_space_errors = 1
set modeline



augroup filetypedetect
au BufNewFile,BufRead cf.*      setf cfengine
au BufNewFile,BufRead cfagent.conf      setf cfengine
au BufNewFile,BufRead cfservd.conf      setf cfengine
au BufNewFile,BufRead update.conf       setf cfengine
augroup END

set clipboard=autoselect,exclude:cons\|linux\|screen


function! AppendModeline(tab, width, indent_ai, indent_pi)
	let f_tab           = a:tab >= 1
	let f_tab_noet      = a:tab >= 2
	let f_tab_all       = a:tab >= 3

	let f_width         = a:width >= 1
	let f_width_all     = a:width >= 2

	let f_indent_ai     = a:indent_ai >= 1
	let f_indent_ai_all = a:indent_ai >= 2

	let f_indent_pi     = a:indent_pi >= 1
	let f_indent_pi_all = a:indent_pi >= 2

	
	"let save_cursor = getpos('.')
	let modes = ''

	if len(&ft)
		let modes .= ' ft='.&ft
	endif
	if f_tab
		if f_tab_all || &ts != &sw
			let modes .= ' ts='.&ts
			let modes .= ' sw='.&sw
		endif

		if f_tab_all || (&sts != 0 && &sts != &ts)
			let modes .= ' sts='.&sts
		endif

		if &smarttab
			let modes .= ' sta'
		elseif f_tab_all
			let modes .= ' nosta'
		endif

		if &expandtab
			let modes .= ' et'
		elseif f_tab_noet
			let modes .= ' noet'
		endif
	endif

	if f_width && (f_width_all || &tw != 0)
		let modes .= ' tw='.&tw
	endif

	if f_indent_ai
		if &cindent
			let modes .= ' cin'
		elseif f_indent_ai_all
			let modes .= ' nocin'
		endif

		if &smartindent && ! &cindent
			let modes .= ' si'
		elseif f_indent_ai_all
			let modes .= ' nosi'
		endif

		if &autoindent && !&smartindent && ! &cindent
			let modes .= ' ai'
		elseif f_indent_ai_all
			let modes .= ' noai'
		endif
	endif

	if f_indent_pi
		if &copyindent
			let modes .= ' ci'
		elseif f_indent_pi_all
			let modes .= ' noci'
		endif

		if &preserveindent
			let modes .= ' pi'
		elseif f_indent_pi_all
			let modes .= ' nopi'
		endif
	endif

	if modes == ''
		echo "No custom settings found.  Modeline not necessary."
		return
	endif

	let modes = ' vim'.': set'.modes.' : '
	if &ft == 'php'
		let modes = '<?php /*'.modes.'*/ ?>'
		call setline('$', getline('$').modes)
	else
		let modes = "\n". substitute(&commentstring, '%s', modes, '')
		$put =modes
	endif
	"call setpos('.', save_cursor)
	call setpos('.', [0, line('$'), 1, 1])
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline(2,1,1,1)<CR>
nnoremap <silent> <Leader>tml :call AppendModeline(3,1,1,1)<CR>

function! Tabify()
	let whitelen = strlen(substitute(getline('.'), '[^\t ].*$', '', ''))
	let whitelen = virtcol([line('.'), whitelen])
	let tablen = whitelen / &ts
	let spclen = whitelen % &ts
	call setline('.', substitute(getline('.'), '^[\t ]*', repeat('\t', tablen) . repeat(' ', spclen), ''))
	"call setline('.', substitute(getline('.'), '\v%(^\t* *)@<= {'.&ts.'}', '\t', 'g'))
endfunction
command! -range=% Tabify call Tabify()

" vim: set ft=vim noet tw=78 ai :  
EOF

#THIS BLOCK IS FOR SCREENRC... PLACE THE FILE CONTENTS HERE
bashrc_install_file .screenrc <<'EOF'
termcapinfo xterm*|rxvt*|kterm*|Eterm* 'hs:ts=\E]0;:fs=\007:ds=\E]0;screen\007'
termcapinfo screen 'hs:ts=\Ek:fs=\E\\:ds=\Ekscreen\E\\'
hardstatus string "%t"
defutf8 on
bind q
bind s
bind k focus up
bind K focus top
bind j focus down
bind J focus bottom
#zombie ^DR

altscreen	 on

bind - command -c selectxx
bind -c selectxx - select -

bind -c selectxx 0 command -c select0x
bind -c selectxx 1 command -c select1x
bind -c selectxx 2 command -c select2x

bind -c select0x 0 select 0
bind -c select0x 1 select 1
bind -c select0x 2 select 2
bind -c select0x 3 select 3
bind -c select0x 4 select 4
bind -c select0x 5 select 5
bind -c select0x 6 select 6
bind -c select0x 7 select 7
bind -c select0x 8 select 8
bind -c select0x 9 select 9

bind -c select1x 0 select 10
bind -c select1x 1 select 11
bind -c select1x 2 select 12
bind -c select1x 3 select 13
bind -c select1x 4 select 14
bind -c select1x 5 select 15
bind -c select1x 6 select 16
bind -c select1x 7 select 17
bind -c select1x 8 select 18
bind -c select1x 9 select 19

bind -c select2x 0 select 20
bind -c select2x 1 select 21
bind -c select2x 2 select 22
bind -c select2x 3 select 23
bind -c select2x 4 select 24
bind -c select2x 5 select 25
bind -c select2x 6 select 26
bind -c select2x 7 select 27
bind -c select2x 8 select 28
bind -c select2x 9 select 29
EOF

bashrc_install_file .bash_logout <<'EOF'
# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
	if [ -x /usr/bin/clear_console ]; then
		/usr/bin/clear_console -q
	else
		clear
	fi
fi
EOF

umask 0026
if [ ! -e .ssh ]; then
	echo "Profile Generation: .ssh/ Installing.";
	mkdir .ssh;
	chmod g-w,o= .ssh
	echo "Profile Generation: .ssh/ Done.";
fi

umask 0077
rm -f .profile_initialized 2>/dev/null
date >| .profile_initialized


cd "$BASHRC_PROFILE_OLDPWD"
unset bashrc_install_file

# vim: set ft=sh noet : 
