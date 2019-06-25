" ファイルを上書きする前にバックアップを作ることを無効化
set nowritebackup
" ファイルを上書きする前にバックアップを作ることを無効化
set nobackup
" vim の矩形選択で文字が無くても右へ進める
set virtualedit=block
" 全角文字専用の設定
set ambiwidth=double
" wildmenuオプションを有効(vimバーからファイルを選択できる)
set wildmenu

"----------------------------------------
" 検索
"----------------------------------------
" 検索がファイル末尾まで進んだら、ファイル先頭から再び検索
set wrapscan
" 検索結果をハイライト表示
set hlsearch

"----------------------------------------
" 表示設定
"----------------------------------------
" エラーメッセージの表示時にビープを鳴らさない
set noerrorbells
" 対応する括弧やブレースを表示
set showmatch matchtime=1
" 入力モードでTabキー押下時に半角スペースを挿入
set expandtab
" インデント幅
set shiftwidth=2
" タブキー押下時に挿入される文字幅を指定
set softtabstop=2
" ファイル内にあるタブ文字の表示幅
set tabstop=2
" yでコピーした時にクリップボードに入る
set guioptions+=a
" 対応する括弧を強調表示
set showmatch
" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent
" タイトルを表示
set title
" 行番号表示
set number
" ヤンクでクリップボードにコピー
set clipboard=unnamed,autoselect
" シンタックスハイライト
syntax on

