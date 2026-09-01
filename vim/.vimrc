let mapleader = " "
set undofile

set noswapfile

set number
set relativenumber

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent
filetype plugin indent on

set ignorecase
set smartcase
set incsearch
set hlsearch

set ttimeout
set ttimeoutlen=10

set termguicolors
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20

if $TERM =~# 'tmux\|screen'
  let &t_EI = "\<Esc>[2 q"
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
endif

set background=dark
syntax enable
colorscheme retrobox

nnoremap <silent> J 5j
xnoremap <silent> J 5j
nnoremap <silent> K 5k
xnoremap <silent> K 5k

nnoremap <silent> H ^
xnoremap <silent> H ^
onoremap <silent> H ^
nnoremap <silent> L g_
xnoremap <silent> L g_
onoremap <silent> L g_

nnoremap <silent> <C-e> 3<C-e>
nnoremap <silent> <C-y> 3<C-y>

xnoremap <silent> w iw
onoremap <silent> w iw
xnoremap <silent> ii i{
onoremap <silent> ii i{
xnoremap <silent> ai a{
onoremap <silent> ai a{
xnoremap <silent> b i(
onoremap <silent> b i(

xnoremap <silent> ie <Esc>ggVG
onoremap <silent> ie :normal! ggVG<CR>

nnoremap <silent> <leader>a za
nnoremap <silent> <leader>nh :nohlsearch<CR>

if exists('##TextYankPost')
  function! s:ClearYankHighlight(match_id, timer) abort
    if exists('*matchdelete')
      silent! call matchdelete(a:match_id)
    endif
  endfunction

  function! s:HighlightYank() abort
    let l:start = getpos("'[" )
    let l:end = getpos("']")
    let l:positions = []

    for l:line in range(l:start[1], l:end[1])
      let l:first_col = l:line == l:start[1] ? l:start[2] : 1
      let l:last_col = l:line == l:end[1] ? l:end[2] : strlen(getline(l:line))
      let l:length = max([1, l:last_col - l:first_col + 1])
      call add(l:positions, [l:line, l:first_col, l:length])
    endfor

    let l:match_id = matchaddpos('IncSearch', l:positions, 10)
    call timer_start(300, function('s:ClearYankHighlight', [l:match_id]))
  endfunction

  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent! call <SID>HighlightYank()
  augroup END
endif

" Copy Visual-mode selections to the local Kitty clipboard via OSC 52.
if !has('gui_running') && executable('base64') && executable('tr')
  function! s:Osc52Copy() abort
    let l:text = @"
    if empty(l:text)
      return
    endif

    let l:encoded = system('base64 | tr -d "\\r\\n"', l:text)
    let l:sequence = printf("\<Esc>]52;c;%s\x07", l:encoded)
    if exists('$TMUX') && !empty($TMUX)
      let l:sequence = "\<Esc>Ptmux;" . substitute(l:sequence, "\<Esc>", "\<Esc>\<Esc>", 'g') . "\<Esc>\\"
    endif
    call system('printf %s ' . shellescape(l:sequence) . '> /dev/tty')
  endfunction

  xnoremap <silent> y y:call <SID>Osc52Copy()<CR>
endif

nnoremap <silent> <leader>q :qa<CR>

