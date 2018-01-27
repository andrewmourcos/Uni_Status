#!/usr/local/bin/python3
import requests, lxml.html
from bs4 import BeautifulSoup as soup

# specify login url
login_url = 'https://www.ouac.on.ca/apply/secondary/en_CA/user/login'

# begin network session with requests
s = requests.session()
# retrieve page for login from url
login = s.get(login_url)

# find csrf token and adding to "form"
login_html = lxml.html.fromstring(login.text)
hidden_inputs = login_html.xpath(r'//form//input[@type="hidden"]')
form = {x.attrib["name"]: x.attrib["value"] for x in hidden_inputs}

# adding other credentials to form
form['login'] = 'username here'
form['password'] = 'password here'

# post credentials for login
response = s.post(login_url, data=form)

# Collect URL with offers
offer_url = 'https://www.ouac.on.ca/apply/secondary/en_CA/program/index'
offer_page = s.get(offer_url)
# text to soup
offer_soup = soup(offer_page.text, "lxml")

# Gather tables
table = offer_soup.table
table_rows = table.find_all('tr')

# Look for Offer string in each row
# If true print accepted to University
# If false print pending
for tr in table_rows:
    td = tr.find_all('td')
    row = [i.text for i in td]

    if any("Offer" in s for s in row):
        name = row[4][0:50]  # limiting program name to 50 characters (visually appealing)
        print("(Accepted)", name)
    elif "\n" in row:
        name = row[4][0:50]  # limiting program name to 50 characters (visually appealing)
        print("(Pending)", name)