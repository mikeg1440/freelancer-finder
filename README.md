# FreelancerFinder

Freelancer-Finder is a CLI application written in ruby that scrapes the website Freelancer.com for job listings and displays the jobs information to the user.  By default it automatically scrapes the first 50 listings and gives the user the option of viewing the most recent listings, scraping more listings, search listings for a specific word or phrase and filter by pay range.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'freelancer_finder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install freelancer_finder

## Usage

  You can run the executable file found in the `bin` directly or add the `bin/freelancer_finder` file to your PATH.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/freelancer_finder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
