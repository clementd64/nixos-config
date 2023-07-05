syntax on
set nu rnu " Show line number

set showmatch
set incsearch

set showtabline=2

set termguicolors
colorscheme moonfly

" Hides the -- INSERT -- and lets the vim-airline plugin do it
set noshowmode

let g:airline_powerline_fonts = 1
let g:airline_theme='violet'

" Show whitespace
set listchars=tab:→\ ,trail:•,extends:»,precedes:«,space:·
set list

let g:airline#extensions#tabline#enabled = 1

" Show 10 lines from the top / bottom minimum
set so=10

" Disable mouse
set mouse=