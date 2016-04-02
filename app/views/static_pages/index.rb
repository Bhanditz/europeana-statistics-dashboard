module StaticPages
  class Index < Europeana::Styleguide::View
    def page_title
      'Europeana Statistics Dashboard'
    end

    def bodyclass
      "europeana_statsdashboard page_home"
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
        	path: asset_path('application.js')
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
        "quicklinks": {
	        "title": "",
          "items":[
            {
              "title":"Find your Dashboard",
              "items":[
                {
                  "text": "Find an Aggregator",
                  "url": providers_path
                },
                {
                  "text": "Find an Institution",
                  "url": data_providers_path
                }
              ]
            },
            {
              "title":"Browse Statistics:",
              "items":[
                {
                  "text": "By Country",
                  "url": countries_path
                }
              ]
            }
          ]
	      }
		  }
    end

    def gon
    	helpers.include_gon
    end
  end
end
