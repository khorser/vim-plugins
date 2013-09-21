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


function! BuildPluginDir(dir, plugins)
  let plugfiles = {}
  let allfiles = {}
  let alldirs = {}
  for plugin in a:plugins
    let plugfiles[plugin] = filter(map(glob(plugin.'/**', 0, 1), 'SplitPath(v:val)'), '!empty(v:val)')
    for f in plugfiles[plugin]
      let path = join(f, '/')
      if exists('allfiles["'.path.'"]')
        call add(allfiles[path], plugin)
      else
        let allfiles[path] = [plugin]
      endif
      let dir = join(f[:-2], '/')
      let alldirs[dir] = 1
    endfor
  endfor
  let conflicts = filter(copy(allfiles), 'len(v:val) > 1')
  if !empty(conflicts)
    echoerr "Conflicting entries found:" string(conflicts)
  else
    let dir = strftime(a:dir)
    for d in keys(alldirs)
      let dd = dir.'/'.d
      if !isdirectory(dd)
        call mkdir(dd, 'p')
      endif
    endfor
    for [plugin, files] in items(plugfiles)
      for f in files
        let name = join(f, '/')
        call writefile(readfile(plugin.'/'.name), dir.'/'.name)
      endfor
    endfor
  endif
endfunction

function! BuildPlugins()
  call BuildPluginDir('Plugins%Y%m%d%H%M%S', ['csv.vim', 'ghcmod-vim', 'neco-ghc',
    \ 'neocomplete.vim', 'NrrwRgn', 'patchreview-vim', 'quickfixsigns_vim',
    \ 'tagbar', 'vim2hs', 'vimproc', 'vimtodo',
    \ 'vim-mark-tools', 'vim-northsky', 'vim-repl', 'vim-rst-ftplugin'])
endfunction


function! BuildLazyPlugins()
  call BuildPluginDir('LazyPlugins%Y%m%d%H%M%S', ['undotree', 'vcscommand'])
endfunction

" vim: set ft=vim sw=2 sts=2 ts=8 et:
