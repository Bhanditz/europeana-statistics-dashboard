# == Schema Information
#
# Table name: core_articles
#
#  id              :integer          not null, primary key
#  core_project_id :integer
#  name            :string
#  created_by      :integer
#  updated_by      :integer
#  status          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Core::Article < ActiveRecord::Base
  #GEMS
  self.table_name= "core_articles"
  include WhoDidIt
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  has_many :core_article_cards, class_name: "Core::ArticleCard", foreign_key: "core_article_id"
  has_many :core_cards,class_name: "Core::Card" ,through: :core_article_cards
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  validates :core_project_id, presence: true
  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS

  private

    def before_create_set
      true
    end

    def after_create_set
      true
    end
end
