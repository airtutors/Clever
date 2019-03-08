# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

require 'clever/client'
require 'clever/connection'
require 'clever/response'
require 'clever/version'

require 'clever/types/token'

module Clever
  API_URL         = 'https://api.clever.com/v2.0'
  TOKENS_ENDPOINT = 'https://clever.com/oauth/tokens?owner_type=district'
end
