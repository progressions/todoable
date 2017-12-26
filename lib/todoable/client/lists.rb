module Todoable
  class Client
    # Methods associated with querying the Todoable server around Lists.
    #
    module Lists
      # Fetches all available Lists from the Todoable server.
      #
      # @return [Array<Hash>] an Array of List resources in Hash form
      #
      # @example
      #   Todoable::Client.lists #=>
      #     [{"name"=>"Groceries", "src"=>"...", "id"=>"..."},
      #     {"name"=>"Shopping", "src"=>"...", "id"=>"..."}]
      #
      def lists
        response = get(path: "lists")

        response["lists"]
      end

      # Creates a new List object with the given name.
      #
      # @param [Hash] args the attributes to create the List
      # @option args [Symbol] :name the name of the new List
      #
      # @return [Hash] a List resource in Hash form
      #
      # @example
      #   Todoable::Client.create(name: "Birthday List") #=>
      #     {"name"=>"Birthday List", "src"=>"...", "id"=>"..."}
      #
      def create_list(args = {})
        name = args[:name] || args["name"]

        params = {
          "list" => {
            "name" => name
          }
        }
        post(path: "lists", params: params)
      end

      # Fetches a List from the Todoable server, including its Items.
      #
      # Takes either an arguments Hash, including the id of the List,
      # or a List object itself.
      #
      # By default this API does not include the List"s id in the
      # Hash. We add it here for consistency.
      #
      # @param [Hash|List] args arguments to identify the List;
      # optionally, a List object can be passed
      # @option args [Symbol] :id the id of the List
      #
      # @return [Hash] a List resource in Hash form
      #
      # @example
      #   Todoable::Client.get_list(id: "41cf70a2-...") #=>
      #     {"name"=>"Birthday List", "src"=>"...", "id"=>"..."}
      #
      def get_list(args = {})
        id = args["id"] || args[:id]

        list = get(path: "lists/#{id}")
        list["id"] ||= id

        list
      end

      # Saves changes to a given List to the Todoable server.
      #
      # Takes either an arguments Hash, including the id of the List and
      # its new name, or a List object itself.
      #
      # If a List object is passed, the name will be updated to the current name
      # of the List object.
      #
      # @param [Hash|List] args arguments to identify the List;
      # optionally, a List object can be passed
      # @option args [Symbol] :id the id of the List
      # @option args [Symbol] :name the new name of the List
      #
      # @return [Hash] a List resource in Hash form
      #
      # @example
      #   Todoable::Client.update_list(id: "123-abc", name: "Birthday List") #=>
      #     {"name"=>"Birthday List", "src"=>"...", "id"=>"123-abc"}
      #
      def update_list(args = {})
        id = args["id"] || args[:id]
        name = args["name"] || args[:name]

        path = "lists/#{id}"
        params = {
          "list" => {
            "name" => name
          }
        }
        request(method: :patch, path: path, params: params)
      end

      # Deletes a List from the Todoable server.
      #
      # @param [Hash|List] args arguments to identify the List;
      # optionally, a List object can be passed
      # @option args [Symbol] :id the id of the List
      #
      # @example
      #   Todoable::Client.delete_list(id: "41cf70a2-...") #=>
      #     true
      #   Todoable::Client.get_list(id: "41cf70a2-...") #=>
      #     Todoable::NotFound
      #
      def delete_list(args = {})
        id = args["id"]

        path = "lists/#{id}"
        request(method: :delete, path: path)
      end
    end
  end
end
