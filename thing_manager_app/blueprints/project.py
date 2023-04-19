from flask import Blueprint, request, render_template
from ..service.Deletion_Handling_Service import Deletion_Handling_Service
from ..service.Creation_Handling_Service import Creation_Handling_Service
from ..controller.WoT_Hive_Controller import WoT_Hive_Controller
import os


# GET ENVIROMENT VARIABLES CONFIGURATION
ts_host = os.environ.get('TS_HOST')
ts_user = os.environ.get('TS_USER')
ts_pass = os.environ.get('TS_PASS')
tdd_host = os.environ.get('TDD_HOST')
helio_host = os.environ.get('HELIO')


project = Blueprint('project', __name__)

@project.route('/project/<id>', methods=['POST'])
def create_project(id):
    """
    Creates a new project, its respective triples and thing description, comes with a json file format
    """
    if request.method == 'POST':
        wot_hive_controller = WoT_Hive_Controller(tdd_host)
        response = wot_hive_controller.get_td(id)
        if response.status_code == 200:
            return "Project alrady exists", 400
        project_info = request.get_json()
        print(project_info)
        creation_service = Creation_Handling_Service(ts_host, ts_user, ts_pass, tdd_host, helio_host)
        creation_service.create_project(id, project_info)

    return "Project created"

@project.route('/project/<id>', methods=['DELETE'])
def delete_project(id):
    """
    Deletes an existing project, its respective triples and thing description, and also the thing descriptions associated to it in cascade mode
    NO PROJECTS WILL BE DELETED
    """
    if request.method == 'DELETE':
        deletion_service = Deletion_Handling_Service(ts_host, ts_user, ts_pass, tdd_host)
        result = deletion_service.delete_project(id)
        return result
    else:
        return "Method not allowed", 405