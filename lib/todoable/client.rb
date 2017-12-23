module Todoable
  class Client
    attr_reader :token, :expires_at

    class NotFound < StandardError; end
    class Unauthorized < StandardError; end
    class UnprocessableEntity < StandardError; end

    # http://todoable.teachable.tech/api/
    # username = "progressions@gmail.com"
    # password = "todoable"
    #
    def initialize(username: "progressions@gmail.com", password: "todoable")
      @username = username
      @password = password

      @base_uri = "http://todoable.teachable.tech/api/"
    end

    def request(method: :get, path:, params: {})
      @token, @expires_at = get_token

      uri = "#{@base_uri}/#{path}"
      headers = {
        "Authorization" => "Token token=\"#{@token}\"",
        "Accept" => "application/json",
        "Content-Type" => "application/json",
      }

      response = RestClient::Request.execute(method: method, url: uri, payload: params.to_json, headers: headers) do |response|
        case response.code
        when 200..300
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            response.body
          end
        when 404
          raise Todoable::Client::NotFound.new
        when 422
          errors = JSON.parse(response.body)

          raise Todoable::Client::UnprocessableEntity.new(errors)
        end
      end
    end

    def get(path:, params: {})
      request(method: :get, path: path, params: params)
    end

    def post(path:, params: {})
      request(method: :post, path: path, params: params)
    end

    private

      # curl \
      # -u progressions@gmail.com:todoable \
      # -H "Accept: application/json" \
      # -H "Content-Type: application/json" \
      # -X POST \
      # http://todoable.teachable.tech/api/authenticate
      #
      def get_token
        if expires_at.nil? || DateTime.now > expires_at
          url = "#{@base_uri}/authenticate"
          response = RestClient::Request.execute(method: :post, url: url, user: @username, password: @password, headers: {content_type: :json, accept: :json})
          body = JSON.parse(response.body)

          token = body["token"]
          expires_at = DateTime.parse(body["expires_at"])

          [token, expires_at]
        else
          [@token, @expires_at]
        end
      end
  end
end
