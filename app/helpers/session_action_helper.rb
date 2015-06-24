module SessionActionHelper
  
  def convert_to_link(sa)
    if sa.objectable.blank?
      return ""
    else
      if sa.objectable_type == "Core::Project"
        link_to sa.objectable.to_s, _account_project_path(sa.objectable.account, sa.objectable)
      elsif sa.objectable_type == "Account"
        link_to sa.objectable.to_s, edit_core_organisation_path(sa.objectable)
      elsif sa.objectable_type == "Core::ConfigurationEditor"
        link_to sa.objectable.to_s, account_core_project_configuration_editor_path(sa.objectable.account_id, sa.objectable.core_project, sa.objectable)
      elsif sa.objectable_type == "Core::DataStore"
        link_to sa.objectable.to_s, _account_project_data_store_path(sa.objectable.account, sa.objectable.core_project, sa.objectable)
      elsif sa.objectable_type == "Core::Permission"
        "<a href=''>#{sa.objectable.to_s}</a>".html_safe
      elsif sa.objectable_type == "Core::TeamProject"
        "<a href=''>#{sa.objectable.to_s}</a>".html_safe
      elsif sa.objectable_type == "Core::Team"
        "<a href=''>#{sa.objectable.to_s}</a>".html_safe
      elsif sa.objectable_type == "Core::CustomDashboard"
        "<a href=''>#{sa.objectable.to_s}</a>".html_safe
      elsif sa.objectable_type == "Core::Viz"
        link_to sa.objectable.to_s, _edit_visualization_account_project_data_store_path(sa.objectable.core_project.account,sa.project,sa.objectable.data_store, sa.objectable_id)
      else
        "<strong> #{sa.objectable.to_s} </strong>".html_safe
      end
    end
  end
  
end