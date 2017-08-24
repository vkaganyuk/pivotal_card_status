require 'sinatra'
require 'pivotal_card_checker'

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

get '/' do
  report = PivotalCardChecker::CardChecker.check_cards(ENV['API_KEY'], ENV['PROJECT_ID'])
  report.gsub!("\n", "<br />")
  report.gsub!("        ", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;") if report.include?('        ')
  report.gsub!(/https.*?\d+/) {|sym| "<a target='_blank' href='#{sym}'>#{sym}</a>"} if report.include('https')
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
  STORY_ID_INDEX = 3
  result = PivotalCardChecker::CardChecker.create_deploy_card(ENV['API_KEY'], ENV['PROJECT_ID'], [DEPLOY_LABEL_ID])
  content_type 'text'
  if result.is_a?(Array)
    "Successfully created deploy card: https://www.pivotaltracker.com/story/show/#{result[STORY_ID_INDEX]}"
  else
    result
  end
end
