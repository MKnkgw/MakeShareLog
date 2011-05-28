require File.dirname(__FILE__) + "/spec_helper"


describe 'Hello MakeupLog' do
  include Rack::Test::Methods

  def app
    run Sinatra::Application
  end

  it "says hello" do
    get '/'
    p last_response
    p last_response.body
    last_response.should be_ok
  end
end
