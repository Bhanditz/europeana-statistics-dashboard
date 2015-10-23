class CreateImplAggregationRankViews < ActiveRecord::Migration
  def change
    #Creating impl_aggregation_rank_for_pageviews
    execute "CREATE OR REPLACE VIEW impl_aggregation_rank_of_pageviews AS
      Select *,rank_for_europeana - lag(rank_for_europeana) over(Partition by impl_aggregation_id) as diff_in_rank_for_europeana
      FROM
        (
          SELECT
            impl_join.impl_aggregation_id,sum(cta.value) AS sum,
            rank() OVER (PARTITION BY split_part(cta.aggregation_level_value::text, '_'::text, 1), split_part(cta.aggregation_level_value::text, '_'::text, 2) ORDER BY sum(cta.value) DESC) AS rank_for_europeana,
            sum(cta.value) - lag(sum(cta.value)) OVER (PARTITION BY impl_join.impl_aggregation_id ORDER BY split_part(cta.aggregation_level_value::text, '_'::text, 1), to_date(split_part(cta.aggregation_level_value::text, '_'::text, 2), 'Month'::text)) AS diff,
            sum(cta.value)::numeric * 100.00 / europeana_data.pageviews_for_europeana::numeric AS contribution_to_europeana,
            'pageviews'::text AS metric,
            split_part(cta.aggregation_level_value::text, '_'::text, 1) as year,
            split_part(cta.aggregation_level_value::text, '_'::text, 2) as month,
            impl_aggregation_name
          FROM
            core_time_aggregations cta
          JOIN
            (
              SELECT
                iap.impl_aggregation_id,io.id AS impl_output_id,iap.impl_aggregation_name
              FROM
                impl_outputs io
              JOIN
                (
                  SELECT
                    ia.id AS impl_aggregation_id,ap.impl_provider_id, ia.name as impl_aggregation_name
                  FROM
                    impl_aggregations ia
                  JOIN
                    impl_aggregation_providers ap
                  ON
                    ia.id = ap.impl_aggregation_id AND
                    (
                      ia.genre::text = ANY (ARRAY['provider'::character varying, 'data_provider'::character varying]::text[])
                    )
                ) iap
              ON
                iap.impl_provider_id = io.impl_parent_id AND io.impl_parent_type::text = 'Impl::DataSet'::text AND io.genre::text = 'pageviews'::text
            ) impl_join
          ON
            cta.parent_id = impl_join.impl_output_id AND cta.parent_type::text = 'Impl::Output'::text
          JOIN
            (
              SELECT
                sum(europeana_cta.value) AS pageviews_for_europeana,europeana_cta.aggregation_level_value AS europeana_aggregation_level_value
              FROM
                impl_aggregations europeana_ia
              JOIN
                impl_outputs europeana_io
              ON
                europeana_ia.genre::text = 'europeana'::text AND europeana_ia.id = europeana_io.impl_parent_id AND europeana_io.impl_parent_type::text = 'Impl::Aggregation'::text AND europeana_io.genre::text = 'pageviews'::text
              JOIN
                core_time_aggregations europeana_cta
              ON
                europeana_cta.parent_id = europeana_io.id
              GROUP BY
                europeana_cta.aggregation_level_value
            ) europeana_data
          ON
            europeana_data.europeana_aggregation_level_value::text = cta.aggregation_level_value::text
          GROUP BY
            impl_join.impl_aggregation_id, cta.aggregation_level_value, europeana_data.pageviews_for_europeana,impl_aggregation_name
        )
      as europeana_rank;"
    #Creating impl_aggregation_rank_for_collections
    execute "CREATE OR REPLACE VIEW impl_aggregation_rank_of_collections AS
      SELECT
        io.impl_parent_id AS impl_aggregation_id,io.value::bigint AS sum, rank() OVER (ORDER BY io.value::integer DESC) AS rank,
        io.value::integer::numeric * 100.00 / ((
              SELECT
                europeana_io.value
              FROM
                impl_outputs europeana_io
              JOIN
                impl_aggregations europeana_ia
              ON
                europeana_io.impl_parent_id = europeana_ia.id
              WHERE europeana_ia.name::text = 'Europeana'::text AND europeana_io.genre::text = 'collections'::text AND europeana_io.impl_parent_type::text = 'Impl::Aggregation'::text
            )::integer
          )::numeric AS contribution_to_europeana,
        'collections'::text AS metric,
        ia.name as impl_aggregation_name
      FROM
        impl_outputs io
      JOIN
        impl_aggregations ia ON io.impl_parent_id = ia.id
      WHERE io.genre::text = 'collections'::text AND io.impl_parent_type::text = 'Impl::Aggregation'::text AND ia.name::text <> 'Europeana'::text;"
    #Creating impl_aggregation_rank(combined metrics)
    execute "CREATE OR REPLACE VIEW impl_aggregation_ranks AS
      SELECT
        impl_aggregation_rank_of_pageviews.impl_aggregation_id,
        impl_aggregation_rank_of_pageviews.impl_aggregation_name,
        impl_aggregation_rank_of_pageviews.sum,
        impl_aggregation_rank_of_pageviews.rank_for_europeana,
        impl_aggregation_rank_of_pageviews.diff,
        impl_aggregation_rank_of_pageviews.contribution_to_europeana,
        impl_aggregation_rank_of_pageviews.metric,
        impl_aggregation_rank_of_pageviews.year,
        impl_aggregation_rank_of_pageviews.month,
        impl_aggregation_rank_of_pageviews.diff_in_rank_for_europeana
      FROM
        impl_aggregation_rank_of_pageviews
      UNION ALL
        SELECT
          impl_aggregation_rank_of_collections.impl_aggregation_id,
          impl_aggregation_rank_of_collections.impl_aggregation_name,
          impl_aggregation_rank_of_collections.sum,
          impl_aggregation_rank_of_collections.rank AS rank_for_europeana,
          0 AS diff,
          impl_aggregation_rank_of_collections.contribution_to_europeana,
          impl_aggregation_rank_of_collections.metric,
          'N/A'::text AS year,
          'N/A'::text AS month,
          0 as diff_in_rank_for_europeana
      FROM
        impl_aggregation_rank_of_collections;"
  end
end