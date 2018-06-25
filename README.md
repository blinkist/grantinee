# Grantinee

Grantinee is a library to manage your database permissions. It supports MySQL and Postgres, allowing for granular per-table, and per-column permission setting. Tight and explicit permissions, instead of "allow all access" approach, may enhance the data security in your app, and make the GDPR compliance easier for multi-user databases (like when you have a service-oriented architecture).

[![Gem Version](https://badge.fury.io/rb/grantinee.svg)](https://badge.fury.io/rb/grantinee)
[![CircleCI](https://circleci.com/gh/blinkist/grantinee/tree/master.svg?style=svg&circle-token=be47ddf3e39aa44795797ae40c06bd42144ad888)](https://circleci.com/gh/blinkist/grantinee/tree/master)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grantinee'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grantinee

## Usage

Before you start using Grantinee you need to configure it.

### User ActiveRecord connection (Rails)

As long as you use Grantinee's executable, everything is plug-and-play. Just make sure that you operate in the right environment, and your database user has granting rights (most likely it won't have them for security reasons). Simply run:

    $ RAILS_ENV=production bundle exec grantinee

If you'd like to use Grantinee programmatically as a library, you will need to create two things:

```ruby
# Create or pass an existing logger
Grantinee.logger = ::Logger.new(STDOUT)

# (optional) Manually call ActiveRecord detection
Grantinee::Engine.detect_active_record_connection!
```

### Custom database connection

You may create an initializer, providing each information separately:

```ruby
Grantinee.configure do |c|
  c.engine   = :mysql

  c.username = 'root'
  c.password = 'password'
  c.hostname = 'localhost'
  c.port     = 3306
  c.database = 'database_name'
end
```

Alternatively you can use the database URL (looking at you Heroku):

```ruby
Grantinee.configure do |c|
  c.engine = :mysql
  c.url    = "mysql://root:password@localhost:3306/database_name"
end
```

In case you do not want to or cannot use an initializer, you can save your configuration in a standalone ruby file, which you pass as an argument in the command line, i.e.:

    $ grantinee -c ./config/grantinee.yml

### Command line options

Grantinee provides flexible configuration options through the command line parameters, you can easily review them, by running:

    $ grantinee --help

```
Usage: grantinee [options]
    -h, --help                       Displays help
    -v, --verbosity=LEVEL            Set verbosity level to debug, info, warn, error, fatal, or unknown (default: warning)
    -r, --require=FILE               Application boot file path (default: ./config/environment.rb)
    -f, --file=FILE                  Permission definitions file path (default: ./Grantinee)
    -c, --config=FILE                Database configuration file path
```

## Permissions definition

You can use the DSL to quickly set up your permissions:

```ruby
on "database_name" do
  # User on any host
  user :username do
    select :users, [ :id, :name ]
    insert :users, [ :tracking_id ]
    update :users, [ :tracking_id ]

    all :articles
  end

  # Or user on a specific host
  user 'username@example.org' do
    select :users, [ :id, :name ]
    insert :users, [ :tracking_id ]
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/blinkist/grantinee. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Grantinee project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/grantinee/blob/master/CODE_OF_CONDUCT.md).
