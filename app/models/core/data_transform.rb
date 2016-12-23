# frozen_string_literal: true
class Core::DataTransform
  # Converts data from a db query to 2D array.
  #
  # @param object [Object] an object of an executed db query.
  # @return [Array] a 2D array representation of data.
  def self.twod_array_generate(object)
    # Convert db query object to 2d array
    final_data = []
    begin
      final_data << object[0].keys
      object.each do |row|
        final_data << row.values
      end
    rescue
      return []
    end
    final_data
  end

  # Converts data from db query to JSON or XML.
  #
  # @param object [Object] an object of an executed db query.
  # @param dont_want_json [Boolean] a boolean that indicates whether the output is JSON (default false).
  # @return [String] json or xml representation of data based on parametes.
  def self.json_generate(object, dont_want_json = false)
    # Convert db query object to JSON or XML
    final_data = []
    object.each do |row|
      final_data << row
    end
    dont_want_json ? final_data.to_xml : final_data.to_json
  end

  # Converts data from db query to CSV string.
  #
  # @param object [Object] an object of an executed db query.
  # @return [String] csv representation of data.
  def self.csv_generate(object)
    # Convert db query object to CSV
    final_data = ''
    begin
      headers = object[0].keys
      final_data += headers.to_csv
      object.each do |row|
        row = row.values
        final_data += row.to_csv
      end
      final_data = final_data[0...-1] # removing the last extra \n
    rescue IndexError
      return ''
    end
    final_data
  end
end
