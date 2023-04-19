<#if file_id??>

<#assign config = {"data-format" : "turtle", "output-format" : "nt"}>
<@action type="RdfCast" data=rdf conf=config; result>
<#assign rdf_nt = result>
</@action>
[=rdf_nt]

<#assign rdf_splitted = rdf_nt?split("\n")>
<#list rdf_splitted?chunk(20) as row>
<#assign triples_joined = row?join("\n")>
[=triples_joined]

<#assign graph="INSERT DATA { GRAPH <https://data.cogito.iot.linkeddata.es/" + project_id + "> { " + triples_joined + "} }">

<#assign graph="http://graphdb:7200/repositories/cogito-triplestore/statements?update="+ graph?url('ISO-8859-1')>

<#assign dataset>
{
            "method": "POST",
            "url": "[=graph]",
            "body": ""
}
</#assign>

<#assign dataset=providers("HttpProvider", dataset)>
<#assign file_graph="INSERT DATA { GRAPH <https://data.cogito.iot.linkeddata.es/" + project_id + "/" + file_id + "> { " + triples_joined + "} }">

<#assign file_graph="http://graphdb:7200/repositories/cogito-triplestore/statements?update="+ file_graph?url('ISO-8859-1')>

<#assign dataset_file>
{
            "method": "POST",
            "url": "[=file_graph]",
            "body": ""
}
</#assign>

<#assign dataset=providers("HttpProvider", dataset_file)>


</#list>

<#else>

<#assign config = {"data-format" : "turtle", "output-format" : "nt"}>
<@action type="RdfCast" data=rdf conf=config; result>
<#assign rdf_nt = result>
</@action>
[=rdf_nt]

<#assign rdf_splitted = rdf_nt?split("\n")>
<#list rdf_splitted?chunk(20) as row>
<#assign triples_joined = row?join("\n")>
[=triples_joined]

<#assign graph="INSERT DATA { GRAPH <https://data.cogito.iot.linkeddata.es/" + project_id + "> { " + triples_joined + "} }">

<#assign graph="http://graphdb:7200/repositories/cogito-triplestore/statements?update="+ graph?url('ISO-8859-1')>

<#assign dataset>
{
            "method": "POST",
            "url": "[=graph]",
            "body": ""
}
</#assign>

<#assign dataset=providers("HttpProvider", dataset)>

</#list>

</#if>
