# == Schema Information
#
# Table name: core_cards
#
#  id                       :integer          not null, primary key
#  name                     :string
#  is_public                :boolean
#  content                  :text
#  properties               :hstore
#  core_card_layout_id      :integer
#  core_project_id          :integer
#  core_datacast_identifier :integer
#  image                    :text
#  created_by               :integer
#  updated_by               :integer
#  filesize                 :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Core::Card < ActiveRecord::Base
  #GEMS
  self.table_name = "core_cards"
  include WhoDidIt
  #CONSTANTS
  #ATTRIBUTES
  store_accessor :properties
  #ACCESSORS
  #ASSOCIATIONS
  belongs_to :core_project_id, class_name: "Core::Project", foreign_key: "core_project_id"
  has_many :core_article_cards, class_name: "Core::ArticleCard", foreign_key: "core_card_id"
  #VALIDATIONS
  mount_uploader :image, ImageUploader
  validates :name, presence: true
  validates :template, presence: true
  validate  :validate_filesize

  #validates :core_datacast_identifier, if: check_for_mandatory_params

  # def check_for_mandatory_params
  #   self.core_card_layout.mandatory_parameters.each do |parameter|
  #     return false if value is nil
  #     if self[parameter].nil?
  #      
  #     end
  #   end
  # end

  def validate_filesize
    if (self.image.size.to_f/1000).round(2) > 200
      self.errors.add(:filesize,"maximum 200 KB allowed")
    end
  end


  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  #FUNCTIONS

  private

    def before_create_set
      self.is_public = self.is_public.present? ? self.is_public : false
      true
    end

    def after_create_set
      true
    end

end
