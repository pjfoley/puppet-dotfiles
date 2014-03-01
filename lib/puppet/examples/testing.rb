require File.expand_path('../../util/dotfiles', __FILE__)

df = Puppet::Util::Dotfiles.new("/root/.dotfiles/home", "/root/tmp/zzzz", { :owner => "pjfoley", :group => "pjfoley"})

df.create if ! df.exists?
