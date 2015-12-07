class GraduationsController < ApplicationController
  include GraduationAccess

  CENSOR_ACTIONS = [:add_group, :approve, :create, :edit, :index, :new, :update]
  before_filter :admin_required, except: CENSOR_ACTIONS
  before_filter :authenticate_user, only: CENSOR_ACTIONS

  def index
    @graduations = Graduation.includes(:group).references(:groups).
        order('held_on DESC, group_id DESC').where('groups.martial_art_id = 1').
        to_a.group_by(&:held_on)
    @groups = Group.order('from_age DESC').to_a
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
      flash[:notice] = 'Graduation was successfully created.'
      redirect_to edit_graduation_path(@graduation)
    else
      new
      render action: 'new'
    end
  end

  def edit
    @graduation = Graduation
        .includes(
            censors: {member: {graduates: {rank: :martial_art}}},
            graduates: {
                graduation: {
                    group: {
                        martial_art: {ranks: [{group: [:martial_art, :ranks]}, :martial_art]}
                    }
                },
                member: [
                    {
                        attendances: {
                            practice: :group_schedule
                        },
                        graduates: [
                            {
                                graduation: :group
                            },
                            :rank
                        ]
                    },
                    :nkf_member
                ],
                rank: [{group: [:group_schedules, :ranks]}, :martial_art],
            },
            group: {members: :nkf_member})
        .find(params[:id])
    @approval = @graduation.censors.
        select { |c| c.member == current_user.member }.
        sort_by { |c| c.approved_grades_at ? 0 : 1 }.last
    return unless admin_or_censor_required(@graduation, @approval)
    @groups = Group.order(:from_age).includes(members: [:attendances, :nkf_member]).to_a
    @groups.unshift(@groups.delete(@graduation.group))
    @graduate = Graduate.new(graduation_id: @graduation.id)
    @censor = Censor.new graduation_id: @graduation.id
    @ranks = Rank.where(martial_art_id: @graduation.group.martial_art_id)
        .order(:position).to_a

    included_members = @graduation.graduates.map(&:member)
    @excluded_members = @groups
        .map { |g| [g, g.members.active(@graduation.held_on).sort_by(&:name) - included_members] }
        .select { |_g, members| members.any? }

    @instructors = Member.instructors - @graduation.censors.map(&:member)
  end

  def update
    @graduation = Graduation.find(params[:id])
    if @graduation.update_attributes(params[:graduation])
      flash[:notice] = 'Graduation was successfully updated.'
      redirect_to action: :show, id: @graduation
    else
      render action: :edit
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
      censors = graduation.censors.to_a.sort_by { |c| -(c.member.current_rank.try(:position) || 99) }
      {name: g.member.name, rank: g.rank.label, group: g.rank.group.name,
          censor1: censors[0] ? {title: (censors[0].member.title), name: censors[0].member.name, signature: censors[0].member.signatures.sample.try(:image)} : nil,
          censor2: censors[1] ? {title: (censors[1].member.title), name: censors[1].member.name, signature: censors[1].member.signatures.sample.try(:image)} : nil,
          censor3: censors[2] ? {title: (censors[2].member.title), name: censors[2].member.name, signature: censors[2].member.signatures.sample.try(:image)} : nil,
      }
    end
    filename = "Certificates_#{graduation.group.martial_art.name}_#{graduation.held_on}.pdf"
    send_data Certificates.pdf(date, content), type: 'text/pdf',
        filename: filename, disposition: 'attachment'
  end

  def censor_form
    @graduation = Graduation.includes(graduates: [:member, :rank]).find params[:id]
    render layout: 'print'
  end

  def censor_form_pdf
    graduation = Graduation.find(params[:id])
    filename = "Sensorskjema_#{graduation.held_on}.pdf"

    pdf = Prawn::Document.new do
      date = graduation.held_on
      text "Gradering #{date.day}. #{I18n.t(Date::MONTHNAMES[date.month]).downcase} #{date.year}",
          size: 18, align: :center
      move_down 16
      data = graduation.graduates.sort_by { |g| [-g.rank.position, g.member.name] }.map do |graduate|
        member_current_rank = graduate.member.current_rank(graduate.graduation.martial_art, graduate.graduation.held_on)
        [
            "<font size='18'>" + graduate.member.first_name + '</font> ' + graduate.member.last_name + (graduate.member.birthdate && " (#{graduate.member.age} år)" || '') + "\n" +
                (member_current_rank && "#{member_current_rank.name} #{member_current_rank.colour}" || 'Ugradert') + "\n" +
                "Treninger: #{graduate.member.attendances_since_graduation(graduation.held_on).count}" + ' (' + graduate.current_rank_age + ")\n" +
                "#{graduate.rank.name} #{graduate.rank.colour}",
            '',
            '',
        ]
      end
      table([['Utøver', 'Bra', 'Kan bli bedre']] + data, header: true, cell_style: {inline_format: true, width: 180, padding: 8})
      start_new_page
    end

    send_data pdf.render, type: 'text/pdf', filename: filename, disposition: 'attachment'
  end

  def approve
    @graduation = Graduation.find(params[:id])
    @graduation.censors.where(member_id: current_user.member.id).
        update_all(approved_grades_at: Time.now)
    flash.notice = 'Gradering godkjent!'
    redirect_to edit_graduation_path(@graduation)
  end

  def add_group
    Graduation.transaction do
      graduation = Graduation.includes(:graduates).find(params[:id])
      group = Group.includes(:members).find(params[:group_id])
      members = group.members.active(graduation.held_on) - graduation.graduates.map(&:member)
      graduation.graduates << members.map do |member|
        Graduate.new member_id: member.id,
            rank_id: member.next_rank(graduation).id,
            passed: graduation.group.school_breaks?,
            paid_graduation: true, paid_belt: true
      end
      flash[:notice] = "Group #{group.name} was added to the graduation."
    end
    back_or_redirect_to action: :edit
  end

  private

  def load_graduates
    @graduation = Graduation.includes(group: {martial_art: {ranks: :group}}).find(params[:id])
    @censors = Censor.includes(:member).where(graduation_id: @graduation.id).to_a
    @graduates = Graduate.where('graduates.graduation_id = ? AND graduates.member_id != 0', params[:id]).
        #includes({:graduation => :martial_art}, {:member => [{:attendances => :group_schedule}, {:graduates => [:graduation, :rank]}]}, {:rank => :group}).
        includes({graduation: {group: :martial_art}}, :member, {rank: :group}).
        #order('ranks_graduates.position DESC, members.first_name, members.last_name').to_a
        order('ranks.position DESC, members.first_name, members.last_name').to_a
  end
end
