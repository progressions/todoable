module Todoable
  class NotFound < StandardError; end
  class Unauthorized < StandardError; end
  class UnprocessableEntity < StandardError; end

  # Class to handle making requests from the Todoable API.
  #
  class Client
    BASE_URI = 'http://todoable.teachable.tech/api/'

    attr_reader :token

    def initialize(username: nil, password: nil, base_uri: nil)
      @username = username || Todoable.configuration.username
      @password = password || Todoable.configuration.password

      @base_uri ||= Todoable.configuration.base_uri || BASE_URI
    end

    def request(method: :get, path:, params: {})
      @token, @expires_at = authenticate

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

    # curl \
    # -u progressions@gmail.com:todoable \
    # -H "Accept: application/json" \
    # -H "Content-Type: application/json" \
    # -X POST \
    # http://todoable.teachable.tech/api/authenticate
    #
    def authenticate
      if @expires_at.nil? || DateTime.now > @expires_at
        url = "#{@base_uri}/authenticate"
        response = RestClient::Request.execute(
          method: :post,
          url: url,
          user: @username,
          password: @password,
          headers: { content_type: :json, accept: :json }
        )
        body = JSON.parse(response.body)

        @token = body['token']
        @expires_at = Date.parse(body['expires_at'])
      end

      [@token, @expires_at]
    end
  end
end
