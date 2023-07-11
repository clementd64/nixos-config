let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'

	Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim'

	Plug 'github/copilot.vim'
	Plug 'bluz71/vim-moonfly-colors'
	Plug 'neovim/nvim-lspconfig'
	Plug 'williamboman/mason.nvim'

	Plug 'LnL7/vim-nix'
call plug#end()

" Fuck yourself Github and let me use an up to date node version
let g:copilot_ignore_node_version = 1
