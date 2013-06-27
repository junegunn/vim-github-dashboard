" Copyright (c) 2013 Junegunn Choi
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if exists("g:loaded_github_dashboard")
  finish
endif
let g:loaded_github_dashboard = 1

let s:github_username = ''
let s:github_password = ''
let s:more_line       = '   -- MORE --'
let s:not_loaded      = ''

let s:is_mac =
  \ has('mac') ||
  \ has('macunix') ||
  \ executable('uname') &&
  \ index(['Darwin', 'Mac'], substitute(system('uname'), '\n', '', '')) != -1
let s:is_win = has('win32') || has('win64')

if s:is_mac
  let s:emoji_map = {
  \ 'CommitCommentEvent':            '💬',
  \ 'CreateEvent':                   '✨',
  \ 'DeleteEvent':                   '❌',
  \ 'DownloadEvent':                 '📎',
  \ 'FollowEvent':                   '💚',
  \ 'ForkEvent':                     '🍴',
  \ 'ForkApplyEvent':                '🍴',
  \ 'GistEvent':                     '📝',
  \ 'GollumEvent':                   '📝',
  \ 'IssueCommentEvent':             '💬',
  \ 'IssuesEvent':                   '❗',
  \ 'MemberEvent':                   '👥',
  \ 'PublicEvent':                   '🎉',
  \ 'PullRequestEvent':              '👼',
  \ 'PullRequestReviewCommentEvent': '💬',
  \ 'PushEvent':                     '🍡',
  \ 'TeamAddEvent':                  '👥',
  \ 'WatchEvent':                    '⭐'
  \ }
endif

let s:original_statusline = &statusline

function! s:option(key, default)
  return get(get(g:, 'github_dashboard', {}), a:key, a:default)
endfunction

function! s:option_defined(key)
  return has_key(get(g:, 'github_dashboard', {}), a:key)
endfunction

function! s:init_tab(...)
  let b:github_index = 0
  let b:github_error = 0
  let b:github_links = {}
  let b:github_emoji = s:is_mac && ((!has('gui_running') && s:option('emoji', 2) != 0) || s:option('emoji', 2) == 1)
  let b:github_indent = repeat(' ', b:github_emoji ? 11 : 8)

  if a:0 == 2
    let [what, type] = a:000
    let elems = len(filter(split(what, '/', 1), '!empty(v:val)'))
    if elems == 0 || elems > 2 | echoerr "Invalid username or repository" | return 0 | endif
    let path = elems == 1 ? '/users/' : '/repos/'
    let b:github_init_url = "https://api.github.com" .path.what. "/" .type
    if type == 'received_events'
      if elems > 1 | echoerr "Use :GHActivity command instead" | return 0 | endif
      let b:github_statusline = '[GitHub Dashboard: '.what.']'
    elseif type == 'events'
      let b:github_statusline = '[GitHub Activity: '.what.']'
    else
      echoerr "Invalid type"
      return 0
    endif
  endif
  let b:github_more_url = b:github_init_url

  setlocal statusline=%!github_dashboard#statusline()

  syntax clear
  syntax region githubTitle start=/^ \{0,2}[0-9]/ end="\n" oneline contains=githubNumber,Keyword,githubRepo,githubUser,githubTime,githubRef,githubCommit,githubTag,githubBranch
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
  hi def link githubNumber  Number
  hi def link githubUser    String
  hi def link githubRepo    Identifier
  hi def link githubRef     Special
  hi def link githubTag     Label
  hi def link githubBranch  Label
  hi def link githubEdit    Constant
  hi def link githubTime    Comment
  hi def link githubSHA     Float
  hi def link githubCommit  Special
  execute 'syntax match githubKeyword /'.s:more_line.'/'
  syntax match githubKeyword /^Loading.*/
  syntax match githubKeyword /^Reloading.*/
  syntax match githubFailure /^Failed.*/
  hi def link githubKeyword Conditional
  hi def link githubFailure Exception

  return 1
endfunction

function! s:refresh()
  call s:init_tab()
  setlocal modifiable
  normal! ggdG
  setlocal nomodifiable

  call s:call_ruby('Reloading GitHub event stream ...')
  if b:github_error
    call setline(line('$'), 'Failed to load events. Press R to reload.')
    setlocal nomodifiable
    return
  endif
endfunction

function! s:open(what, type)
  " Assign buffer name
  let bufname = '['.a:what.']'
  let bufidx = 2
  while bufexists(bufname)
    let bufname = '['.a:what.']('. bufidx .')'
    let bufidx = bufidx + 1
  endwhile

  tabnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap nonu cursorline foldmethod=manual
  setf github-dashboard
  silent! execute "f ".fnameescape(bufname)

  return s:init_tab(a:what, a:type)
endfunction

function! s:call_ruby(msg)
  if !empty(s:not_loaded)
    echoerr s:not_loaded
    return
  endif

  setlocal modifiable
  call setline(line('$'), a:msg)
  redraw!
  ruby GitHubDashboard.more
  if !b:github_error
    setlocal nomodifiable
  end
endfunction

function! s:emoji(type)
  if b:github_emoji
    let prefix = get(s:emoji_map, a:type, '')
    return empty(prefix) ? '   ' : prefix . '  '
  else
    return ''
  endif
endfunction

function! github_dashboard#open(auth, type, ...)
  if !empty(s:not_loaded)
    echoerr s:not_loaded
    return
  endif

  let username = s:option('username', s:github_username)
  if a:auth
    if empty(username)
      call inputsave()
      let username = input('Enter GitHub username: ')
      call inputrestore()
      if empty(username) | echo "Empty username" | return | endif
    endif

    let password = s:option('password', s:github_password)
    if empty(password)
      call inputsave()
      let password = inputsecret('Enter GitHub password: ')
      call inputrestore()
      if empty(password) | echo "Empty password" | return | endif
    endif
  else
    let password = ''
  endif

  let who = a:0 == 0 ? username : a:1
  if empty(who) | echo "Username not given" | return | endif

  if !s:open(who, a:type)
    bd
    return
  endif

  if a:auth
    let s:github_username = username
    let s:github_password = password
  endif

  call s:call_ruby('Loading GitHub event stream ...')
  if b:github_error
    bd
    return
  endif

  nnoremap <silent> <buffer> q             :q<cr>
  nnoremap <silent> <buffer> R             :call <SID>refresh()<cr>
  nnoremap <silent> <buffer> <cr>          :call <SID>action()<cr>
  nnoremap <silent> <buffer> <2-LeftMouse> :call <SID>action()<cr>
  nnoremap <silent> <buffer> <tab>         :silent! call <SID>tab('')<cr>
  nnoremap <silent> <buffer> <S-tab>       :silent! call <SID>tab('b')<cr>
endfunction

function! s:find_url()
  let line = getline(line('.'))
  let nth   = 0
  let start = 0
  let col   = col('.') - 1
  while 1
    let idx = match(line, '\[.\{-}\]', start)
    if idx == -1 || idx > col | return | endif

    let eidx = match(line, '\[.\{-}\zs\]', start)
    if col >= idx && col <= eidx
      return b:github_links[line('.')][nth]
    endif

    let start = eidx + 1
    let nth   = nth + 1
  endwhile
  return ''
endfunction

function! s:open_url(url)
  let cmd = s:option('open_command', '')
  if empty(cmd)
    if s:is_mac
      let cmd = 'open'
    elseif s:is_win
      let cmd = 'start rundll32 url.dll,FileProtocolHandler'
    elseif executable('xdg-open')
      let cmd = 'xdg-open'
    else
      echo "Cannot determine command to open: ". a:url
      return
    endif
  endif
  if s:is_win
    execute ':!' . cmd . ' ' . shellescape(a:url)
  else
    call system(cmd . ' ' . shellescape(a:url))
  endif
endfunction

function! github_dashboard#statusline()
  if exists('b:github_statusline')
    let url = s:find_url()
    if empty(url)
      return b:github_statusline
    else
      return b:github_statusline .' '. url
    endif
  else
    return s:original_statusline
endfunction

function! s:action()
  let line = getline(line('.'))
  if line == s:more_line
    call s:call_ruby('Loading ...')
    if b:github_error
      call setline(line('$'), s:more_line)
      setlocal nomodifiable
    endif
    return
  endif

  let url = s:find_url()
  if !empty(url)
    call s:open_url(url)
  endif
endfunction

function! s:tab(flags)
  call search(
             \ '\(^ *-- \zsMORE\)\|' .
             \ '\(^ *\[\zs[0-9a-fA-F]\{4,}\]\)\|' .
             \ '\(^ *Edited \[\zs\)\|' .
             \ '\(\(^ \{0,2}[0-9].\{-}\)\@<=\[\zs\)', a:flags)
endfunction

" {{{
ruby << EOF
require 'rubygems' rescue nil # 1.9.1
begin
  require 'json/pure'
rescue LoadError
  begin
    require 'json'
  rescue LoadError
    VIM::command("let s:not_loaded = 'JSON gem is not installed. try: sudo gem install json_pure'")
  end
end
require 'net/http'
require 'net/https'
require 'open-uri'
require 'time'

module GitHubDashboard
  class << self
    def fetch uri, username, password
      tried = false
      begin
        req = Net::HTTP::Get.new(uri.request_uri, 'User-Agent' => 'vim')
        req.basic_auth username, password unless password.empty?

        http = Net::HTTP.new('api.github.com', uri.port)
        http.use_ssl = true
        http.ca_file = ENV['SSL_CERT_FILE'] if ENV['SSL_CERT_FILE']
        http.open_timeout = VIM::evaluate("s:option('api_open_timeout', 10)").to_i
        http.read_timeout = VIM::evaluate("s:option('api_read_timeout', 20)").to_i

        http.request req
      rescue OpenSSL::SSL::SSLError
        unless tried
          # https://gist.github.com/pweldon/767249
          tried = true
          tempname = VIM::evaluate('tempname()')
          File.open(tempname, 'w') { |f| f << Net::HTTP.get('curl.haxx.se', '/ca/cacert.pem') }
          ENV['SSL_CERT_FILE'] = tempname
          retry
        end
        raise
      end
    end

    def more
      overbose = $VERBOSE
      $VERBOSE = nil
      username = VIM::evaluate("s:github_username")
      password = VIM::evaluate("s:github_password")
      uri      = URI(VIM::evaluate("b:github_more_url"))

      res = fetch uri, username, password
      if res.code !~ /^2/
        if %w[401 403].include? res.code
          # Invalidate credentials
          VIM::command(%[let s:github_username = ''])
          VIM::command(%[let s:github_password = ''])
        end
        error "#{JSON.parse(res.body)['message']} (#{res.code})"
        return
      end

      # Doesn't work on 1.8.7
      # more = res.header['Link'].scan(/(?<=<).*?(?=>; rel=\"next)/)[0]
      more = res.header['Link'].scan(/<.*?; rel=\"next/)[0]
      more = more && more.split('>; rel')[0][1..-1]

      VIM::command(%[normal! Gd$])
      if more
        VIM::command(%[let b:github_more_url = '#{more}'])
      else
        VIM::command(%[unlet b:github_more_url])
      end

      bfr  = VIM::Buffer.current
      JSON.parse(res.body).each do |event|
        VIM::command('let b:github_index = b:github_index + 1')
        index = VIM::evaluate('b:github_index')
        lines = process(event, index)
        lines.each_with_index do |line, idx|
          line, *links = line

          if idx == 0
            line = VIM::evaluate(%[s:emoji('#{event['type']}')]) + line
            bfr.append bfr.count - 1,
              "#{index.to_s.rjust(3)}) #{line} (#{format_time event['created_at']})"
          else
            bfr.append bfr.count - 1, VIM::evaluate('b:github_indent') + line
          end
          VIM::command(%[let b:github_links[#{bfr.count - 1}] = [#{links.map { |e| vstr e }.join(', ')}]])
        end

        if lines.length > 6
          VIM::command("normal! #{bfr.count - 1}Gzf#{lines.length - 6}k``")
        end
      end
      bfr[bfr.count] = VIM::evaluate('s:more_line') if more
      VIM::command(%[normal! ^zz])
    rescue Exception => e
      error e
    ensure
      $VERBOSE = overbose
    end

  private
    def process event, idx
      who    = event['actor']['login']
      type   = event['type']
      data   = event['payload']
      where  = event['url']
      action = data['action']
      repo   = event['repo'] && event['repo']['name']

      who_url  = "https://github.com/#{who}"
      repo_url = "https://github.com/#{repo}"

      case type
      when 'CommitCommentEvent'
        [[ "[#{who}] commented on commit [#{repo}@#{data['comment']['commit_id'][0, 10]}]",
            who_url, data['comment']['html_url'] ]] +
        wrap(data['comment']['body']).map { |e| [e] }
      when 'CreateEvent'
        if data['ref']
          ref_url = repo_url + "/tree/#{data['ref'].split('/').last}"
          [["[#{who}] created #{data['ref_type']} [#{data['ref']}] at [#{repo}]", who_url, ref_url, repo_url]]
        else
          [["[#{who}] created #{data['ref_type']} [#{repo}]", who_url, repo_url]]
        end
      when 'DeleteEvent'
        [["[#{who}] deleted #{data['ref_type']} #{data['ref']} at [#{repo}]", who_url, repo_url]]
      when 'DownloadEvent'
        # TODO
        [["#{type} from [#{who}]"], who_url]
      when 'FollowEvent'
        whom = data['target']['login']
        [["[#{who}] started following [#{whom}]", who_url, "https://github.com/#{whom}"]]
      when 'ForkEvent'
        [["[#{who}] forked [#{repo}] to [#{data['forkee']['full_name']}]",
            who_url, repo_url, data['forkee']['html_url']]]
      when 'ForkApplyEvent'
        # TODO
        [["#{type} from [#{who}]"], who_url]
      when 'GistEvent'
        [["[#{who}] created a gist [#{data['gist']['url']}]", data['gist']['url']]]
      when 'GollumEvent'
        [["[#{who}] edited the [#{repo}]", who_url, repo_url]] +
        data['pages'].map { |page|
          ["Edited [#{page['title']}]", page['html_url']]
        }
      when 'IssueCommentEvent'
        [["[#{who}] commented on issue [#{repo}##{data['issue']['number']}]", who_url, data['issue']['html_url']]] +
        wrap(data['comment']['body']).map { |line| [line] }
      when 'IssuesEvent'
        [
         ["[#{who}] #{action} issue [#{repo}##{data['issue']['number']}]", who_url, data['issue']['html_url']],
         [data['issue']['title']]
        ]
      when 'MemberEvent'
        [["[#{who}] #{action} [#{data['member']['login']}] to [#{repo}]", who_url, data['member']['html_url'], repo_url]]
      when 'PublicEvent'
        [["[#{who}] open-sourced [#{repo}]", who_url, repo_url]]
      when 'PullRequestEvent'
        [["[#{who}] #{action} pull request [#{repo}##{data['number']}]", who_url, data['pull_request']['html_url']]]
      when 'PullRequestReviewCommentEvent'
        prnum = data['comment']['pull_request_url'].scan(/[0-9]+$/).first
        [["[#{who}] commented on pull request [#{repo}##{prnum}]", who_url, data['comment']['html_url']]] +
        wrap(data['comment']['body']).map { |e| [e] }
      when 'PushEvent'
        branch = data['ref'].split('/').last
        ref_url = repo_url + "/tree/#{branch}"
        [["[#{who}] pushed to [#{branch}] at [#{repo}]", who_url, ref_url, repo_url]] +
        data['commits'].map { |commit|
          title = commit['message'].lines.first.chomp
          ["[#{commit['sha'][0, 7]}] #{title}", repo_url + '/commit/' + commit['sha']]
        }
      when 'TeamAddEvent'
        # TODO
        [["#{type} from [#{who}]"], who_url]
      when 'WatchEvent'
        [["[#{who}] #{action} watching [#{repo}]", who_url, repo_url]]
      else
        [["#{type} from [#{who}]"], who_url]
      end
    end

    def resolve_ssl
    end

    def wrap str
      tw = VIM::evaluate("&textwidth").to_i
      if tw == 0
        tw = 70
      else
        tw = [tw - 10, 1].max
      end

      str.gsub(/(.{1,#{tw}})(\s+|$)/, "\\1\n").lines.map(&:chomp)
    end

    def error e
      VIM::command(%[let b:github_error = 1])
      VIM::command(%[echoerr #{vstr e}])
    end

    def vstr s
      %["#{s.to_s.gsub '"', '\"'}"]
    end

    def format_time at
      time = Time.parse(at)
      diff = Time.now - time
      pdenom = 1
      [
        [60,           'second'],
        [60 * 60,      'minute'],
        [60 * 60 * 24, 'hour'  ],
        [60 * 60 * 24, 'hour'  ],
        [nil, 'day']
      ].each do |pair|
        denom, unit = pair
        if denom.nil? || diff < denom
          t = diff.to_i / pdenom
          return "#{t} #{unit}#{t == 1 ? '' : 's'} ago"
        end
        pdenom = denom
      end
    end
  end
end
EOF
" }}}
