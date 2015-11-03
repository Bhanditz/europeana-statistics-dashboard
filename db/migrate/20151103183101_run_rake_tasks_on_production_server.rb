class RunRakeTasksOnProductionServer < ActiveRecord::Migration
  def change
    Rake::Task['ref:create_default_template'].invoke
  end
end
