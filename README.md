# popper
To post a variety of services by analyzing the email
* slack notification
* create issue to github.com or ghe

# install
  $ gem install popper

# usage
`~/.procmailrc`
```
* ^To: example1@example.com
| /path/to/popper
```

# configure
## /etc/popper.conf
```
[popper]
git_token = your token

ghe_token = your token
ghe_url   = your token

slack_webhook_url = webhook_url

[example1@example.com.match]
subject = .*match_word.*
body = .*match_word.*

[example1@example.com.action]
slack = #channel_name
git = orgs/repo
```

# option
* config_file `--config or -c`
* log_file(default=/var/log/popper.log) `--log or -l`

# author
* pyama
