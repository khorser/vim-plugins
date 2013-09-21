let g:plugins = ['csv.vim', 'ghcmod-vim', 'neco-ghc',
\ 'neocomplcache.vim', 'neocomplete.vim', 'NrrwRgn',
\ 'patchreview-vim', 'quickfixsigns_vim', 'tagbar',
\ 'undotree', 'vcscommand', 'vim2hs', 'vim-mark-tools',
\ 'vim-northsky', 'vimproc', 'vim-repl', 'vim-rst-ftplugin', 'vimtodo']

function! StripFirstDir(fname)
  let res = []
  let n = a:fname
  let nn = fnamemodify(n, ':h')
  while fnamemodify(nn, ':h') != nn
    call insert(res, fnamemodify(n, ':t'))
    let n = nn
    let nn = fnamemodify(n, ':h')
  endwhile
  return res
endfunction

function! List()
  let f = {}
  for plugin in g:plugins
    let f[plugin] = map(filter(glob(plugin.'/**', 0, 1), '!isdirectory(v:val)'), 'StripFirstDir(v:val)')
  endfor
  return f
endfunction

" vim: set ft=vim sw=2 sts=2 ts=8 et:
