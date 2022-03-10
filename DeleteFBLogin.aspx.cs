using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class DeleteFBLogin : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        System.Web.Script.Serialization.JavaScriptSerializer ser = new System.Web.Script.Serialization.JavaScriptSerializer();
        Response.Write(ser.Serialize(new { status_url = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/DeleteFBCheck.aspx?id=ABC123", confirmation_code = "ABC123" }));
    }
}