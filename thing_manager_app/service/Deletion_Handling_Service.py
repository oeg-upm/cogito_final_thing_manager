from ..controller.TripleStore_Controller import TripleStore_Controller
from ..controller.WoT_Hive_Controller import WoT_Hive_Controller

class Deletion_Handling_Service:
    def __init__(self, ts_host, ts_user, ts_pass, tdd_host):
        self.ts_host = ts_host
        self.ts_user = ts_user
        self.ts_pass = ts_pass
        self.tdd_host = tdd_host

    def delete_project(self, id):
        """
        Deletes an existing project, its respective triples and thing description, and also the thing descriptions associated to it in cascade mode
        """
        # Delete project triples
        try:
            ts_controller = TripleStore_Controller(None, id, self.ts_host, self.ts_user, self.ts_pass)
            ts_controller.delete_graph()
        except:
            pass

        try:
            tdd = WoT_Hive_Controller(self.tdd_host)
            td = tdd.get_td(id).json()
            if td['type'] == "https://cogito.iot.linkeddata.es/def/facility#Project":
                if "links" in td:
                    if td["links"] != []:
                        for link in td["links"]:
                            if link["rel"] =="platform:hasIfc":
                                ifc_id = link["href"].replace("http://data.cogito.iot.linkeddata.es/api/things/", "")
                                ifc_td = tdd.get_td(ifc_id).json()
                                for elem in ifc_td["links"]:
                                    tdd.delete_td(elem["href"].replace("http://data.cogito.iot.linkeddata.es/api/things/", ""))
                            tdd.delete_td(link["href"].replace("http://data.cogito.iot.linkeddata.es/api/things/", ""))
                tdd.delete_td(id)
            return "Delete project with id: " + id + " and all its associated thing descriptions."
        except:
            return "Project " + id + " does not exist."
        

        
    def delete_file_from_project(self, id, file_id):
        try:
            ts_controller = TripleStore_Controller(None, id, self.ts_host, self.ts_user, self.ts_pass, file_id=file_id)
            ts_controller.delete_graph()
            tdd = WoT_Hive_Controller(self.tdd_host)
            td = tdd.get_td(id).json()
            if td['type'] == "https://cogito.iot.linkeddata.es/def/facility#Project":
                if td["links"] != []:
                    for link in td["links"]:
                        if link["href"] ==  "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + file_id:
                            td["links"].remove(link)
            tdd.post_td(id, td)
            file_td = tdd.get_td(file_id)
            if file_td["title"] == "IFC File":
                if file_td["links"] != []:
                    for link in file_td["links"]:
                        tdd.delete_td(link["href"].replace("http://data.cogito.iot.linkeddata.es/api/things/", ""))
            tdd.delete_td(file_id)
            return "Delete file with id: " + file_id + " and related thing descriptions from project with id: " + id
        except:
            return "File " + file_id + " does not exist in project " + id + "."