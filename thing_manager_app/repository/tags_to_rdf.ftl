<#assign jpath=handlers('JsonHandler')>
<#assign file_mapping = "http://localhost:4567/api/" + mapping_url + "/data">
<#assign file_request>
{
            "method": "GET",
            "url": "[=file_mapping]",
            "body":""
}
</#assign>
<#assign file=providers("HttpProvider", file_request)>
<#assign real_json=file?eval_json>
<#assign rdf>
@prefix schema: <http://schema.org#> .
@prefix process: <https://cogito.iot.linkeddata.es/def/process#> .
@prefix iot: <https://cogito.iot.linkeddata.es/def/iot#> .
@prefix owl:   <http://www.w3.org/2002/07/owl#> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix resource: <https://cogito.iot.linkeddata.es/def/resource#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix tag:  <http://data.cogito.iot.linkeddata.es/resources/tag/> .
@prefix tag_group:  <http://data.cogito.iot.linkeddata.es/resources/tag_group/> .
@prefix project: <http://data.cogito.iot.linkeddata.es/resources/project/> .
@prefix facility: <https://cogito.iot.linkeddata.es/def/facility#> .
@prefix platform: <https://cogito.iot.linkeddata.es/def/platform#> .

<#if real_json.groups?is_sequence>
<#list real_json.groups as group>
tag_group:[=group.groupId]
<#if group.groupId == "0">
    a   iot:HumanTrackingTagGroup ;
<#else>
    a   iot:EquipmentTrackingTagGroup ;
</#if>
    dcterms:identifier "[=group.groupId]" ;
    dcterms:title "[=group.groupName]" ;
<#if group.tags?is_sequence>
    iot:hasTrackingTag
<#list group.tags as tag>
        tag:[=tag.tagId]<#if tag?is_last> .<#else> , </#if>
</#list>
<#else>
    iot:hasTrackingTag tag:[=group.tags.tagId] .
</#if>


<#if group.tags?is_sequence>
<#list group.tags as tag>
tag:[=tag.tagId]
<#if group.groupId == "0">
    a   facility:HumanTrackingTag ;
<#else>
    a   facility:EquipmentTrackingTag ;
</#if>
    dcterms:identifier "[=tag.tagId]" ;
    iot:belongsToTagGroup tag_group:[=group.groupId] .

</#list>
<#else>
<#if group.groupId == "0">
    a   facility:HumanTrackingTag ;
<#else>
    a   facility:EquipmentTrackingTag ;
</#if>
    dcterms:identifier "[=group.tags.tagId]" ;
    iot:belongsToTagGroup tag_group:[=group.groupId] .

</#if>
</#list>
</#if>

project:[=project_id]
    a   facility:Project ;
    platform:hasFileURL "[=file_url]" .
</#assign>
[=rdf]