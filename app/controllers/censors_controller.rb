class CensorsController < ApplicationController
  include GraduationAccess

  CENSOR_ACTIONS = [:confirm, :decline]
  before_filter :admin_required, except: [:create, :destroy, *CENSOR_ACTIONS]

  def index
    @censors = Censor.includes(:graduation).order('graduations.held_on DESC')
        .paginate(page: params[:page], per_page: 10)
  end

  def list_instructors
    @graduation = Graduation.find(params[:id])
    @instructors = Member.where('left_on IS NULL AND instructor = true').order(:first_name, :last_name).to_a
    @instructors -= @graduation.censors.map(&:member)
    rstr = <<EOH
    <div style="height:512px; width:284px; overflow: auto; overflow-x: hidden;">
    <table STYLE="height: 128px;" CELLPADDING="0" CELLSPACING="0" width="100%">
      <tr>
        <td STYLE="border-top: 1px solid #000000;background: #e3e3e3;border-bottom: 1px solid #000000;"><B>Instrukt&oslash;rer</B></td>
        <td ALIGN="right" STYLE="border-top: 1px solid #000000;background: #e3e3e3;border-bottom: 1px solid #000000;"><A HREF="#" onClick="hide_glist();">X</A></td>
        <td width=20>&nbsp;</td>
      </tr>
EOH
    @instructors.each do |instr|
      fn = instr.first_name.split(/\s+/).each(&:capitalize!).join(' ')
      ln = instr.last_name.split(/\s+/).each(&:capitalize!).join(' ')
      nm = fn << ' ' << ln
      rstr = rstr << "<tr id='censor_#{instr.id}'>" \
          "<td><a href='#' onClick='add_censor(" + instr.id.to_s + ",\"" + nm + "\");'>" <<
          nm << '</a></td>'
      '</tr>'
    end
    rstr << "</table>\n</div>\n"
    render text: rstr
  end

  def show
    @censor = Censor.find(params[:id])
  end

  def new
    @censor = Censor.new
  end

  def add_new_censor
    gid = params[:graduation_id].to_i
    mid = params[:member_id].to_i
    name = params[:name]
    if Censor.first(conditions: "member_id = #{mid} AND graduation_id = #{gid}")
      render text: 'Censor already exists'
    else
      Censor.create!(graduation_id: gid, member_id: mid)
      render text: "Added #{name} as new sensor to graduation"
    end
  end

  def create
    @censor = Censor.where('graduation_id = ? AND member_id = ?',
        params[:censor][:graduation_id], params[:censor][:member_id]).first ||
        Censor.new
    @censor.attributes = params[:censor]
    return unless admin_or_censor_required(@censor.graduation)
    if @censor.save
      flash[:notice] = 'Censor was successfully created.'
      back_or_redirect_to action: :index
    else
      render action: :new
    end
  end

  def edit
    @censor = Censor.find(params[:id])
  end

  def update
    @censor = Censor.find(params[:id])
    if @censor.update(params[:censor])
      flash[:notice] = 'Censor was successfully updated.'
      redirect_to action: :show, id: @censor
    else
      render action: :edit
    end
  end

  # From email link
  def confirm
    @censor = Censor.find(params[:id])
    return unless admin_or_censor_required(@censor.graduation)
    if @censor.update(confirmed_at: Time.zone.now, declined: false)
      flash[:notice] = 'Din deltakelse på gradering er bekreftet.'
      redirect_to action: :show, id: @censor
    else
      render action: :edit
    end
  end

  # From email link
  def decline
    @censor = Censor.find(params[:id])
    return unless admin_or_censor_required(@censor.graduation)
    if @censor.update(confirmed_at: Time.zone.now, declined: true)
      flash[:notice] = 'Ditt avslag på gradering er bekreftet.'
      redirect_to action: :show, id: @censor
    else
      render action: :edit
    end
  end

  def destroy
    censor = Censor.find(params[:id])
    censor.destroy!
    if request.xhr?
      render js: "$('#censor_#{censor.id}').remove()"
    else
      redirect_to action: :index
    end
  end
end
