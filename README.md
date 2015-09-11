# popper
To post a variety of services by analyzing the email
* slack notification
* create issue to github.com or ghe

# install
  $ gem install popper

# usage
  # create ~/popper/popper.conf
  $ popper init
  
  # edit popper.conf
  $ vi ~/popper/popper.conf
  
  # pop uidl prefetch
  # to avoid duplication and to fetch the uidl
  $ popper prepop
  
  $ popper
  
`crontab -l`
```
* * * * * /path/to/popper
```

# configure
## ~/popper/popper.conf
```
[popper]
git_token = "token"
ghe_token = "token"
ghe_url   = "http://git.example.com"

slack_webhook_url = "webhook_url"
slack_user = "slack"

# [config_name].login
[example.login]
server = "example.com"
# port = 110(default)
user = "example@example.com"
password = "password"

# [config_name].rules.[rule_name].condition
[example.rules.normal_log.condition]
subject = ".*Webmailer Exception.*"

# [config_name].rules.[rule_name].action.[action_name]
[example.rules.normal_log.action.slack]
channel = "#channel"
mentions = ["@user"]
message = "webmailer error mail"

[example.rules.normal_log.action.git]
repo = "example/fuu"

[example2.login]
user = "example2@example.com"
...
```

# option
* config_file `--config or -c`
* log_file(default=/var/log/popper.log) `--log or -l`

# author
* pyama
