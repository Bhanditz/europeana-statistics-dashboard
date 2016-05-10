# == Schema Information
#
# Table name: core_db_connections
#
#  id              :integer          not null, primary key
#  name            :string
#  adapter         :string
#  properties      :hstore
#  created_by      :integer
#  updated_by      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  core_project_id :integer
#

class Core::DbConnection < ActiveRecord::Base

  #GEMS
  self.table_name = "core_db_connections"
  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :host, :port, :username, :password, :db_name
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  has_many :core_datacasts, class_name: "Core::Datacast", foreign_key: "core_db_connection_id", dependent: :destroy
  #VALIDATIONS
  validates :name, presence: true, uniqueness: {scope: :core_project_id}
  validates :adapter, presence: true
  validates :host, presence: true
  validates :port, presence: true
  validates :username, presence: true
  validates :password, presence: true
  validates :db_name, presence: true
  validate  :test_connection

  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  def self.default_db
    where(name: "Default Database").first
  end
  #OTHER
  #FUNCTIONS

  def self.create_or_update(name,adapter,host,port,db_name,username,password,validate= false)
    c = Core::DbConnection.where(name: name, adapter: adapter).first
    if c.blank?
      c = Core::DbConnection.new({name: name,
                                  adapter: adapter,
                                  host: host,
                                  port: port,
                                  db_name: db_name,
                                  username: username,
                                  password: password,
                                })
      c.save(validate: validate)
    else
      c.attributes = {name: name,
                      adapter: adapter,
                      host: host,
                      port: port,
                      db_name: db_name,
                      username: username,
                      password: password,
                      }
      c.save(validate: validate)
    end
    c
  end

  #PRIVATE
  private

  def test_connection
    begin
      require 'pg'
      connection = PG.connect(dbname: self.db_name, user: self.username, password: self.password, port: self.port, host: self.host)
      connection.close
    rescue => e
      errors.add(:name,e.to_s)
    end
  end

end
