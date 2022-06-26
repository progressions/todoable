# Todoable

## Summary

This is a Ruby client used to interact with the API for a todo-list server.

It encapsulates the API calls necessary to perform the following actions:

- create a new Todo List
- update the name of a list
- read a list, with its name and associated items
- delete a list
- add an unfinished item to a list
- mark an item from a list as finished
- delete an item from a list

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

# Fetch all lists from the server. Uses the configured username and password
# unless you supply overrides.

client = Todoable::Client.new

client.create_list(name: "Groceries")

#=> {"name"=>"Groceries", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}

lists = client.lists

#=> [{"name"=>"Groceries", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}, {"name"=>"Death List", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}, {"name"=>"Shopping", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}, {"name"=>"Birthday List", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}]

client.update_list(id: list["id"], name: "Buy Groceries")

#=> {"name"=>"Buy Groceries", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}

item = client.create_item

#=> {"name"=>"get dog food", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/98b2510c-0eb7-4316-bfef-d38c762b1ffb/items/bcf6443f-7231-4064-a607-667369792a77", "id"=>"bcf6443f-7231-4064-a607-667369792a77", "list_id"=>"98b2510c-0eb7-4316-bfef-d38c762b1ffb"}

# When you fetch a List with `get_list`, it includes the List's associated Items.

client.get_list(id: list["id"])

#=> {"name"=>"Groceries", "items"=>[{"name"=>"get dog food", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/.../items/...", "id"=>"..."}], "id"=>"..."}

client.finish_item(list_id: list["id"], id: item["id"])

client.delete_item(list_id: list["id"], id: item["id"])

client.delete_list(id: list["id"])

```

### Models

To make use of the optional List and Item model classes:

```ruby
require "todoable/models"

Todoable::List.create(name: "Shopping")

#=> #<Todoable::List:0x007f8e74b6aa80 ...>

```

See the documentation for more on the List and Item model classes.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/progressions/todoable.

## Documentation

Documentation can be generated with:

    $ yard doc -m markdown

