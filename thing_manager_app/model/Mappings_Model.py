
class Mappings_Model:
    def __init__(self, file_type):
        self.file_type = file_type
        self.validation_mapping = None
        self.translation_mapping = None
        self.td_mapping = None

    def get_mappings(self):
        if self.file_type == "construction":
            self.validation_mapping = "construction_shacl_validation"
            self.td_mapping = "construction_td_mapping"
        elif self.file_type == "image_metadata":
            self.validation_mapping = "image_metadata_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "point_cloud":
            self.validation_mapping = "point_cloud_metadata_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "process":
            self.validation_mapping = "process_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "process_model":
            self.translation_mapping = "process_model_to_rdf"
            self.validation_mapping = "process_model_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "qc":
            self.validation_mapping = "qc_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "qc_results":
            self.validation_mapping = "qc_results_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "resource":
            self.validation_mapping = "resource_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "rules":
            self.validation_mapping = "rules_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "safety":
            self.validation_mapping = "safety_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "tags":
            self.translation_mapping = "tags_to_rdf"
            self.validation_mapping = "tags_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "work_order":
            self.translation_mapping = "work_order_to_rdf"
            self.validation_mapping = "work_order_shacl_validation"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "xml_schedule":
            self.translation_mapping = "schedule_xml_to_rdf"
            self.td_mapping = "information_resource_td_mapping"
        elif self.file_type == "resource_types":
            self.translation_mapping = "resources_to_rdf"
            self.td_mapping = "information_resource_td_mapping"