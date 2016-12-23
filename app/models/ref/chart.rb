# frozen_string_literal: true
# == Schema Information
#
# Table name: ref_charts
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :text
#  img_small        :text
#  genre            :string
#  map              :text
#  api              :text
#  created_by       :integer
#  updated_by       :integer
#  img_data_mapping :string
#  slug             :string
#  combination_code :string(6)
#  source           :string
#  file_path        :string
#  sort_order       :integer
#

class Ref::Chart < ActiveRecord::Base
  # GEMS
  self.table_name = 'ref_charts'

  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  # ASSOCIATIONS
  # VALIDATIONS
  # validates :name, presence: true

  # CALLBACKS
  # SCOPES
  # CUSTOM SCOPES
  # FUNCTIONS
  # PRIVATE
end
