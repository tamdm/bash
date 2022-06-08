
import requests, json, sys, re, time, warnings
warnings.filterwarnings("ignore")

import datetime

def setBootTarget():
    print("Setting temporary boot override to: {}".format(selection))
    payload = {'Boot': {'BootSourceOverrideTarget': selection}}
    headers = {'content-type': 'application/json'}
    response = requests.patch(url, data=json.dumps(payload), headers=headers, verify=False, auth=(idrac_username, idrac_password))
    systemData = response.json()


try:
    idrac_ip = sys.argv[1]
    idrac_username = sys.argv[2]
    idrac_password = sys.argv[3]

except:
    print("\n- FAIL, you must pass in script name along with iDRAC IP/iDRAC username/iDRAC password")
    sys.exit()

url = "https://%s/redfish/v1/Systems/System.Embedded.1" %idrac_ip

response = requests.get(url, verify=False, auth=(idrac_username, idrac_password))
systemData = response.json()
jsonString = systemData[u'Boot']['BootSourceOverrideTarget@Redfish.AllowableValues']

print("Please select a boot override option from the following list: \n")
#for entry in range(0, len(jsonString)):
for index in jsonString:
    print(index)
while True:
    print() 
    selection = input("\nBoot device: ")
    if selection not in jsonString:
        print("\nInvalid selection. Please enter a valid boot action (\"None\" is also valid).")
    else:
        setBootTarget()
        break

