function! SplitPath(fname)
  if isdirectory(a:fname) " skip directories
    return []
  endif
  let components = [] " components of the file name
  let n = a:fname
  let nup = fnamemodify(n, ':h')
  while fnamemodify(nup, ':h') != nup
    call insert(components, fnamemodify(n, ':t'))
    let n = nup
    let nup = fnamemodify(n, ':h')
  endwhile
  " skip top level files or unneeded entries
  if len(components) == 1 || index(['test', 'screenshots', 'UltiSnips', 'vest', 't', 'misc'], components[0]) != -1
    return []
  endif
  return components
endfunction


function! BuildPluginDir(root, plugins)
  let plugfiles = {}
  let allfiles = {}
  let alldirs = {}
  for p in a:plugins
    let paths = filter(map(glob(p.'/**', 0, 1), 'SplitPath(v:val)'), '!empty(v:val)')
    for pa in paths
      let alldirs[join(pa[:-2], '/')] = 1
    endfor
    let plugfiles[p] = map(copy(paths), "join(v:val, '/')")
    for f in plugfiles[p]
      if exists('allfiles["'.f.'"]')
        call add(allfiles[f], p)
      else
        let allfiles[f] = [p]
      endif
    endfor
  endfor
  unlet f
  unlet p
  let conflicts = filter(copy(allfiles), 'len(v:val) > 1')
  if !empty(conflicts)
    echoerr "Conflicting entries found:" string(conflicts)
  else
    for d in keys(alldirs)
      let dd = a:root.'/'.d
      if !isdirectory(dd)
        call mkdir(dd, 'p')
      endif
    endfor
    unlet d
    for [f, p] in items(allfiles)
      call writefile(readfile(p[0].'/'.f), a:root.'/'.f)
    endfor
    unlet f
    unlet p
    let del = []
    for [p, fs] in items(plugfiles)
      call add(del, '" '.p)
      call extend(del, map(copy(fs), '"call delete(\"".v:val."\")"'))
    endfor
    call writefile(del, a:root.'-uninstall.vim')
  endif
endfunction


let g:plugins = {'Lazy' : ['undotree', 'vcscommand']
  \, 'Own' : ['vim-mark-tools', 'vim-northsky', 'vim-repl', 'vim-rst-ftplugin']
  \, 'Haskell' : ['ghcmod-vim', 'neco-ghc', 'neocomplete.vim', 'vim2hs', 'vimproc']
  \, 'Utils' : ['csv.vim', 'NrrwRgn', 'patchreview-vim', 'quickfixsigns_vim', 'tagbar', 'vimtodo']}


function! BuildPlugins()
  for [dir, plist] in items(g:plugins)
    call BuildPluginDir(strftime('%Y%m%d%H%M%S').'/'.dir, plist)
  endfor
endfunction

" vim: set ft=vim sw=2 sts=2 ts=8 et:
