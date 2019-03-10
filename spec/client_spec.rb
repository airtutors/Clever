# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clever::Client do
  let(:vendor_key) { 'vendor_key' }
  let(:vendor_secret) { 'vendor_secret' }
  let(:client) do
    Clever::Client.configure do |config|
      config.app_id        = app_id
      config.vendor_key    = vendor_key
      config.vendor_secret = vendor_secret
    end
  end
  let(:app_token) { '0ed35a0de3005aa1c77df310ac0375a6158881c4' }
  let(:app_id) { '5800e1c5e16c4230146fce0' }
  let(:status) { 200 }
  let(:tokens_body) do
    {
      'data' => [{
        'id' => '58939ac0a206f40316fe8a1c',
        'created' => '2017-02-02T20:46:56.435Z',
        'owner' => { 'type' => 'district', 'id' => app_id },
        'access_token' => app_token,
        'scopes' => ['read:district_admins']
      }]
    }
  end

  it 'is configurable' do
    expect(client).to be_a(Clever::Client)
    expect(client.app_id).to eq(app_id)
    expect(client.vendor_key).to eq(vendor_key)
    expect(client.vendor_secret).to eq(vendor_secret)
  end

  it 'has proper defaults' do
    client = Clever::Client.new
    expect(client.api_url).to eq(Clever::API_URL)
    expect(client.tokens_endpoint).to eq(Clever::TOKENS_ENDPOINT)
  end

  describe 'authentication' do
    let(:mock_response) { Clever::Response.new(stub(body: tokens_body, status: status)) }
    before { client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(mock_response) }

    context 'successful authentication' do
      it 'sets app_token' do
        client.connection.expects(:set_token).with(app_token)
        client.authenticate
        expect(client.app_token).to eq(app_token)
      end
    end

    context 'connection error' do
      let(:tokens_body) { nil }
      let(:status) { 401 }
      it 'raises error' do
        expect { client.authenticate }.to raise_error(Clever::ConnectionError)
      end
    end

    context 'district not found' do
      let(:tokens_body) { { 'data' => [] } }
      it 'raises error' do
        expect { client.authenticate }.to raise_error(Clever::DistrictNotFound)
      end
    end
  end

  describe 'tokens' do
    before { client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(mock_response) }
    let(:response) { client.tokens }

    context 'unsuccessful response' do
      let(:mock_response) { Clever::Response.new(stub(body: nil, status: 401)) }

      it 'returns a failed response' do
        expect(response.success?).to eq(false)
        expect(response.status).to eq(401)
      end
    end

    context 'successful response' do
      let(:raw_body) do
        {
          'data' => [{
            'id' => '58939ac0a206f40316fe8a1c',
            'created' => '2017-02-02T20:46:56.435Z',
            'owner' => { 'type' => 'district', 'id' => '5800e1c5e16c4230146fce0' },
            'access_token' => '0ed35a0de3005aa1c77df310ac0375a6158881c4',
            'scopes' => ['read:district_admins']
          }]
        }
      end
      let(:mock_response) { Clever::Response.new(stub(body: raw_body, status: 200)) }

      it 'returns a response with the body mapped' do
        expect(response.success?).to eq(true)
        expect(response.status).to eq(200)
        expect(response.raw_body).to eq(raw_body)
        expect(response.body.size).to eq(raw_body['data'].length)
      end
    end
  end

  describe 'district data requests' do
    let(:tokens_response) { Clever::Response.new(stub(body: tokens_body, status: status)) }
    before do
      client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(tokens_response)
      client.connection.expects(:set_token).with(app_token)
    end

    describe 'students' do
      let(:student_1) do
        {
          'data' => {
            'id' => '17b6cc35f',
            'name' => { 'first' => 'jane', 'last' => 'doe' },
            'credentials' => { 'district_username' => 'jdoez' },
            'grade' => '1'
          }
        }
      end
      let(:student_2) do
        {
          'data' => {
            'id' => '5b1f7442',
            'name' => { 'first' => 'johnny', 'last' => 'appleseed' },
            'credentials' => { 'district_username' => 'applej0n' },
            'grade' => '6'
          }
        }
      end
      let(:students_body) { { 'data' => [student_1, student_2] } }
      let(:students_response) { Clever::Response.new(stub(body: students_body, status: status)) }

      before do
        client.connection.expects(:execute)
          .with(Clever::STUDENTS_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(students_response)
      end

      context 'not yet authenticated' do
        it 'authenticates and returns students' do
          response = client.students.force
          expect(client.app_token).to eq(app_token)

          first_student  = response[0]
          second_student = response[1]

          expect(first_student.class).to eq(Clever::Types::Student)
          expect(first_student.id).to eq(student_1['data']['id'])
          expect(first_student.first_name).to eq(student_1['data']['name']['first'])
          expect(first_student.last_name).to eq(student_1['data']['name']['last'])
          expect(first_student.district_username).to eq(student_1['data']['credentials']['district_username'])
          expect(first_student.grade).to eq(student_1['data']['grade'])
          expect(first_student.provider).to eq('clever')

          expect(second_student.class).to eq(Clever::Types::Student)
          expect(second_student.id).to eq(student_2['data']['id'])
          expect(second_student.first_name).to eq(student_2['data']['name']['first'])
          expect(second_student.last_name).to eq(student_2['data']['name']['last'])
          expect(second_student.district_username).to eq(student_2['data']['credentials']['district_username'])
          expect(second_student.grade).to eq(student_2['data']['grade'])
          expect(second_student.provider).to eq('clever')
        end
      end
    end

    describe 'courses' do
      let(:course_1) do
        {
          'data' => {
            'id' => '1',
            'district' => '12345',
            'name' => 'The Best Course',
            'number' => '555'
          }
        }
      end
      let(:course_2) do
        {
          'data' => {
            'id' => '100',
            'district' => '12345',
            'name' => 'The Worst Course',
            'number' => '000'
          }
        }
      end
      let(:courses_body) { { 'data' => [course_1, course_2] } }
      let(:courses_response) { Clever::Response.new(stub(body: courses_body, status: status)) }

      before do
        client.connection.expects(:execute)
          .with(Clever::COURSES_ENDPOINT, :get, limit: Clever::PAGE_LIMIT)
          .returns(courses_response)
      end

      context 'not yet authenticate' do
        it 'authenticates and returns courses' do
          response = client.courses.force
          expect(client.app_token).to eq(app_token)

          first_course  = response[0]
          second_course = response[1]

          expect(first_course.class).to eq(Clever::Types::Course)
          expect(first_course.id).to eq(course_1['data']['id'])
          expect(first_course.district).to eq(course_1['data']['district'])
          expect(first_course.name).to eq(course_1['data']['name'])
          expect(first_course.number).to eq(course_1['data']['number'])

          expect(second_course.class).to eq(Clever::Types::Course)
          expect(second_course.id).to eq(course_2['data']['id'])
          expect(second_course.district).to eq(course_2['data']['district'])
          expect(second_course.name).to eq(course_2['data']['name'])
          expect(second_course.number).to eq(course_2['data']['number'])
        end
      end
    end
  end
end
