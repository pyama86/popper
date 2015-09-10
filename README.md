# popper
To post a variety of services by analyzing the email
* slack notification
* create issue to github.com or ghe

# install
  $ gem install popper

# usage
  $ popper init

`crontab -l`
```
* * * * * /path/to/popper
```

# configure
## ~/popper/popper.conf
```
[popper]
git_token = token
ghe_token = token
ghe_url   = url

slack_webhook_url = webhook_url

[example1.login]
user = example1@example.com
password = password

[example1.match]
subject = .*match_word.*
body = .*match_word.*

[example1.action]
slack = #channel_name
git = orgs/repo

[example2.login]
user = example2@example.com
...
```

# option
* config_file `--config or -c`
* log_file(default=/var/log/popper.log) `--log or -l`

# author
* pyama
