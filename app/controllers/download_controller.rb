class DownloadController < ApplicationController
  def download
    # @station = DataGateway.find_by_id(SymmetricEncryption.decrypt(params[:secret_code]))
    # unless `find lib/java_compiler/compiled_apks -name "#{@station.id}".apk`.present?
    #   #generate APK
    #   @station_name = @station.title.parameterize.underscore
    #   `"#{Rails.root}/lib/java_compiler/generate_files.sh" "#{@station_name}" #{params[:url]}`

    #   File.open("lib/java_compiler/tmp/#{@station_name}/res/values/strings.xml", "w") do |f|
    #     f.write('<?xml version="1.0" encoding="utf-8"?>')
    #     f.write('<resources>')
    #     f.write('<string name="app_name">test</string>')
    #     f.write('<string name="hello_world">Hello world!</string>')
    #     f.write('<string name="menu_settings">Settings</string>')
    #     f.write("<string name=\"website\">#{params[:url]}</string>")
    #     f.write('<string name="browser">Choose a browser</string>')
    #     f.write('</resources>')
    #   end
    #   if @station.logo.present?
    #     `"#{Rails.root}/lib/java_compiler/delete_pictures.sh" "#{@station_name}"`
    #     source_path = "public#{@station.logo.url(:xhdpi)}".partition('?')[0]
    #     destination_path = "lib/java_compiler/tmp/#{@station_name}/res/drawable-xhdpi/ic_launcher." + @station.logo_file_name.split(".").last
    #     `cp "#{source_path}" "#{destination_path}"`

    #     source_path = "public#{@station.logo.url(:hdpi)}".partition('?')[0]
    #     destination_path = "lib/java_compiler/tmp/#{@station_name}/res/drawable-hdpi/ic_launcher." + @station.logo_file_name.split(".").last
    #     `cp "#{source_path}" "#{destination_path}"`

    #     source_path = "public#{@station.logo.url(:mdpi)}".partition('?')[0]
    #     destination_path = "lib/java_compiler/tmp/#{@station_name}/res/drawable-mdpi/ic_launcher." + @station.logo_file_name.split(".").last
    #     `cp "#{source_path}" "#{destination_path}"`

    #     source_path = "public#{@station.logo.url(:ldpi)}".partition('?')[0]
    #     destination_path = "lib/java_compiler/tmp/#{@station_name}/res/drawable-ldpi/ic_launcher." + @station.logo_file_name.split(".").last
    #     `cp "#{source_path}" "#{destination_path}"`
    #   end
    # end
    if request.user_agent.include?("Android")
      send_file "#{Rails.root}/public/embed/GhanaRadioNow.apk", type: "application/vnd.android.package-archive", disposition: 'attachment', filename: "GhanaRadioNow.APK"
    elsif !(request.user_agent.include?("iPhone") || request.user_agent.include?("iPad"))
      url = params[:url] || "http://ghanaradionow.com"
      content = %Q{<html><body onload="window.location='#{url}'"></body></html>}
      send_data(content, type: 'text/html; charset=utf-8; header=present', filename: "bookmark.html")      
    end
  end
end