#!/usr/bin/env ruby

require 'uri'
require 'open-uri'
require 'digest/md5'

module RBSearch
  class Spider
    def initialize(valid_domains, seed)
      @to_visit = [seed]
      @visited = []
      @valid_domains = valid_domains
    end
  
    def fetch(url)
      open(URI::parse(url)).read rescue ""
    end
  
    def extract_urls(html_content)
      urls = []
      URI::extract(html_content, "http").each do |url|
        host = URI::parse(url).host rescue ""
        if @valid_domains.include?(host)
          urls.push(url)
        end
      end
    
      return urls
    end
  
    def dump_data(url, data, dir="spider_data")
      fname = Digest::MD5.hexdigest(url)
      File.new(dir + fname, "w").write(url + "\n" + data)
    end
  
    def process_url(current_url)
      if @visited.include?(current_url)
        return
      end
    
      puts "URI: %s" % [current_url]
      html_content = self.fetch(current_url)
      new_urls = self.extract_urls(html_content)
      new_urls.each do |new_url|
        absolute_url = URI::join(current_url, new_url).to_s
        if !@to_visit.include?(absolute_url) and !@visited.include?(absolute_url)
          @to_visit.push(absolute_url)
        end
      end
    
      self.dump_data(current_url, html_content)
      @visited.push(current_url)
    end
  
    def crawl
      while !@to_visit.empty?
        self.process_url(@to_visit.shift)
      end
    end
  end
end
