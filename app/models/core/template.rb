# == Schema Information
#
# Table name: core_templates
#
#  id                 :integer          not null, primary key
#  name               :string
#  html_content       :text
#  genre              :string
#  required_variables :json             default({})
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Core::Template < ActiveRecord::Base
  #GEMS
  self.table_name = "core_templates"

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  has_many :impl_reports, class_name: "Impl::Report", foreign_key: "core_template_id", dependent: :destroy
  #VALIDATIONS
  validates :name, presence: true
  validates :genre, presence: true, uniqueness: {scope: :name}
  #CALLBACKS
  #SCOPES
  scope :default_europeana_template, -> {where(genre: 'europeana').first}
  #CUSTOM SCOPES
  #FUNCTIONS

  def self.create_or_update(name,html_content,genre,required_variables)
    a = where(name: name, genre: genre).first
    if a.blank?
      a = create({name: name, html_content: html_content,genre: genre, required_variables: required_variables })
    else
      a.update_attributes(html_content: html_content, required_variables: required_variables)
    end
    a
  end

  #PRIVATE
end
