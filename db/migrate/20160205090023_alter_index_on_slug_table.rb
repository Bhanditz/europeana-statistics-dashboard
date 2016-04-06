class AlterIndexOnSlugTable < ActiveRecord::Migration
  def change
    execute "Drop index index_impl_reports_on_slug"
    add_index "impl_reports", ["slug"], name: "index_impl_reports_on_slug", using: :btree
  end
end
