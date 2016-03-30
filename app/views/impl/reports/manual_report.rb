module Impl
  module Reports
    class ManualReport < Europeana::Styleguide::View
      def page_title
        "#{@impl_report.name.titleize} - Europeana Statistics Dashboard"
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
          prose: {
            html: @markdown.render(@impl_report.html_content)
          }
        }
      end

      def title
        ""
      end

    end
  end
end
