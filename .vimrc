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
au BufNewFile,BufRead *.g       setf antlr
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
syntax on
syntax on
