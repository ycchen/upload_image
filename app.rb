require 'sinatra'
require 'sinatra/contrib/all'
require 'mini_magick'

# class App < Sinatra::Base
  set :bind, '0.0.0.0'

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  get '/' do
    # 'Welcome to Upload File'
    erb :form
  end

  namespace '/api/v1' do
    get '/list' do
      content_type :json
      list = Dir.glob("./public/uploads/*.*").map{|f| f.split('/').last}
      {files: list}.to_json
    end

    post '/upload' do
      content_type :json
      
      begin
        @file = params[:file]
        @filename = params[:file][:filename]

        tempfile = params[:file][:tempfile]
        image = MiniMagick::Image.open(File.new(tempfile))

        is_allow_type = check_type(@file[:type])
        is_allow_size = check_dimension(image.dimensions)

        if is_allow_type && is_allow_size
          target = "public/uploads/#{@filename}"
          File.open(target, 'wb') do |f|
            f.write(tempfile.read)
          end
          
          status 200
          {message: 'Successful uploaded file.'}.to_json
        else
          status 400
          {message: 'Upload file type or size is not allow.'}.to_json
        end

      rescue => exception
        status 400
        {message: "Something went wrong #{exception}"}.to_json
      end
    end
  end

  def check_type(file_type)
    %w(image/jpeg image/png).include?(file_type)
  end

  def check_dimension(dimension)
    width = dimension[0]
    height = dimension[1]
    (width >= 350 && height <= 5000) ? true : false
  end

  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
# end