---
title: JSON から Objective-C のリテラルに変換する
description: JSON から Objective-C のリテラルに変換する
date: 2012-07-26 00:00
public: true
tags: objective-c, json, javascript
---

Xcode 4.4 からNSDictionary, NSArray, NSNumber が簡単にかけるようになったので、ユニットテストのデータなど、コードに直接書こうと思います。
[http://clang.llvm.org/docs/ObjectiveCLiterals.html](http://clang.llvm.org/docs/ObjectiveCLiterals.html)

手で作るのも面倒なので、JSON2.js の stringify メソッドをカスタマイズして、JS オブジェクトから Objective-C リテラルの文字列を返却するようなスクリプトを作りました。

READMORE

Node.js からは以下の様に標準入力で JSON を渡すと、標準出力します。

```sh
$ node Dictionary.js < test.js
# with cURL
$ curl 'http://itunes.apple.com/search?term=Path&entity=software' | node Dictionary.js
```

ブラウザからも、`if(process)` の中を削れば Dictionary.stringify メソッドで実行できます。

```js
Dictionary.stringify({ a:1, b:"Hello", c:[1,2,3] }, null, "  ");
```

```js
var Dictionary;
if (!Dictionary) {
    Dictionary = {};
}

(function () {
    'use strict';

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof String.prototype.toDictionary !== 'function') {

        String.prototype.toDictionary      =
            Number.prototype.toDictionary  =
            Boolean.prototype.toDictionary = function (key) {
                return "@" + this.valueOf();
            };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {
        escapable.lastIndex = 0;
        return escapable.test(string) ? '@"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string'
                ? c
                : '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' : '@"' + string + '"';
    }



    function str(key, holder) {

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

        if (value && typeof value === 'object' &&
                typeof value.toDictionary === 'function') {
            value = value.toDictionary(key);
        }

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

            return isFinite(value) ? "@" + String(value) : 'nil';

        case 'boolean':
        case 'null':

            return "@" + String(value);

        case 'object':

            if (!value) {
                return 'nil';
            }

            gap += indent;
            partial = [];

            if (Object.prototype.toString.apply(value) === '[object Array]') {

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

                v = partial.length === 0
                    ? '@[]'
                    : gap
                    ? '@[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']'
                    : '@[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if (typeof rep[i] === 'string') {
                        k = rep[i];
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

                for (k in value) {
                    if (Object.prototype.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

            v = partial.length === 0
                ? '@{}'
                : gap
                ? '@{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}'
                : '@{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

    if (typeof Dictionary.stringify !== 'function') {
        Dictionary.stringify = function (value, replacer, space) {

            var i;
            gap = '';
            indent = '';

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

            } else if (typeof space === 'string') {
                indent = space;
            }

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('Dictionary.stringify');
            }

            return str('', {'': value});
        };
    }
    
}());

if(process) {
  var data = "";
  process.stdin.resume();
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', function (chunk) {
    data += chunk;
  });
  process.stdin.on('end', function () {
    process.stdout.write(Dictionary.stringify(JSON.parse(data), null, "  "));
  });
}
```