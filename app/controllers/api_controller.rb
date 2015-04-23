class ApiController < ApplicationController
  def query
    lines = [
      { :f => 'gryffindor', :k => 'harry', :v => 'potter' },
      { :f => 'gryffindor', :k => 'ron', :v => 'weasley' },
      { :f => 'slytherin', :k => 'draco', :v => 'malfoy' }
    ]
    render :json => lines
  end
end
