#rake seed:setup
#rake seed:users

namespace :seed do

  task :setup => :environment do
    puts "----> Migrations"
    if Rails.env.development?
      begin
        Rake::Task['db:drop'].invoke
      rescue
        nil
      end
      begin
        Rake::Task['db:create'].invoke
      rescue
        nil
      end
    end
    Rake::Task['db:migrate'].invoke
    Rake::Task['ref:load'].invoke
  end

  task :users => :environment do
    puts "----> Creating users"
    accounts = [["europeana_user@europeana.eu", "europeana_user"]]
    accounts.each do |a|
      c = Account.new(email: a[0], username: a[1], password: "Europeana123!@#", confirmation_sent_at: Time.now)
      c.save
    end
  end

  task :test_db => :environment do
    a = Account.new(email: 'europeana_user@europeana.eu', username: 'europeana_user', password: "Europeana123!@#", confirmation_sent_at: Time.now)
    a.save

    Core::Project.create!([
      {account_id: 1, name: "Europeana", slug: "europeana", properties: {}, is_public: true, created_by: nil, updated_by: nil}
    ])

    Impl::Aggregation.skip_callback(:create, :before, :before_create_set)
    Impl::Aggregation.skip_callback(:create, :after, :after_create_set)
    Impl::Aggregation.create!([{
      core_project_id: 1,
      genre: "provider",
      name: "Rijksmuseum",
      created_by: nil,
      updated_by: nil,
      status: "Failed",
      error_messages: "error_message",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "data_provider",
      name: "Diputació de Barcelona",
      created_by: nil,
      updated_by: nil,
      status: "In Queue",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "country",
      name: "france",
      created_by: 1,
      updated_by: 1,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "provider",
      name: "LoCloud",
      created_by: nil,
      updated_by: nil,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "data_provider",
      name: "DANS-KNAW",
      created_by: nil,
      updated_by: nil,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "country",
      name: "spain",
      created_by: 1,
      updated_by: 1,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-03-31"
    }, {
      core_project_id: 1,
      genre: "europeana",
      name: "Europeana",
      created_by: nil,
      updated_by: nil,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-03-31"
    }])
    Impl::Aggregation.set_callback(:create, :before, :before_create_set)
    Impl::Aggregation.set_callback(:create, :after, :after_create_set)


    Core::Datacast.skip_callback(:create, :before, :before_create_set)
    Core::Datacast.skip_callback(:create, :after, :after_create_set)
    Core::Datacast.create!([{
      core_project_id: 1,
      core_db_connection_id: 1,
      name: "PROVIDER Rijksmuseum - Providers Count",
      identifier: "9d35a217e92ee36ce54ec37ea51d360148b59bddd98a0aa9b85f31352e60b2738a",
      properties: {
        "error" => "", "query" => "Select count(*) as value, '' as key, '' as content, 'Total Institutions' as title, '' as diff_in_value from impl_aggregation_relations where impl_parent_genre='provider' and impl_child_genre='data_provider' and impl_parent_id = '631'",
        "format" => "json",
        "method" => "get",
        "number_of_rows" => "1",
        "number_of_columns" => "5",
        "refresh_frequency" => "0"
      },
      created_by: nil,
      updated_by: nil,
      params_object: {},
      column_properties: {
        "value" => {
          "data_type" => "integer", "d_or_m" => "m", "data_distribution" => {
            "string" => 0, "boolean" => 0, "float" => 0, "integer" => 1, "date" => 0, "blank" => 0
          }
        }, "key" => {
          "data_type" => "string", "d_or_m" => "d", "data_distribution" => {
            "string" => 0, "boolean" => 0, "float" => 0, "integer" => 0, "date" => 0, "blank" => 1
          }
        }, "content" => {
          "data_type" => "string", "d_or_m" => "d", "data_distribution" => {
            "string" => 0, "boolean" => 0, "float" => 0, "integer" => 0, "date" => 0, "blank" => 1
          }
        }, "title" => {
          "data_type" => "string", "d_or_m" => "d", "data_distribution" => {
            "string" => 1, "boolean" => 0, "float" => 0, "integer" => 0, "date" => 0, "blank" => 0
          }
        }, "diff_in_value" => {
          "data_type" => "string", "d_or_m" => "d", "data_distribution" => {
            "string" => 0, "boolean" => 0, "float" => 0, "integer" => 0, "date" => 0, "blank" => 1
          }
        }
      },
      last_run_at: "2016-03-09 08:19:05",
      last_data_changed_at: "2015-12-09 14:35:27",
      count_of_queries: 4,
      average_execution_time: 0.005986304,
      size: 85.0,
      slug: "rijksmuseum-providers-count",
      table_name: ""
    }])
    Core::Datacast.set_callback(:create, :before, :before_create_set)
    Core::Datacast.set_callback(:create, :after, :after_create_set)

    Impl::Output.skip_callback(:create, :before, :before_create_set)
    Impl::Output.skip_callback(:create, :after, :after_create_set)
    Impl::Output.create!([{
      genre: "visits",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 1,
      status: "Built visits",
      error_messages: "",
      key: "",
      value: "",
      properties: {}
    }, {
      genre: "pageviews",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 2,
      status: "Built pageviews",
      error_messages: "",
      key: "",
      value: "",
      properties: {}
    }, {
      genre: "item_views",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 3,
      status: "Processed item views",
      error_messages: "",
      key: "",
      value: "",
      properties: {}
    }, {
      genre: "click_throughs",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 4,
      status: "Processed click throughs",
      error_messages: "",
      key: "",
      value: "",
      properties: {}
    }, {
      genre: "top_media_types",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 5,
      status: "",
      error_messages: "",
      key: "media_type",
      value: "IMAGE",
      properties: {}
    }, {
      genre: "top_reusables",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 6,
      status: "",
      error_messages: "",
      key: "reusable",
      value: "permission",
      properties: {}
    }, {
      genre: "top_countries",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 7,
      status: "",
      error_messages: "",
      key: "country",
      value: "Spain",
      properties: {}
    }, {
      genre: "top_digital_objects",
      impl_parent_type: "Impl::Aggregation",
      impl_parent_id: 8,
      status: "",
      error_messages: "",
      key: "title",
      value: "MAROC XIX E 313",
      properties: {
        "image_url" => "http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO", "title_url" => "http://www.europeana.eu/portal/record/09328/2CAB9DDED28F8369CC89575706430F94D66D80C4.html"
      }
    }])
    Impl::Output.set_callback(:create, :before, :before_create_set)
    Impl::Output.set_callback(:create, :after, :after_create_set)

    Impl::Aggregation.skip_callback(:create, :before, :before_create_set)
    Impl::Aggregation.skip_callback(:create, :after, :after_create_set)
    Impl::Aggregation.create!([{
      core_project_id: 1,
      genre: "data_provider",
      name: "DANS-KNAW",
      created_by: nil,
      updated_by: nil,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "country",
      name: "france",
      created_by: 1,
      updated_by: 1,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "provider",
      name: "LoCloud",
      created_by: nil,
      updated_by: nil,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "data_provider",
      name: "Diputació de Barcelona",
      created_by: nil,
      updated_by: nil,
      status: "In Queue",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "provider",
      name: "Rijksmuseum",
      created_by: nil,
      updated_by: nil,
      status: "Failed",
      error_messages: "error_message",
      properties: {},
      last_updated_at: "2016-02-29"
    }, {
      core_project_id: 1,
      genre: "country",
      name: "spain",
      created_by: 1,
      updated_by: 1,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-03-31"
    }, {
      core_project_id: 1,
      genre: "europeana",
      name: "Europeana",
      created_by: nil,
      updated_by: nil,
      status: "Report built",
      error_messages: "",
      properties: {},
      last_updated_at: "2016-03-31"
    }])
    Impl::Aggregation.set_callback(:create, :before, :before_create_set)
    Impl::Aggregation.set_callback(:create, :after, :after_create_set)

    Impl::AggregationDataSet.skip_callback(:create, :before, :before_create_set)
    Impl::AggregationDataSet.skip_callback(:create, :after, :after_create_set)
    Impl::AggregationDataSet.create!([{
      impl_aggregation_id: 1,
      impl_data_set_id: 1
    }, {
      impl_aggregation_id: 2,
      impl_data_set_id: 2
    }, {
      impl_aggregation_id: 3,
      impl_data_set_id: 3
    }, {
      impl_aggregation_id: 4,
      impl_data_set_id: 4
    }, {
      impl_aggregation_id: 5,
      impl_data_set_id: 5
    }, {
      impl_aggregation_id: 6,
      impl_data_set_id: 6
    }])
    Impl::AggregationDataSet.set_callback(:create, :before, :before_create_set)
    Impl::AggregationDataSet.set_callback(:create, :after, :after_create_set)

    Impl::DataSet.skip_callback(:create, :before, :before_create_set)
    Impl::DataSet.skip_callback(:create, :after, :after_create_set)
    Impl::DataSet.create!([{
      data_set_id: "91956",
      created_by: nil,
      updated_by: nil,
      status: "In queue",
      error_messages: "",
      impl_aggregation_id: nil,
      name: "91956_L_Es_BibCatalunya_fulletsAB"
    }, {
      data_set_id: "91996",
      created_by: nil,
      updated_by: nil,
      status: "In queue",
      error_messages: "",
      impl_aggregation_id: nil,
      name: "91996_L_Es_BibCatalunya_IGuerraMuAB"
    }, {
      data_set_id: "91959",
      created_by: nil,
      updated_by: nil,
      status: "In queue",
      error_messages: "",
      impl_aggregation_id: nil,
      name: "91959_L_Es_BibCatalunya_incunableAB"
    }, {
      data_set_id: "91947",
      created_by: nil,
      updated_by: nil,
      status: "In queue",
      error_messages: "",
      impl_aggregation_id: nil,
      name: "91947_L_Es_BibCatalunya_abertrana"
    }, {
      data_set_id: "09317",
      created_by: nil,
      updated_by: nil,
      status: "In queue",
      error_messages: "",
      impl_aggregation_id: nil,
      name: "09317_Ag_EU_Judaica_Museo_Sefardi_Toledo"
    }, {
      data_set_id: "92078",
      created_by: nil,
      updated_by: nil,
      status: "In queue",
      error_messages: "",
      impl_aggregation_id: nil,
      name: "92078_Ag_EU_TEL_a1030_EuropanaRegia"
    }
    ])
    Impl::DataSet.set_callback(:create, :before, :before_create_set)
    Impl::DataSet.set_callback(:create, :after, :after_create_set)

    Impl::Report.skip_callback(:create, :before, :before_create_set)
    Impl::Report.skip_callback(:create, :after, :after_create_set)
    Impl::Report.create!([{
      impl_aggregation_id: 1,
      core_template_id: nil,
      name: "About This Dashboard",
      slug: "about-this-dashboard",
      html_content: "The Europeana Statistics Dashboard has been developed to act as a space where partners, researchers, stakeholders and anyone interested in Europeana can interact and re-use the statistics coming out of our websites and services. Europeana is a network, representing more than 2,500 cultural heritage organisations and a thousand individuals from these and other walks of life, passionate about bringing Europe’s vast wealth of cultural heritage to the world. \r\n\r\nTraditionally our statistics and metrics have been locked up in formatted documents, now we are liberating that data, visualising it and making it embeddable and re-useable. With this dashboard it is now much easier to see how Europeana has progressed and evolved through the years and how we are working to increase the reach of our data providers’ collections. Many of the visualisations are dynamic and utilise both the Europeana and Google Analytics APIs to generate charts that are accurate and up to date. \r\n\r\nSome of the key metrics that we are visualising in this dashboard include traffic and usage figures for the Europeana.eu website, social media reach, the size and composition of the Europeana repository, together with the number of digital object views on Europeana for a selection of our data providers. \r\n\r\nAn alpha version of the Statistics Dashboard was released in October 2014 and a beta version is due to be realised in 2015. During this alpha phase we are eager to hear your feedback, also if you are a data provider and would like to have statistics related to your collection available via this dashboard please [**contact us**][1].\r\n\r\n\r\n  [1]: http://statistics.europeana.eu/contact",
      variable_object: {},
      is_autogenerated: false,
      core_project_id: 1,
      impl_aggregation_genre: nil
    }, {
      impl_aggregation_id: 2,
      core_template_id: nil,
      name: "Content: 2014",
      slug: "content-2014",
      html_content: "This section of the dashboard visualises various aspects of the digital objects available in the Europeana repository during 2014. Charts display the re-use status of the digital objects, the types of digital objects available, together with a breakdown from which countries the digital objects originate. All visualisations are broken down by quarter to see how Europeana has grown and evolved over time. Every month the Europeana aggregation team publishes new collections and updates to the Europeana repository from hundreds of institutions. \r\n\r\nThis entire article along with all individual charts is embeddable. Also the data from each visualisation is downloadable in CSV format. We encourage you to use these charts and data in your own research and reporting. If you would like more detailed statistics, please [**contact us**][1] and we will be more than happy to provide you with more information.\r\n\r\n<div class='row'><div class='col-sm-6'><H4>Total Items in Europeana & Re-use Status</H4>This chart displays the total number of digital objects in Europeana by re-use status between Q1 and Q4 of 2014. (Filter by quarter within the chart)\r\n<br><br/> \r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/hWlOO/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"550\" height=\"350\"></iframe></div><div class='col-sm-6'><H4>Breakdown of Item Types in Europeana</H4>This chart displays a breakdown of the types of digital objects in  Europeana between Q1 and Q4 of 2014. (Filter by quarter within the chart)<p></p><iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/8lK9X/2/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"550\" height=\"350\"></iframe></div></div>\r\n<p><p/>\r\n<H4>Items Per Country in Europeana</H4>\r\nThis chart displays a breakdown from which countries the digital objects in Europeana originate between Q1 and Q4 of 2014. (Filter by quarter within the chart)\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/ciM2u/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"100%\" height=\"550\"></iframe>\r\n\r\n\r\n\r\n\r\n\r\n \r\n\r\n\r\n  [1]: http://statistics.europeana.eu/contact\r\n",
      variable_object: {},
      is_autogenerated: false,
      core_project_id: 1,
      impl_aggregation_genre: nil
    }, {
      impl_aggregation_id: 3,
      core_template_id: nil,
      name: "Traffic & Usage: 2014",
      slug: "traffic-usage-2014",
      html_content: "This section of the dashboard visualises the main traffic dimensions of web traffic and usage on the Europeana.eu website in 2014. Social media and Wikipedia related statistics are also visualised to showcase the increased reach of data providers’ collections outside of the Europeana.eu website. \r\n\r\nAll charts show data from 2014 and many of them can be broken down by quarter. The data in this section is sourced from Google Analytics for traffic, BaGLAMa for Wikipedia, Facebook Insights and Pinterest Analytics. \r\n\r\nThis entire article along with all individual charts is embeddable. Also the data from each visualisation is downloadable in CSV format. We encourage you to use these charts and data in your own research and reporting. If you would like more detailed statistics, please [**contact us**][1] and we will be more than happy to provide you with more information.\r\n\r\n<div class='row'><div class='col-sm-6'>\r\n<H4> Europeana.eu: Pageviews, Visits & Click-throughs</H4>\r\nThe chart displays number of pageviews and visits on the Europeana.eu website together with the number of times a user clicked through to the website of a data provider between Q1 and Q4 of 2014. (Filter by quarter within the chart)\r\n<p></p>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/zBTeq/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe></iframe></iframe>\r\n</div>\r\n\r\n<h4>Europeana.eu: New vs. Returning Visits</h4>\r\nThis chart displays the percentage of new and returning visits to the Europeana.eu website between Q1 and Q4 of 2014. \r\n(Filter by quarter within the chart)\r\n<p><p/>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/v8tVW/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n\r\n</div></div>\r\n\r\n<H4> Europeana.eu: Top 100 Countries</H4>\r\nThis chart displays the top 100 countries based on the number of visits to the Europeana.eu website between Q1 and Q4 of 2014.\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/JxVDs/4/\" frameborder=\"0\" scrolling=\"no\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"100%\" height=\"600\"></iframe>\r\n\r\n<div class='row'><div class='col-sm-6'>\r\n<h4>Europeana.eu: Traffic Sources</h4>\r\n\r\nThis chart displays a breakdown of traffic sources based on the number of visits to the Europeana.eu website between Q1 and Q4 of 2014. (Filter by quarter within the chart)\r\n<p></p>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/862Cw/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n\r\n<h4>Europeana.eu: Digital Object & Search Result Pageviews</h4>\r\n\r\nThis chart displays the number of pageviews of digital objects and search result pages on the Europeana.eu website between Q1 and Q4 2014.\r\n<p></p>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/EXwbm/4/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n<div class='row'><div class='col-sm-6'></div>\r\n\r\n\r\n\r\n\r\n</div></div>\r\n\r\n<div class='row'><div class='col-sm-6'>\r\n\r\n<h4>Europeana.eu: Tablet & Mobile Devices</h4>\r\n\r\nThis chart displays a breakdown of visits to the Europeana.eu website that were from a desktop, tablet or mobile device between Q1 and Q4 of 2014. (Filter by quarter within the chart)\r\n<p></p>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/tWMNz/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n</div>\r\n\r\n<h4>Europeana.eu: Search Usage</h4>\r\n\r\nThis chart displays the number of visits during which at least one search occurred together with the number of unique times a search was performed on the Europeana.eu website between Q1 and Q4 2014.\r\n<p></p>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/lCOAz/7/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n</div>\r\n\r\n</div></div>\r\n\r\n<h4>Off-site reach: Impressions on Wikipedia, Facebook & Pinterest</h4>\r\nThis chart displays the number of impressions of cultural heritage collections on Wikipedia, Facebook and Pinterest as a result of Europeana’s outreach activities between Q1 and Q4 of 2014.\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/PYywJ/4/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"100%\" height=\"450\"></iframe>\r\n\r\n<div class='row'><div class='col-sm-6'>\r\n\r\n<h4>Facebook: Engaged Users</h4>\r\n\r\nThis chart displays the number of unique users that engaged with collections published on the Europeana Facebook page between Q1 and Q4 of 2014.\r\n<p><p/>\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/bZehq/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n\r\n</div><div class='col-sm-6'>\r\n\r\n<h4>Wikimedia & Wikipedia: Uploaded & Used Images</h4>\r\n\r\nThis chart displays the number of  images uploaded to Wikimedia together with how many of those are used in Wikipedia articles as a result of Europeana’s outreach activities between Q1 and Q4 of 2014.\r\n<p><p/>\r\n\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/7NnCS/3/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe>\r\n\r\n</div></div>\r\n\r\n\r\n  [1]: http://statistics.europeana.eu/contact",
      variable_object: {},
      is_autogenerated: false,
      core_project_id: 1,
      impl_aggregation_genre: nil
    }, {
      impl_aggregation_id: 4,
      core_template_id: nil,
      name: "Content: 2013",
      slug: "content-2013",
      html_content: "This section of the dashboard visualises various aspects of the digital objects available in the Europeana repository during 2013. Charts display the re-use status of the digital objects, the types of digital objects available, together with a breakdown from which countries the digital objects originate. All visualisations are broken down by quarter to see how Europeana has grown and evolved over time. Every month the Europeana aggregation team publishes new collections and updates to the Europeana repository from hundreds of institutions. \r\n\r\nThis entire article along with all individual charts is embeddable. Also the data from each visualisation is downloadable in CSV format. We encourage you to use these charts and data in your own research and reporting. If you would like more detailed statistics, please [**contact us**][1] and we will be more than happy to provide you with more information.\r\n\r\n<div class='row'><div class='col-sm-6'><H4>Total Items in Europeana & Re-use Status</H4>This chart displays the total number of digital objects in Europeana by re-use status between Q1 and Q4 of 2013. (Filter by quarter within the chart) \r\n<br><br/> \r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/1sQfV/1/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"550\" height=\"350\"></iframe></div><div class='col-sm-6'><H4>Breakdown of Item Types in Europeana</H4>This chart displays a breakdown of the types of digital objects in Europeana between Q1 and Q4 of 2013. (Filter by quarter within the chart)<p></p><iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/aNHxr/1/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"550\" height=\"350\"></iframe></div></div>\r\n\r\n<H4>Items Per Country in Europeana</H4>\r\nThis chart displays a breakdown from which countries the digital objects in Europeana originate between Q1 and Q4 of 2013. (Filter by quarter within the chart)\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/Hqy1U/4/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"100%\" height=\"550\"></iframe>\r\n\r\n  [1]: http://statistics.europeana.eu/contact",
      variable_object: {},
      is_autogenerated: false,
      core_project_id: 1,
      impl_aggregation_genre: nil
    }, {
      impl_aggregation_id: 7,
      core_template_id: nil,
      name: "Content",
      slug: "content",
      html_content: "This section of the dashboard visualises various aspects of the digital objects available in the Europeana repository between 2012 and 2015. Charts display the re-use status of the digital objects, the types of digital objects available, together with a breakdown from which countries the digital objects originate. All visualisations are broken down by year to see how Europeana has grown and evolved over time. Every month the Europeana aggregation team publishes new collections and updates to the Europeana repository from hundreds of institutions. \r\n\r\nThis entire article along with all individual charts is embeddable. Also the data from each visualisation is downloadable in CSV format. We encourage you to use these charts and data in your own research and reporting. If you would like more detailed statistics, please [**contact us**][1] and we will be more than happy to provide you with more information.\r\n\r\n\r\n<div class='row'><div class='col-sm-6'><H4>Total Items in Europeana & Re-use Status</H4>This chart displays the total number of digital objects in Europeana by re-use status between 2012 and 2015.  \r\n(Filter by year within the chart)\r\n<br><br/> \r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/1QniL/2/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe></div><div class='col-sm-6'><H4>Breakdown of Item Types in Europeana</H4>This chart displays a breakdown of the types of digital objects in  Europeana between 2012 and 2015. \r\n\r\n(Filter by year within the chart)<p></p><iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/vibsl/1/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"450\" height=\"350\"></iframe></div></div>\r\n<p><p/>\r\n<H4>Items Per Country in Europeana</H4>\r\nThis chart displays a breakdown from which countries the digital objects in Europeana originate between  2012 and 2015. (Filter by year within the chart)\r\n<iframe src=\"//dw-europeana.s3-website-us-west-2.amazonaws.com/3yxw6/5/\" frameborder=\"0\" allowtransparency=\"true\" allowfullscreen=\"allowfullscreen\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" oallowfullscreen=\"oallowfullscreen\" msallowfullscreen=\"msallowfullscreen\" width=\"100%\" height=\"550\"></iframe>\r\n\r\n\r\n\r\n\r\n\r\n \r\n\r\n\r\n  [1]: http://statistics.europeana.eu/contact    ",
      variable_object: {},
      is_autogenerated: false,
      core_project_id: 1,
      impl_aggregation_genre: nil
    }])
    Impl::Report.set_callback(:create, :before, :before_create_set)
    Impl::Report.set_callback(:create, :after, :after_create_set)

    Impl::BlacklistDataset.skip_callback(:create, :before, :before_create_set)
    Impl::BlacklistDataset.skip_callback(:create, :after, :after_create_set)
    Impl::BlacklistDataset.create!([
      {dataset: "2023601_Ag_DE_DISMARC"},
      {dataset: "2022608_Ag_NO_ELocal_DiMu"},
      {dataset: "2023003_Ag_BE_Elocal_Erfgoedregister"},
      {dataset: "2022611_Ag_NO_ELocal_difo"},
      {dataset: "08701_Ag_EU_BHL"}
    ])
    Impl::BlacklistDataset.set_callback(:create, :before, :before_create_set)
    Impl::BlacklistDataset.set_callback(:create, :after, :after_create_set)

    Core::Viz.skip_callback(:create, :before, :before_create_set)
    Core::Viz.skip_callback(:create, :after, :after_create_set)
    Core::Viz.create!([{
      core_project_id: 1,
      properties: {},
      name: "PROVIDER Digitising Contemporary Art - Media Type Donut Chart",
      config: {
        "mode" => "default", "chart_height" => 400, "chart_width" => 600, "chart_margin_top" => 35, "chart_margin_right" => 25, "chart_margin_bottom" => 35, "chart_margin_left" => 60, "title_text" => "", "title_size" => 2, "title_color" => "#1D1D1D", "title_weight" => "bold", "title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "subtitle_text" => "", "subtitle_size" => 1, "subtitle_color" => "black", "subtitle_weight" => "normal", "subtitle_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "highlight" => "Nissan", "highlight_color" => "#08306b", "background_color" => "#FFFFFF", "chart_color" => ["#255AEE"], "saturation_color" => "#255AEE", "border_between_chart_elements_thickness" => 1, "border_between_chart_elements_color" => "white", "border_between_chart_elements_style" => "solid", "legends_enable" => "yes", "legends_display" => "horizontal", "legends_text_size" => 13, "legends_text_color" => "#1D1D1D", "legends_text_weight" => "normal", "legends_text_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "label_size" => 13, "label_color" => "white", "label_weight" => "normal", "label_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pointer_overflow_enable" => "yes", "pointer_thickness" => 1, "pointer_weight" => "normal", "pointer_size" => 13, "pointer_color" => "#1D1D1D", "pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "export_enable" => "no", "color_mode" => "saturation", "axis_x_pointer_size" => 12, "axis_x_pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_x_pointer_weight" => "normal", "axis_x_pointer_color" => "#1D1D1D", "axis_x_enable" => "yes", "axis_x_title" => "", "axis_x_title_size" => 14, "axis_x_title_color" => "#1D1D1D", "axis_x_title_weight" => "bold", "axis_x_title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_x_position" => "bottom", "axis_x_pointer_position" => "bottom", "axis_x_line_color" => "#1D1D1D", "axis_x_no_of_axis_value" => 5, "axis_x_pointer_length" => 5, "axis_x_pointer_padding" => 6, "axis_x_pointer_values" => [], "axis_x_outer_pointer_length" => 0, "axis_x_time_value_datatype" => "month", "axis_x_time_value_interval" => 0, "axis_x_data_format" => "string", "loading_gif_url" => "https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/distribution/img/loader.gif", "tooltip_enable" => "yes", "tooltip_mode" => "moving", "credit_my_site_name" => "Pykih", "credit_my_site_url" => "http://www.pykih.com", "data_source_name" => "Rumi.io", "data_source_url" => "http://rumi.io", "real_time_charts_refresh_frequency" => 0, "real_time_charts_last_updated_at_enable" => "no", "transition_duration" => 0, "clubdata_enable" => "yes", "clubdata_text" => "Others", "clubdata_maximum_nodes" => 5, "pie_radius_percent" => 70, "donut_radius_percent" => 70, "donut_inner_radius_percent" => 40, "donut_show_total_at_center" => "yes", "donut_show_total_at_center_size" => 14, "donut_show_total_at_center_color" => "#1D1D1D", "donut_show_total_at_center_weight" => "bold", "donut_show_total_at_center_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "funnel_rect_width" => 100, "funnel_rect_height" => 100, "percent_column_rect_width" => 15, "percent_row_rect_height" => 26, "pictograph_show_all_images" => "yes", "pictograph_total_count_enable" => "yes", "pictograph_current_count_enable" => "yes", "pictograph_image_per_line" => 3, "pictograph_image_width" => 79, "pictograph_image_height" => 66, "pictograph_current_count_size" => 64, "pictograph_current_count_color" => "#255AEE", "pictograph_current_count_weight" => "normal", "pictograph_current_count_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pictograph_total_count_size" => 64, "pictograph_total_count_color" => "grey", "pictograph_total_count_weight" => "normal", "pictograph_total_count_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pictograph_units_per_image_text_size" => 24, "pictograph_units_per_image_text_color" => "grey", "pictograph_units_per_image_text_weight" => "normal", "pictograph_units_per_image_text_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "chart_grid_x_enable" => "yes", "chart_grid_y_enable" => "yes", "chart_grid_color" => "#dddddd", "axis_onhover_highlight_enable" => "no", "axis_y_pointer_size" => 12, "axis_y_pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_y_pointer_weight" => "normal", "axis_y_pointer_color" => "#1D1D1D", "axis_y_enable" => "yes", "axis_y_title" => "", "axis_y_title_size" => 14, "axis_y_title_color" => "#1D1D1D", "axis_y_title_weight" => "bold", "axis_y_title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_y_position" => "left", "axis_y_pointer_position" => "left", "axis_y_line_color" => "#1D1D1D", "axis_y_no_of_axis_value" => 5, "axis_y_pointer_length" => 5, "axis_y_pointer_padding" => 6, "axis_y_pointer_values" => [], "axis_y_outer_pointer_length" => 0, "axis_y_time_value_datatype" => "month", "axis_y_time_value_interval" => 0, "axis_y_data_format" => "number", "panels_enable" => "no", "variable_circle_size_enable" => "yes", "crosshair_enable" => "yes", "zoom_enable" => "no", "zoom_level" => 3, "spiderweb_outer_radius_percent" => 80, "scatterplot_radius" => 20, "scatterplot_pointer_enable" => "no", "curvy_lines_enable" => "no", "annotation_enable" => "no", "annotation_view_mode" => "onload", "annotation_background_color" => "#C2CBCF", "annotation_font_color" => "black", "data_sort_enable" => "no", "data_sort_type" => "alphabetically", "data_sort_order" => "ascending", "tooltip_position_top" => 0, "tooltip_position_left" => 0, "timeline_duration" => 1, "timeline_margin_top" => 5, "timeline_margin_right" => 25, "timeline_margin_bottom" => 25, "timeline_margin_left" => 45, "label_enable" => "no", "click_enable" => "no", "onhover" => "shadow", "shade_color" => "#255AEE", "axis_x_formatting_enable" => "no", "default_color" => ["#E4E4E4"], "map_code" => "world"
      },
      created_by: nil,
      updated_by: nil,
      ref_chart_combination_code: "a93b2d",
      core_datacast_identifier: "1b19f5de7ad7b4dbf2698a2e11194b0cabe96b5f22c0592a1a389e9a49b22f0539",
      filter_present: false,
      is_autogenerated: true
    }])
    Core::Viz.set_callback(:create, :before, :before_create_set)
    Core::Viz.set_callback(:create, :after, :after_create_set)

    Ref::Chart.skip_callback(:create, :before, :before_create_set)
    Ref::Chart.skip_callback(:create, :after, :after_create_set)
    Ref::Chart.create!([{
      name: "Multi-series Line",
      description: "Sometimes we wish to visualise the trend based behaviour of several data sets against a common ordinal/ interval data range. In such cases a multi-series line offers insight into both the trend behaviour and comparison between trend behaviour for different data sets",
      img_small: "https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/icons/multi-line.png",
      genre: "Multi Dimensional Charts",
      map: "{\"dimensions_required\":2,\"metrics_required\":1,\"dimensions_alias\":[\"x\",\"name\"],\"metrics_alias\":[\"y\"]}",
      api: "PykCharts.multiD.multiSeriesLine",
      created_by: nil,
      updated_by: nil,
      img_data_mapping: "https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/icons/data.multi-series.line.png",
      slug: "multi-series-line",
      combination_code: "f80d2e",
      source: "public/PykCharts/src/js/multiD/multiD.js",
      file_path: "public/PykCharts/src/js/multiD/lineChart.js",
      sort_order: 2
    }])
    Ref::Chart.set_callback(:create, :before, :before_create_set)
    Ref::Chart.set_callback(:create, :after, :after_create_set)

    Core::Theme.skip_callback(:create, :before, :before_create_set)
    Core::Theme.skip_callback(:create, :after, :after_create_set)
    Core::Theme.create!([{
      account_id: nil,
      name: "Default",
      sort_order: 1,
      config: {
        "mode" => "default", "chart_height" => 400, "chart_width" => 600, "chart_margin_top" => 35, "chart_margin_right" => 25, "chart_margin_bottom" => 35, "chart_margin_left" => 60, "title_text" => "", "title_size" => 2, "title_color" => "#1D1D1D", "title_weight" => "bold", "title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "subtitle_text" => "", "subtitle_size" => 1, "subtitle_color" => "black", "subtitle_weight" => "normal", "subtitle_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "highlight" => "Nissan", "highlight_color" => "#08306b", "background_color" => "#FFFFFF", "chart_color" => ["#255AEE"], "saturation_color" => "#255AEE", "border_between_chart_elements_thickness" => 1, "border_between_chart_elements_color" => "white", "border_between_chart_elements_style" => "solid", "legends_enable" => "yes", "legends_display" => "horizontal", "legends_text_size" => 13, "legends_text_color" => "#1D1D1D", "legends_text_weight" => "normal", "legends_text_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "label_size" => 13, "label_color" => "white", "label_weight" => "normal", "label_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pointer_overflow_enable" => "yes", "pointer_thickness" => 1, "pointer_weight" => "normal", "pointer_size" => 13, "pointer_color" => "#1D1D1D", "pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "export_enable" => "no", "color_mode" => "saturation", "axis_x_pointer_size" => 12, "axis_x_pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_x_pointer_weight" => "normal", "axis_x_pointer_color" => "#1D1D1D", "axis_x_enable" => "yes", "axis_x_title" => "", "axis_x_title_size" => 14, "axis_x_title_color" => "#1D1D1D", "axis_x_title_weight" => "bold", "axis_x_title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_x_position" => "bottom", "axis_x_pointer_position" => "bottom", "axis_x_line_color" => "#1D1D1D", "axis_x_no_of_axis_value" => 5, "axis_x_pointer_length" => 5, "axis_x_pointer_padding" => 6, "axis_x_pointer_values" => [], "axis_x_outer_pointer_length" => 0, "axis_x_time_value_datatype" => "month", "axis_x_time_value_interval" => 0, "axis_x_data_format" => "string", "loading_gif_url" => "https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/distribution/img/loader.gif", "tooltip_enable" => "yes", "tooltip_mode" => "moving", "credit_my_site_name" => "Pykih", "credit_my_site_url" => "http://www.pykih.com", "data_source_name" => "Rumi.io", "data_source_url" => "http://rumi.io", "real_time_charts_refresh_frequency" => 0, "real_time_charts_last_updated_at_enable" => "no", "transition_duration" => 0, "clubdata_enable" => "yes", "clubdata_text" => "Others", "clubdata_maximum_nodes" => 5, "pie_radius_percent" => 70, "donut_radius_percent" => 70, "donut_inner_radius_percent" => 40, "donut_show_total_at_center" => "yes", "donut_show_total_at_center_size" => 14, "donut_show_total_at_center_color" => "#1D1D1D", "donut_show_total_at_center_weight" => "bold", "donut_show_total_at_center_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "funnel_rect_width" => 100, "funnel_rect_height" => 100, "percent_column_rect_width" => 15, "percent_row_rect_height" => 26, "pictograph_show_all_images" => "yes", "pictograph_total_count_enable" => "yes", "pictograph_current_count_enable" => "yes", "pictograph_image_per_line" => 3, "pictograph_image_width" => 79, "pictograph_image_height" => 66, "pictograph_current_count_size" => 64, "pictograph_current_count_color" => "#255AEE", "pictograph_current_count_weight" => "normal", "pictograph_current_count_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pictograph_total_count_size" => 64, "pictograph_total_count_color" => "grey", "pictograph_total_count_weight" => "normal", "pictograph_total_count_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pictograph_units_per_image_text_size" => 24, "pictograph_units_per_image_text_color" => "grey", "pictograph_units_per_image_text_weight" => "normal", "pictograph_units_per_image_text_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "chart_grid_x_enable" => "yes", "chart_grid_y_enable" => "yes", "chart_grid_color" => "#dddddd", "axis_onhover_highlight_enable" => "no", "axis_y_pointer_size" => 12, "axis_y_pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_y_pointer_weight" => "normal", "axis_y_pointer_color" => "#1D1D1D", "axis_y_enable" => "yes", "axis_y_title" => "", "axis_y_title_size" => 14, "axis_y_title_color" => "#1D1D1D", "axis_y_title_weight" => "bold", "axis_y_title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_y_position" => "left", "axis_y_pointer_position" => "left", "axis_y_line_color" => "#1D1D1D", "axis_y_no_of_axis_value" => 5, "axis_y_pointer_length" => 5, "axis_y_pointer_padding" => 6, "axis_y_pointer_values" => [], "axis_y_outer_pointer_length" => 0, "axis_y_time_value_datatype" => "month", "axis_y_time_value_interval" => 0, "axis_y_data_format" => "number", "panels_enable" => "no", "variable_circle_size_enable" => "yes", "crosshair_enable" => "yes", "zoom_enable" => "no", "zoom_level" => 3, "spiderweb_outer_radius_percent" => 80, "scatterplot_radius" => 20, "scatterplot_pointer_enable" => "no", "curvy_lines_enable" => "no", "annotation_enable" => "no", "annotation_view_mode" => "onload", "annotation_background_color" => "#C2CBCF", "annotation_font_color" => "black", "data_sort_enable" => "no", "data_sort_type" => "alphabetically", "data_sort_order" => "ascending", "tooltip_position_top" => 0, "tooltip_position_left" => 0, "timeline_duration" => 1, "timeline_margin_top" => 5, "timeline_margin_right" => 25, "timeline_margin_bottom" => 25, "timeline_margin_left" => 45, "label_enable" => "no", "click_enable" => "no", "onhover" => "shadow", "shade_color" => "#255AEE", "axis_x_formatting_enable" => "no", "default_color" => ["#E4E4E4"], "map_code" => "world"
      },
      image_url: "https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/themes/pie-Default.png",
      created_by: nil,
      updated_by: nil
    }, {
      account_id: nil,
      name: "Dusk",
      sort_order: 2,
      config: {
        "mode" => "default", "chart_height" => 400, "chart_width" => 600, "chart_margin_top" => 35, "chart_margin_right" => 25, "chart_margin_bottom" => 35, "chart_margin_left" => 50, "title_text" => "", "title_size" => 2, "title_color" => "#8B0000", "title_weight" => "normal", "title_family" => "Garamond, Times New Roman, Times, serif", "subtitle_text" => "", "subtitle_size" => 1, "subtitle_color" => "#302B54", "subtitle_weight" => "normal", "subtitle_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "highlight" => "Nissan", "highlight_color" => "#7F00FF", "background_color" => "#D9D9F3", "chart_color" => ["#5959AB"], "saturation_color" => "#5959AB", "border_between_chart_elements_thickness" => 1, "border_between_chart_elements_color" => "white", "border_between_chart_elements_style" => "solid", "legends_enable" => "yes", "legends_display" => "horizontal", "legends_text_size" => 13, "legends_text_color" => "#333B42", "legends_text_weight" => "normal", "legends_text_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "label_size" => 13, "label_color" => "white", "label_weight" => "normal", "label_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pointer_overflow_enable" => "yes", "pointer_thickness" => 1, "pointer_weight" => "normal", "pointer_size" => 13, "pointer_color" => "#333B42", "pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "export_enable" => "no", "color_mode" => "saturation", "axis_x_pointer_size" => 12, "axis_x_pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_x_pointer_weight" => "normal", "axis_x_pointer_color" => "#333B42", "axis_x_enable" => "yes", "axis_x_title" => "", "axis_x_title_size" => 14, "axis_x_title_color" => "#302B54", "axis_x_title_weight" => "bold", "axis_x_title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_x_position" => "bottom", "axis_x_pointer_position" => "bottom", "axis_x_line_color" => "#1D1D1D", "axis_x_no_of_axis_value" => 5, "axis_x_pointer_length" => 5, "axis_x_pointer_padding" => 6, "axis_x_pointer_values" => [], "axis_x_outer_pointer_length" => 0, "axis_x_time_value_datatype" => "month", "axis_x_time_value_interval" => 0, "axis_x_data_format" => "string", "loading_gif_url" => "https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/distribution/img/loader.gif", "tooltip_enable" => "yes", "tooltip_mode" => "moving", "credit_my_site_name" => "Pykih", "credit_my_site_url" => "http://www.pykih.com", "data_source_name" => "Rumi.io", "data_source_url" => "http://rumi.io", "real_time_charts_refresh_frequency" => 0, "real_time_charts_last_updated_at_enable" => "no", "transition_duration" => 0, "clubdata_enable" => "yes", "clubdata_text" => "Others", "clubdata_maximum_nodes" => 5, "pie_radius_percent" => 70, "donut_radius_percent" => 70, "donut_inner_radius_percent" => 40, "donut_show_total_at_center" => "yes", "donut_show_total_at_center_size" => 14, "donut_show_total_at_center_color" => "#333B42", "donut_show_total_at_center_weight" => "bold", "donut_show_total_at_center_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "funnel_rect_width" => 120, "funnel_rect_height" => 170, "percent_column_rect_width" => 16, "percent_row_rect_height" => 16, "pictograph_show_all_images" => "yes", "pictograph_total_count_enable" => "yes", "pictograph_current_count_enable" => "yes", "pictograph_image_per_line" => 3, "pictograph_image_width" => 79, "pictograph_image_height" => 66, "pictograph_current_count_size" => 64, "pictograph_current_count_color" => "#5959AB", "pictograph_current_count_weight" => "normal", "pictograph_current_count_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pictograph_total_count_size" => 64, "pictograph_total_count_color" => "#333B42", "pictograph_total_count_weight" => "normal", "pictograph_total_count_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "pictograph_units_per_image_text_size" => 24, "pictograph_units_per_image_text_color" => "#333B42", "pictograph_units_per_image_text_weight" => "normal", "pictograph_units_per_image_text_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "chart_grid_x_enable" => "yes", "chart_grid_y_enable" => "yes", "chart_grid_color" => "#dddddd", "axis_onhover_highlight_enable" => "no", "axis_y_pointer_size" => 12, "axis_y_pointer_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_y_pointer_weight" => "normal", "axis_y_pointer_color" => "#333B42", "axis_y_enable" => "yes", "axis_y_title" => "", "axis_y_title_size" => 14, "axis_y_title_color" => "#302B54", "axis_y_title_weight" => "bold", "axis_y_title_family" => "Helvetica Neue,Helvetica,Arial,sans-serif", "axis_y_position" => "left", "axis_y_pointer_position" => "left", "axis_y_line_color" => "#1D1D1D", "axis_y_no_of_axis_value" => 5, "axis_y_pointer_length" => 5, "axis_y_pointer_padding" => 6, "axis_y_pointer_values" => [], "axis_y_outer_pointer_length" => 0, "axis_y_time_value_datatype" => "month", "axis_y_time_value_interval" => 0, "axis_y_data_format" => "number", "panels_enable" => "no", "variable_circle_size_enable" => "yes", "crosshair_enable" => "yes", "zoom_enable" => "no", "zoom_level" => 3, "spiderweb_outer_radius_percent" => 80, "scatterplot_radius" => 20, "scatterplot_pointer_enable" => "no", "curvy_lines_enable" => "yes", "annotation_enable" => "no", "annotation_view_mode" => "onclick", "annotation_background_color" => "#F2F2F2", "annotation_font_color" => "#333B42", "data_sort_enable" => "no", "data_sort_type" => "alphabetically", "data_sort_order" => "ascending", "total_no_of_colors" => 3, "palette_color" => "Blue-1", "tooltip_position_top" => 0, "tooltip_position_left" => 0, "timeline_duration" => 1, "timeline_margin_top" => 5, "timeline_margin_noht" => 25, "timeline_margin_bottom" => 25, "timeline_margin_left" => 45, "label_enable" => "no", "click_enable" => "no", "onhover" => "shadow", "shade_color" => "#5959AB", "default_color" => ["#E4E4E4"], "map_code" => "world"
      },
      image_url: "https://s3-ap-southeast-1.amazonaws.com/charts.pykih.com/themes/pie-Dusk.png",
      created_by: nil,
      updated_by: nil
    }
    ])
    Core::Theme.set_callback(:create, :before, :before_create_set)
    Core::Theme.set_callback(:create, :after, :after_create_set)
  end

end