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
    db_name = Rails.configuration.database_configuration[Rails.env]["database"]
    host = Rails.configuration.database_configuration[Rails.env]["host"]
    port = Rails.configuration.database_configuration[Rails.env]["port"] || 5432
    adapter = "postgresql"
    username = Rails.configuration.database_configuration[Rails.env]["username"]
    password = Rails.configuration.database_configuration[Rails.env]["password"]
    Core::DbConnection.create({name: name, db_name: db_name, host: host, port: port,adapter: adapter, username: username, password: password})
  end

  task :create_default_template => :environment do |t,args|
    Core::Template.delete_all
    puts "----> Creating Default Template for data providers"
    name = "Default Data Provider Template"
    genre = "data_providers"
    required_variables = {"required_variables" => ['$AGGREGATION_WIKIPEDIA_DESCRIPTION$','$COLLECTION_IN_EUROPEANA$','$MEDIA_TYPES_CHART$','$REUSABLES_CHART$','$TRAFFIC_CHART$','$LINE_CHART$','$TOP_COUNTRIES_MAP$','$TOP_DIGITAL_OBJECTS$']}
    html_content = File.open("ref/default_data_provider_template.txt").read.gsub(/\n(\s+|)/,' ')
    Core::Template.create_or_update(name,html_content,genre,required_variables)
    puts "----> Creating Default Template for providers"
    name = "Default Provider Template"
    genre = "providers"
    required_variables = {"required_variables" => ['$AGGREGATION_WIKIPEDIA_DESCRIPTION$','$COLLECTION_IN_EUROPEANA$','$MEDIA_TYPES_CHART$','$REUSABLES_CHART$','$TOP_COUNTRIES$','$TOP_DATA_PROVIDERS$','$TRAFFIC_CHART$','$LINE_CHART$','$TOP_COUNTRIES_MAP$','$TOP_DIGITAL_OBJECTS$']}
    html_content = File.open("ref/default_provider_template.txt").read.gsub(/\n(\s+|)/,' ')
    Core::Template.create_or_update(name,html_content,genre,required_variables)
    puts "----> Creating Default Template for countries"
    name = "Default Country Template"
    genre = "country"
    required_variables = {"required_variables" => ['$AGGREGATION_WIKIPEDIA_DESCRIPTION$','$COLLECTION_IN_EUROPEANA$','$MEDIA_TYPES_CHART$','$REUSABLES_CHART$','$TOP_PROVIDERS$','$TOP_DATA_PROVIDERS$','$TRAFFIC_CHART$','$LINE_CHART$','$TOP_COUNTRIES_MAP$','$TOP_DIGITAL_OBJECTS$']}
    html_content = File.open("ref/default_country_template.txt").read.gsub(/\n(\s+|)/,' ')
    Core::Template.create_or_update(name,html_content,genre,required_variables)

  end

  task :create_europeana_aggregation_report => :environment do |t,args|
    puts "----> Building Europeana Report"
    core_project_id = Core::Project.where(name: "Europeana").first.id
    name = "Europeana"
    genre = "europeana"
    wikiname = nil
    status = ""
    impl_aggregation = Impl::Aggregation.create({genre: genre, name: name, wikiname: wikiname, status: status, core_project_id: core_project_id })
    if impl_aggregation.id.present?
      Impl::DataProviders::CollectionsBuilder.perform_async(impl_aggregation.id)
      Impl::DataProviders::DatacastsBuilder.perform_at(1.minute.from_now, impl_aggregation.id)
    else
      puts impl_aggregation.error_messages
      puts "----> FAILED"
    end
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
    Rake::Task['ref:create_europeana_aggregation_report'].invoke
    Rake::Task['ref:seed_europeana_production_reports'].invoke
  end
end