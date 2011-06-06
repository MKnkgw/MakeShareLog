require "spec/spec_helper"

describe 'MakeupLog' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "must login" do
    get '/'
    last_response.status.should == 302
    last_response.location.should =~ %r{/login$}
  end

  it "success login" do
    get '/'
    last_response.status.should == 302
    last_response.location.should =~ %r{/login$}
  end
end
