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
@prefix const: <https://cogito.iot.linkeddata.es/def/construction#> .
@prefix owl:   <http://www.w3.org/2002/07/owl#> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix resource: <https://cogito.iot.linkeddata.es/def/resource#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix tag:  <http://data.cogito.iot.linkeddata.es/resources/tag/> .
@prefix tag_group:  <http://data.cogito.iot.linkeddata.es/resources/tag_group/> .
@prefix equipment:  <http://data.cogito.iot.linkeddata.es/resources/equipment/> .
@prefix worker:  <http://data.cogito.iot.linkeddata.es/resources/worker/> .
@prefix task:  <http://data.cogito.iot.linkeddata.es/resources/task/> .
@prefix work_order:  <http://data.cogito.iot.linkeddata.es/resources/work_order/> .
@prefix project: <http://data.cogito.iot.linkeddata.es/resources/project/> .
@prefix facility: <https://cogito.iot.linkeddata.es/def/facility#> .
@prefix platform: <https://cogito.iot.linkeddata.es/def/platform#> .


<#list real_json.workorders?keys as wo>
work_order:[=wo]
    a process:WorkOrder ;
<#if real_json.workorders[wo].task_list?is_sequence>
    process:hasComponentTask    
<#list real_json.workorders[wo].task_list as task>
        task:[=task]<#if task?is_last> ;<#else>, </#if>
</#list>
<#else>
    process:hasComponentTask task:[=real_json.workorders[wo].task_list] ;
</#if>
    process:hasMainProvider worker:[=real_json.workorders[wo].main_provider] ;
    process:plannedEndDate "[=real_json.workorders[wo].end_time]"^^xsd:dateTime ;
    process:plannedStartDate "[=real_json.workorders[wo].start_time]"^^xsd:dateTime .

</#list>

<#list real_json.tasks?keys as task>
task:[=task]
    a process:Task ;
<#if real_json.tasks[task].equipment_list?is_sequence && real_json.tasks[task].human_list?is_sequence>
    process:hasComponentTask    
<#list real_json.tasks[task].equipment_list as el>
        equipment:[=el] ,
</#list>
<#list real_json.tasks[task].human_list as hl>
        worker:[=hl] <#if hl?is_last> ;<#else>, </#if>
</#list>
    process:hasMainProvider worker:[=real_json.tasks[task].provider] .
</#if>

</#list>

<#list real_json.equipment_instances?keys as ei>
equipment:[=ei]
    a resource:Equipment ;
<#if real_json.equipment_instances[ei].tag??>
    process:hasTrackingTag tag:[=real_json.equipment_instances[ei].tag] ;
</#if>
    dcterms:title   "[=real_json.equipment_instances[ei].name]" .

</#list>

<#list real_json.human_instances?keys as hi>
worker:[=hi]
    a resource:Worker ;
    process:hasTrackingTag tag:[=real_json.human_instances[hi].tag] ;
    resource:email "[=real_json.human_instances[hi].email]" ;
    resource:firstName "[=real_json.human_instances[hi].first_name]" ;
    resource:lastName "[=real_json.human_instances[hi].last_name]" .
    
</#list>

project:[=project_id]
    a   facility:Project ;
    platform:hasFileURL "[=file_url]" .

</#assign>
[=rdf]