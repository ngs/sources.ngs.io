---
title: CoffeeLint で該当行だけ設定を有効/無効化する
description: CoffeeLint で、コメントアウトで該当行だけ設定を有効/無効化する機能について
date: 2014-02-16 22:30
public: true
tags: CoffeeScript, CoffeeLint
---

他言語の lint だったらある機能なので、無いはずないだろうと思っても、ドキュメントではどこにも見当たらず、テストコードを見たら、実装されていました。

[test/test_comment_config.coffee on master](https://github.com/clutchski/coffeelint/blob/master/test/test_comment_config.coffee)

READMORE

```coffeescript
# coffeelint: disable=no_trailing_semicolons
a 'you get a semi-colon';
b 'you get a semi-colon';
# coffeelint: enable=no_trailing_semicolons
c 'everybody gets a semi-colon';
```

a, b は無視されるそうな。

逆も可能で、

```coffeescript
# coffeelint: enable=no_implicit_parens
a 'implicit parens here'
b 'implicit parens', 'also here'
# coffeelint: disable=no_implicit_parens
c 'implicit parens allowed here'
```

今度は、a, b が怒られ、c は無視される。


更に `enable` とだけ言うと、全部 (??) 有効化できる風。

```coffeescript
# coffeelint: disable=no_trailing_semicolons,no_implicit_parens
a 'you get a semi-colon';
b 'you get a semi-colon';
# coffeelint: enable
c 'everybody gets a semi-colon';
```

テストコードは無いですが、きっと `disable` もできるんでしょう。

これの有効範囲がどこまでなのか気になります。見た感じ、一度、有効/無効化した設定は、もう一度逆のことを設定してやらない限り、そのまま引き継がれるっぽいです。

[coffeelint.coffee#171 付近](https://github.com/clutchski/coffeelint/blob/master/src/coffeelint.coffee#L171) で実装されているようで、じっくり読書して理解を深めたいですが、今日は寝るので、今度調査します。
