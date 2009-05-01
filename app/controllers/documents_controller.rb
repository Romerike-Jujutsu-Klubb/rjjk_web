require 'webdav/active_record_web_dav_controller'
require 'webdav/active_record_resource'

class DocumentsController < ActionController::Base
  act_as_railsdav
  
  protected
  
  def mkcol_for_path(path)
    #Forbidden
    raise WebDavErrors::ForbiddenError
  end 
  
  def write_content_to_path(path, content)
    obj = YAML::load( content )
    obj.save if obj
  end
  
  def get_resource_for_path(path)
    puts "Hi: #{path.inspect}"
    if path.blank? or path.eql?("/")
      puts "list"
      return DocumentFolderResource.new(href_for_path(nil))
    end
    puts 1
    id = path
    if /(\w+)\.doc$/ =~ id
      return DocumentResource.new(clazz.find($1.to_i), href_for_path(path))
    else
      raise WebDavErrors::NotFoundError
    end     
  end
  
  def webdav_get
    resource = get_resource_for_path(@path_info)
    p resource
    raise WebDavErrors::NotFoundError if resource.blank?
    data_to_send = resource.data
    p data_to_send
    raise WebDavErrors::NotFoundError if data_to_send.blank?
    response.headers["Last-Modified"] = resource.getlastmodified
    if data_to_send.kind_of? File
      send_file File.expand_path(data_to_send.path), :filename => resource.displayname, :stream => true
    else
      send_data data_to_send, :filename => resource.displayname unless data_to_send.nil?
    end
    
  end
  
end
