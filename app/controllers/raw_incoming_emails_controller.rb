class RawIncomingEmailsController < ApplicationController
  before_action :set_raw_incoming_email, only: [:show, :edit, :update, :destroy]

  # GET /raw_incoming_emails
  # GET /raw_incoming_emails.json
  def index
    @raw_incoming_emails = RawIncomingEmail.all
  end

  # GET /raw_incoming_emails/1
  # GET /raw_incoming_emails/1.json
  def show
  end

  # GET /raw_incoming_emails/new
  def new
    @raw_incoming_email = RawIncomingEmail.new
  end

  # GET /raw_incoming_emails/1/edit
  def edit
  end

  # POST /raw_incoming_emails
  # POST /raw_incoming_emails.json
  def create
    @raw_incoming_email = RawIncomingEmail.new(raw_incoming_email_params)

    respond_to do |format|
      if @raw_incoming_email.save
        format.html { redirect_to @raw_incoming_email, notice: 'Raw incoming email was successfully created.' }
        format.json { render :show, status: :created, location: @raw_incoming_email }
      else
        format.html { render :new }
        format.json { render json: @raw_incoming_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /raw_incoming_emails/1
  # PATCH/PUT /raw_incoming_emails/1.json
  def update
    respond_to do |format|
      if @raw_incoming_email.update(raw_incoming_email_params)
        format.html { redirect_to @raw_incoming_email, notice: 'Raw incoming email was successfully updated.' }
        format.json { render :show, status: :ok, location: @raw_incoming_email }
      else
        format.html { render :edit }
        format.json { render json: @raw_incoming_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /raw_incoming_emails/1
  # DELETE /raw_incoming_emails/1.json
  def destroy
    @raw_incoming_email.destroy
    respond_to do |format|
      format.html { redirect_to raw_incoming_emails_url, notice: 'Raw incoming email was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_raw_incoming_email
      @raw_incoming_email = RawIncomingEmail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def raw_incoming_email_params
      params.require(:raw_incoming_email).permit(:content)
    end
end
