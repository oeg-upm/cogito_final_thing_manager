import requests
import json

class Helio_Controller:
    def __init__(self, project_id, file_id, ttl, helio_host, rdf=None):
        self.helio_endpoint = helio_host
        self.task = "api/" + project_id + "_" + file_id
        self.ttl = ttl
        self.project_id = project_id
        self.file_id = file_id
        self.rdf = rdf
        self.res = None

    def create_task(self):
        if self.rdf:
            url = self.helio_endpoint + self.task + "_rdf"
        else:
            url = self.helio_endpoint + self.task
        payload = self.ttl
        headers = {
            'Content-Type': 'text/plain'
        }
        try:
            print("Creating Helio Task")
            response = requests.request("POST", url, headers=headers, data=payload)
            print("Helio Task Created")
        except:
            print("Error creating task")

    def retrieve_task(self, task, extra=""):
        url = self.helio_endpoint + "api/" + task + "/data" + extra
        payload={}
        headers = {}

        try:
            print("Retrieving Helio Task")
            response = requests.request("GET", url, headers=headers, data=payload)
            print("Helio Graph Task Retrieved")
            self.res = response.text
        except:
            print("Error retrieving file from helio")

    def delete_task(self):
        if self.rdf:
            url = self.helio_endpoint + self.task + "_rdf"
            headers = {
                'Content-Type': 'text/plain'
            }
            try:
                print("Deleting Helio Task")
                response = requests.request("DELETE", url, headers=headers)
                print("Helio Task Deleted")
            except:
                print("Error deleting task")
        else:
            url = self.helio_endpoint + self.task
            headers = {
                'Content-Type': 'text/plain'
            }
            try:
                print("Deleting Helio Task")
                response = requests.request("DELETE", url, headers=headers)
                response = requests.request("DELETE", url + "_rdf", headers=headers)
                print("Helio Task Deleted")
            except:
                print("Error deleting task")