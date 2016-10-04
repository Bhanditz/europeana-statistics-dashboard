# frozen_string_literal: true
class AddIndexesOnImplReports < ActiveRecord::Migration
  def change
    execute 'Drop index index_impl_reports_on_slug'
    execute "CREATE INDEX index_impl_reports_on_slug_for_country
      ON impl_reports
      USING btree
      (slug) where impl_aggregation_genre='country';"
    execute "CREATE INDEX index_impl_reports_on_slug_for_provider
      ON impl_reports
      USING btree
      (slug) where impl_aggregation_genre='provider';"
    execute "CREATE INDEX index_impl_reports_on_slug_for_data_provider
      ON impl_reports
      USING btree
      (slug) where impl_aggregation_genre='data_provider';"

    execute "CREATE INDEX index_impl_report_on_slug_for_europeana
      ON impl_reports
      USING btree
      (slug) where impl_aggregation_genre='europeana';"

    execute "CREATE INDEX index_impl_report_on_slug_for_manual_reports
      ON impl_reports
      USING btree
      (slug) where impl_aggregation_genre IS NULL;"
  end
end
