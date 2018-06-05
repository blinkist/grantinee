# Grantinee

Grantinee is a library to manage your database permissions. It supports MySQL and Postgres, allowing for granular per-table, and per-column permission setting. Tight and explicit permissions, instead of "allow all access" approach, may enhance the data security in your app, and make the GDPR compliance easier for multi-user databases (like when you have a service-oriented architecture).

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

### Configure the connection with database

Using Rails? Woop woop, you don't, have to do anything more, Grantinee is plug-and-play, as long as your database.yml user has granting permissions (probably doesn't, though).

You can specify connection in a block, providing each information separately:

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

In case you do not want to or cannot use an initializer, you can save your configuration in a YAML file:

```yaml
engine:    mysql
username:  root
password:  password
hostname:  localhost
port:      3306
database:  database_name
```

You can use it then by providing the command line argument, i.e. `grantinee -c config/grantinee.yml`

### Permissions definition

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
