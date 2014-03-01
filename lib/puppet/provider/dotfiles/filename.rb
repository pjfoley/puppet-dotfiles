require File.expand_path('../../../util/dotfiles', __FILE__)
#require 'puppet'

Puppet::Type.type(:dotfiles).provide(:filename) do
  def create
    dotfiles.create
  end

  def exists?
    dotfiles.exists?
  end

  private
  def dotfiles
    @dotfiles ||= Puppet::Util::Dotfiles.new(@resource[:dotfiles], @resource[:home], @resource.to_hash)
  end
end
