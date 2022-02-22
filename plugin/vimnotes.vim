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
    autocmd InsertLeave *.note call ProcessTask() 
augroup END

function! GetTaskBoundaries(start)
    while matchstr(getline(a:start), '^- ') != '- '
        let a:start -= 1
    endwhile

    let topline = a:start

    let botline = topline
    while matchstr(getline(botline+1), '^- ') != '- ' && strlen(getline(botline+1)) > 0
        let botline += 1
    endwhile
    return [topline, botline]
endfunction

function! InsertDateHeader()
    let currdate = strftime("%Y-%m-%d")
    call setline('.', currdate)
    call append('.', repeat('-',10))
endfunction

function! CompleteTask()
    let taskb = GetTaskBoundaries(getpos('.')[1])

    let target = tolower(substitute(matchstr(getline(taskb[0]), '- \[.*\]'),'[][\- ]','','g'))
    if len(target) == 0
        let target = 'completed'
    endif

    echo "Writing task to: " . target . ".note..."

    let task = substitute(getline(taskb[0]), '^- ', '', '')
    call writefile([strftime("%Y-%m-%d") . ": " . task], target . ".note", "a")
    call writefile(getline(taskb[0]+1,taskb[1]), target . ".note", "a")

    execute ":" . taskb[0] . "," . taskb[1] . "d"
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

function! ProcessTask()
    "General purpose function that gets called whenever leaving edit mode
    let taskb = GetTaskBoundaries(getpos('.')[1])
    for tline in range(taskb[0], taskb[1])
        let m = matchstr(getline(tline),'>> [0-9]\{8}$')
        if len(m)
            " Move to reminder file
            echo "Found: " . m 
            break
        endif
    endfor
endfunction
