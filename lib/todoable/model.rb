module Todoable
  # Encapsulate treating these classes as models.
  #
  module Model
    attr_accessor :id, :attributes

    def self.included(base)
      base.class_eval do
        def self.client
          username = 'progressions@gmail.com'
          password = 'todoable'

          @client ||= Todoable::Client.new(
            username: username,
            password: password,
          )
        end
      end
    end

    def initialize(attributes={})
      @attributes = attributes
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def [](key)
      attributes[key]
    end

    def name
      attributes["name"]
    end

    def delete!
      self.class.delete(self)
    end

    def delete
      delete!
    rescue StandardError => e
      false
    end

    def save
      save!
    rescue StandardError => e
      false
    end
  end
end
