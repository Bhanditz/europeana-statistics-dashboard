#rake ref:load
require 'json/pure'
namespace :ref do

  task :load => :environment do  |t, args|
    puts "----> Migrations"
  
    Rake::Task['db:migrate'].invoke
  
    puts "----> Loading Ref::Chart"
    Ref::Chart.destroy_all
    #headers-> name,slug,description,img_small,img_data_mapping,api,sort_order,genre,combination_code,source,file_path,map
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
    
    puts "----> Loading Ref::Plan"
    Ref::Plan.destroy_all
    #header name,slug,can_private_public,can_configuration_edit,can_host_custom_dashboard,can_publish_data_store,can_visualize_data,can_publish_visualizations,can_remove_branding,storage_space,price_per_month,description,sort_order,target_customer,genre,can_use_apis
    CSV.read("ref/ref_plan.csv").each_with_index do |line, index|
      next if index == 0 #skipping header
      name                       = line[0]
      slug                       = line[1]
      can_private_public         = line[2]
      can_configuration_edit     = line[3]
      can_host_custom_dashboard  = line[4]
      can_publish_data_store     = line[5]
      can_visualize_data         = line[6]
      can_publish_visualizations = line[7]
      can_remove_branding        = line[8]
      storage_space              = line[9]
      price_per_month            = line[10]
      description                = line[11]
      sort_order                 = line[12]
      target_customer            = line[13]
      genre                      = line[14]
      can_use_apis               = line[15]

      Ref::Plan.create!({name: name,
                        slug: slug,
                        can_private_public: can_private_public,
                        can_configuration_edit: can_configuration_edit,
                        can_host_custom_dashboard: can_host_custom_dashboard,
                        can_publish_data_store: can_publish_data_store,
                        can_visualize_data: can_visualize_data,
                        can_publish_visualizations: can_publish_visualizations,
                        can_remove_branding: can_remove_branding,
                        storage_space: storage_space,
                        price_per_month: price_per_month,
                        description: description,
                        sort_order: sort_order,
                        target_customer: target_customer,
                        genre: genre,
                        can_use_apis: can_use_apis
                      })
    end

    Core::Project.where("ref_plan_slug IN (?)",["enterprise","picasso_enterprise"]).each do |core_project|
      core_project.update_attributes({ref_plan_slug: "_enterprise_picasso" })
    end

    puts "----> Done"
  end

  task :delete_all_viz => :environment do  |t, args|
    puts "----> Destroying All Viz"
    Core::Viz.all.each do |viz|
      viz.destroy
    end
    puts "----> Done"
  end
end