#rake ref:load
require 'json/pure'
namespace :ref do

  task :load => :environment do  |t, args|
    puts "----> Migrations"

    Rake::Task['db:migrate'].invoke
  
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
      Core::Theme.create!({name: name, config: config,account_id: account_id, sort_order: sort_order, image_url: image_url})
    end
    header name,template,img,sort_order
    puts "----> Loading Core::CardLayout"
    CSV.read("ref/core_card_layouts.csv").each_with_index do |line, index|
      next if index == 0
      name = line[0]
      template = line[1]
      img = line[2]
      sort_order = line[3]
      Core::CardLayout.create!({name: name, template: template, img: img, sort_order: sort_order})
    end

    puts '----> Seeding Ref::CountryCode'
    Ref::CountryCode.seed
    puts "----> Done"
  end

  task :create_default_db_connection => :environment do |t, args|
    puts "----> Creating Default DB connection"
    name = "Default Database"
    db_name = Rails.env.production? ? "rumi" : "datastory"
    host = Rails.env.production? ? "10.64.147.66" : "localhost"
    port = "5432"
    adapter = "postgresql"
    username = Rails.env.production? ? "rumidbuser" : "developer"
    password = Rails.env.production? ? "eimGevheurovyur" : "developer"
    db_connection = Core::DbConnection.new({name: name, db_name: db_name, host: host, port: port,adapter: adapter, username: username, password: password})
    db_connection.save!
  end
end