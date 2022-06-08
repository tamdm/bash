import requests, json, sys, re, time, warnings
warnings.filterwarnings("ignore")

import datetime

def setPowerAction():
    url = "https://%s/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset" %idrac_ip
    payload = {'ResetType': selection}
    headers = {'content-type': 'application/json'}
    print("Executing power action: %s" %selection)
    #response = requests.port(url, data=json.dumps(payload), headers=headers, verify=False, auth=('vinahost','oPyhYttotM9WC0'))
    response = requests.post(url, data=json.dumps(payload), headers=headers, verify=False, auth=(idrac_username, idrac_password))



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
jsonString = systemData[u'Actions']['#ComputerSystem.Reset']['ResetType@Redfish.AllowableValues']

print("Please select a power action from the following list: \n")
#for entry in range(0, len(jsonString)):
for index in jsonString:
    print(index)
while True:
    print() 
    selection = input("Power action: ")
    if selection not in jsonString:
        print("\nInvalid selection. Please enter a valid power action.")
    else:
        setPowerAction()
        break

