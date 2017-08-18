require 'sinatra'
require 'pivotal_card_checker'

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

get '/' do
  report = PivotalCardChecker::CardChecker.check_cards(ENV['API_KEY'], ENV['PROJECT_ID'])
  report.gsub!("\n", "<br />")
  report.gsub!("        ", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
  report.gsub!(/https.*?\d+/) {|sym| "<a target='_blank' href='#{sym}'>#{sym}</a>"}
end

get '/plaintext' do
  content_type 'text'
  PivotalCardChecker::CardChecker.check_cards(ENV['API_KEY'], ENV['PROJECT_ID'])
end

get '/create' do
  erb :create
end

get '/create_deploy_card' do
  DEPLOY_LABEL_ID = 2_506_935
  PivotalCardChecker::CardChecker.create_deploy_card(ENV['API_KEY'], ENV['PROJECT_ID'], [DEPLOY_LABEL_ID])
  "<h1>Successfully created card.</h1>"
end