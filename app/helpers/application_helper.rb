# encoding: UTF-8
require 'redbox_helper'

module ApplicationHelper
  include UserSystem
  include RedboxHelper

  def menu_item(name, options = {})
    options[:controller] ||= 'info'
    link_to name, {:controller => options[:controller], :action => options[:action], :id => options[:id]}, :class => [controller.controller_name, controller.action_name, params[:id].to_s] == [options[:controller].to_s, options[:action].to_s, options[:id].to_s] ? 'active' : nil
  end

  def yes_no(bool)
    if bool == true
      'Ja'
    else
      'Nei'
    end
  end

  def l(time)
    return t(time) if time.is_a?(Symbol) || time.is_a?(String)
    super
  end

  def t(time)
    return super if time.is_a?(Symbol) || time.is_a?(String)
    time && time.strftime('%H:%M')
  end

  def wday(wday_index)
    %w{Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag Søndag}[wday_index]
  end

  def textalize(s)
    return '' if s.nil?
    s.gsub! /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i do |m|
      mail_to m, nil # , :encode => :javascript
    end
    html = RedCloth.new(s.strip).to_html
    if @email
      base = url_for(:controller => :welcome, :action => :index, :only_path => false)

      html.gsub!(/\b(href|src)="(?:#{base}|\/)([^?"]*)(\?[^"]*)?"/i) do |m|
        %Q{#$1="#{base}#$2#$3#{$3 ? '&' : '?'}email=#{Base64.encode64(@email)}#{"&newsletter_id=#{@newsletter.id}" if @newsletter}"}
      end

      html.gsub! /(<a href="[^"]*")>/i, %Q{\\1 style="color: #CD071E;text-decoration:none;font-weight:bold;">}
    end
    html.html_safe
  end

  def textify(s)
    return '' if s.blank?
    RedCloth.new(s.strip).to_plain
  end

end
