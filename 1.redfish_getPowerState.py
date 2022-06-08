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

url = "https://%s/redfish/v1/Systems/System.Embedded.1" %idrac_ip

response = requests.get(url, verify=False, auth=(idrac_username, idrac_password))
data = response.json()
power_state = data[u'PowerState']
print("Server {} power state is: {}", format(power_state))
