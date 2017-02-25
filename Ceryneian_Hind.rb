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
			login = line.delete("\n")
			# Formats login output
			log_text = "#{login}"
			log_text = log_text.ljust(15)

			# Checks if login exists or was just newline
			if login != ""
				begin
					success = false
					# Runs until server responds
					until success
						response = token.get("/v2/users/#{login}/locations")
						if response.status == 200
							success = true
							# Checks if user ended session
							if !response.parsed[0]["end_at"]
								puts "#{log_text} : \e[32m#{response.parsed[0]["host"]}\e[0m"
							else
								puts "#{log_text} : \e[33mnot active in cluster\e[0m"
							end
						else
							puts "Server not responding...\e[0m"
							sleep 10
						end
					end
				rescue
					puts "#{log_text} : \e[31mcannot find user\e[0m"
				end
			end
		end
		file.close
	else
		puts "File not found"
	end
else
	puts "USAGE: ruby #{$0} {filename}"
end
