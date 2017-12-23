module Todoable
  module List
    class << self
      def client
        @client ||= Todoable::Client.new
      end

      def all
        response = client.get(path: "lists")

        response["lists"]
      end

      def create(name:)
        params = {
          "list" => {
            "name" => name
          }
        }
        client.post(path: "listz", params: params)
      end

      def get(list_id:)
        client.get(path: "lists/#{list_id}")
      end

      def update(list_id:, name:)
        path = "lists/#{list_id}"
        params = {
          "list" => {
            "name" => name
          }
        }
        client.request(method: :patch, path: path, params: params)
      end

      def delete(list_id:)
        path = "lists/#{list_id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
