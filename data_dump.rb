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

  CSV.open("report.csv", "w") do |csv|
    page = agent.submit(search_form).search('#grdResults').search('table')
    page.each do |rows|
      result = Array.new
      newresult = Array.new
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
                  splitresult.push(splittd.text.delete("\n").delete("\r").delete("\t"))
                end
                textA.push(splitresult)
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
          result[3] = textA[11]
          result[4] = textA[12]
          result[5] = textA[15]
          result[6] = textA[4][1]
          result[7] = textA[5][1]
          result[8] = textA[6][1]
          result[9] = textA[7][1]
          result[10] = textA[8][1]

          csv << result
          #newresult.push(result.join(','))
          #p newresult
        end
        # ["2013", "12", "59588", [], ["Cowies Hill (70kms to go)", "01:06:15", "06:36:20", " ", " ", " ", " ", "16.86", "70.1", "  3.93"], ["Drummond (halfway)", "02:51:24", "08:21:28", " ", " ", " ", " ", "42.96", "44", "  3.99"], ["Camperdown (26kms to go)", "04:04:09", "09:34:14", " ", " ", " ", " ", "60.66", "26.3", "  4.03"], ["Polly Shorts (7kms to go)", "05:27:43", "10:57:48", " ", " ", " ", " ", "79.26", "7.7", "  4.13"], ["Finish", "05:58:49", "11:28:53", " ", " ", " ", " ", "86.96", "0", "  4.13"], "Mkhonzeni", "Basi", "05:58:50", "Ages 30 - 39", "10", "Male", "12", "Wally Hayward", "Finished", "4", "View Video"]
        # Now we want to turn it into a json object
        # Year  Pos Race No First Name  Last Name Gun Time  Category  Cat Pos Gender  Gen Pos Medal Status  Medals  Video
        #result.push("{'year' : '" + textA[0] +
        #    "', 'position' : '" + textA[1] +
        #    ", 'race_no' : '" + textA[2] +
        #    "', 'first' : '" + textA[3] +
        #    "', 'last' : '" + textA[4] +
        #    "', 'time' : '" + textA[5] +
        #    "', 'category' : '" + textA[6] +
        #    "', 'category_pos' : '" + textA[7] +
        #    "', 'gender' : '" + textA[8] +
        #    "', 'gender_pos' : '" + textA[9] +
        #    "', 'medal' : '" + textA[10] +
        #    "', 'status' : '" + textA[11] +
        #    "', 'medals' : '" + textA[12] +
        #    "}")
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
