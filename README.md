# Todoable

## Summary

This was a coding assignment for Teachable. I've built gems like this in the
past, so I modeled it more or less on how I approached those.

To configure the gem, I've provided a Configuration class with a few simple
methods which can be called to assign username and password. In a
production environment, we'd probably store the username and password in
environment variables, so they don't need to be explicitly included in
code anywhere.

My first approach was the simplest--just to build the most basic wrapper around
the API, which would handle and return the Hash objects the API uses.

Then I dug in a little deeper, building out some model-like behaviors for the
List and Item classes, more or less inspired by ActiveRecord.

The final approach simplified those a bit, and made sure you can use the
Todoable::Client by itself if you wish for a more functional approach,
just passing around data. If you're looking for a more OOP perspective, the
List and Item classes provide that.

## Dependencies

- ActiveSupport
- RestClient

## Installation

This is not a gem intended for general consumption, but if you do need to
install it, you can add this line to your application's Gemfile:

```ruby
gem 'todoable', git: "https://github.com/progressions/todoable"
```

And then execute:

    $ bundle

## Quick Start Example

```ruby
require "todoable"

Todoable.configuration do |c|
  c.username = "username"
  c.password = "password"
end

# Fetch all lists from the server.
Todoable::List.all

#=> [#<Todoable::List:0x007f875ce78390 @attributes={"name"=>"Grocs", "src"=>"http://todoable.teachable.tech/api/lists/41cf70a2-9251-42f7-b8d1-c0a47ec58629", "id"=>"41cf70a2-9251-42f7-b8d1-c0a47ec58629"}, @name="Grocs", @src="http://todoable.teachable.tech/api/lists/41cf70a2-9251-42f7-b8d1-c0a47ec58629", @id="41cf70a2-9251-42f7-b8d1-c0a47ec58629">, #<Todoable::List:0x007f875ce788b8 @attributes={"name"=>"Death List", "src"=>"http://todoable.teachable.tech/api/lists/70679c05-65c6-4023-9841-d72fe804a0e2", "id"=>"70679c05-65c6-4023-9841-d72fe804a0e2"}, @name="Death List", @src="http://todoable.teachable.tech/api/lists/70679c05-65c6-4023-9841-d72fe804a0e2", @id="70679c05-65c6-4023-9841-d72fe804a0e2">

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/progressions/todoable.

## Documentation

Documentation can be generated with:

    $ yard doc -m markdown

