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
          }
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
        # {
        #   main_chart: {
        #     title: "Total pageviews in throughout the years",
        #     id: "spain_-_line_chart",
        #     api: "PykCharts.multiD.multiSeriesLine",
        #     datacast_identifier: "73a218cfeeafbc4db46bca62340d9e931da4fa6b959629cece30dc531f0ccfba5a",
        #     class: 'd3-pykcharts'
        #   },
        #   topcountries:{
        #     title: "Top 25 Countries",
        #     id: "spain_-_top_countries",
        #     api: "PykCharts.maps.oneLayer",
        #     datacast_identifier: "1a08e1be9ff9bbb728521df12cb86bd8ab95d510d37fcf37e8d529b8e3b75e98d5",
        #     class: 'd3-pykcharts',
        #   },
        #   total_items: {
        #     title: "Total number of items",
        #     id: "spain_-_media_type_donut_chart",
        #     api: "PykCharts.oneD.electionDonut",
        #     datacast_identifier: "99c1e6eeda0363af1f368e07efcc6c0e5a214d57491a4946142e8f1c406bd313c8",
        #     class: 'd3-pykcharts',
        #   },
        #   open_for_reuse: {
        #     title: "Open for Re-use",
        #     id: "spain_-_reusables",
        #     api: "PykCharts.oneD.pie",
        #     datacast_identifier: "8a8e60211b3a0c21b7da1ec8fb9a7c0226387e7675f90b0db563d657fd2ff678a6",
        #     class: 'd3-pykcharts',
        #   }
        # }
      end

      def get_data_providers
        {
          title: "Institutions working with Europeana",
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
    end
  end
end
