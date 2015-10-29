class Core::Util
  
  #------------------------------------------------------------------------------------------
  
  class Core::Util::Spreadsheet
    #Core::Util::Spreadsheet.twod_to_csv(twod_array)
    def self.twod_to_csv(twodarray, options = {})
      CSV.generate(options) do |csv|
        twodarray.each do |row|
          csv << row
        end
      end
    end
  end
  
  #------------------------------------------------------------------------------------------
  
  class Core::Util::String
    
    #Core::Util::String.extract_source
    def self.extract_source(s)
      if s.present?
        s[(s.index(">") + 1)..(s.index("</a>") - 1)].to_s.gsub("Twitter for ", "").strip
      else
        ""
      end
    end
  
    #Core::Util::String.date_in_javascript_format(d)
    def self.datetime_in_javascript_format(d, time_zone="Mumbai")
      d.in_time_zone(time_zone).strftime("%a %b %d %Y 00:00:00 GMT%z (%Z)")
      #d.in_time_zone(time_zone).strftime("%a %b %d %Y %H:%M:%S GMT%z (%Z)")
    end
  
    def self.date_in_javascript_format(d)
      d.strftime("%a %b %d %Y")
    end
  
    def self.time_in_javascript_format(d)
       d.strftime("%H:%M:%S GMT+0530 (IST)")
    end
    
  end
  
  #------------------------------------------------------------------------------------------
  
end