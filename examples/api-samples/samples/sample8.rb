# GET request
get '/sample8' do
  haml :sample8
end

# POST request
post '/sample8' do
  # set variables
  set :client_id, params[:client_id]
  set :private_key, params[:private_key]
  set :guid, params[:guid]
  set :page_number, params[:page_number]

  #   file = GroupDocs::Storage::Folder.list!.last
  #   document = file.to_document
  #   document.page_images! 1024, 768, first_page: 0, page_count: 1

  begin
    # check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty?

    file = nil
    doc = nil
    metadata = nil

    # get document by file GUID
    case settings.source
      when 'guid'
        file = GroupDocs::Storage::File.new({:guid => settings.file_id})
      when 'local'
        # construct path
        filepath = "#{Dir.tmpdir}/#{params[:file][:filename]}"
        # open file
        File.open(filepath, 'wb') { |f| f.write(params[:file][:tempfile].read) }
        # make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(filepath, {}, client_id: settings.client_id, private_key: settings.private_key)
      when 'url'
        file = GroupDocs::Storage::File.upload_web!(settings.url, client_id: settings.client_id, private_key: settings.private_key)
      else
        raise 'Wrong GUID source.'
    end

    doc = file.to_document
    metadata = doc.metadata!({:client_id => settings.client_id, :private_key => settings.private_key})


    # get document page images
    images = doc.page_images!(800, 400, {:first_page => 0, :page_count => metadata.page_count}, {:client_id => settings.client_id, :private_key => settings.private_key})

    # result
    unless images.empty?
      image = images[Integer(settings.page_number)]
    end

  rescue Exception => e
    err = e.message
  end

  # set variables for template
  haml :sample8, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :guid => settings.guid, :page_number => settings.page_number, :image => image, :err => err}
end
