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
@prefix facility: <https://cogito.iot.linkeddata.es/def/facility#> .
@prefix owl:   <http://www.w3.org/2002/07/owl#> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix resource: <https://cogito.iot.linkeddata.es/def/resource#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix task:  <http://data.cogito.iot.linkeddata.es/resources/task/> .
@prefix element:  <http://data.cogito.iot.linkeddata.es/resources/element/> .
@prefix resource_type_requirement:  <http://data.cogito.iot.linkeddata.es/resources/resource_type_requirement/> .
@prefix resource_type:  <http://data.cogito.iot.linkeddata.es/resources/resource_type/> .
@prefix data_process:  <http://data.cogito.iot.linkeddata.es/resources/process/> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix project: <http://data.cogito.iot.linkeddata.es/resources/project/> .
@prefix platform: <https://cogito.iot.linkeddata.es/def/platform#> .

<#list real_json.tasks?keys as task>
task:[=task] # Needs process id
    dcterms:title   "[=real_json.tasks[task].name]" ;
    dcterms:identifier  "[=task]" ;
    process:hasType    "[=real_json.tasks[task].type]" ;
<#if real_json.tasks[task].sub_task_list?is_sequence && (real_json.tasks[task].sub_task_list?size > 0)>
    process:hasSubTaskList    <#list real_json.tasks[task].sub_task_list as sub_task>"[=sub_task]"<#if sub_task?is_last> ; <#else> , </#if> </#list>
</#if>
<#if real_json.tasks[task].parent_task??>
    process:isSubTaskOf    "[=real_json.tasks[task].parent_task]" ;
</#if>
<#-- Necesitamos los resource type requirements para hacer el process:hasResourceTypeRequirement-->
<#-- Necesitamos los process para hacer el process:belongsToProcess-->
    process:plannedEndDate   "[=real_json.tasks[task].end_time]"^^xsd:dateTime ;
    process:plannedStartDate   "[=real_json.tasks[task].start_time]"^^xsd:dateTime 
<#if real_json.tasks[task].element_list?is_sequence && (real_json.tasks[task].element_list?size > 0)>
    ;
    process:controlsElement    <#list real_json.tasks[task].element_list as element>element:[=element]<#if element?is_last> . <#else> , </#if> </#list>

<#list real_json.tasks[task].element_list as element>
element:[=element]
    a facility:Element ;
<#-- Necesitamos saber qué tarea se ha encargado de hacer el process:isAddedByTask-->
    process:isControlledByTask   task:[=task] . 
</#list>
<#else>
    .
</#if>

</#list>
project:[=project_id]
    a   facility:Project ;
    platform:hasFileURL "[=file_url]" .
</#assign>
[=rdf]