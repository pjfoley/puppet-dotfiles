require 'pathname'

class Dotfile
  attr_reader :file, :dotfiles, :action
  def initialize (file, dfs)
    @file = file
    @dotfiles = dfs
    @target = dfs.home + file.relative_path_from(dfs.dotfiles).sub(/^(dot_|dcp_)/, '.').sub(/^(cpy_|mov_|mkd_)/, '').sub(/(\/dot_|\/dcp_)/, '/.').sub(/(\/cpy_|\/mov_|\/mkd_)/, '/')
    @action = file.basename.to_path =~ /^(dcp_|cpy_|mov_|mkd_)/ ? file.basename.to_path[0,4] : "lnk_"
  end

  def directory?
    @action == 'mkd_' ? true : false
  end

  def to_s
    "#{@action} #{@file.to_path} \t#{@target}"
  end
end


class Dotfiles
  attr_reader :dotfiles, :home

  def initialize (dotfiles, home)
    @dotfiles = Pathname.new(dotfiles)
    @home = Pathname.new(home)
  end

  def to_s 
    "Source: #{@dotfiles.to_path}\nDestination: #{@home.to_path}"
  end

end

def sync_subdir(dir, level = 1)
  Pathname.glob(dir.file.to_path + "/*") do |f|
    df = Dotfile.new(f, dir.dotfiles)

    puts df.to_s
    sync_subdir(df, level + 1) if df.directory?
  end
end

def sync_dotfiles(dfs)
  puts dfs.to_s
  Pathname.glob(dfs.dotfiles.to_path + "/*") do |f|
    df = Dotfile.new(f, dfs)

    puts df.to_s

    sync_subdir(df) if df.directory?
  end

end

dfs = Dotfiles.new("/root/.dotfiles/home", "/root")

sync_dotfiles(dfs)
