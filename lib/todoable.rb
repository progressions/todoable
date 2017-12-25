require 'rest-client'
require 'json'
require 'date'

require 'todoable/version'

module Todoable
  autoload :Client, 'todoable/client'
  autoload :List, 'todoable/list'
  autoload :Item, 'todoable/item'
  autoload :Configuration, 'todoable/configuration'

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
