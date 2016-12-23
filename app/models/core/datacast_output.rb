# frozen_string_literal: true
# == Schema Information
#
# Table name: core_datacast_outputs
#
#  id                  :integer          not null, primary key
#  datacast_identifier :string           not null
#  output              :text
#  fingerprint         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Core::DatacastOutput < ActiveRecord::Base
  self.table_name = 'core_datacast_outputs'
  # GEMS
  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  # ASSOCIATIONS
  belongs_to :core_datacast, class_name: 'Core::Datacast', foreign_key: 'datacast_identifier', primary_key: 'identifier'

  # VALIDATIONS
  # CALLBACKS
  # SCOPES
  # CUSTOM SCOPES
  # OTHER
  # FUNCTIONS
end
