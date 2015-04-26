class ApiController < ApplicationController
  
  # https://github.com/qoobaa/s3
  require "s3"
  
  DEFAULT_SORT = "fkv"
  
  # return array of s3 file objects
  # [#<S3::Object:/conspire-challenge/claims_to_fame.txt>, ...]
  def get_files_from_s3
    # connect to s3
    service = S3::Service.new(:access_key_id => ENV['S3_KEY'], 
                              :secret_access_key => ENV['S3_SECRET'])
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
        lines << { :filename => filename, :key => trim(key), :value => trim(value) }
      end
    end
    lines
  end
  
  # validate a sort value and normalize it to have one of each of the letters
  def validate_and_normalize_sort(sort)
    # validate sort has only f, k, and v characters
    raise ArgumentError unless sort =~ /^[fkv]*$/
    # set default if empty
    sort = DEFAULT_SORT if sort.empty?()
    # append default sort to fill in any unspecified letters in the right order
    sort += DEFAULT_SORT
    # reduce a sort that has any letter more than once (e.g. fkvvkf => fkv) to
    # get a three letter sort in the right order
    sort.split("").uniq.join
  end
  
  # get a property for the array_for_sort_by based on the letter
  # "f" => obj[:filename].to_s.downcase
  def get_property_by_sort_letter(obj, sort_letter)
    property = case (sort_letter)
    when "f" then obj[:filename]
    when "k" then obj[:key]
    when "v" then obj[:value]
    end
    # add to_s to handle non string values (like nil) and downcase for sort
    property.to_s.downcase
  end
  
  # get a custom array for the sort_by call, based on the sort param. e.g.
  # "fkv" => [ obj[:filename], obj[:key], obj[:value] ]
  def get_array_for_sort_by(obj, sort)
    array_for_sort_by = []
    sort.split("").each do |sort_letter|
      array_for_sort_by << get_property_by_sort_letter(obj, sort_letter)
    end
    array_for_sort_by
  end
  
  # sort line objects based on a sort specified on the query string
  def sort_lines(lines)
    # get sort from the query string, else defaut to "fkv"
    sort = (request.GET.has_key?("sort")) ? request.GET["sort"] : DEFAULT_SORT
    normalized_sort = validate_and_normalize_sort(sort)
    lines.sort_by { |obj| get_array_for_sort_by(obj, normalized_sort) }
  end
  
  # render errors consistently
  def render_error(status, message)
    error = {
      :status => status, 
      :message => message
    }
    render :json => error.to_json(), status: status
  end

  # query endpoint 
  def query
    begin
      files = get_files_from_s3()
      lines = read_files_into_line_objects(files)
      sorted_lines = sort_lines(lines)
      render :json => sorted_lines, status: :ok
    rescue ArgumentError
      message = "Invalid sort value. Please specify a string of length zero "\
                "or greater consisting of only the characters f, k and v"
      render_error(400, message)
    rescue Exception
      render_error(500, "Unknown server error")
    end
  end
end

