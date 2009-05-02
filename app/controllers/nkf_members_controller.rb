class NkfMembersController < ApplicationController
  before_filter :admin_required
  
  def index
    @nkf_members = NkfMember.all :order => 'fornavn, etternavn'
  end
  
  def show
    @nkf_member = NkfMember.find(params[:id])
  end
  
  def new
    @nkf_member = NkfMember.new
  end
  
  def edit
    @nkf_member = NkfMember.find(params[:id])
  end
  
  def create
    @nkf_member = NkfMember.new(params[:nkf_member])
    if @nkf_member.save
      flash[:notice] = 'NkfMember was successfully created.'
      redirect_to(@nkf_member)
    else
      render :action => "new"
    end
  end
  
  def update
    @nkf_member = NkfMember.find(params[:id])
    if @nkf_member.update_attributes(params[:nkf_member])
      flash[:notice] = 'NkfMember was successfully updated.'
      # redirect_to(@nkf_member)
      # redirect_to nkf_members_path
      redirect_to :action => :comparison, :id => 0
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @nkf_member = NkfMember.find(params[:id])
    @nkf_member.destroy
    redirect_to(nkf_members_url)
  end
  
  FIELD_MAP = {
    :etternavn => :last_name,
    :fodselsdato => :birthdate,
    :fornavn => :first_name,
    :innmeldtdato => :joined_on,
    :postnr => :postal_code,
    :utmeldtdato => :left_on,
  }
  
  def comparison
    @orphan_nkf_members = NkfMember.find(:all, :conditions => 'member_id IS NULL', :order => 'fornavn, etternavn')
    @orphan_members = NkfMember.find_free_members
    @members = []
    nkf_members = NkfMember.all :conditions => 'member_id IS NOT NULL', :order => 'fornavn, etternavn'
    nkf_members.each do |nkfm|
      new_attributes = convert_attributes(nkfm.attributes)
      p new_attributes
      member = nkfm.member
      member.attributes = new_attributes
      if member.changed?
        @members << nkfm.member
      end
    end
  end
  
  def create_member
    nkf_member = NkfMember.find(params[:id])
    attributes = convert_attributes(nkf_member.attributes)
    attributes[:instructor] = false
    attributes[:male] = true
    attributes[:nkf_fee] = true
    attributes[:payment_problem] = false
    
    if member = Member.create!(attributes)
      nkf_member.update_attributes! :member_id => member.id
      flash[:notice] = 'Member was successfully created.'
    else
      flash[:notice] = 'Member creation failed.'
    end
    redirect_to :action => :comparison, :id => 0
  end
  
  def update_member
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Member was successfully updated.'
    else
      flash[:notice] = 'Member update failed.'
    end
    redirect_to :action => :comparison, :id => 0
  end
  
  private
  
  def convert_attributes(attributes)
    new_attributes = {}
    attributes.each do |k, v|
      if FIELD_MAP.keys.include?(k.to_sym)
        if FIELD_MAP[k.to_sym]
          if v =~ /^\s*(\d{2}).(\d{2}).(\d{4})\s*$/
            v = "#$3-#$2-#$1"
          end
          new_attributes[FIELD_MAP[k.to_sym]] = v
        else
          puts "Ignoring attribute: #{k}"
        end
      else
        puts "Unknown attribute: #{k}"
      end
    end
    return new_attributes
  end
  
end
