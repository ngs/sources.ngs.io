---
title: Homebrew vs Boxen を比較して、brewproj に着手
date: 2014-05-08 07:00
description: Boxen から Homebrew を技術検証していたら、新しい OSS プロジェクトを始めようと思いました。
tags: homebrew, osx, boxen, brewproj
public: true
alternate: false
---

[前の投稿]で書いたとおり、連休中、開発環境を整理しながら、同僚の開発環境を構築している [Boxen] から [Homebrew] へ移行できないかと、技術検証していました。

READMORE

結論、それぞれ Pros. / Cons. があり、まだ Homebrew で構築するには足りないものがあるなぁ、と思った次第です。

## Package 管理は Brewfile だけでやるのが楽。

例えば、Boxen で VMWare Fusion と tree をインストールしたい場合、

* `Puppetfile` に `github "vmware_fusion","1.1.0"` を追加
* `modules/people/manifests/$USER.pp` に以下を追加:
    * `include vmware_fusion`
    * `package { 'tree': ; }`

の2工程を踏み、`boxen` スクリプトを実行します。

```bash
script/boxen
```

さらに VMWare Fusion がアップデートした場合には、`Puppetfile` を更新します。

それをせずに、手動で VMWare Fusion をアップデートし、`boxen` スクリプトを再度実行した場合、[init.pp] に宣言されているバージョンにデグレードしてしまいます。

それに対して、Homebrew は Brewfile に以下の4行を書き、

```
update
upgrade
install tree
cask install vmware-fusion
```

`brew bundle` コマンドを実行するだけで、常に最新のソフトウェアをインストールしてくれます。

```bash
brew bundle
```

定義ファイルとバージョンの管理は Homebrew に軍配があがります。

## Ruby vs Puppet

Boxen は Puppet です。Ruby と違って、システムの自動管理の目的にできたものなので、プログラミング言語としての機能はそこまで高度ではありません。

ライブラリを Ruby 書いて、拡張していくことができます。

Puppet の定義ファイルはシンプルに書けるのですが、構築で躓くと、結局 Puppet の Ruby のソースを読まざるを得なくなります。

これを扱う同僚のほとんどがインフラではなく、アプリケーションエンジニアなので、Puppet を学習してもらうのは、多少コストが高いです。

Homebrew の [Formula] も DSLできれいな定義ファイルが書けるので、特に Puppet が優位でもないと思います。

\# 前に Chef でプログラマティックに recipe を書きすぎて注意されたので、Ruby 乱用厳禁ですが。

## では、Boxen はオワコンでおｋ？

いいえ。

## Boxen はバイナリをキャッシュする

Boxen は、`sync` コマンドで Homebrew の Celler 配下、rbenv でインストールした Ruby をそれぞれ tarball にしてアップロードし、次にセットアップする人は、ビルドする必要がありません。

https://github.com/boxen/our-boxen/blob/master/script/sync

![](2014-05-08-homebrew-boxen/synced.png)

Ruby, Homebrew は Boxen が独自に拡張している機能です: [rubybuild.rb], [boxen-bottle-hook]

NodeJS は [nodenv] に元々その機能があるみたいです: [nodenv-install]。

## Project で開発環境構築

この機能が一番大きくて、[Project Manifests] を書いたら、ソースコードをチェックアウトし、依存しているモジュール、DB 設定など、諸々面倒を見てくれます。

```puppet
class projects::trollin {
  include icu4c
  include phantomjs

  boxen::project { 'trollin':
    dotenv        => true,
    elasticsearch => true,
    mysql         => true,
    nginx         => true,
    redis         => true,
    ruby          => '1.9.3',
    source        => 'boxen/trollin'
  }
}
```


## ということで、Homebrew 拡張に着手します。

前述の様に Boxen にも良い所があり、とはいえ、Puppet が面倒臭い、設定が複雑など、超えられない壁があるので、Homebrew を拡張して、それらの足りない機能を補うモジュールを開発しようと思います。

### ProjectFormula

まずは、[Project Manifests] と同じ様なことをできるようにしました。

#### 1. 個人、組織で [Tap] を作成する。

* リポジトリを作成。 例:`kaizenplatform/homebrew-kaizenplatform`
* 基礎クラス `ProjectFormula`: `lib/project_formula.rb`
* プロジェクト Formula

こんな感じで Formula を書くと、

```ruby
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
```


* 依存モジュールをインストール (Homebrew標準機能)
* プロジェクトコードのチェックアウト
* `config/database.yml` をインストール
* `.ruby-version` に入っている Ruby を rbenv でインストール
* Bundler のインストール、`bundle install` の実行
* MySQL 起動
* Rake タスク: DB 作成+マイグレーション

を行ってくれます。

**lib/project_formula.rb:**

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
    rbenv_exec "#{env} bundle exec #{cmd}"
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
    ENV['HOMEBREW_PROJECT_SRC_DIR'] || File.join(ENV['HOME'], 'src')
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



#### 2. `brew tap` コマンドで Tap をインストール。

```bash
brew tap kaizenplatform/kaizenplatform
```

#### 3. `brew install` でプロジェクト環境構築

```bash
brew install planbcd
```

### 使ってみていい感じだったので、Homebrew Cask みたいにしたい。

上記で、必要最低限の環境構築はできました。

さらにこれをワークフロー化するために、Homebrew Cask みたいにサブコマンドを作って、サクサク Formula を作成できるようにしたいです。

<%= partial 'partials/2014-05-08-homebrew-boxen/brew_proj.sh' %>

とりあえず、組織とリポジトリだけ作りました。 [brewproj/homebrew-proj]

ちゃんと OSS プロジェクトとしてやっていければと思います。

[前の投稿]: https://ja.ngs.io/2014/05/07/zsh-debut/
[Boxen]: http://boxen.github.com/
[Homebrew]: http://brew.sh/
[Homebrew Cask]: http://caskroom.io/
[init.pp]: https://github.com/boxen/puppet-vmware_fusion/blob/master/manifests/init.pp#L9
[Formula]: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
[puppet-ruby]: https://github.com/boxen/puppet-ruby
[rubybuild.rb]: https://github.com/boxen/puppet-ruby/blob/c06526add39f11e5ec899c55483fee57c8497368/lib/puppet/provider/ruby/rubybuild.rb#L35
[nodenv]: https://github.com/wfarr/nodenv
[nodenv-install]: https://github.com/wfarr/nodenv/blob/master/libexec/nodenv-install#L72
[boxen-bottle-hook]: https://github.com/boxen/puppet-homebrew/blob/master/files/boxen-bottle-hooks.rb#L39
[Project Manifests]: https://github.com/boxen/our-boxen/tree/master/modules/projects#readme
[Tap]: https://github.com/Homebrew/homebrew/wiki/brew-tap
[brewproj/homebrew-proj]: https://github.com/brewproj/homebrew-proj
