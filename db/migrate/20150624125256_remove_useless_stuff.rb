class RemoveUselessStuff < ActiveRecord::Migration
  def change
    drop_table :core_account_images
    drop_table :core_session_actions
    drop_table :cerebro_accounts
    drop_table :cerebro_socials
    drop_table :cerebro_websites
    drop_table :cerebro_works
    drop_table :core_referrals
    drop_table :core_referral_gifts
    drop_table :core_configuration_editors
    drop_table :core_map_files
    remove_column :core_session_impls, :core_map_file_id
    remove_column :core_data_stores , :is_verified_dictionary
    drop_table :ref_plans
    remove_column :core_projects, :ref_plan_slug
    drop_table :core_project_oauths
  end
end
