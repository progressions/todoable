module Todoable
  class NotFound < StandardError; end
  class Unauthorized < StandardError; end
  class UnprocessableEntity < StandardError; end

  # Class to handle making requests from the Todoable API.
  #
  class Client
    attr_accessor :expires_at

    BASE_URI = 'http://todoable.teachable.tech/api'

    autoload :Lists, 'todoable/client/lists'
    autoload :Items, 'todoable/client/items'

    include Lists
    include Items

    def initialize(username: nil, password: nil, base_uri: nil)
      username = "progressions@gmail.com"
      password = "todoable"

      @username = username || Todoable.configuration.username
      @password = password || Todoable.configuration.password

      @base_uri ||= Todoable.configuration.base_uri || BASE_URI

      authenticate
    end

    def request(method: :get, path:, params: {})
      authenticate

      uri = "#{@base_uri}/#{path}"
      headers = {
        'Authorization' => "Token token=\"#{@token}\"",
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      RestClient::Request.execute(
        method: method, url: uri, payload: params.to_json, headers: headers
      ) do |response|
        handle_response(response)
      end
    end

    def get(path:, params: {})
      request(method: :get, path: path, params: params)
    end

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

        @token = response['token']
        @expires_at = DateTime.parse(response['expires_at'])
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
