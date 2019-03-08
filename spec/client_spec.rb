# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clever::Client do
  let(:app_id) { 'app' }
  let(:vendor_key) { 'vendor_key' }
  let(:vendor_secret) { 'vendor_secret' }

  let(:client) do
    Clever::Client.configure do |config|
      config.app_id        = app_id
      config.vendor_key    = vendor_key
      config.vendor_secret = vendor_secret
    end
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
    let(:raw_body) { nil }
    let(:status) { 200 }
    let(:mock_response) { Clever::Response.new(stub(body: raw_body, status: status)) }
    before { client.connection.expects(:execute).with(Clever::TOKENS_ENDPOINT).returns(mock_response) }

    context 'connection error' do
      let(:status) { 401 }
      it 'raises error' do
        expect { client.authenticate }.to raise_error(Clever::ConnectionError)
      end
    end

    context 'district not found' do
      let(:raw_body) { { 'data' => [] } }
      it 'raises error' do
        expect { client.authenticate }.to raise_error { Clever::DistrictNotFound }
      end
    end

    context 'successful authentication' do
      let(:app_token) { '0ed35a0de3005aa1c77df310ac0375a6158881c4' }
      let(:app_id) { '5800e1c5e16c4230146fce0' }
      let(:raw_body) do
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
      it 'sets app_token' do
        client.connection.expects(:set_token).with(app_token)
        client.authenticate
        expect(client.app_token).to eq(app_token)
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
end
