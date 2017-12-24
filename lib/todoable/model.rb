module Todoable
  # Encapsulate treating these classes as models.
  #
  module Model
    attr_accessor :id, :attributes

    def self.included(base)
      base.class_eval do
        def self.client
          @client ||= Todoable::Client.new
        end
      end
    end

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

    def delete!
      self.class.delete(self)
    end
  end
end
