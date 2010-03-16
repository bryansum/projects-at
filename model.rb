#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'projects-at'


class Project
  include MongoMapper::Document
  
  key :name, String, :required => true
  key :summary, String, :required => true
  key :description, String
  key :icon, String
  key :homepage, String
  key :tags, Array

  timestamps!

  many :authors
end

class Author
  include MongoMapper::EmbeddedDocument
  
  key :name, String, :required => true
  key :email, String
  
end
