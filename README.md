# Capistrano::Deploylock

[![Gem Version](https://badge.fury.io/rb/capistrano-deploylock.svg)](http://badge.fury.io/rb/capistrano-deploylock)

デプロイした環境を一日だけロックする

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-deploylock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-deploylock

## Usage

    add config/deploy.rb

    require 'capistrano/deploylock'

~~~
before "deploy:lock:start", "deploy:lock:check"
before "deploy", "deploy:lock:start"
~~~

## なぜ作ったのか
1. デプロイしていいか聞きまわるの面倒くさい　とはいえ一人ずつサーバ作って管理するというのも面倒
1. デプロイしていいかその環境自体に聞けばｲｲｼﾞｬﾝという発想
1. 要はlockファイルさえなければあらゆる環境に自由にデプロイしたい. lockファイル作っとかないほうが悪い状態が効率が良い

## 機能仕様
1. staging専用
1. `` cap deploy`` 後、 自分以外のユーザが24hデプロイできないようになる
1. `` cap deploy:lock:end`` で取り消し可能

## 詳細仕様
1. `` cap deploy``  時にdeploy_lock.ymlファイルをshared/systemに作成(`` cap deploy:lock:start`` フック)
1. `` cap deploy:lock:start `` 時にdeploy_lock.ymlファイルがshared/systemにないか確認(`` cap deploy:lock:start`` フック)
1. lockファイルが存在する場合
　* 自分が作ったやつなら無視して、`` expired_at`` を今から24h後に更新
　* 他人が作ったやつで`` expired_at > Time.now　`` ならロック

* deploy_lock.ymlにはデプロイしたuser名と, 現在時間の24時間後が、expired_at時間として入る


## cmd 


* ロック開始

~~~
 % bundle exec cap $STAGE  deploy:lock:start
~~~

* ロック終了

~~~
 % bundle exec cap $STAGE  deploy:lock:end
~~~

* ロック確認

~~~
 % bundle exec cap $STAGE  deploy:lock:check
~~~



## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-deploylock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
