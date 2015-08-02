module ApplicationHelper
  def get_list_weeks_of_current_year
    start = DateTime.now.beginning_of_year
    ende = DateTime.now.end_of_year

    weeks = []
    while start < ende
      weeks << ["#{start.strftime("%b")} #{start.beginning_of_week.strftime("%d")}-#{start.end_of_week.strftime("%d")}", start.cweek]  # <-- enhanced
      start += 1.week
    end
    weeks
  end

  def get_hours_list
    hours = []
    (1..24).each do |t|
      hours << t
    end

    hours
  end

  def cut_string(str)
    if str.length > 60
      return "#{str[0..60]}..."
    else
      return str
    end
  end

  def format_decimal(number)
    number_with_delimiter(number, :delimiter => ',') 
  end


  def get_4_weeks_name
    start = DateTime.current.beginning_of_week
    ende = DateTime.current.end_of_week

    @result = []

    (0..7).each do |i|
      @result << "#{start.strftime("%b %d")}-#{ende.strftime("%d")}"
      start -= 1.week
      ende -= 1.week
    end

    @result
    # start = DateTime.now.beginning_of_year
    # ende = DateTime.now.end_of_year

    # weeks = []
    # _4weeks= []
    # while start < ende
    #   weeks << ["#{start.strftime("%b")} #{start.beginning_of_week.strftime("%d")}-#{start.end_of_week.strftime("%d")}", start.cweek]  # <-- enhanced
    #   prev_month = DateTime.now - 1.month
    #   if start.strftime("%b") == Date.today.strftime("%b") || start.strftime("%b") == prev_month.strftime("%b")
    #     # puts "#{start.strftime("%b")} #{start.beginning_of_week.strftime("%d")}-#{start.end_of_week.strftime("%d")} => #{start.cweek}"
    #     # _4weeks << ["#{start.strftime("%b")} #{start.beginning_of_week.strftime("%d")}-#{start.end_of_week.strftime("%d")}", start.cweek]  # <-- enhanced
    #     _4weeks << "#{start.strftime("%b")} #{start.beginning_of_week.strftime("%d")}-#{start.end_of_week.strftime("%d")}"  # <-- enhanced
    #   end
    #   start += 1.week
    # end

    # _4weeks.reverse
  end

  def current_week 
    [Date.today.beginning_of_month.strftime("%b"), 
     Date.today.beginning_of_week.strftime("%d"), "-",
     Date.today.end_of_week.strftime("%d")].join(" ")
  end 

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}.merge({gateway_id: params[:gateway_id], week: params[:week], page: params[:page]}), {:class => css_class}
  end

  def cal_percent(a,b)
    if (b.blank? || b.nil?) && a.blank?
      return ""
    end

    a = a.to_f
    b = b.to_f
    c = a - b
    
    if a == 0
      return ""
    end

    c = (c / a) * 100
    return "#{print2digits(c)}%"
  end

  def print2digits(a)
    if a.blank?
      return ""
    end

    return sprintf("%02.2f", a)
  end

  #Slider sort order has changed to horizontal order
  #This method helps to change verical order to horizontal order
  #item_size: size of items need to be displayed
  #w: width of a slider page
  #h: height of a slider page
  #Example: 
  #1  4  7  10
  #2  5  8  11
  #3  6  9  12
  #============
  #1  2  3  4
  #5  6  7  8
  #9  10 11 12
  def cal_slider_pos_arr(item_size, w, h)
    r = []
    page_size = (item_size.to_f/(h*w).to_f).ceil
    (1..page_size).each do |page|
      offset = (page-1) * (h*w)
      (1..w).each do |i|
        (1..h).each do |j|
          r<<(offset+i+(j-1)*w-1)
        end
      end
    end
    r
  end

  def sort_slider_stations(stations, w, h)
    size = stations.length
    slider_pos_arr = cal_slider_pos_arr(size, w, h)
    result = []
    slider_pos_arr.each_with_index do |pos, index|
      result[index] = stations[pos]
    end
    
    result
  end

  def cal_slider_height(stations_size)
    height = stations_size <= 16 ? 1 : (stations_size <= 32 ? 2 : 3)
    height
  end

  def html_group_name(user)
    role = user.permission_id.to_i
    current_group_name = nil
    case role
      when 2
        data_group = user.sys_user_resource_3rdparties
        current_group_name = data_group.first.data_group_3rdparty.title rescue nil
      when 3
        data_group = user.sys_user_resource_broadcasts
        current_group_name = data_group.first.data_group_broadcast.title rescue nil
      when 4
        data_group = user.sys_user_resource_rcas
        current_group_name = data_group.first.data_group_rca.title rescue nil
    end
    return current_group_name
  end

  def html_role(status, permission_id)
    return nil unless status.present?
    if status == "Broadcast user"
      content_tag :div, class: "btn btn-purple btn-squared btn-xs sort_role", data: {permission: permission_id} do
        "Broadcaster"
      end
    elsif status == "Super user"
      content_tag :div, class: "btn btn-orange btn-squared btn-xs sort_role", data: {permission: permission_id} do
        "Administrator"
      end
    elsif status == "3rd party user"
      content_tag :div, class: "btn btn-red btn-squared btn-xs sort_role", data: {permission: permission_id} do
        "Third Party"
      end
    elsif status == "RCA user"
      content_tag :div, class: "btn btn-teal btn-squared btn-xs sort_role", data: {permission: permission_id} do
        "RCA"
      end
    elsif status == "Zenoradio employee"
      content_tag :div, class: "btn btn-beige btn-squared btn-xs", data: {permission: permission_id} do
        "Employee"
      end
    end
  end

  def report_sort_link(path, name, column, target)
    html  = "<a href='#{path}?column=#{column}&target=#{target}&order=#{(params[:order] == 'asc' ? 'desc' : 'asc')}'>"
    if params[:column] == column and params[:target] == target
      html += "<i class='fa fa-sort-#{params[:order]}'></i>"
    else
      html += "<i class='fa fa-sort'></i>"
    end
      html += " #{name}"
    html += "</a>"
    html.html_safe
  end

  def values_trend(previous, current, percentage, show_previous=false, from=nil, to=nil )
    previous, current = previous.to_i, current.to_i
    changes = '-'
    alert = nil
    icon = nil
    if current == 0 or previous == 0
      alert = 'default'
      icon = 'down'
    elsif current < previous
      alert = 'danger'
      icon = 'down'
    elsif current > previous
      alert = 'success'
      icon = 'up'
    else
      alert = 'default'
      icon = 'down'
    end
    html = "<span class='label label-#{alert} reporting'>"
      html += "<i class='fa fa-chevron-#{icon}'></i>"
      html += "<span>"
        html += " #{number_with_delimiter(current.to_i, delimiter: ',')} "
        if to
          html += "<i class='fa fa-info-circle icon-smaller' tip='#{to}'></i></small>"
        end
        if show_previous
          html += "<br /><small style='margin-left: 18px'> #{number_with_delimiter(previous.to_i, delimiter: ',')} <i class='fa fa-info-circle icon-smaller' tip='#{from}'></i></small>"
        end
      html += "</span>"
      html += "<small class='pull-right'>#{percentage}%</small><span class='clearfix'></span>"
    html += "</span>"
    html.html_safe
  end

  def roles_for_new_select
    options = []
    x = SysUserPermission.find_by_title("Super user")
    options << ["Administrator", x.id]
    x = SysUserPermission.find_by_title("RCA User")
    options << ["RCA", x.id]
    x = SysUserPermission.find_by_title("3rd party user")
    options << ["Third Party", x.id]
    x = SysUserPermission.find_by_title("Broadcast user")
    options << ["Broadcaster", x.id]
    return options
  end

  def roles_for_new_select_with_all
    options = []
    options << ["All", 0]
    x = SysUserPermission.find_by_title("Super user")
    options << ["Administrator", x.id]
    x = SysUserPermission.find_by_title("RCA User")
    options << ["RCA", x.id]
    x = SysUserPermission.find_by_title("3rd party user")
    options << ["Third Party", x.id]
    x = SysUserPermission.find_by_title("Broadcast user")
    options << ["Broadcaster", x.id]
    return options
  end

  def displayable_tags(tags, count = 0)
    return nil unless tags.present?
    html = ""
    if count == 0
      tags.each do |tag|
        html << "<span class='label label-inverse inlined-block'>#{tag.title}</span>&nbsp;&nbsp;"
      end
    else
      tags.limit(3).each do |tag|
        html << "<span class='label label-inverse inlined-block'>#{tag.title}</span>&nbsp;&nbsp;"
      end
    end
    html.html_safe
  end

  def displayable_countries(countries, count = 0)
    return nil unless countries.present?
    html = ""
    if count == 0
      countries.each do |tag|
        html << "<span class='label label-inverse inlined-block'>#{tag.title}</span>&nbsp;&nbsp;"
      end
    else
      countries.limit(3).each do |tag|
        html << "<span class='label label-inverse inlined-block'>#{tag.title}</span>&nbsp;&nbsp;"
      end
    end
    html.html_safe
  end

  def display_status(status, note = nil)
    return nil unless status.present?
    if status == "unprocessed"
      content_tag :span, class: "label label-inverse"  do
        #status.titleize
        ""
      end
    elsif status == "pending_info"
      content_tag :span, class: "label label-success",  :tip => note do
        status.gsub('_', ' ').titleize
      end
    elsif status == "pending_reply"
      content_tag :span, class: "label label-warning",  :tip => note do
        status.gsub('_', ' ').titleize
      end
    elsif status == "pending_services"
      content_tag :span, class: "label label-default",  :tip => note do
        status.gsub('_', ' ').titleize
      end
    elsif status == "ignored"
      content_tag :span, class: "label label-info" do
        status.titleize
      end
    elsif status == "duplicate"
      content_tag :span, class: "label label-danger" do
        status.titleize
      end
    elsif status == "processed"
      content_tag :span, class: "label label-success" do
        status.titleize
      end
    elsif status == "enabled"
      content_tag :span, class: "label label-success" do
        status.titleize
      end
    elsif status == "disabled"
      content_tag :span, class: "label label-danger" do
        status.titleize
      end
    elsif status == "Completed"
      content_tag :span, class: "label label-danger completed" do
        status.titleize
      end
    elsif status == "Started"
      content_tag :span, class: "label label-warning" do
        status.titleize
      end
    elsif status == "Active"
      content_tag :span, class: "label label-success" do
        status.titleize
      end
    else
      content_tag :span, class: "label label-inverse" do
        status.titleize
      end
    end
  end

  def role_for(id)
    return nil unless id.present?
    role = SysUserPermission.find_by_id(id)
    return nil unless role.present?

    x = case role.title
    when "Super user"
      "Marketer"
    when "RCA User"
      "RCA"
    when "3rd party user"
      "Third Party"
    when "Broadcast user"
      "Broadcaster"
    end
    return x
  end

  def html_date(date)
    return nil unless date.present?
    date.strftime("%B %d, %Y")
  end

  def html_datetime(date)
    return nil unless date.present?
    date.strftime("%B %d, %Y %l:%M%p")
  end

  def shared_params(id = nil, path = nil)
    parameters = params.dup
    parameters.delete(:controller)
    parameters.delete(:action)
    parameters.delete(:utf8)

    parameters[:station_id] = id unless id.nil?

    if path.present?
      str = path + "?"
      x = 1
      parameters.each do |key,value|
         str << "&" if x == 1
        if key == "q"
          xx = 1
          value.each do |kk,vv|
            if xx == 1 ? xx += 1 : str << "&"
              str += "q[#{key}]=#{value.to_s}"
            end
          end
          xx += 1
        else
          str += "#{key}=#{value.to_s}"
        end
        x += 1
      end
      str
    else
      parameters
    end
  end

  def html_days
    days = []
    (0..6).each do |x|
      days << (Date.today + x).strftime("%a")
    end
    return days
  end

  def last_week_minutes(station)
    return [] unless station.present?
    minutes = []
    (0..6).each do |x|
      reports = station.reports.where(report_date: ((Date.today - 7) + x))
      if reports.present?
        minutes << reports.collect(&:total_minutes).sum.to_i
      else
        minutes << 0
      end
    end
    return minutes
  end

  def html_class_for(activity)
    return nil unless activity.present?
    model, action = activity.key.split(".")
    if action.include?("destroy")
      return "bricky"
    else
      case model
      when "user"
        "green"
      when "data_gateway_conference"
        "teal"
      when "data_content"
        "purple"
      when "data_gateway"
        "purple"
      else
        ""
      end
    end
  end

  def timeline_color(action)
    color = {'create' => '156, 220, 252',
             'create_prompt' => '156, 220, 252',
             'create_entryway' => '156, 220, 252',
             'request_snippet' => '156, 220, 252',
             'add_phone' => '156, 220, 252',
             'unlock' => '156, 220, 252',
             'destroy' => '165, 0, 0',
             'destroy_entryway' => '165, 0, 0',
             'destroy_prompt' => '165, 0, 0',
             'unassigned_welcome_prompt' => '165, 0, 0',
             'unassigned_ask_extension_prompt' => '165, 0, 0',
             'remove_phone' => '165, 0, 0',
             'user_destroyed' => '165, 0, 0',
             'login' => '0, 128, 0',
             'update' => '255, 216, 0',
             'switch_stream' => '255, 216, 0',
             'change_name' => '255, 216, 0',
             'media_type' => '255, 216, 0',
             'move_content' => '255, 216, 0',
             'update_welcome_prompt' => '255, 216, 0',
             'update_ask_extension_prompt' => '255, 216, 0',
             'update_broadcaster' => '255, 216, 0',
             'update_station_name' => '255, 216, 0',
             'update_language' => '255, 216, 0',
             'update_country' => '255, 216, 0',
             'update_rca' => '255, 216, 0',
             'update_information' => '255, 216, 0',
             'tagging' => '255, 216, 0',
             'grouping' => '255, 216, 0',
             'switch' => '255, 216, 0',
             'change_stream_url' => '255, 216, 0',
             'lock' => '255, 216, 0'
    }
    color[action]
  end

  def timeline_icon_for(activity)
    return nil unless activity.present?
    model, action = activity.key.split(".")
    if action.include?("destroy")
      "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
        <i class='fa fa-trash'></i>
      </div>".html_safe
    else
      case model
      when "user"
        "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)}'>
          <i class='fa fa-user'></i>
        </div>".html_safe
      when "data_gateway_conference"
        "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-whatsapp'></i>
        </div>".html_safe
      when "data_content"
        "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-link'></i>
        </div>".html_safe
      when "data_gateway"
        "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-rss'></i>
        </div>".html_safe
      when "reachout_tab_campaign"
        "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-flag'></i>
        </div>".html_safe
      when "admin_setting"
        "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-gears'></i>
        </div>".html_safe
      when "data_group_rca"
          "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-user-secret'></i>
        </div>".html_safe
        when "data_gateway_note"
          "<div class='timeline-badge #{action}' style='background: rgba(#{timeline_color(action)}, 1)'>
          <i class='fa fa-file-o'></i>
        </div>".html_safe
      else
        ""
      end
    end
  end

  def get_day_label(idx)
    days = {'-1' => 'Default',
            '0' => 'Sunday',
            '1' => 'Monday',
            '2' => 'Tuesday',
            '3' => 'Wednesday',
            '4' => 'Thursday',
            '5' => 'Friday',
            '6' => 'Saturday'}
    days[idx]
  end

  def signup_local(field)
    params[:local] ||= 'en'
    lib = {accountinfo: {'en' => 'Account Information',
                         'es' => 'Información de Cuenta',
                         'ar' => ' معلوماتك الخاصه',
                         'fr' => 'Information du compte'},
           stationinfo: {'en' => 'Station Information',
                         'es' => 'Información de Estación',
                         'ar' => ' معلومات محطتك الاذاعيه',
                         'fr' => 'Information de la Radio'},
           header: {'en' => 'Join ZenoRadio\'s network of stations, the fastest growing network of immigrant focused content in the U.S',
                    'es' => 'Únete a la red de estaciones de ZenoRadio la red mas rápida en crecimiento, enfocado en contenido para la comunidad inmigrante en Estados Unidos.',
                    'ar' => '
باقه اذاعات زينو راديو العالميه فى الولايات المتحدة الامريكيه تقدم خدماتها الى جميع المهاجريين من كل الجنسيات مما يتيح لاذاعتك الفرصه لمضاعفه عدد المستمعيين',
                    'fr' => 'Rejoignez la plateforme de Radios sur ZenoRadio, le réseau croissant le plus rapide des programmes destinés aux immigrants concentrés aux États-Unis'},
           email: {'en' => 'Email Address',
                   'es' => 'Correo Electrónico',
                   'ar' => '  عنوان بريدك الالكترونى',
                   'fr' => 'Adresse Email'},
           landline: {'en' => 'Phone Number',
                      'es' => 'Número de Teléfono',
                      'ar' => ' رقم الهاتف',
                      'fr' => 'Numero de téléphone'},
           station_name: {'en' => 'Station Name',
                          'es' => 'Nombre de Estación',
                          'ar' => ' اسم محطتك الاذاعيه ',
                          'fr' => 'Nom de la Radio'},
           company_name: {'en' => 'Company/Name',
                          'es' => 'Compania/Nombre',
                          'ar' => ' اسم شركتك ',
                          'fr' => 'Compagnie/Nom'},
           website: {'en' => 'Website',
                     'es' => 'Sitio Web',
                     'ar' => 'الموقع',
                     'fr' => 'Site Web'},
           country: {'en' => 'Country',
                     'es' => 'País',
                     'ar' => 'بلد',
                     'fr' => 'Pays'},
           streaming_url: {'en' => 'Do you have streaming URL?',
                           'es' => 'Tiene URL de transmisión en linea?',
                           'ar' => 'هل لديك بث اذاعى مباشر على الانترنت',
                           'fr' => 'Avez-vous un URL Stream pour votre Radio'},
           bool_no: {'en' => 'No',
                     'es' => 'No',
                     'ar' => 'لا',
                     'fr' => 'Non'},
           bool_yes: {'en' => 'Yes',
                      'es' => 'Si',
                      'ar' => ' نعم',
                      'fr' => 'Oui'},
           select_stream: {'en' => 'Select Your Services',
                           'es' => 'Selección de Servicios',
                           'ar' => '',
                           'ar' => ' اختر الخدمه المطلوبه',
                           'fr' => 'Selectionner vos Services'},
           free_streaming: {'en' => 'Free Streaming',
                            'es' => 'Streaming Gratis',
                            'ar' => 'بث حر',
                            'fr' => 'Streaming gratuit'},
           dial_in_service: {'en' => 'Dial In Service',
                             'es' => 'Servicio por Marcaciòn',
                             'ar' => 'خدمه سماع  الاذاعه على خط تلفونى',
                             'fr' => 'Service téléphonique'},
           media_player: {'en' => 'Media Player',
                          'es' => 'Reproductor Multimedia',
                          'ar' => 'خدمه سماع الاذاعه على  الحاسب الالى',
                          'fr' => 'Player Média (Radio)'},
           btn_text: {'en' => 'Sign Up',
                      'es' => 'Registrarse',
                      'ar' => 'التوقيع ',
                      'fr' => 'Inscrivez-vous'}
    }
    return lib[field][params[:local]]
  end

  # def truncate(truncate_at, options = {})
  #   return dup unless length > truncate_at

  #   options[:omission] ||= '...'
  #   length_with_room_for_omission = truncate_at - options[:omission].length
  #   stop =        if options[:separator]vc
  #                   rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
  #                 else
  #                   length_with_room_for_omission
  #                 end

  #   "#{self[0...stop]}#{options[:omission]}"
  # end

end