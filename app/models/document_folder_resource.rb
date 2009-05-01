require 'find'

class DocumentFolderResource
  include WebDavResource

  attr_accessor :href
   
  WEBDAV_PROPERTIES = [:displayname, :creationdate, :getlastmodified, :getcontenttype, :getcontentlength]
   
  def initialize(*args)
    if args.last.is_a?(String)
      puts "DocumentFolderResource.initialize: #{args.inspect}"
      @href = args.last
      @href = @href + '/' if collection? and not @href.last == '/'
    end
  end

  def collection?
    puts "collection"
    true
  end

  def delete!
  end

  def move! (dest_path, depth)
  end

  def copy! (dest_path, depth)
  end

  def children
    puts "Children: "
    Document.find( :all ).map { |d| DocumentResource.new(d,"#{href}#{d.id.to_s}.doc") }
  end
  
  def properties
    WEBDAV_PROPERTIES
  end 

  def displayname
    puts "displayname"
    "/"
  end
   
  def creationdate
    if !record.nil? and record.respond_to? :created_at
      record.created_at.httpdate
    end
  end
   
  def getlastmodified
    Time.now.httpdate
  end
   
  def set_getlastmodified(value)
    if !record.nil? and record.respond_to? :updated_at=
      record.updated_at = Time.httpdate(value)
      gen_status(200, "OK").to_s
    else
        gen_status(409, "Conflict").to_s
    end
  end
   
  def getetag
    #sprintf('%x-%x-%x', @st.ino, @st.size, @st.mtime.to_i) unless @file.nil?
  end
      
  def getcontenttype
    puts 'getcontenttype'
    collection? ? "httpd/unix-directory" : "text/yaml"
  end
      
  def getcontentlength 
    0
  end
   
  def data
    children.map {|d| d.href}
  end
   
end