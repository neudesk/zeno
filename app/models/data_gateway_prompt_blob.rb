class DataGatewayPromptBlob < ActiveRecord::Base
  attr_accessible :id, :binary

  has_one :data_gateway_prompt, :foreign_key => "id"

  def get_mp3
    Util::AudioConverter.bin_audio_convert(binary, Util::AudioConverter::GSM, Util::AudioConverter::MP3)
  end

  def get_wav
    Util::AudioConverter.bin_audio_convert(binary, Util::AudioConverter::GSM, Util::AudioConverter::WAV)
  end
end

# == Schema Information
#
# Table name: data_gateway_prompt_blob
#
#  id     :integer          not null, primary key
#  binary :binary(214748364
#

