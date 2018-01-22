RSpec.describe Todoable::Client do
  case ENV["API"]
  when "teachable"
    puts("Running live tests against Teachable API")

    let(:base_uri) { "http://todoable.teachable.tech/api/" }
    let(:username) { "progressions@gmail.com" }
    let(:password) { "todoable" }
  when "heroku"
    puts("Running live tests against Heroku API")

    let(:base_uri) { "https://intense-hamlet-87296.herokuapp.com/api" }
    let(:username) { "username" }
    let(:password) { "password" }
  else
    puts("Running live tests against local API")

    let(:base_uri) { "http://localhost:4000/api" }
    let(:username) { "username" }
    let(:password) { "password" }
  end

  let(:client) { Todoable::Client.new(base_uri: base_uri, username: username, password: password) }

  it "integration test", live: true do
    lists = client.lists
    lists.select { |list| list["name"] == "Shopping List" }
      .each { |list| client.delete_list(id: list["id"]) }

    # Create list
    list = client.create_list(name: "Shopping List")
    expect(list["name"]).to eq("Shopping List")

    # Check that new list is included in all lists
    lists = client.lists
    matches = lists.select { |list| list["name"] == "Shopping List" }
    expect(matches.length).to eq(1)

    # Create an item
    item = client.create_item(list_id: list["id"], name: "Get some milk")
    expect(item["name"]).to eq("Get some milk")
    expect(item["finished_at"]).to be_nil
    expect(item["list_id"]).to eq(list["id"])

    # Finish an item
    result = client.finish_item(list_id: list["id"], id: item["id"])
    expect(result).to eq(true)

    # Get list, check that item exists on it
    list = client.get_list(id: list["id"])
    items = list["items"].select { |item| item["name"] == "Get some milk"}
    expect(items.length).to eq(1)

    # Delete list
    result = client.delete_list(id: list["id"])
    expect(result).to eq(true)

    # Check that deleted list doesn't appear on all lists
    lists = client.lists
    matches = lists.select { |list| list["name"] == "Shopping List" }
    expect(matches.length).to eq(0)

    # Check that nonexistent list can't be found
    expect { client.get_list(id: list["id"]) }.to raise_exception(Todoable::NotFound)
  end
end
