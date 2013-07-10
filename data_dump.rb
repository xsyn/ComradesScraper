#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'logger'

# Usage: - data_dump.rb [year]

scope = ARGV[0]
#scope = 2013

def connect_to_www(scope)

  agent = Mechanize.new do |agent| 
    agent.log = Logger.new(STDOUT)
    agent.follow_meta_refresh = true 
  end

  page = agent.get('http://results.comrades.com/Default.aspx') 

  #Search form
  search_form = page.form('form1')
  search_form.add_field!("__EVENTTARGET")
  search_form.add_field!("__EVENTARGUMENT")
  search_form.add_field!("__LASTFOCUS")
  search_form.add_field!("btnSearch", "Search")
  search_form.cbRace = scope - 1919
  search_form.cbEvent = 1
  
  page = agent.submit(search_form).search('#grdResults').search('table')
  page.each do |rows|
    tdArray = Array.new
    result = Array.new
    rows.search('tr').each do |tr|
      textA = Array.new
      textArray = Array.new
      tr.search('td').each do |td|
        textA = textArray.push(td.text.delete("\n").delete("\r").delete("\t"))
      end
      result = tdArray.push(textA.join(','))
    end
  end
end

if scope.nil?
  time = Time.new
  start = 1921
  finish = p time.year
  for i in start..finish
    connect_to_www(i)
  end
else
  conenct_to_www(scope)
end
