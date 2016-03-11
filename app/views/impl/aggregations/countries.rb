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
          { rel: 'stylesheet', href: styleguide_url('/css/statistics/screen.css'), media: 'all', title: nil}
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
            items: Impl::Aggregation.get_countries_json
          }
        }
      end

      def footer
        {
          "linklist1":
            {
              "title": "More info",
              "items":
              [
                {
                  "text": "News",
                  "url": "http://google.com"
                },

                {
                  "text": "Contact",
                  "url": "http://google.com"
                },
                false
              ]
            },
            "linklist2": false,
            "subfooter": {
                "items": [
                    {
                        "text": "Home",
                        "url": "./"
                    },
                    {
                        "text": "About us",
                        "url": "./"
                    },
                    {
                        "text": "Terms of use & policies",
                        "url": "http://europeana.eu/portal/rights/terms-and-policies.html"
                    },
                    {
                        "text": "Sitemap",
                        "url": "./"
                    }
                ]
            }
        }
      end

    end
  end
end
