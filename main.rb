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

puts "Do You Want To Use Proxies? Y/n > "
proxy = gets.chomp()

if proxy == "Y"
  def scraped
    f = File.readlines("proxies.txt")
    puts "Scraped #{f.size} proxies."
  end

  r = HTTPX.get("https://api.proxyscrape.com/v3/free-proxy-list/get?request=displayproxies&protocol=http&proxy_format=ipport&format=text&timeout=20000")
  body = r.body.to_s
  File.open("proxies.txt", "w") do |p|
    body.split("\n").each do |line|
      p.write(line.strip + "\n")
    end
  end
  scraped()
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

