module Todoable
  class Client
    # Methods associated with querying the Todoable server around Items.
    #
    module Items
      # Creates a new Item with the given list_id and name on the Todoable
      # server.
      #
      # @param [Symbol] list_id the id of a List
      # @param [Symbol] name the name of the new Item
      #
      # @return [Hash] an Item resource in Hash form
      #
      # @example
      #   Todoable::Client.create_item(list_id: "123-abc", name: "dog food") #=>
      #     {"name"=>"dog food", "finished_at"=>nil, "src"=>"...",
      #     "id"=>"987-zyx", "list_id"=>"123-abc"}
      #
      def create_item(list_id:, name:)
        path = "lists/#{list_id}/items"
        params = {
          "item" => {
            "name" => name
          }
        }
        attributes = post(path: path, params: params)
        attributes.merge({"list_id" => list_id })
      end

      # Marks an Item as finished on the Todoable server.
      #
      # @param [Symbol] list_id the id of a List
      # @param [Symbol] id the id of a Item
      #
      # @return [Boolean] returns `true` if request was successful
      #
      # @example
      #   Todoable::Client.finish_item(list_id: "123-abc", id: "987-zyx") #=>
      #     true
      #
      def finish_item(list_id:, id:)
        path = "lists/#{list_id}/items/#{id}/finish"
        request(method: :put, path: path)
      end

      # Deletes an Item from the Todoable server.
      #
      # The Todoable server raises a NotFound exception if the
      # Item is already finished.
      #
      # @param [Symbol] list_id the id of a List
      # @param [Symbol] id the id of a Item
      #
      # @return [Boolean] returns `true` if request was successful
      #
      # @example
      #   Todoable::Client.delete_item(list_id: "123-abc", id: "987-zyx") #=>
      #     true
      #
      def delete_item(list_id:, id:)
        path = "lists/#{list_id}/items/#{id}"
        request(method: :delete, path: path)
      end
    end
  end
end
