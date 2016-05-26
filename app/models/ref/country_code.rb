# == Schema Information
#
# Table name: ref_country_codes
#
#  id         :integer          not null, primary key
#  country    :string
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Ref::CountryCode < ActiveRecord::Base
  #GEMS USED
  self.table_name = "ref_country_codes"
  #ACCESSORS
  #ASSOCIATIONS
  #VALIDATIONS
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS

  #Creates Ref::CountryCode entries in databased from csv data.
  def self.seed
    CSV.read("ref/country_code.csv").each do |line|
      code = line[0]
      country = line[1]
      Ref::CountryCode.find_or_create(code,country)
    end
  end

  # Either creates a new Ref::CountryCode or returns an existing Ref::CountryCode object from the database.
  #
  # @param code [String] country code.
  # @param country [String] name of the country.
  # @return [Object] a reference to Ref::CountryCode.
  def self.find_or_create(code, country)
    a = where(code: code,country: country).first
    if a.blank?
      a = create({code:code, country: country})
    end
    a
  end
  #JOBS
  #PRIVATE
end
