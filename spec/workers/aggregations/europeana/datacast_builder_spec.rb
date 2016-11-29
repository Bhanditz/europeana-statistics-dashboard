# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Aggregations::Europeana::DatacastBuilder do
  it { is_expected.to be_kind_of( Sidekiq::Worker) }

  describe '#perform' do
    context 'when everything works' do
      let(:datacast_double) { double("dummy_datacast", identifier: "fake_id") }
      let(:project_id) { core_projects(:europeana_project).id }
      it 'should create or update, Total Pageviews, Top Digital Objects, Total Countries, Total Providers,
          Total Data Providers, Media Types, Reusables and Top Country Datacasts. Then queue the VizBuilder.'  do
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Line Chart') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Top Digital Objects') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Countries Count') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Providers Count') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Data Providers Count') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Media Type Donut Chart') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Reusables') { datacast_double }
        expect(Core::Datacast).to receive(:create_or_update_by).with(
            an_instance_of(String), project_id, 'Europeana - Top Countries') { datacast_double }
        expect(Impl::AggregationDatacast).to receive(:find_or_create).exactly(8).times
        expect(Aggregations::Europeana::VizBuilder).to receive(:perform_async)
        subject.perform
        expect(Impl::Aggregation.europeana.status).to eq('Created all datacasts')
        expect(Impl::Aggregation.europeana.error_messages).to eq(nil)
      end
    end

    context 'when there is an error' do
      it 'should log the error' do
        expect(Core::Datacast).to receive(:create_or_update_by).and_raise 'Error with retrieving datacast'
        expect(Impl::AggregationDatacast).to_not receive(:find_or_create)
        subject.perform
        expect(Impl::Aggregation.europeana.status).to eq('Failed to build datacast')
        expect(Impl::Aggregation.europeana.error_messages).to eq('Error with retrieving datacast')
      end
    end
  end
end