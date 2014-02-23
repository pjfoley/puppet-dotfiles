require File.expand_path('../dotfiles/dotfile', __FILE__)
require 'find'

module Puppet
module Util
  class Dotfiles

    def initialize(dotfiles, home, backup = true, backup_path = "#{home}/.dotfiles_org" )
      # Folder locations
      @dotfiles_path, @home_path, @backup_path = dotfiles, home, backup_path

      # Do we want to backup any existing files
      @backup = backup

      # Used with backup file name
      @timestamp = Time.now.strftime("%Y%m%d%H%M")

      @dotfile_hash = {}
      @cleanup_dotfile_hash = {}

      if File.directory?(@dotfiles_path)
        parse_dangling_dotfiles
        parse_dotfiles
      end
    end

    attr_reader :dotfile_hash, :dotfiles_path, :home_path, :backup_path, :timestamp


    def create
      @cleanup_dotfile_hash.each { |k,df| df.remove; @cleanup_dotfile_hash.delete(k) }
      return if exists?
      @dotfile_hash.each do |k,df|
        df.backup if @backup && df.exists_bkupfile?
        df.install
      end
    end

    def destroy
      puts "Lets tear the joint down!"
    end

    def exists?
      dotfile_hash.collect { |k, v| v.exists_dotfile?}.all? && @cleanup_dotfile_hash.empty?
    end


    private

    def parse_dotfiles(subdir = nil)
      directory = subdir.nil? ? @dotfiles_path : subdir
      Dir.glob(directory + "/*").each do |f|
        df = Dotfile.new(f, self)
        @dotfile_hash[df.homefile] = df
        parse_dotfiles(f) if df.directory?
      end
    end

    def parse_dangling_dotfiles
      Find.find(@home_path) do |path|
        if File.symlink?(path) && ! File.exists?(path) && File.readlink(path).start_with?(@dotfiles_path)
          df = Dotfile.new(File.readlink(path), self)
          @cleanup_dotfile_hash[df.homefile] = df
        end
      end
    end
  end
end
end
