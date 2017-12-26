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
  # autoload :List, "todoable/list"
  # autoload :Item, "todoable/item"

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
