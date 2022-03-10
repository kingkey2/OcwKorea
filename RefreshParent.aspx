﻿<%@Page Language="C#"%>
<%
    string DestURL;

    Response.Clear();
    Response.Expires = 0;

    DestURL = CodingControl.GetQueryString();

    if (string.IsNullOrEmpty(DestURL))
        DestURL = "/";
%>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="Content-Language" content="zh-cn">
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body style="width: 100%">
<span style="font-size:24px; text-align: center; width: 100%;">
Please wait...
</span>
<script language="javascript">
    window.top.location.href="<%=CodingControl.JSEncodeString(DestURL) %>";
</script>
</body>
</html>