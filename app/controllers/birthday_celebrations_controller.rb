# encoding: UTF-8
class BirthdayCelebrationsController < ApplicationController
  # GET /birthday_celebrations
  # GET /birthday_celebrations.json
  def index
    @birthday_celebrations = BirthdayCelebration.order('held_on DESC').all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @birthday_celebrations }
    end
  end

  # GET /birthday_celebrations/1
  # GET /birthday_celebrations/1.json
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
    #['Oskar Flesland', 'Peter Flesland', 'Jørgen Daland Bjørnsen', 'Ulvar Jensen Fresvig', 'Nicolai Hagen',
    # 'Ismael Iturrieta-Ismail', 'Leander Mathisen', 'Jesper Skogly', 'Selmer Solland', 'Oskar Strand',
    # 'Benjamin westby', 'Haben']
    general = {
        :rank => "Innføring i Jujutsu", :group => "",
        :censor1 => bc.sensor1 ? {:title => (bc.sensor1.current_rank(MartialArt.find_by_name('Kei Wa Ryu'), bc.held_on).name =~ /dan/ ? 'Sensei' : 'Sempai'),
                                  :name => bc.sensor1.name} : nil,
        :censor2 => bc.sensor1 ? {:title => (bc.sensor2.current_rank(MartialArt.find_by_name('Kei Wa Ryu'), bc.held_on).name =~ /dan/ ? 'Sensei' : 'Sempai'),
                                          :name => bc.sensor2.name} : nil,
        :censor3 => bc.sensor1 ? {:title => (bc.sensor3.current_rank(MartialArt.find_by_name('Kei Wa Ryu'), bc.held_on).name =~ /dan/ ? 'Sensei' : 'Sempai'),
                                          :name => bc.sensor3.name} : nil,
    }

    content = participants.map{|n| general.dup.update({:name => n})}
    filename = "Certificates_birthday_#{date}.pdf"
    send_data Certificates.pdf(date, content), :type => "text/pdf",
              :filename => filename, :disposition => 'attachment'
  end

  # GET /birthday_celebrations/new
  # GET /birthday_celebrations/new.json
  def new
    @birthday_celebration = BirthdayCelebration.new
    @members = Member.order(:first_name).active(Date.today).all.select{|m| m.age >= 15}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @birthday_celebration }
    end
  end

  # GET /birthday_celebrations/1/edit
  def edit
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    @members = Member.order(:first_name).active(@birthday_celebration.held_on).all.select{|m| m.age >= 15}
  end

  # POST /birthday_celebrations
  # POST /birthday_celebrations.json
  def create
    @birthday_celebration = BirthdayCelebration.new(params[:birthday_celebration])

    respond_to do |format|
      if @birthday_celebration.save
        format.html { redirect_to @birthday_celebration, notice: 'Birthday celebration was successfully created.' }
        format.json { render json: @birthday_celebration, status: :created, location: @birthday_celebration }
      else
        format.html { render action: "new" }
        format.json { render json: @birthday_celebration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /birthday_celebrations/1
  # PUT /birthday_celebrations/1.json
  def update
    @birthday_celebration = BirthdayCelebration.find(params[:id])

    respond_to do |format|
      if @birthday_celebration.update_attributes(params[:birthday_celebration])
        format.html { redirect_to @birthday_celebration, notice: 'Birthday celebration was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @birthday_celebration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /birthday_celebrations/1
  # DELETE /birthday_celebrations/1.json
  def destroy
    @birthday_celebration = BirthdayCelebration.find(params[:id])
    @birthday_celebration.destroy

    respond_to do |format|
      format.html { redirect_to birthday_celebrations_url }
      format.json { head :no_content }
    end
  end
end
