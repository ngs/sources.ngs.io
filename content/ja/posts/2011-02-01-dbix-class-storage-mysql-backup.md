---
title: "DBIx::Class::Storage::DBI::mysql::backup"
description: "先月、CPAN に公開したモジュール DBIx::Class::Storage::DBI::mysql::backup の紹介です。 DBIx::Class::Schema::Versioned にある、backup_directory という設定 目は、設定すると backup メソッドをコールする..."
date: 2011-02-01T05:00:00+09:00
public: true
tags: ["backup", "cpan", "dbix::class", "mysql", "perl"]
---

先月、CPAN に公開したモジュール&nbsp;[DBIx::Class::Storage::DBI::mysql::backup](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI::mysql::backup) の紹介です。

<!--more-->

[DBIx::Class::Schema::Versioned](http://search.cpan.org/perldoc?DBIx::Class::Schema::Versioned)&nbsp;にある、`backup_directory`&nbsp;という設定項目は、設定すると `backup`&nbsp;メソッドをコールするだけで、設定したディレクトリにバックアップを作成してくれるのだろうな、と思いますが、実は、[SQLite](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI::SQLite) など ( 他の DBI は確認してません ) 、<span style="">[DBIx::Class::Storage::DBI](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI) のサブクラス側で各々実装するものらしく、MySQL で</span>&nbsp;`backup`&nbsp;メソッドをコールすると、以下の様に `die` してしまいます。

```
Can't locate object method "backup" via package "DBIx::Class::Storage::DBI"
    at /path/to/lib/site_perl/5.xx.x/DBIx/Class/Schema/Versioned.pm line 560.
```

[SYNOPSIS](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI::mysql::backup#SYNOPSIS)&nbsp;に書いた様に、<span style="font-family: monospace;">Storage::DBI::mysql::backup</span>&nbsp;を、Schema.pm (&nbsp;<span style="">DBIx::Class::Schema のサブクラス</span>&nbsp;) の&nbsp;`load_components`&nbsp;に加えて下さい。

```perl
package MyApp::Schema;
use base qw/DBIx::Class::Schema/;
 
our $VERSION = 0.001;
 
__PACKAGE__->load_classes(qw/CD Book DVD/);
__PACKAGE__->load_components(qw/
  Schema::Versioned
  Storage::DBI::mysql::backup
/);
__PACKAGE__->upgrade_directory("/path/to/var/upgrade");
__PACKAGE__->backup_directory("/path/to/var/backup");
```

これで&nbsp;`backup`&nbsp;メソッドをコールしても&nbsp;`die`&nbsp;しなくなりました。

```perl
my $schema = MyApp::Schema->connect(
  'DBI:mysql:myapp_db',
  'myapp_user',
  'myapp_pass' );
 
$schema->do_backup( 1 ); # これが必要
$schema->backup;
```

<span style="font-family: monospace;">backup_directory</span>&nbsp;で 設定したディレクトリに、_myapp_db-20110202-050441.sql_ という名前で、ダンプデータが作成されていると思います。

よかったら、是非、使ってみてください。

```bash
$ cpanm DBIx::Class::Storage::DBI::mysql::backup
```

or checkout from GitHub

```bash
$ git clone git://github.com/ngs/p5-dbix-class-storage-dbi-mysql-backup.git
$ cd p5-dbix-class-storage-dbi-mysql-backup
$ perl Makefile.PL
$ make test
$ make install
```

&nbsp;

テストコードを書くに当たって、[Test::mysqld](http://search.cpan.org/perldoc?Test::mysqld)&nbsp;というモジュールを使わせて頂きました。

