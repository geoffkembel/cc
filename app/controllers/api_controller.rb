class ApiController < ApplicationController
  
  # https://github.com/qoobaa/s3
  require "s3"
  
  # return array of s3 file objects
  # [#<S3::Object:/conspire-challenge/claims_to_fame.txt>, ...]
  def get_files_from_s3
    # connect to s3
    service = S3::Service.new(:access_key_id => ENV['S3_KEY'], :secret_access_key => ENV['S3_SECRET'])
    # get bucket
    bucket = service.buckets.find(ENV['S3_BUCKET'])
    # return files
    bucket.objects
  end
  
  # trim an object: strip a string, ignore otherwise
  def trim(v)
    v.respond_to?('strip') ? v.strip : v
  end
  
  # return array of line objects from array of s3 file objects
  # [{ "f": "claims_to_fame.txt", "k": "Maroon 5", "v": "lameness" }, ... ]
  def read_files_into_line_objects(files)
    lines = []
    files.each do |f|
      filename = f.key
      file = files.find(filename)
      file.content.split(/\r?\n/).each do |line|
        key, value = line.split("\t")
        lines << { :f => filename, :k => trim(key), :v => trim(value) }
      end
    end
    lines
  end
  
  def query
    files = get_files_from_s3()
    lines = read_files_into_line_objects(files)
    render :json => lines
  end
end
