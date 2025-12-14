" ------------------
" General Settings
" ------------------
" ------------------
" General Settings
" ------------------
":set nonumber norelativenumber
set number                      " Show line numbers
set relativenumber              " Relative line numbers
set tabstop=4                   " Number of spaces that a <Tab> counts for
set shiftwidth=4                " Number of spaces for autoindent
set expandtab                   " Use spaces instead of tabs
set smartindent                 " Smart auto-indentation
set cursorline                  " Highlight the current line
set wildmenu                    " Enhanced command-line completion
set clipboard=unnamedplus       " Use system clipboard for copy-paste
set encoding=utf-8              " Encoding for file compatibility
set background=dark             " Preferred background color
set mouse=a                     " Enable mouse support in all modes
" --------------------
" Plugin Management (vim-plug)
" --------------------
call plug#begin('~/.vim/plugged')

" Syntax Highlighting and Language Support
" Plug 'sheerun/vim-polyglot'       " Collection of syntax files for various languages
Plug 'dense-analysis/ale'         " Asynchronous Lint Engine
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Intellisense (like VSCode)

" File Explorer
Plug 'preservim/nerdtree'         " File explorer
Plug 'ryanoasis/vim-devicons'     " NerdTree icons

" Theme and Visual Enhancements
Plug 'morhetz/gruvbox'            " Gruvbox color scheme
Plug 'itchyny/lightline.vim'      " Lightweight status line for Vim
call plug#end()

" ------------------
" Theme and Appearance
" ------------------
colorscheme gruvbox               " Use Gruvbox colors
set termguicolors                 " True colors for better appearance

" --------------------
" Key Bindings
" --------------------
nnoremap <C-n> :NERDTreeToggle<CR>    " Ctrl + N to toggle file explorer
nnoremap <C-s> :w<CR>                 " Save with Ctrl + S
inoremap <C-c> <Esc>                  " Use Ctrl + C to exit insert mode
vnoremap <C-c> "+y                    " Copy to system clipboard
vnoremap <C-v> "+p                    " Paste from system clipboard

" ------------------
" ALE Linting Configuration
" ------------------
let g:ale_fix_on_save = 1            " Automatically fix issues on save
let g:ale_linters = {'python': ['flake8'], 'bash': ['shellcheck']}
let g:ale_fixers = {'python': ['black'], 'bash': ['shfmt']}

" --------------------
" CoC Configuration (Intellisense)
" --------------------
" Install language servers using :CocInstall coc-python coc-sh
let g:coc_global_extensions = ['coc-pyright', 'coc-sh']

" Enable Python Virtual Environment Detection
"augroup python_venv
"    autocmd!
"    autocmd BufEnter * :CocCommand python.setInterpreter
"augroup END

" --------------------
" Enhanced Search
" --------------------
set ignorecase                    " Ignore case when searching
set smartcase                     " Override ignorecase if search contains uppercase

" --------------------
" Lightline Status Line
" --------------------
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ ['mode', 'paste'], ['readonly', 'filename', 'modified'] ]
      \ },
      \ 'component_expand': {
      \ },
      \ 'component_type': {
      \ }
      \ }

