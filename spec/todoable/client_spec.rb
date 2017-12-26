require 'spec_helper'
require 'timecop'

RSpec.describe Todoable::Client do
  let(:client) { Todoable::Client.new }
  let(:rest_client) { double("rest_client request") }
  let(:response) { double("response", code: 200) }
  let(:auth_response) { double('auth response', code: 200, body: authentication.to_json) }
  let(:authentication) { { "token": "abcdef", "expires_at": expires_at.to_s } }
  let(:now) { Time.local(2017, 12, 25, 12, 0, 0) }
  let(:expires_at) { Time.local(2017, 12, 25, 12, 20, 0) }
  let(:auth_request) { {:method=>:post, :url=>"http://todoable.teachable.tech/api/authenticate", :user=>"progressions@gmail.com", :password=>"todoable", :headers=>{:content_type=>:json, :accept=>:json}} }

  before(:each) do
    Timecop.freeze(now)
    allow(RestClient::Request).to receive(:execute).with(auth_request).and_yield(auth_response)
  end

  after(:each) do
    Timecop.return
  end

  describe "instantiation" do
    it "authenticates immediately" do
      expect(RestClient::Request).to receive(:execute).with(auth_request).and_yield(auth_response)

      client
    end
  end

  describe "request" do
    let(:response) { double("response: lists", code: 200, body: lists.to_json) }
    let(:lists) { [{"name"=>"Groceries", "src"=>"...", "id"=>"..."}, {"name"=>"Shopping", "src"=>"...", "id"=>"..."}] }

    it "checks authentication before making request" do
      client

      # token has expired, we'll need to fetch a new one
      Timecop.freeze(Time.local(2018, 12, 25, 12, 40, 0))

      expect(client).to receive(:request_token).and_return({"token" => "ghijkl", "expires_at" => "2017-12-25 12:50:00 -0600"})
      expect(RestClient::Request).to receive(:execute).with({:method=>:get, :url=>"http://todoable.teachable.tech/api/lists", :payload=>"{}", :headers=>anything}).and_yield(response)
      result = client.request(path: 'lists')

      expect(result).to eq(lists)
    end
  end

  describe "get" do
    let(:response) { double("response: lists", code: 200, body: list.to_json) }
    let(:list) { {"name"=>"Groceries", "src"=>"...", "id"=>"..."} }

    it "makes request with method GET" do
      expect(RestClient::Request).to receive(:execute).with({:method=>:get, :url=>"http://todoable.teachable.tech/api/list", :payload=>"{\"list_id\":\"123-abc\"}", :headers=>anything}).and_yield(response)
      result = client.get(path: "list", params: {list_id: '123-abc'})

      expect(result).to eq(list)
    end
  end

  describe "post" do
    let(:response) { double("response: lists", code: 200, body: list.to_json) }
    let(:list) { {"name"=>"Shopping", "src"=>"...", "id"=>"..."} }

    it "makes request with method POST" do
      expect(RestClient::Request).to receive(:execute).with({:method=>:post, :url=>"http://todoable.teachable.tech/api/lists", :payload=>"{\"name\":\"Shopping\"}", :headers=>anything}).and_yield(response)
      result = client.post(path: "lists", params: {name: 'Shopping'})

      expect(result).to eq(list)
    end
  end
end
