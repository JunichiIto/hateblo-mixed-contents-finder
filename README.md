# hateblo-mixed-contents-finder

Helper scripts for Hatena blog HTTPS migration

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hateblo-mixed-contents-finder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hateblo-mixed-contents-finder

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JunichiIto/hateblo-mixed-contents-finder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dev::Gem::Sandbox project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/JunichiIto/hateblo-mixed-contents-finder/blob/master/CODE_OF_CONDUCT.md).

----

# hateblo-mixed-contents-finder

はてなブログをHTTP配信からHTTPS配信に移行する際に利用すると便利なヘルパースクリプト集です。

参考: [自分のブログ（独自ドメインのはてなブログ）をHTTPS配信に切り替えました \- give IT a try](https://blog.jnito.com/entry/2018/07/16/084116)

## 免責事項

このスクリプトを使用して、何か問題が起きても作者は一切の責任を負いません。

## 動作環境

Ruby 2.5.1 + Mac環境で動作確認しています。

Ruby 2.4以下や、Windows環境で正常に動くかどうかは未検証です。

## セットアップ

[Bundler](https://bundler.io/)を使ってgemをインストールします。

```
bundle install
```

テスト（RSpec）がパスすればOKです。

```
bundle exec rspec
```

過去記事の更新を実行する場合は`config.yml`の設定も必要になります。以下のページを参照して、自分のOAuthクレデンシャルを`config.yml`に設定してください。

https://github.com/kymmt90/hatenablog/blob/master/README.md

## 使用方法

ここでは `http://my-example.hatenablog.com` という架空のブログを対象とします。

### ブログ全体のhttpコンテンツを検証する

以下コマンドを実行すると、`result.txt`に検証結果（見つかったhttpコンテンツの一覧）が保存されます。ファイルはタブ区切りになっているので、Excel等にコピー＆ペーストで貼り付けることができます。

```
bundle exec rake 'validate_all[http://my-example.hatenablog.com]'
```

本文だけでなく、ページ全体を検証の対象にしたい場合は、第2引数に`1`を指定します。

```
bundle exec rake 'validate_all[http://my-example.hatenablog.com,1]'
```

エントリが多くて時間がかかる場合は第3引数に上限値を指定します。

```
bundle exec rake 'validate_all[http://my-example.hatenablog.com,1,5]'
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

### 特定のページのhttpコンテンツを検証する

以下のコマンドを実行すると、特定のページのhttpコンテンツを検証します。検証結果は標準出力に出力されます。

```
bundle exec rake 'validate_page[http://my-example.hatenablog.com/2018/07/17/075334]'
```

本文だけでなく、ページ全体を検証の対象にしたい場合は、第2引数に`1`を指定します。

```
bundle exec rake 'validate_page[http://my-example.hatenablog.com/2018/07/17/075334,1]'
```

### 過去記事に対して無変更で「更新」だけを実行する

`invalid_entries.txt`というテキストファイルに更新したいページのURLを行区切りで記述します。URLが重複するとそのぶん繰り返し更新が走るため、重複しないように記述する方が望ましいです。

```
http://my-example.hatenablog.com/2018/07/17/075334
http://my-example.hatenablog.com/2018/07/13/123434
http://my-example.hatenablog.com/2018/06/27/053436
```

また、前述の「セットアップ」に書いた`config.yml`も設定してください。

NOTE: 予期せぬ問題が起きてエントリの内容が失われた場合に備え、全エントリを事前に[バックアップ](http://staff.hatenablog.com/entry/2014/08/22/180000)しておくことをお勧めします。

準備ができたら、以下のコマンドを実行します。

```
bundle exec rake update_all
```

実行するかどうかの確認を求められるので、実行する場合は`yes`を入力してください。

```
[WARNING] Please backup your entries before update!!
Do you update 3 entries? [yes|no]: yes
```

## License
MIT License.