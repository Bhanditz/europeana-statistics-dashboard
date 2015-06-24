# == Schema Information
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  username               :string(255)
#  email                  :string(255)      default(""), not null
#  slug                   :string(255)
#  accountable_type       :string(255)
#  properties             :hstore
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  confirmation_token     :string(255)
#  unconfirmed_email      :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  authentication_token   :string(255)
#  devis                  :hstore
#  sign_in_count          :integer
#  confirmation_sent_at   :datetime
#  reset_password_sent_at :datetime
#

class Account < ActiveRecord::Base
  
  #GEMS
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable
  
  extend FriendlyId
  friendly_id :username, use: :slugged

  include PgSearch
  pg_search_scope :search, against: [:username, :email, :properties],using: {tsearch: {dictionary: "english"}}, ignoring: :accents    
  
  include WhoDidItOrganisation

  #CONSTANTS
  before_create :before_create_set
  after_create :after_create_set
  
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :bio, :gravatar_email_id, :url, :is_pseudo_account, :name, :location, :company, :image_url, :referral_code, :referred_by_account_id, :is_enterprise_organisation
  store_accessor :devis, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmed_at, :current_sign_in_at, :remember_created_at
  
  #ASSOCIATIONS
  
  #user has cerebros
  has_one :cerebro_account, class_name: "Cerebro::Account", foreign_key: "account_id"
  has_many :cerebro_socials, class_name: "Cerebro::Social", through: :cerebro_accounts
  has_many :cerebro_works, class_name: "Cerebro::Social", through: :cerebro_accounts
  has_many :cerebro_websites, class_name: "Cerebro::Social", through: :cerebro_accounts
  
  # if account is User
  has_many :session_actions_u, class_name: "Core::SessionAction", foreign_key: "account_id"
  has_many :permissions, class_name: "Core::Permission", foreign_key: :account_id
  has_many :accounts_u, -> {where "is_owner_team = true"}, class_name: "Core::Permission", foreign_key: :account_id
  has_many :owners_u, -> {where "is_owner_team = true", role: Constants::ROLE_O}, 
                      class_name: "Core::Permission", foreign_key: :account_id
  has_many :core_tokens, class_name: "Core::Token"
  has_many :core_referrals, class_name: "Core::Referral", foreign_key: "account_id"
  has_many :core_referral_gift, class_name: "Core::ReferralGift" 
  has_many :core_account_emails,class_name: "Core::AccountEmail" ,foreign_key: :account_id, dependent: :destroy #DONE
  has_many :core_map_files,class_name: "Core::MapFile",foreign_key: :account_id
  has_one  :core_account_image,class_name: "Core::AccountImage",foreign_key: :account_id
  
  def organisations
    Account.where(accountable_type: Constants::ACC_O, id: self.accounts_u.pluck(:organisation_id).uniq)
  end
  
  # if account is Organisation
  has_many :session_actions_o, class_name: "Core::SessionAction", foreign_key: "organisation_id"
  has_many :accounts_o, -> {where "is_owner_team = true"}, class_name: "Core::Permission", foreign_key: :organisation_id
  has_many :owners_o, -> {where "is_owner_team = true", role: Constants::ROLE_O}, 
                      class_name: "Core::Permission", foreign_key: :organisation_id
  has_many :core_teams, class_name: "Core::Team", foreign_key: "organisation_id" # dependent: :destroy
  has_one :owner_team, -> {where "is_owner_team = true"}, class_name: "Core::Team", foreign_key: "organisation_id"
  has_many :custom_themes, class_name: "Core::Theme", foreign_key: "account_id", dependent: :destroy #DONE
  

  def accounts
    self.accountable_type == Constants::ACC_U ? self.accounts_u.joins(:account) : self.accounts_o
  end
  
  def owners
    self.accountable_type == Constants::ACC_U ? self.owners_u.joins(:account) : self.owners_o.joins(:account)
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
    
  def core_projects
    Core::Project.where(id: Core::Permission.where("core_permissions.account_id = ? OR core_permissions.organisation_id = ?", self.id, self.id).where(role: [Constants::ROLE_C, Constants::ROLE_O]).joins(:core_team_projects).pluck("core_team_projects.core_project_id").uniq)
  end
  
  def session_actions
    self.accountable_type == Constants::ACC_U ? self.session_actions_u : self.session_actions_o
  end
  
  #VALIDATIONS
  validates :username, presence: true, :uniqueness => { :case_sensitive => false }, length: { minimum: 5 }
  validates :username, exclusion: {in: Constants::STUPID_USERNAMES, message: "%{value} is reversed."}
  validates :password, exclusion: {in: Constants::STUPID_PASSWORDS, message: "that's a stupid password. Choose a new one."}
  validates :email, presence: true, format: {with: Constants::EMAIL}
  validates :url, format: {with: Constants::URL}, allow_blank: true
  validates :gravatar_email_id, format: {with: Constants::EMAIL}, presence: true, on: :update
  validate :email_unique_from_core_account_email, on: :create
  #SCOPES
  scope :o, -> { where(accountable_type: Constants::ACC_O) }
  scope :u, -> { where(accountable_type: Constants::ACC_U) }
  
  #CUSTOM SCOPES
  #FUNCTIONS
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def sudo_organisation_owner(o) #always run off current_user
    if o.accountable_type == Constants::ACC_O
      return self.permissions.where(organisation_id: o.id, core_team_id: o.owner_team.id, role: Constants::ROLE_O).first.blank?
    else
      return self.id == o.id ? false : true
    end
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def sudo_project_owner(o, p) #always run off current_user
    self.permissions.joins(:core_team_projects).where("core_team_projects.core_project_id = ?", p).where(organisation_id: o.id, role: Constants::ROLE_O).first.blank?
  end  
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
    
  def sudo_project_member(o, p) #always run off current_user
    c = self.permissions.joins(:core_team_projects).where("core_team_projects.core_project_id = ?", p).where(organisation_id: o.id, role: [Constants::ROLE_C, Constants::ROLE_O]).first
    return nil                  if c.blank?
    return Constants::SUDO_011  if c.role == Constants::ROLE_C
    return Constants::SUDO_111  if c.role == Constants::ROLE_O
    FAIL
  end
  
  def self.text_search(q)
    if q.present?
      search(q)
    else
      where("username IS NOT NULL")
    end
  end
  
  def to_s
    self.username
  end
  
  def is_not_collaborator?(cid)
    Core::Permission.where(account_id: cid, organisation_id: self.id).first.blank? ? true : false
  end
  
  def is_online
    Core::SessionImpl.logged_in_from_multiple_sources(self.id).present?
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def is_admin?
    self.email.index("@pykih.com").present? and self.confirmation_token.blank?
  end
  
  def is_user_account? #IF
    self.accountable_type == Constants::ACC_U
  end
  
  def email_unique_from_core_account_email
    core_account_email_count = Core::AccountEmail.where(email: self.email).count
    if core_account_email_count > 0
      errors.add(:email, "already registered")
    end
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
    self.referral_code = SecureRandom.hex(6)   if self.is_user_account?
    self.is_enterprise_organisation = false
    true
  end
  
  # LOCKING this method. Do not change. 
  # Module: Access-Control
  # Author: Ritvvij Parrikh
  
  def after_create_set
    if self.is_user_account? and (self.sign_in_count == 0 or self.sign_in_count.blank?)
      Core::Permission.create!(account_id: self.id, organisation_id: self.id, role: Constants::ROLE_O, email: self.email, status: Constants::STATUS_A, is_owner_team: true)
      Cerebro::Account.find_or_create(self.email, self.id)  if Rails.env.production?
      if self.referred_by_account_id.present?
        Core::Referral.create(email: self.email, referered_id: self.id, account_id: self.referred_by_account_id, is_eligible: false)
      end
      if self.accountable_type == "User"
        Core::AccountEmail.create(email: self.email,account_id: self.id, is_primary: true)
      end
    end
    true
  end
  
  protected 
  
  # This function is used to override devise's search by email to search by username
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if uzername = conditions.delete(:username)
      where(conditions).where(["lower(username) = :value", { :value => uzername.downcase }]).first
    else
      where(conditions).first
    end
  end
  
end
