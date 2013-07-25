#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'logger'
require 'csv'
require 'json'

# Usage: - data_dump.rb [year]

#scope = ARGV[0]
scope = 2013

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

  CSV.open("results.csv", "w") do |csv|
    page = agent.submit(search_form).search('#grdResults').search('table')
    page.each do |rows|
      result = Array.new
      rows.search('tr').each do |tr|
        textA = Array.new
        tr.search('td').each do |td|
          textA.push(td.text.delete("\n").delete("\r").delete("\t"))
          td.search('font').search('a').each do |a|
            if a["href"].include? "Splits"
              # This should maybe be turned into a sub-routine
              split_url = a["href"]
              spage = agent.get('http://results.comrades.com/' + split_url)
              spage.search('#grdResults').search('table').search('tr').each do |splittr|
                splitresult = Array.new
                splittr.search('td').each do |splittd|
                  splitresult << splittd.text.delete("\n").delete("\r").delete("\t")
                end
                textA << splitresult
              end
            end
          end
        end
        # First result returns nil for some reason
        if textA[1].nil?
          next
        else
          #Position, runnerid, time, category, status, splits 1 - 5
          result[0] = textA[1]
          result[1] = textA[2]
          result[2] = textA[11]
          result[3] = textA[12]
          result[4] = textA[16]
          result[5] = textA[4][1]
          result[6] = textA[5][1]
          result[7] = textA[6][1]
          result[8] = textA[7][1]
          result[9] = textA[8][1]

          csv << result
        end
      end
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
