from logging import root
import xml.etree.ElementTree as ET
import xml.dom.minidom
import os

class Schedule_Pre_Service:
    def __init__(self, project_id):
        self.__ns = '{http://schemas.microsoft.com/project}'
        self.__project_id = project_id # Add as an additional functionality
        self.__process_id = None
        self.__tree = None
        self.__root = None
        self.__tasks = None
        self.__task_list = None
        self.__childs_to_remove = ["Views", "Filters", "Groups", "Tables", "Maps",
                                    "Reports", "Drawings", "DataLinks", "VBAProjects",
                                    "OutlinesCodes", "WBSMasks", "ExtendedAttributes",
                                    "Calendars", "Resources", "Assignments", "BoardColumns", "Sprints"]
        self.final_tree = None
        

    def preprocessing(self, file_data):
        ET.register_namespace('', 'http://schemas.microsoft.com/project')
        self.__tree = ET.fromstring(file_data)
        self.__root = self.__tree
        self.__get_process_id()
        self.__remove_childs()
        self.__tasks = self.__tree.find(self.__ns + 'Tasks')
        self.__task_list = self.__tasks.findall(self.__ns + 'Task')
        self.__add_project_id()
        self.__annidate(1)
        self.__save_tree()
    
    def __get_process_id(self):
        self.__process_id = self.__root.find(self.__ns + 'GUID').text

    def __remove_childs(self):
        for child in self.__childs_to_remove:
            if self.__root.find(self.__ns + child):
                self.__root.remove(self.__root.find(self.__ns + child))
        

    def __compare(self, l1, l2):
        result = all(map(lambda x, y: x == y, l1, l2))
        return result and len(l1) == len(l2)
    
    def __generate_tree_values(self, father, child):
        for task in self.__task_list:
            if task.find(self.__ns + 'WBS').text == father[1]:
                childs_node = None
                if not task.find(self.__ns + 'Childs'):
                    childs_node = ET.SubElement(task, self.__ns + "Childs")
                else:
                    childs_node = task.find(self.__ns + 'Childs')
                child_element = ET.SubElement(childs_node, self.__ns + "WBS")
                if not child_element.text == child:
                    child_element.text = child[0]
            if task.find(self.__ns + 'WBS').text == child[1]:
                if not task.find(self.__ns + 'Parent_WBS'):
                    parent_node = ET.SubElement(task, self.__ns + "Parent_WBS")
                    parent_node.text = father[0]

    def __iterate_lists(self, father_list, child_list):
        for father in father_list:
            for child in child_list: # Here goes the function
                father_split = father[1].split('.')
                child_split = child[1].split('.')[:-1]
                flag = self.__compare(child_split, father_split)
                if flag and len(child_split) == len(father_split):
                    # Save father in list of fathers that have children
                    self.__generate_tree_values(father, child)

    def __annidate(self, counter):
        father_list = []
        child_list = []

        for task in self.__task_list:
            wbs = task.find(self.__ns + 'WBS').text
            task_UID = task.find(self.__ns + 'UID').text
            task_identifier =self.__project_id + "_" + self.__process_id + "_" + task_UID
            task_element = [task_identifier,wbs]
            if len(wbs.split('.')) == counter:
                father_list.append(task_element)
            elif len(wbs.split('.')) > counter:
                child_list.append(task_element)
        
        if child_list == []:
            return
        else:
            counter += 1
            self.__iterate_lists(father_list, child_list)
            self.__annidate(counter)

    def __add_project_id(self):
        project_id = ET.SubElement(self.__root, self.__ns + "Final_Project_ID")
        project_id.text = self.__project_id


    def __save_tree(self):
        save_tree = ET.tostring(self.__root, encoding='utf-8', method='xml')
        # Se puede acelerar el proceso poniendo esto directamente pero no se pone bonito
        # tree.write('new.xml', encoding='utf-8', method='xml')
        dom = xml.dom.minidom.parseString(save_tree)
        pretty_xml = dom.toprettyxml()
        pretty_xml = os.linesep.join([s for s in pretty_xml.splitlines() if s.strip()])
        self.final_tree = pretty_xml
        # with open('./repository/schedule/files/file.xml', 'w') as f:
        #     f.write(pretty_xml)
        # f.close()