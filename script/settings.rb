
require 'yaml'
require 'rubygems'

root = File.dirname(__FILE__)+"/.."
$config = File.open(root+"/config/config.yaml") {|fh| YAML::load(fh) }
ENV['GEM_HOME'] = $config['eecs']['gem_home']
ENV['GEM_PATH'] = $config['eecs']['gem_path']
Gem.clear_paths