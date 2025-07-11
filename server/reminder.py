import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_gmail(to_email, subject, body):
    gmail_user = 'yesje1@khu.ac.kr'  
    gmail_password = 'ffhxjimuobmtlmzh'  

    msg = MIMEMultipart()
    msg['From'] = gmail_user
    msg['To'] = to_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(gmail_user, gmail_password)
        text = msg.as_string()
        server.sendmail(gmail_user, to_email, text)
        server.quit()
        print("✅ Email sent successfully.")
    except Exception as e:
        print(f"Failed to send email: {e}")

if __name__ == "__main__":
    send_gmail(
        to_email="yesje1@khu.ac.kr",
        subject="Your nail reservation is confirmed",
        body="See you at the nail studio!"
    )
