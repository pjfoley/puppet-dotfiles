require 'fileutils'
require 'pathname'

class Dotfile
  attr_reader :file, :dotfiles, :action

  def initialize (file, dfs)
    @file = file
    @dotfiles = dfs
    @relative_target = file.relative_path_from(Pathname.new(dfs.dotfiles)).to_path.gsub(/^(dot_|dcp_)/, '.').gsub(/^(cpy_|mkd_)/, '').gsub(/(\/dot_|\/dcp_)/, '/.').gsub(/(\/cpy_|\/mkd_)/, '/')
    @target = (Pathname.new(dfs.home) + @relative_target)
    @backup = (Pathname.new(dfs.backup_path) + @relative_target)
    @action = case file.basename.to_path[0,3]
                when "dcp", "cpy" then "copy"
                when "mkd" then "mkdir"
                else "link"
              end

  end

  def directory?
    @action == 'mkdir' ? true : false
  end

  def to_s
    "#{@file} \n\t#{@target} \n\t#{@backup}"
  end

  def install
    backup_file if backup?
    self.send(action) if !exists?
  end

  def backup?
    if @dotfiles.backup && File.exists?(@target) && ! exists?
      case @action
        when "copy" then false
        else
          bck_fn = Dir.glob(File.dirname(@backup) + "/*" + File.basename(@backup)).sort_by { |e| e[/\d{14}/].to_i }.last

          return true if ! bck_fn

          FileUtils.compare_file(@target, bck_fn) ? false : true
      end
    else
      false
    end
  end

  def backup_file
    FileUtils.mkdir_p File.dirname(@backup) if ! File.directory?(File.dirname(@backup))
    FileUtils.mv @target, File.dirname(@backup) + "/#{@dotfiles.timestamp}_" + File.basename(@backup)
  end

  def exists?
    case @action
      when "link" then File.identical?(@file, @target)
      when "copy" then File.exists?(@target)
      when "mkdir" then File.directory?(@target)
    end
  end

  def copy
    FileUtils.copy @file, @target
  end

  def link
    FileUtils.ln_sf @file, @target
  end

  def mkdir
    FileUtils.mkdir_p @target
  end

  def cleanup
    return if @action != "link" && ! File.exists?(@target)
    fn = Pathname.new(@target)
    fn.delete if File.symlink?(@target)

    bck_fn = Dir.glob(File.dirname(@backup) + "/*" + File.basename(@backup)).sort_by { |e| e[/\d{14}/].to_i }.last

    FileUtils.copy bck_fn, @target if bck_fn
  end
end


class Dotfiles
  include Enumerable

  attr_reader :dotfiles, :home, :backup, :backup_path, :timestamp, :removed_files

  def initialize (dotfiles, home, backup = false, backup_path = "", dotfiles_cleanup = [])
    @dotfiles, @home, @backup, @backup_path, @dotfiles_cleanup = dotfiles, home, backup, backup_path, dotfiles_cleanup

    @timestamp = Time.now.strftime("%Y%m%d%H%M%S")

    FileUtils.mkdir_p @backup_path if @backup

    cleanup

  end

  def each(&block)
    Pathname.glob(@dotfiles + "/*").each do |f|
      df = Dotfile.new(f,self)
      block.call(df)
      dotfile_subdir(df, block) if df.directory?
    end
  end

  def to_s 
    "Source: #{@dotfiles}\nDestination: #{@home}"
  end

  private

  def dotfile_subdir(df, block)
    Pathname.glob(df.file.to_path + "/*").each do |f|
      df = Dotfile.new(f,self)
      block.call(df)
      dotfile_subdir(df, block) if df.directory?
    end
  end

  def cleanup
    return if @dotfiles_cleanup.empty?

    @dotfiles_cleanup.each do |f|
      Dotfile.new(Pathname.new(@dotfiles) + f, self).cleanup
    end

  end

end

dfs = Dotfiles.new("/root/.dotfiles/home", "/root/tmp/dotfiles_test", true, "/root/tmp/dotfiles_test/.dotfiles_backup", ["dot_inputrc", "mkd_foo", "dot_foo/dot_hidden"])
dfs.each { |f| f.install }
