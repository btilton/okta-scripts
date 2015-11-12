#!/usr/bin/env ruby
#############################
#      Author : Brian Tilton
#        Date : 8/18/2015
#       Title : lookup-user.rb
# Description : Script to experiment with and test the Okta API
#############################

require 'json'
require 'net/http'

##### API Token and Subdomain #####
# Place your API Token as the first line of a file called api.token in the same
#   directory as this script. The second line of the file should be the
#   subdomain, domain, and TLD for your Okta account up to the TLD. For example
#   if your account is at https://example.okta.com/ the second line of the file
#   should be 'example.okta.com'
###################################

APIFILE = File.readlines("#{File.dirname(__FILE__)}/api.token").each\
          {|f| f.chomp!}
APITOKEN = APIFILE[0]
ADDRESS = APIFILE[1]

##### Constant/Input Variables #####

username = ARGV[0]
jsonkey = ARGV[1]
myquery = "/users/#{username}"

##### Net Stuff #####

uri = URI.parse("https://#{ADDRESS}/api/v1")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

headers = {
    "Authorization" => "SSWS #{APITOKEN}",
    "Accept" => "application/json",
    "Content-Type" => "application/json",
    "Cache-Control" => "no-cache"
}

response = http.get("#{uri}#{myquery}", headers)
datahash = JSON.parse(response.body)

##### Main Logic #####
##### AKA So Many Ifs #####

if !jsonkey.nil?
    splitkeys = jsonkey.split('.')
    puts jsonkey
end

if jsonkey.nil?
    output = datahash
elsif splitkeys[1].nil?
    output = datahash[jsonkey]
elsif splitkeys[2].nil?
    output = datahash[splitkeys[0]][splitkeys[1]]
else
    output = datahash[splitkeys[0]][splitkeys[1]][splitkeys[2]]
end

if output.is_a? String
    puts output
else
    puts JSON.pretty_generate(output)
end
