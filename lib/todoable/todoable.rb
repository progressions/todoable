class Todoable
  attr_accessor :token, :expires_at

  def initialize
    @token, @expires_at = get_token
  end

  # curl \
  # -u progressions@gmail.com:todoable \
  # -H "Accept: application/json" \
  # -H "Content-Type: application/json" \
  # -X POST \
  # http://todoable.teachable.tech/api/authenticate
  #
  def get_token
    if expires_at.nil? || DateTime.now > expires_at
      url = "http://todoable.teachable.tech/api/authenticate"
      username = "progressions@gmail.com"
      password = "todoable"
      response = RestClient::Request.execute(method: :post, url: url, user: username, password: password, headers: {content_type: :json, accept: :json})
      body = JSON.parse(response.body)

      token = body["token"]
      expires_at = DateTime.parse(body["expires_at"])

      [token, expires_at]
    else
      [@token, @expires_at]
    end
  end

  def request(method: :get, path:, params: {})
    @token, @expires_at = get_token

    uri = "http://todoable.teachable.tech/api/#{path}"
    headers = {
      "Authorization" => "Token token=\"#{@token}\"",
      "Accept" => "application/json",
      "Content-Type" => "application/json",
    }

    response = RestClient::Request.execute(method: method, url: uri, payload: params.to_json, headers: headers)
    JSON.parse(response.body)
  end

  def get(path:, params: {})
    request(method: :get, path: path, params: params)
  end

  def post(path:, params: {})
    request(method: :post, path: path, params: params)
  end

  def index
    get(path: "lists")
  end

  def create(name)
    params = {
      "list" => {
        "name" => name
      }
    }
    post(path: "lists", params: params)
  end
end
