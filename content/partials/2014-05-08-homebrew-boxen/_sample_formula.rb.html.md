$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require "project_formula"
class Planbcd < ProjectFormula
  homepage "https://github.com/kaizenplatform/planbcd/"
  head "git@github.com:kaizenplatform/planbcd.git", :using => :git
  depends_on "rbenv"
  depends_on "ruby-build"
  depends_on 'readline'
  depends_on 'openssl'
  depends_on "mysql"
  depends_on "imagemagick"
  depends_on "phantomjs"
  def install
    backup_existing
    copy_cached_download
    create_database_yml
    rbenv_install
    install_bundler
    start_mysql
    rake 'db:create'
    rake 'db:create',  'RAILS_ENV=test'
    rake 'db:migrate'
    rake 'db:migrate',  'RAILS_ENV=test'
  end
end
