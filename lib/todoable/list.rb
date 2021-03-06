require "todoable/model"

module Todoable
  # Class to represent a Todoable List object, and to encapsulate
  # querying and updating List objects.
  #
  # @attr [String] id of the List on the Todoable server
  # @attr [String] name name of the List
  # @attr [Hash] attributes of the original List object
  #
  class List
    include Model

    # Returns the items belonging to this List.
    #
    # @return [Array<Item>] an Array of Todoable::Item objects
    #
    # @example
    #   list.items #=>
    #     [#<Todoable::Item @name="get dog food", @finished_at=nil, @src="...", @id="...", @list_id="...">,
    #     #<Todoable::Item @name="get cat food", @finished_at=nil, @src="...", @id="...", @list_id="...">,
    #     #<Todoable::Item @name="adopt dog", @finished_at=nil, @src="...", @id="...", @list_id="...">,
    #     #<Todoable::Item @name="adopt cat", @finished_at=nil, @src="...", @id="...", @list_id="...">]
    #
    def items
      reload unless attributes["items"]

      @_items ||= Array(attributes["items"]).map do |item|
        item["list_id"] = @id

        Todoable::Item.new(item)
      end

      @_items
    end

    # Reloads this List from the Todoable server.
    #
    # Any changes made to this List will be lost if not saved.
    #
    # @return [Item] a Todoable::Item
    #
    # @example
    #   list #=>
    #     #<Todoable::List @name="Shopping", @src="...", @id="...">
    #   list.name = "Grocery Shopping" # Don"t save this change
    #   list.reload #=>
    #     #<Todoable::List @name="Shopping", @src="...", @id="...">
    #
    def reload
      @items = nil

      attributes = self.class.client.get_list(id: id)
      initialize(attributes)

      self
    end

    # Saves changes to this List to the Todoable server, returning
    # +false+ on error.
    #
    # @return [Boolean] `true` if List saved successfully
    #
    # @example
    #   list #=>
    #     #<Todoable::List @name="Shopping", @src="...", @id="...">
    #   list.name = "Grocery Shopping" # Don"t save this change
    #   list.save
    #   list.reload #=>
    #     #<Todoable::List @name="Grocery Shopping", @src="...", @id="...">
    #
    def save
      save!
    rescue StandardError
      false
    end

    # Saves changes to this List to the Todoable server, raising
    # exceptions on error.
    #
    # @return [Boolean] `true` if List saved successfully
    #
    # @example
    #   list #=>
    #     #<Todoable::List @name="Shopping", @src="...", @id="...">
    #   list.name = "Grocery Shopping" # Don"t save this change
    #   list.save
    #   list.reload #=>
    #     #<Todoable::List @name="Grocery Shopping", @src="...", @id="...">
    #
    def save!
      self.class.update(id: id, name: name)

      reload
    end

    # Changes the name of the in-memory List object.
    #
    # Use `save` after changing it to persist the change to the
    # Todoable server.
    #
    # @return [String] new name
    #
    # @param [String] value the new name for this List object
    #
    def name=(value)
      @name = attributes[:name] = value
    end

    class << self
      # Fetches all available Lists from the Todoable server.
      #
      # @return [Array<List>] an Array of Todoable::List objects
      #
      # @example
      #   Todoable::List.all #=>
      #     [#<Todoable::List @name="Shopping", @src="...", @id="...">,
      #     #<Todoable::List @name="Christmas", @src="...", @id="...">]
      #
      def all
        lists = client.lists

        Array(lists).map do |list|
          Todoable::List.new(list)
        end
      end

      # Creates a new List object with the given name.
      #
      # @param [Symbol] name the name of the new List
      #
      # @return [List] a Todoable::List object
      #
      # @example
      #   Todoable::List.create(name: "Birthday List") #=>
      #     #<Todoable::List @name="Birthday List", @src="...", @id="...">
      #
      def create(name:)
        attributes = client.create_list(name: name)

        Todoable::List.new(attributes)
      end

      # Fetches a List from the Todoable server.
      #
      # @param [Symbol] id the id of the List
      #
      # @return [List] a Todoable::List object
      #
      # @example
      #   Todoable::List.get(id: "41cf70a2-...") #=>
      #     #<Todoable::List @name="Birthday List", @src="...", @id="41cf70a2-...">
      #
      def get(id:)
        list = client.get_list(id: id)

        Todoable::List.new(list)
      end

      # Saves changes to a given List to the Todoable server.
      #
      # Takes either an arguments Hash, including the id of the List and
      # its new name, or a List object itself.
      #
      # If a List object is passed, the name will be updated to the current name
      # of the List object.
      #
      # @param [Symbol] id the id of the List
      # @param [Symbol] name the new name of the List
      #
      # @return [List] a Todoable::List object
      #
      # @example
      #   Todoable::List.update(id: "41cf70a2-...", name: "Jenny"s Birthday List") #=>
      #     #<Todoable::List @name="Jenny"s Birthday List", @src="...", @id="41cf70a2-...">
      #
      # @example
      #   list = Todoable::List.get(id: "41cf70a2-...") #=>
      #     #<Todoable::List @name="Birthday List", @src="...", @id="41cf70a2-...">
      #   list.name = "Jenny"s Birthday List"
      #   Todoable::List.update(list) #=>
      #     #<Todoable::List @name="Jenny"s Birthday List", @src="...", @id="41cf70a2-...">
      #
      def update(id:, name:)
        list = client.update_list(id: id, name: name)

        Todoable::List.new(list)
      end

      # Deletes a List from the Todoable server.
      #
      # @param [Symbol] id the id of the List
      #
      # @example
      #   Todoable::List.delete(id: "41cf70a2-...") #=>
      #     true
      #   Todoable::List.get(id: "41cf70a2-...") #=>
      #     Todoable::NotFound
      #
      def delete!(id:)
        client.delete_list(id: id)
      end
    end
  end
end
