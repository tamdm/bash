import requests, json, sys, re, time, warnings
warnings.filterwarnings("ignore")

import datetime

try:
    idrac_ip = sys.argv[1]
    idrac_username = sys.argv[2]
    idrac_password = sys.argv[3]

except:
    print("\n- FAIL, you must pass in script name along with iDRAC IP/iDRAC username/iDRAC password")
    sys.exit()

url = "https://%s/redfish/v1/Chassis/System.Embedded.1" %idrac_ip

response = requests.get(url, verify=False, auth=(idrac_username, idrac_password))
systemData = response.json()
jsonString = systemData[u'Links'][u'CooledBy']

for entry in range(0, len(jsonString)):
    fan = systemData[u'Links'][u'CooledBy'][entry]['@odata.id']
    fanURL = 'https://%s%s' %(idrac_ip, fan)
    response = requests.get(fanURL, verify=False, auth=(idrac_username, idrac_password))
    fanData = response.json()
    print("{} running at {} rpm".format(fanData[u'FanName'], fanData[u'Reading']))
    


