# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require 'csv'

def load_csv_seeds csv_file
  namespace = Pathname.new(csv_file).parent.to_s.split('/').last
  filename  = File.join(namespace,File.basename(csv_file,".*"))
  csv_text = File.read(csv_file)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    ("#{filename.camelize.singularize}".constantize).create!(row.to_hash)
  end
end


# THE ORDER OF THE FOLLOWING TASKS IS IMPORTANT

puts '----> Creating users'
accounts = [['europeana_user@europeana.eu', 'europeana_user']]
accounts.each do |a|
  c = Account.new(email: a[0], username: a[1], password: 'Europeana123!@#', confirmation_sent_at: Time.now)
  c.save
end

puts '----> Creating Europeana Project'

Core::Project.create(account_id: 1, name: 'Europeana')

puts '----> Loading Ref::Chart'
Ref::Chart.destroy_all
# headers name,slug,description,img_small,img_data_mapping,api,sort_order,genre,combination_code,source,file_path,map
CSV.read(Dir[File.join(Rails.root, 'db', 'seeds', 'ref','chart.csv')].first).each_with_index do |line, index|
  next if index == 0 # skipping header
  name             = line[0]
  slug             = line[1]
  description      = line[2]
  img_small        = line[3]
  img_data_mapping = line[4]
  api              = line[5]
  sort_order       = line[6]
  genre            = line[7]
  cc_code          = line[8] || SecureRandom.hex(3) # it produces a random hex code when no combination_code is present in the csv
  source           = line[9]
  file_path        = line[10]
  map              = line[11]

  Ref::Chart.create!(name: name,
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
                     map: map)
end

puts '----> Loading Core::Theme'
Core::Theme.admin.destroy_all
# header name,config,account_id,sort_order,image_url
CSV.read(Dir[File.join(Rails.root, 'db', 'seeds', 'core','themes.csv')].first).each_with_index do |line, index|
  next if index == 0 # skipping header
  name           = line[0]
  config         = line[1]
  account_id     = line[2]
  sort_order     = line[3]
  image_url      = line[4]
  Core::Theme.create(name: name, config: config, account_id: account_id, sort_order: sort_order, image_url: image_url)
end


puts '----> Loading Ref::CountryCode'
CSV.read(Dir[File.join(Rails.root, 'db', 'seeds', 'ref','country_code.csv')].first).each do |line|
  code = line[0]
  country = line[1]
  Ref::CountryCode.find_or_create(code, country)
end

puts '----> Loading Impl::BlacklistDatasets'
Impl::BlacklistDataset.destroy_all
# headers name,slug,description,img_small,img_data_mapping,api,sort_order,genre,combination_code,source,file_path,map
CSV.read(Dir[File.join(Rails.root, 'db', 'seeds', 'impl','blacklist_datasets.csv')].first).each_with_index do |line, index|
  next if index == 0 # skipping header
  dataset = line[0]
  Impl::BlacklistDataset.create!(dataset: dataset)
end

puts '----> Creating Default Template for data providers'
name = 'Default Europeana Template'
genre = 'europeana'
required_variables = { 'required_variables' => %w(main_chart topcountries total_items open_for_reuse) }
html_content = ' '
Core::Template.create_or_update(name, html_content, genre, required_variables)


puts '----> Building Europeana'
core_project_id = Core::Project.where(name: 'Europeana').first.id
name = 'Europeana'
genre = 'europeana'
Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)


puts '----> Seeding Production Reports'
CSV.read(Dir[File.join(Rails.root, 'db', 'seeds', 'impl','reports_backup.csv')].first).each_with_index do |line, index|
  next if index == 0
  name = line[0]
  slug = name.downcase.gsub(" ", "-")
  html_content = line[1]
  Impl::Report.create(name: name, html_content: html_content, slug: slug, variable_object: {}, is_autogenerated: false)
end

#load_csv_seeds(Dir[File.join(Rails.root, 'db', 'seeds', 'impl','aggregations.csv')].first)
#load_csv_seeds(Dir[File.join(Rails.root, 'db', 'seeds', 'impl','reports.csv')].first)

# Seeds are split into multiple files in the directory db/seeds, run in order
# of their filename.
#puts"loading: datacasts.csv";
#load_csv_seedse(Dir[File.join(Rails.root, 'db', 'seeds', 'core','datacasts.csv')].first)
#puts"loading: datacast_outputs.csv";
#load_csv_seeds(Dir[File.join(Rails.root, 'db', 'seeds', 'core','datacast_outputs.csv')].first)
#puts"loading: time_aggregations.csv";
#load_csv_seeds(Dir[File.join(Rails.root, 'db', 'seeds', 'core','time_aggregations.csv')].first)
#Dir[File.join(Rails.root, 'db', 'seeds', 'impl','*.csv')].sort.each { |csv_seeds| puts"loading: #{csv_seeds}";load_csv_seeds csv_seeds }
