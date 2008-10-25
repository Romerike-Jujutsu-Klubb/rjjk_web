class CmsMembersController < ApplicationController
  # GET /cms_members
  # GET /cms_members.xml
  def index
    @cms_members = CmsMember.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cms_members }
    end
  end

  # GET /cms_members/1
  # GET /cms_members/1.xml
  def show
    @cms_member = CmsMember.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cms_member }
    end
  end

  # GET /cms_members/new
  # GET /cms_members/new.xml
  def new
    @cms_member = CmsMember.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cms_member }
    end
  end

  # GET /cms_members/1/edit
  def edit
    @cms_member = CmsMember.find(params[:id])
  end

  # POST /cms_members
  # POST /cms_members.xml
  def create
    @cms_member = CmsMember.new(params[:cms_member])

    respond_to do |format|
      if @cms_member.save
        flash[:notice] = 'CmsMember was successfully created.'
        format.html { redirect_to(@cms_member) }
        format.xml  { render :xml => @cms_member, :status => :created, :location => @cms_member }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cms_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cms_members/1
  # PUT /cms_members/1.xml
  def update
    @cms_member = CmsMember.find(params[:id])

    respond_to do |format|
      if @cms_member.update_attributes(params[:cms_member])
        flash[:notice] = 'CmsMember was successfully updated.'
        format.html { redirect_to(@cms_member) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cms_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cms_members/1
  # DELETE /cms_members/1.xml
  def destroy
    @cms_member = CmsMember.find(params[:id])
    @cms_member.destroy

    respond_to do |format|
      format.html { redirect_to(cms_members_url) }
      format.xml  { head :ok }
    end
  end
  
  def active_contracts
    @members = CmsMember.find_active
  end

  def excel_export
    @cms_members = CmsMember.find(:all)
    render :layout => false
  end
  
  def import
    @new_members, @updated_members = CmsImport.import
  end
  
end
