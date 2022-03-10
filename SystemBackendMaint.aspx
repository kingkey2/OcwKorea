<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SystemBackendMaint.aspx.cs" Inherits="SystemBackendMaint" %>
<%
    string errMsg = "";
    string PassWord = "";
    string InMaintenance = "";
    dynamic o = null;
    string Filename;

    if (string.IsNullOrEmpty(Request["PassWord"]) == false) {
        PassWord = Request["PassWord"];
    } else {
        errMsg += " 密碼缺失;";
    }

    if (PassWord != "1qaz@WSX") {
        errMsg += " 密碼錯誤;";
    }

    if (string.IsNullOrEmpty(Request["InMaintenance"]) == false) {
        InMaintenance = Request["InMaintenance"];
    } else {
        errMsg += " InMaintenance缺失;";
    }

    if (InMaintenance == "0" || InMaintenance == "1") {

    } else {
        errMsg += " InMaintenance格式錯誤;";
    }

    if (string.IsNullOrEmpty(errMsg)) {
        Filename = HttpContext.Current.Server.MapPath("./App_Data/Setting.json");

        if (System.IO.File.Exists(Filename)) {
            string SettingContent;

            SettingContent = System.IO.File.ReadAllText(Filename);

            if (string.IsNullOrEmpty(SettingContent) == false) {
                try {
                    o = Newtonsoft.Json.JsonConvert.DeserializeObject(SettingContent);
                    o.InMaintenance = InMaintenance;

                    System.IO.File.WriteAllText(Filename, Newtonsoft.Json.JsonConvert.SerializeObject(o));
                } catch (Exception ex) { }
            }
        }
    }

%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
        
        </div>
    </form>
</body>
</html>

<script>
    var errMsg = "<%=errMsg%>";

    function init() {
        if (errMsg) {
            alert(errMsg);
        }
    }

    window.onload = init();
</script>