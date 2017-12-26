require "spec_helper"
require "timecop"

RSpec.describe Todoable::Client do
  let(:client) { Todoable::Client.new }
  let(:rest_client) { double("rest_client request") }
  let(:response) { double("response", code: 200) }
  let(:auth_response) { double("auth response", code: 200, body: authentication.to_json) }
  let(:authentication) { { "token": "abcdef", "expires_at": expires_at.to_s } }
  let(:now) { Time.local(2017, 12, 25, 12, 0, 0) }
  let(:expires_at) { Time.local(2017, 12, 25, 12, 20, 0) }
  let(:auth_request) { {:method=>:post, :url=>"http://todoable.teachable.tech/api/authenticate", :user=>"username", :password=>"password", :headers=>{:content_type=>:json, :accept=>:json}} }

  before(:each) do
    Todoable.configure do |c|
      c.username = "username"
      c.password = "password"
    end
    Timecop.freeze(now)
    allow(RestClient::Request).to receive(:execute).with(auth_request).and_yield(auth_response)
  end

  after(:each) do
    Timecop.return
  end

  describe "list methods" do
    let(:lists_attributes) do
      [
        {"name" => "Christmas List", "src" => "http://todoable.teachable.tech/api/lists/123-abc", "id" => "123-abc"},
        {"name" => "Birthday List", "src" => "http://todoable.teachable.tech/api/lists/456-def", "id" => "456-def"}
      ]
    end
    let(:list_attributes) do
      {
        "name" => "Christmas List",
        "src" => "http://todoable.teachable.tech/api/lists/123-abc",
        "id" => "123-abc"
      }
    end

    describe "#lists" do
      let(:response) { double("response", code: 200, body: { "lists" => lists_attributes }.to_json) }

      it "fetches lists from the Todoable server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:get, :url=>"http://todoable.teachable.tech/api/lists", :payload=>"{}", :headers=>anything).and_yield(response)

        expect(client.lists).to eq(lists_attributes)
      end
    end

    describe "#create_list" do
      let(:response) { double("response", code: 200, body: list_attributes.to_json) }

      it "creates a List" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:post, :url=>"http://todoable.teachable.tech/api/lists", :payload=>"{\"list\":{\"name\":\"Christmas List\"}}", :headers=>anything).and_yield(response)

        list = client.create_list(name: "Christmas List")
        expect(list).to eq(list_attributes)
      end
    end

    describe "#get_list" do
      let(:list_attributes) do
        {
          "name" => "Groceries",
          "items" => [
            { "name" => "get dog food",
              "finished_at" => nil,
              "src" => "http://todoable.teachable.tech/api/lists/123-abc/items/987-zyx",
              "id" => "987-zyx" },
            { "name" => "dish soap",
              "finished_at" => nil,
              "src" => "http://todoable.teachable.tech/api/lists/123-abc/items/654-wvu",
              "id" => "654-wvu" }
          ], "id" => "123-abc"
        }
      end
      let(:response) { double("response", code: 200, body: list_attributes.to_json) }

      it "fetches a List from the server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:get, :url=>"http://todoable.teachable.tech/api/lists/123-abc", :payload=>"{}", :headers=>anything).and_yield(response)
        client.get_list(id: "123-abc")
      end

    end

    describe "#update_list" do
      let(:response) { double("response", code: 200, body: list_attributes.to_json) }

      it "updates the name of the List on the Todoable server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:patch, :url=>"http://todoable.teachable.tech/api/lists/123-abc", :payload=>"{\"list\":{\"name\":\"Grocery List\"}}", :headers=>anything).and_yield(response)
        client.update_list(id: "123-abc", name: "Grocery List")
      end
    end

    describe "#delete_list" do
      let(:response) { double("response", code: 200, body: "") }

      it "deletes the List from the Todoable server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:delete, :url=>"http://todoable.teachable.tech/api/lists/123-abc", :payload=>"{}", :headers=>anything).and_yield(response)
        client.delete_list(id: "123-abc")
      end
    end
  end

  describe "item methods" do
    let(:item_attributes) do
      {
        "name" => "get dog food",
        "finished_at" => nil,
        "src" => "http://todoable.teachable.tech/api/lists/123-abc/items/987-zyx",
        "list_id" => "123-abc",
        "id" => "987-zyx",
      }
    end

    describe "#create_item" do
      let(:response) { double("response", code: 200, body: item_attributes.to_json) }

      it "creates an Item on the Todoable server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:post, :url=>"http://todoable.teachable.tech/api/lists/123-abc/items", :payload=>"{\"item\":{\"name\":\"get dog food\"}}", :headers=>anything).and_yield(response)
        client.create_item(list_id: "123-abc", name: "get dog food")
      end
    end

    describe "#finish_item" do
      let(:response) { double("response", code: 200, body: "get dog food finished") }

      it "finishes an Item on the Todoable server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:put, :url=>"http://todoable.teachable.tech/api/lists/123-abc/items/987-zyx/finish", :payload=>"{}", :headers=>anything).and_yield(response)
        client.finish_item(list_id: "123-abc", id: "987-zyx")
      end
    end

    describe "#delete_item" do
      let(:response) { double("response", code: 200, body: "") }

      it "deletes an Item from the Todoable server" do
        expect(RestClient::Request).to receive(:execute).with(:method=>:delete, :url=>"http://todoable.teachable.tech/api/lists/123-abc/items/987-zyx", :payload=>"{}", :headers=>anything).and_yield(response)
        client.delete_item(list_id: "123-abc", id: "987-zyx")
      end
    end
  end

  describe "request" do
    let(:response) { double("response: lists", code: 200, body: lists.to_json) }
    let(:lists) { [{"name"=>"Groceries", "src"=>"...", "id"=>"..."}, {"name"=>"Shopping", "src"=>"...", "id"=>"..."}] }

    it "checks authentication before making request" do
      client

      # token has expired, we"ll need to fetch a new one
      Timecop.freeze(Time.local(2018, 12, 25, 12, 40, 0))

      expect(client).to receive(:request_token).and_return({"token" => "ghijkl", "expires_at" => "2017-12-25 12:50:00 -0600"})
      expect(RestClient::Request).to receive(:execute).with({:method=>:get, :url=>"http://todoable.teachable.tech/api/lists", :payload=>"{}", :headers=>anything}).and_yield(response)
      result = client.request(path: "lists")

      expect(result).to eq(lists)
    end
  end

  describe "get" do
    let(:response) { double("response: lists", code: 200, body: list.to_json) }
    let(:list) { {"name"=>"Groceries", "src"=>"...", "id"=>"..."} }

    it "makes request with method GET" do
      expect(RestClient::Request).to receive(:execute).with({:method=>:get, :url=>"http://todoable.teachable.tech/api/list", :payload=>"{\"list_id\":\"123-abc\"}", :headers=>anything}).and_yield(response)
      result = client.get(path: "list", params: {list_id: "123-abc"})

      expect(result).to eq(list)
    end
  end

  describe "post" do
    let(:response) { double("response: lists", code: 200, body: list.to_json) }
    let(:list) { {"name"=>"Shopping", "src"=>"...", "id"=>"..."} }

    it "makes request with method POST" do
      expect(RestClient::Request).to receive(:execute).with({:method=>:post, :url=>"http://todoable.teachable.tech/api/lists", :payload=>"{\"name\":\"Shopping\"}", :headers=>anything}).and_yield(response)
      result = client.post(path: "lists", params: {name: "Shopping"})

      expect(result).to eq(list)
    end
  end
end
