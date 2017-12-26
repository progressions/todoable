module Todoable
  # Encapsulate treating these classes as models.
  #
  module Model
    attr_accessor :id, :attributes, :name

    # @!visibility private
    def self.included(base)
      base.class_eval do
        def self.client
          @client ||= Todoable::Client.new
        end
      end
    end

    # Initializes a new in-memory model object.
    #
    # @param [Hash] attributes a set of attributes to define the object
    #
    # @return [List|Item] a List or Item object
    #
    def initialize(attributes = {})
      assign_attributes(attributes)
    end

    # Returns a value from the object's attributes.
    #
    # @param [Symbol|String] key the key to identify the requested
    # attribute.
    #
    # @return the value contained within the attribute
    #
    def [](key)
      attributes[key.to_sym]
    end

    # Deletes this object from the Todoable server, raising exceptions
    # on error.
    #
    # @return [Boolean] return +true+ if the request is successful
    #
    def delete!
      self.class.delete!(id: id)
    end

    # Deletes this object from the Todoable server, returning +false+
    # on error.
    #
    # @return [Boolean] return +true+ if the request is successful
    #
    def delete
      delete!
    rescue StandardError
      false
    end

    private

    # Assign attributes from a Hash to instance variables in the object.
    #
    # @param [Hash] attributes attributes describing the object
    #
    def assign_attributes(attributes = {})
      @attributes = HashWithIndifferentAccess.new(attributes)
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
