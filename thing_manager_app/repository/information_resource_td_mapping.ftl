<#assign jpath=handlers("JsonHandler")>
<#assign rdf_uri = "http://localhost:4567/api/" + rdf_mapping + "/data">
<#attempt>
<#assign get_rdf>
{
            "method": "GET",
            "url": "[=rdf_uri]",
            "body":""
}
</#assign>
<#assign rdf=providers("HttpProvider", get_rdf)>
<#recover>
500, Error retrieving RDF
</#attempt>
<#assign query>
PREFIX platform:<https://cogito.iot.linkeddata.es/def/platform#>
PREFIX qual:<https://cogito.iot.linkeddata.es/def/quality#>
SELECT ?s ?type ?file_format ?file_url WHERE {
    ?s a ?type .
    ?s platform:hasFileURL ?file_url .
}
</#assign>
<#assign thing_description>
[
{
    "@context": [
    "https://www.w3.org/2019/wot/td/v1",
    {
        "qual": "https://cogito.iot.linkeddata.es/quality#",
        "platform": "https://cogito.iot.linkeddata.es/def/platform#"
    }
    ],
    "title" : "[=file_type] Information Resource Thing Description",
    "id": "[=file_id]",
    "@type" : "qual:InformationResource",
    "description": "[=file_type] Information Resource in project [=project_id]", 
    "properties": {
        "platform:hasKnowledgeGraph": {
            "forms": [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/resources/[=project_id]/[=file_id]",
                    "type": "text/turtle"
                }
            ]
        }
<#assign config = '{"query" : "'+query+'" }'>
<@action type="SparqlEngine" data=rdf conf=config; result>
<#list jpath.filter("$.*",result) as res>
<#if res?contains("bindings")>
<#if jpath.filter("$.bindings",res)?is_sequence>
        ,
        "platform:hasFileURL": {
            "forms": [
<#list jpath.filter("$.bindings",res)>
<#items as bindings>
<#if bindings?is_last>
<#if jpath.filter("$.type.value",bindings) == "https://cogito.iot.linkeddata.es/def/facility#Project">
                {
                    "href": "[=jpath.filter("$.file_url.value",bindings)]",
                    "type": "[=file_type]"
                }
<#else>
                {
                    "href": "[=jpath.filter("$.file_url.value",bindings)]",
                    "type": "[=jpath.filter("$.type.value",bindings)]"
                }
</#if>
<#else>
<#if jpath.filter("$.type.value",bindings) == "https://cogito.iot.linkeddata.es/def/facility#Project">
                {
                    "href": "[=jpath.filter("$.file_url.value",bindings)]",
                    "type": "[=file_type]"
                },
<#else>
                {
                    "href": "[=jpath.filter("$.file_url.value",bindings)]",
                    "type": "[=jpath.filter("$.type.value",bindings)]"
                },
</#if>
</#if>
</#items>
</#list>
            ]
        }
<#else>
<#if jpath.filter("$.bindings.*.type.value",res) == "https://cogito.iot.linkeddata.es/def/facility#Project">
        ,
        "platform:hasFileURL": {
            "forms": [
                {
                    "href": "[=jpath.filter("$.bindings.*.file_url.value",res)]",
                    "type": "[=file_type]"
                }
            ]
        }
<#else>
        ,
        "platform:hasFileURL": {
            "forms": [
                {
                    "href": "[=jpath.filter("$.bindings.*.file_url.value",res)]",
                    "type": "[=jpath.filter("$.bindings.*.type.value",res)]"
                }
            ]
        }
</#if>
</#if>
</#if>
</#list>
</@action>
    },
    "actions": {},
    "events": {},
    "links": [
        {
            "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/[=project_id]",
            "rel": "platform:relatedTD",
            "type": "application/td+json"
        }
    ],
    "security": [
        "nosec_sc"
    ],
    "securityDefinitions": {
        "nosec_sc": {
            "scheme": "nosec"
        }
    }
    
}
]
</#assign>
[=thing_description]