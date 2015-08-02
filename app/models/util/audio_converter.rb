module Util

  module AudioConverter
    GSM = "gsm"
    MP3 = "mp3"
    WAV = "wav"
    # Convert from binary data
    def self.bin_audio_convert(data, from_type, to_type)
      Open3.capture2("sox -t #{from_type} - -r 8000 -c1 -t #{to_type} - ", :stdin_data => data, :binmode=>true)[0]
    end

    # Get duration of a binary data
    def self.bin_audio_duration(data, type)
      Open3.capture2("sox -t #{type} - -n stat 2>&1 | sed -n 's#^Length (seconds):[^0-9]*\\([0-9.]*\\)$#\\1#p'", :stdin_data => data, :binmode=>true)[0].to_i
    end

  end
end