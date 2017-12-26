require 'spec_helper'

RSpec.describe Todoable::List do
  let(:list_attributes) { {'name'=>'Christmas List', 'src'=>'http://todoable.teachable.tech/api/lists/123-abc', 'id'=>'123-abc'} }
  let(:list) { Todoable::List.new(list_attributes) }
  let(:mock_client) { double('mock client', get_list: list_attributes) }

  before(:each) do
    allow(Todoable::Client).to receive(:new).and_return(mock_client)
  end

  after(:each) do
    # Keep the mocked client from sticking around
    Todoable::List.instance_variable_set("@client", nil)
  end

  describe '.new' do
    it 'creates a List' do
      expect(list.name).to eq("Christmas List")
    end
  end

  describe '.all' do
    let(:lists_attributes) { [
      {'name'=>'Christmas List', 'src'=>'http://todoable.teachable.tech/api/lists/123-abc', 'id'=>'123-abc'},
      {'name'=>'Birthday List', 'src'=>'http://todoable.teachable.tech/api/lists/456-def', 'id'=>'456-def'}
    ] }

    it 'queries all lists and turns them into List objects' do
      expect(mock_client).to receive(:lists).and_return(lists_attributes)
      lists = Todoable::List.all

      expect(lists[0].name).to eq("Christmas List")
      expect(lists[1].name).to eq("Birthday List")
    end
  end

  describe '.create' do
    it 'creates a List object from a Hash' do
      expect(list.name).to eq("Christmas List")
    end
  end

  describe '.get' do
    it 'fetches a List from the server and converts it to a List object' do
      expect(mock_client).to receive(:get_list).with(id: '123-abc').and_return(list_attributes)
      list = Todoable::List.get(id: '123-abc')
      expect(list.name).to eq("Christmas List")
    end
  end

  describe '.update' do
    it 'updates a List on the Todoable server' do
      expect(mock_client).to receive(:update_list).with(id: "123-abc", name: "Birthday List").and_return(list_attributes.merge(name: "Birthday List"))
      list = Todoable::List.update(id: '123-abc', name: 'Birthday List')
      expect(list.name).to eq("Birthday List")
    end
  end

  describe '.delete' do
    it 'deletes the List from the Todoable server' do
      expect(mock_client).to receive(:delete_list).with(id: '123-abc').and_return("")
      Todoable::List.delete(id: '123-abc')
    end
  end

  describe '#items' do
    let(:list_attributes) {
      {"name"=>"Grocs", "items"=>[{"name"=>"this be an item", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/41c87aee-c56f-4890-9c88-a6c34201ae7e/items/e6927127-b60c-44d4-b7d5-3510ca0b6f80", "id"=>"e6927127-b60c-44d4-b7d5-3510ca0b6f80"}, {"name"=>"QA7a382fa0-5670-404e-8ac8-24439bc96bd7", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/41f12914-b47a-4abe-9b48-606a6b76c959/items/b82ebd34-6be9-4838-b08a-c22a756509db", "id"=>"b82ebd34-6be9-4838-b08a-c22a756509db"}, {"name"=>"Bootsy", "finished_at"=>"2017-12-24T17:54:43.760Z", "src"=>"http://todoable.teachable.tech/api/lists/41cf70a2-9251-42f7-b8d1-c0a47ec58629/items/b61c612a-a4f8-4a4c-b2cc-7e0c72148679", "id"=>"b61c612a-a4f8-4a4c-b2cc-7e0c72148679"}], "id"=>"41cf70a2-9251-42f7-b8d1-c0a47ec58629"}
    }

    it 'fetches the List from the API' do
      expect(mock_client).to receive(:get_list).and_return(list_attributes)
      list = Todoable::List.get(id: '123-abc')
      expect(list.items.count).to eq(3)
    end
  end

  describe '#reload' do
    it 'reloads an existing List from the server' do
      list.name = "Birthday List"
      expect(mock_client).to receive(:get_list).and_return(list_attributes)
      expect(list.reload.name).to eq("Christmas List")
    end

    it "can't reload a new List" do
      list = Todoable::List.new(name: "Birthday List")
      expect(list.name).to eq("Birthday List")
    end
  end

  describe '#save' do
    it 'saves the List' do
      expect(mock_client).to receive(:update_list).and_return(list_attributes)
      list.name = 'Birthday List'
      list.save
    end

    it "returns false on failure" do
      expect(mock_client).to receive(:update_list).and_raise(Todoable::UnprocessableEntity)
      expect(list.save).to be_falsey
    end
  end

  describe '#save!' do
    it 'saves the List' do
      expect(mock_client).to receive(:update_list).and_return(list_attributes)
      list.name = 'Birthday List'
      list.save!
    end

    it "returns false on failure" do
      expect(mock_client).to receive(:update_list).and_raise(Todoable::UnprocessableEntity)
      expect { list.save! }.to raise_exception(Todoable::UnprocessableEntity)
    end
  end

  describe '#delete' do
    it 'deletes the List' do
      expect(mock_client).to receive(:delete_list).with(list).and_return("")
      expect(list.delete).to be_truthy
    end

    it 'returns false on failure' do
      expect(mock_client).to receive(:delete_list).with(list).and_raise(Todoable::NotFound)
      expect(list.delete).to be_falsey
    end
  end

  describe '#delete!' do
    it 'deletes the List' do
      expect(mock_client).to receive(:delete_list).with(list).and_return("")
      expect(list.delete!).to be_truthy
    end

    it 'raises exception on failure' do
      expect(mock_client).to receive(:delete_list).with(list).and_raise(Todoable::NotFound)
      expect { list.delete! }.to raise_exception(Todoable::NotFound)
    end
  end

  describe '#name=' do
    it 'updates the name of the List' do
      list = Todoable::List.new(name: "Birthday")
      list.name = "Christmas"
      expect(list.name).to eq("Christmas")
    end
  end
end
