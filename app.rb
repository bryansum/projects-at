#!/usr/bin/env ruby -KU

%w(rubygems sinatra erb rack rdiscount haml sass json).each {|l| require l }

# local requires
require 'config'
require 'model'

# css styling
get '/main.css' do
  content_type 'text/css', :charset =>'utf-8'
  sass 'css/main'.to_sym
end

# viewing
get '/tag/:q' do
  tag = Tag.first(:tag => params[:q])
  @projs = tag.projects if tag
  haml :tag
end

# find by project id 
get %r{/proj/([\dabcdef]{24})} do
  @p = Project.first(:name=>params[:captures].first)
  if @p
    @p.points += 1
    @p.save
  end
  haml :show
end

get '/proj/:proj_name' do
  @p = Project.first(:name=>params[:proj_name])
  if @p
    @p.points += 1
    @p.save # add to this project's point score
  end
  @title = @p.name
  haml :show
end

# adding / editing
get '/add' do
  @is_add = true
  @p = Project.new
  @title = "Add a project"
  haml :add
end

post '/add' do
  @p = Project.make(params)

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
  @p.make(params) if @p

  if @p and is_secret? params[:secret_password] and @p.save
    redirect "/proj/#{@p.name}"
  else
    @is_add = false
    haml :add
  end
end

get "/tags/complete/:str" do
  content_type 'application/json', :charset=>'utf-8'
  JSON::generate(Tag.all(:tag.like => "#{params[:str]}%").map(&:to_json))
end

get "/tags/popular" do
  JSON::generate Tag.popular(5).map(&:to_json)
end

%w{/all /explore}.each do |path|
  get path do
    @projs = Project.all
    haml :explore
  end
end

get '/search' do
  @projs = Project.with_keyword params[:q]
  haml :tag
end

get '/' do
  haml :index
end


