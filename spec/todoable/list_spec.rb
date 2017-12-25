require 'spec_helper'

RSpec.describe Todoable::List do
  let(:list_attributes) { {'name'=>'Christmas List', 'src'=>'http://todoable.teachable.tech/api/lists/d8443c22-5833-479d-bc5a-9866fe1fc264', 'id'=>'d8443c22-5833-479d-bc5a-9866fe1fc264'} }
  let(:list) { Todoable::List.new(list_attributes) }
  let(:mock_client) { Todoable::MockClient.new(username: "username",
                                               password: "password") }

  before(:each) do
    allow(Todoable::Client).to receive(:new).and_return(mock_client)
  end

  context 'new' do
    it 'creates a List' do
      expect(list.name).to eq("Christmas List")
    end
  end

  context '#save' do
    it 'saves the List' do
      list.name = 'Birthday List'
      list.save
    end
  end

  context '#items' do
    let(:list_attributes) {
      {"name"=>"Grocs", "items"=>[{"name"=>"this be an item", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/41c87aee-c56f-4890-9c88-a6c34201ae7e/items/e6927127-b60c-44d4-b7d5-3510ca0b6f80", "id"=>"e6927127-b60c-44d4-b7d5-3510ca0b6f80"}, {"name"=>"QA7a382fa0-5670-404e-8ac8-24439bc96bd7", "finished_at"=>nil, "src"=>"http://todoable.teachable.tech/api/lists/41f12914-b47a-4abe-9b48-606a6b76c959/items/b82ebd34-6be9-4838-b08a-c22a756509db", "id"=>"b82ebd34-6be9-4838-b08a-c22a756509db"}, {"name"=>"Bootsy", "finished_at"=>"2017-12-24T17:54:43.760Z", "src"=>"http://todoable.teachable.tech/api/lists/41cf70a2-9251-42f7-b8d1-c0a47ec58629/items/b61c612a-a4f8-4a4c-b2cc-7e0c72148679", "id"=>"b61c612a-a4f8-4a4c-b2cc-7e0c72148679"}], "id"=>"41cf70a2-9251-42f7-b8d1-c0a47ec58629"}
    }

    before(:each) do
      allow(Todoable::List).to receive(:get).and_return(list)
    end

    it 'fetches the List from the API' do
      expect(list.items.count).to eq(3)
    end
  end
end
