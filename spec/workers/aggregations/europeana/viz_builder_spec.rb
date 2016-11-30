# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Aggregations::Europeana::VizBuilder do
  it { is_expected.to be_kind_of( Sidekiq::Worker) }
  describe '#perform' do
    let(:core_project_id) { core_projects(:europeana_project).id }
    let(:top_objects_datacast_double) { double('datacast_double',
                                               name: 'Europeana - Top Digital Objects',
                                               identifier: 1,
                                               core_project_id: core_project_id
    ) }
    let(:line_chart_datacast_double) { double('datacast_double',
                                              name: 'Europeana - Line Chart',
                                              identifier: 2,
                                              core_project_id: core_project_id
    ) }
    let(:europeana_datacasts) { [top_objects_datacast_double, line_chart_datacast_double] }

    before do
      europeana_aggregation = Impl::Aggregation.europeana
      allow(europeana_aggregation).to receive(:core_datacasts) { europeana_datacasts }
      allow(Impl::Aggregation).to receive(:europeana) { europeana_aggregation }
    end
    context 'when things work' do

      it 'should create Core::Vizs for each core_datacast' do
#=begin
        expect(Core::Viz).to receive(:find_or_create).with(2,
                                                           'Europeana - Line Chart',
                                                           ref_charts(:multi_series_line).combination_code,
                                                           core_project_id,
                                                           false,
                                                           nil,
                                                           nil,
                                                           false,
                                                           true
        )
#=end
        #expect(Core::Viz).to receive(:find_or_create).exactly(1).times {true}
        expect(Aggregations::Europeana::ReportBuilder).to receive(:perform_async)
        subject.perform

      end

    end

    context 'when things do not work' do
      it 'should set the status to failed to build Vizs and set the error message' do
        expect(Core::Viz).to receive(:find_or_create).and_raise ('Error creating Vizs')
        expect(Impl::DataProviders::ReportBuilder).to_not receive(:perform_async)
        subject.perform
        expect(Impl::Aggregation.europeana.status).to eq('Failed to build Vizs')
        expect(Impl::Aggregation.europeana.error_messages).to eq('Error creating Vizs')
      end
    end
  end

  describe '#get_filters' do
    context 'when the genre is in the non-present list' do
      %w(reusables providers_count countries_count data_providers_count top_countries media_type_donut_chart line_chart).each do |genre|
        it 'should return false for filter_present' do
          expect(described_class.get_filters(genre)).to eq([false, nil, nil])
        end
      end
    end
    context 'when the genre is something else' do
      it 'should return true for filter_present' do
        expect(described_class.get_filters('something_else')).to eq([true, nil, nil])
      end
    end
  end

  describe '#get_ref_chart' do
    it 'should lookup the ref_chart by the slug' do
      expect(described_class.get_ref_chart('line_chart')).to eq(ref_charts(:multi_series_line))
    end
  end
end