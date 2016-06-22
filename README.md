# popper

[![Build Status](https://travis-ci.org/pyama86/popper.svg)](https://travis-ci.org/pyama86/popper)
[![Code Climate](https://codeclimate.com/github/pyama86/popper/badges/gpa.svg)](https://codeclimate.com/github/pyama86/popper)
[![Test Coverage](https://codeclimate.com/github/pyama86/popper/badges/coverage.svg)](https://codeclimate.com/github/pyama86/popper/coverage)

To post a variety of services by analyzing the email
* slack notification
* create issue to github.com or ghe
* exec arbitrary commands

# install
  $ gem install popper

# usage
```
  # create /etc/popper.conf
  $ popper init

  # edit popper.conf
  $ vi /etc/popper.conf

  # print config
  $ popper print

  $ popper --daemon --config /etc/popper.conf --log /var/log/popper.log --pidfile /var/run/popper/popper.pid
```
systmd service config: https://github.com/pyama86/popper/tree/master/init_script/cent7/etc/systemd/system/popper.service

# configure(toml)
## ~/popper/popper.conf
```toml
include = ["/etc/popper/*.conf"]
interval = 60         # fetch interbal default:60

[default.condition]

subject = ["^(?!.*Re:).+$"]

[default.action.slack]

webhook_url = "webhook_url"
user = "slack"
channel = "#default_channel"
message = "default message"

# <user_name>.login
[example.login]

server = "example.com"
user = "example@example.com"
password = "password"
port = 110(default)
ssl = false
delete_after = false

# <user_name>.default.condition
[example.default.condition]
subject = [".*default.*"]

# <user_name>.default.action.<action_name>
[example.default.action.slack]
channel = "#account default"

# <user_name>.rules.<rule_name>.condition
[example.rules.normal_log.condition]

subject = [".*Webmailer Exception.*"]

# <user_name>.rules.<rule_name>.action.<action_name>
[example.rules.normal_log.action.slack]

channel = "#channel"
mentions = ["@user"]
message = "webmailer error mail"

[example.rules.normal_log.action.git]
repo = "example/fuu"

[example.rules.normal_log.action.exec_cmd]
repo = "/path/to/other_command.rb"

[example2.login]
user = "example2@example.com"
...
```

# option
```
  -c, [--config=CONFIG]
  -l, [--log=LOG]
  -d, [--daemon], [--no-daemon]
  -p, [--pidfile=PIDFILE]
```

# author
* pyama
