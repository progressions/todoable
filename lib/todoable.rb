require "rest-client"
require "json"
require "date"
require "active_support/core_ext/hash/indifferent_access"

require "todoable/version"

# Base module to govern querying the Todoable API to manage to-do Lists
# and their Items.
#
module Todoable
  autoload :Configuration, "todoable/configuration"
  autoload :Client, "todoable/client"
  autoload :List, "todoable/list"
  autoload :Item, "todoable/item"

  class << self
    # Returns a +Configuration+ object which can be used to save
    # +username+ and +password+ for the Todoable client.
    #
    # @example
    #   Todoable.configuration.username = "my_username"
    #   Todoable.configuration.password = "password"
    #
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields a configuration object which can be used in block
    # format to configure the Todoable client.
    #
    # @example
    #   Todoable.configure do |c|
    #     c.username = "my_username"
    #     c.password = "password"
    #   end
    #
    def configure
      yield(configuration)
    end
  end
end
