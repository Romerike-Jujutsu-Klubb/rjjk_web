# frozen_string_literal: true

class SignaturesController < ApplicationController
  before_action :admin_required

  def index
    @signatures = Signature.all
  end

  def show
    @signature = Signature.find(params[:id])
  end

  def image
    @signature = Signature.find(params[:id])
    send_data(@signature.image,
        disposition: 'inline',
        type: @signature.content_type,
        filename: @signature.name)
  end

  def new
    @signature ||= Signature.new(member: current_user.member)
    load_form_data
    render action: :new
  end

  def edit
    @signature ||= Signature.find(params[:id])
    load_form_data
    render action: :edit
  end

  def create
    @signature = Signature.new(params[:signature])
    if @signature.save
      redirect_to member_path(@signature.member, anchor: :tab_signatures_tab),
          notice: 'Signatur lagret.'
    else
      new
    end
  end

  def update
    @signature = Signature.find(params[:id])
    if @signature.update(params[:signature])
      redirect_to @signature, notice: 'Signaturen ble oppdatert.'
    else
      edit
    end
  end

  def destroy
    @signature = Signature.find(params[:id])
    @signature.destroy!
    redirect_to user_path(@signature.member.user_id, anchor: :tab_signatures_tab)
  end

  private

  def load_form_data
    @members = Member.active(Date.current).with_user.order('users.birthdate').to_a
  end
end
