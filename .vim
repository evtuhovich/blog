let g:ctrlp_custom_ignore = {
    \ 'dir':  '\(build\)',
    \ }


augroup ruby
	autocmd!
	autocmd BufRead,BufNewFile *.markdown set formatoptions+=a expandtab

	set spell
	set spelllang=ru,en
augroup END
