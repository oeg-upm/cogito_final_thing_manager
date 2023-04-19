<#-- Call SHACL Validation Mapping -->

<#attempt>

<#assign shape = "http://localhost:4567/api/file_shacl_validation/data?shape_uri=" + shape_uri?url('ISO-8859-1') + "&rdf_mapping=" + rdf_mapping?url('ISO-8859-1')>

<#assign shacl_validation>
{
            "method": "GET",
            "url": "[=shape]",
            "body":""
}
</#assign>

<#assign validation=providers("HttpProvider", shacl_validation)>

<#recover>
500, Error validating RDF data with Shacl Shape
</#attempt>

<#if validation?contains("True")>
<#-- Save in Triplestore -->

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

<#-- Transform turtle format to n-triples -->
<#assign config = {"data-format" : "turtle", "output-format" : "nt"}>
<@action type="RdfCast" data=rdf conf=config; result>
<#assign rdf_nt = result>
</@action>

<#-- Chunk in 20 by 20 triples -->

<#assign rdf_splitted = rdf_nt?split("\n")>
<#list rdf_splitted?chunk(20) as row>
<#assign triples_joined = row?join("\n")>

<#-- Insert data in project graph in Triplestore -->

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
<#-- Insert data in file graph in Triplestore -->

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
OK, no Errors in Graph
<#else>
Validation Report
--
[=validation]
--
</#if>

