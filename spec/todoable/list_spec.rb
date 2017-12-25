require 'spec_helper'

RSpec.describe Todoable::List do
  let(:list_attributes) { {'name'=>'Christmas List', 'src'=>'http://todoable.teachable.tech/api/lists/d8443c22-5833-479d-bc5a-9866fe1fc264', 'id'=>'d8443c22-5833-479d-bc5a-9866fe1fc264'} }
  let(:list) { Todoable::List.new(list_attributes) }
  let(:mock_client) { double('mock client', get_list: list_attributes) }

  before(:each) do
    allow(Todoable::Client).to receive(:new).and_return(mock_client)
  end

  after(:each) do
    # Keep the mocked client from sticking around
    Todoable::List.instance_variable_set("@client", nil)
  end

  context '.new' do
    it 'creates a List' do
      expect(list.name).to eq("Christmas List")
    end
  end

  context '#items' do
    let(:list_attributes) {
      {"name"=>"Grocs", "items"=>[{"name"=>"this be an item", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/41c87aee-c56f-4890-9c88-a6c34201ae7e/items/e6927127-b60c-44d4-b7d5-3510ca0b6f80", "id"=>"e6927127-b60c-44d4-b7d5-3510ca0b6f80"}, {"name"=>"QA7a382fa0-5670-404e-8ac8-24439bc96bd7", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/41f12914-b47a-4abe-9b48-606a6b76c959/items/b82ebd34-6be9-4838-b08a-c22a756509db", "id"=>"b82ebd34-6be9-4838-b08a-c22a756509db"}, {"name"=>"Bootsy", "finished_at"=>"2017-12-24T17:54:43.760Z", "src"=>"http://todoable.teachable.tech/api/lists/41cf70a2-9251-42f7-b8d1-c0a47ec58629/items/b61c612a-a4f8-4a4c-b2cc-7e0c72148679", "id"=>"b61c612a-a4f8-4a4c-b2cc-7e0c72148679"}], "id"=>"41cf70a2-9251-42f7-b8d1-c0a47ec58629"}
    }

    it 'fetches the List from the API' do
      expect(mock_client).to receive(:get_list).and_return(list_attributes)
      list = Todoable::List.get(id: '123-abc')
      expect(list.items.count).to eq(3)
    end
  end

  context '#reload' do
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

  context '#save' do
    it 'saves the List' do
      expect(mock_client).to receive(:update_list).and_return(list_attributes)
      list.name = 'Birthday List'
      list.save
    end

    it "returns false on failure" do
      expect(mock_client).to receive(:update_list).and_raise(Todoable::UnprocessableEntity)
      expect { list.save }.not_to raise_exception
    end
  end

  context '#save!' do
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
end