module Todoable
  # Simple class to store authentication information for the Todoable server.
  #
  class Configuration
    attr_accessor :username, :password, :base_uri

    # URI of the Todoable API server.
    BASE_URI = "http://todoable.teachable.tech/api".freeze

    def initialize
      @base_uri = BASE_URI
    end
  end
end
