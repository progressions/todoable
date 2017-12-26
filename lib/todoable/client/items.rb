module Todoable
  class Client
    module Items
      # Creates a new Item with the given list_id and name on the Todoable server.
      #
      # @param [Hash] args the attributes to create the Item
      # @option args [Symbol] :list_id the id of a List
      # @option args [Symbol] :name the name of the new Item
      #
      # @return [Hash] an Item resource in Hash form
      #
      # @example
      #   Todoable::Client.create_item(list_id: '123-abc', name: 'Get dog food')
      #     {"name"=>"Get dog food", "finished_at"=>nil, "src"=>"...", "id"=>"987-zyx", "list_id"=>"123-abc"}
      #
      def create_item(args={})
        list_id = args[:list_id] || args["list_id"]
        name = args[:name] || args["name"]

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

      # Marks an Item as finished on the Todoable server.
      #
      # @param [Hash] args the attributes to identify the Item
      # @option args [Symbol] :list_id the id of a List
      # @option args [Symbol] :id the id of a Item
      #
      # @return [Boolean] returns `true` if request was successful
      #
      # @example
      #   Todoable::Client.finish_item(list_id: '123-abc', id: '987-zyx')
      #     true
      #
      def finish_item(args={})
        list_id = args["list_id"] || args[:list_id]
        id = args["id"] || args[:id]

        path = "lists/#{list_id}/items/#{id}/finish"
        request(method: :put, path: path)
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
      #   Todoable::Client.delete_item(list_id: '123-abc', id: '987-zyx')
      #     true
      #
      def delete_item(args={})
        list_id = args["list_id"] || args[:list_id]
        id = args["id"] || args[:id]

        path = "lists/#{list_id}/items/#{id}"
        request(method: :delete, path: path)
      end
    end
  end
end
