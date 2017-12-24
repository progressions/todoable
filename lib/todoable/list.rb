module Todoable
  autoload :Model, 'todoable/model'

  # Module to handle querying and creation of lists.
  #
  class List
    include Model

    def items
      unless @items
        response = self.class.get(self)
        @items = Array(response["items"]).map do |item|
          item["list_id"] = @id

          Item.new(item)
        end
      end

      @items
    end

    def reload
      @items = nil

      self.class.get(self)
    end

    def save!
      self.class.update(id: id, name: name)
    end

    class << self
      def first
        all.first
      end

      def all
        response = client.get(path: 'lists')

        Array(response['lists']).map do |list|
          List.new(list)
        end
      end

      def create(args={})
        name = args[:name] || args["name"]

        params = {
          'list' => {
            'name' => name
          }
        }
        client.post(path: 'lists', params: params)
      end

      def get(args={})
        id = args["id"]
        list = client.get(path: "lists/#{id}")
        list["id"] = id

        Todoable::List.new(list)
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

      def delete(args={})
        id = args["id"]

        path = "lists/#{id}"
        client.request(method: :delete, path: path)
      end
    end
  end
end
