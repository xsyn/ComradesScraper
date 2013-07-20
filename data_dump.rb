#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'logger'
require 'fastest-csv'
require 'json'

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
  search_form.cbRace = (scope.to_i - 1919)
  search_form.cbEvent = 1
  
  page = agent.submit(search_form).search('#grdResults').search('table')
  page.each do |rows|
    result = Array.new
    rows.search('tr').each do |tr|
      textA = Array.new
      tr.search('td').each do |td|
        textA.push(td.text.delete("\n").delete("\r").delete("\t"))
        #td.link.each_with_index do |x, i|
        #  if i == 0
        #    individual = agent.click(link) 
        #    p individual
        #  end
        #end
      end
      # First result returns nil for some reason
      if textA[1].nil?
        next
      end
      # Need to remove escaping backslashes that are input for inverted comma's
      # Year  Pos Race No First Name  Last Name Gun Time  Category  Cat Pos Gender  Gen Pos Medal Status  Medals  Video
      result.push("{'year' : '" + textA[0] +
          "', 'position' : '" + textA[1] +
          ", 'race_no' : '" + textA[2] +
          "', 'first' : '" + textA[3] +
          "', 'last' : '" + textA[4] +
          "', 'time' : '" + textA[5] +
          "', 'category' : '" + textA[6] +
          "', 'category_pos' : '" + textA[7] +
          "', 'gender' : '" + textA[8] +
          "', 'gender_pos' : '" + textA[9] +
          "', 'medal' : '" + textA[10] +
          "', 'status' : '" + textA[11] +
          "', 'medals' : '" + textA[12] +
          "}")
      #result = tdArray.push(textA.join(','))
      #FastestCSV.parse(result).to_json
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
  connect_to_www(scope)
end
