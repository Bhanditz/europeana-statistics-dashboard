# == Schema Information
#
# Table name: core_vizs
#
#  id                         :integer          not null, primary key
#  core_project_id            :integer
#  properties                 :hstore
#  pykquery_object            :json
#  created_at                 :datetime
#  updated_at                 :datetime
#  name                       :string
#  config                     :json
#  created_by                 :integer
#  updated_by                 :integer
#  ref_chart_combination_code :string
#  refresh_freq_in_minutes    :integer
#  output                     :text
#  refreshed_at               :datetime
#  datagram_identifier        :string
#  is_static                  :boolean
#  was_output_big             :boolean
#

class Core::Viz < ActiveRecord::Base
  #GEMS
  self.table_name = "core_vizs"
  include WhoDidIt
   

  #CONSTANTS
  #ATTRIBUTES
  #ACCESSORS
  store_accessor :properties, :cdn_published_at, :cdn_published_url, :cdn_published_error, :cdn_published_count
  attr_accessor :dataformat
  #ASSOCIATIONS
  belongs_to :core_project, class_name: "Core::Project", foreign_key: "core_project_id"
  belongs_to :ref_chart,class_name: "Ref::Chart",foreign_key: "ref_chart_combination_code", primary_key: "combination_code"
  has_many :views, class_name: "Core::SessionImpl",foreign_key: "core_viz_id", dependent: :destroy

  #VALIDATIONS
  validates :name, uniqueness: {scope: :core_project_id}

  #CALLBACKS
  before_create :before_create_set
  after_create :after_create_set

  #SCOPES
  #CUSTOM SCOPES
  #FUNCTIONS
  def headers
    data_store_id = self.data_store_id
    if datatypes.first.present?
      datatypes.each_with_index do |datatype,index|
        contents[index] = "#{contents[index]}:#{datatype}"
      end
    else
      contents.each_with_index do |datatype,index|
        contents[index] = "#{contents[index]}:string"
      end
    end
    contents
  end

  def to_s
    self.name
  end

  #PRIVATE
  private
  
  def after_create_set
    #Core::Viz::DatagramWorker.perform_async(self.id)
    true
  end

  def before_create_set
    self.datagram_identifier = SecureRandom.hex(42)
    self.refreshed_at = nil
    self.was_output_big = false
    self.cdn_published_count = "0"
    self.cdn_published_url = ""
    self.cdn_published_at = ""
    self.cdn_published_error = ""
    if self.ref_chart.slug == "grid"
      self.config = {
        "data" => {},
        "readOnly" => true,
        "fixedRowsTop" => 0,
        "colHeaders" => [],
        "manualColumnMove" => true,
        "outsideClickDeselects" => false,
        "contextMenu" => false
      }
    end
    self.is_static = false
    self.refresh_freq_in_minutes = 0
    self.name = Core::Viz.last.present? ? "Untitled Visualisation #{Core::Viz.last.id + 1}" : "Untitled Visualisation 1"
    true
  end

end
