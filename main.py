import requests, queue, threading, os
from datetime import datetime
from colorama import Fore

#-----------------------------------------------#

blue = Fore.BLUE
green = Fore.GREEN
red = Fore.RED
yellow = Fore.YELLOW

#-----------------------------------------------#

class Data:
    def __init__(self, hits, fails, ratelimited):
        self.hits = hits
        self.fails = fails
        self.ratelimited = ratelimited

data = Data(0, 0, 0)

class Checker:
    def __init__(self, threads: int):
        self.threads = threads

    def checker(self):
        with open("tokens.txt", "r", encoding="utf-8") as f:
            tokens = f.readlines()
        q = queue.Queue()
        for i in tokens:
            tk = i.strip()
            q.put(tk)

        def check(q):
            while not q.empty():
                try:
                    token = q.get()
                    r = requests.get("https://discord.com/api/v9/users/@me/billing/country-code", headers={"Authorization": token})

                    if r.status_code == 200:
                        self.writehit(token)
                        data.hits += 1
                        print(green + f"[ {self.timestamp()} ] | [+] Valid Token")
                    elif r.status_code == 429:
                        data.ratelimited += 1
                        print(yellow + f"[ {self.timestamp()} ] | [!] Rate Limited")
                    else:
                        data.fails += 1
                        print(red + f"[ {self.timestamp()} ] | [-] Invalid Token")

                except:
                    data.fails += 1
                    print(yellow + f"[ {self.timestamp()} ] | [-] Invalid Token")

        num_threads = int(self.threads)
        threads = []
        for i in range(num_threads):
            t = threading.Thread(target=check, args=(q,))
            threads.append(t)
            t.start()
        for t in threads:
            t.join()

    #----- Other Stuff -----#

    def timestamp(self):
        cts = datetime.now()
        pretty = cts.strftime("%Y-%m-%d %H:%M:%S")
        return pretty
    
    def writehit(self, token):
        with open("valid.txt", "a", encoding="utf-8") as f:
            f.write(f"{token}\n")

#-----------------------------------------------#

def main():
    os.system("cls")
    
    tokens = len(open("tokens.txt", "r", encoding="utf-8").readlines())
    threads = int(input(blue + "Threads: "))
    os.system("cls")
    input(blue + f"Tokens: {tokens} | Thread: {threads} | Press Enter To Start > ")
    print()

    checker = Checker(threads)
    checker.checker()

    input(blue + f"\nValid Tokens: {data.hits} | Invalid Tokens: {data.fails} | Rate Limited: {data.ratelimited} | Press Enter To Close > ")

#-----------------------------------------------#

if __name__ == "__main__":
    main()