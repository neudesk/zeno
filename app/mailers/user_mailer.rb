class UserMailer < ActionMailer::Base
  default from: 'Admin <admin@zenoradio.com>', :return_path => 'admin@zenoradio.com'

  def request_content(options = {})
  	@content = options
    mail(to: options["to_emails"], subject: 'Request content')
  end

  def inform_signup(user, entryway = nil, current_path, note)
    @user = user
    @current_path = current_path
    @entryway = entryway
    @note = note
    mail(to: @user.email, subject: 'Thank you for signing up')
  end

  def inform_rt(user)
    @user = user
    time = Time.now.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y')
    mail(to: 'signups@zenonetwork.com', subject: "Broadcaster Sign Up Submissions - #{time} - #{@user.email}")
  end

  def mail_new_user(template, recipient, subject, attachs, bcc)
    files = attachs.split(',')
    if files.length > 0
      files.each do |file|
        attachments["#{Time.now.to_i.to_s}.#{file.split('.').last}"] = File.read(Rails.root.join(file.to_s))
      end
    end
    mail(:to => recipient,
         :bcc => bcc,
         :from => 'signups@zenoradio.com',
         :subject => subject) do |format|
      format.html { render :inline => template }
    end
  end

end