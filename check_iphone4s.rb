#!/usr/bin/env ruby
# encoding = UTF-8
#
# This script requires following gems:
# - Hpricot
# - growl (Please build it from latest github source code)
#
# And of course, you need a Mac and Growl.
# 
#

require "rubygems"
require "open-uri"
require "hpricot"
require "growl"

#Growl.bin_path = "/usr/local/bin/growlnotify"

def check_availbility(country)
  links = {"China" => "http://store.apple.com/cn/browse/home/shop_iphone/family/iphone/iphone4s",
          "HK" => "http://store.apple.com/hk-zh/browse/home/shop_iphone/family/iphone/iphone4s"}
  
  message, title = ""
  sticky = false

  begin
    f = open links[country]
  rescue OpenURI::HTTPError => e
    sticky = false
    title = "iPhone 4s not available"
    message = "iPhone 4s pre-order is not started in #{country}, yet."
  rescue Exception => e
    sticky = false
    title = "Unknwon Error"
    message = "Unknown error for HK Store: #{e.message}."
  else
    doc = Hpricot(f)
    results = []
    doc.search("//span[@class='shipping']/span").each do |span|
      results << span.to_plain_text
    end
    results.delete_if {|item| item == "暂无供应" or item == "暫無供應"}

    if results.size == 0
      sticky = false
      title = "iPhone 4s not available"
      message = "iPhone 4s is not available for purchase in #{country}, yet."
    else
      sticky = true
      title = "iPhone 4s Available"
      message = "#{results.size} modal(s) maybe available in #{country} to purchase!!!"
    end
  end

  Growl.notify message, :title => title, :sticky => sticky
end

while true 
  #["China", "HK"].each { |country| check_availbility(country) }
  ["HK"].each { |country| check_availbility(country) }
  sleep(300)
end 
