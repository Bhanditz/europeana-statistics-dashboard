class Core::DataTransform
  
  def self.twod_array_generate(object)
    # Convert PG::Result object to 2d array

    final_data = []
    begin
      final_data << object[0].keys
      object.each do |row|
        final_data << row.values
      end
    rescue => e
      return []
    end
    return final_data
  end

  def self.json_generate(object, dont_want_json=false)
    # Convert PG::Result object to JSON or XML
    final_data = []
    object.each do |row|
      final_data << row
    end
    return dont_want_json ? final_data.to_xml : final_data.to_json
  end
  
  def self.csv_generate(object)
    # Convert PG::Result object to CSV
    final_data = ""
    begin
      headers = object[0].keys
      final_data += headers.to_csv
      object.each do |row|
        row = row.values
        final_data += row.to_csv
      end
      final_data = final_data[0...-1] #removing the last extra \n
    rescue IndexError => e
      return ""
    end
    return final_data
  end

end
