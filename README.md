# Capistrano::Deploylock

TODO: Write a gem description

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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-deploylock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
