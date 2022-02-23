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

function! GetTask(start)
    while matchstr(getline(a:start), '^- ') != '- '
        let a:start -= 1
    endwhile

    let topline = a:start

    let botline = topline
    while matchstr(getline(botline+1), '^- ') != '- ' && strlen(getline(botline+1)) > 0
        let botline += 1
    endwhile
    return [getline(topline, botline),[topline, botline]]
endfunction

function! InsertDateHeader()
    let currdate = strftime("%Y-%m-%d")
    call setline('.', currdate)
    call append('.', repeat('-',10))
endfunction

function! CompleteTask()
    let task_data = GetTask(getpos('.')[1])
    let task = task_data[0]
    let taskp = task_data[1]

    "See if this is a reminder
    if match(task[-1],'>> [0-9]\{8}$') > -1
        let target = 'reminders'
        let remind_date = matchstr(task[-1],'[0-9]\{8}$')
        let task[-1] = substitute(task[-1],'>> [0-9]\{8}','','') . ":" . remind_date
    else 
        "See if it is a named list
        let target = tolower(substitute(matchstr(task[0]), '- \[.*\]'),'[][\- ]','','g'))
        if len(target) == 0
            "If none of the above, it's just a standard task
            let target = 'completed'
        endif
    endif

    echo "Writing task to: " . target . ".note..."

    let task[0] = substitute(task[0], '^- ', '', '')
    call writefile([strftime("%Y-%m-%d") . ": " . task[0]], target . ".note", "a")
    if len(task) > 1
        call writefile(task[1:-1]), target . ".note", "a")
    endif

    execute ":" . taskp[0] . "," . taskp[1] . "d"
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

function! PopReminder()
    "Find and pop valid reminders off the reminder file and into the todo.note
    
endfunction
