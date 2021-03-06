" Copyright (c) 2012, chikatoike
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
"
"     Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
"     Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
      " if &concealcursor isn't contains "v" (visual mode), yank as normal.
      return
    endif

    let type = getregtype(v:register)

    let startline = line("'[")
    let lastline = line("']")
    " col is zero based.
    let startcol = col("'[") - 1
    let lastcol = col("']") - 1

    let text = []

    if startline == lastline
      " single line
      call add(text, s:getconcealedline(startline, startcol, lastcol))

    elseif type[0] !=# "\<C-v>"
      " multi line
      call add(text, s:getconcealedline(startline, startcol, -1))
      for lnum in range(startline + 1, lastline - 1)
        call add(text, s:getconcealedline(lnum, 0, -1))
      endfor
      call add(text, s:getconcealedline(lastline, 0, lastcol))

    else
      " blockwise
      for lnum in range(startline, lastline)
        call add(text, s:getconcealedline(lnum, startcol, lastcol))
      endfor
    endif

    call setreg(v:register, join(text, "\n"), type)
  endfunction

  function! s:getconcealedline(lnum, startcol, endcol)
    let line = getline(a:lnum)
    let index = a:startcol
    let endcol = a:endcol >= 0 ? min([a:endcol, strlen(line)]) : strlen(line)

    let region = -1
    let ret = ''

    while index <= endcol
      let concealed = synconcealed(a:lnum, index + 1)
      if concealed[0] != 0
        if region != concealed[2]
          let region = concealed[2]
          let ret .= concealed[1]
        endif
      else
        let ret .= line[index]
      endif

      " get next char index.
      let index += 1
    endwhile

    return ret
  endfunction

else
  nnoremap <Plug>(operator-concealedyank) y
  xnoremap <Plug>(operator-concealedyank) y
endif

let &cpo = s:save_cpo
unlet s:save_cpo
