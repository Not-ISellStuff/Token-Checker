require 'httpx'

#clear data
File.open("Data/good.txt", "w") do |f|
  nil
end
File.open("Data/bad.txt", "w") do |f|
  nil
end
File.open("Data/retry.txt", "w") do |f|
  nil
end

tokens_ = File.readlines("tokens.txt")

puts "Tokens: #{tokens_.size}"
puts


def check(token)
  r = HTTPX.get("https://discord.com/api/v9/premium-marketing", headers: {"Authorization"=>"#{token}"})
  if r.status == 200
    File.open("valid_tokens.txt", "a") do |hit|
      hit.write("#{token}\n")
    end
    File.open("Data/good.txt", "a") do |hit_|
      hit_.write("hit\n")
    end
    puts "[+] Valid Token"
  elsif r.status == 401
    puts "[-] Invalid Token"
    File.open("Data/bad.txt", "a") do |f|
      f.write("bad\n")
    end
  elsif r.status == 429
    File.open("Data/retry.txt", "a") do |re|
      re.write("ratelimited\n")
    end
    puts "[!] Rate Limited"
  else
    puts "[-] Invalid Token"
    File.open("Data/bad.txt", "a") do |f|
      f.write("bad\n")
    end
  end
    
end

tokens = File.readlines("tokens.txt")
for i in tokens
  check(i)
end
hits = File.readlines("Data/good.txt")
bad = File.readlines("Data/bad.txt")
fails = File.readlines("Data/retry.txt")

puts "\nStopped Checking | Results: Valid -> #{hits.size} | Invalid -> #{bad.size} | Requests Failed To Send: #{fails.size}\n Press Enter To Close > "
gets

