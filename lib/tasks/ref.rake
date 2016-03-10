#rake ref:load
require 'json/pure'
namespace :ref do

  task :load => :environment do  |t, args|
    puts "----> Migrations"

    Rake::Task['db:migrate'].invoke
    Rake::Task['seed:users'].invoke

    puts '----> Creating Europeana Project'

    Core::Project.create({account_id: 1, name: "Europeana"})

    puts "----> Loading Ref::Chart"
    Ref::Chart.destroy_all
    #headers name,slug,description,img_small,img_data_mapping,api,sort_order,genre,combination_code,source,file_path,map
    CSV.read("ref/ref_chart.csv").each_with_index do |line, index|
      next if index == 0 #skipping header
      name             = line[0]
      slug             = line[1]
      description      = line[2]
      img_small        = line[3]
      img_data_mapping = line[4]
      api              = line[5]
      sort_order       = line[6]
      genre            = line[7]
      cc_code          = line[8] || SecureRandom.hex(3) #it produces a random hex code when no combination_code is present in the csv
      source           = line[9]
      file_path        = line[10]
      map              = JSON.parse(line[11]).to_json

      Ref::Chart.create!({
                name: name,
                slug: slug,
                description: description,
                img_small: img_small,
                img_data_mapping: img_data_mapping,
                api: api,
                sort_order: sort_order,
                genre: genre,
                combination_code: cc_code,
                source: source,
                file_path: file_path,
                map: map
              })
    end

    puts "----> Loading Core::Theme"
    Core::Theme.admin.destroy_all
    #header name,config,account_id,sort_order,image_url
    CSV.read("ref/theme.csv").each_with_index do |line,index|
      next if index == 0 #skipping header
      name           = line[0]
      config         = JSON.parse(line[1]).to_json
      account_id     = line[2]
      sort_order     = line[3]
      image_url      = line[4]
      Core::Theme.create({name: name, config: config,account_id: account_id, sort_order: sort_order, image_url: image_url})
    end
    puts '----> Loading Ref::CountryCode'
    Ref::CountryCode.seed
  end

  task :create_default_db_connection => :environment do |t, args|
    puts "----> Creating Default DB connection"
    name = "Default Database"
    db_name = ActiveRecord::Base.configurations[Rails.env]["database"]
    host = ActiveRecord::Base.configurations[Rails.env]["host"]
    port = ActiveRecord::Base.configurations[Rails.env]["port"] || 5432
    adapter = "postgresql"
    username = ActiveRecord::Base.configurations[Rails.env]["username"]
    password = ActiveRecord::Base.configurations[Rails.env]["password"]
    Core::DbConnection.create({name: name, db_name: db_name, host: host, port: port,adapter: adapter, username: username, password: password})
  end

  task :create_default_template => :environment do |t,args|
    puts "----> Creating Default Template for data providers"
    # name = "Default Data Provider Template"
    # genre = "data_providers"
    # required_variables = {"required_variables" => ["$DATA_PROVIDER_NAME$","$Total_PAGEVIEWS$","$TOP_DIGITAL_OBJECTS$","$MEDIA_TYPES_CHART$","$REUSABLES_CHART$","$TOP_COUNTRIES_TABLE$"]}
    # html_content = File.open("ref/default_data_provider_template.txt").read.gsub(/\n(\s+|)/,' ')
    # Core::Template.create_or_update(name,html_content,genre,required_variables)
    # puts "----> Creating Default Template for providers"
    # name = "Default Provider Template"
    # genre = "providers"
    # required_variables = {"required_variables" => ["$PROVIDER_NAME$","$Total_PAGEVIEWS$","$TOTAL_PROVIDERS_COUNT$","$TOP_DIGITAL_OBJECTS$","$MEDIA_TYPES_CHART$","$REUSABLES_CHART$","$TOP_COUNTRIES_TABLE$"]}
    # html_content = File.open("ref/default_provider_template.txt").read.gsub(/\n(\s+|)/,' ')
    # Core::Template.create_or_update(name,html_content,genre,required_variables)
    # puts "----> Creating Default Template for countries"
    # name = "Default Country Template"
    # genre = "country"
    # required_variables = {"required_variables" => ["$COUNTRY_NAME$","$Total_PAGEVIEWS$","$TOP_DIGITAL_OBJECTS$","$TOTAL_PROVIDERS_COUNT$","$MEDIA_TYPES_CHART$","$REUSABLES_CHART$","$TOP_COUNTRIES_TABLE$"]}
    # html_content = File.open("ref/default_country_template.txt").read.gsub(/\n(\s+|)/,' ')
    # Core::Template.create_or_update(name,html_content,genre,required_variables)
    # puts "----> Creating Default Template for Europeana"
    name = "Default Europeana Template"
    genre = "europeana"
    required_variables = {"required_variables" => ["main_chart","topcountries","total_items","open_for_reuse"]}
    html_content = File.open("ref/default_europeana_template.txt").read.gsub(/\n(\s+|)/,' ')
    Core::Template.create_or_update(name,html_content,genre,required_variables)
  end

  task :create_or_update_europeana_aggregation_report => :environment do |t,args|
    puts "----> Building Europeana"
    core_project_id = Core::Project.where(name: "Europeana").first.id
    name = "Europeana"
    genre = "europeana"
    status = ""
    impl_aggregation = Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)
    Aggregations::Europeana::PageviewsBuilder.perform_async
  end

  task :seed_europeana_production_reports => :environment do |t,args|
    puts "----> Seeding Production Report"
    CSV.read("ref/reports_backup.csv").each_with_index do |line, index|
      next if index == 0
      name = line[0]
      html_content = line[1]
      Impl::Report.create({name: name, html_content: html_content, variable_object: {}, is_autogenerated: false})
    end
  end

  task :seed => :environment do |t,args|
    Rake::Task['ref:load'].invoke
    Rake::Task['ref:create_default_db_connection'].invoke
    Rake::Task['ref:create_default_template'].invoke
    Rake::Task['ref:create_or_update_europeana_aggregation_report'].invoke
    Rake::Task['ref:seed_europeana_production_reports'].invoke
  end
end
