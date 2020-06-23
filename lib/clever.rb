# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

require 'clever/client'
require 'clever/connection'
require 'clever/paginator'
require 'clever/response'
require 'clever/version'

require 'clever/types/base'
require 'clever/types/classroom'
require 'clever/types/course'
require 'clever/types/enrollment'
require 'clever/types/event'
require 'clever/types/student'
require 'clever/types/section'
require 'clever/types/teacher'
require 'clever/types/term'
require 'clever/types/token'

module Clever
  API_URL           = 'https://api.clever.com/v2.0'
  TOKENS_ENDPOINT   = 'https://clever.com/oauth/tokens?owner_type=district'
  STUDENTS_ENDPOINT = '/v2.0/students'
  COURSES_ENDPOINT  = '/v2.0/courses'
  SECTIONS_ENDPOINT = '/v2.0/sections'
  TEACHERS_ENDPOINT = '/v2.0/teachers'
  EVENTS_ENDPOINT   = '/v1.2/events'
  TERMS_ENDPOINT    = '/v2.0/terms'
  GRADES_ENDPOINT   = 'https://grades-api.beta.clever.com/v1/grade'

  class DistrictNotFound < StandardError; end
  class ConnectionError < StandardError; end
end
