module Impl
  module Aggregations
    class Providers < Europeana::Styleguide::View
      def page_title
        'All Providers'
      end

      def navigation
        { global: {} }
      end

      def head_links
        [
          { rel: 'stylesheet', href: styleguide_url('/css/statistics/screen.css'), media: 'all', title: nil }
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
        {
          links:{
            items: Impl::Aggregation.get_providers_json
          }
        }
      end

    end
  end
end
