ENV['APP_ENV'] = 'test'

require 'spec_helper'
require 'rack/test'
require_relative '../app'

RSpec.describe 'api/v1' do

  def app
    Sinatra::Application
  end

  context 'API' do
    it 'returns a list of files' do
      get '/api/v1/list'
      expect(last_response.status).to eq(200)
      
      expect(JSON.parse(last_response.body)['files']).to include('hello.tx')
    end
  
    it 'returns message: successful uploaded file' do
      post '/api/v1/upload', 'file' => Rack::Test::UploadedFile.new(File.open('./spec/fixtures/files/butterflies-png-hd-736.png'), 'image/png')
      expect(JSON.parse(last_response.body)['message']).to eq('Successful uploaded file.')
    end
  
    it 'returns message: Upload file type or size is not allow.' do
      post '/api/v1/upload', 'file' => Rack::Test::UploadedFile.new(File.open('./spec/fixtures/files/king-198x255.jpg'), 'image/jpeg')
      expect(JSON.parse(last_response.body)['message']).to eq('Upload file type or size is not allow.')
    end

    it 'returns message: Something went wrong ...' do
      post '/api/v1/upload', {}
      expect(JSON.parse(last_response.body)['message']).to eq("Something went wrong undefined method `[]' for nil:NilClass")
    end
  end
  
  context '#check_type' do
    it 'returns true' do
      file_type = 'image/jpeg'
      subject = check_type(file_type)
      expect(subject).to be true
    end

    it 'returns false' do
      file_type = 'image/tiff'
      subject = check_type(file_type)
      expect(subject).to be false
    end
  end

  context '#check_dimensions' do
    it 'returns true' do
      image_dimension = [600,600]
      subject = check_dimension(image_dimension)
      expect(subject).to be_truthy
    end

    it 'returns false' do
      image_dimension = [125,450]
      subject = check_dimension(image_dimension)
      expect(subject).to be_falsey
    end
  end
end
