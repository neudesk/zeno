class RequestWidgetMailer < ActionMailer::Base
  default from: 'Admin <admin@zenoradio.com>', :return_path => 'admin@zenoradio.com'

  def self.send_request_media_player_widget(options = {})
    options[:to].each do |re|
      if re == 'rt@zenoradio.com'
        request_media_player_widget_text_only(options, re).deliver
      else
        request_media_player_widget(options, re).deliver
      end
    end
  end

  def request_media_player_widget(options, recipient)
    @content = options
    attachments["logo-#{@content[:player_data].logo_file_name.to_s}"] = File.read(Rails.root.join('public', @content[:player_data].logo.path.to_s)) if @content[:player_data].logo.present?
    attachments["background-#{@content[:player_data].background_file_name.to_s}"] = File.read(Rails.root.join('public', @content[:player_data].background.path.to_s)) if @content[:player_data].background.present?
    mail(to: recipient, from: @content[:from].email, subject: @content[:subject])
  end

  def request_media_player_widget_text_only(options, recipient)
    @content = options
    attachments["logo-#{@content[:player_data].logo_file_name.to_s}"] = File.read(Rails.root.join('public', @content[:player_data].logo.path.to_s)) if @content[:player_data].logo.present?
    attachments["background-#{@content[:player_data].background_file_name.to_s}"] = File.read(Rails.root.join('public', @content[:player_data].background.path.to_s)) if @content[:player_data].background.present?
    mail(to: recipient, from: @content[:from].email, subject: @content[:subject])
  end

  def request_widget_did(gateway_object, user)
    @station = gateway_object
    @current_user = user
    mail(to: ['rt@zenoradio.com', 'jon@zenoradio.com'], from: @current_user.email, subject: 'Widget DID request')
  end

end
