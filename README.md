# Blurhash

This is a Ruby binding for the Blurhash library. With it you can encode an image as a small string that can be saved in the database, returned in API responses, and displayed as a blurred preview before the real image loads.

Blurhash is written by [Dag Ågren](https://github.com/DagAgren).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blurhash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blurhash

## Usage

To generate the blurhash string from an image file, you need to read in the image pixel data yourself, for example with RMagick:

```ruby
require 'blurhash'
require 'rmagick'

image = Magick::ImageList.new('foo.png')

blurhash = Blurhash.encode(image.columns, image.rows, image.export_pixels)
puts blurhash

pixels = Blurhash.decode(blurhash, image.columns, image.rows)
# pixels can be converted to image with gem minimagick
```

To display the visual component once you have the blurhash string, you need another library in JavaScript, Swift, Kotlin and so on. Fore more information, see [the original blurhash repository](https://github.com/woltapp/blurhash).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Gargron/blurhash. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Blurhash project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Gargron/blurhash/blob/master/CODE_OF_CONDUCT.md).
