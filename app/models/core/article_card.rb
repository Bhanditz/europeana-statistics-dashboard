# == Schema Information
#
# Table name: core_article_cards
#
#  id              :integer          not null, primary key
#  core_article_id :integer
#  core_card_id    :integer
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Core::ArticleCard < ActiveRecord::Base
  #GEMS
  self.table_name= "core_article_cards"
  include WhoDidIt
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_article, class_name: "Core::Article", foreign_key: "core_article_id"
  belongs_to :core_card, class_name: "Core::Card", foreign_key: "core_card_id"
  #VALIDATIONS
  validates :core_article_id, presence: true
  validates :core_card_id, presence: true
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS
end
