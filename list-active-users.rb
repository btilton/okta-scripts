#!/usr/bin/env ruby

#############################
#      Author : Brian Tilton
#        Date : 10/26/2015
#       Title : list-active-users.rb
# Description : Script to list all active users in Okta.
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

# Read API Token from file
APIFILE = File.readlines("#{File.dirname(__FILE__)}/api.token").each\
          {|f| f.chomp!}
APITOKEN = APIFILE[0]
ADDRESS = APIFILE[1]


##### Net Stuff #####

$GURI = URI.parse("https://#{ADDRESS}/api/v1/users/")
$GHTTP = Net::HTTP.new($GURI.host, $GURI.port)
$GHTTP.use_ssl = true

headers = {
    "Authorization" => "SSWS #{APITOKEN}",
    "Accept" => "application/json",
    "Content-Type" => "application/json"
}


##### Methods #####

def HttpGetLinkBody (uri,headers)
    response = $GHTTP.get("#{uri}",headers)
    
    ### Get pagination links
    links = Hash.new
    parts = response["link"].split(',')

    parts.each do |part, index|
        section = part.split(';')
        url = section[0][/<(.*)>/,1]
        name = section[1][/rel="(.*)"/,1].to_sym
        links[name] = url
    end

    datahash = JSON.parse(response.body)

    return links,datahash
end


##### MAIN #####

### Get initial data set and first page link
links = HttpGetLinkBody("#{$GURI}?limit=200",headers)
links[1].each { |x| puts x["profile"]["login"] }

### Page through data until no next page link
until links[0][:next].nil?
    links = HttpGetLinkBody(links[0][:next],headers)
    links[1].each { |x| puts x["profile"]["login"] }
end
