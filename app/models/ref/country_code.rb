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
  def self.seed
    CSV.read("ref/country_code.csv").each do |line|
      code = line[0]
      country = line[1]
      Ref::CountryCode.find_or_create(code,country)
    end
  end

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
