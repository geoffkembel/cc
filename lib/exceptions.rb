module Exceptions
  class ApiError < StandardError; end
  class InvalidSort < ApiError; end
  class Maroon5IsntThatLame < ApiError; end
end