module Impl
  module Aggregations
    class Countries < Europeana::Styleguide::View
      def page_title
        'Europeana Statistics Dashboard'
      end

      def bodyclass
        "europeana_statsdashboard page_countries"
      end

      def version
        {
          is_beta: @is_beta
        }
      end


      def navigation
        {
          global: {
              logo: {
                url: root_path,
                text: "Europeana statistics"
              },
              primary_nav: {
                menu_id: "main-menu",
                items: [
                  {
                    text: "Europeana Stats",
                    url: europeana_report_path
                  },
                  {
                    text: "Find a dashboard",
                    submenu: {
                      items: [
                          {
                            url: false,
                            text: "Browse Statistics:",
                            subtitle: true
                          },
                          {
                            url: countries_path,
                            text: "By Country"
                          },
                          {
                              is_divider: true
                          },
                          {
                            url: false,
                            text: "Find statistics for an organisation:",
                            subtitle: true
                          },
                          {
                            url: providers_path,
                            text: "Find an Aggregator"
                          },
                          {
                            url: data_providers_path,
                            text: "Find an Institution"
                          }
                      ]
                    }
                  },
                  {
                    url: @about_report.present? ? manual_report_path(@about_report) : false,
                    text: @about_report.present? ? About : ""
                  }
                ]
              }
            }
         }
      end

      def css_files
        [
          { path: styleguide_url('/css/statistics/screen.css'), media: 'all', title: nil }
        ]
      end

      def js_vars
        [
          {
            name: 'rumi_api_endpoint', value: REST_API_ENDPOINT
          }
        ] + super
      end


      def js_files
        [
          {
            path: asset_path('application.js')
          },
          {
            path: asset_path('homepage.js')
          },
          {
            path: styleguide_url('/js/dist/require.js'),
            data_main: styleguide_url('/js/dist/main/main-statistics.js'),
          }
        ]
      end
      def title
        ""
      end

      def content
        {
          charts: {
            main_chart: {
              id: "europeana_navigator_map"
            }
          }
        }
      end

      def gon
        helpers.include_gon
      end

    end
  end
end