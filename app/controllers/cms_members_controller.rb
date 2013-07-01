class CmsMembersController < ApplicationController
  before_filter :admin_required

  def index
    @cms_members = CmsMember.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cms_members }
    end
  end

  def show
    @cms_member = CmsMember.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cms_member }
    end
  end

  def new
    @cms_member = CmsMember.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cms_member }
    end
  end

  def edit
    @cms_member = CmsMember.find(params[:id])
  end

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
