module SettingsHelper
   
  def split_str(str, len = 10)
    fragment = /.{#{len}}/
    str.split(/(\s+)/).map! { |word|
      (/\s/ === word) ? word : word.gsub(fragment, '\0<br />')
    }.join
  end

  def display_activity(activity)
    text = ""
    hover = ""
    key, action = activity.key.split(".")
    
    case key
    when "data_gateway"
      case action
      when "add_phone"
        text = "Phone number #{activity.sec_trackable_title} added"
        hover = "#{activity.owner.title} added phone number #{activity.sec_trackable_title} last #{html_datetime(activity.created_at)}"
      when "create_entryway"
        text = "Phone number #{activity.sec_trackable_title} added"
        hover = "#{activity.owner.title} added phone number #{activity.sec_trackable_title} last #{html_datetime(activity.created_at)}"
      when "create_prompt"
        text = "Uploaded new prompt: #{activity.sec_trackable_title}"
        hover = "#{activity.owner.title} uploaded new prompt #{activity.sec_trackable_title} last #{html_datetime(activity.created_at)}"
      when "destroy_entryway"
      when "destroy_gateway"
      when "destroy_prompt"
        text = "Deleted prompt: #{activity.sec_trackable_title}"
        hover = "#{activity.owner.title} deleted prompt #{activity.sec_trackable_title} last #{html_datetime(activity.created_at)}"
      when "move_content"
        text = "#{activity.sec_trackable_title} channel was changed from #{activity.parameters[:old_extension]} to #{activity.parameters[:extension_id]}"
        hover = "#{activity.owner.title} change the channel of #{activity.sec_trackable_title} from #{activity.parameters[:old_extension]} to #{activity.parameters[:new_extension]} last #{html_datetime(activity.created_at)}"
      when "remove_phone"
        text = "Deleted phone number #{activity.trackable_title}"
        hover = "#{activity.owner.title} deleted phone number #{activity.trackable_title} last #{html_datetime(activity.created_at)}"
      when "tag_rca"
      when "untag_rca"
      end
    when "data_content"
      case action
      when "change_name"
        if activity.parameters[:old_name].present?
          text = "#{activity.parameters[:old_name]} was changed to #{activity.parameters[:new_name]}"
          hover = "#{activity.owner.title} change name from #{activity.parameters[:old_name]} was changed to #{activity.parameters[:new_name]} last #{html_datetime(activity.created_at)}"
        else
          text = ""
          hover = "none"
        end
      when "change_stream_url"
      when "create"
      when "destroy"
      when "switch_stream"
        text = "Switched Main and BackUp URL of #{activity.trackable_title}"
        hover = "#{activity.owner.title} switched main and backup URL of #{activity.sec_trackable_title} last #{html_datetime(activity.created_at)} last #{html_datetime(activity.created_at)}"
      when "update"
      end
    when "data_gateway_conference"
      case action
      when "create"
      when "destroy"
      end
    end
    hover.present? ? [text, hover] : [activity.key, nil]
  end
end