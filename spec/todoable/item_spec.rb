require "spec_helper"
require "todoable/item"
require "todoable/list"

RSpec.describe Todoable::Item do
  let(:item_attributes) do
    {
      "name" => "get dog food",
      "finished_at" => nil,
      "src" => "http://todoable.teachable.tech/api/lists/123-abc/items/987-zyx",
      "list_id" => "123-abc",
      "id" => "987-zyx",
    }
  end
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
  let(:list_with_finished_item_attributes) {
    {
      "name" => "Groceries",
      "items" => [
        { "name" => "get dog food",
          "finished_at" => "2017-12-26T01:32:22.268Z",
          "src" => "http://todoable.teachable.tech/api/lists/123-abc/items/987-zyx",
          "id" => "987-zyx" },
        { "name" => "dish soap",
          "finished_at" => nil,
          "src" => "http://todoable.teachable.tech/api/lists/123-abc/items/654-wvu",
          "id" => "654-wvu" }
      ], "id" => "123-abc"
    }
  }


  let(:item) { Todoable::Item.new(item_attributes) }
  let(:mock_client) { double("mock client") }

  before(:each) do
    allow(Todoable::Client).to receive(:new).and_return(mock_client)
  end

  after(:each) do
    # Keep the mocked client from sticking around
    Todoable::List.instance_variable_set("@client", nil)
    Todoable::Item.instance_variable_set("@client", nil)
  end

  describe "#finish!" do
    it "sends request to finish the Item" do
      allow(mock_client).to receive(:get_list).with(id: "123-abc").and_return(list_attributes, list_with_finished_item_attributes)
      expect(mock_client).to receive(:finish_item).with(list_id: "123-abc", id: '987-zyx').and_return("get dog food finished")
      item.finish!
    end
  end

  describe "#finished?" do
    it "returns true if Item has a finished_at date" do
      item.finished_at = "2017-12-26T01:32:22.268Z"
      expect(item.finished?).to be_truthy
    end

    it "returns false if Item has no finished_at date" do
      item.finished_at = nil
      expect(item.finished?).to be_falsey
    end
  end

  describe "#list" do
    it "returns nil unless the Item has an associated List" do
      item.list_id = nil
      expect(item.list).to be_nil
    end

    it "fetches the associated List and instantiates it as a List object" do
      expect(mock_client).to receive(:get_list).with(id: "123-abc").and_return(list_attributes)
      expect(item.list.name).to eq("Groceries")
    end
  end

  describe ".new" do
    it "creates a Item object in memory" do
      expect(item.name).to eq("get dog food")
    end
  end

  describe ".create" do
    it "creates a new Item on the Todoable server" do
      expect(mock_client).to receive(:create_item).with(list_id: "123-abc", name: "get dog food").and_return(item_attributes)
      item = Todoable::Item.create(list_id: "123-abc", name: "get dog food")
      expect(item.name).to eq("get dog food")
    end
  end

  describe ".finish" do
    it "sends a request to finish the Item on the Todoable server" do
      expect(mock_client).to receive(:finish_item).with(list_id: "123-abc", id: "987-zyx").and_return("get dog food finished")
      expect(Todoable::Item.finish(list_id: "123-abc", id: "987-zyx")).to be_truthy
    end
  end

  describe ".delete" do
    it "deletes the Item from the Todoable server" do
      expect(mock_client).to receive(:delete_item).with(list_id: "123-abc", id: "987-zyx").and_return("")
      expect(Todoable::Item.delete(list_id: "123-abc", id: "987-zyx")).to be_truthy
    end
  end
end
