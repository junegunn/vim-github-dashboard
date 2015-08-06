vim-github-dashboard
====================

Browse GitHub events (user dashboard, user/repo activity) in Vim.

### User dashboard: `:GHD! matz`

![](https://raw.github.com/junegunn/i/master/matz-dashboard.png)

### User activity: `:GHA! matz`

![](https://raw.github.com/junegunn/i/master/matz-activity.png)

### Repository activity: `:GHA! mruby/mruby`

![](https://raw.github.com/junegunn/i/master/mruby-activity.png)

(Color scheme used: [seoul256-light](https://github.com/junegunn/seoul256.vim))

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/vim-github-dashboard'
```

Requirements
------------

1. Your Vim must have Ruby support enabled. Check if `:echo has('ruby')` prints 1.
2. If you see LoadError on `:ruby require 'json/pure'`, you need to install `json_pure` gem.

### Mac OS X

The current version of Mac OS X is shipped with a Ruby-enabled Vim.
However, by default it comes with an old Ruby (1.8.7),
so you still need to install `json_pure` (or `json`) gem.

```sh
sudo gem install json_pure
```

If your Vim crashes, try installing a newer version of Vim
with [Homebrew](http://mxcl.github.io/homebrew/).

### Ubuntu

```sh
sudo apt-get install ruby rubygems vim-nox && sudo /usr/bin/gem install json_pure
```

(Reference: [Installing vim with ruby support (+ruby)](http://stackoverflow.com/questions/3794895/installing-vim-with-ruby-support-ruby))

### Windows

1. Download and install the [official GVim](http://www.vim.org/download.php#pc)
2. Download a newer build of GVim executable from [here](http://wyw.dcweb.cn/#download) and replace the existing one
3. Download and install Ruby 1.9.3 using [RubyInstaller](http://rubyinstaller.org/downloads/). You must check `Add Ruby executable to your PATH` option.

Commands
--------

### With authentication

- `:GHDashboard`
- `:GHDashboard USER`
- `:GHActivity`
- `:GHActivity USER`
- `:GHActivity USER/REPO`

### Without authentication (60 calls/hour limit, only public activities)

- `:GHDashboard! USER`
- `:GHActivity! USER`
- `:GHActivity! USER/REPO`

Navigation
----------

Use `CTRL-N` and `CTRL-P` to navigate back and forth through the links.

Press `Enter` key or `double-click` on a link to open it in the browser.

Press `R` to refresh the window.

Press `q` to close the window.

Authentication
--------------

When you first run `:GHDashboard` or `:GHActivity` command,
you will be asked to enter your GitHub username and the password.
Once it is successfully authenticated, the Vim process will remember
the credentials and will no more ask for them.

If you don't want to be asked for username and password, you can set up
`g:github_dashboard` variable as follows.

```vim
let g:github_dashboard = { 'username': 'you', 'password': 'secret' }
```

Since having plain-text password in your .vimrc is not the most secure
thing you can do, it is strongly recommended that you don't put password in
your Vim configuration file.

As a more secure alternative, create a [Personal Access Token][pat], export it
as an environment variable and use it as a password.

```
# in some secure file sourced in your .bashrc, .bash_profile, .zshrc, etc.
export GITHUB_TOKEN="<your 40 char token>"
```

```vim
let g:github_dashboard = { 'username': 'you', 'password': $GITHUB_TOKEN }
```

[pat]: https://github.com/settings/tokens/new

### Without authentication

In fact, GitHub API allows you to browse dashboard or activity stream
without authentication, though the hourly rate is limited to 60.
Well, that's good enough as long as you don't check GitHub page every
minute. Use bang commands then: `:GHDashboard!` and `:GHActivity!`.

### Caveat about GitHub Two-factor authentication

If you have enabled [GitHub Two-factor
authentication](https://github.com/settings/two_factor_authentication/configure),
you cannot login with your username and password. In that case, you can generate
a [Personal Access Token](https://github.com/settings/applications) and use it
as the password.


Optional configuration
----------------------

```vim
let g:github_dashboard = {}

" Dashboard window position
" - Options: tab, top, bottom, above, below, left, right
" - Default: tab
let g:github_dashboard['position'] = 'top'

" Disable Emoji output
" - Default: only enable on terminal Vim on Mac
let g:github_dashboard['emoji'] = 0

" Customize emoji (see http://www.emoji-cheat-sheet.com/)
let g:github_dashboard['emoji_map'] = {
\   'user_dashboard': 'blush',
\   'user_activity':  'smile',
\   'repo_activity':  'laughing',
\   'ForkEvent':      'fork_and_knife'
\ }

" Command to open link URLs
" - Default: auto-detect
let g:github_dashboard['open_command'] = 'open'

" API timeout in seconds
" - Default: 10, 20
let g:github_dashboard['api_open_timeout'] = 10
let g:github_dashboard['api_read_timeout'] = 20

" Do not set statusline
" - Then you can customize your own statusline with github_dashboard#status()
let g:github_dashboard['statusline'] = 0

" GitHub Enterprise
let g:github_dashboard['api_endpoint'] = 'http://github.mycorp.com/api/v3'
let g:github_dashboard['web_endpoint'] = 'http://github.mycorp.com'
```

Profiles
--------

In case you need access to GitHub Enterprise as well as the public GitHub, you
might want to define multiple sets of configuration as profiles.

```vim
" Default configuration for public GitHub
let g:github_dashboard = {
\ 'username': 'kent'
\ }

" Profile named `ck`
let g:github_dashboard#ck = {
\ 'username':     'kent.clark',
\ 'api_endpoint': 'http://github.daily-planet.com/api/v3',
\ 'web_endpoint': 'http://github.daily-planet.com'
\ }

" Profile named `super`
let g:github_dashboard#super = {
\ 'username':     'superman',
\ 'api_endpoint': 'http://github.justice-league.org/api/v3',
\ 'web_endpoint': 'http://github.justice-league.org'
\ }
```

Then you can access each GitHub instance like so:

```vim
GHD!

" GitHub Enterprise requires authentication, so use non-bang versions
GHD -ck
GHA -ck lois

GHD -super
GHA -super batman/bmobile
```

Author
------

[Junegunn Choi](https://github.com/junegunn)

License
-------

MIT

_"Why Ruby?"_
-------------

1. This is a personal fun project, and I like Ruby, so why not?
2. Ruby allows me to access GitHub API without another Vim plugin or an external executable
3. Mac OS X (which I use the most) is shipped with a Ruby-enabled Vim, so it's pretty easy to set up

