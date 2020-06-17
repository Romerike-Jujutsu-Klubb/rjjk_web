# frozen_string_literal: true

class BirthdayCelebrationsController < ApplicationController
  before_action :admin_required

  def index
    @birthday_celebrations = BirthdayCelebration.order('held_on DESC').to_a
  end

  def show
    edit
  end

  def certificates
    bc = BirthdayCelebration.find(params[:id])
    date = bc.held_on
    participants = bc.participants.split(/\s*\n+\s*/)
    general = -> do
      {
        rank: 'Innføring i Jujutsu', group: '',
        censor1: bc.sensor1 && { title: bc.sensor1.title, name: bc.sensor1.name,
                                 signature: bc.sensor1.user.signatures.sample.try(:image) },
        censor2: bc.sensor1 && { title: bc.sensor2.title, name: bc.sensor2.name,
                                 signature: bc.sensor2.user.signatures.sample.try(:image) },
        censor3: bc.sensor1 && { title: bc.sensor3.title, name: bc.sensor3.name,
                                 signature: bc.sensor3.user.signatures.sample.try(:image) }
      }
    end
    content = participants.map { |n| general.call.update(name: n) }
    filename = "Certificates_birthday_#{date}.pdf"
    send_data Certificates.pdf(date, content), type: 'text/pdf',
                                               filename: filename, disposition: 'attachment'
  end

  def new
    @birthday_celebration ||= BirthdayCelebration.new
    @members = Member.active(Date.current).to_a.sort_by(&:name).select { |m| m.age >= 15 }
    render action: :new
  end

  def edit
    @birthday_celebration ||= BirthdayCelebration.find(params[:id])
    @members = Member.active(@birthday_celebration.held_on)
        .to_a.select { |m| m.age >= 15 }.sort_by(&:name)
    @members = (@members + @birthday_celebration.sensors).uniq
    render action: :edit
  end

  def create
    @birthday_celebration = BirthdayCelebration.new(params[:birthday_celebration])
    if @birthday_celebration.save
      redirect_to @birthday_celebration,
          notice: 'Birthday celebration was successfully created.'
    else
      new
    end
  end

  def update
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    if @birthday_celebration.update(params[:birthday_celebration])
      redirect_to @birthday_celebration,
          notice: 'Birthday celebration was successfully updated.'
    else
      edit
    end
  end

  def destroy
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    @birthday_celebration.destroy
    redirect_to birthday_celebrations_url
  end
end
