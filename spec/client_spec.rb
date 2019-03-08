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

  it 'authenticates connection' do
    client.connection.expects(:authenticate?).once

    client.authenticate?
  end

  it 'has proper defaults' do
    client = Clever::Client.new
    expect(client.api_url).to eq(Clever::API_URL)
    expect(client.tokens_endpoint).to eq(Clever::TOKENS_ENDPOINT)
  end
end
