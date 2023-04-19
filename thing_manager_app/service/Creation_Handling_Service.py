from ..controller.WoT_Hive_Controller import WoT_Hive_Controller
import uuid
import requests


class Creation_Handling_Service:
    def __init__(self, ts_host, ts_user, ts_pass, tdd_host, helio_host):
        self.ts_host = ts_host
        self.ts_user = ts_user
        self.ts_pass = ts_pass
        self.tdd_host = tdd_host
        self.helio_host = helio_host
        self.json_metadata = None
        self.rdf_mapping = "project_to_rdf"
        self.shape_uri = "project_shacl_validation"
        self.thing_description_mapping = "project_td"
        self.project_id = None

    def is_valid_uuid(self, value):
        try:
            uuid.UUID(value, version=4)
            return True
        except:
            return False

    def create_project(self, id, project_info):
        tdd_controller = WoT_Hive_Controller(self.tdd_host)
        self.json_metadata = project_info
        self.json_metadata['project_id'] = id
        self.project_id = id
        if not tdd_controller.get_td(id):
            if self.is_valid_uuid(id):
                print(str(self.json_metadata))
                # call mapping with ?json_metadata, ?rdf_mapping, ?shape_uri, ?thing_description_mapping, ?project_id
                url = self.helio_host + "api/project_controller/data?rdf_mapping=" + self.rdf_mapping + "&json_metadata=" + str(self.json_metadata) + "&shape_uri=" + self.shape_uri + "&thing_description_mapping=" + self.thing_description_mapping + "&project_id=" + self.project_id
                payload={}
                headers = {}

                response = requests.request("GET", url, headers=headers, data=payload)

                print(response.text)
            else:
                return "Invalid id, the id must be a valid uuid"
        else:
            return "Project already exists"
        return "Create project with id: " + id