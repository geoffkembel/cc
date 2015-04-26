require 'spec_helper'
require 'rails_helper'

describe "Api#query", :type => :request do

  # mock the line data
  L_1 = { :filename => 'a', :key => 'a', :value => 'a'}
  L_2 = { :filename => 'a', :key => 'b', :value => 'b'}
  L_3 = { :filename => 'a', :key => 'c', :value => 'c'}
  L_4 = { :filename => 'b', :key => 'a', :value => 'b'}
  L_5 = { :filename => 'b', :key => 'b', :value => 'c'}
  L_6 = { :filename => 'b', :key => 'c', :value => 'a'}
  L_7 = { :filename => 'c', :key => 'a', :value => 'c'}
  L_8 = { :filename => 'c', :key => 'b', :value => 'a'}
  L_9 = { :filename => 'c', :key => 'c', :value => 'b'}

  # defaut line order
  LINES = [L_1, L_2, L_3, L_4, L_5, L_6, L_7, L_8, L_9]

  # all possible line orders
  LINES_FKV = LINES.to_json
  LINES_FVK = [L_1, L_2, L_3, L_6, L_4, L_5, L_8, L_9, L_7].to_json
  LINES_KFV = [L_1, L_4, L_7, L_2, L_5, L_8, L_3, L_6, L_9].to_json
  LINES_KVF = [L_1, L_4, L_7, L_8, L_2, L_5, L_6, L_9, L_3].to_json
  LINES_VFK = [L_1, L_6, L_8, L_2, L_4, L_9, L_3, L_5, L_7].to_json
  LINES_VKF = [L_1, L_8, L_6, L_4, L_2, L_9, L_7, L_5, L_3].to_json

  # stub get_lines_from_s3_files() method to return mocked data i/o hit s3
  before(:each) do
    allow_any_instance_of(ApiController).to receive(:get_lines_from_s3_files)
      .and_return(LINES)
  end

  describe 'empty query' do
    it "returns success" do
      get 'query'
      expect(response).to be_success
    end
  end

  describe 'invalid sort' do
    it "returns 400" do
      get 'query', { :sort => "invalid" }
      expect(response.status).to eq(400)
    end
  end

  describe 'empty sort' do
    it "returns fkv" do
      get 'query', { :sort => "" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_FKV)
    end
  end

  describe 'f sort' do
    it "returns fkv" do
      get 'query', { :sort => "f" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_FKV)
    end
  end

  describe 'fv sort' do
    it "returns fvk" do
      get 'query', { :sort => "fv" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_FVK)
    end
  end

  describe 'fvk sort' do
    it "returns fvk" do
      get 'query', { :sort => "fvk" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_FVK)
    end
  end

  describe 'k sort' do
    it "returns kfv" do
      get 'query', { :sort => "k" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_KFV)
    end
  end

  describe 'kv sort' do
    it "returns kvf" do
      get 'query', { :sort => "kv" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_KVF)
    end
  end

  describe 'v sort' do
    it "returns vfk" do
      get 'query', { :sort => "v" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_VFK)
    end
  end

  describe 'vkf sort' do
    it "returns vkf" do
      get 'query', { :sort => "vkf" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_VKF)
    end
  end

  describe 'vkkvffvkvff sort' do
    it "returns vkf" do
      get 'query', { :sort => "vkkvffvkvff" }
      expect(response.status).to eq(200)
      expect(response.body).to eq(LINES_VKF)
    end
  end

end