class AddCols123ToImplAggregation < ActiveRecord::Migration
  def change
    add_column :impl_aggregations, :last_updated_at, :date
    Impl::Aggregation.where(genre: ['europeana','data_provider']).each do |d|
      impl_output = d.impl_outputs.where(genre: 'pageviews').first
      if impl_output.present?
        last_updated = impl_output.core_time_aggregations.order("split_part(aggregation_level_value,'_',1) desc, to_date(split_part(aggregation_level_value,'_',2),'Month') desc").first
        if last_updated_at.present?
          last_updated_at = Date.parse(last_updated.aggregation_level_value.split("_").join(" ")).at_end_of_month
          d.update_column(:last_updated_at, last_updated_at)
        end
      end
    end
  end
end
