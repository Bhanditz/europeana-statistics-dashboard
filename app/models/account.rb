# == Schema Information
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  username               :string
#  email                  :string           default(""), not null
#  slug                   :string
#  properties             :hstore
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  confirmation_token     :string
#  unconfirmed_email      :string
#  created_at             :datetime
#  updated_at             :datetime
#  authentication_token   :string
#  devis                  :hstore
#  sign_in_count          :integer
#  confirmation_sent_at   :datetime
#  reset_password_sent_at :datetime
#

class Account < ActiveRecord::Base

  #GEMS
  devise :database_authenticatable, :recoverable, :validatable, :registerable

  extend FriendlyId
  friendly_id :username, use: :slugged

  #CONSTANTS
  before_create :before_create_set
  after_create :after_create_set

  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :bio, :gravatar_email_id, :url, :is_pseudo_account, :name, :location, :company, :image_url
  store_accessor :devis, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmed_at, :current_sign_in_at, :remember_created_at

  #ASSOCIATIONS
  has_many :permissions, class_name: "Core::Permission", foreign_key: :account_id, dependent: :destroy

  def core_projects
    Core::Project.where(id: self.permissions.where(role: [Constants::ROLE_C, Constants::ROLE_O]).pluck(:core_project_id).uniq)
  end

  #VALIDATIONS
  validates :username, presence: true, :uniqueness => { :case_sensitive => false }, length: { minimum: 5 }
  validates :username, exclusion: {in: Constants::STUPID_USERNAMES, message: "%{value} is reversed."}
  validates :password, exclusion: {in: Constants::STUPID_PASSWORDS, message: "that's a stupid password. Choose a new one."}
  validates :email, presence: true, format: {with: Constants::EMAIL}
  validates :url, format: {with: Constants::URL}, allow_blank: true
  validates :gravatar_email_id, format: {with: Constants::EMAIL}, presence: true, on: :update
  validates_confirmation_of :password
  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS

  def to_s
    self.username
  end

  #PRIVATE
  private

  def should_generate_new_friendly_id?
    username_changed?
  end

  def before_create_set
    self.properties                       = {} if self.properties.blank?
    self.properties["gravatar_email_id"]  = self.email
    self.authentication_token = SecureRandom.hex(24)
    true
  end

  def after_create_set
    if self.sign_in_count == 0 or self.sign_in_count.blank?
      Core::Permission.create!(account_id: self.id, role: Constants::ROLE_O, email: self.email, status: Constants::STATUS_A, is_owner_team: true)
    end
    true
  end

  # This function is used to override devise's search by email to search by username
  class << self
    def find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      uzername = conditions.delete(:username)
      if uzername.present?
        where(conditions).where(["lower(username) = :value", { :value => uzername.downcase }]).first
      else
        where(conditions).first
      end
    end
  end

end
