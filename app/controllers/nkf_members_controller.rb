class NkfMembersController < ApplicationController
  before_filter :admin_required

  # FIXME(uwe):  Verify caching
  cache_sweeper :member_sweeper, only: [:create_member, :update_member]

  def index
    @nkf_members = NkfMember.order(:fornavn, :etternavn).to_a
  end

  def show
    if params[:id] && respond_to?(params[:id])
      send params[:id]
      render action: params[:id] unless response_body
      return
    end
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
      render action: 'new'
    end
  end

  def update
    @nkf_member = NkfMember.find(params[:id])
    if @nkf_member.update_attributes(params[:nkf_member])
      flash[:notice] = 'NkfMember was successfully updated.'
      # redirect_to(@nkf_member)
      # redirect_to nkf_members_path
      redirect_to action: :comparison, id: 0
    else
      render action: 'edit'
    end
  end

  def destroy
    @nkf_member = NkfMember.find(params[:id])
    @nkf_member.destroy
    redirect_to(nkf_members_url)
  end

  def comparison
    c = NkfMemberComparison.new
    @orphan_nkf_members = c.orphan_nkf_members
    @orphan_members = c.orphan_members
    @groups = Group.order('from_age DESC, to_age DESC').to_a
    @members = c.members
  end

  def create_member
    nkf_member = NkfMember.find(params[:id])
    flash[:notice] = if nkf_member.create_member!
                       t(:member_created)
                     else
                       'Member creation failed.'
                     end
    redirect_to action: :comparison, id: 0
  end

  def update_member
    @member = Member.find(params[:id])
    flash[:notice] = if @member.update_attributes(params[:member])
                       'Member was successfully updated.'
                     else
                       'Member update failed.'
                     end
    redirect_to action: :comparison, id: 0
  end

  def import
    import = NkfMemberImport.new
    flash[:notice] = "#{import.changes.size} records imported, #{html_escape(import.error_records.size.to_s)} failed, #{import.import_rows.size - import.changes.size - import.error_records.size} skipped" +
        (import.error_records.any? ? "<br>#{html_escape(import.error_records.map { |r| [r, r.errors.full_messages] }.inspect)}" : '')

    redirect_to action: :comparison
  end

  def age_vs_contract
    members = NkfMember.where(medlemsstatus: 'A').to_a
    @wrong_contracts = members.select { |m|
      (m.member.age < 10 && m.kont_sats !~ /^Barn/) ||
          (m.member.age >= 10 && m.member.age < 15 && m.kont_sats !~ /^Ungdom/) ||
          (m.member.age >= 15 && m.kont_sats !~ /^(Voksne|Styre|Trenere|Æresmedlem)/)
    }
  end
end
