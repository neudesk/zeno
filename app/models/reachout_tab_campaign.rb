class ReachoutTabCampaign < ActiveRecord::Base
  require 'open3'
  require 'open-uri'
  require 'digest/md5'

  include PublicActivity::Model
  
  attr_accessible :gateway_id, :prompt, :did_e164, :generic_prompt, :schedule_end_date, :schedule_start_date, :campaign_id, :status, :data_gateway_attributes,
    :main_id, :listeners_no, :did_provider, :carrier_title, :created_by, :campaign_saved, :dpaste_link
  before_save :convert_to_wav

  validates :gateway_id , :presence => {:on => :create}
  validates :schedule_start_date , :presence => {:on => :create}
  validates :schedule_end_date , :presence => {:on => :create}
  
  has_attached_file :prompt, :presence => {:on => :create}
  belongs_to :data_gateway, foreign_key: :gateway_id
  belongs_to :creator, class_name: "User", foreign_key: :created_by
  accepts_nested_attributes_for :data_gateway
 
  validates_attachment_content_type :prompt, :content_type => ['audio/wav', 'audio/x-wav', 'audio/wave', 'audio/x-pn-wav',"audio/mpeg", "audio/mp3" ]

  
  def statistics
   campaign_ids = ReachoutTabCampaign.where(:main_id => self.id).map(&:id)
   na, pm, pu, total_all = 0, 0, 0, 0
   campaigns = GoAutoDial.get_campaigns_statuses(campaign_ids)
   if campaigns.present?
    campaign_ids.each do |c|
      if campaigns[c.to_s].present?
        if campaigns[c.to_s]["total_stats"].present?
          total_all += campaigns[c.to_s]["totalAll"].to_i
          if campaigns[c.to_s]["total_stats"].present?
            campaigns[c.to_s]["total_stats"].each do |stats|
              if stats["status"] == "NA"
                na += stats["status_yes"].to_i
              elsif stats["status"] == "PM"
                pm += stats["status_yes"].to_i
              elsif stats["status"] == "PU"
                pu += stats["status_yes"].to_i
              else
                na += stats["status_yes"].to_i
              end
            end
          end
        end
      end
    end
  end
  pm_percent = (pm > 0) ? 100 * (pm.to_f / total_all) : 0
  pu_percent = (pu > 0) ? 100 * (pu.to_f / total_all) : 0
  na_percent = (na > 0) ? 100 * (na.to_f / total_all) : 0
  {"total_all" => total_all, "pm" => pm, "pu" => pu, "na" => na, "pm_percent" => pm_percent, "pu_percent" => pu_percent, "na_percent" => na_percent}
  end

  def convert_to_wav
    if self.prompt.present? and self.prompt.queued_for_write[:original]
      data = File.read(self.prompt.queued_for_write[:original].path)
      if self.prompt.content_type == "audio/mp3" || self.prompt.content_type == "audio/mpeg"
        file = Util::AudioConverter.bin_audio_convert(data, "mp3", "wav")
        wavfile = Tempfile.new([self.prompt.original_filename.chomp('.mp3'), ".wav"])
      else
        file = Util::AudioConverter.bin_audio_convert(data, "wav", "wav")
        wavfile = Tempfile.new([self.prompt.original_filename.chomp('.wav'), ".wav"])
      end
      wavfile.binmode
      wavfile.write(file)
      self.prompt = wavfile
      self.prompt_file_name = Digest::MD5.hexdigest(self.prompt_file_name) + ".wav"
    end
  end
end
