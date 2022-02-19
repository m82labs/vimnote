"This sets syntax highlighting for cross-note links
augroup vimnotes
    autocmd! * <buffer>
    autocmd BufRead,BufNewFile *.note hi nlink
        \ guifg=black guibg=green
        \ ctermfg=black ctermbg=green
    autocmd BufRead,BufNewFile *.note syn match nlink "{[a-z].*}"

    "Buffer local bindings for special commands
    autocmd BufRead,BufNewFile *.note noremap <buffer> <leader>l :<c-u>call OpenNoteLink()<cr>
    autocmd BufRead,BufNewFile *.note noremap <buffer> <leader>d :<c-u>call InsertDateHeader()<cr>
    autocmd BufRead,BufNewFile *.note noremap <buffer> <leader>c :<c-u>call CompleteTask()<cr>
    autocmd BufRead,BufNewFile *.note noremap <buffer> <leader>n :<c-u>call NewTask()<cr>i- 
augroup END

function! InsertDateHeader()
    let currdate = strftime("%Y-%m-%d")
    call setline('.', currdate)
    call append('.', repeat('-',10))
endfunction

function! CompleteTask()
    let task = substitute(getline('.'), '^- ', '', '')
    call writefile([strftime("%Y-%m-%d") . ": " . task], "completed.note", "a")
    execute "normal dd"
endfunction

function! NewTask()
    execute "normal gg<cr>"
    let currdate = strftime("%Y-%m-%d")
    let result = search('^' . currdate . '$', "c")
    execute "normal :nohlsearch<cr>"
    execute "normal G<cr>"
    
    if result == 0
        call append('.', "")
        execute "normal G<cr>"
        call append('.', currdate)
        execute "normal G<cr>"
        call append('.',"----------")

    endif
    execute "normal G<cr>"
    let w = strwidth(getline('.'))
    if w > 0
        execute "normal o"
    endif
endfunction

function! OpenNoteLink()
    let word = expand("<cword>")

    execute "below split " . word . ".note"
    let bufsize = wordcount()['chars']
    
    if bufsize == 0
        let currdate = strftime("%Y-%m-%d")
        call append(0,"      file: " . word . ".note")
        call append(1,"   created: " . currdate)
        call append(2,repeat('=',80))
    else
	    call setpos('.', [0, 4, 0, 0])
    endif
endfunction
