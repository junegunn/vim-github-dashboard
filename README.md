vim-github-dashboard
====================

Browse GitHub dashboard in Vim.

![matz's activity stream](https://github.com/junegunn/vim-github-dashboard/raw/master/screenshot.png)

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

Requirements
------------

- Ruby support
  - `:echo has('ruby')`
- JSON gem
  - `:ruby require 'json'`
- Internet connection :grin:

Commands
--------

- `:GitHubDashboard`
- `:GitHubDashboard somebody`
- `:GitHubActivity`
- `:GitHubActivity somebody`

Navigation
----------

Use `Tab` and `Shift-Tab` to navigate back and forth through the links.
Press `Enter` key with the cursor on a link to open the link in the
default browser.
Press `q` to close the tab.

Authentication
--------------

When you first run `:GitHubDashboard` or `:GitHubActivity` command,
you will be asked to enter your GitHub username and the password.
Once it is successfully authenticated, the Vim process will remember
the credentials and will no more ask for them. However, if you need to
login as a different user, run `:GitHubDashboard!` or
`:GitHubActivity!` command.

If you don't want to be asked for username and password when running
the commands, you can set up `g:github_dashboard` variable as follows.

```vim
let g:github_dashboard = { 'username': 'you', 'password': 'secret' }
```

Since having plain-text password in your .vimrc is not the most secure
thing you can do, it is strongly recommended that you put only
username in your Vim configuration file.

### Without authentication

In fact, GitHub API allows you to browse dashboard or activity stream
without authentication, though the hourly rate is limited to 60.
Well, that's good enough as long as you don't check GitHub page every
minute. Define empty `password` to bypass authentication without
password prompt. If `password` key is not defined, you will be asked
to enter password.

```vim
" No authentication. Limit: 60 calls/hour
let g:github_dashboard = { 'username': 'you', 'password': '' }
```

Optional configuration
----------------------

```vim
let g:github_dashboard = { 'username': 'you', 'password': '' }

" Disable Emoji output
" - Default: 1 (enabled)
" - (Emoji is only enabled on terminal Vim on MAC)
let g:github_dashboard['emoji'] = 0

" Command to open link URLs
" - Default: 'open' on Mac, 'start' on Windows, or 'xdg-open'
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
