module Todoable
  # Module to handle querying and creation of lists.
  #
  class List
    attr_accessor :src, :id, :attributes

    def initialize(attributes={})
      @attributes = attributes
      attributes.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
    end

    def [](key)
      attributes[key]
    end

    def name=(value)
      attributes["name"] = value
    end

    def name
      attributes["name"]
    end

    def items
      unless @items
        response = self.class.get(id: id)
        @items = Array(response["items"]).map do |item|
          Item.new(item)
        end
      end

      @items
    end

    def reload
      @items = nil

      self
    end

    def save
      self.class.update(id: id, name: name)
    end

    class << self
      def client
        @client ||= Todoable::Client.new
      end

      def first
        all.first
      end

      def all
        response = client.get(path: 'lists')

        Array(response['lists']).map do |list|
          List.new(list)
        end
      end

      def create(name:)
        params = {
          'list' => {
            'name' => name
          }
        }
        client.post(path: 'lists', params: params)
      end

      def get(args={})
        id = args["id"]
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
