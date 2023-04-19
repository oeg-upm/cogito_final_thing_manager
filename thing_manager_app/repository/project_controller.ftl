<#-- 
Variables:
?json_metadata = json with project metadata
?rdf_mapping = mapping identifier to call and get the rdf data
?shape_uri = shape uri that is used in shape_mapping to download the respective shape and validate the respective rdf generated
?thing_description_mapping = mapping identifier to call and generate the thing description asociated to the graph
?project_id = identifier for the project
-->

<#assign flag_error=false>

<#-- Generate Project RDF data -->

<#attempt>

<#assign data = "http://localhost:4567/api/" + rdf_mapping + "/data?json_metadata=" + json_metadata?replace('"', "'")?url('ISO-8859-1')>

<#assign rdf_generator>
{
            "method": "GET",
            "url": "[=data]",
            "body":""
}
</#assign>

<#assign rdf=providers("HttpProvider", rdf_generator)>

<#recover>
500, Error Generating Project RDF Triples
<#assign flag_error=true>
</#attempt>

<#-- Validate RDF data with Shacl Shape -->

<#attempt>

<#assign shape = "http://localhost:4567/api/shacl_validation/data?shape_uri=" + shape_uri?url('ISO-8859-1') + "&rdf=" + rdf?url('ISO-8859-1')>

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
<#assign flag_error=true>
</#attempt>

<#-- Save Triples in Triplestore -->

<#attempt>

<#if validation?contains("True")>
<#assign save_graph = "http://localhost:4567/api/triplestore_handler/data?project_id=" + project_id?url('ISO-8859-1') + "&rdf=" + rdf?url('ISO-8859-1')>

<#assign triplestore_save_graph>
{
            "method": "GET",
            "url": "[=save_graph]",
            "body":""
}
</#assign>

<#assign triplestore=providers("HttpProvider", triplestore_save_graph)>
<#else>
406, Triples with errors
<#assign flag_error=true>
</#if>

<#recover>
500, Error saving RDF data in Triplestore
<#assign flag_error=true>
</#attempt>

<#-- Generate Project Thing Description -->

<#attempt>

<#assign td_uri = "http://localhost:4567/api/" + thing_description_mapping + "/data?json_metadata=" + json_metadata?url('ISO-8859-1')>

<#assign td_generator>
{
            "method": "GET",
            "url": "[=td_uri]",
            "body":""
}
</#assign>

<#assign td=providers("HttpProvider", td_generator)>

<#recover>
500, Error generating project Thing Description
<#assign flag_error=true>
</#attempt>

<#-- Save Thing Description in WoT-Hive -->

<#attempt>

<#assign wot_uri = "http://localhost:4567/api/wot-hive_controller/data?td=" + td?url('ISO-8859-1') + "&project_id=" + project_id?url('ISO-8859-1')>

<#assign wot_hive_controller>
{
            "method": "GET",
            "url": "[=wot_uri]",
            "body":""
}
</#assign>

<#assign wot_response=providers("HttpProvider", wot_hive_controller)>

<#recover>
500, Error saving project Thing Description in WoT-Hive
<#assign flag_error=true>
</#attempt>


<#-- Final Flag Status -->
<#if flag_error>
ERROR
<#else>
OK
</#if>