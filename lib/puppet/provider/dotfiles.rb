require 'fileutils'
require 'pathname'

class Dotfile
  attr_reader :file, :dotfiles, :action
  def initialize (file, dfs)
    @file = file
    @dotfiles = dfs
    @target = (Pathname.new(dfs.home) + file.relative_path_from(Pathname.new(dfs.dotfiles))).to_path.gsub(/^(dot_|dcp_)/, '.').gsub(/^(cpy_|mov_|mkd_)/, '').gsub(/(\/dot_|\/dcp_)/, '/.').gsub(/(\/cpy_|\/mov_|\/mkd_)/, '/')
    @action = case file.basename.to_path[0,3]
                when "dcp", "cpy" then "copy"
                when "mov" then "move"
                when "mkd" then "mkdir"
                else "link"
              end
  end

  def directory?
    @action == 'mkdir' ? true : false
  end

  def to_s
    "#{@file.to_path} \t#{@target}"
  end

  def operation
    self.send(action)
  end

  def copy
    FileUtils.copy @file, @target
#    puts "Copying #{self}"
  end

  def link
    FileUtils.ln_sf @file, @target
#    puts "Linking #{self}"
  end

  def move
    puts "moving #{self}"
  end

  def mkdir
    FileUtils.mkdir_p @target
#    puts "Make Directory #{self}"
  end
end


class Dotfiles
  include Enumerable

  attr_reader :dotfiles, :home

  def initialize (dotfiles, home)
    @dotfiles, @home = dotfiles, home
  end

  def each(&block)
    Pathname.glob(@dotfiles + "/*").each do |f|
      block.call(Dotfile.new(f,self))
    end
  end

  def to_s 
    "Source: #{@dotfiles}\nDestination: #{@home}"
  end

end

def sync_subdir(dir, level = 1)
  Pathname.glob(dir.file.to_path + "/*") do |f|
    df = Dotfile.new(f, dir.dotfiles)
  df.operation

#    puts df.to_s
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

dfs = Dotfiles.new("/root/.dotfiles/home", "/root/tmp/dotfiles_test")
puts dfs
dfs.each do |f|

  f.operation

    sync_subdir(f) if f.directory?

end
