<#assign jpath=handlers("JsonHandler")>

<#-- GET RDF from Mapping -->

<#assign rdf_uri = "http://localhost:4567/api/" + rdf_mapping + "/data">



<#assign get_rdf>
{
            "method": "GET",
            "url": "[=rdf_uri]",
            "body":""
}
</#assign>

<#assign rdf=providers("HttpProvider", get_rdf)>

<#-- Make validation -->
<#assign uri = "http://localhost:4567/api/" + shape_uri + "/data">
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
True
<#else>
[=report]
</#if>
</#if>
</#list>
</@action>