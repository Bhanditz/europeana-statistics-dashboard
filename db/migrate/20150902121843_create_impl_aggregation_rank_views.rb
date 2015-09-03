class CreateImplAggregationRankViews < ActiveRecord::Migration
  def change
    #Creating impl_aggregation_rank_for_pageviews
    execute "CREATE OR REPLACE VIEW impl_aggregation_rank_of_pageviews AS 
      SELECT impl_join.impl_aggregation_id,
        sum(cta.value) AS sum,
        cta.aggregation_level_value,
        rank() OVER (PARTITION BY split_part(cta.aggregation_level_value::text, '_'::text, 1), split_part(cta.aggregation_level_value::text, '_'::text, 2) ORDER BY sum(cta.value) DESC) AS rank_for_europeana,
        sum(cta.value) - lag(sum(cta.value)) OVER (PARTITION BY impl_join.impl_aggregation_id ORDER BY split_part(cta.aggregation_level_value::text, '_'::text, 1), to_date(split_part(cta.aggregation_level_value::text, '_'::text, 2), 'Month'::text)) AS diff,
        sum(cta.value)::numeric * 100.00 / europeana_data.pageviews_for_europeana::numeric AS contribution_to_europeana,
        'pageviews'::text AS metric
        FROM core_time_aggregations cta
          JOIN ( SELECT iap.impl_aggregation_id,
                io.id AS impl_output_id
                FROM impl_outputs io
                JOIN ( SELECT ia.id AS impl_aggregation_id,
                        ap.impl_provider_id
                        FROM impl_aggregations ia
                        JOIN impl_aggregation_providers ap ON ia.id = ap.impl_aggregation_id AND (ia.genre::text = ANY (ARRAY['provider'::character varying, 'data_provider'::character varying]::text[]))) iap ON iap.impl_provider_id = io.impl_parent_id AND io.impl_parent_type::text = 'Impl::Provider'::text AND io.genre::text = 'pageviews'::text) impl_join ON cta.parent_id = impl_join.impl_output_id AND cta.parent_type::text = 'Impl::Output'::text
          JOIN ( SELECT sum(europeana_cta.value) AS pageviews_for_europeana,
                europeana_cta.aggregation_level_value AS europeana_aggregation_level_value
                FROM impl_aggregations europeana_ia
                 JOIN impl_outputs europeana_io ON europeana_ia.genre::text = 'europeana'::text AND europeana_ia.id = europeana_io.impl_parent_id AND europeana_io.impl_parent_type::text = 'Impl::Aggregation'::text AND europeana_io.genre::text = 'pageviews'::text
                 JOIN core_time_aggregations europeana_cta ON europeana_cta.parent_id = europeana_io.id
                GROUP BY europeana_cta.aggregation_level_value) europeana_data ON europeana_data.europeana_aggregation_level_value::text = cta.aggregation_level_value::text
      GROUP BY impl_join.impl_aggregation_id, cta.aggregation_level_value, europeana_data.pageviews_for_europeana;"
    #Creating impl_aggregation_rank_for_collections
    execute "CREATE OR REPLACE VIEW impl_aggregation_rank_of_collections AS 
      SELECT io.impl_parent_id AS impl_aggregation_id,
        io.value::bigint AS sum,
        rank() OVER (ORDER BY io.value::integer DESC) AS rank,
        io.value::integer::numeric * 100.00 / ((( SELECT europeana_io.value
              FROM impl_outputs europeana_io
                JOIN impl_aggregations europeana_ia ON europeana_io.impl_parent_id = europeana_ia.id
              WHERE europeana_ia.name::text = 'Europeana'::text AND europeana_io.genre::text = 'collections'::text AND europeana_io.impl_parent_type::text = 'Impl::Aggregation'::text))::integer)::numeric AS contribution_to_europeana,
        'collections'::text AS metric
      FROM impl_outputs io
        JOIN impl_aggregations ia ON io.impl_parent_id = ia.id
      WHERE io.genre::text = 'collections'::text AND io.impl_parent_type::text = 'Impl::Aggregation'::text AND ia.name::text <> 'Europeana'::text;"
    #Creating impl_aggregation_rank(combined metrics)
    execute "CREATE OR REPLACE VIEW impl_aggregation_rank AS 
      SELECT 
        impl_aggregation_rank_of_pageviews.impl_aggregation_id,
        impl_aggregation_rank_of_pageviews.sum,
        impl_aggregation_rank_of_pageviews.aggregation_level_value,
        impl_aggregation_rank_of_pageviews.rank_for_europeana,
        impl_aggregation_rank_of_pageviews.diff,
        impl_aggregation_rank_of_pageviews.contribution_to_europeana,
        impl_aggregation_rank_of_pageviews.metric
      FROM 
        impl_aggregation_rank_of_pageviews
      UNION ALL
        SELECT 
          impl_aggregation_rank_of_collections.impl_aggregation_id,
          impl_aggregation_rank_of_collections.sum,
          'N/A'::text AS aggregation_level_value,
          impl_aggregation_rank_of_collections.rank AS rank_for_europeana,
          0 AS diff,
          impl_aggregation_rank_of_collections.contribution_to_europeana,
          impl_aggregation_rank_of_collections.metric
      FROM 
        impl_aggregation_rank_of_collections;"
  end
end
