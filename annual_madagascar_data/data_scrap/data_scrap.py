""" This file countains the main package, where all the functions are written"""
import pandas as pd
import requests
from bs4 import BeautifulSoup
import numpy as np
url = "https://weatherandclimate.com"
request = requests.get(url)
print(request.status_code)
def summary_scrap(town,month,year):
    request = requests.get(url + "/{}/{}-{}".format(town,month,year))
    soup = BeautifulSoup(request.text,"lxml")
    table = soup.find("table",{"class","tb8"}).find_all("td") 
    data = []
    def place(array,index,separator):
        storage = []
        for i in range(len(array)):
            storage.append((array[i].split(separator))[index])

        return storage
    
    for i in range(len(table)):
        if table[i].text != "":
            data.append(table[i].text)
    
    tx = place(data[1:4],0,"°C")
    t= place(data[5:8],0,"°C")
    tm = place(data[9:12],0,"°C")
    td = place(data[13:16],0,"°C")
    RR = place(data[17:20],0,"|")
    ff = place(data[27:30],1,"|")
    rf = place(data[31:34],0,"kmh")
    mslp = place(data[35:],0,"mb")
 

    df = pd.DataFrame({"max_temperature [°C]":tx,"avg_temperature [°C]":t,"min_temperature [°C]":tm,"dew_point [°C]":td,"RR [mm]":RR,"FF [kmh]":ff,"gust_wind[kmh]":rf,"mslp[mb]":mslp})
    df["RR [mm]"] = df["RR [mm]"].str.replace("mm"," ")
    df["FF [kmh]"] = df["FF [kmh]"].str.replace("kmh"," ")
    
    for i in range(len(df.columns)):
        df[(df.columns)[i]] = df[(df.columns)[i]].astype("float64")
    
    try:
        df.to_excel("summary:{}_{}_{}.xlsx".format(town,month,year),sheet_name="sheet1",index = False)
    except:
        pass
    
    return df

def daily_scrap(town,month,year):

    request = requests.get(url + "/{}/{}-{}".format(town,month,year))
    soup = BeautifulSoup(request.text,"lxml")
    table = soup.find("table",{"class","tb7"}).find_all("tr") 
    data = []

    def place(array,index,separator):
        storage = []
        for i in range(len(array)):
            storage.append((array[i].split(separator))[index])

        return storage
    
    for i in range(2,len(table)):
        if table[i].text != "":
            data.append(table[i].text.split("|"))

    data = np.array(data)  
    date = place(data[:,0],1,"\n")
    temperature = place(data[:,0],2,"\n")
    td = place(data[:,1],1,"\n")
    U = place(data[:,2],1,"\n")
    ff = place(data[:,2],2,"\n")
    P = place(data[:,4],0,"\n")
    RR = place(data[:,5],0,"\n")

    df = pd.DataFrame({"date":date,"temperature[°C]":temperature,"td[°C]":td,"Humidity[%]":U,"wind_speed[m/s]":ff,"Pressure[hPa]":P,"RR[mm]":RR})
    for i in range(1,len(df.columns)):
        df[(df.columns)[i]] = df[(df.columns)[i]].astype("float64")

    df["date"] = df["date"].astype("datetime64[ns]")
    try:
        df.to_excel("daily:{}_{}_{}.xlsx".format(town,month,year),sheet_name="sheet1",index = False)
    except:
        pass
    
    return df
    