module Todoable
  # Include this module to make use of model-like classes for the
  # List and Item.
  #
  autoload :List, "todoable/list"
  autoload :Item, "todoable/item"
end
