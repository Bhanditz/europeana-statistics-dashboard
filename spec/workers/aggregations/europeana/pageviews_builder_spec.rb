# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Aggregations::Europeana::PageviewsBuilder do
  let(:ga_pageviews_url) {"something"}
  let(:ga_visits_url) {"something"}
  let(:ga_clickthrough_url) {"something"}
  let(:ga_country_pageviews_url) {"something"}
  let(:ga_top_objects_url) {"something"}

  let(:all_objects_data) { [{ 'image_url' => 'image_url', 'title' => 'title', 'title_url' => 'title_url', 'size' => 'size', 'year' => 'year', 'month' => 'month' }] }
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
          expect(subject).to receive(:open).with(ga_pageviews_url) { 'pageviewsdata' }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', a_thing, 'pageviewsdata', 'pageviews', 'monthly')
          expect(subject).to receive(:open).with(ga_visits_url) { 'visistsdata' }
          expect(Core::TimeAggregation).to receive(:create_aggregations).with('visistsdata', 'monthly', whatever, 'Impl::Aggregation', 'visits', 'medium')
          expect(subject).to receive(:open).with(ga_clickthrough_url) { 'clickthroughdata' }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', a_thing, 'clickthroughdata', 'pageviews', 'monthly')
          expect(subject).to receive(:open).with(ga_countries_url) { 'countrypageviewsdata' }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', a_thing, 'countrypageviewsdata', 'pageviews', 'monthly')
          expect(Aggregations::Europeana::PageviewsBuilder).to receive(:fetch_data_for_all_items_between).with(dates) { all_objects_data }
          expect(Core::TimeAggregation).to receive(:create_time_aggregations).with('Impl::Output', a_thing, all_objects_data, 'pageviews', 'monthly')
          subject.perform
          expect(Impl::Aggregation.europeana.status).to eq('Fetched data successfully')
          expect(Impl::Aggregation.europeana.error_messages).to eq(nil)
        end
      end
      context 'when running monthly' do
        let(:expected_start_date) { (Date.today.at_beginning_of_month - 1).strftime('%Y-%m-%d') }
        before do
          Impl::Aggregation.europeana.update_attributes(last_updated_at: Date.today.at_beginning_of_month - 1)
        end
        it 'should get the pageviews, visits, click throughs, country pageviews and top digital objects,
          then create TimeAggregations for each,
          then asynchroneously perform a Aggregations::Europeana::PropertiesBuilder' do
          expect(subject).to receive(:open).with(ga_pageviews_url)
          subject.perform
          expect(Impl::Aggregation.europeana.status).to eq('Fetched data successfully')
          expect(Impl::Aggregation.europeana.error_messages).to eq(nil)
        end
      end

      context 'when running with a gap larger than a month' do
        let(:expected_start_date) { (Date.today.at_beginning_of_month - (3).month).strftime('%Y-%m-%d') }
        before do
          Impl::Aggregation.europeana.update_attributes(last_updated_at: Date.today.at_beginning_of_month - (3).month)
        end
        it 'should get the pageviews, visits, click throughs, country pageviews and top digital objects,
          then create TimeAggregations for each,
          then asynchroneously perform a Aggregations::Europeana::PropertiesBuilder' do
          expect(subject).to receive(:open).with(ga_pageviews_url)
          subject.perform
          expect(Impl::Aggregation.europeana.status).to eq('Fetched data successfully')
          expect(Impl::Aggregation.europeana.error_messages).to eq(nil)
        end
      end
    end

    context 'when there is an error' do
      it 'should set the status to failed and set the error' do
        expect(Impl::DataSet).to receive(:get_access_token).and_raise('An error on the dataset.')
        subject.perform
        expect(Impl::Aggregation.europeana.status).to eq('Failed Fetching pageviews')
        expect(Impl::Aggregation.europeana.error_messages).to eq('An error on the dataset.')
      end

    end
  end

  describe 'Aggregations::Europeana::PageviewsBuilder#fetch_data_for_all_items_between' do
    let(:expected_results) { all_quarter_data }
    it 'should get pageviews for digital objects from Google Analytics and details for them from the Europeana API' do


      expect(described_class.fetch_data_for_all_items_between).to eq(expected_results)
    end
  end
end