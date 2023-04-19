<#assign json = file_info?eval>

<#assign rdf>
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix data: <http://data.cogito.iot.linkeddata.es/resources/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix facility: <https://cogito.iot.linkeddata.es/def/facility#> .
@prefix project: <http://data.cogito.iot.linkeddata.es/resources/project/> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .

project:[=json.project_id]
    a                           facility:Project ;
<#if json.project_name??>
    dcterms:title            "[=json.project_name]"^^xsd:string ;
</#if>
<#if json.project_description??>
    dcterms:description     "[=json.project_description]"^^xsd:string ;
</#if>
    dcterms:identifier          "[=json.project_id]"^^xsd:string .

</#assign>

[=rdf]