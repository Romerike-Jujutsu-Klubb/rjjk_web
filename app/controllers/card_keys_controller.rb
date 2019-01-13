# frozen_string_literal: true

class CardKeysController < ApplicationController
  before_action :set_card_key, only: %i[show edit update destroy]

  def index
    @card_keys = CardKey.all.sort_by { |ck| [ck.user&.name || '', ck.label] }
  end

  def show; end

  def new
    @card_key ||= CardKey.new
    load_form_data
    render :new
  end

  def edit
    load_form_data
    render :edit
  end

  def create
    @card_key = CardKey.new(card_key_params)
    if @card_key.save
      redirect_to card_keys_path, notice: 'Card key was successfully created.'
    else
      new
    end
  end

  def update
    if @card_key.update(card_key_params)
      redirect_to card_keys_path, notice: 'Card key was successfully updated.'
    else
      edit
    end
  end

  def destroy
    @card_key.destroy
    respond_to do |format|
      format.html { redirect_to card_keys_url, notice: 'Card key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def load_form_data
    @users = Member.active.includes(:user).map(&:user).sort_by(&:name)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_card_key
    @card_key = CardKey.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def card_key_params
    params.require(:card_key).permit(:label, :office_key, :user_id, :comment)
  end
end
