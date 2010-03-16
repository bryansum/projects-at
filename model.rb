#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'projects-at'

require 'lingua/stemmer'
class Stemmer
  STOP_WORDS = "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,
been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,
got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,
least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,
only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,
their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,
where,which,while,who,whom,why,will,with,would,yet,you,your".split(",")

  def self.index(str)
    words = str.scan(/\w+[-_]*\w+/).map(&:downcase).compact.uniq
    Lingua.stemmer(words - STOP_WORDS) unless words.nil?
  end
  
  def self.make_keyword(str)
    Lingua.stemmer(str.downcase)
  end
end

class Project
  include MongoMapper::Document
  
  key :name, String, :required => true, :index => true
  key :summary, String, :required => true
  key :description, String
  key :icon, String
  key :homepage, String
  key :tags, Array, :index => true
  key :keywords, Array, :index => true

  timestamps!

  many :authors
  before_save :check
  
  def self.search(str)
    str.split.each_with_object({}) do |w,h| 
      projs = Project.find_by_keywords(Stemmer::make_keyword(w))
      [projs].flatten.each {|p| h[p] = h[p] ? h[p] += 1 : 1 } if projs
    end.sort{|a,b| b[1] <=> a[1] }.map{|n| n[0]}
  end
  
  def self.similar_tags(str)
    regex = /^#{str}.*$/
    self.collection.find({:tags=>regex},:fields=>'tags').to_a.\
    each_with_object(Set.new){|h,set| h['tags'].each{|t| set << t} }.\
    select {|s| s =~ regex }
  end
  
  def self.all_tags(opts={})
    tags = self.collection.distinct('tags').compact.flatten.uniq!
    tags = tags.take(opts[:limit]) if opts[:limit]
    tags
  end
  
  def self.popular_tags(opts={})
    tags = self.all_tags.each_with_object({}){|t,h| h[t] = h[t] ? h[t] + 1 : 1}.\
    sort{|a,b| a[1] <=> b[1] }.reverse!
    tags = tags.take(opts[:limit]) if opts[:limit]
    tags
  end
  
  # index our description
  def check
    self.keywords = Stemmer::index([self.description,self.name,self.tags].compact.join(" "))
    self.secret_password = nil
  end
  
  def pp_authors
    self.authors.reduce(""){|str,a| str += a.name; str += " <"+a.email+">" if a.email; str += ", "; }[0..-3]
  end
end

class Author
  include MongoMapper::EmbeddedDocument
  
  key :name, String, :required => true
  key :email, String
  
end
