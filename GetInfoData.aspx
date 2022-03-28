<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GetInfoData.aspx.cs" Inherits="GetInfoData" %>
<%
    string InfoID = Request["ID"];
    string ReturnStr = string.Empty;
    
    ReturnStr = GetInfoData2(InfoID);

    Response.Flush();
    Response.Write(ReturnStr);
    Response.End();
%>
