module Todoable
  module Item
    class << self
      def client
        @client ||= Todoable::Client.new
      end

      def create_item(list_id:, name:)
        path = "lists/#{list_id}/items"
        params = {
          "item" => {
            "name" => name
          }
        }
        client.post(path: path, params: params)
      end

      def finish_item(list_id:, item_id:)
        path = "lists/#{list_id}/items/#{item_id}/finish"
        client.request(method: :put, path: path)
      end

      def delete_item(list_id:, item_id:)
        path = "lists/#{list_id}/items/#{item_id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
