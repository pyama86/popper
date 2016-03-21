module Popper::Action
  autoload :Base,    "popper/action/base"
  autoload :Slack,   "popper/action/slack"
  autoload :Ghe,     "popper/action/ghe"
  autoload :Git,     "popper/action/git"
  autoload :ExecCmd, "popper/action/exec_cmd"
end
