# frozen_string_literal: true
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
  # GEMS
  self.table_name = 'core_db_connections'
  # CONSTANTS
  # ATTRIBUTES
  # ACCESSORS
  store_accessor :properties, :host, :port, :username, :password, :db_name
  # ASSOCIATIONS
  belongs_to :core_project, class_name: 'Core::Project', foreign_key: 'core_project_id'
  has_many :core_datacasts, class_name: 'Core::Datacast', foreign_key: 'core_db_connection_id', dependent: :destroy
  # VALIDATIONS
  validates :name, presence: true, uniqueness: { scope: :core_project_id }
  validates :adapter, presence: true
  validates :host, presence: true
  validates :port, presence: true
  validates :username, presence: true
  validates :password, presence: true
  validates :db_name, presence: true
  validate  :test_connection

  # CALLBACKS
  # SCOPES
  # CUSTOM SCOPES

  # Returns a single row where the name is "Default database".
  def self.default_db
    where(name: 'Default Database').first
  end
  # OTHER
  # FUNCTIONS

  # Either creates a new Core::DbConnection or updates an existing Core::DbConnection object in the database.
  #
  # @param name [String] name of the database (reference name).
  # @param adapter [String] name of the database adapter to be used.
  # @param host [String] host name of the database server.
  # @param port [String] port number at which database is accessable.
  # @param db_name [String] actual name of the database.
  # @param username [String] username required to access the database.
  # @param password [String] password required to access the database.
  # @param validate [Boolean] to indicate whether to save the object to database with or without validation.
  # @return [Object] a reference to Core::DbConnection.
  def self.create_or_update(name, adapter, host, port, db_name, username, password, validate = false)
    c = Core::DbConnection.where(name: name, adapter: adapter).first
    if c.blank?
      c = Core::DbConnection.new(name: name,
                                 adapter: adapter,
                                 host: host,
                                 port: port,
                                 db_name: db_name,
                                 username: username,
                                 password: password)
      c.save(validate: validate)
    else
      c.attributes = { name: name,
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

  # PRIVATE
  private

  def test_connection
    require 'pg'
    connection = PG.connect(dbname: db_name, user: username, password: password, port: port, host: host)
    connection.close
  rescue => e
    errors.add(:name, e.to_s)
  end
end
