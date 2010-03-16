#!/usr/bin/env ruby -KU

%w(rubygems sinatra erb rack rdiscount haml sass).each {|l| require l }

# local requires
require 'config'
require 'model'

# css styling
get '/main.css' do
  content_type 'text/css', :charset =>'utf-8'
  sass 'css/main'.to_sym
end

# viewing
get '/tag/:tag' do
  @projs = Project.find_all_by_tags(params[:tag])
  haml :tag
end

# find by project id 
get %r{/proj/([\dabcdef]{24})} do
  @p = Project.find(params[:captures].first)
  haml :show
end

get '/proj/:proj_name' do
  @p = Project.find_by_name(params[:proj_name])
  @p.homepage = "http://github.com"
  @title = @p.name
  haml :show
end

# adding / editing
get '/add' do
  @is_add = true
  @p = Project.new
  haml :add
end

post '/add' do
  @p = Project.new(params)
  @is_add = true
  if is_secret? params[:secret_password] and @p.save
    redirect "/proj/#{@p.name}"
  else
    haml :add
  end
end

# editing
get "/edit/:id" do
  @p = Project.find(params[:id]) || Project.new
  @is_add = false
  haml :add
end

post "/edit/:id" do
  @p = Project.find(params[:id])
  @is_add = false
  if is_secret? params[:secret_password] and @p.update_attributes!(params)
    redirect "/proj/#{@p.name}"
  else
    haml :add
  end
end

get '/' do
  haml :index
end


