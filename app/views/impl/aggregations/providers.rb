# frozen_string_literal: true
module Impl
  module Aggregations
    class Providers < Europeana::Styleguide::View
      def page_title
        'Aggregators - Europeana Statistics Dashboard'
      end

      def bodyclass
        'europeana_statsdashboard page_static'
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
              text: 'Europeana statistics'
            },
            primary_nav: {
              menu_id: 'main-menu',
              items: [
                {
                  text: 'Europeana Stats',
                  url: europeana_report_path
                },
                {
                  text: 'Find a dashboard',
                  submenu: {
                    items: [
                      {
                        url: false,
                        text: 'Browse Statistics:',
                        subtitle: true
                      },
                      {
                        url: countries_path,
                        text: 'By Country'
                      },
                      {
                        is_divider: true
                      },
                      {
                        url: false,
                        text: 'Find statistics for an organisation:',
                        subtitle: true
                      },
                      {
                        url: providers_path,
                        text: 'Find an Aggregator'
                      },
                      {
                        url: data_providers_path,
                        text: 'Find an Institution'
                      }
                    ]
                  }
                },
                {
                  url: @about_report.present? ? manual_report_path(@about_report) : false,
                  text: @about_report.present? ? 'About' : ''
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

      def js_files
        [
          {
            path: styleguide_url('/js/dist/require.js'),
            data_main: styleguide_url('/js/dist/main/main-statistics.js')
          }
        ]
      end

      def content
        {
          links: {
            items: Impl::Aggregation.get_providers_json
          },
          prose: {
            html: "<small>Can't find your dashboard? Please check the #{link_to 'About', manual_report_path(@about_report)} section.</small>".html_safe
          }
        }
      end

      def title
        'All Provider Reports'
      end
    end
  end
end
