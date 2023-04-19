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
<#assign query2>
PREFIX facility:<https://cogito.iot.linkeddata.es/def/facility#>
PREFIX dcterms:<http://purl.org/dc/terms/>
SELECT DISTINCT ?s ?id ?title WHERE {
    ?s a facility:Element.
    ?s dcterms:identifier ?id .
    ?s dcterms:title ?title .
}
</#assign>
[
<#assign info_res_thing_description>
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
<#assign raw_file = jpath.filter("$.bindings.*.file_url.value",res)>
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
            "href": "[=project_id]",
            "rel": "platform:relatedTD",
            "type": "application/td+json"
        }
<#assign config2 = '{"query" : "'+query2+'" }'>
<@action type="SparqlEngine" data=rdf conf=config2; result2>
<#list jpath.filter("$.*",result2) as res2>
<#if res2?contains("bindings")>
<#if jpath.filter("$.bindings",res2)?is_sequence>
<#list jpath.filter("$.bindings",res2)>
<#items as bindings2>
        ,{
            "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/[=jpath.filter("$.id.value",bindings2)]",
            "rel": "platform:relatedTD",
            "type": "application/td+json"
        }
</#items>
</#list>
<#else>
        ,{
            "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/[=jpath.filter("$.bindings.*.id.value",res2)]",
            "rel": "platform:relatedTD",
            "type": "application/td+json"
        }
</#if>
</#if>
</#list>
</@action>
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
</#assign>
[=info_res_thing_description]
<@action type="SparqlEngine" data=rdf conf=config2; result3>
<#list jpath.filter("$.*",result3) as res3>
<#if res3?contains("bindings")>
<#if jpath.filter("$.bindings",res3)?is_sequence>
<#list jpath.filter("$.bindings",res3)>
<#items as bindings3>
,{
    "id": "[=jpath.filter("$.id.value",bindings3)]",
    "securityDefinitions": {
        "nosec_sc": {
            "scheme": "nosec"
        }
    },
    "td:description": "Element from IFC File associated to project [=project_id]",
    "links": [
        {
            "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/[=project_id]",
            "rel": "platform:relatedTD",
            "type": "application/td+json"
        }
    ],
    "properties": {
        "platform:hasFileURL": {
            "forms": [
                {
                    "href": "[=raw_file]",
                    "type": "[=file_type]"
                }
            ]
        },
        "platform:hasIRI": {
            "forms": [
                {
                    "href": "[=jpath.filter("$.s.value",bindings3)]",
                    "type": "text/turtle"
                }
            ]
        },
        "platform:refersToKnowledgeGraph": {
            "forms": [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/resources/[=project_id]/[=file_id]",
                    "type": "text/turtle"
                }
            ]
        }
    },
    "hasSecurityConfiguration": {
        "id": "https://data.cogito.iot.linkeddata.es/tdd/api/things/nosec_sc"
    },
    "title": "[=jpath.filter("$.title.value",bindings3)]",
    "@type": "facility:Element",
    "@context": [
        "https://www.w3.org/2019/wot/td/v1",
        {
            "facility": "https://cogito.iot.linkeddata.es/def/facility#",
            "bot": "https://w3id.org/bot#",
            "platform": "https://cogito.iot.linkeddata.es/def/platform#"
        },
        "https://w3c.github.io/wot-discovery/context/discovery-context.jsonld"
    ]
}
</#items>
</#list>
<#else>
,{
    "id": "[=jpath.filter("$.bindings.*.id.value",res3)]",
    "securityDefinitions": {
        "nosec_sc": {
            "scheme": "nosec"
        }
    },
    "td:description": "Element from IFC File associated to project [=project_id]",
    "links": [
        {
            "href": "https://data.cogito.iot.linkeddata.es/tdd/api/things/[=project_id]",
            "rel": "platform:relatedTD",
            "type": "application/td+json"
        }
    ],
    "properties": {
        "platform:hasFileURL": {
            "forms": [
                {
                    "href": "[=raw_file]",
                    "type": "[=file_type]"
                }
            ]
        },
        "platform:hasIRI": {
            "forms": [
                {
                    "href": "[=jpath.filter("$.bindings.*.s.value",res3)]",
                    "type": "text/turtle"
                }
            ]
        },
        "platform:refersToKnowledgeGraph": {
            "forms": [
                {
                    "href": "https://data.cogito.iot.linkeddata.es/resources/[=project_id]/[=file_id]",
                    "type": "text/turtle"
                }
            ]
        }
    },
    "hasSecurityConfiguration": {
        "id": "https://data.cogito.iot.linkeddata.es/tdd/api/things/nosec_sc"
    },
    "title": "[=jpath.filter("$.bindings.*.title.value",res3)]",
    "@type": "facility:Element",
    "@context": [
        "https://www.w3.org/2019/wot/td/v1",
        {
            "facility": "https://cogito.iot.linkeddata.es/def/facility#",
            "bot": "https://w3id.org/bot#",
            "platform": "https://cogito.iot.linkeddata.es/def/platform#"
        },
        "https://w3c.github.io/wot-discovery/context/discovery-context.jsonld"
    ]
}
</#if>
</#if>
</#list>
</@action>
]