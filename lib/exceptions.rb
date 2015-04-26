module Exceptions
  class ApiError < StandardError; end
  class InvalidSort < ApiError; end
end