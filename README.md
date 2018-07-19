# hateblo-mixed-contents-finder

[![Gem Version](https://badge.fury.io/rb/hateblo-mixed-contents-finder.svg)](https://badge.fury.io/rb/hateblo-mixed-contents-finder) [![Build Status](https://travis-ci.org/JunichiIto/hateblo-mixed-contents-finder.svg?branch=master)](https://travis-ci.org/JunichiIto/hateblo-mixed-contents-finder)

Helper scripts for Hatena blog HTTPS migration

はてなブログをHTTP配信からHTTPS配信に移行する際に利用すると便利なヘルパースクリプト集です。

参考: [自分のブログ（独自ドメインのはてなブログ）をHTTPS配信に切り替えました \- give IT a try](https://blog.jnito.com/entry/2018/07/16/084116)

## 免責事項

このスクリプトを使用して、何か問題が起きても作者は一切の責任を負いません。

## 動作環境

Ruby 2.3以上 + Mac環境で動作確認しています。

Ruby 2.2以下や、Windows環境で正常に動くかどうかは未検証です。

## セットアップ

以下のコマンドを使ってgemをインストールします。

```
gem install hateblo-mixed-contents-finder
```

過去記事の更新を実行する場合は`config.yml`の設定が必要になります。以下のページを参照して、自分のOAuthクレデンシャルを`config.yml`に設定してください。

https://github.com/kymmt90/hatenablog/blob/master/README.md

## 使用方法

ここでは `http://my-example.hatenablog.com` という架空のブログを対象とします。

### ブログ全体のhttpコンテンツを検証する

以下コマンドを実行すると、`result.txt`に検証結果（見つかったhttpコンテンツの一覧）が保存されます。ファイルはタブ区切りになっているので、Excel等にコピー＆ペーストで貼り付けることができます。

```
hateblo_mixed_contents_finder validate_all http://my-example.hatenablog.com
```

本文だけでなく、ページ全体を検証の対象にしたい場合は、`--entire-page`オプションを指定します。

```
hateblo_mixed_contents_finder validate_all http://my-example.hatenablog.com --entire-page
```

エントリが多くて時間がかかる場合は`--limit`オプションを指定します。

```
hateblo_mixed_contents_finder validate_all http://my-example.hatenablog.com --limit=5
```

#### 検証する要素や属性について

このタスクは以下の要素や属性を検証します。

- `<img>`要素のsrc属性およびsrcset属性
- `<source>`要素のsrc属性およびsrcset属性
- `<script>`要素のsrc属性
- `<video>`要素のsrc属性
- `<audio>`要素のsrc属性
- `<iframe>`要素のsrc属性
- `<embed>`要素のsrc属性
- rel属性にstylesheetが指定されている`<link>`要素のhref属性
- `<form>`要素のaction属性
- `<object>`要素のdata属性

参考: https://smdn.jp/works/tools/HatenaBlogTools/

#### 制限事項

このタスクではサーバーから返却されたHTMLを静的解析するだけです。そのため、JavaScriptやCSSの内部で外部のリソースをHTTPでリクエストしている場合はhttpコンテンツを検出できません。

### 特定のエントリのhttpコンテンツを検証する

以下のコマンドを実行すると、特定のエントリのhttpコンテンツを検証します。検証結果は標準出力に出力されます。

```
hateblo_mixed_contents_finder validate_entry http://my-example.hatenablog.com/2018/07/17/075334
```

本文だけでなく、ページ全体を検証の対象にしたい場合は、`--entire-page`オプションを指定します。

```
hateblo_mixed_contents_finder validate_entry http://my-example.hatenablog.com/2018/07/17/075334 --entire-page
```

### 過去記事に対して無変更で「更新」だけを実行する

`invalid_entries.txt`というテキストファイルに更新したいエントリのURLを行区切りで記述します。URLが重複するとそのぶん繰り返し更新が走るため、重複しないように記述する方が望ましいです。

```
http://my-example.hatenablog.com/2018/07/17/075334
http://my-example.hatenablog.com/2018/07/13/123434
http://my-example.hatenablog.com/2018/06/27/053436
```

また、前述の「セットアップ」に書いた`config.yml`も設定してください。

NOTE: 予期せぬ問題が起きてエントリの内容が失われた場合に備え、全エントリを事前に[バックアップ](http://staff.hatenablog.com/entry/2014/08/22/180000)しておくことをお勧めします。

準備ができたら、以下のコマンドを実行します。

```
hateblo_mixed_contents_finder update_all
```

実行するかどうかの確認を求められるので、実行する場合は`yes`を入力してください。

```
[WARNING] Please backup your entries before update!!
Do you update 3 entries? [yes|no]: yes
```

## License
MIT License.