require 'rest-client'
require 'json'
require 'date'

require 'todoable/version'
require 'todoable/todoable'

module Todoable
  autoload :Client, 'todoable/client'
  autoload :List, 'todoable/list'
  autoload :Item, 'todoable/item'
end
