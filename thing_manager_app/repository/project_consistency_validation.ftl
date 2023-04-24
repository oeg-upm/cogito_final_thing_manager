<#assign jpath=handlers("JsonHandler")>
<#assign query>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
CONSTRUCT 
{?s ?p ?o}
FROM <https://data.cogito.iot.linkeddata.es/[=project_id]>
WHERE { 
	SERVICE <https://data.cogito.iot.linkeddata.es/sparql> {  
  		?s ?p ?o .
	}
}
<#-- https://data.cogito.iot.linkeddata.es/all_graph -->
</#assign>
<#assign config = '{"query" : "'+query+'" }'>
<@action type="SparqlEngine" data="" conf=config; result>
<#assign rdf=result>
</@action>

<#-- Make validation -->
<#assign uri = "http://localhost:4567/api/project_consistency_shacl_validation/data">
<#assign shape_uri_validation>
{
            "method": "GET",
            "url": "[=uri]",
            "body":""
}
</#assign>
<#assign shape=providers("HttpProvider", shape_uri_validation)>

<#assign config="{\"shape\" : \""+shape?js_string+"\", \"output-format\" : \"turtle\"  }">
<@action type="ShaclValidator" data=rdf conf=config; report>
<#--  aggregate the RDF and the report into a variable-->
<#assign rdf_report = rdf+"\n"+report>
<#assign report = report>
</@action>

<#assign query>
SELECT ?o WHERE {
    ?s <http://www.w3.org/ns/shacl#conforms> ?o .
}
</#assign>

<#assign config = '{"query" : "'+query+'" }'>
<@action type="SparqlEngine" data=rdf_report conf=config; result>
<#list jpath.filter("$.*",result) as res>

<#if res?contains("bindings")>
<#if jpath.filter("$.bindings.*.o.value",res)?contains("true")>
Project Knowledge Graph is consistent
<#else>

<#assign query>
PREFIX sh:<http://www.w3.org/ns/shacl#>
SELECT ?focusNode ?resultMessage ?resultPath WHERE {
    ?s          sh:result           ?result .
    ?result   sh:focusNode        ?focusNode .
    ?result   sh:resultMessage    ?resultMessage .
    ?result   sh:resultPath       ?resultPath .
}
</#assign>
<#assign config = '{"query" : "'+query+'" }'>
<@action type="SparqlEngine" data=report conf=config; result>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Project [=project_id] Consistency Table</title>
    <style>
        #customers {
        font-family: Arial, Helvetica, sans-serif;
        border-collapse: collapse;
        width: 100%;
        }

        #customers td, #customers th {
        border: 1px solid #ddd;
        padding: 8px;
        }

        #customers tr:nth-child(even){background-color: #f2f2f2;}

        #customers tr:hover {background-color: #ddd;}

        #customers th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: left;
        background-color: #04AA6D;
        color: white;
        }
    </style>
  </head>
  <body>
    <div class="container">
    <center>
        <a href="https://cogito-project.eu/"><img src="https://raw.githubusercontent.com/oeg-upm/cogito-sparql/main/static/logo/logo.jpg" width="500" alt="COGITO logo" class="img-rounded center"></a>
    
    <h1>Project [=project_id] Consistency Table</h1>
    </center>

        <table class="tb" id="customers">
            <tr>
                <th colspan="1">Focus Node</th>
                <th colspan="1">Result Message</th>
                <th colspan="1">Result Path</th>
            </tr>    
<#list jpath.filter("$.*",result) as res>
<#if res?contains("bindings")>
<#list jpath.filter("$.bindings.*",res) as binding>
<#assign focusNode = jpath.filter("$.focusNode.value",binding) >
<#assign resultMessage = jpath.filter("$.resultMessage.value",binding) >
<#assign resultPath = jpath.filter("$.resultPath.value",binding) >
            <tr>
                <td>[=focusNode]</td>
                <td>[=resultMessage]</td>
                <td>[=resultPath]</td>
            </tr>
</#list>
</#if>
</#list>
</@action>
</#if>
</#if>
</#list>
          </table>
</div>
  </body>
</html>
</@action>
