module Todoable
  class NotFound < StandardError; end
  class Unauthorized < StandardError; end
  class UnprocessableEntity < StandardError; end
  class ItemAlreadyFinished < StandardError; end

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
  #   item = client.create_item
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
    attr_accessor :expires_at

    autoload :Lists, "todoable/client/lists"
    autoload :Items, "todoable/client/items"

    include Lists
    include Items

    # Instantiate a new client, passing optional username and password, or
    # using the configured defaults.
    #
    # @param [String] username username on the Todoable server
    # @param [String] password password for the Todoable server
    # @param [String] base_uri URI of the Todoable API server
    #
    def initialize(username: nil, password: nil, base_uri: nil)
      @username = username || Todoable.configuration.username
      @password = password || Todoable.configuration.password
      @base_uri = base_uri || Todoable.configuration.base_uri

      authenticate
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

    private

    def handle_response(response)
      case response.code
      when 204
        true
      when 200..300
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          true
        end
      when 401
        raise Todoable::Unauthorized.new
      when 404
        raise Todoable::NotFound.new
      when 422
        errors = JSON.parse(response.body)

        raise Todoable::UnprocessableEntity.new(errors)
      end
    end

    def authenticate
      if @expires_at.nil? || DateTime.now > @expires_at
        response = request_token

        @token = response["token"]
        @expires_at = DateTime.parse(response["expires_at"])
      end

      [@token, @expires_at]
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
