module Impl
  module Reports
    class Show < Europeana::Styleguide::View
      def page_title
        'Report'
      end

      def title
        page_title
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
          }
        ] + super
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
            text: helpers.include_gon.html_safe + markdown.render(@impl_report.html_content.html_safe).html_safe
          }
        end
      end

      protected

      def markdown
        @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      end
    end
  end
end
