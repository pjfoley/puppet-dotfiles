require File.expand_path('../dotfiles/dotfile', __FILE__)

module Puppet
module Util
  class Dotfiles
    include Enumerable

    def initialize(dotfiles, home, backup = false, backup_location = "", removed_dotfiles = [])
      # Folder locations
      @dotfiles, @home, @backup_location = dotfiles, home, backup_location

      # Do we want to backup any existing files
      @backup = backup

      # Used with backup file name
      @timestamp = Time.now.strftime("%Y%m%d%H%M%S")

      # Files to clean up from home directory
      @removed_dotfiles = removed_dotfiles

      if File.directory?(@dotfiles)
        parse_dotfiles
      end

    end
  end
end
end
