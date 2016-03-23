module Impl
  module Reports
    class Show < Europeana::Styleguide::View
      def page_title
        'Welcome'
      end

      def navigation
        { global: {} }
      end

      def css_files
        [
          { path: styleguide_url('/css/statistics/screen.css'), media: 'all', title: nil },
          { path: asset_path("europeana.css"), media: 'all', title: nil},
        ]
      end

      def js_files
        [
          {
            path: asset_path('application.js')
          },
          {
            path: asset_path('accounts.js')
          },
          {
            path: asset_path('reports.js')
          },
          {
            path:Rails.env.production? ? asset_path("ga.js") : ""
          },
          {
            path: styleguide_url('/js/dist/require.js'),
            data_main: styleguide_url('/js/dist/main/main-statistics.js')
          }
        ]
      end

      def js_vars
        [
          {
            name: 'rumi_api_endpoint', value: REST_API_ENDPOINT
          }
        ] + super
      end

      def content
        a = {
          stats_source: @impl_aggregation.name.titleize,
          charts: get_report_charts,
          numberedlist: {
            title: "Top 25 Digital Objects"
          },
          stats_bar: get_stats_bar
        }
        unless @impl_report.impl_aggregation_genre == "data_provider"
          if @impl_report.impl_aggregation_genre == "europeana"
            a["total_countries"] = get_countries_count
            a["total_providers"] = get_providers_count
          end
            a['data_providers'] = get_data_providers
        end
        a
      end

      def gon
        helpers.include_gon
      end

      def bodyclass
        "europeana_statsdashboard page_dashboard"
      end

      protected

      def get_report_charts
        @impl_report.variable_object
      end

      def get_data_providers
        {
          title: "Institutions working with Europeana #{@impl_aggregation.genre == "europeana" ? "" : "in " + @impl_aggregation.name}",
          value: @impl_aggregation.genre == "europeana" ? 3521 : @impl_aggregation.child_data_providers.count,
          description: "The total number of institutions working with Europeana."
        }
      end

      def get_countries_count
        {
          title: "Countries working with Europeana",
          value: @impl_aggregation.impl_outputs.where(genre: "top_country_counts").first.core_time_aggregations.where(aggregation_level_value: "#{@selected_date.year}_#{@current_month}").first.value,
          description: "The total number of institutions working with Europeana."
        }
      end

      def get_providers_count
        {
          title: "Aggregators working with Europeana",
          value: @impl_aggregation.impl_outputs.where(genre: "top_provider_counts").first.core_time_aggregations.where(aggregation_level_value: "#{@selected_date.year}_#{@current_month}").first.value,
          description: "The total number of institutions working with Europeana."
        }
      end

      def get_stats_bar
        {
          items: [{
            "title": "Total Views in 2014",
            "value": helpers.number_with_delimiter(@impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2014'").sum("value").to_i),
          },{
            "title": "Total Views in 2015",
            "value": helpers.number_with_delimiter(@impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2015'").sum("value").to_i),
            "trend": "20%"
          },{
            "title": "Total Views in 2016(till now)",
            "value": helpers.number_with_delimiter(@impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2016'").sum("value").to_i),
          },{
            "title": "Total clickThrough in 2016",
            "value": helpers.number_with_delimiter(@impl_aggregation.impl_outputs.where(genre: "clickThrough").first.core_time_aggregations.where("aggregation_level_value = '2016'").sum("value").to_i),
          },{
            "title": "Total events in 2015",
            "value": helpers.number_with_delimiter(@impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2016'").sum("value").to_i),
          },{
            "title": "Total events in 2016(till now)",
            "value": helpers.number_with_delimiter(@impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2016'").sum("value").to_i),
          }]
        }
      end
    end
  end
end
