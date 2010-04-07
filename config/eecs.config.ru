require 'rubygems'
require 'yaml'
$config = File.open("config/config.yaml") {|fh| YAML::load(fh) }

ENV['GEM_HOME'] = $config['eecs']['gem_home']
ENV['GEM_PATH'] = $config['eecs']['gem_path']
Gem.clear_paths

require 'app'

run Sinatra::Application
