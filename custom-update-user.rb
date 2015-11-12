#!/usr/bin/env ruby

#############################
#      Author : Brian Tilton
#        Date : 8/18/2015
#       Title : custom-update-user.rb
# Description : Script to update users' secondary email and phone number,
#               reset their password and multifactor, and reactivate them
#               in Okta via the API. 
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

uri = URI.parse("https://#{ADDRESS}/api/v1/users/")
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
    response = http.get("#{uri}#{email}",headers)
    datahash = JSON.parse(response.body)
    userID = datahash["id"]
    
    # Create user update hash
    userData = {
        "status" => "ACTIVE",
        "profile" => {
            "login" => "#{x[0]}",
            "secondEmail"  => "#{x[1]}",
            #"primaryPhone" => "#{x[2]}" #Commented out, phone not necessary
        },
        "credentials" => {
            "password" => "P@$ta27279"
        }
    }
    
    # Reactivate User
    puts "Reactivate"
    response = http.post2("#{uri}#{userID}/lifecycle"\
                          "/activate?sendEmail=FALSE",'',headers)
    puts response.body

    # Reset Multifactor
    puts "Reset MFA"
    response = http.post2("#{uri}#{userID}/lifecycle/reset_factors",'',headers)
    puts response.body

    # Update user in Okta
    puts "Update"
    response = http.post2("#{uri}#{userID}",JSON.generate(userData),headers)
    puts response.body
end
