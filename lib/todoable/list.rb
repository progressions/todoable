module Todoable
  # Module to handle querying and creation of lists.
  #
  module List
    class << self
      def client
        @client ||= Todoable::Client.new
      end

      def all
        response = client.get(path: 'lists')

        response['lists']
      end

      def create(name:)
        params = {
          'list' => {
            'name' => name
          }
        }
        client.post(path: 'list', params: params)
      end

      def get(id:)
        client.get(path: "lists/#{id}")
      end

      def update(id:, name:)
        path = "lists/#{id}"
        params = {
          'list' => {
            'name' => name
          }
        }
        client.request(method: :patch, path: path, params: params)
      end

      def delete(id:)
        path = "lists/#{id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
