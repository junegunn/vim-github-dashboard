if exists("b:current_syntax")
  finish
endif
let s:cpo_save = &cpo
set cpo&vim

syntax clear
syntax region githubTitle start=/^ \{0,2}[0-9]/ end="\n" oneline contains=githubNumber,Keyword,githubRepo,githubUser,githubTime,githubRef,githubCommit,githubTag,githubBranch,githubGist,githubRelease
syntax match githubNumber /^ \{0,2}[0-9]\{-1,})/ contained
syntax match githubTime   /(.\{-1,})$/ contained
syntax match githubSHA    /^\s\+\[[0-9a-fA-F]\{4,}\]/
syntax match githubEdit   /\(^\s\+Edited \)\@<=\[.\{-}\]/
syntax match githubUser   /\[[^/\]]\{-1,}\]/ contained
syntax match githubRepo   /\[[^/\]]\{-1,}\/[^/\]@]\{-1,}\]/ contained
syntax match githubCommit /\[[^/\]]\{-1,}\/[^/\]@]\{-1,}@[0-9a-fA-Z]\{-1,}\]/ contained
syntax match githubTag    /\(tag \)\@<=\[.\{-1,}\]/ contained
syntax match githubBranch /\(branch \)\@<=\[.\{-1,}\]/ contained
syntax match githubBranch /\(pushed to \)\@<=\[.\{-1,}\]/ contained
syntax match githubGist   /\(a gist \)\@<=\[.\{-1,}\]/ contained
syntax match githubRelease /\(released \)\@<=\[.\{-1,}\]/ contained

syntax region githubFoldBlock start=/\%(\_^ \{4,}.*\n\)\{5}/ms=s+1 end=/\%(^ \{,4}\S\)\@=/ contains=githubFoldBlockLine2
syntax region githubFoldBlockLine2 start=/^ \{4,}/ms=e+1 end=/\%(^ \{,4}\S\)\@=/ contained contains=githubFoldBlockLine3 keepend
syntax region githubFoldBlockLine3 start=/^ \{4,}/ms=e+1 end=/\%(^ \{,4}\S\)\@=/ contained contains=githubFoldBlockLine4 keepend
syntax region githubFoldBlockLine4 start=/^ \{4,}/ms=e+1 end=/\%(^ \{,4}\S\)\@=/ contained contains=githubFoldBlockLine5 keepend
syntax region githubFoldBlockLine5 start=/^ \{4,}/ms=e+1 end=/\%(^ \{,4}\S\)\@=/ contained keepend fold

hi def link githubNumber  Number
hi def link githubUser    String
hi def link githubRepo    Identifier
hi def link githubRef     Special
hi def link githubRelease Label
hi def link githubTag     Label
hi def link githubBranch  Label
hi def link githubEdit    Constant
hi def link githubTime    Comment
hi def link githubSHA     Float
hi def link githubCommit  Special
hi def link githubGist    Identifier
execute 'syntax match githubKeyword /'.g:_github_dashboard_more_line.'/'
syntax match githubKeyword /^Loading.*/
syntax match githubKeyword /^Reloading.*/
syntax match githubFailure /^Failed.*/
hi def link githubKeyword Conditional
hi def link githubFailure Exception

let b:current_syntax = "github-dashboard"

let &cpo = s:cpo_save
unlet s:cpo_save
