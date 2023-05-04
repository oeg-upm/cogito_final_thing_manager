from flask import Blueprint, request, render_template
from ..service.Deletion_Handling_Service import Deletion_Handling_Service
from ..service.Schedule_Preprocessing_Service import Schedule_Pre_Service
from ..controller.Helio_Controller import Helio_Controller
from ..controller.TripleStore_Controller import TripleStore_Controller
from ..controller.WoT_Hive_Controller import WoT_Hive_Controller
from ..model.Mappings_Model import Mappings_Model
import os
import json
from ..model.File_Model import File_Model
import sys
sys.stdout.flush()

# GET ENVIROMENT VARIABLES CONFIGURATION
ts_host = os.environ.get('TS_HOST')
ts_user = os.environ.get('TS_USER')
ts_pass = os.environ.get('TS_PASS')
tdd_host = os.environ.get('TDD_HOST')
helio_host = os.environ.get('HELIO')


file_blu = Blueprint('file_blu', __name__)

@file_blu.route('/project/<id>/file', methods=['POST'])
def add_file_to_project(id):
    """
    Receives a file and tranlsate it to rdf, adds it to the project, validates, save triples and generated and save thing description
    """
    if request.method == 'POST':
        wot_hive_controller = WoT_Hive_Controller(tdd_host)
        response = wot_hive_controller.get_td(id)
        project_td = json.loads(response.text)
        if response.status_code != 200:
            return "Project not found", 404
        # get data
        file_json = request.data.decode('utf-8')
        file_json = json.loads(file_json)
        # create file model
        if "file_id" in file_json:
            file_url = "https://dtp.cogito-project.com/file/" + file_json["file_id"] + "/download"
            file_model = File_Model(file_url, file_json["file_type"], file_json["file_id"])
            # analyse if file_id is correct
            if not file_model.get_file_id():
                return "Error file_id is not a valid UUID", 400
            response = file_model.get_file()
            if response.status_code != 200:
                return "Not able to download file", 400
            file_data = response.text
        elif "file_url" in file_json:
            file_model = File_Model(file_json["file_url"], file_json["file_type"])
            # create file_id
            file_model.get_file_id()
            response = file_model.get_file()
            if response.status_code != 200:
                return "Not able to download file", 400
            file_data = response.text
        else:
            return "Error, file_id or file_url not found", 400

        if file_model.file_type == "xml_schedule":
            # preprocess
            #try:
            schedule_pre_service = Schedule_Pre_Service(id)
            schedule_pre_service.preprocessing(file_data)
            #except:
            #    return "Error preprocessing file", 400
            file_data = schedule_pre_service.final_tree

        # create helio controller
        helio_controller = Helio_Controller(id, file_model.file_id, file_data, helio_host, rdf=False)
        # creamos el mapping del fichero
        helio_controller.create_task()

        # retrieve file from helio
        task= id + "_" + file_model.file_id
        #helio_controller.retrieve_task(task)
        # get mappings models
        mappings = Mappings_Model(file_model.file_type)
        mappings.get_mappings()
        
        # generate rdf
        extra = "?mapping_url=" + task + "&project_id=" + id + "&file_url=" + file_model.file_url
        helio_controller.retrieve_task(mappings.translation_mapping, extra)
        helio_controller.rdf = True
        helio_controller.ttl = helio_controller.res
        helio_controller.create_task()
        task= id + "_" + file_model.file_id + "_rdf"
        # save triples
        triplestore_controller = TripleStore_Controller(helio_controller.res, id, ts_host, ts_user, ts_pass, file_model.file_id)
        triplestore_controller.serialize_graph()

        if len(triplestore_controller.graph) > 1500000:
            triplestore_controller.chunk_string(triplestore_controller.graph, 5000)
        else:
            try:
                triplestore_controller.create_graph()
            except:
                helio_controller.delete_task()
                helio_controller.rdf = False
                helio_controller.delete_task()
                return "Error saving triples", 500
        # generate Thing Descriptions
        extra = "?rdf_mapping=" + task + "&project_id=" + id + "&file_id=" + file_model.file_id + "&file_type=" + file_model.file_type
        try:
            helio_controller.retrieve_task(mappings.td_mapping, extra)
        except:
            helio_controller.delete_task()
            helio_controller.rdf = False
            helio_controller.delete_task()
            return "Error generating Thing Description", 500
        thing_descriptions = json.loads(helio_controller.res)
        information_resource_td = thing_descriptions[0]["id"]
        # update project thing description
        if "links" not in project_td:
            project_td['links'] = [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + information_resource_td,
                    "rel": "platform:relatedTD",
                    "type": "application/td+json"
                }
            ]
        else:
            flag = [True for link in project_td['links'] if link['href'] == "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + information_resource_td]
            if True not in flag:
                project_td['links'].append(
                    {
                        "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + information_resource_td,
                        "rel": "platform:relatedTD",
                        "type": "application/td+json"
                    }
                )
        if "security" not in project_td:
            project_td['security'] = [
                "nosec_sc"
            ]
        # save project thing descriptions in tdd
        response = wot_hive_controller.put_td(id, project_td)
        if response.status_code > 299:
            helio_controller.delete_task()
            helio_controller.rdf = False
            helio_controller.delete_task()
            return response.text, response.status_code
        # save information resources and digital twins thing descriptions in tdd
        try:
            for td in thing_descriptions:
                if "security" not in td:
                    td['security'] = [
                        "nosec_sc"
                    ]
                response = wot_hive_controller.put_td(td["id"], td)
                if response.status_code > 299:
                    helio_controller.delete_task()
                    helio_controller.rdf = False
                    helio_controller.delete_task()
                    return response.text, response.status_code
        except:
            helio_controller.delete_task()
            return "Error updating information resources and digital twins thing descriptions", 500
        #remove mapping from helio pertaining to the ttl file
        helio_controller.delete_task()
        helio_controller.rdf = False
        helio_controller.delete_task()

        return "File added to project " + id + " with file_id " + file_model.file_id, 201
    else:
        return "Method not allowed", 405



@file_blu.route('/project/<id>/ttl/<file_type>/<file_id>', methods=['POST'])
def add_ttl_to_project(id, file_type, file_id):
    """
    Receives a ttl file and adds it to the project, validates, save triples and generated and save thing description
    """
    if request.method == 'POST':
        # call wot-hive controller
        wot_hive_controller = WoT_Hive_Controller(tdd_host)
        response = wot_hive_controller.get_td(id)
        project_td = json.loads(response.text)
        if response.status_code != 200:
            return "Project not found", 404
        # create project info triple
        project_info_triple = '''\n
        @prefix project: <http://data.cogito.iot.linkeddata.es/resources/project/> .
        @prefix facility: <https://cogito.iot.linkeddata.es/def/facility#> .
        @prefix platform: <https://cogito.iot.linkeddata.es/def/platform#> .
        
        project:''' + id + '''
            a   facility:Project ;
            platform:hasFileURL "https://dtp.cogito-project.com/file/''' + file_id + '''/download"  .
        '''
        # get ttl file
        ttl = request.data.decode('utf-8') + project_info_triple
        # create helio controller
        helio_controller = Helio_Controller(id, file_id, ttl, helio_host, rdf=True)
        # create helio task
        helio_controller.create_task()
        # retrieve file from helio
        task= id + "_" + file_id + "_rdf"
        #helio_controller.retrieve_task(task)
        # get mappings models
        mappings = Mappings_Model(file_type)
        mappings.get_mappings()
        # validate file
        extra = "?rdf_mapping=" + task + "&shape_uri=" + mappings.validation_mapping
        try:
            helio_controller.retrieve_task("file_shacl_validation", extra)
        except:
            helio_controller.delete_task()
            return "Error validating knowledge graph", 500
        if helio_controller.res.replace("\n", "") != "True":
            return "TTL file not valid" + helio_controller.res, 400
        # save triples
        triplestore_controller = TripleStore_Controller(ttl, id, ts_host, ts_user, ts_pass, file_id)
        triplestore_controller.serialize_graph()

        if len(triplestore_controller.graph) > 1500000:
            triplestore_controller.chunk_string(triplestore_controller.graph, 5000)
        else:
            try:
                triplestore_controller.create_graph()
            except:
                helio_controller.delete_task()
                return "Error saving triples", 500
        # generate Thing Descriptions
        extra = "?rdf_mapping=" + task + "&project_id=" + id + "&file_id=" + file_id + "&file_type=" + file_type
        try:
            helio_controller.retrieve_task(mappings.td_mapping, extra)
        except:
            helio_controller.delete_task()
            return "Error generating Thing Description", 500
        thing_descriptions = json.loads(helio_controller.res)
        information_resource_td = thing_descriptions[0]["id"]
        # update project thing description
        if "links" not in project_td:
            project_td['links'] = [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + information_resource_td,
                    "rel": "platform:relatedTD",
                    "type": "application/td+json"
                }
            ]
        else:
            flag = [True for link in project_td['links'] if link['href'] == "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + information_resource_td]
            if True not in flag:
                project_td['links'].append(
                    {
                        "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/" + information_resource_td,
                        "rel": "platform:relatedTD",
                        "type": "application/td+json"
                    }
                )
        if "security" not in project_td:
            project_td['security'] = [
                "nosec_sc"
            ]
        # save project thing descriptions in tdd
        response = wot_hive_controller.put_td(id, project_td)
        if response.status_code > 299:
            helio_controller.delete_task()
            return response.text, response.status_code
        # save information resources and digital twins thing descriptions in tdd
        try:
            for td in thing_descriptions:
                if "security" not in td:
                    td['security'] = [
                        "nosec_sc"
                    ]
                response = wot_hive_controller.put_td(td["id"], td)
                if response.status_code > 299:
                    helio_controller.delete_task()
                    return response.text, response.status_code
        except:
            helio_controller.delete_task()
            return "Error updating information resources and digital twins thing descriptions", 500
        #remove mapping from helio pertaining to the ttl file
        helio_controller.delete_task()
        return "TTL added to project " + id + " with file_id " + file_id, 201
    else:
        return "Method not allowed", 405
    



@file_blu.route('/project/<id>/file/<file_id>', methods=['DELETE'])
def delete_file_from_project(id, file_id):
    """
    Deletes file from project and its respective triples and thing descriptions
    Update parent project thing description removing the td link from links
    """
    if request.method == 'DELETE':
        deletion_service = Deletion_Handling_Service(ts_host, ts_user, ts_pass, tdd_host)
        result = deletion_service.delete_file_from_project(id, file_id)
        return result
    else:
        return "Method not allowed", 405