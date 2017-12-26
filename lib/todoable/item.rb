module Todoable
  autoload :Model, "todoable/model"

  # Class to represent a Todoable Item object, and to encapsulate
  # querying and updating Item objects.
  #
  # @attr [String] id id of the List on the Todoable server
  # @attr [String] list_id id of the List to which this Item belongs
  # @attr [String] name name of the Item
  # @attr [Hash] attributes of the original Item object
  #
  class Item
    include Model

    attr_accessor :id, :list_id, :name, :finished_at

    # Mark this Item as finished on the Todoable server, and re-initialize
    # this Item object by reloading its associated List and finding its
    # new attributes.
    #
    # We reload the List and its Items in order to correctly set the
    # `finished_at` attribute on this Item object so it matches the
    # server.
    #
    # Raises an exception if the Item is already finished.
    #
    # @return [Boolean] returns `true` if request was successful
    #
    # @example
    #   item.finish! #=>
    #     true
    #   item.finished? #=>
    #     true
    #
    # @example
    #   item.finished? #=>
    #     true
    #   item.finish #=>
    #     Todoable::ItemAlreadyFinished: Item: `get dog food` is already
    #     finished
    #
    def finish!
      raise ItemAlreadyFinished.new("Item: `#{name}` is already finished") if finished?

      if self.class.finish(self)
        attributes = list.reload.items.select { |i| i["id"] == self["id"] }.first
        initialize(attributes)

        true
      else
        false
      end
    end

    # Returns the List object associated with this Item. Lazy-loads the
    # List object from the Todoable server if it has not already been loaded.
    #
    # @return [List] the list object associated with this Item
    #
    # @example
    #   item.list #=>
    #     #<Todoable::List:0x007f972e5ac1a8 ...>
    #
    def list
      return nil unless list_id

      @list ||= Todoable::List.get("id" => list_id)
    end

    # Returns true if this Item object has a `finished_at` date.
    #
    # @return [Boolean] returns true if this Item object has a
    # `finished_at` date
    #
    def finished?
      !finished_at.nil?
    end

    class << self
      # Creates a new Item associated with a given List, and instantiates a
      # new Item object based on it.
      #
      # @param [Hash] args the attributes to create the Item
      # @option args [Symbol] :list_id the id of the List to associate this
      # Item with
      # @option args [Symbol] :name the name of the new Item
      #
      # @return [Item] a Todoable::List object
      #
      # @example
      #   Todoable::Item.create(list_id: "123-abc", name: "get dog food") #=>
      #     #<Todoable::Item @name="get dog food", @finished_at=nil, @src="...",
      #     @list_id="123-abc", @id="...">
      #
      def create(args = {})
        list_id = args[:list_id] || args["list_id"]
        name = args[:name] || args["name"]

        attributes = client.create_item(list_id: list_id, name: name)
        Todoable::Item.new(attributes)
      end

      # Marks an Item as finished on the Todoable server.
      #
      # The Todoable server raises a NotFound exception if the
      # Item is already finished.
      #
      # @param [Hash] args the attributes to identify the Item
      # @option args [Symbol] :list_id the id of a List
      # @option args [Symbol] :id the id of a Item
      #
      # @return [Boolean] returns `true` if request was successful
      #
      # @example
      #   Todoable::Item.finish(list_id: "123-abc", id: "987-zyx") #=>
      #     true
      #
      def finish(args = {})
        client.finish_item(args)
      end

      # Deletes an Item from the Todoable server.
      #
      # @param [Hash] args the attributes to identify the Item
      # @option args [Symbol] :list_id the id of a List
      # @option args [Symbol] :id the id of a Item
      #
      # @return [Boolean] returns `true` if request was successful
      #
      # @example
      #   Todoable::Item.delete(list_id: "123-abc", id: "987-zyx") #=>
      #     true
      #
      def delete(args = {})
        client.delete(args)
      end
    end
  end
end
