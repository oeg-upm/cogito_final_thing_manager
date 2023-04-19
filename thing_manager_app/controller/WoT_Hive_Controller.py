import requests
import json

class WoT_Hive_Controller():
    def __init__(self, wot_hive_url):
        self.wot_hive_url = wot_hive_url
        self.predetermined_td = None



    def get_td(self, id): # get thing description with provided id
        url = self.wot_hive_url + "api/things/" + id
        payload={}
        headers = {
        'Content-Type': 'application/td+json'
        }
        response = requests.request("GET", url, headers=headers, data=payload)
        return response



    def put_td(self, id, td):
        url = self.wot_hive_url + "api/things/" + id
        payload = json.dumps(td)
        #payload = td
        headers = {
        'Content-Type': 'application/td+json'
        }
        response = requests.request("PUT", url, headers=headers, data=payload)
        return response



    def delete_td(self, id):
        url = self.wot_hive_url + "api/things/" + id
        payload={}
        headers = {
        'Content-Type': 'application/td+json'
        }
        response = requests.request("DELETE", url, headers=headers, data=payload)
        return response.text
