require 'pathname'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:dotfiles) do
  desc = "Install dotfiles in a user specified location"

  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
  end

  validate do
    if self[:dotfiles] == nil || !File.exists?(self[:dotfiles])
      raise ArgumentError, "'dotfiles' is missing or is not a valid directory"
    end

    if self[:home] == nil || !File.exists?(self[:home])
      raise ArgumentError, "'home' is missing or is not a valid directory"
    end
  end

  newparam(:dotfiles, :parent => Puppet::Parameter::Path) do
    desc "Location of dotfiles to install"
  end

  newparam(:home, :parent => Puppet::Parameter::Path) do
    desc "Location of the directory to install the dotfiles"
    isnamevar
  end

  newparam(:backup_path, :parent => Puppet::Parameter::Path) do
    desc "Save to this location if we are backing up existing files"
  end

  newparam(:backup, :boolean => false, :parent => Puppet::Parameter::Boolean) do
    desc "Used to signal if the user wants existing files backed up"
  end

  newparam(:owner) do
    desc "The user/uid that owns the dotfiles"
  end

  newparam(:group) do
    desc "The group/gid that owns the dotfiles"
  end
end
