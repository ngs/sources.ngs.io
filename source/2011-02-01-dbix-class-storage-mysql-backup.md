---
title: DBIx::Class::Storage::DBI::mysql::backup
description: 先月、CPAN に公開したモジュール DBIx::Class::Storage::DBI::mysql::backup の紹介です。 DBIx::Class::Schema::Versioned にある、backup_directory という設定 目は、設定すると backup メソッドをコールする...
date: 2011-02-01 05:00
public: true
tags: backup, cpan, dbix::class, mysql, perl
---

先月、CPAN に公開したモジュール&nbsp;[DBIx::Class::Storage::DBI::mysql::backup](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI::mysql::backup) の紹介です。

[DBIx::Class::Schema::Versioned](http://search.cpan.org/perldoc?DBIx::Class::Schema::Versioned)&nbsp;にある、`backup_directory`&nbsp;という設定項目は、設定すると `backup`&nbsp;メソッドをコールするだけで、設定したディレクトリにバックアップを作成してくれるのだろうな、と思いますが、実は、[SQLite](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI::SQLite) など ( 他の DBI は確認してません ) 、<span style="">[DBIx::Class::Storage::DBI](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI) のサブクラス側で各々実装するものらしく、MySQL で</span>&nbsp;`backup`&nbsp;メソッドをコールすると、以下の様に `die` してしまいます。

```
Can't locate object method "backup" via package "DBIx::Class::Storage::DBI"
&nbsp;&nbsp;&nbsp;&nbsp;at /path/to/lib/site_perl/5.xx.x/DBIx/Class/Schema/Versioned.pm line 560.
```

[SYNOPSIS](http://search.cpan.org/perldoc?DBIx::Class::Storage::DBI::mysql::backup#SYNOPSIS)&nbsp;に書いた様に、<span style="font-family: monospace;">Storage::DBI::mysql::backup</span>&nbsp;を、Schema.pm (&nbsp;<span style="">DBIx::Class::Schema のサブクラス</span>&nbsp;) の&nbsp;`load_components`&nbsp;に加えて下さい。

<script src="https://gist.github.com/825200.js?file=MyApp-Schema.pl"></script>

これで&nbsp;`backup`&nbsp;メソッドをコールしても&nbsp;`die`&nbsp;しなくなりました。

<script src="https://gist.github.com/825200.js?file=Snippet%2029.pl"></script>

<span style="font-family: monospace;">backup_directory</span>&nbsp;で 設定したディレクトリに、_myapp_db-20110202-050441.sql_ という名前で、ダンプデータが作成されていると思います。

よかったら、是非、使ってみてください。

<script src="https://gist.github.com/825200.js?file=Snippet%2030.sh"></script>

or checkout from GitHub

<script src="https://gist.github.com/825200.js?file=Snippet%2031.sh"></script>

&nbsp;

テストコードを書くに当たって、[Test::mysqld](http://search.cpan.org/perldoc?Test::mysqld)&nbsp;というモジュールを使わせて頂きました。

mysql.sock をテスト用に作成して、テストが完了すると、自動的に削除してくれるので、実際動いている DB に干渉せず、安心して開発ができました。