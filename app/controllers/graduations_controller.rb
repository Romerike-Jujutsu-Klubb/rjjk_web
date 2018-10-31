# frozen_string_literal: true

class GraduationsController < ApplicationController
  include GraduationAccess

  CENSOR_ACTIONS = %i[add_group approve create disapprove edit graduates_tab index new update]
      .freeze
  before_action :admin_required, except: CENSOR_ACTIONS
  before_action :authenticate_user, only: CENSOR_ACTIONS

  def index
    @graduations = Graduation.includes(:group).references(:groups)
        .order('held_on DESC, group_id DESC').where('groups.martial_art_id = ?', MartialArt::KWR_ID)
        .to_a.group_by(&:held_on)
    @groups = @graduations.values.flatten.map(&:group).uniq.sort_by(&:from_age).reverse
  end

  def show
    @graduation = Graduation.includes(:censors, :graduates).find(params[:id])
  end

  def new
    @graduation ||= Graduation.new(params[:graduation])
    @groups = Group.active(nil).order(:from_age).to_a
  end

  def create
    @graduation = Graduation.new(params[:graduation])
    if @graduation.save
      flash[:notice] = 'Gradering er opprettet.'
      redirect_to edit_graduation_path(@graduation)
    else
      new
      render action: 'new'
    end
  end

  def edit
    @graduation = Graduation.for_edit.find(params[:id])
    @approval = load_current_user_approval
    return unless admin_or_censor_required(@graduation, @approval)

    @censor = Censor.new graduation_id: @graduation.id
    @instructors = Member.instructors(@graduation.held_on).to_a.sort_by(&:current_rank).reverse -
        @graduation.censors.map(&:member)
  end

  def graduates_tab
    @graduation = Graduation.for_edit.find(params[:id])
    approval = load_current_user_approval
    return unless admin_or_censor_required(@graduation, approval)

    @groups = Group.order(:from_age).includes(members: %i[attendances nkf_member user])
        .merge(Member.active(@graduation.held_on)).to_a
    @groups.unshift(@groups.delete(@graduation.group))
    @ranks = Rank.where(martial_art_id: @graduation.group.martial_art_id)
        .order(:position).to_a
    included_members = @graduation.graduates.map(&:member)
    @excluded_members = @groups
        .map { |g| [g, g.members.sort_by(&:name) - included_members] }
        .select { |_g, members| members.any? }
    @graduate = Graduate.new(graduation_id: @graduation.id)
    render partial: 'graduates_tab'
  end

  def update
    @graduation = Graduation.for_edit.find(params[:id])
    if @graduation.update(params[:graduation])
      # FIXME(uwe): If the date has changed:
      # * Clear sensor confirmations
      # * Request sensors again
      # * Clear graduate confirmations
      # * Send date change message to graduates
      flash[:notice] = 'Gradering er oppdatert.'
      redirect_to action: :edit, id: @graduation, anchor: :form_tab
    else
      new
      render action: 'new'
    end
  end

  def destroy
    Graduation.find(params[:id]).destroy
    redirect_to action: :index, id: nil
  end

  def certificates
    graduation = Graduation.find(params[:id])
    date = graduation.held_on

    content = graduation.graduates.sort_by { |g| -g.rank.position }.map do |g|
      censors = graduation.censors.to_a
          .sort_by { |c| -(c.member.current_rank.try(:position) || 99) }
      censor_1 =
          if censors[0]
            { title: censors[0].member.title, name: censors[0].member.name,
              signature: censors[0].member.signatures.sample.try(:image) }
          end
      censor_2 =
          if censors[1]
            { title: censors[1].member.title,
              name: censors[1].member.name,
              signature: censors[1].member.signatures.sample.try(:image) }
          end
      censor_3 =
          if censors[2]
            { title: censors[2].member.title,
              name: censors[2].member.name,
              signature: censors[2].member.signatures.sample.try(:image) }
          end
      { name: g.member.name, rank: g.rank.label, group: g.rank.group.name,
        censor1: censor_1, censor2: censor_2, censor3: censor_3 }
    end
    filename = "Certificates_#{graduation.group.martial_art.name}_#{graduation.held_on}.pdf"
    send_data Certificates.pdf(date, content), type: 'text/pdf',
                                               filename: filename, disposition: 'attachment'
  end

  def censor_form
    @graduation = Graduation.includes(graduates: %i[member rank]).find params[:id]
    render layout: 'print'
  end

  def censor_form_pdf
    graduation = Graduation.find(params[:id])
    filename = "Sensorskjema_#{graduation.held_on}.pdf"
    data = GraduationCensorForm.new(graduation).binary
    send_data data, type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def lock
    @graduation = Graduation.find(params[:id])
    censor = @graduation.censors.find_by(member_id: current_user.member.id)
    censor.confirmed_at ||= Time.current
    censor.locked_at ||= Time.current
    censor.save!
    flash.notice = 'Gradering klar for innkalling!'
    redirect_to edit_graduation_path(@graduation)
  end

  def approve
    graduation = Graduation.find(params[:id])
    censor = graduation.censors.find_by(member_id: current_user.member.id)
    censor.confirmed_at ||= Time.current
    censor.locked_at ||= Time.current
    censor.approved_grades_at ||= Time.current
    censor.save!
    flash.notice = 'Gradering godkjent!'
    redirect_to edit_graduation_path(graduation)
  end

  def disapprove
    graduation = Graduation.find(params[:id])
    censor = graduation.censors.find_by(member_id: current_user.member.id)
    censor.update! approved_grades_at: nil
    flash.notice = 'Gradering ikke godkjent!'
    redirect_to edit_graduation_path(graduation)
  end

  def add_group
    Graduation.transaction do
      graduation = Graduation.includes(:graduates).find(params[:id])
      if params[:group_id].blank?
        flash.notice = 'Velg en gruppe'
        back_or_redirect_to edit_graduation_path(graduation)
        return
      end
      group = Group.includes(:members).find(params[:group_id])
      members = group.members.active(graduation.held_on) - graduation.graduates.map(&:member)
      success_count = 0
      failures = []
      members.each do |member|
        next_rank = member.next_rank(graduation)
        next if graduation.group_notification && next_rank.position >= Rank::SHODAN_POSITION

        g = Graduate.new graduation_id: graduation.id, member_id: member.id,
                         rank_id: next_rank.id,
                         passed: graduation.group.school_breaks? || nil,
                         paid_graduation: true, paid_belt: true
        if g.save
          success_count += 1
        else
          failures << g
        end
      end

      flash[:notice] = "Gruppe #{group.name} ble lagt til graderingen.  " \
          "#{success_count} nye kandidater. "

      if failures.any?
        failure_list = failures.map(&:member).map(&:name).join(', ')
        flash[:notice] += "#{failure_list} kunne ikke legges til."
        flash[:error] = "Disse kunne ikke legges til: #{failure_list}"
        failures.each do |fg|
          logger.error "Failed record: #{fg.member.name}: " \
              "#{fg.errors.full_messages} #{fg.rank.name} #{fg.inspect}"
        end
      end
    end
    back_or_redirect_to action: :edit
  end

  private

  def load_current_user_approval
    @graduation.censors.select { |c| c.member == current_user.member }
        .max_by { |c| c.approved_grades_at ? 0 : 1 }
  end

  def load_graduates
    @graduation = Graduation.includes(group: { martial_art: { ranks: :group } }).find(params[:id])
    @censors = Censor.includes(:member).where(graduation_id: @graduation.id).to_a
    @graduates = Graduate.where('graduates.graduation_id = ? AND graduates.member_id != 0',
        params[:id])
        .includes({ graduation: { group: :martial_art } }, :member, rank: :group)
        .order('ranks.position DESC, members.first_name, members.last_name').to_a
  end
end
