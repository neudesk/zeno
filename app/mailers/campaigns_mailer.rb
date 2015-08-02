class CampaignsMailer < ActionMailer::Base
  default from: "developer@zenoradio.com"

  def send_campaign_error(options)
    @content = options
    mail(:to => "Csaba Zsigmond <zsigmondcsaba@reea.net>,Sheil Roblete <sheil@zenoradio.com>, SysAdmins <sysadmin@zenoradio.com>", :subject => "Send Campaign Error")
  end
end
