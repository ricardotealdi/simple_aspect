# SimpleAspect

[![Build Status](https://travis-ci.org/ricardotealdi/simple_aspect.svg?branch=master)](https://travis-ci.org/ricardotealdi/simple_aspect)

Simple AOP implementation for Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_aspect'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_aspect

## Usage

```ruby
require 'simple_aspect'

class Worker
  extend SimpleAspect

  aspect_around :perform do |*args, &original|
    puts "Before: \"args\" => #{args}"
    result = original.call # Don't forget to `call` the original implementation
    puts "After: \"result\" => #{result}, \"args\" => #{args}"
  end

  def perform(n1, n2)
    puts 'doing something'
    yield if block_given?
    n1 + n2
  end
end
```

or

```ruby
require 'simple_aspect'

class Worker
  extend SimpleAspect

  aspect_around :perform, :around_perform

  def perform(n1, n2)
    puts 'doing something'
    yield if block_given?
    n1 + n2
  end

  private

  def around_perform(*args)
    puts "Before: \"args\" => #{args}"
    result = yield # Don't forget to execute the original implementation
    puts "After: \"result\" => #{result}, \"args\" => #{args}"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ricardotealdi/simple_aspect.
