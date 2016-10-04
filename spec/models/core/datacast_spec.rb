# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Core::Datacast, type: :model do
  context 'getting data distribution' do
    it 'returns data distribution of data' do
      data = [
        %w(col1 col2 col3 col4),
        ['first name', 'true', '12', '11-12-2015'],
        ['first name', 'true', '13', '31-12-2015'],
        ['first name', 'true', '14', '01-01-2016'],
        ['first name', 'true', '15', '11-01-2016'],
        ['first name', 'true', '16', '21-01-2016'],
        ['first name', 'true', '17', '31-01-2016']
      ]

      desired_distribution = {
        'col1' => { string: 6, boolean: 0, float: 0, integer: 0, date: 0, blank: 0 },
        'col2' => { string: 0, boolean: 6, float: 0, integer: 0, date: 0, blank: 0 },
        'col3' => { string: 0, boolean: 0, float: 0, integer: 6, date: 0, blank: 0 },
        'col4' => { string: 0, boolean: 0, float: 0, integer: 0, date: 6, blank: 0 }
      }

      distribution = Core::Datacast.get_data_distribution(data)
      expect(distribution).to eq(desired_distribution)
    end
  end

  context 'getting the datatype of data' do
    it 'should return float' do
      type = Core::Datacast.get_element_datatype('123.2312')
      expect(type).to eq('float')
    end

    it 'should return integer' do
      type = Core::Datacast.get_element_datatype('123')
      expect(type).to eq('integer')
    end

    it 'should return boolean' do
      type = Core::Datacast.get_element_datatype('y')
      expect(type).to eq('boolean')

      type = Core::Datacast.get_element_datatype('t')
      expect(type).to eq('boolean')

      type = Core::Datacast.get_element_datatype('f')
      expect(type).to eq('boolean')

      type = Core::Datacast.get_element_datatype('true')
      expect(type).to eq('boolean')

      type = Core::Datacast.get_element_datatype('no')
      expect(type).to eq('boolean')
    end

    it 'should return date' do
      type = Core::Datacast.get_element_datatype('01-01-2016')
      expect(type).to eq('date')
    end

    it 'should return blank' do
      type = Core::Datacast.get_element_datatype('')
      expect(type).to eq('blank')
    end

    it 'should return string' do
      type = Core::Datacast.get_element_datatype('sample')
      expect(type).to eq('string')
    end
  end

  context 'Core::Datacast#create_or_update_by' do
    it 'should return a new datacast' do
      previous_datacast = Core::Datacast.where(name: 'NEW_TEST_DATACAST', core_project_id: 1, core_db_connection_id: 1).first
      new_datacast = Core::Datacast.create_or_update_by(
        'SELECT * FROM generate_series(2,3);',
        1,
        1,
        'NEW_TEST_DATACAST'
      )
      expect(previous_datacast).to eq(nil)
      expect(new_datacast.id.class).to eq(Fixnum)
    end

    it 'should return the update the datacast object' do
      previous_datacast = Core::Datacast.create_or_update_by(
        'SELECT * FROM generate_series(2,3);',
        1,
        1,
        'NEW_TEST_DATACAST'
      )
      expect(previous_datacast.query).to eq('SELECT * FROM generate_series(2,3);')

      new_datacast = Core::Datacast.create_or_update_by(
        'SELECT * FROM generate_series(5,6);',
        1,
        1,
        'NEW_TEST_DATACAST'
      )

      expect(new_datacast.query).to eq('SELECT * FROM generate_series(5,6);')
      previous_datacast.delete
      new_datacast.delete
    end
  end
end
