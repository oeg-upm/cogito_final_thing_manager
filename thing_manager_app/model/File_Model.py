import requests
import uuid
import hashlib

class File_Model:
    def __init__(self, file_url, file_type, file_id=None):
        self.file_url = file_url
        self.file_type = file_type
        self.file_id = file_id
    
    def get_file(self):
        response = requests.get(self.file_url)
        return response
    
    def get_file_id(self):
        if self.file_id is None:
            self.file_id = hashlib.sha256(self.file_url.encode('utf-8')).hexdigest()
        else:
            if not self.is_valid_uuid(self.file_id):
                return False
            else:
                return True
            
    def is_valid_uuid(self, value):
        try:
            uuid.UUID(value, version=4)
            return True
        except:
            return False