module Todoable
  autoload :Model, 'todoable/model'

  # Module to handle querying and creation of list items.
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
