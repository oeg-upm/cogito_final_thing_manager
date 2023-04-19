<#assign wot_uri = "http://wothive:9000/api/things/" + project_id>
<#assign putConfig>
{
    "url": "[=wot_uri]",
    "method": "PUT"
}
</#assign>
<@action type="HttpRequest" data=td conf=putConfig; result>
[=result]
</@action>