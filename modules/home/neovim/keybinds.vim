" Move around in buffer with the help of Shift + j/k, closing them with Shift + x
nnoremap <S-j> :bprev<CR>
nnoremap <S-k> :bnext<CR>
nnoremap <S-x> :bdelete<CR>

let mapleader="\<Space>"

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Delete text without putting it into the vim register.
nnoremap D "_d
nnoremap DD "_dd
xnoremap D "_d
nnoremap C "_c
nnoremap CC "_cc
xnoremap C "_c

" Copy to clipboard
nnoremap  <leader>Y "+yg_
nnoremap  <leader>y "+y
vnoremap  <leader>y "+y

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P
