# SimpleUsecase

SimpleUsecase provides a simple yet effective interface for writing UseCase
classes, that is, classes that handle a specific, 'high level' domain task.
UseCases can be nested, and perform their work in three distinct steps: a
'prepare' phase, a 'commit!' phase, and an 'after_commit' phase.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_usecase'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_usecase

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/simple_usecase/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
