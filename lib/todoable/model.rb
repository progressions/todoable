module Todoable
  # Encapsulate treating these classes as models.
  #
  module Model
    attr_accessor :id, :attributes, :name

    def self.included(base)
      base.class_eval do
        def self.client
          @client ||= Todoable::Client.new
        end
      end
    end

    def initialize(attributes={})
      set_attributes(attributes)
    end

    def set_attributes(attributes={})
      @attributes = HashWithIndifferentAccess.new(attributes)
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def [](key)
      attributes[key.to_sym]
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
