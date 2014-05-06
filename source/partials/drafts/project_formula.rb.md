```ruby
require "formula"

class ProjectFormula < Formula

  def start_mysql
    system %Q{ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents}
    system %Q{launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist}
  end

  def rake cmd, env = ''
    bundle_exec "rake #{cmd}", env
  end

  def bundle_exec cmd, env = ''
    rbenv_exec "#{env} bundle exec #{cmd}".strip
  end

  def install_bundler
    rbenv_exec 'gem install bundler && rbenv rehash && bundle install'
  end

  def rbenv_exec cmd
    system %Q{cd #{install_dir} && eval "$(rbenv init -)" && #{cmd.strip}}
  end

  def rbenv_install
    system %Q{rbenv install --skip-existing #{ruby_version}} if ruby_version
  end

  def nodenv_install
    system %Q{nodenv install --skip-existing #{node_version}} if node_version
  end

  def ruby_version
    f = "#{install_dir}/.ruby-version"
    @ruby_version ||= IO.read(f).strip if File.exists? f
  end

  def node_version
    f = "#{install_dir}/.node-version"
    @node_version ||= IO.read(f).strip if File.exists? f
  end

  def create_database_yml
    File.open(File.join(install_dir, 'config', 'database.yml'), 'w') {|f|
      f.write database_yml
    }
  end

  def copy_cached_download
    FileUtils::mkdir_p src_dir
    FileUtils::cp_r cached_download, install_dir
  end

  def backup_existing
    if File.directory?(install_dir)
      File.rename install_dir, "#{install_dir}-org-#{Time.now.strftime '%Y%m%d%H%M%S'}"
    end
  end

  def install_dir
    File.join src_dir, name
  end

  def src_dir
    ENV['PBCD_SRC_DIR'] || File.join(ENV['HOME'], 'src')
  end

  def database_yml
    <<EOM;
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{name}_development
  pool: 15
  username: root
  password:
  host: 127.0.0.1
test:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{name}_test
  pool: 15
  username: root
  password:
  host: 127.0.0.1
EOM

  end

end
```
