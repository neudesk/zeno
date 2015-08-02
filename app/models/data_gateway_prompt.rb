class DataGatewayPrompt < ActiveRecord::Base
  require 'open3'
  include PublicActivity::Common

  attr_accessible :title, :media_kb, :media_seconds, :date_last_change, :data_gateway_prompt_blob_attributes, :raw_audio, :gateway_id
  attr_accessor :raw_audio

  has_one :data_gateway_prompt_blob, :foreign_key => "id", :dependent => :destroy

  has_many :welcome_data_gateways, class_name: "DataGateway", foreign_key: :ivr_welcome_prompt_id, dependent: :nullify
  has_many :ask_data_gateways, class_name: "DataGateway", foreign_key: :ivr_extension_ask_prompt_id, dependent: :nullify
  has_many :invalid_data_gateways, class_name: "DataGateway", foreign_key: :ivr_extension_invalid_prompt_id, dependent: :nullify

  belongs_to :data_gateway, foreign_key: :gateway_id

  has_many :data_carrier_rules

  accepts_nested_attributes_for :data_gateway_prompt_blob, :allow_destroy => true

  CONVERT_OK = 1
  INVALID_FORMAT = 2

  def self.convert_uploaded_audio(upload_audio_file)
    data = ""
    if upload_audio_file.present? && (upload_audio_file.content_type == "audio/mpeg" || upload_audio_file.content_type == "audio/mp3" || upload_audio_file.content_type == "audio/x-wav" || upload_audio_file.content_type == "audio/wav")
      raw_data = upload_audio_file.read

      if upload_audio_file.content_type == "audio/mpeg" || upload_audio_file.content_type == "audio/mp3"
        data = Util::AudioConverter.bin_audio_convert(raw_data, Util::AudioConverter::MP3, Util::AudioConverter::GSM)
      else
        data = Util::AudioConverter.bin_audio_convert(raw_data, Util::AudioConverter::WAV, Util::AudioConverter::GSM)
      end

      duration = Util::AudioConverter.bin_audio_duration(data, Util::AudioConverter::GSM)

      media_kb = data.size/1024

      def data.duration=(value)
        @duration = value
      end

      def data.duration
        @duration
      end

      data.duration= duration

      def data.media_kb=(value)
        @media_kb = value
      end

      def data.media_kb
        @media_kb
      end

      data.media_kb= media_kb

      def data.status
        CONVERT_OK
      end

    else
      def data.status
        INVALID_FORMAT
      end

    end

    data

  end

end

# == Schema Information
#
# Table name: data_gateway_prompt
#
#  id               :integer          not null, primary key
#  title            :string(200)
#  gateway_id       :integer
#  media_kb         :integer          default(0)
#  media_seconds    :integer          default(0)
#  date_last_change :datetime
#
# Indexes
#
#  fk_data_gateway_prompt_1_idx  (gateway_id)
#

