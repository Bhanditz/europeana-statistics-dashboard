class AddIndexes < ActiveRecord::Migration
  def change
  	#Core::Datacast
		execute("CREATE UNIQUE INDEX index_core_datacasts_on_identifier
		  ON core_datacasts
		  USING btree
		  (identifier);");

		#Core::TimeAggregation
		execute ("CREATE INDEX aggregation_level_value_index
		  ON core_time_aggregations
		  USING btree
		  (split_part(aggregation_level_value::text, '_'::text, 1), split_part(aggregation_level_value::text, '_'::text, 2));");

		execute("CREATE INDEX parent_type_parent_id_index
		  ON core_time_aggregations
		  USING btree
		  (parent_type, parent_id);");

		#Core::Viz
		execute("CREATE INDEX index_core_vizs_on_core_datacast_identifier
		  ON core_vizs
		  USING btree
		  (core_datacast_identifier);")

		#Impl::AggregationDatacast
		execute("CREATE INDEX index_impl_aggregation_id_core_datacast_identifier_on_impl_aggr
		  ON impl_aggregation_datacasts
		  USING btree
		  (impl_aggregation_id, core_datacast_identifier);");

		#Impl::AggregationRelation
		execute("CREATE INDEX impl_aggregation_relations_child_index
		  ON impl_aggregation_relations
		  USING btree
		  (impl_child_id, impl_child_genre);");

		execute("CREATE INDEX impl_aggregation_relations_index
		  ON impl_aggregation_relations
		  USING btree
		  (impl_parent_id, impl_parent_genre);");

		#Impl::Aggregation
		execute("CREATE INDEX impl_aggregation_genre_index
		  ON impl_aggregations
		  USING btree
		  (genre);");

		#Impl::DataProviderDataSet
		execute("CREATE INDEX impl_data_provider_data_sets_index
			  ON impl_data_provider_data_sets
			  USING btree
			  (impl_aggregation_id, impl_data_set_id);");

		#Impl::Dataset
		execute("CREATE INDEX impl_data_sets_aggregation_index
		  ON impl_datasets
		  USING btree
		  (impl_aggregation_id);");

		#Impl::Output
		execute("CREATE INDEX impl_outputs_genre_index
		  ON impl_outputs
		  USING btree
		  (genre);");

		execute("CREATE INDEX impl_parent_index
		  ON impl_outputs
		  USING btree
		  (impl_parent_id, impl_parent_type);")

		#Ref::Chart
		execute("CREATE INDEX ref_charts_index
		  ON ref_charts
		  USING btree
		  (combination_code);");

		#Ref::CountryCode
		execute("CREATE INDEX ref_country_codes_index
		  ON ref_country_codes
		  USING btree
		  (country);");

  end
end
