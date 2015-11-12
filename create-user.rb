#!/usr/bin/env ruby
#############################
#      Author : Brian Tilton
#        Date : 8/18/2015
#       Title : create-user.rb
# Description : Script to create users in Okta via the API
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
debug = false

##### Net Stuff #####

uri = URI.parse("https://#{ADDRESS}/api/v1/users?activate=false")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

headers = {
    "Authorization" => "SSWS #{APITOKEN}",
    "Accept" => "application/json",
    "Content-Type" => "application/json"
}

##### Read Required Fields for New User #####

puts "Please Enter Information for New User."
puts "First Name:"
firstname = gets.chomp

puts "Last Name:"
lastname = gets.chomp

puts "Company Email Address:"
email = gets.chomp

puts "Secondary Email Address:"
secondemail = gets.chomp

login = email

# debug output fields entered by user
if debug
    puts firstname
    puts lastname
    puts email
    puts secondemail
    puts login
    puts mobilephone
end

##### Construct JSON Object #####
newuser = {
    "profile" => {
        "firstName"   => "#{firstname}",
        "lastName"    => "#{lastname}",
        "email"       => "#{email}",
        "secondEmail" => "#{secondemail}",
        "login"       => "#{login}"
    }
}

# debug output JSON to be sent
puts JSON.generate(newuser) if debug

# Send JSON to API
response = http.post(uri,JSON.generate(newuser),headers)

# Output response
if debug
    puts response.code
    puts response.body
end
