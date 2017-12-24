module Todoable
  autoload :Model, 'todoable/model'

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

    def finish
      self.class.finish(self)

      attributes = list.reload.items.select { |i| i["id"] == self["id"] }.first
      initialize(attributes)
    end

    def list
      unless @list
        @list = Todoable::List.get("id" => list_id)
      end

      @list
    end

    def finished?
      !!finished_at
    end

    class << self
      def create(list_id:, name:)
        path = "lists/#{list_id}/items"
        params = {
          'item' => {
            'name' => name
          }
        }
        attributes = client.post(path: path, params: params)

        attributes["list_id"] = list_id
        Todoable::Item.new(attributes)
      end

      def finish(args={})
        list_id = args["list_id"]
        id = args["id"]

        path = "lists/#{list_id}/items/#{id}/finish"
        client.request(method: :put, path: path)
      end

      def delete(args={})
        list_id = args["list_id"]
        id = args["id"]

        path = "lists/#{list_id}/items/#{id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
