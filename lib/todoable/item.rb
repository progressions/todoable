module Todoable
  # Module to handle querying and creation of list items.
  #
  class Item
    attr_accessor :name, :src, :id

    def initialize(attributes={})
      attributes.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
    end

    class << self
      def client
        @client ||= Todoable::Client.new
      end

      def create(list_id:, name:)
        path = "lists/#{list_id}/items"
        params = {
          'item' => {
            'name' => name
          }
        }
        client.post(path: path, params: params)
      end

      def finish(list_id:, id:)
        path = "lists/#{list_id}/items/#{id}/finish"
        client.request(method: :put, path: path)
      end

      def delete(list_id:, id:)
        path = "lists/#{list_id}/items/#{id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
