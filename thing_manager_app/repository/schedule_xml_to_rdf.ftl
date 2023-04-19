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
<@action type="JsonCast" conf= { "format" : "xml" } data=file; json>
<#assign real_json=json?eval>
<#assign rdf>
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix data: <http://data.cogito.iot.linkeddata.es/resources/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix facility: <https://cogito.iot.linkeddata.es/def/facility#> .
@prefix process: <https://cogito.iot.linkeddata.es/def/process#> .
@prefix resource: <https://cogito.iot.linkeddata.es/def/resource#> .
@prefix const: <https://cogito.iot.linkeddata.es/def/construction#> .
@prefix time: <http://www.w3.org/2006/time#> .
@prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> .
@prefix s4city: <https://saref.etsi.org/saref4city#> .
@prefix saref: <https://saref.etsi.org/core#> .
@prefix cost: <http://data.cogito.iot.linkeddata.es/resources/cost/> .
@prefix interval: <http://data.cogito.iot.linkeddata.es/resources/interval/> .
@prefix process_data: <http://data.cogito.iot.linkeddata.es/resources/process/> .
@prefix project: <http://data.cogito.iot.linkeddata.es/resources/project/> .
@prefix task: <http://data.cogito.iot.linkeddata.es/resources/task/> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix platform: <https://cogito.iot.linkeddata.es/def/platform#> .
@prefix dcterms: <http://purl.org/dc/terms/> .

project:[=project_id]
    a   facility:Project ;
    facility:isRelatedToProcess process_data:[=project_id]_[=real_json.Project.Title] ;
    platform:hasFileURL "[=file_url]" .

process_data:[=project_id]_[=real_json.Project.Title]
    a process:Process ;
    process:hasTask
<#list real_json.Project.Tasks.Task>
<#items as task>
        task:[=project_id]_[=real_json.Project.Title]_[=task.UID] <#if task?is_last> ; <#else> , </#if>
</#items>
</#list>
    dcterms:identifier '[=real_json.Project.GUID]' ;
    dcterms:title '[=real_json.Project.Title]' ;
    dcterms:created '[=real_json.Project.CreationDate]'^^<http://www.w3.org/2001/XMLSchema#dateTime> .

<#list real_json.Project.Tasks.Task>
<#items as task>
task:[=project_id]_[=real_json.Project.Title]_[=task.UID]
    a process:Task ;
    facility:isRelatedToProject project:[=project_id] ;
    dcterms:identifier '[=task.UID]' ;
    dcterms:title '[=task.Name]' ;
    dcterms:created '[=task.CreateDate]'^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
    process:priority '[=task.Priority]'^^<http://www.w3.org/2001/XMLSchema#integer> ;
    process:progess '[=task.RemainingWork]'^^<http://www.w3.org/2001/XMLSchema#string> ;
    process:belongsToProcess process_data:[=project_id]_[=real_json.Project.Title] ;
<#if task.Active == 1>
    process:hasStatus 'Active'^^<http://www.w3.org/2001/XMLSchema#string> ;
<#else>
    process:hasStatus "Not Active"^^<http://www.w3.org/2001/XMLSchema#string> ;
</#if>
    process:plannedStartDate '[=task.Start]'^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
    process:plannedEndDate '[=task.Finish]'^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
    process:workQuantity '[=task.Work]' <#if task.Childs?? || task.Parent_WBS??>;<#else>.

    </#if>
<#if task.Childs??>
    process:hasSubTask
<#assign childs = task.Childs.WBS>
<#if childs?is_sequence>
<#list childs as child>
        task:[=child] <#if child?is_last && !task.Parent_WBS??> .
        <#elseif child?is_last && task.Parent_WBS??> ; <#else> , </#if>
</#list>
<#else>
        task:[=childs] <#if !task.Parent_WBS??> .
        
        <#else> ; </#if>
</#if>
</#if>
<#if task.Parent_WBS??>
    process:isSubTaskOf task:[=task.Parent_WBS] .

</#if>
</#items>
</#list>
</#assign>
</@>
[=rdf]