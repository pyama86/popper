# popper

[![Build Status](https://travis-ci.org/pyama86/popper.svg)](https://travis-ci.org/pyama86/popper)
[![Code Climate](https://codeclimate.com/github/pyama86/popper/badges/gpa.svg)](https://codeclimate.com/github/pyama86/popper)
[![Code Climate](https://codeclimate.com/github/pyama86/popper/badges/gpa.svg)](https://codeclimate.com/github/pyama86/popper)

To post a variety of services by analyzing the email
* slack notification
* create issue to github.com or ghe

# install
  $ gem install popper

# usage
```
  # create ~/popper/popper.conf
  $ popper init

  # edit popper.conf
  $ vi ~/popper/popper.conf

  # pop uidl prefetch
  # to avoid duplication and to fetch the uidl
  $ popper prepop

  $ popper
```
`crontab -l`
```
* * * * * /path/to/popper
```

# configure(toml)
## ~/popper/popper.conf
```
[default.condition]

subject = ["^(?!.*Re:).+$"]

[default.action.slack]

webhook_url = "webhook_url"
user = "slack"
channel = "#default_channel"
message = "default message"

# [config_name].login
[example.login]

server = "example.com"
user = "example@example.com"
password = "password"
port = 110(default)

# [config_name].default.condition
[example.default.condition]
subject = [".*default.*"]

# [config_name].default.action.[action_name]
[example.default.action.slack]
channel = "#account default"

# [config_name].rules.[rule_name].condition
[example.rules.normal_log.condition]

subject = [".*Webmailer Exception.*"]

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
