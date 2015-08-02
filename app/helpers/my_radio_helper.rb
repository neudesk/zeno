
module MyRadioHelper
  module Role
    VALUES = {
      'marketer' => 1,
      'rca' => 2,
      '3rd_party' => 3,
      'broadcaster' => 4
    }
    NAMES = {
      VALUES['marketer'] => 'Marketer',
      VALUES['rca'] => 'RCA',
      VALUES['3rd_party'] => 'Third Party',
      VALUES['broadcaster'] => 'Broadcaster'
    }
  end

  def roles_for_select
    options = []
    Role::VALUES.each do |_, v|
      options << [Role::NAMES[v], v]
    end
    options
    # options_for_select(options)
  end

  def groups_for_select(source, user_id)
    options = []

    source.each do |obj|
      options << [obj.title, obj.id]
    end

    if user_id == "undefined"
      return options_for_select(options)
    else
      return options_for_select(options, selected: user_id)
    end
  end

  def countries_for_select(source=nil)
    source ||= DataGroupCountry.all
    options = []
    source.each do |obj|
      options << [obj.title, obj.id]
    end
    options_for_select(options)
  end

  def assignments_for_checklist(source=[])
    options = []
    source.each_with_index do |obj, idx|
      name = "assignments[#{idx}]"
      ck = check_box_tag(name, obj.id, SharedMethods::Parser::Boolean(obj.status), :class => 'pull-left')
      lb = label_tag(name, obj.title, :class => 'pull-left')
      options << content_tag(:div, [ck,lb].join('').html_safe, :class => 'ck_option pull-left', style: "margin: 5px 10px 5px 0px")
    end
    options.join('')
  end
end
