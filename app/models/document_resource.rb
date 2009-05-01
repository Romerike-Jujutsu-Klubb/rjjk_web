# Copyright (c) 2006 Stuart Eccles
# Released under the MIT License.  See the LICENSE file for more details.

require 'find'
class DocumentResource
  include WebDavResource

   attr_accessor :href, :document, :table
   
   WEBDAV_PROPERTIES = [:displayname, :creationdate, :getlastmodified, :getcontenttype, :getcontentlength]
   @@classes = Hash.new
   
    Find.find( File.join(RAILS_ROOT, 'app/models') ) do |model|
          if File.extname(model) == ".rb" 
            model = File.basename(model, ".rb")
            kls = ActiveSupport::Inflector.classify( model )
            @@classes[model] = Module::const_get( kls )
          end
     end
   
   def initialize(*args)
       obj = args.first
       
       if obj.respond_to?(:save)
         @document = obj
       end

       if args.last.is_a?(String)
          @href = args.last
          @href = @href + '/' if collection? and not @href.last == '/'
       end
    end

    def collection?
      document.nil? ? true : false
    end

    def delete!
      document.destroy! unless document.nil?
    end

    def move! (dest_path, depth)
      
    end

    def copy! (dest_path, depth)
      
    end

    def children
     return [] unless collection?

     #If we have a table then return the children as all the records
     return table.find( :all ).map { |o| ActiveRecordResource.new(o,"#{href}#{o.id.to_s}.yaml") } unless table.nil?
     
     #The root case return the list of the tables
     return @@classes.keys.sort.map { |o| ActiveRecordResource.new(o,"#{href}#{o}") } if table.nil? and document.nil?

    end
  
   def properties
     WEBDAV_PROPERTIES
   end 

   def displayname 
      return "#{document.id.to_s}.yaml" unless document.nil?
      return @@classes.index(table) unless table.nil?
      "/"
   end
   
   def creationdate
      if !document.nil? and document.respond_to? :created_at
        document.created_at.httpdate
      end
   end
   
   def getlastmodified
      if !document.nil? and document.respond_to? :updated_at
        document.updated_at.httpdate
      end
   end
   
   def set_getlastmodified(value)
     if !document.nil? and document.respond_to? :updated_at=
      document.updated_at = Time.httpdate(value)
      gen_status(200, "OK").to_s
     else
        gen_status(409, "Conflict").to_s
     end
   end
   
   def getetag
      #sprintf('%x-%x-%x', @st.ino, @st.size, @st.mtime.to_i) unless @file.nil?
   end
      
   def getcontenttype
      collection? ? "httpd/unix-directory" : "text/yaml"
   end
      
   def getcontentlength 
      0
   end
   
   def data
     YAML::dump( document ) unless document.nil?
   end
   
end