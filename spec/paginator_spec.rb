# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clever::Paginator do
  include_context 'api responses'

  let(:connection) { Clever::Connection.new(client) }
  let(:paginator) do
    Clever::Paginator.fetch(
      connection, Clever::SECTIONS_ENDPOINT,
      :get, Clever::Types::Section
    )
  end

  describe '#fetch' do
    before do
      connection.expects(:execute).with(Clever::SECTIONS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT).returns(page_1_response)
      connection.expects(:execute).with(page_2_uri, :get, limit: Clever::PAGE_LIMIT).returns(page_2_response)
      connection.expects(:execute).with(page_3_uri, :get, limit: Clever::PAGE_LIMIT).returns(page_3_response)
    end

    it 'makes paginated requests' do
      sections = paginator.force
      first_section  = sections[0]
      second_section = sections[1]
      third_section  = sections[2]

      expect(first_section.class).to eq(Clever::Types::Section)
      expect(first_section.uid).to eq(section_1['data']['id'])
      expect(first_section.name).to eq(section_1['data']['name'])
      expect(first_section.grades).to eq([section_1['data']['grade']])
      expect(first_section.period).to eq(section_1['data']['period'])
      expect(first_section.course).to eq(section_1['data']['course'])
      expect(first_section.teachers).to eq(section_1['data']['teachers'])
      expect(first_section.students).to eq(section_1['data']['students'])
      expect(first_section.provider).to eq('clever')

      expect(second_section.class).to eq(Clever::Types::Section)
      expect(second_section.uid).to eq(section_2['data']['id'])
      expect(second_section.name).to eq(section_2['data']['name'])
      expect(second_section.grades).to eq([section_2['data']['grade']])
      expect(second_section.period).to eq(section_2['data']['period'])
      expect(second_section.course).to eq(section_2['data']['course'])
      expect(second_section.teachers).to eq(section_2['data']['teachers'])
      expect(second_section.students).to eq(section_2['data']['students'])
      expect(second_section.provider).to eq('clever')

      expect(third_section.class).to eq(Clever::Types::Section)
      expect(third_section.uid).to eq(section_3['data']['id'])
      expect(third_section.name).to eq(section_3['data']['name'])
      expect(third_section.grades).to eq([section_3['data']['grade']])
      expect(third_section.period).to eq(section_3['data']['period'])
      expect(third_section.course).to eq(section_3['data']['course'])
      expect(third_section.teachers).to eq(section_3['data']['teachers'])
      expect(third_section.students).to eq(section_3['data']['students'])
      expect(third_section.provider).to eq('clever')
    end
  end
end
