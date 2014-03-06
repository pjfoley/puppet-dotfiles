# For testing export the RUBYLIB to point to the lib directory
dotfiles{ '/root/tmp/zzzz':
  dotfiles       => '/root/.dotfiles/home-old',
  owner          => 'pjfoley',
  group          => 'pjfoley',
  backup         => true,
}

