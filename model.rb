#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'dm-timestamps'
require 'dm-ar-finders'

DataMapper.setup(:default,ENV['DATABASE_URL']||"sqlite3://#{Dir.pwd}/my.db")

module Stemmer
  require 'lingua/stemmer'
  STOP_WORDS = "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,
been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,
got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,
least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,
only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,
their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,
where,which,while,who,whom,why,will,with,would,yet,you,your".split(",")

  def self.extract_keywords(str)
    words = str.scan(/\w+[-_]*\w+/).compact.map(&:downcase).uniq
    [Lingua.stemmer(words - STOP_WORDS)].flatten unless words.nil?
  end
  
  def self.keywordize(str)
    Lingua.stemmer(str.downcase)
  end
end

class Keyword
  include DataMapper::Resource
  property :id, Serial
  property :keyword, String, :unique_index => true
  has n, :projects, :through => Resource # anonymous join
end

class Tag
  include DataMapper::Resource
  property :id, Serial
  property :tag, String, :unique_index => true
  has n, :projects, :through => Resource
  
  def to_json
    {:tag => self.tag, :id => self.id }
  end
  
  def self.popular(limit=10)
    repository.adapter.select("SELECT t.id, t.tag, COUNT(*) as 'num' FROM tags t JOIN 
    project_tags pt on pt.tag_id = t.id GROUP BY t.id ORDER BY num DESC LIMIT ?",
    [limit]).map{|a| Tag.new(:id=>a[0],:tag=>a[1]) }
  end
end

class Project
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :unique_index => true
  property :summary, String, :required => true
  property :description, Text
  property :icon, String
  property :homepage, String
  property :points, Integer, :default => 0
  property :authors, String

  property :updated_at, DateTime
  property :created_at, DateTime

  has n, :tags, :through => Resource # anon. join
  has n, :keywords, :through => Resource
  
  before :save, :index_keywords

  def self.with_keyword(kw)
    kw = Keyword.first :keyword=>Stemmer::keywordize(kw)
    kw.projects if kw
  end
  
  def self.popular(limit=10)
    all(:order=>:points.desc, :limit=>limit)
  end
  
  def self.make(params)
    p = Project.new
    p.make(params)
    p
  end
  
  def make(p)
    self.attributes = {:name => p[:name], 
      :summary => p[:summary],
      :description => p[:description],
      :homepage => p[:homepage],
      :tags => conv_tag_str(p[:tags]),
      :authors => p[:authors]
    }
  end

private

  def conv_tag_str(str)
    str ? str.split.map{|t| Tag.find_or_create :tag => t } : []
  end

  def index_keywords
    self.keywords = Stemmer::extract_keywords([name,summary,description].join(" "))
    .map {|kw| Keyword.find_or_create :keyword => kw }
  end

end

