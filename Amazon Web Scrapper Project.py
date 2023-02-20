#!/usr/bin/env python
# coding: utf-8

# In[8]:


#import libraries

from bs4 import BeautifulSoup
import requests
import time
import datetime

import smtplib


# In[37]:


# Connect to Website and pull in data

URL = 'https://www.amazon.com.au/Bose-QuietComfort-Cancelling-Headphones-Microphone/dp/B098FKXT8L/ref=sr_1_4?crid=1S0JUEV0TONLC&keywords=bose+quietcomfort+35&qid=1676851253&s=electronics&sprefix=%2Celectronics%2C207&sr=1-4'


# set the user agent in headers to avoid getting blocked

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 OPR/94.0.0.0"}


# make a GET request to the URL
page = requests.get(URL, headers=headers)

# create a BeautifulSoup object 
soup1 = BeautifulSoup(page.content, "html.parser")

# prettify the BeautifulSoup object and create a new one
soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

# find the price element by its class
price_element = soup2.find('span', {'class': 'a-price-whole'})

# get the text of the price element
price_text = price_element.get_text()

# remove any non-numeric characters from the price text and convert to float
price = float(''.join(filter(str.isdigit, price_text))) 

# find the title element by its ID
title_element = soup2.find('span', {'id': 'productTitle'})

# get the text of the title element
title = title_element.get_text().strip()

# print the title and price
print(f'{title}')
print(f'${price:.2f}')






# In[38]:


import datetime

today = datetime.date.today()

print(today)


# In[39]:


import csv

#convert output(string) to list
header = ['Title', 'Price', 'Date']
data = [title,price,today]

#write data to csv file

with open('AmazonWebScraperDataset.csv', 'w', newline='',encoding =' UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)


# In[41]:


import pandas as pd

#read csv file

df = pd.read_csv(r'C:\Users\Owner\AmazonWebScraperDataset.csv')

#print data frame

print(df)


# In[42]:


#append data to CSV

with open('AmazonWebScraperDataset.csv', 'a+', newline='',encoding =' UTF8') as f:
    writer = csv.writer(f) 
    writer.writerow(data)


# In[45]:


#Automating, combining into one function



def check_price():
    # Connect to Website and pull in data
    URL = 'https://www.amazon.com.au/Bose-QuietComfort-Cancelling-Headphones-Microphone/dp/B098FKXT8L/ref=sr_1_4?crid=1S0JUEV0TONLC&keywords=bose+quietcomfort+35&qid=1676851253&s=electronics&sprefix=%2Celectronics%2C207&sr=1-4'

    # set the user agent in headers to avoid getting blocked
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 OPR/94.0.0.0"}

    # make a GET request to the URL
    page = requests.get(URL, headers=headers)

    # create a BeautifulSoup object 
    soup1 = BeautifulSoup(page.content, "html.parser")

    # prettify the BeautifulSoup object and create a new one
    soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

    # find the price element by its class
    price_element = soup2.find('span', {'class': 'a-price-whole'})

    # get the text of the price element
    price_text = price_element.get_text()

    # remove any non-numeric characters from the price text and convert to float
    price = float(''.join(filter(str.isdigit, price_text))) 

    # find the title element by its ID
    title_element = soup2.find('span', {'id': 'productTitle'})

    # get the text of the title element
    title = title_element.get_text().strip()

    # get today's date
    today = datetime.date.today()

    # create a dataframe with the extracted data
    header = ['Title', 'Price', 'Date']
    data = [title,price,today]

    # write data to csv file
    with open('AmazonWebScraperDataset.csv', 'a', newline='',encoding =' UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)
        
    #send email if below target price
    if (price < 250):
        send_mail()


# In[ ]:


#Set time of day 24hr format
run_time = datetime.time(9,0,0) #9:00am

while True:
    now = datetime.datetime.now().time()
    if now > run_time:
        check_price()
        time.sleep(86400) # wait for 24 hours (in seconds)
    else:
        time.sleep(60) # wait for 1 minute


# In[51]:


import pandas as pd

#read csv file

df = pd.read_csv(r'C:\Users\Owner\AmazonWebScraperDataset.csv')

#print data frame

print(df)


# In[ ]:


def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com',465)
    server.ehlo()
    #server.starttls()
    server.ehlo()
    server.login('jamescaosydney123@gmail.com','xxxxxxxxxxxxxx') #the 2nd argument is where you add your password
    
    subject = "The headphones you want is $250! Now is your chance to buy!"
    body = "James, Now is your chance to pick up the headphones of your dreams. Don't cheat yourself, treat yourself! Link here: https://www.amazon.com.au/Bose-QuietComfort-Cancelling-Headphones-Microphone/dp/B098FKXT8L/ref=sr_1_5?crid=9GTJPGCCU490&keywords=Bose%2BNoise%2BCancelling%2BHeadphones%2B700%2Bvs%2B35&qid=1676849433&s=electronics&sprefix=bose%2Bnoise%2Bcancelling%2Bheadphones%2B700%2Bvs%2B35%2Celectronics%2C333&sr=1-5&th=1"
   
    msg = f"Subject: {subject}\n\n{body}"
    
    server.sendmail(
        'jamescaoysydney123@gmail.com',
        msg
     
    )

