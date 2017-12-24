module Todoable
  autoload :Model, 'todoable/model'

  # Class to represent a Todoable List object, and to encapsulate
  # querying and updating List objects.
  #
  class List
    include Model

    # Returns the items belonging to this List.
    #
    # @return [Array] an Array of Todoable::Item objects
    #
    # @example
    #   list.items =>
    #     [#<Todoable::Item @name="get dog food", @finished_at=nil, @src="...", @id="...", @list_id="...">,
    #     #<Todoable::Item @name="get cat food", @finished_at=nil, @src="...", @id="...", @list_id="...">,
    #     #<Todoable::Item @name="adopt dog", @finished_at=nil, @src="...", @id="...", @list_id="...">,
    #     #<Todoable::Item @name="adopt cat", @finished_at=nil, @src="...", @id="...", @list_id="...">]
    #
    def items
      unless @items
        response = self.class.get(self)
        @items = Array(response["items"]).map do |item|
          item["list_id"] = @id

          Item.new(item)
        end
      end

      @items
    end

    # Reloads this List from the Todoable server.
    #
    def reload
      @items = nil

      initialize(self.class.get(self))
    end

    # Saves changes to this List to the Todoable server.
    #
    def save!
      self.class.update(id: id, name: name)
    end

    class << self
      # Fetches all available Lists from the Todoable server.
      #
      # @example
      #   Todoable::List.all =>
      #     [#<Todoable::List @name="Shopping", @src="...", @id="...">,
      #     #<Todoable::List @name="Christmas", @src="...", @id="...">]
      #
      def all
        response = client.get(path: 'lists')

        Array(response['lists']).map do |list|
          List.new(list)
        end
      end

      # Creates a new List object with the given name.
      #
      def create(args={})
        name = args[:name] || args["name"]

        params = {
          'list' => {
            'name' => name
          }
        }
        attributes = client.post(path: 'lists', params: params)

        Todoable::List.new(attributes)
      end

      # Fetches a List from the Todoable server.
      #
      def get(args={})
        id = args["id"]
        list = client.get(path: "lists/#{id}")
        list["id"] = id

        Todoable::List.new(list)
      end

      # Saves changes to a given List to the Todoable server.
      #
      def update(id:, name:)
        path = "lists/#{id}"
        params = {
          'list' => {
            'name' => name
          }
        }
        client.request(method: :patch, path: path, params: params)
      end

      # Deletes a List from the Todoable server.
      #
      def delete(args={})
        id = args["id"]

        path = "lists/#{id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
