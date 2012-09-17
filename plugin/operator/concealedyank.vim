if exists('g:loaded_operator_concealedyank') && g:loaded_operator_concealedyank
  finish
endif
let g:loaded_operator_concealedyank = 1

let s:save_cpo = &cpo
set cpo&vim

if has('conceal')
  " nnoremap <silent> <Plug>(operator-concealedyank) y:call <SID>concealedyank()<CR>
  " TODO implement operator
  nnoremap <silent> <Plug>(operator-concealedyank) y
  xnoremap <silent> <Plug>(operator-concealedyank) y:call <SID>concealedyank()<CR>

  function! s:concealedyank()
    if &concealcursor !~# 'v'
      " Only yank if &concealcursor isn't contains visual mode.
      return
    endif

    let type = getregtype(v:register)

    let startline = line("'[")
    let startcol = col("'[")
    let lastline = line("']")
    let lastcol = col("']")
    let text = []

    if startline == lastline
      " single line
      call add(text, s:getconcealedline(startline, startcol, lastcol))
    elseif type[0] !=# "\<C-v>"
      " multi line
      call add(text, s:getconcealedline(startline, startcol, -1))
      for lnum in range(startline + 1, lastline - 1)
        call add(text, s:getconcealedline(lnum, 1, -1))
      endfor
      call add(text, s:getconcealedline(lastline, 1, lastcol))
    else
      " blockwise
      for lnum in range(startline, lastline)
        call add(text, s:getconcealedline(lnum, startcol, lastcol))
      endfor
    endif

    call setreg(v:register, join(text, "\n"), type)
  endfunction

  function! s:getconcealedline(lnum, startcol, endcol)
    let chars = split(getline(a:lnum), '\zs')
    let endcol = a:endcol >= 1 ? min([a:endcol, len(chars)]) : len(chars)
    let ret = ''

    for col in range(a:startcol, endcol)
      let concealed = synconcealed(a:lnum, col)
      if concealed[0] != 0
        let ret .= concealed[1]
      else
        let ret .= chars[col - 1]
      endif
    endfor

    return ret
  endfunction

else
  nnoremap <Plug>(operator-concealedyank) y
  xnoremap <Plug>(operator-concealedyank) y
endif

let &cpo = s:save_cpo
unlet s:save_cpo
