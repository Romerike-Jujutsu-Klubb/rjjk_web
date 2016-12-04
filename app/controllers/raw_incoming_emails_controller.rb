# frozen_string_literal: true
class RawIncomingEmailsController < ApplicationController
  before_action :admin_required
  before_action :set_raw_incoming_email, only: [:show, :edit, :update, :destroy]

  def index
    @raw_emails = RawIncomingEmail.order(created_at: :desc).limit(300).decorate
  end

  def show; end

  def new
    @raw_incoming_email = RawIncomingEmail.new
  end

  def edit; end

  def create
    @raw_incoming_email = RawIncomingEmail.new(raw_incoming_email_params)

    respond_to do |format|
      if @raw_incoming_email.save
        format.html do
          redirect_to @raw_incoming_email, notice: 'Raw incoming email was successfully created.'
        end
        format.json { render :show, status: :created, location: @raw_incoming_email }
      else
        format.html { render :new }
        format.json { render json: @raw_incoming_email.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @raw_incoming_email.update(raw_incoming_email_params)
        format.html do
          redirect_to @raw_incoming_email, notice: 'Raw incoming email was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @raw_incoming_email }
      else
        format.html { render :edit }
        format.json { render json: @raw_incoming_email.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @raw_incoming_email.destroy
    respond_to do |format|
      format.html do
        redirect_to raw_incoming_emails_url,
            notice: 'Raw incoming email was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_raw_incoming_email
    @raw_incoming_email = RawIncomingEmail.find(params[:id]).decorate
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def raw_incoming_email_params
    params.require(:raw_incoming_email).permit(:content)
  end
end
