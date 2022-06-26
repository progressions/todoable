require 'pry'
module Todoable
  NotFound = Class.new(StandardError)
  Unauthorized = Class.new(StandardError)
  UnprocessableEntity = Class.new(StandardError)
  InternalServerError = Class.new(StandardError)
  class ItemAlreadyFinished < StandardError
    def initialize(item)
      super("Item: `#{item.name}` is already finished")
    end
  end

  # Class to handle making requests from the Todoable API.
  #
  # @example
  #   client = Todoable::Client.new
  #
  #   client.create_list(name: "Groceries")
  #
  #   #=> {"name"=>"Groceries", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}
  #
  #   lists = client.lists
  #
  #   #=> [{"name"=>"Groceries", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}, {"name"=>"Death List", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}, {"name"=>"Shopping", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}, {"name"=>"Birthday List", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}]
  #
  #   client.update_list(id: list["id"], name: "Buy Groceries")
  #
  #   #=> {"name"=>"Buy Groceries", "src"=>"http://todoable.teachable.tech/api/lists/...", "id"=>"..."}
  #
  #   item = client.create_item(list_id: "...", name: "get dog food")
  #
  #   #=> {"name"=>"get dog food", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/98b2510c-0eb7-4316-bfef-d38c762b1ffb/items/bcf6443f-7231-4064-a607-667369792a77", "id"=>"bcf6443f-7231-4064-a607-667369792a77", "list_id"=>"98b2510c-0eb7-4316-bfef-d38c762b1ffb"}
  #
  #   When you fetch a List with `get_list`, it includes the List's associated Items.
  #
  #   client.get_list(id: list["id"])
  #
  #   #=> {"name"=>"Groceries", "items"=>[{"name"=>"get dog food", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/.../items/...", "id"=>"..."}], "id"=>"..."}
  #
  #   client.finish_item(list_id: list["id"], id: item["id"])
  #
  #   client.delete_item(list_id: list["id"], id: item["id"])
  #
  #   client.delete_list(id: list["id"])
  #
  class Client
    attr_reader :token, :expires_at

    autoload :Lists, "todoable/client/lists"
    autoload :Items, "todoable/client/items"

    include Lists
    include Items

    # Instantiate a new client, passing optional username and password, or
    # using the configured defaults.
    #
    # Instantiate the client one of two ways:
    #
    # - username/password
    # - token/expires_at
    #
    # @param [String] username username on the Todoable server
    # @param [String] password password for the Todoable server
    # @param [String] base_uri URI of the Todoable API server
    # @param [String] token authentication token
    # @param [String] expires_at expiration time of the authentication token
    #
    # @example
    #
    #   If you are authenticating for the first time, and/or if you intend
    #   to keep the Client in memory, you can authenticate with your
    #   username and password.
    #
    #   This will create a temporary token with an expiry date, but the client
    #   will re-authenticate with the username and password you entered when
    #   it expires.
    #
    #   Todoable::Client.new(username: "user", password: "pass")
    #
    # @example
    #   If you have previously authenticated, but need to reinstantiate the
    #   client, you can store the token and expires_at values and pass them
    #   to the client upon instantiation.
    #
    #   Todoable::Client.new(token: "abcdef", expires_at: "2018-01-02T00:00:00+00:00"
    #
    def initialize(username: nil, password: nil, base_uri: nil,
                   token: nil, expires_at: nil)

      @token = token
      @expires_at = DateTime.parse(expires_at.to_s) if expires_at

      @username = username || Todoable.configuration.username
      @password = password || Todoable.configuration.password
      @base_uri = base_uri || Todoable.configuration.base_uri
    end

    # Make a request against the Todoable API sever.
    #
    # @param [String] method the method to make the request wth
    # @param [String] path the path of the request, will be appended
    # to the base URI
    # @param [String] params optional parameters to send
    #
    # @return [String|Boolean] the JSON-decoded body of a successful request,
    # or +true+ if the request had no body
    #
    def request(method: :get, path:, params: {})
      authenticate

      uri = "#{@base_uri}/#{path}"
      headers = {
        "Authorization" => "Token token=\"#{@token}\"",
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      }

      RestClient::Request.execute(
        method: method, url: uri, payload: params.to_json, headers: headers
      ) { |response| handle_response(response) }
    end

    # Make a GET request against the Todoable API sever.
    #
    # @param [String] path the path of the request, will be appended
    # to the base URI
    # @param [String] params optional parameters to send
    #
    # @return [String|Boolean] the JSON-decoded body of a successful request,
    # or +true+ if the request had no body
    #
    def get(path:, params: {})
      request(method: :get, path: path, params: params)
    end

    # Make a POST request against the Todoable API sever.
    #
    # @param [String] path the path of the request, will be appended
    # to the base URI
    # @param [String] params optional parameters to send
    #
    # @return [String|Boolean] the JSON-decoded body of a successful request,
    # or +true+ if the request had no body
    #
    def post(path:, params: {})
      request(method: :post, path: path, params: params)
    end

    # Indicate whether authentication is required.
    #
    # @return [Boolean] +true+ if the client needs to re-authenticate
    #
    def authenticated?
      @expires_at && DateTime.now <= @expires_at
    end

    # Request a token and expiration date from the Todoable server.
    #
    # Raise Todoable::Unauthorized if credentials are not accepted.
    #
    # @return [String, String] [token, expires_at]
    #
    def authenticate!
      if !authenticated?
        response = request_token

        @token = response["token"]
        @expires_at = DateTime.parse(response["expires_at"])
      end

      [@token, @expires_at]
    end

    # Request a token and expiration date from the Todoable server.
    #
    # If credentials are not accepted, return nil values but do not
    # raise exception.
    #
    def authenticate
      authenticate!
    rescue StandardError
      [nil, nil]
    end

    private

    def handle_response(response)
      case response.code
      when 204
        true
      when 200..300
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          response.body
        end
      when 401
        raise Todoable::Unauthorized.new
      when 404
        raise Todoable::NotFound.new
      when 422
        errors = JSON.parse(response.body)

        raise Todoable::UnprocessableEntity.new(errors)
      when 500
        raise Todoable::InternalServerError.new
      end
    end

    def request_token
      url = "#{@base_uri}/authenticate"

      RestClient::Request.execute(
        method: :post,
        url: url,
        user: @username,
        password: @password,
        headers: { content_type: :json, accept: :json }
      ) do |response|
        handle_response(response)
      end
    end
  end
end
