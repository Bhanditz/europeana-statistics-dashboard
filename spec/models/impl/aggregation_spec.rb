# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Impl::Aggregation, type: :model do
  before :each do
    @aggregation = Impl::Aggregation.first
  end

  context '#get_static_query' do
    it 'should return a static query for a given Impl::Agregation object' do
      today = Date.today
      query = "Select name, value as weight from core_time_aggregations INNER JOIN (Select id as impl_output_id, value as name from impl_outputs where impl_parent_id = 1 and genre = 'top_media_types') as io on parent_id = impl_output_id and parent_type = 'Impl::Output' where aggregation_level_value = '#{today.year}_#{Date::MONTHNAMES[today.month]}'"
      expect(@aggregation.get_static_query('media_type')).to eq(query)
    end
  end

  context '#get_digital_objects_query' do
    it 'should retrun the static query for digital_objects' do
      year = Date.today.year
      query = "Select year,month, value,image_url,title_url,title  from (Select split_part(ta.aggregation_level_value,'_',1) as year, split_part(ta.aggregation_level_value, '_',2) as month, sum(ta.value) as value,ta.aggregation_index, output_properties -> 'image_url' as image_url, output_properties -> 'title_url' as title_url, output_value as title, ROW_NUMBER() OVER (PARTITION BY  split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2) order by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), sum(value) desc) AS row  from core_time_aggregations ta, (Select o.id as output_id, o.key as output_key, o.value as output_value, o.properties as output_properties from impl_outputs o where o.impl_parent_id = 1 and genre='top_digital_objects') as b where ta.parent_id = b.output_id group by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), ta.aggregation_value_to_display, ta.metric,ta.aggregation_index, output_properties -> 'image_url', output_properties -> 'title_url', output_value order by split_part(ta.aggregation_level_value,'_',1), split_part(ta.aggregation_level_value, '_',2), value desc) as final_output where row < 25 and year::integer in (#{(2014..year).to_a.join(',')});"
      expect(@aggregation.get_digital_objects_query).to eq(query)
    end
  end

  context '#get_countries_query' do
    it 'should return static query for the year' do
      year = Date.today.year
      query = "Select sum(ta.value) as size, b.code as iso2, 'Pageviews' as tooltip_column_name from core_time_aggregations as ta, (Select o.id as output_id, value, code from impl_outputs o,ref_country_codes as code where o.impl_parent_id = 1 and o.genre='top_countries' and o.value = code.country) as b where ta.parent_id = b.output_id and split_part(ta.aggregation_level_value,'_',1)='#{year}' group by b.code order by size desc limit 10"
      expect(@aggregation.get_countries_query).to eq(query)
    end
  end

  context '#get_pageviews_line_chart_query' do
    it 'should return a query that feeds the line chart' do
      year = Date.today.year
      month = Date::MONTHNAMES[Date.today.month]
      query = "Select name, x,y from (Select split_part(ta.aggregation_level_value,'_',1) as year,split_part(ta.aggregation_level_value,'_',1) as name,aggregation_value_to_display as x,sum(ta.value) as y  from core_time_aggregations ta join (Select o.id as output_id from impl_outputs o where impl_parent_id = 1  and genre='pageviews') as b  on parent_type='Impl::Output' and parent_id = output_id group by ta.aggregation_level_value,aggregation_value_to_display order by split_part(ta.aggregation_level_value,'_',1),to_date(aggregation_value_to_display,'Month')) as final_output where (year::integer < #{year} or x <> '#{month}') and year::integer > 2012;"
      expect(@aggregation.get_pageviews_line_chart_query).to eq(query)
    end
  end

  context '#get_aggregated_filters' do
    it 'should return aggregation Google Analytics filters for europeana' do
      filters = 'ga:hostname=~europeana.eu;ga:pagePath=~/91956/'
      aggregation = Impl::Aggregation.first
      expect(aggregation.get_aggregated_filters).to eq(filters)
    end
  end

  context '#europeana?' do
    it 'should return true if aggregation report is of europeana' do
      europeana_aggregation = Impl::Aggregation.where(genre: 'europeana').first
      not_europeana_aggregation = Impl::Aggregation.where.not(genre: 'europeana').first

      expect(europeana_aggregation.europeana?).to eq(true)
      expect(not_europeana_aggregation.europeana?).to eq(false)
    end
  end

  context '#blacklist_data_set?' do
    it 'should return if the aggregation record is blacklisted or not.' do
      blacklisted_dataset = Impl::Aggregation.first
      expect(blacklisted_dataset.blacklist_data_set?).to eq(false)
    end
  end

  context '#create_or_find_aggregation' do
    it 'should create a new Impl::Aggregation record in the database' do
      name = 'spain'
      genre = 'country'
      core_project_id = -1

      impl_aggreagtion = Impl::Aggregation.where(name: name, genre: genre, core_project_id: core_project_id).first
      expect(impl_aggreagtion.present?).to eq(false)

      impl_aggreagtion = Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)

      expect(impl_aggreagtion.present?).to eq(true)
      impl_aggreagtion.delete
    end

    it 'should return a Impl::Aggregation record from the database' do
      name = 'spain'
      genre = 'country'
      core_project_id = -1

      impl_aggreagtion = Impl::Aggregation.where(name: name, genre: genre, core_project_id: core_project_id).first
      expect(impl_aggreagtion.present?).to eq(false)

      impl_aggreagtion = Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)
      id = impl_aggreagtion.id
      expect(impl_aggreagtion.present?).to eq(true)

      impl_aggreagtion = Impl::Aggregation.create_or_find_aggregation(name, genre, core_project_id)
      expect(impl_aggreagtion.id).to eq(id)

      impl_aggreagtion.delete
    end
  end

  context '#fetch_GA_data_between' do
    it 'should fetch Google Analytics data between the given dates' do
      start_date = '2016-03-01'
      end_date = '2016-03-02'
      ga_data = [
        { 'month' => '03', 'year' => '2016', 'country' => 'Spain', 'pageviews' => 18_039 },
        { 'month' => '03', 'year' => '2016', 'country' => 'Netherlands', 'pageviews' => 15_188 },
        { 'month' => '03', 'year' => '2016', 'country' => 'Germany', 'pageviews' => 7745 }
      ]
      query_data = Impl::Aggregation.fetch_GA_data_between(start_date, end_date, nil, 'country', 'pageviews')
      expect([query_data.first, query_data.second, query_data.third]).to eq(ga_data)
    end
  end

  context '#get_ga_data' do
    it 'should return Google Analytics data for given metric an dimension sorted by given order' do
      data_provider = Impl::Aggregation.fourth
      start_date = '2016-03-01'
      end_date = '2016-03-02'
      metrics = 'ga:pageviews'
      dimensions = 'ga:month,ga:year'
      filters = "#{data_provider.get_aggregated_filters};ga:pagePath=~/portal/record/"
      sort = 'ga:year,ga:month'
      ga_data = [%w(03 2016 0)]

      query_data = Impl::Aggregation.get_ga_data(start_date, end_date, metrics, dimensions, filters, sort)
      expect(query_data).to eq(ga_data)
    end
  end

  context '#get_data_providers_json' do
    it 'should return the data providers data as json' do
      data = { 'url' => 'http://localhost:3000/dataprovider/content-2014', 'text' => "Diputació de Barcelona" }

      expected_data = Impl::Aggregation.get_data_providers_json.first
      expect(expected_data['url']).to eq(data['url'])
      expect(expected_data['text']).to eq(data['text'])
    end
  end

  context '#get_providers_json' do
    it 'should return the providers data as json' do
      data = { 'url' => 'http://localhost:3000/provider/content-2013', 'text' => 'LoCloud' }

      expected_data = Impl::Aggregation.get_providers_json.first
      expect(expected_data['url']).to eq(data['url'])
      expect(expected_data['text']).to eq(data['text'])
    end
  end

  context '#get_countries_json' do
    it 'should return the countries data as json' do
      data = { 'url' => 'http://localhost:3000/country/traffic-usage-2014', 'text' => 'France' }

      expected_data = Impl::Aggregation.get_countries_json.first
      expect(expected_data['url']).to eq(data['url'])
      expect(expected_data['text']).to eq(data['text'])
    end
  end

  context '#get_data_providers_count_query' do
    it 'should return a query that get data_provider count' do
      query =  "Select count(*) as value, '' as key, '' as content, 'Total Institutions' as title, '' as diff_in_value from impl_aggregation_relations where impl_parent_genre='provider' and impl_child_genre='data_provider' and impl_parent_id = '1'"
      expect(@aggregation.get_data_providers_count_query).to eq(query)
    end
  end

  context '#get_aggregations_count_query' do
    it 'should return a empty string if genre not specified ' do
      query = ''
      aggregation = Impl::Aggregation.where.not(genre: 'europeana').first
      expect(aggregation.get_aggregations_count_query('provider')).to eq(query)
    end

    it 'should return a empty string if genre not specified ' do
      today = Date.today
      query = "Select cta.value, '' as key, '' as content, 'Total Europeanas' as title, '' as diff_in_value,io.genre  from impl_outputs io INNER JOIN  core_time_aggregations cta on parent_id = io.id and parent_type = 'Impl::Output' and io.impl_parent_id = 1 and genre = 'top_europeana_counts' and split_part(aggregation_level_value,'_',1) = '#{today.year}' and split_part(aggregation_level_value,'_',2) = '#{Date::MONTHNAMES[today.month]}'"
      expect(@aggregation.get_aggregations_count_query('europeana')).to eq(query)
    end
  end
end
