class AddCdnAuthenticationIdToCoreProjects < ActiveRecord::Migration
  def change
    add_column :core_projects, :cdn_core_authentication_id, :integer
  end
end
