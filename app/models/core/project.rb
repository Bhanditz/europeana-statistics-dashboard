# == Schema Information
#
# Table name: core_projects
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  slug       :string
#  properties :hstore
#  is_public  :boolean
#  created_at :datetime
#  updated_at :datetime
#  created_by :integer
#  updated_by :integer
#

  # == Schema Information
#
# Table name: core_projects
#
#  id            :integer          not null, primary key
#  account_id    :integer
#  name          :string(255)
#  slug          :string(255)
#  properties    :hstore
#  is_public     :boolean
#  created_at    :datetime
#  updated_at    :datetime
#  created_by    :integer
#  updated_by    :integer
#

class Core::Project < ActiveRecord::Base
  
  #GEMS
  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :account
  include WhoDidIt
  self.table_name = "core_projects"
  
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :license, :description, :cdn_source
  
  #ASSOCIATIONS
  belongs_to :account
  has_many :data_stores, foreign_key: "core_project_id"
  has_many :custom_dashboards, class_name: "Core::CustomDashboard", foreign_key: "core_project_id"
  has_many :vizs, foreign_key: "core_project_id"
  has_many :core_team_projects, class_name: "Core::TeamProject", foreign_key: "core_project_id" #DONE
  has_many :core_teams, class_name: "Core::Team", through: :core_team_projects
  has_many :core_tokens, class_name: "Core::Token", foreign_key: "core_project_id"
  has_many :core_data_store_pulls, class_name: "Core::DataStorePull", foreign_key: "core_project_id", dependent: :destroy
  
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :account_id}
  validates :account_id, presence: true
  validates :license, presence: true
  
  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set
  before_destroy :on_delete
  
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  
  def core_permissions
    Core::Permission.where(core_team_id: self.core_team_projects.pluck(:core_team_id).uniq)
  end
  
  def to_s
    self.name
  end

  #PRIVATE
  private
  
  def before_create_set
    self.properties = "{}" if self.properties.blank?
    self.properties["license"] = "Not Specified" if self.properties["license"].blank?
    self.is_public  = true
    self.cdn_source = "softlayer"
    true
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def after_create_set
    if self.account.is_user_account?
      team = Core::Team.new(organisation_id: self.account_id, name: self.name, created_by: self.account_id, role: Constants::ROLE_C)
      team.save
      Core::TeamProject.create(core_project_id: self.id, core_team_id: team.id)
      Core::Permission.create(account_id: self.account_id, organisation_id: self.account_id, role: Constants::ROLE_O, email: self.account.email, status: Constants::STATUS_A, core_team_id: team.id)
    else
      Core::TeamProject.create(core_team_id: self.account.owner_team.id, core_project_id: self.id)
    end
    Core::Token.create(account_id: self.account_id, core_project_id: self.id, api_token: SecureRandom.hex(24), name: "rumi-weblayer-api")
    true
  end
  
  def should_generate_new_friendly_id?
    name_changed?
  end
  
  def on_delete
    begin
      self.vizs.each do |core_viz|
        core_viz.destroy
      end

      self.custom_dashboards.each do |c_dashboard|
        Core::GitToS3::DestroyWorker.perform_async(c_dashboard.cdn_bucket)
        c_dashboard.destroy
      end

      self.data_stores.each do |d_store|
        Nestful.post REST_API_ENDPOINT + "#{self.account.slug}/#{self.slug}/#{d_store.slug}/grid/delete", {:token => self.core_tokens.first.api_token}, :format => :json
        if d_store.cdn_published_url.present?
          d_store.update_attributes(marked_to_be_deleted: "true")
          Core::S3File::DestroyWorker.perform_async("DataStore", d_store.id)
        else
          d_store.destroy
        end
      end
      self.core_tokens.destroy_all
      if self.account.is_user_account?
        Core::Team.where(id: self.core_team_projects.pluck(:core_team_id)).delete_all
        self.core_team_projects.destroy_all
        self.core_permissions.destroy_all
      else
        self.core_team_projects.destroy_all
      end
      true
    rescue Exception => e
      errors.add(:name,e.to_s)
      false
    end
  end

end

