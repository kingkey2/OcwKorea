<%@ Page Language="C#" %>
<%
    string Filename = string.Empty;
    string TextContent;
    string TextContentAgent= string.Empty;
    string FileData;
    string isModify = "0";
    string[] stringSeparators = new string[] { "&&_" };
    string[] Separators;

    if (System.IO.File.Exists(Server.MapPath("/App_Data/Bulletin.txt")) == false) {
        System.IO.File.Create(Server.MapPath("/App_Data/Bulletin.txt"));
    }
    Filename = Server.MapPath("/App_Data/Bulletin.txt");

    if (CodingControl.FormSubmit()) {
        TextContent = Request["TextData"];
        TextContentAgent = Request["TextDataAgent"];

        if (string.IsNullOrEmpty(Request["isModify"]) == false)
        {
            TextContent = TextContent + "&&_1";
        }
        else {
            TextContent = TextContent + "&&_0";
        }

        TextContent = TextContent + "&&_" + TextContentAgent;
        System.IO.File.WriteAllText(Filename, TextContent);

        ASG.AlertMessage("OK", String.Empty);
    }

    FileData = System.IO.File.ReadAllText(Filename);
    Separators = FileData.Split(stringSeparators, StringSplitOptions.None);
    TextContent = Separators[0];

    if (Separators.Length > 1) { 
        isModify = Separators[1];
    }

    if (Separators.Length > 2) { 
        TextContentAgent = Separators[2];
    } 
%>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="description" content="cbFlyout Plugin">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <form method="post">
        <input type="checkbox" name="isModify" <%if (isModify == "1"){%>checked<%}%> />System Under Maintenance
        <br />
        <textarea id="TextArea1" cols="60" name="TextData" rows="20"><%=Server.HtmlEncode(TextContent) %></textarea>
        <br />
        <textarea id="TextAreaAgent" cols="60" name="TextDataAgent" rows="20"><%=Server.HtmlEncode(TextContentAgent) %></textarea>
        <br />
        <input type="submit" value="OK" />
    </form>
</body>
</html>
