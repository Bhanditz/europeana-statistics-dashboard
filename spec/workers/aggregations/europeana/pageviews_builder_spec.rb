# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Aggregations::Europeana::PageviewsBuilder do
  let(:ga_base_url) { "#{GA_ENDPOINT}?access_token=fake_token&start-date=#{expected_start_date}&end-date=#{expected_end_date}&ids=ga:#{GA_IDS}" }
  let(:expected_end_date) { (Date.today.at_beginning_of_month - 1).strftime('%Y-%m-%d')  }
  let(:ga_pageviews_url) { "#{ga_base_url}&metrics=ga:pageviews&dimensions=ga:month,ga:year&filters=ga:hostname=~europeana.eu;ga:pagePath=~/portal/(../)?record/" }
  let(:ga_visits_url) {"#{ga_base_url}&metrics=ga:visits&dimensions=ga:month,ga:year,ga:medium&filters=ga:hostname=~europeana.eu"}
  let(:ga_clickthrough_url) {"#{ga_base_url}&metrics=ga:totalEvents&dimensions=ga:year&filters=ga:hostname=~europeana.eu;ga:pagePath=~/portal/(../)?record/;ga:eventCategory==Europeana Redirect,ga:eventCategory==Redirect" }
  let(:ga_top_objects_url) {"#{ga_base_url}&metrics=ga:pageviews&dimensions=ga:pagePath,ga:month,ga:year&filters=ga:hostname=~europeana.eu;ga:pagePath=~/portal/(../)?record/&sort=-ga:pageviews&max-results=50"}

  let(:all_objects_data) { [
      { 'image_url' => 'image_url', 'title' => 'title', 'title_url' => 'http://www.europeana.eu/portal/record/provider_id/item_id.html', 'size' => 55984, 'year' => '2015', 'month' => '10' },
      { 'image_url' => 'image_url', 'title' => 'title', 'title_url' => 'http://www.europeana.eu/portal/record/provider_id/item_id.html', 'size' => 13279, 'year' => '2013', 'month' => '10' },
      { 'image_url' => 'image_url', 'title' => 'title', 'title_url' => 'http://www.europeana.eu/portal/record/provider_id/item_id.html', 'size' => 663, 'year' => '2016', 'month' => '11' },
      { 'image_url' => 'image_url', 'title' => 'title', 'title_url' => 'http://www.europeana.eu/portal/record/provider_id/item_id.html', 'size' => 532, 'year' => '2016', 'month' => '11' }
  ] }
  let(:page_views_data) { { 'rows' => [['1', '2014', 20]] } }
  let(:visits_data) { { 'rows' => [['1', '2014', 'medium',15]] } }
  let(:clickthrough_data) { { 'rows' => [['1', '2014', 'medium',15]] } }
  let(:country_pageviews_data) { [['1', '2014', 'medium',15]] }
  before  do
    allow(Impl::DataSet).to receive(:get_access_token) { 'fake_token' }
  end
  it { is_expected.to be_kind_of( Sidekiq::Worker) }
  describe '#perform' do
    context 'when things work' do
      context 'when running for the first time' do
        let(:expected_start_date) { '2013-01-01' }
        before do
          Impl::Aggregation.europeana.update_attributes(last_updated_at: nil)
        end
        it 'should get the pageviews, visits, click throughs, country pageviews and top digital objects,
          then create TimeAggregations for each,
          then asynchroneously perform a Aggregations::Europeana::PropertiesBuilder' do
          expect(described_class).to receive(:parsed_json_for).with(ga_pageviews_url) { page_views_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', kind_of(Numeric), [{'month'=>'1', 'year'=>'2014', 'pageviews'=>20}], 'pageviews', 'monthly')
          expect(described_class).to receive(:parsed_json_for).with(ga_visits_url) { visits_data }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with([{'month'=>'1', 'year'=>'2014', 'medium'=>'medium', 'visits'=>15}], 'monthly',kind_of(Numeric), 'Impl::Aggregation', 'visits', 'medium')
          expect(described_class).to receive(:parsed_json_for).with(ga_clickthrough_url) { clickthrough_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', kind_of(Numeric), [{'year'=>'1', 'clickThrough'=>2014}], 'clickThrough', 'yearly')
          expect(Impl::Aggregation).to receive(:fetch_GA_data_between).with(expected_start_date, expected_end_date, nil, 'country', 'pageviews') { country_pageviews_data }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with(country_pageviews_data, 'monthly',kind_of(Numeric), 'Impl::Aggregation', 'pageviews', 'country')
          expect(Aggregations::Europeana::PageviewsBuilder).to receive(:fetch_data_for_all_items_between).with(expected_start_date, expected_end_date) { all_objects_data }
          expect(Core::TimeAggregation).to receive(:create_digital_objects_aggregation).with(all_objects_data, 'monthly', kind_of(Numeric))
          subject.perform
          expect(Impl::Aggregation.europeana.error_messages).to be_nil
          expect(Impl::Aggregation.europeana.status).to eq('Fetched data successfully')
        end
      end
      context 'when running monthly' do
        let(:expected_start_date) { (Date.today.at_beginning_of_month - (1).month).strftime('%Y-%m-%d') }
        before do
          Impl::Aggregation.europeana.update_attributes(last_updated_at: Date.today.at_beginning_of_month - (1).month - 1)
        end
        it 'should get the pageviews, visits, click throughs, country pageviews and top digital objects,
          then create TimeAggregations for each,
          then asynchroneously perform a Aggregations::Europeana::PropertiesBuilder' do
          expect(described_class).to receive(:parsed_json_for).with(ga_pageviews_url) { page_views_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', kind_of(Numeric), [{'month'=>'1', 'year'=>'2014', 'pageviews'=>20}], 'pageviews', 'monthly')
          expect(described_class).to receive(:parsed_json_for).with(ga_visits_url) { visits_data }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with([{'month'=>'1', 'year'=>'2014', 'medium'=>'medium', 'visits'=>15}], 'monthly',kind_of(Numeric), 'Impl::Aggregation', 'visits', 'medium')
          expect(described_class).to receive(:parsed_json_for).with(ga_clickthrough_url) { clickthrough_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', kind_of(Numeric), [{'year'=>'1', 'clickThrough'=>2014}], 'clickThrough', 'yearly')
          expect(Impl::Aggregation).to receive(:fetch_GA_data_between).with(expected_start_date, expected_end_date, nil, 'country', 'pageviews') { country_pageviews_data }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with(country_pageviews_data, 'monthly',kind_of(Numeric), 'Impl::Aggregation', 'pageviews', 'country')
          expect(Aggregations::Europeana::PageviewsBuilder).to receive(:fetch_data_for_all_items_between).with(expected_start_date, expected_end_date) { all_objects_data }
          expect(Core::TimeAggregation).to receive(:create_digital_objects_aggregation).with(all_objects_data, 'monthly', kind_of(Numeric))
          subject.perform
          expect(Impl::Aggregation.europeana.error_messages).to be_nil
          expect(Impl::Aggregation.europeana.status).to eq('Fetched data successfully')
        end
      end

      context 'when running with a gap larger than a month' do
        let(:expected_start_date) { (Date.today.at_beginning_of_month - (3).month).strftime('%Y-%m-%d') }
        before do
          Impl::Aggregation.europeana.update_attributes(last_updated_at: Date.today.at_beginning_of_month - (3).month - 1)
        end
        it 'should get the pageviews, visits, click throughs, country pageviews and top digital objects,
          then create TimeAggregations for each,
          then asynchroneously perform a Aggregations::Europeana::PropertiesBuilder' do
          expect(described_class).to receive(:parsed_json_for).with(ga_pageviews_url) { page_views_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', kind_of(Numeric), [{'month'=>'1', 'year'=>'2014', 'pageviews'=>20}], 'pageviews', 'monthly')
          expect(described_class).to receive(:parsed_json_for).with(ga_visits_url) { visits_data }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with([{'month'=>'1', 'year'=>'2014', 'medium'=>'medium', 'visits'=>15}], 'monthly',kind_of(Numeric), 'Impl::Aggregation', 'visits', 'medium')
          expect(described_class).to receive(:parsed_json_for).with(ga_clickthrough_url) { clickthrough_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', kind_of(Numeric), [{'year'=>'1', 'clickThrough'=>2014}], 'clickThrough', 'yearly')
          expect(Impl::Aggregation).to receive(:fetch_GA_data_between).with(expected_start_date, expected_end_date, nil, 'country', 'pageviews') { country_pageviews_data }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with(country_pageviews_data, 'monthly',kind_of(Numeric), 'Impl::Aggregation', 'pageviews', 'country')
          expect(Aggregations::Europeana::PageviewsBuilder).to receive(:fetch_data_for_all_items_between).with(expected_start_date, expected_end_date) { all_objects_data }
          expect(Core::TimeAggregation).to receive(:create_digital_objects_aggregation).with(all_objects_data, 'monthly', kind_of(Numeric))
          subject.perform
          expect(Impl::Aggregation.europeana.error_messages).to be_nil
          expect(Impl::Aggregation.europeana.status).to eq('Fetched data successfully')
        end
      end
    end

    context 'when there is an error' do
      it 'should set the status to failed and set the error' do
        expect(described_class).to receive(:parsed_json_for).and_raise('An error Parsing the json.')
        subject.perform
        expect(Impl::Aggregation.europeana.status).to eq('Failed Fetching pageviews')
        expect(Impl::Aggregation.europeana.error_messages).to eq('An error Parsing the json.')
      end

    end
  end

  let(:all_objects_response) {
    { 'rows' => [
        ["/portal/record/09003/745EB6AEE653A9218911BB5902EC3F832BC43E87.html", "10", "2015", "55984"],
        ["/portal/record/9200105/wellcomeimages_org_record_L0024849.html?start=1&query=title:Plastic+Surgery&startPage=1&rows=24", "10", "2013", "13279"],
        ["/portal/it/record/2023701/ANS68ccd66e6d1211e1ae16bc305bd461d9.html", "11", "2016", "663"],
        ["/portal/pl/record/92002/BibliographicResource_1000093325497_source.html?q=Codex+Gigas", "11", "2016", "532"]
    ] }
  }
  let(:europeana_response) {
    { 'success' => true,
      'object' => { 'proxies' => [{ 'dcTitle' => { "def": [ 'title'] } }],
                    'europeanaAggregation' => {
                        'edmPreview' => 'image_url',
                        'about' => '/aggregation/europeana/provider_id/item_id'
                    }
      }
    }
  }

  describe 'Aggregations::Europeana::PageviewsBuilder#fetch_data_for_all_items_between' do
    # this function should actually ensure it gets the top 50 items for each month in the selected period
    # at the moment however it only gets the top 50 items for the selected period overall.
    # TODO: investigate if it's possible to get the top 50 for each month in one request!

    let(:expected_result) { all_objects_data_one_month}
    context 'when getting all data since the beggining' do
      let(:expected_start_date) { '2013-01-01' }
      let(:expected_results) { all_objects_data }
      it 'should get pageviews for digital objects from Google Analytics and details for them from the Europeana API' do
        expect(described_class).to receive(:parsed_json_for).with(ga_top_objects_url) { all_objects_response }
        expect(described_class).to receive(:parsed_json_for).with("#{ENV['EUROPEANA_API_URL']}/record/09003/745EB6AEE653A9218911BB5902EC3F832BC43E87.json?wskey=#{ENV['WSKEY']}&profile=full") { europeana_response }
        expect(described_class).to receive(:parsed_json_for).with("#{ENV['EUROPEANA_API_URL']}/record/9200105/wellcomeimages_org_record_L0024849.json?wskey=#{ENV['WSKEY']}&profile=full") { europeana_response }
        expect(described_class).to receive(:parsed_json_for).with("#{ENV['EUROPEANA_API_URL']}/record/2023701/ANS68ccd66e6d1211e1ae16bc305bd461d9.json?wskey=#{ENV['WSKEY']}&profile=full") { europeana_response }
        expect(described_class).to receive(:parsed_json_for).with("#{ENV['EUROPEANA_API_URL']}/record/92002/BibliographicResource_1000093325497_source.json?wskey=#{ENV['WSKEY']}&profile=full") { europeana_response }
        expect(described_class.fetch_data_for_all_items_between(expected_start_date, expected_end_date)).to eq(expected_results)
      end
    end

    ## See the todo above ^
    #
    # context 'when getting all objects for the last month' do
    #   let(:expected_start_date)  { (Date.today.at_beginning_of_month - (1).month - 1).strftime('%Y-%m-%d') }
    #   let(:end_date) { expected_end_date }
    # end

  end

  describe 'Aggregations::Europeana::PageviewsBuilder#parsed_json_for' do
    let(:dummy_response) { double('uri_response', read: 'stream') }
    it 'should open the url and call JSON.parse on it.'do
      expect(described_class).to receive(:open).with('url_param', {:ssl_verify_mode=>0} ) { dummy_response }
      expect(JSON).to receive(:parse).with('stream') { ['parsed' => 'object'] }
      expect(described_class.parsed_json_for('url_param')).to eq ['parsed' => 'object']
    end

  end
end