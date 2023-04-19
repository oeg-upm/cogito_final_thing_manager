
<#assign json = file_info?eval>

{
    "@context": [
    "https://www.w3.org/2019/wot/td/v1",
    {
        "facility": "https://cogito.iot.linkeddata.es/def/facility#",
        "platform": "https://cogito.iot.linkeddata.es/def/platform#"
    }

    ],
    "title" : "[=json.project_name]",
    "id": "[=json.project_id]",
    "@type" : "facility:Project",
    "description": "[=json.project_description]", 
    "properties": {
        "platform:hasIRI": {
            "forms": [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/resources/project/[=json.project_id]",
                    "type": "text/turtle"
                }
            ]
        },
        "platform:hasKnowledgeGraph": {
            "forms": [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/resources/[=json.project_id]",
                    "type": "text/turtle"
                }
            ]
        }
    },
    "actions": {},
    "events": {},
    "links": [],
    "security": [
        "nosec_sc"
    ],
    "securityDefinitions": {
        "nosec_sc": {
            "scheme": "nosec"
        }
    }
    
}