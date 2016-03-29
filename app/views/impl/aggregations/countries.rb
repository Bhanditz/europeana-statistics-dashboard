module Impl
  module Aggregations
    class Countries < Europeana::Styleguide::View
      def page_title
        'Countries - Europeana Statistics Dashboard'
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
            items: Impl::Aggregation.get_countries_json
          }
        }
      end

      def title
        "All Country Reports"
      end

    end
  end
end
