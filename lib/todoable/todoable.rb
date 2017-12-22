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

  def lists
    get(path: "lists")["lists"]
  end

  def create_list(name:)
    params = {
      "list" => {
        "name" => name
      }
    }
    post(path: "lists", params: params)
  end

  def get_list(list_id:)
    get(path: "lists/#{list_id}")
  end

  def update_list(list_id:, name:)
    path = "lists/#{list_id}"
    params = {
      "list" => {
        "name" => name
      }
    }
    request(method: :patch, path: path, params: params)
  end

  def delete_list(list_id:)
    path = "lists/#{list_id}"
    request(method: :delete, path: path)
  end

  def create_item(list_id:, name:)
    path = "lists/#{list_id}/items"
    params = {
      "item" => {
        "name" => name
      }
    }
    post(path: path, params: params)
  end

  def finish_item(list_id:, item_id:)
    path = "lists/#{list_id}/items/#{item_id}/finish"
    request(method: :put, path: path)
  end

  def delete_item(list_id:, item_id:)
    path = "lists/#{list_id}/items/#{item_id}"
    request(method: :delete, path: path)
  end
end
