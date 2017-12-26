require "spec_helper"

RSpec.describe Todoable::List do
  let(:list_attributes) { {"name" => "Christmas List", "src" => "http://todoable.teachable.tech/api/lists/123-abc", "id" => "123-abc"} }
  let(:list) { Todoable::List.new(list_attributes) }
  let(:mock_client) { double("mock client", get_list: list_attributes) }

  before(:each) do
    allow(Todoable::Client).to receive(:new).and_return(mock_client)
  end

  after(:each) do
    # Keep the mocked client from sticking around
    Todoable::List.instance_variable_set("@client", nil)
  end

  describe ".new" do
    it "creates a List" do
      expect(list.name).to eq("Christmas List")
    end
  end

  describe ".all" do
    let(:lists_attributes) do
      [
        {"name" => "Christmas List", "src" => "http://todoable.teachable.tech/api/lists/123-abc", "id" => "123-abc"},
        {"name" => "Birthday List", "src" => "http://todoable.teachable.tech/api/lists/456-def", "id" => "456-def"}
      ]
    end

    it "queries all lists and turns them into List objects" do
      expect(mock_client).to receive(:lists).and_return(lists_attributes)
      lists = Todoable::List.all

      expect(lists[0].name).to eq("Christmas List")
      expect(lists[1].name).to eq("Birthday List")
    end
  end

  describe ".create" do
    it "creates a List object from a Hash" do
      expect(list.name).to eq("Christmas List")
    end
  end

  describe ".get" do
    it "fetches a List from the server and converts it to a List object" do
      expect(mock_client).to receive(:get_list).with(id: "123-abc").and_return(list_attributes)
      list = Todoable::List.get(id: "123-abc")
      expect(list.name).to eq("Christmas List")
    end
  end

  describe ".update" do
    it "updates a List on the Todoable server" do
      expect(mock_client).to receive(:update_list).with(id: "123-abc", name: "Birthday List").and_return(list_attributes.merge(name: "Birthday List"))
      list = Todoable::List.update(id: "123-abc", name: "Birthday List")
      expect(list.name).to eq("Birthday List")
    end
  end

  describe ".delete" do
    it "deletes the List from the Todoable server" do
      expect(mock_client).to receive(:delete_list).with(id: "123-abc").and_return("")
      Todoable::List.delete(id: "123-abc")
    end
  end

  describe "#items" do
    let(:list_attributes) do
      {
        "name" => "Groceriess",
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

    it "fetches the List from the API" do
      expect(mock_client).to receive(:get_list).and_return(list_attributes)
      list = Todoable::List.get(id: "123-abc")
      expect(list.items.count).to eq(2)
    end
  end

  describe "#reload" do
    it "reloads an existing List from the server" do
      list.name = "Birthday List"
      expect(mock_client).to receive(:get_list).and_return(list_attributes)
      expect(list.reload.name).to eq("Christmas List")
    end

    it "can't reload a new List" do
      list = Todoable::List.new(name: "Birthday List")
      expect(list.name).to eq("Birthday List")
    end
  end

  describe "#save" do
    it "saves the List" do
      expect(mock_client).to receive(:update_list).and_return(list_attributes)
      list.name = "Birthday List"
      list.save
    end

    it "returns false on failure" do
      expect(mock_client).to receive(:update_list)
        .and_raise(Todoable::UnprocessableEntity)
      expect(list.save).to be_falsey
    end
  end

  describe "#save!" do
    it "saves the List" do
      expect(mock_client).to receive(:update_list).and_return(list_attributes)
      list.name = "Birthday List"
      list.save!
    end

    it "returns false on failure" do
      expect(mock_client).to receive(:update_list)
        .and_raise(Todoable::UnprocessableEntity)
      expect { list.save! }.to raise_exception(Todoable::UnprocessableEntity)
    end
  end

  describe "#delete" do
    it "deletes the List" do
      expect(mock_client).to receive(:delete_list).with(list).and_return("")
      expect(list.delete).to be_truthy
    end

    it "returns false on failure" do
      expect(mock_client).to receive(:delete_list)
        .with(list).and_raise(Todoable::NotFound)
      expect(list.delete).to be_falsey
    end
  end

  describe "#delete!" do
    it "deletes the List" do
      expect(mock_client).to receive(:delete_list).with(list).and_return("")
      expect(list.delete!).to be_truthy
    end

    it "raises exception on failure" do
      expect(mock_client).to receive(:delete_list)
        .with(list).and_raise(Todoable::NotFound)
      expect { list.delete! }.to raise_exception(Todoable::NotFound)
    end
  end

  describe "#name=" do
    it "updates the name of the List" do
      list = Todoable::List.new(name: "Birthday")
      list.name = "Christmas"
      expect(list.name).to eq("Christmas")
    end
  end
end
