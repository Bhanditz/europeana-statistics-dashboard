module Impl
  module Aggregations
    class Countries < Europeana::Styleguide::View
      def page_title
        'All Countries'
      end

      def navigation
        { global: {} }
      end

      def head_links
        [
          { rel: 'stylesheet', href: styleguide_url('/css/pro/screen.css'), media: 'all', title: nil },
          { rel: 'stylesheet', href: asset_path("europeana.css"), media: 'all', title: nil}
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
            data_main: styleguide_url('/js/dist/main/main-collections.js')
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
        @mustache_content ||= begin
          {
            title: page_title,
            text: helpers.include_gon.html_safe + Impl::Aggregation.get_countries_html.html_safe
          }
        end
      end

    end
  end
end
