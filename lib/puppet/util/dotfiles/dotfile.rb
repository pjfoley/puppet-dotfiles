require 'fileutils'
require 'pathname'

module Puppet
module Util
class Dotfiles
  class Dotfile
    attr_reader :dotfile, :homefile, :backupfile

    def initialize(file, dfs)
      relative_path = Pathname.new(file).relative_path_from(Pathname.new(dfs.dotfiles_path)) \
                      .to_path \
                      # Regex match from start of line and replace
                      .gsub(/^(dot_|dcp_)/, '.') \
                      .gsub(/^(cpy_|mkd_)/, '') \
                      # Regex match from path seperator '/' and replace
                      .gsub(/(\/dot_|\/dcp_)/, '/.') \
                      .gsub(/(\/cpy_|\/mkd_)/, '/')

      @timestamp = dfs.timestamp

      @dotfile = file
      @homefile = (Pathname.new(dfs.home_path) + relative_path).to_path
      @backupfile = (Pathname.new(dfs.backup_path) + relative_path).to_path

      @action = case File.basename(file)[0,3]
                  when "dcp", "cpy" then "copy"
                  when "mkd" then "mkdir"
                  else "link"
                end

      @exists_dotfile \
              = case @action
                  when "link" then File.identical?(@dotfile, @homefile)
                  when "copy" then File.exists?(@homefile)
                  when "mkdir" then File.directory?(@homefile)
                end
    end

    def to_s
      "#{@dotfile}\n\t#{@homefile}\n\t#{@backupfile}\n\t" + (@exists ? "True" : "False")
    end

    def install
      if !exists_dotfile?
        self.send(@action)
      end
    end

    def remove
      puts "Removing"
    end

    def backup
      backup_file
    end

    def directory?
      @action == 'mkdir' ? true : false
    end

    def exists_dotfile?
      @exists_dotfile
    end

    def exists_bkupfile?
      return false if ! File.exists?(@homefile) || exists_dotfile?
      case @action
        when "copy" then false
        else
          bck_fn = Dir.glob(File.dirname(@backupfile) + "/*" + File.basename(@backupfile)) \
                            .sort_by { |e| e[/\d{14}/].to_i }.last

          return true if ! bck_fn

          puts "Compare me: " + bck_fn.to_s

          ! FileUtils.compare_file(@homefile, bck_fn)
      end
    end

    private

    def copy
      FileUtils.copy @dotfile, @homefile
    end

    def link
      FileUtils.ln_sf @dotfile, @homefile
    end

    def mkdir
      FileUtils.mkdir_p @homefile
    end

    def backup_file
      FileUtils.mkdir_p File.dirname(@backupfile) if ! File.directory?(File.dirname(@backupfile))
      FileUtils.mv @homefile, File.dirname(@backupfile) + "/#{@timestamp}_" + File.basename(@backupfile)
    end
  end
end
end
end
