if &shell =~# 'fish$'
    set shell=/bin/sh
endif


" " My Bundles here:
" call plug#begin('~/.local/share/nvim/plugged')
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
" - For vim:
"   call plug#begin('~/.vim/plugged')
call plug#begin(stdpath('data') . '/plugged')
" call plug#begin('~/.config/nvim/site/autoload')
" call plug#begin()

" Language Server
"
" Plug 'autozimu/LanguageClient-neovim', { 'tag': 'binary-*-x86_64-apple-darwin', 'do': ':UpdateRemotePlugins' }
" branch is 'next'
" Plug 'autozimu/LanguageClient-neovim', {'commit': 'cf6dd11baf62fb6ce18308e96c0ab43428b7c686', 'do': 'bash install.sh' }
" fork for a couple fixes we needed to do locally. would prefer to use the
" upstream version. "
Plug 'scooter-dangle/LanguageClient-neovim', {'branch': 'recent-fixes', 'do': 'bash install.sh' }

" "
" " Rust (see https://rust-analyzer.github.io/manual.html#nvim-lsp)
" "
" " Collection of common configurations for the Nvim LSP client
" Plug 'neovim/nvim-lspconfig'
" " Extensions to built-in LSP, for example, providing type inlay hints
" " Might break things
" Plug 'nvim-lua/lsp_extensions.nvim'
" " Autocompletion framework for built-in LSP
" Plug 'nvim-lua/completion-nvim'

" call plug#end()

" (Optional) Multi-entry selection UI.
" Disabling fzf 2023-02-21 due to error mentioning prev_default_command
" Plug 'junegunn/fzf'
" (Optional) Multi-entry selection UI.
" Plug 'Shougo/denite.nvim'

" (Optional) Completion integration with deoplete.
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" (Optional) Completion integration with nvim-completion-manager.
" Archived
" Plug 'roxma/nvim-completion-manager'
" The repo recommends using ncm2/ncm2 instead
" Plug 'ncm2/ncm2'
" Plug 'roxma/nvim-yarp' " An ncm2 dependency
" Plug 'ncm2/ncm2-racer'

" (Optional) Showing function signature and inline doc.
" Plug 'Shougo/echodoc.vim'


" original repos on github
" Plug 'thoughtbot/Vim-Rspec'


Plug 'tpope/vim-fugitive'
" Addon to 'tpope/vim-fugitive' graphical features, but hasn't been updated
" to match changes in fugitive "
" Plug 'gregsexton/gitv'
" Addon to 'tpope/vim-fugitive' "
Plug 'tpope/vim-rhubarb'
Plug 'tveskag/nvim-blame-line', {'commit': 'b3d94f0ed5882d3d1c843c69788b9670476e1f42'}

Plug 'tpope/vim-surround'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-endwise'
" Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
" for storing vim sessions "
Plug 'tpope/vim-obsession'
" Plug 'tpope/vim-vividchalk'
" DB "
Plug 'tpope/vim-dadbod'

" tpope! "
Plug 'github/copilot.vim', {'branch': 'release'}

" coc "
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Gives `g=` and `g:`
" Seems super cool but we're not using it yet "
Plug 'tommcdo/vim-express', {'commit': '2cbe706b4940dd567596b892e2d6af829b096b4b'}

" Has to come before plasticboy/vim-markdown
Plug 'godlygeek/tabular', {'commit': '339091ac4dd1f17e225fe7d57b48aff55f99b23a'}
" Plug 'tpope/vim-markdown'
" Addon to tpope/vim-markdown "
" Plug 'jtratner/vim-flavored-markdown'
" Addon to tpope/vim-markdown "
" Plug 'rhysd/vim-gfm-syntax'
Plug 'plasticboy/vim-markdown', {'commit': 'cc82d88'}
" Specific branch to fix a build issue. Remove when that branch is merged upstream "
Plug 'iamcco/markdown-preview.nvim', { 'branch': 'dependabot/npm_and_yarn/next-12.1.0', 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

Plug 'tommcdo/vim-exchange', {'commit': '784d630'}

" Updates for Python 3 syntax changes "
Plug 'vim-python/python-syntax', {'commit': '2cc00ba72929ea5f9456a26782db57fb4cc56a65'}

Plug 'kana/vim-textobj-user', {'commit': '41a675ddbeefd6a93664a4dc52f302fe3086a933'}
" depends on kana/vim-textobj-user.git
Plug 'nelstrom/vim-textobj-rubyblock', {'commit': '2b882e2cc2599078f75e6e88cd268192bf7b27bf'}

Plug 'noprompt/vim-yardoc', {'commit': '88f110698e6742e74d3b4eda75b5830510e42d6d'}

Plug 'vito-c/jq.vim', {'commit': '6ff60efab7a15c60ff073c5bb7aec2858a0bafba'}

Plug 'cespare/vim-toml', {'commit': '897cb4eaa81a0366bc859effe14116660d4015cd'}
Plug 'rust-lang/rust.vim', {'commit': '889b9a7515db477f4cb6808bef1769e53493c578'}
" Used by rust-lang/rust.vim "
Plug 'mattn/webapi-vim', {'commit': '70c49ada7827d3545a65cbdab04c5c89a3a8464e'}
Plug 'mhinz/vim-crates', {'commit': 'f6f13113997495654a58f27d7169532c0d125214'}

" For the pest parser syntax "
Plug 'pest-parser/pest.vim', {'commit': 'ebeeea5e0757adee037135cf3b8248589b22ae16'}

" Plug 'racer-rust/vim-racer'

Plug 'vmchale/ion-vim', {'commit': 'cdb3cf709e39b366cf3f83c873130dca0e7d2854'}

" Plug 'evanmiller/nginx-vim-syntax'

Plug 'scrooloose/nerdtree', {'commit': 'fc85a6f07c2cd694be93496ffad75be126240068'}
Plug 'Xuyuanp/nerdtree-git-plugin', {'commit': 'e1fe727127a813095854a5b063c15e955a77eafb'}

Plug 'nvim-treesitter/nvim-treesitter', {'commit': 'fa0644667ea7ee7a72efdb69c471de4953a11019', 'do': ':TSUpdate'}
" Sticky headers "
Plug 'wellle/context.vim', {'commit': 'c06541451aa94957c1c07a9f8a7130ad97d83a65'}

Plug 'nathanaelkane/vim-indent-guides', {'commit': '9a106c73f64b16f898276ca87cd55326a2e5cf4c'}
Plug 't9md/vim-ruby-xmpfilter', {'commit': '8612796004396616c53f05fbf328bfc2fd62fbb2'}
Plug 'elixir-lang/vim-elixir', {'commit': '6dd03f87d825bf0a9f8611eb54076c7952d4f15c'}
Plug 'tpope/vim-salve'
Plug 'tpope/vim-fireplace'
Plug 'tpope/vim-classpath'
Plug 'guns/vim-clojure-static', {'commit': 'fae5710a0b79555fe3296145be4f85148266771a'}
" Plug 'kien/rainbow_parentheses.vim'
Plug 'luochen1990/rainbow', {'commit': '61f719aebe0dc5c3048330c50db72cfee1afdd34'}
" Plug 'junegunn/rainbow_parentheses.vim'
Plug 'guns/vim-clojure-highlight', {'commit': '9ac6cb8fef04b2c243377adb671324a60952aee0'}
Plug 'derekwyatt/vim-scala', {'commit': '7657218f14837395a4e6759f15289bad6febd1b4'}
Plug 'slim-template/vim-slim', {'commit': 'f0758ea1c585d53b9c239177a8b891d8bbbb6fbb'}
Plug 'hwartig/vim-seeing-is-believing', {'commit': '8ca3af76117401e18358a5fdb4f542082c920833'}
" Plug 'msteinert/vim-ragel'
"
Plug 'leafo/moonscript-vim', {'commit': '715c96c7c3b02adc507f84bf5754985460afc426'}
Plug 'vim-airline/vim-airline', {'commit': '038e3a6ca59f11b3bb6a94087c1792322d1a1d5c'}
" LiveScript "
Plug 'gkz/vim-ls', {'commit': '795568338ecdc5d8059db2eb84c7f0de3388bae3'}

Plug 'salpalvv/vim-gluon', {'commit': '07f9f69c6c8902c76c25f8c19d355ff9e279bb25'}

" if !executable('terraform-lsp')
" Plug 'hashivim/vim-terraform'
" endif
" Plug 'juliosueiras/vim-terraform-completion'

" Io "
" Plug 'andreimaxim/vim-io'

" Factor "
" Plug 'scooter-dangle/vim-factor'

" Elm
Plug 'lambdatoast/elm.vim', {'commit': '04df290781f8a8a9a800e568262e0f2a077f503e'}

" Idris "
Plug 'idris-hackers/idris-vim', {'commit': '091ed6b267749927777423160eeab520109dd9c1'}

" Fish! "
Plug 'dag/vim-fish', {'commit': '50b95cbbcd09c046121367d49039710e9dc9c15f'}
Plug 'kana/vim-vspec', {'commit': '4438b57f85ba25d67143fe2d0c95cfa958fb7b94'}

Plug 'typedclojure/vim-typedclojure', {'commit': 'a9ac01784606a2b9f69a1d4686225987f1e7024e'}

" Plug 'terryma/vim-multiple-cursors'
" The following is recommended in lieu of deprecated vim-multiple-cursors
Plug 'mg979/vim-visual-multi', {'commit': '724bd53adfbaf32e129b001658b45d4c5c29ca1a'}

Plug 'adimit/prolog.vim', {'commit': '9ce494aba8e9fb90fc5c987a1b87118d6e8192c9'}

" Plug 'ekalinin/Dockerfile.vim'

Plug 'LnL7/vim-nix', {'commit': '7d23e97d13c40fcc6d603b291fe9b6e5f92516ee'}

" Plug 'csv.vim'

" vim-scripts repos
" Plug 'rcodetools.vim'
" Plug 'Puppet-Syntax-Highlighting'
Plug 'vim-scripts/SyntaxRange', {'commit': '74894260c0d1c281b5141df492495aa9c43fd620'}
" Requirement for SyntaxRange "
Plug 'vim-scripts/ingo-library', {'commit': '558132e2221db3af26dc2f2c6756d092d48a459f'}

Plug 'Glench/Vim-Jinja2-Syntax', {'commit': '2c17843b074b06a835f88587e1023ceff7e2c7d1'}

" All 3 of these as a bundle "
" Might require Neovim nightly "
Plug 'nvim-lua/popup.nvim', {'commit': 'b7404d35d5d3548a82149238289fa71f7f6de4ac'}
Plug 'nvim-lua/plenary.nvim', {'commit': '253d34830709d690f013daf2853a9d21ad7accab'}
Plug 'nvim-telescope/telescope.nvim', {'commit': '6daf35c88c07dd4b220468968a742cda04889cd3'}

" Plug 'kchmck/vim-coffee-script'
Plug 'eparreno/vim-l9', {'commit': 'f4c9eb5c980c3e58bd3c837a0949f163c82006b9'}
" Am liking ctrlp such much better than FuzzyFinder
" Plug 'FuzzyFinder'
" Plug 'kien/ctrlp.vim' " Old version
Plug 'ctrlpvim/ctrlp.vim', {'commit': '8b4a9523632049b3b373de1233bef346073b8982'}
Plug 'wavded/vim-stylus', {'commit': '99031823d216c4433fb5c2661a33a43fbebaff61'}
" Plug 'Command-T' " CAREFUL! CAN CRASH VIM IF NOT SET UP PROPERLY
Plug 'easymotion/vim-easymotion', {'commit': 'b3cfab2a6302b3b39f53d9fd2cd997e1127d7878'}
" Plug 'Markdown' "
Plug 'vim-scripts/VimClojure', {'commit': '2a17c249571395a7f45523d38cac6a9326ecf8f1'}
" Plug 'Textile-for-VIM'
Plug 'timcharper/textile.vim', {'commit': '00541bdac375938ca013fdb39eab95a04e622bac'}
" Plug 'Mercury-compiler-support'
" Plug 'go.vim'
" Plug 'jnwhiteh/vim-golang'
" Plug 'Blackrush/vim-gocode'
Plug 'fatih/vim-go', {'commit': '23cc4bca2f586c8c2f7d2cb78bbbfec4b7361763'}
Plug 'jodosha/vim-godebug', {'commit': '8b751a3ea3b8adbbf87f391d794dfa1d42bc5d44'}
Plug 'godoctor/godoctor.vim', {'commit': '17973331d1ea88bad082fba406c1690f17943b52'}
" Plug 'Shougo/neosnippet.vim'
" Plug 'Valloric/YouCompleteMe'



" if has("lua")
"     Plug 'Shougo/neocomplete.vim'
" endif

" Plug 'scrooloose/syntastic'
Plug 'dense-analysis/ale', {'commit': 'e1a0781f9de7d90554ea572cd220d72f823be3dc'}
Plug 'majutsushi/tagbar', {'commit': 'af3ce7c3cec81f2852bdb0a0651d2485fcd01214'}
" Plug 'meain/vim-package-info', { 'do': 'npm install' }

" Plug 'vimsh'
" Plug 'slimv.vim'
Plug 'vim-ruby/vim-ruby', {'commit': 'd8ef4c3584d0403d26f69bfd0a8fc6bfe198aeee'}
" Plug 'ruby.vim'
" Temp disabled due to <Leader>r mapping
" Plug 'danchoi/ri.vim'
" Plug 'repmo.vim' " This one gets rid of my j and k mappings :(
Plug 'rhysd/vim-crystal', {'commit': 'dc21188ec8c2ee77bb81dffca02e1a29d87cfd9f'}

" Coq "
Plug 'vim-scripts/Coq-indent', {'commit': '643f189308ed6a979d5f72c05633881ada7ff4bd'}
Plug 'vim-scripts/coq-syntax', {'commit': 'e4c588c2df58c878f68427f229a7a00fa4211a16'}
Plug 'the-lambda-church/coquille', {'commit': 'df2460066686367b7949fe024c43ffd9d672f469'}
" Required by the-lambda-church/coquille
Plug 'let-def/vimbufsync', {'commit': '15de54fec24efa8a78f1ea8231fa53a9a969ce04'}

Plug 'hwayne/tla.vim', {'commit': '0d6d453a401542ce1db247c6fd139ac99b8a5add'}

Plug 'vim-scripts/rails.vim', {'commit': 'a390780c863f993847d23789b1dae86f779313d5'}
Plug 'vim-scripts/taglist.vim', {'commit': '53041fbc45398a9af631a20657e109707a455339'}
Plug 'vim-scripts/rake.vim', {'commit': '1bdc4fe273d524aecd693783fb9fb8cbdaab638b'}
Plug 'vim-scripts/tslime.vim', {'commit': '14330ce48a7b181293bb9d74df94cd51eb6fcb4b'}
Plug 'vim-scripts/bufexplorer.zip', {'commit': '08b0100f5242e1de07bce40dc6376a4996791c33'}
Plug 'vim-scripts/BufOnly.vim', {'commit': '43dd92303979bdb234a3cb2f5662847f7a3affe7'}
Plug 'vim-scripts/yaifa.vim', {'commit': 'ab87aa42cb7c51e9357c3ea05057a2d9d6cb3aea'}
Plug 'vim-scripts/ftpluginruby.vim', {'commit': '0eb1a5521e4d211182ee7e5c78f03898fa0c7d63'}
Plug 'vim-scripts/repeat.vim', {'commit': '80d23204c2e189c0c73f7fe77fd8e14a8d4bd428'}
Plug 'vim-scripts/ctags.vim', {'commit': 'a438a4f580c9445744c25941185c8cb8fb6b79b9'}
Plug 'vim-scripts/AutoTag', {'commit': 'ef0a37e8da77cd6c40d97a8e7a60c33ddc39d6ba'}

" Plug 'isRuslan/vim-es6'

" Snippet engine "
" if has("lua")
"     Plug 'SirVer/ultisnips'
" endif
" snippets for ultisnips engine "
" Plug 'honza/vim-snippets'

" snipmate (and dependences) "
" TODO: test removing these
Plug 'MarcWeber/vim-addon-mw-utils', {'commit': '6aaf4fee472db7cbec6d2c8eea69fdf3a8f8a75d'}
Plug 'tomtom/tlib_vim', {'commit': 'd3bdad7b5e4253dc7ce6793342d7b8755c67ff0c'}
" Plug 'garbas/vim-snipmate'
" optional for snipMate
" Plug 'honza/vim-snippets'
Plug 'vim-scripts/dbext.vim', {'commit': '14f3d530b6189dc3f97edfa70b7a36006e21148c'}
Plug 'vim-scripts/sqlcomplete.vim', {'commit': 'dfdbba6181cb83085ce166c6497f2af44cc5136d'}
" Plug 'exu/pgsql.vim'

Plug 'vim-scripts/php.vim', {'commit': '66a4486cc0d21c2b86cd4633931909efa06376bf'}
Plug 'vim-scripts/phpcomplete.vim', {'commit': '616e1301e8e9d40ffeebece06d502734b57d84a2'}
Plug 'vim-scripts/Lisper.vim', {'commit': '74bbe884e42a2fae3771f2023bd2af594af42970'}
" Plug 'vim-scripts/mercury.vim'
Plug 'vim-scripts/matchit.zip', {'commit': 'ced6c409c9beeb0b4142d21906606bd194411d1d'}
" Colorscheme bundles "
Plug 'vim-scripts/burnttoast256', {'commit': 'ffaaa13e8040a98fae398583205f1760d74c4e11'}
Plug 'vim-scripts/desert-warm-256', {'commit': 'aeb48b473715b708fc62690cbfe96022ca50a115'}
Plug 'vim-scripts/twilight256.vim', {'commit': '7080ae87fe1c4286e65d3de98c36bc4e2762c00c'}
Plug 'chriskempson/base16-vim', {'commit': '3be3cd82cd31acfcab9a41bad853d9c68d30478d'}
Plug 'chriskempson/vim-tomorrow-theme', {'commit': '46994f3a4d4574ce0d48c26a3bc1e528b8092c93'}
Plug 'vim-scripts/devbox-dark-256', {'commit': '1064873969b3b5e1a18f33e03a9663f87e1990f2'}
Plug 'vim-scripts/256-grayvim', {'commit': 'dd978fdbe8de45fb6264dcae1ed74d63273a152e'}
Plug 'vim-scripts/mrkn256.vim', {'commit': '82dd19d58d18012637d80bd09774681304f9b2da'}
Plug 'vim-scripts/summerfruit256.vim', {'commit': 'bc8c76de922bfa6941136e3a2454ae5c3b50bf07'}
Plug 'vim-scripts/charged-256.vim', {'commit': 'e4207db364acc8a45d7a3eeddde8f57728db429a'}
Plug 'vim-scripts/wombat256.vim', {'commit': '8734ba45dcf5e38c4d2686b35c94f9fcb30427e2'}
Plug 'vim-scripts/256-jungle', {'commit': 'a44de6342388da50b165acd7f4ebc1970a458a0a'}
Plug 'vim-scripts/beauty256', {'commit': '9e71770bb9fe4dd6e42a08ae2a61208708e3d3c7'}
Plug 'vim-scripts/Railscasts-Theme-GUIand256color', {'commit': 'f297c6771b1a2adf48bd278da1d5a6debed792cc'}
Plug 'vim-scripts/xoria256.vim', {'commit': 'ae38fd50b365052ed4ddbc79a006a45628d5786a'}
Plug 'vim-scripts/colorful256.vim', {'commit': 'ea8be4f48a729cb5907294c966884ef08305e3c2'}
Plug 'vim-scripts/OceanBlack256', {'commit': '3a7357c0f106d75c46a28440c4d20461fc8dd49d'}
Plug 'vim-scripts/calmar256-lightdark.vim', {'commit': '9e039e3c1e1898139da47924c3a0ece629057f7b'}
Plug 'morhetz/gruvbox', {'commit': 'bf2885a95efdad7bd5e4794dd0213917770d79b7'}
Plug 'mustache/vim-mustache-handlebars', {'commit': '0153fe03a919add2d6cf2d41b2d5b6e1188bc0e0'}
" Untested (downloaded on whim)
" Plug 'jsbeautify'
" Plug 'Superior-Haskell-Interaction-Mode-SHIM'
" Plug 'vim-erlang-skeleteons'
" Plug 'Erlang_detectVariable'
" Plug 'erlang-indent-file'
" Plug 'Erlang-plugin-package'
" Plug 'rubycomplete.vim'
" Plug 'vim-scripts/coffee-check.vim'
" Plug 'coffee-check.vim-B'
" Plug 'vim-scripts/coffee.vim'

Plug 'ziglang/zig.vim', {'commit': 'a0d9adedafeb1a33a0159d16ddcdf194b7cea881'}

" Plug 'zxqfl/tabnine-vim'

" non github repos
" Plug ''

" deprecated with nvim 0.5
" Plug 'mhartington/nvim-typescript'
Plug 'HerringtonDarkholme/yats.vim', {'commit': '4bf3879055847e675335f1c3050bd2dd11700c7e'}

Plug 'rking/ag.vim', {'commit': '4a0dd6e190f446e5a016b44fdaa2feafc582918e'}

Plug 'pelodelfuego/vim-swoop', {'commit': '99c9a7a40d34f89391fc0ac2a9f0260dd73a7d51'}

Plug 'unblevable/quick-scope', {'commit': 'a147fe0b180479249a6770eac332e2cd8f35b673'}

Plug 'dermusikman/sonicpi.vim', {'commit': 'f7690e4073ddd853eef38ae3a6a49b00dd2fe672'}
if !exists("g:sonicpi_enabled")
    let g:sonicpi_enabled = 0
endif

Plug 'neovim/nvim-lspconfig', {'commit': '63f4c0082f007d2356df4bc335f55e6d414da89c'}

call plug#end()         " required

" From
" https://github.com/hashicorp/terraform-ls/blob/main/docs/USAGE.md#neovim-v050
" lua <<EOF
"   require'lspconfig'.terraformls.setup{}
" EOF
" autocmd BufWritePre *.tf lua vim.lsp.buf.formatting_sync()

set termguicolors

let mapleader = ' '
let g:mapleader = ' '

set nojoinspaces

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

let g:swoopAutoInsertMode = 0

" Searching and things "
set incsearch
set hlsearch
nnoremap / /\v\c
vnoremap / /\v\c
nnoremap <Leader>/<ESC> :noh<CR>
" ag.vim "
nnoremap <Leader>// :Ag '/'<CR>
nnoremap <Leader>/<Leader> :Ag<SPACE>
nnoremap <Leader>/k :let @/ = "<C-R><C-W>"<CR>:Ag "\b<C-R><C-W>\b"<CR>:cw<CR>
" let g:ag_prg="ag --column --ignore log --ignore tags --ignore local.tags --ignore .min.js --ignore docs --ignore '*.dump' --ignore doc --smart-case --skip-vcs-ignores --silent"
" try ripgrep instead of silver searcher
let g:ag_prg="rg --column --vimgrep --smart-case"
" "
nnoremap <Leader>/s :%s///
vnoremap <Leader>/s :s///
nnoremap <Leader>/d :g///d
vnoremap <Leader>/d :///d
nnoremap <Leader>/n :g///normal
vnoremap <Leader>/n :///normal
" "

if has("nvim")
    nnoremap <Leader>FF :terminal fish<CR>
end

set shortmess=nIat
set rulerformat=%15(%c\ %l\ %p%%%)
set autoindent
set showcmd
set linebreak
set nrformats=hex,alpha
set nu
syntax on

" FIXME "
" Some commands from Casey "
set backup
set noswapfile
set undodir=~/.vim/tmp/undo/
set backupdir=~/.vim/tmp/backup/
set directory=~/.vim/tmp/swap

" Cursor cross-hairs "
" Note: this isn't great when using an E ink display Would be useful   "
" to be able to toggle it or make it conditional on, perhaps, an env   "
" var.                                                                  "
"augroup Cursorline
"    au!
"    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
"    au VimEnter,WinEnter,BufWinEnter * setlocal cursorcolumn
"    au WinLeave * setlocal nocursorline
"    au WinLeave * setlocal nocursorcolumn
"augroup END
" "
" END Some commands from Casey "

" tslime mapping "
" (<C-C><C-C> no longer works for some reason :(  ) "
nnoremap <Leader>rt vip"ry:call Send_to_Tmux(@r)<CR>
vnoremap <Leader>rt "ry:call Send_to_Tmux(@r)<CR>
" "

" Set interactive shell commands (allows aliases) "
" This also ends up making mappings that include shell
" commands force vim to run as a background process
" or something. Blerg.
" set shellcmdflag=-ic
" "

let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]

let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0

" Fewer warnings when switching changed buffers "
set hidden
" "

" Color scheme "
" colorscheme desert256
" colorscheme wombat256mod
" colorscheme twilight256
" colorscheme Tomorrow-Night-Bright
" colorscheme Tomorrow-Night
if $ALACRITTY_COLOR_SCHEME == 'light'
    colorscheme base16-grayscale-light
    " set background=light

    " Hacks for Gruvbox italics in Neovim. Should figure out correct way of
    " using these.
    highlight Italic4 ctermfg=208 guifg=#404040 gui=italic
    highlight Italic3 ctermfg=167 guifg=#303030 gui=italic
    highlight Italic2 ctermfg=108 guifg=#202020 gui=italic
    highlight Italic1 ctermfg=175 guifg=#101010 gui=italic
    " highlight GrayScaleRed ctermfg=167 guifg=#303030 gui=bold,undercurl
    highlight GrayScaleRed ctermfg=167 guifg=#303030 gui=bold guisp=undercurl
    " highlight Strikethrough gui=strikethrough
    highlight! link Keyword Italic3
    highlight! link Conditional Italic3
    highlight! link StorageClass Italic4
    " highlight! link Constant Italic1
    highlight! link PreProc Italic2
    highlight! link Error GrayScaleRed
    " highlight! link text.strike Strikethrough

else
    colorscheme gruvbox
    set background=dark

    " Hacks for Gruvbox italics in Neovim. Should figure out correct way of
    " using these.
    highlight GruvboxOrangeItalic ctermfg=208 guifg=#fe8019 gui=italic
    highlight GruvboxRedItalic ctermfg=167 guifg=#fb4934 gui=italic
    highlight GruvboxAquaItalic ctermfg=108 guifg=#8ec07c gui=italic
    highlight GruvboxPurpleItalic ctermfg=175 guifg=#d3869b gui=italic
    highlight! link Keyword GruvboxRedItalic
    highlight! link Conditional GruvboxRedItalic
    highlight! link StorageClass GruvboxOrangeItalic
    " highlight! link Constant GruvboxPurpleItalic
    highlight! link PreProc GruvboxAquaItalic
    highlight! link Error GruvBoxRed

    let g:gruvbox_contrast_dark = 'soft'
endif

" colorscheme delek
" colorscheme base16-tomorrow
" colorscheme summerfruit256
" colorscheme colorful256
" "

lua << HOWL
treesitter_captures = function()
    local result = vim.treesitter.get_captures_at_cursor(0)
    print(vim.inspect(result))
end
HOWL

nnoremap <Leader>S :call v:lua.treesitter_captures()<CR>

" Shorthand system "
source ~/.vim/abbrevlist-devel.vim
" "

" Totally awesome extension of    "
" the Q keystroke in input mode   "
" to enable lambda-like function- "
" ality. Was kindly provided by   "
" ZyX in the vim-use forum in     "
" response to my posting.         "
" source ~/.vim/Q-lambda-extension.vim
" "

" Additional mappings "
" Can just rely on vim digraphs for this.
" source ~/.vim/additionalMappings.vim
" "

" Test extending matchit for ruby "
" source ~/.vim/ruby-matchit-2.vim
" "

" Test minimap "
" source ~/.vim/1470884/.vimrc
" "

" Extra digraphs "
" ⊕ XOR
digraphs XO 8853
" "

" Show highlighting groups for current word "
source ~/.vim/syntaxHighlightInspect.vim
" "

" neocomplete "
" let g:neocomplete#enable_at_startup = 1
" nnoremap <Leader>tn :NeoCompleteToggle<CR>
" "

" Trying out w0rp/ale
""" syntastic options "
""let g:syntastic_mode_map = { 'mode': 'active',
""                           \ 'active_filetypes': ['ruby', 'php', 'clojure', 'erlang'],
""                           \ 'passive_filetypes': ['puppet', 'go'] }
""
""" Don't run syntastic if I'm exiting "
""nnoremap ZZ :autocmd! syntastic<CR>ZZ

" ale
"
" Removed the Rust one due to duplication with language server plugin
"            \   'rust': ['analyzer'],
let g:ale_linters = {
            \   '*': ['remove_trailing_lines', 'trim_whitespace'],
            \   'javascript': ['standard'],
            \   'ruby': ['standardrb'],
            \   'rust': [],
            \   'python': ['pipenv run flake8', 'pipenv run mypy', 'pipenv run yapf'],
            \   'terraform': [],
            \}
" Removed the Rust ones due to rust-analyzer
" let g:ale_rust_rls_config = {
"             \   'rust': {
"             \       'clippy_preference': 'on',
"             \   },
"             \}
" Removed the Rust ones due to rust-analyzer
let g:ale_fixers = {
            \'*': ['remove_trailing_lines', 'trim_whitespace'],
            \'javascript': ['standard'],
            \'rust': ['rustfmt'],
            \'python': ['yapf'],
            \'terraform': [],
            \}
let g:ale_fix_on_save = 1
let g:ale_virtualtext_cursor = 1
let g:ale_completion_enabled = 1

let g:ale_rust_rustfmt_options = '--edition=2021'
let g:ale_rust_rustfmt_toolchain = 'stable'
" let g:ale_rust_rls_toolchain = 'stable'

" if executable('terraform-lsp')
"     autocmd User lsp_setup call lsp#register_server({
"         \ 'name': 'tf',
"         \ 'cmd': {server_info->['terraform-lsp']},
"         \ 'whitelist': ['tf'],
"         \ })
" endif

nnoremap <silent> <Leader>en <Plug>(ale_next_wrap)
nnoremap <silent> <Leader>eN <Plug>(ale_previous_wrap)

" Some stuff from cupakromer's vimrc "
set wildmenu
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.class,.svn,vender/gems/*
set wildignorecase

" set list listchars=tab:¬·,trail:·
set list listchars=tab:¬·,trail:·,extends:→,precedes:←,conceal:✗,nbsp:┄
" set list listchars=tab:¬·,trail:·,extends:…,precedes:…,conceal:×,nbsp:┄
" "

" Language-specific auto-complete from syntax highlighting files "
filetype plugin indent on
if has("autocmd") && exists("+omnifunc")
    autocmd Filetype *
                \	if &omnifunc == "" |
                \		setlocal omnifunc=syntaxcomplete#Complete |
                \	endif
endif
" "

" Additional ruby auto-complete options "
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1
" "

" Set snipMate directory "
" let g:snippets_dir = '~/.vim/snippets'
" "

" Useful for when using snipMate and in general, I think. "
" Are there some languages where I shouldn't use this?    "
" (And don't just say pig-latin, you jerk.)               "
set expandtab
" "

" EasyMotion "
let g:EasyMotion_leader_key = '\'
" "

let mapleader = ' '
" Window navigation shortcuts "
nnoremap <Leader>- s
nnoremap <Leader>| v
" nnoremap <Leader>- -
" nnoremap <Leader>= +
nnoremap <Leader>_ _
" nnoremap <Leader>| |
nnoremap <Leader>+ =
nnoremap <Leader>j j
nnoremap <Leader>k k
nnoremap <Leader>l l
nnoremap <Leader>h h
" nnoremap <Leader>w w
nnoremap <Leader>c c
nnoremap <Leader>o o
nnoremap <Leader>> >
nnoremap <Leader>< <
" "

" Conflicts with <Leader>l above
let g:swoopUseDefaultKeyMap = 0

nnoremap <Leader>ml :call SwoopMulti()<CR>
" nnoremap <Leader>ml :call SwoopMultiSelection()<CR>

" Tab navigation shortcuts "
" nnoremap <Leader>t gt
" nnoremap <Leader>T gT
" "

" Toggle paste mode "
nnoremap <Leader>P :set paste!
" "

" Quick-toggle fold "
" Might not keep this one... "
nnoremap <Leader><Enter> za
" "

" Save-so-Much! "
nnoremap <Leader><Leader> :w<CR>
" "

" Buffer navigation shortcuts "
nnoremap <Leader>n  :bn<CR>
nnoremap <Leader>p  :bp<CR>
nnoremap <Leader>be :BufExplorer<CR>
nnoremap <Leader>bo :BufOnly<CR>
" Get rid of the current buffer without closing the window "
" (Dersn't work s'well) "
nnoremap <Leader>bd sj:bdj
" "

" NERDTree mapping "
nnoremap <Leader>N :NERDTreeToggle<CR>
nnoremap <Leader>M :NERDTreeFind<CR>
" "

" Taglist mapping "
nnoremap <Leader>tl :TlistToggle<CR>
let Tlist_Use_Right_Window=1
" "

" The first 2 of these are only useful when :set wrap is on. "
" pretty lousy when navigating code. Might want to put them  "
" in an ftplugin for txt or something.                       "
nnoremap k gk
nnoremap j gj
nnoremap <C-K>  <C-Y>
nnoremap <C-J>  <C-E>
nnoremap <C-H>  zh
nnoremap <C-L>  zl
nnoremap <UP>   <C-Y>k
nnoremap <DOWN> <C-E>j

" nnoremap <S-F5> :w<CR>:!texexec --xetex --purgeall "%"<CR>
" nnoremap <S-F6> :w<CR>:!texexec --pdf --purgeall "%"<CR>
" nnoremap <S-F7> :w<CR>:!texexec --lua "%"<CR>

" nnoremap <S-F12> :update<CR>:!python "%"<CR>

" CTAGS setup/mapping (for all programming languages... not just C)  "
" only needs to be run once per file if AutoTags plugin is installed "
" nnoremap <Leader>8 :let g:ctags_path='/usr/bin/ctags'<CR>
" nnoremap <Leader>9 :let g:ctags_args='-I __declspec+'<CR>
" nnoremap <Leader>0 :CTAGS<CR>
" "

" Execution of interpreted languages (with proper hash-bang markup) "
" nnoremap <Leader>E :w<CR>:!chmod 744 %<CR>
" nnoremap <Leader>e :w<CR>:!./%<CR>

" Recommended in help files for auto-complete "
" This first one screws up the escape key
" inoremap  
inoremap  
" inoremap  
inoremap  
" "

" vim-ruby-xmpfilter marks "
" Need to change to a better mapping and move to ruby.vim "
" imap <buffer> <C-M> <Plug>(xmpfilter-mark)
" imap <buffer> <C-O> <Plug>(xmpfilter-run)
" xmap <buffer> <C-M> <Plug>(xmpfilter-mark)
" xmap <buffer> <C-O> <Plug>(xmpfilter-run)
" nmap <buffer> <C-M> <Plug>(xmpfilter-mark)
" nmap <buffer> <C-O> <Plug>(xmpfilter-run)
" "

" start with regular line numbering and provide means "
" of toggling between relative and absolute from "
" TODO improve...currently is initially disabled
" jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/ "
" set number

" function! NumberToggle()
"     if(&relativenumber == 1)
"         set number
"     else
"         set relativenumber
"     endif
" endfunc

" au FocusLost * :set number<CR>
" au FocusGained * :set relativenumber<CR>
" nnoremap <Leader>a :call NumberToggle()<CR>
nnoremap <Leader>a :set relativenumber!<CR>
" "
set relativenumber

set lazyredraw

" Skinny indent guides "
" Plugin 'nathanaelkane/vim-indent-guides' "
let g:indent_guides_guide_size=1
" "

" Set linebreaks when wrap is turned on "
set linebreak
set list
set nowrap
" Toggle wrap "
nnoremap <Leader>A :set wrap!<CR>:set list!<CR>
" "

" Mac Copy "
" vnoremap <Leader>y :w !pbcopy<CR>
" nnoremap <Leader>yy vip:w !pbcopy<CR>

" Ubuntu Copy "
" Complicated version "
" vnoremap <Leader>y :w !xclip -in -selection clipboard<CR>:'<,'>w !tmux load-buffer -<CR>
" nnoremap <Leader>yy vip:w !xclip -in -selection clipboard<CR>:'<,'>w !tmux load-buffer -<CR>
" System clipboard register "
vnoremap <Leader>y "+y
nnoremap <Leader>yp "+yip
nnoremap <Leader>yy "+yy

" Fugitive "
nnoremap <Leader>gg :Git<CR>
nnoremap <Leader>gh :GBrowse<CR>
nnoremap <Leader>gH :GBrowse!<CR>
nnoremap <Leader>gb :Git blame<CR>
" nnoremap <Leader>gl :0Glog<CR>
nnoremap <Leader>gl :Gclog<CR>
vnoremap <Leader>gh :GBrowse<CR>
vnoremap <Leader>gH :GBrowse!<CR>
vnoremap <Leader>gb :Git blame<CR>
" vnoremap <Leader>gl :0Glog<CR>
vnoremap <Leader>gl :Gclog<CR>
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
" Keep vim status line on by default "
set laststatus=2
" "
nnoremap <Leader>gB :ToggleBlameLine<CR>

" rsi "
let g:rsi_no_meta = 1
" "

" quickfix navigation "
nnoremap <Leader>fn :cn<CR>
nnoremap <Leader>fp :cp<CR>
" "

" fast change vimrc "
nnoremap <Leader>vl :source ~/.vimrc<CR>
" edit vimrc "
nnoremap <Leader>ve :e ~/.vimrc<CR>
" close vimrc and return to file "

" TODO

" vim plugin
" --save vimrc
" --source vimrc
" --install new plugin
" --source vimrc
nnoremap <Leader>vp :w<CR>
" "

set diffopt=filler,vertical
" set diffopt=filler,iwhite,vertical

" From http://robots.thoughtbot.com/faster-grepping-in-vim
if executable('fd')
    let g:ctrlp_user_command = 'fd --color never --absolute-path "" %s'
    let g:ctrlp_use_caching = 0
elseif executable('ag')
" if executable('ag')
    " Use ag over grep
    " set grepprg=ag\ --nogroup\ --nocolor

    " Use ag in CtrlP for listing files. Lightning fast and respects
    " .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
endif
" "

" sonic pi "
if exists("g:sonicpi_enabled") && g:sonicpi_enabled == 1
    " vunmap <Leader>r
    vnoremap <Leader>rr :<Home>silent<End>w !sonic_pi<CR>
    " nunmap <Leader>se
    nnoremap <Leader>se vip:<Home>silent<End>w !sonic_pi<CR>
endif
" "

" FuzzyFinder "
" since replaced by ctrlp "
" nnoremap <Leader>ff :FufFile<CR>
" nnoremap <Leader>fb :FufBuffer<CR>
" nnoremap <Leader>fm :FufMruFile<CR>
" "

" Command to restore cursor position "
if has("autocmd")
	" Enable filetype detection
	filetype plugin indent on

	" Restore cursor position
	autocmd BufReadPost *
		\ if line("'\"") > 1 && line("'\"") <= line("$") |
		\   exe "normal! g`\"" |
		\ endif
endif
" "

" Show syntax highlighting groups for word under cursor "
" (from VimCasts)
nmap <Leader>sg :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
" "


" For vim-commentary "
autocmd FileType ruby set commentstring=#\ %s
" autocmd FileType vim  set commentstring=\"\ %s\ \" "
" "

" Ultisnips "
" warning...be careful of interactions with other plugins "
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" Ultisnips split window "
" let g:UltiSnipsEditSplit="vertical"

" For vim-flavored-markdown plugin "
" augroup markdown
"   au!
"   au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
" augroup END


" vim-markdown plugin is way too fold-happy
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_strikethrough = 1

let g:vim_markdown_preview_github = 1

" experimental italics & true color support
" let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
" let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
" Enable italics in gnome-terminal
" set t_ZH=[3m
" set t_ZR=[23m
highlight htmlItalic gui=italic
highlight htmlItalicBold gui=italic,bold
highlight htmlBoldItalic gui=italic,bold
highlight mkdStrike gui=strikethrough
" set termguicolors

""
" For prose formatting with par...helpful for re-flowing comments and markdown
" text.
"
" Note: In order for this to work, you'll need to both
"   1) install `par`
"   2) export PARINIT as 'rTbgqR B=.,?_A_a Q=_s>|' from your shell's
"   profile/init file.
vnoremap <Leader>= !par
nnoremap <Leader>== Vip!par
" TODO: Set up the above command to accept a motion.

" DB Ext

" let g:dbext_default_PGSQL_pgpass = expand('$HOME/.pgpass')
" let g:dbext_default_display_cmd_line = 1
let g:dbext_default_window_use_horiz = 0
let g:dbext_default_window_width = 160
" Profiles
" PostgreSQL
let g:dbext_default_profile_PGSQL_dev           = 'type=pgsql:dbname=distil_development:host=localhost:user=scott:passwd='
let g:dbext_default_profile_PGSQL_dev_reporting = 'type=pgsql:dbname=distil_reporting:host=localhost:user=scott:passwd='
let g:dbext_default_profile_PGSQL_dev_summary   = 'type=pgsql:dbname=distil_summary:host=localhost:user=scott:passwd='

if !exists("g:dbext_default_profile")
    let g:dbext_default_profile                 = 'PGSQL_dev'
endif

nnoremap <unique> <Leader>see <Plug>DBExecSQLUnderCursor
nnoremap <unique> <Leader>spp <Plug>DBPromptForBufferParameters

""
" TODO—tweak these settings so that only variables matching `:var_name`
" are recognized...by default dbext prompts for variable interpolation
" when query contains typecasting such as
"   SELECT 3::text;
"
" Some of the following settings totally remove recognition of
" colon-prefixed variables, but that's not ideal, since it's a nice
" syntax to use.
"
" autocmd BufRead */MyProjectDir/* DBSetOption variable_def_regex=\(\w\|'\)\@<!?\(\w\|'\)\@<!,\zs\(@\|:\a\|\$\)\w\+\>\|#{\(\w\|\[.\-\]\)\+}
" autocmd BufRead *.{pl,}sql DBSetOption variable_def_regex=\v(\w|')@<!\?(\w|')@<!,\v\zs\@\w+>,\v(:)@1<!:\w+>
autocmd BufRead *.{pl,}sql DBSetOption variable_def=?WQ,@wq,$wq
autocmd BufRead *.{pl,}sql DBSetOption variable_def_regex=\v(\w|')@<!\?(\w|')@<!,\v\zs\@\w+>
autocmd BufRead *.{ba,}sh DBSetOption variable_def_regex=\v(\w|')@<!\?(\w|')@<!,\v\zs\@\w+>,\v(:)@1<!:\w+>,\v\$\{\w+\}
autocmd BufRead *.{rake,rb} DBSetOption variable_def_regex=\v(\w|')@<!\?(\w|')@<!,\v\zs\@\w+>,\v#\{(\w|[.\-])+},\v(:)@1<!:\w+>
" autocmd BufRead *.{ba,}sh DBSetOption variable_def_regex=
" autocmd BufRead DBSetOption variable_def_regex=,#{\ \?\(\w\|\[.\-\]\)\+\ \?}
" DBSetOption variable_def_regex=,#{\ \?\(\w\|\[.\-\]\)\+\ \?}


" unblevable/quick-scope "
" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" Trigger a highlight only when pressing f and F.
" let g:qs_highlight_on_keys = ['f', 'F']

"   custom colors
" let g:qs_first_occurrence_highlight_color = '#afff5f' " gui vim
" let g:qs_first_occurrence_highlight_color = 155       " terminal vim

" let g:qs_second_occurrence_highlight_color = '#5fffff'  " gui vim
" let g:qs_second_occurrence_highlight_color = 81         " terminal vim


" It no work! :(
" AddTabularPattern comma_words /\v[^ ,)]+,/l1



autocmd BufReadPost *.rs setlocal filetype=rust

" lua << EOF
" local nvim_lsp = require('lspconfig')
"
" local on_attach = function(client)
"     require('completion').on_attach(client)
" end
"
" nvim_lsp.rust_analyzer.setup({
"     on_attach = on_attach,
"     settings = {
"         ["rust-analyzer"] = {
"             assist = {
"                 importMergeBehavior = "last",
"                 importPrefix = "by_self",
"             },
"             cargo = {
"                 loadOutDirsFromCheck = true,
"             },
"             procMacro = {
"                 enable = true,
"             },
"         },
"     },
" })
" EOF

" Language Server
"
"      \ 'rust': ['rustup', 'run', 'stable', 'rls'],
" \ 'rust': ['env', 'RA_LOG=info', 'rust-analyzer', '--log-file=/tmp/rust-analyzer.log'],
" \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
let g:LanguageClient_serverCommands = {
\ 'rust': ['rust-analyzer'],
\ 'python': ['/usr/local/bin/pyls'],
\ }
"\ 'asm': ['asm-lsp'],
"\ 'terraform': ['terraform-ls'],

lua <<EOF
require('nvim-treesitter.configs').setup {
  -- NOTE: `all` isn't actually recommended (although I'm not sure what an actual list should be.
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/2293#issuecomment-1094250553
  ensure_installed = "all", -- one of "all" or a list of languages
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
  },
}

-- Might be doing something, but it's not particular satisfactory.
-- require'lspconfig'.asm_lsp.setup{}
EOF

" Automatically start language servers.
let g:LanguageClient_autoStart = 1
function LC_maps()
    if has_key(g:LanguageClient_serverCommands, &filetype)
        set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()

        let g:LanguageClient_windowLogMessageLevel = "Info"
        let g:LanguageClient_loggingLevel = 'INFO'
        let g:LanguageClient_loggingFile = expand('/tmp/LanguageClient.log')
        let g:LanguageClient_serverStderr = expand('/tmp/LanguageServer.log')

        nnoremap <silent> <buffer> <Leader>/rr :call LanguageClient#textDocument_references()<CR>
        nnoremap <silent> <buffer> <Leader>ff :call LanguageClient#textDocument_codeAction()<CR>
        nnoremap <silent> <buffer> <Leader>fe :call LanguageClient#explainErrorAtPoint()<CR>

        nnoremap <silent> <buffer> <Return> :call LanguageClient#textDocument_documentHighlight()<CR>

        " Example bindings combining with tpope/vim-abolish:
        " Rename - rn => rename
        noremap <buffer> <leader>/rn :call LanguageClient#textDocument_rename()<CR>

        " Rename - rc => rename camelCase
        noremap <buffer> <leader>/rc :call LanguageClient#textDocument_rename(
                    \ {'newName': Abolish.camelcase(expand('<cword>'))})<CR>

        " Rename - rs => rename snake_case
        noremap <buffer> <leader>/rs :call LanguageClient#textDocument_rename(
                    \ {'newName': Abolish.snakecase(expand('<cword>'))})<CR>

        " Rename - ru => rename UPPERCASE
        noremap <buffer> <leader>/ru :call LanguageClient#textDocument_rename(
                    \ {'newName': Abolish.uppercase(expand('<cword>'))})<CR>
  endif
endfunction

autocmd FileType * call LC_maps()


" Terraform "
let g:terraform_align=1
let g:terraform_commentstring='//%s'

" fzf-powered spell-check
function! FzfSpellSink(word)
  exe 'normal! "_ciw'.a:word
endfunction
function! FzfSpell()
  let suggestions = spellsuggest(expand("<cword>"))
  return fzf#run({
              \   'source': suggestions,
              \   'sink': function("FzfSpellSink"),
              \   'down': 10
              \ })
endfunction
nnoremap z= :call FzfSpell()<CR>
autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us
autocmd FileType gitcommit setlocal spell spelllang=en_us

" Turns on updated vim-python/python-syntax highlighting "
let g:python_highlight_all=1

" let g:rainbow_conf = {
" \  'guifgs': [
" \    'RoyalBlue3',
" \    'SeaGreen3',
" \    'IndianRed3',
" \    'DarkGoldenrod3',
" \    'DarkOrchid3',
" \    'azure3',
" \    'firebrick3',
" \    'PaleGreen3',
" \    'DarkOrange3',
" \    ],
" \  'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
" \  'operators': '_,_',
" \  'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold', 'start=/</ end=/>/ fold'],
" \  'separately': {
" \    '*': {},
" \    'tex': {
" \      'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
" \    },
" \    'lisp': {
" \      'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
" \    },
" \    'vim': {
" \      'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
" \    },
" \    'html': {
" \      'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
" \    },
" \    'css': 0,
" \  }
" \}
" let g:rainbow_active = 1

if has('nvim')
    autocmd BufRead Cargo.toml call crates#toggle()
endif

" Not exactly working yet
" let b:airline_rust_bread_crumbs = 0
" function! RustBreadCrumbs()
"     if b:airline_rust_bread_crumbs == 1
"         return luaeval("require('nvim-treesitter').statusline({ type_patterns = { 'impl', 'function' } })")
"     else
"         return ""
"     endif
" endfunction
" call airline#parts#define('breadcrumbs', {'function': 'RustBreadCrumbs', 'accents': 'bold'})
" let g:airline_section_c .= airline#section#create(['breadcrumbs'])

" Not sure if copilot is working anymore for my things.
" Does it work at all on subsequent editor sessions? It
" doesn't seem to.

" Maybe now it will work? Nope. It's still peacing out and not suggesting.
" It has a split pain for synthesizing 'solutions', but it's not doing
" anything.
" After saving, it still just sits there.
"
" I'm not sure that it actually works.
" Maybe it does now?
" I think maybe coc is disabling copilot somehow?

" Sticky headers (nice but they interact poorly with Language Server popups)
nnoremap <Leader>H :ContextToggle<CR>
