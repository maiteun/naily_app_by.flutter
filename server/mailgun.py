import os
import requests

def send_simple_message():
    res = requests.post(
        "https://api.mailgun.net/v3/sandboxaa6515823ed1418099c06863f2ebe5f4.mailgun.org/messages",
        auth=("api", os.getenv('c5ea400f-268fada7', 'c5ea400f-268fada7')),
      
        data={
            "from": "Mailgun Sandbox <postmaster@sandboxaa6515823ed1418099c06863f2ebe5f4.mailgun.org>",
            "to": "reservation nailstudio <yesje1@khu.ac.kr>",
            "subject": "your nail reservation is confirmed",
            "text": "see you at the nailstudio!"
        }
    )

    print(res.status_code)
    print(res.text)

send_simple_message()
