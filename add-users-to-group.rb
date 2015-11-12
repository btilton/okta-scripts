#!/usr/bin/env ruby

#############################
#      Author : Brian Tilton
#        Date : 8/18/2015
#       Title : add-users-to-group.rb
# Description : Script to add user from column 1 to group from column 2
#                 in specified CSV
#############################

require 'csv'
require 'json'
require 'net/http'


##### API Token and Subdomain #####
# Place your API Token as the first line of a file called api.token in the same
#   directory as this script. The second line of the file should be the
#   subdomain, domain, and TLD for your Okta account up to the TLD. For example
#   if your account is at https://example.okta.com/ the second line of the file
#   should be 'example.okta.com'
###################################

# Read API Token from file
APIFILE = File.readlines("#{File.dirname(__FILE__)}/api.token").each\
          {|f| f.chomp!}
APITOKEN = APIFILE[0]
ADDRESS = APIFILE[1]


##### Constant/Input Variables #####

csvFile = ARGV[0]
debug = false


##### Net Stuff #####

uri = URI.parse("https://#{ADDRESS}/api/v1/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

headers = {
    "Authorization" => "SSWS #{APITOKEN}",
    "Accept" => "application/json",
    "Content-Type" => "application/json"
}


##### Load CSV into Array of Arrays #####

csvAoA = CSV.read(csvFile)


##### Main Logic #####

# Step through array, skip first element
csvAoA[1..-1].each do |x|

    # Get user ID
    email = x[0]
    groupname = x[1]
    uresponse = http.get("#{uri}/users/#{email}",headers)
    udatahash = JSON.parse(uresponse.body)
    userID = udatahash["id"]
    puts userID

    # Get group ID
    gresponse = http.get("#{uri}/groups?q=#{groupname}&limit=",headers)
    gdatahash = JSON.parse(gresponse.body)
    groupID = gdatahash[0]["id"]
    puts groupID

    # Add user to group
    response = http.send_request('PUT',"#{uri}/groups/#{groupID}/users/#{userID}",'',headers)
end
