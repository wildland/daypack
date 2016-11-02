class Installer
  def self.full_install
    ruby_bot = Installer.new
    ruby_bot.ensure_bash_profile
    [
      'git', 'hub',
      'npm', 'bower',
      'psql',
      'rbenv', 'ruby-build',
      'bundler', 'foreman', 'ember-cli',
      'cask',
      'VirtualBox', 'boot2docker', 'docker-compose'
    ].each do |program|
      ruby_bot.install_program(program)
    end
  end

  def ensure_bash_profile
    bash_profile_location = '~/.bash_profile'
    unless File.exist?(bash_profile_location)
      File.write(File.expand_path(bash_profile_location), "")
    end
  end

  def install_program(program, noisy=true)
    if program_exists?(program)
      puts "#{program} is already installed" if noisy
      run_update_script(program, noisy)
    else
      puts "Installing #{program}" if noisy
      check_prerequisites(program, noisy)
      run_install_script(program, noisy)
    end
  end

  protected

  def program_exists?(program)
    case program
    when 'cask'
      system("brew list brew-cask > /dev/null 2>&1")
    when 'VirtualBox'
      system("brew cask list virtualbox > /dev/null 2>&1")
    when 'psql'
      system("brew cask list postgres > /dev/null 2>&1")
    when 'ember-cli', 'bower'
      system("npm list -g --depth=0 #{program} > /dev/null 2>&1")
    else
      system("which #{ program} > /dev/null 2>&1")
    end
  end

  def check_prerequisites(program, noisy=true)
    find_prerequisites(program).each do |program|
      install_program(program, false)
    end
  end

  def run_install_script(program, noisy=true)
    case program
    when 'git'
      system('brew update') # TODO Move this check
      system('brew install git')
    when 'brew'
      system('ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    when 'bower'
      system('npm install -g bower')
    when 'npm'
      system('curl https://raw.githubusercontent.com/creationix/nvm/v0.24.1/install.sh | bash') # TODO find a way to figure out latest version
      system('nvm install stable')
    when 'ruby-build'
      system('brew install ruby-build')
    when 'rbenv'
      system('brew install rbenv')
    when 'psql'
      system('brew cask install postgres --appdir=/Applications')
      system('brew install postgres')
    when 'cask'
      system('brew install caskroom/cask/brew-cask')
    when 'hub'
      system('brew install hub')
    when 'boot2docker'
      system('brew install boot2docker')
    when 'docker-compose'
      system('brew install docker-compose')
    when 'VirtualBox'
      system('brew cask install virtualbox')
    when 'bundler'
      system('gem install bundler')
    when 'foreman'
      system('gem install foreman')
    when 'ember-cli'
      system('npm install -g ember-cli')
    else
      # TODO?
    end
  end

  def run_update_script(program, noisy=true)
    case program
    when 'git'
      system('brew upgrade git')
    when 'brew'
      system('brew update')
    when 'npm'
      system('curl https://raw.githubusercontent.com/creationix/nvm/v0.24.1/install.sh | bash')
      system('nvm install stable')
    when 'hub'
      system('brew upgrade hub')
    when 'ruby-build'
      system('brew upgrade ruby-build')
    when 'rbenv'
      system('brew upgrade rbenv')
    when 'psql'
      system('brew cask update postgres')
      system('brew upgrade postgres')
    when 'cask'
      system('brew upgrade brew-cask')
    when 'boot2docker'
      system('brew upgrade boot2docker')
    when 'docker-compose'
      system('brew upgrade docker-compose')
    when 'VirtualBox'
      system('brew cask update virtualbox')
    when 'bundler'
      system('gem update bundler')
    when 'foreman'
      system('gem update foreman')
    when 'ember-cli'
      system('npm update -g ember-cli')
    else
      # TODO?
    end
  end

  def find_prerequisites(program)
    case program
    when 'ruby-build', 'bundler', 'foreman'
      ['rbenv']
    when 'git', 'rbenv', 'hub'
      ['brew']
    when 'bower', 'ember-cli'
      ['npm']
    when 'boot2docker', 'docker-compose'
      ['brew', 'VirtualBox']
    when 'VirtualBox', 'psql'
      ['cask']
    when 'cask'
      ['brew']
    else
      []
    end
  end
end

class Gitconfig
  def self.setup_config
    ruby_bot = Gitconfig.new
    ruby_bot.add_aliases
  end

  def add_aliases
    add_config('alias.co', 'checkout')
    add_config('alias.st', 'status')
    add_config('alias.aa', 'add --all')
    add_config('alias.ci', 'commit')
    add_config('alias.df', 'diff')
    add_config('alias.create-branch', "!sh -c 'git push origin HEAD:refs/heads/\$1 && git fetch origin && git branch --track \$1 origin/\$1 && cd . && git checkout \$1' -")
    add_config('alias.merge-branch', "!git checkout master && git merge @{-1}")
    add_config('alias.delete-branch', "!sh -c 'git push origin :refs/heads/\$1 && git remote prune origin && git branch -D \$1' -")
    add_config('alias.rebase-origin', "!git fetch origin && git rebase origin/master")
    add_config('alias.irebase-origin', "!git fetch origin && git rebase -i origin/master")
    add_config('alias.force-push-branch', "!git push --force-with-lease origin HEAD")
    add_config('alias.hard-reset-branch', "!sh -c 'git fetch origin && branch=$(git symbolic-ref --short HEAD) && git reset --hard origin/\"$branch\"' -")
  end

  def add_config(var, setting)
    system("git config --global #{var} \"#{setting}\"")
  end
end

Installer.full_install
Gitconfig.setup_config
