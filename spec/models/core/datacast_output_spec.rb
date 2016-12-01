# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Core::DatacastOutput, type: :model do

  it { should respond_to(:id) }
  it { should respond_to(:datacast_identifier) }
  it { should respond_to(:output) }
  it { should respond_to(:fingerprint) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }


  it 'should belong to a core_datacast' do
    expect(core_datacast_outputs(:rijksmuseum_providers_count_output).core_datacast).to eq(core_datacasts(:rijksmuseum_providers_count))
  end
end