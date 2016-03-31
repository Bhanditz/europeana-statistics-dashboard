module Impl
  module Reports
    class Show < Europeana::Styleguide::View
      def page_title
        "#{@impl_aggregation.genre == "europeana" ? "Overall" : @impl_aggregation.name.titleize} - Europeana Statistics Dashboard"
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
            path:Rails.env.production? ? asset_path("ga.js") : "",
            path:Rails.env.production? ? asset_path("hotjar.js") : ""
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
            title: "Top 25 items",
            description: "These items have been viewed most by visitors to Europeana. Use the dropdown menus to look at different time periods."
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
        @impl_report.variable_object["main_chart"]["title"] = "Monthly page views of items"
        @impl_report.variable_object["main_chart"]["description"] = "Hover over the different months to see exact numbers. You can turn the colour for each year on and off by clicking on it."
        @impl_report.variable_object["topcountries"]["title"] = "Top 10 countries"
        @impl_report.variable_object["topcountries"]["description"] = "These countries generated the most views for this collection this year."
        @impl_report.variable_object["total_items"]["title"] = "Total number of items"
        @impl_report.variable_object["open_for_reuse"]["title"] = "Available for re-use"
        @impl_report.variable_object["open_for_reuse"]["description"] = "Every item you find in Europeana comes with a <a href='http://pro.europeana.eu/page/available-rights-statements target='_blank''>rights statements</a> telling you how you can use it. To make it easier, we have divided these rights statements <a href='http://pro.europeana.eu/blogpost/new-features-for-europeana' target='_blank'>into three categories</a>."
        @impl_report.variable_object
      end

      def get_data_providers
        {
          title: "Cultural institutions sharing collections",
          value: @impl_aggregation.genre == "europeana" ? 3521 : @impl_aggregation.child_data_providers.count,
          description: "Thousands of cultural institutions share their digital collections via Europeana. <a href='http://europeana.eu/portal/browse/sources' target='_blank'>Click here for the full list</a>."
        }
      end

      def get_countries_count
        {
          title: "Countries sharing collections",
          value: @impl_aggregation.impl_outputs.where(genre: "top_country_counts").first.core_time_aggregations.where(aggregation_level_value: "#{@selected_date.year}_#{@current_month}").first.value,
          description: false
        }
      end

      def get_providers_count
        {
          title: "Aggregators sharing collections",
          value: @impl_aggregation.impl_outputs.where(genre: "top_provider_counts").first.core_time_aggregations.where(aggregation_level_value: "#{@selected_date.year}_#{@current_month}").first.value,
          description: "Working between Europeana and the cultural heritage institutions are aggregators. They act as intermediaries, harvesting data from the institutions. <a href='http://europeana.eu/portal/browse/sources'>Click here for the full list</a>."
        }
      end

      def get_stats_bar
        pg_views_2014 = @impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2014'").sum("value").to_i
        pg_views_2015 = @impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2015'").sum("value").to_i
        pg_views_2016 = @impl_aggregation.impl_outputs.where(genre: "pageviews").first.core_time_aggregations.where("split_part(aggregation_level_value,'_',1) = '2016'").sum("value").to_i

        ct_2014 = @impl_aggregation.impl_outputs.where(genre: "clickThrough").first.core_time_aggregations.where("aggregation_level_value = '2014'").sum("value").to_i
        ct_2015 = @impl_aggregation.impl_outputs.where(genre: "clickThrough").first.core_time_aggregations.where("aggregation_level_value = '2015'").sum("value").to_i
        ct_2016 = @impl_aggregation.impl_outputs.where(genre: "clickThrough").first.core_time_aggregations.where("aggregation_level_value = '2016'").sum("value").to_i

        {
          items: [{
            "title": "Total views in 2014",
            "value": helpers.number_with_delimiter(pg_views_2014)
          },{
            "title": "Total views in 2015",
            "value": helpers.number_with_delimiter(pg_views_2015),
            "trend": pg_views_2014 == 0 ? {} : {
              "value": (((pg_views_2015 - pg_views_2014).abs.to_f/pg_views_2014)*100).round(2).to_s + "%",
              "positive": pg_views_2015 > pg_views_2014 ? true : false,
              "negative": pg_views_2015 < pg_views_2014 ? true : false
            }
          },{
            "title": "Total views in 2016(till now)",
            "value": helpers.number_with_delimiter(pg_views_2016),
          },{
            "title": "Total click-throughs in 2014",
            "value": helpers.number_with_delimiter(ct_2014)
          },{
            "title": "Total click-throughs in 2015",
            "value": helpers.number_with_delimiter(ct_2015),
            "trend": ct_2014 == 0 ? {} : {
              "value": (((ct_2015 - ct_2014).abs.to_f/ct_2014)*100).round(2).to_s + "%",
              "positive": ct_2015 > ct_2014 ? true : false,
              "negative": ct_2015 < ct_2014 ? true : false
            }
          },{
            "title": "Total click-throughs in 2016(till now)",
            "value": helpers.number_with_delimiter(ct_2016)
          }]
        }
      end
    end
  end
end
