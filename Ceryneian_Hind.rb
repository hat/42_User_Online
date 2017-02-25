require "oauth2"
require './access.rb'

# Create the client with your credentials
client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
# Get an access token
token = client.client_credentials.get_token

if ARGV[0]
	if File.file?(ARGV[0])
		# Open text file
		file = File.open(ARGV[0], "r")

		# Loop for every line in the file
		file.each_line do |line|

			# Remove newlines from every user login
			login = line.delete!("\n")

			if login
				begin
					response = token.get("/v2/users/#{login}/locations")
					if response.status == 200
						if !response.parsed[0]["end_at"]
							puts "#{login} : #{response.parsed[0]["host"]}"
						else
							puts "#{login} : not active in cluster"
						end
					else
						puts "Invalid response from server..."
					end
				rescue
					puts "#{login} : cannot find user"
				end
			end
		end
		file.close
	else
		puts "File not found"
	end
else
	puts "USAGE: ruby Ceryneian_hind.rb {filename}"
end
