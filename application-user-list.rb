#!/usr/bin/env ruby
#############################
#      Author | Brian Tilton
#        Date | 8/18/2015
#       Title | application-user-list.rb
# Description | Search for an application by name in Okta and output list of
#             | users assigned to it
#############################

require 'json'
require 'net/http'

##### API Token and address #####
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

##### Net Stuff #####

uri = URI.parse("https://#{ADDRESS}/api/v1")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

headers = {
    "Authorization" => "SSWS #{APITOKEN}",
    "Accept" => "application/json",
    "Content-Type" => "application/json"
}

##### Input Variables #####

sTerm = ARGV[0]
#myquery = "/apps?q=#{sTerm}&limit=1"

##### Main Logic #####

idkey = ''

response = http.get("#{uri}/apps", headers)
datahash = JSON.parse(response.body)

found = false

datahash.each { |a|

    if a["label"].downcase == sTerm.downcase
        found = true
        idkey = a["id"]
    end
    
    break if found == true
}

if found == false
    puts "Application not found"
    exit
end

#idkey = datahash[0]["id"]
#puts idkey

#puts "#{uri}/groups/#{idkey}/users?limit=2"

response = http.get("#{uri}/apps/#{idkey}/users", headers)
datahash = JSON.parse(response.body)

datahash.each { |k| puts k["profile"]["email"] }
