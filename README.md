vim-github-dashboard
====================

Browse GitHub events (user dashboard, user/repo activity) in Vim.

### User dashboard: `:GHD! matz`

![](https://raw.github.com/junegunn/vim-github-dashboard/screenshot/matz-dashboard.png)

### User activity: `:GHA! matz`

![](https://raw.github.com/junegunn/vim-github-dashboard/screenshot/matz-activity.png)

### Repository activity: `:GHA! mruby/mruby`

![](https://raw.github.com/junegunn/vim-github-dashboard/screenshot/mruby-activity.png)

Installation
------------

Use [Vundle](https://github.com/gmarik/vundle) (recommended)
or [Pathogen](https://github.com/tpope/vim-pathogen).

### With Vundle

Add the following line to your .vimrc,

```vim
Bundle 'junegunn/vim-github-dashboard'
```

then execute, `:BundleInstall` command.

### With Pathogen

```sh
cd ~/.vim/bundle
git clone git@github.com:junegunn/vim-github-dashboard.git
```

Requirements
------------

1. Your Vim must have Ruby support enabled. Check if `:echo has('ruby')` prints 1.
2. If you see LoadError on `:ruby require 'json/pure'`, you need to install `json_pure` gem.

### Mac OS X

The current version of Mac OS X is shipped with Ruby-enabled Vim.
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

Download and install Ruby 1.9.3 using [RubyInstaller](http://rubyinstaller.org/downloads/).
You must check `Add Ruby executable to your PATH` option.

Ruby support of Windows GVim is unstable at the moment, so you may run into some glitches.

Commands
--------

### With authentication

- `:GHDashboard`
- `:GHDashboard USER`
- `:GHActivity`
- `:GHActivity USER`
- `:GHActivity USER/REPO`

### Without authentication (60 calls/hour)

- `:GHDashboard! USER`
- `:GHActivity! USER`
- `:GHActivity! USER/REPO`

Navigation
----------

Use `Tab` and `Shift-Tab` to navigate back and forth through the links.

Press `Enter` key or `double-click` on a link to open it in the browser.

Press `R` to refresh the tab.

Press `q` to close the tab.

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

```vim
let g:github_dashboard = { 'username': 'you' }
```

### Without authentication

In fact, GitHub API allows you to browse dashboard or activity stream
without authentication, though the hourly rate is limited to 60.
Well, that's good enough as long as you don't check GitHub page every
minute. Use bang commands then: `:GHDashboard!` and `:GHActivity!`.

Optional configuration
----------------------

```vim
" Dashboard window position
" - Options: tab, top, bottom, above, below, left, right
" - Default: `top` on Windows, `tab` on others
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
```

Author
------

[Junegunn Choi](https://github.com/junegunn)

License
-------

MIT
