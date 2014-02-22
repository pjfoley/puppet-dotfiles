require File.expand_path('../dotfiles/dotfile', __FILE__)

module Puppet
module Util
  class Dotfiles
#    include Enumerable

    def initialize(dotfiles, home, backup = true, backup_path = "#{home}/.backupdot", removed_dotfiles = [])
      # Folder locations
      @dotfiles_path, @home_path, @backup_path = dotfiles, home, backup_path

      # Do we want to backup any existing files
      @backup = backup

      # Used with backup file name
      @timestamp = Time.now.strftime("%Y%m%d%H%M%S")

      # Files to clean up from home directory
      @removed_dotfiles = removed_dotfiles

      @dotfile_names = []
      @dotfile_hash = {}

      @exists = false

      if File.directory?(@dotfiles_path)
        parse_dotfiles
        @exists = dotfile_hash.collect { |k, v| v.exists_dotfile?}.all?
      end
    end

    attr_reader :dotfile_names, :dotfile_hash, :dotfiles_path, :home_path, :backup_path, :timestamp


    def create
      @dotfile_hash.each do |k,df|
        df.backup if @backup && df.exists_bkupfile?
        df.install
      end
    end

    def destroy
      puts "Lets tear the joint down!"
    end

    def exists?
      @exists
    end


    private

    def add_dotfile(df)
      @dotfile_hash[df.homefile] = df
      @dotfile_names << df.homefile
    end

    def parse_dotfiles(subdir = nil)
      directory = subdir.nil? ? @dotfiles_path : subdir
      Dir.glob(directory + "/*").each do |f|
        df = Dotfile.new(f, self)
        add_dotfile(df)
        parse_dotfiles(f) if df.directory?
      end
    end
  end
end
end
