class BirthdayCelebrationsController < ApplicationController
  before_filter :admin_required

  def index
    @birthday_celebrations = BirthdayCelebration.order('held_on DESC').all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @birthday_celebrations }
    end
  end

  def show
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @birthday_celebration }
    end
  end

  def certificates
    bc = BirthdayCelebration.find(params[:id])
    date = bc.held_on
    participants = bc.participants.split(/\s*\n+\s*/)
    general = {
        :rank => 'Innføring i Jujutsu', :group => '',
        :censor1 => bc.sensor1 ? {:title => (bc.sensor1.title), :name => bc.sensor1.name} : nil,
        :censor2 => bc.sensor1 ? {:title => (bc.sensor2.title), :name => bc.sensor2.name} : nil,
        :censor3 => bc.sensor1 ? {:title => (bc.sensor3.title), :name => bc.sensor3.name} : nil,
    }
    content = participants.map{|n| general.dup.update({:name => n})}
    filename = "Certificates_birthday_#{date}.pdf"
    send_data Certificates.pdf(date, content), :type => 'text/pdf',
              :filename => filename, :disposition => 'attachment'
  end

  def new
    @birthday_celebration = BirthdayCelebration.new
    @members = Member.order(:first_name).active(Date.today).all.select{|m| m.age >= 15}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @birthday_celebration }
    end
  end

  def edit
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    @members = Member.order(:first_name).active(@birthday_celebration.held_on).all.select{|m| m.age >= 15}
  end

  def create
    @birthday_celebration = BirthdayCelebration.new(params[:birthday_celebration])
    respond_to do |format|
      if @birthday_celebration.save
        format.html { redirect_to @birthday_celebration, notice: 'Birthday celebration was successfully created.' }
        format.json { render json: @birthday_celebration, status: :created, location: @birthday_celebration }
      else
        format.html { render action: :new }
        format.json { render json: @birthday_celebration.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    respond_to do |format|
      if @birthday_celebration.update_attributes(params[:birthday_celebration])
        format.html { redirect_to @birthday_celebration, notice: 'Birthday celebration was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json { render json: @birthday_celebration.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    @birthday_celebration.destroy
    respond_to do |format|
      format.html { redirect_to birthday_celebrations_url }
      format.json { head :no_content }
    end
  end
end
