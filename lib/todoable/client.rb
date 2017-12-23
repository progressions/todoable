module Todoable
  class Client
    attr_reader :token, :expires_at

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

      RestClient::Request.execute(method: method, url: uri, payload: params.to_json, headers: headers)
    end

    def get(path:, params: {})
      response = request(method: :get, path: path, params: params)
      JSON.parse(response.body)
    end

    def post(path:, params: {})
      response = request(method: :post, path: path, params: params)
      JSON.parse(response.body)
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
