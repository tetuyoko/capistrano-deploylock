# Capistrano::Deploylock

[![Gem Version](https://badge.fury.io/rb/capistrano-deploylock.svg)](http://badge.fury.io/rb/capistrano-deploylock)

lock set to deployed server for 1 day.

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

## Why
1. to ask people 'Can I deploy this server?', is almost Time-consuming.
1. not ask peoble, but sever.
1. no lockfile sets, you can always deploy. deployment runs quickly.

## Feauture
1. after you run `` cap deploy`` command, lockfile has set to deployed server, then anyone cannot deploy 24h except you.
1. but `` cap deploy:lock:end`` command abort lock.
1. when deploy, if lockfile exits, 

　* it is maked by yourself,  `` expired_at`` has update to 24h after by now.
　* it is not maked by yourself, `` expired_at`` not over current time, you can deploy.
　* it is not maked by yourself, `` expired_at`` over current time, you can deploy.


## cmd 

* lock start

~~~
 % bundle exec cap $STAGE  deploy:lock:start
~~~

* lock end

~~~
 % bundle exec cap $STAGE  deploy:lock:end
~~~

* lock check

~~~
 % bundle exec cap $STAGE  deploy:lock:check
~~~



## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-deploylock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
