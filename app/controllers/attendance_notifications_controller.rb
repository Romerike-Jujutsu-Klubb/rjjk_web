# frozen_string_literal: true

# https://serviceworke.rs/push-rich.html

class AttendanceNotificationsController < ApplicationController
  before_action :admin_required

  def index; end

  def subscribe
    subscription = params[:subscription].to_unsafe_hash
    AttendanceWebpush.where(member_id: current_user.member.id, endpoint: subscription[:endpoint],
            p256dh: subscription[:keys][:p256dh], auth: subscription[:keys][:auth]).first_or_create!
    head :ok
  end

  def push
    AttendanceWebpush.push_all("Hello world, the time is #{Time.zone.now}", 'All is well.', tag: :test)
    head :ok
  end
end
