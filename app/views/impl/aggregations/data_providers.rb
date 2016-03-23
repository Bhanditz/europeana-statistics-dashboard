module Impl
  module Aggregations
    class DataProviders < Europeana::Styleguide::View
      def page_title
        'All Data providers'
      end

      def bodyclass
        "europeana_statsdashboard page_static"
      end

      def navigation
        { global: {} }
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
          links:{
            items: Impl::Aggregation.get_data_providers_json
          }
        }
      end

      def title
        "All Data Provider Reports"
      end

    end
  end
end