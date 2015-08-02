class DataEntrywaysController < ApplicationController
  def tags
    tags = []
    DataEntryway.limit(5).each do |x|
      tags << { value: x.id, text: x.did_e164}
    end

    render json: tags.to_json
  end
end