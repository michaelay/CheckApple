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
  links = {
           "China" => "http://store.apple.com/cn/browse/home/shop_iphone/family/iphone/iphone4s",
           "HK" => "http://store.apple.com/hk/browse/home/shop_iphone/family/iphone",
           "US" => "http://store.apple.com/us/browse/home/shop_iphone/family/iphone",
           "CA" => "http://store.apple.com/ca/browse/home/shop_iphone/family/iphone",
           "SG" => "http://store.apple.com/sg/browse/home/shop_iphone/family/iphone",
          } 
  
  message, title = ""
  sticky = false

  begin
    f = open links[country]
  rescue OpenURI::HTTPError => e
    sticky = false
    title = "iPhone 5 not available"
    message = "iPhone 5 pre-order is not started in #{country}, yet."
  rescue Exception => e
    sticky = false
    title = "Unknwon Error"
    message = "Unknown error for HK Store: #{e.message}."
  else
    doc = Hpricot(f)
    results = []
    doc.search("//p[@class='buy-button']").each do |span|
      results << "pre order" #span.to_plain_text
    end
    #doc.search("//p[@class='coming-soon']").each do |span| 
    #  results << "coming soon"
    #end 
    results.delete_if {|item| item == "暂无供应" or item == "暫無供應"}

    if results.size == 0
      puts country + ": ---"
      sticky = false
      title = "iPhone 5 not available"
      message = "iPhone 4s is not available for purchase in #{country}, yet."
    else
      puts country + ": iphone !!!"
      #sticky = true
      sticky = false
      title = "iPhone 5 Available"
      message = "#{results.size} modal(s) maybe available in #{country} to purchase!!!"
    end
  end

  Growl.notify message, :title => title, :sticky => sticky
end

while true 
  ["HK","SG"].each { |country| check_availbility(country) }
  #sleep(300)
  sleep(5)
end 
