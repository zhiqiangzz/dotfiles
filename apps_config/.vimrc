"" sudo override the edit file
"" :w !sudo tee %

set shiftwidth=2
set tabstop=2
" set expandtab
set ignorecase
" set number
" set relativenumber


inoremap jj <Esc>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-n> <Down>
inoremap <C-p> <Up>

nnoremap <S-j> 5j
nnoremap <S-k> 5k
nnoremap L g_
nnoremap H ^

vnoremap <S-j> 5j
vnoremap <S-k> 5k
vnoremap L $
vnoremap H ^
