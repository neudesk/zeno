module VisualReportsHelper
  def format_date(best_day)
    return "" if best_day.nil?
    date = best_day.strftime("%b %d")
    day = date.split(" ").last
    if day == 1
      date += "st"
    elsif day == 2 
      date += "nd"
    elsif day == 3
      date += "nd"
    else
      date += "th"
    end
    date
  end
end