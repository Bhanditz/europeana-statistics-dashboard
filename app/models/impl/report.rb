# == Schema Information
#
# Table name: impl_reports
#
#  id                  :integer          not null, primary key
#  impl_aggregation_id :integer
#  core_template_id    :integer
#  name                :string
#  slug                :string
#  html_content        :text
#  variable_object     :json
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Impl::Report < ActiveRecord::Base
  #GEMS
  self.table_name = "impl_reports"

  extend FriendlyId
  friendly_id :name, use: :slugged

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_template, class_name: "Core::Template", foreign_key: "core_template_id"
  belongs_to :impl_aggregation, class_name: "Impl::Aggregation", foreign_key: "impl_aggregation_id"
  #VALIDATIONS
  validates :core_template_id, presence: true
  validates :impl_aggregation_id, presence: true, uniqueness: {scope: [:core_template_id]}
  validates :name, presence: true, uniqueness: {scope: [:core_template_id, :impl_aggregation_id]}
  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS

  def self.create_or_update(name,aggregation_id, core_template_id, html_content, variable_object)
    a = where(name: name, impl_aggregation_id: aggregation_id, core_template_id: core_template_id).first
    if a.blank?
      a = create({name: name, impl_aggregation_id: aggregation_id, core_template_id: core_template_id, html_content: html_content, variable_object: variable_object})
    else
      a.update_attributes(html_content: html_content, variable_object: variable_object)
    end
    a
  end
  #PRIVATE
  private

  def before_create_set
    true
  end

  def after_create_set
    true
  end

  def should_generate_new_friendly_id?
    name_changed?
  end
end
