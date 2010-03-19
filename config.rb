
set :haml, {:format => :html5}

configure :development do
  use Rack::Reloader
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def is_secret?(pass)
    require 'digest/md5'
    "773e0611e1b23b0dce69e7896d52ab9f" == Digest::MD5.hexdigest(pass)
  end

  def url(url)
    "<a class=\"url\" href=\"#{url}\">#{url}</a>"
  end
  
  def updated_days(p)
    days = ((Time.now - @p.updated_at)/86400).round
    "updated #{days} #{pluralize('day',days)} ago"
  end
  
  def proj_link(p)
    require 'uri'
    "<a class=\"proj-link\" href=\"/proj/#{URI.escape(p.name)}\">#{h p.name}</a>"
  end
  
  def pluralize(word, arr)
    has_s = arr.size != 1 if arr.kind_of? Enumerable
    has_s = arr != 1 if arr.kind_of? Numeric
    has_s ||= false
    word + (has_s ? "s" : "")
  end

  def link(name, url)
    "<a href=\"#{url}\">#{name}</a>"
  end

  def tag_link(name, url)
    "<a class=\"tag\" href=\"#{url}\">#{name}</a>"
  end
  
  def tag_list(arr, do_link=true)
    arr.reduce("") do |str, tag| 
      t = tag.tag; 
      str += (do_link ? tag_link(t,'/tag/'+t) : t) + " " 
    end[0..-2] 
  end
  
  def markdown(str)
    RDiscount.new(str, :smart, :filter_html).to_html
  end
end

# stolen from http://gist.github.com/119874
# stolen from http://github.com/cschneid/irclogger/blob/master/lib/partials.rb
#   and made a lot more robust by me
# this implementation uses erb by default. if you want to use any other template mechanism
#   then replace `erb` on line 13 and line 17 with `haml` or whatever 
module Sinatra::Partials
  def partial(template, *args)
    template_array = template.to_s.split('/')
    template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:layout => false)
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << erb(:"#{template}", options.merge(:layout =>
        false, :locals => {template_array[-1].to_sym => member}))
      end.join("\n")
    else
      erb(:"#{template}", options)
    end
  end
end
