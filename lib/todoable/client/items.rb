module Todoable
  class Client
    module Items
      def create(list_id:, name:)
        path = "lists/#{list_id}/items"
        params = {
          'item' => {
            'name' => name
          }
        }
        attributes = post(path: path, params: params)

        attributes["list_id"] = list_id

        attributes
      end

      def finish(args={})
        list_id = args["list_id"]
        id = args["id"]

        path = "lists/#{list_id}/items/#{id}/finish"
        request(method: :put, path: path)
      end

      def delete(args={})
        list_id = args["list_id"]
        id = args["id"]

        path = "lists/#{list_id}/items/#{id}"
        request(method: :delete, path: path)
      end
    end
  end
end
