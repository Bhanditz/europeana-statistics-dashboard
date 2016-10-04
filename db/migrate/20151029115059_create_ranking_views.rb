# frozen_string_literal: true
class CreateRankingViews < ActiveRecord::Migration
  def change
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
                    iar.impl_child_id AS impl_child_id,ia.id as impl_aggregation_id ,ia.name as impl_aggregation_name
                  FROM
                    impl_aggregations ia
                  JOIN
                    impl_aggregation_relations iar
                  ON
                    ia.id = iar.impl_parent_id AND
                    (
                      ia.genre::text = 'provider'
                    )
                ) iap
              ON
                iap.impl_child_id = io.impl_parent_id AND io.impl_parent_type::text = 'Impl::Aggregation'::text AND io.genre::text = 'pageviews'::text
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
  end
end
