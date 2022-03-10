﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Web;
using System.Web.UI;

public class CodingControl
{

    public static decimal FormatDecimal(decimal value, int point) {

        decimal pointV =  (decimal)Math.Pow(10, point);
        return decimal.Ceiling(value * pointV) / pointV;
    }

    public static void SendMail(string SMTPServer, System.Net.Mail.MailAddress FromName, System.Net.Mail.MailAddress ToName, string Subject, string Body, string LoginAccount, string LoginPassword, string Charset, Boolean EnableSsl = false, int Port = 587)
    {
        System.Net.Mail.SmtpClient SMTP;
        System.Net.Mail.MailMessage Msg;

        SMTP = new System.Net.Mail.SmtpClient(SMTPServer, Port);
        SMTP.EnableSsl = EnableSsl;
        SMTP.Credentials = new System.Net.NetworkCredential(LoginAccount, LoginPassword);
        Msg = new System.Net.Mail.MailMessage();
        Msg.Body = Body;
        Msg.IsBodyHtml = true;

        if (Charset == String.Empty)
        {
            Msg.BodyEncoding = System.Text.Encoding.Default;
        }
        else
        {
            Msg.BodyEncoding = System.Text.Encoding.GetEncoding(Charset);
        }

        Msg.From = FromName;
        Msg.To.Add(ToName);
        Msg.Subject = Subject;

        try
        {
            SMTP.Send(Msg);
        }
        catch (System.Net.WebException ex)
        {

        }

        Msg = null;
    }

    public static string GetEmailTemp(string LoginAccount, string ValidateCode, enumSendMailType SendMailType) {
        Stream myStream;

        if (SendMailType == enumSendMailType.Register) {
            myStream = new FileStream(HttpContext.Current.Server.MapPath(@"/Html/ocw/verification.html"), FileMode.Open);
        } else if (SendMailType == enumSendMailType.ForgetPassword) {
            myStream = new FileStream(HttpContext.Current.Server.MapPath(@"/Html/ocw/verification.html"), FileMode.Open);
        } else {
            myStream = new FileStream(HttpContext.Current.Server.MapPath(@"/Html/ocw/thanks.html"), FileMode.Open);
        }

        Encoding encode = System.Text.Encoding.GetEncoding("GB2312");
        StreamReader myStreamReader = new StreamReader(myStream, encode);
        string strhtml = myStreamReader.ReadToEnd();
        myStream.Close();
        string stroutput = string.Empty;
        stroutput = strhtml.Replace("{0}", LoginAccount);

        if (SendMailType == enumSendMailType.Register) {
            stroutput = stroutput.Replace("{1}", ValidateCode);
            stroutput = stroutput.Replace("{2}", "MAHARAJA を選択することを誠にありがとうございました。お客様の確認コードは以下となります。");
            stroutput = stroutput.Replace("{3}", "10分 内に確認コードをアカウント申し込みのベージに入力してください。ありがとうございました。");
            stroutput = stroutput.Replace("{4}", "会員登録検証");
        } else if (SendMailType == enumSendMailType.ForgetPassword) {
            stroutput = stroutput.Replace("{1}", ValidateCode);
            stroutput = stroutput.Replace("{2}", "貴方のパスワードをリセット用の確認コードは以下となります。");
            stroutput = stroutput.Replace("{3}", "パスワードリセット画面にて、新しいパスワードを入力し「更新する」ボタンをクリック");
            stroutput = stroutput.Replace("{4}", "再設定メール");
        }

        return stroutput;
    }

    public static string GetUnicodeEscape(string s) {
        StringBuilder asAscii = new StringBuilder();

        foreach (char c in s)
        {
            int cint = Convert.ToInt32(c);
            if (cint <= 127 && cint >= 0)
                asAscii.Append(c);
            else
                asAscii.Append(String.Format("\\u{0:x4} ", cint).Trim());
        }

        return asAscii.ToString();
    }

    public static string JSEncodeString(string Content)
    {
        if (Content != null)
        {
            return System.Web.HttpUtility.JavaScriptStringEncode(Content);
        }
        else
        {
            return null;
        }
    }

    public static string Base64URLEncode(string SourceString, System.Text.Encoding TextEncoding = null)
    {
        System.Text.Encoding TxtEnc;

        if (TextEncoding == null)
            TxtEnc = System.Text.Encoding.UTF8;
        else
            TxtEnc = TextEncoding;

        return Convert.ToBase64String(TxtEnc.GetBytes(SourceString)).Replace('+', '-').Replace('/', '_');
    }

    public static string Base64URLDecode(string b64String, System.Text.Encoding TextEncoding = null)
    {
        string tmp = b64String.Replace('-', '+').Replace('_', '/');
        string tmp2;
        System.Text.Encoding TxtEnc;

        // 轉換表: '-' -> '+'
        //         '_' -> '/'
        //         c -> c

        if (TextEncoding == null)
            TxtEnc = System.Text.Encoding.UTF8;
        else
            TxtEnc = TextEncoding;

        if ((tmp.Length % 4) == 0)
        {
            tmp2 = tmp;
        }
        else
        {
            tmp2 = tmp + new string('=', 4 - (tmp.Length % 4));
        }

        return TxtEnc.GetString(Convert.FromBase64String(tmp2));
    }

    public static string GetGUID()
    {
        return System.Guid.NewGuid().ToString();
    }

    public static bool GetIsHttps()
    {
        bool RetValue = false;

        if (string.IsNullOrEmpty(HttpContext.Current.Request.Headers["X-Forwarded-Proto"]) == false)
        {
            if (System.Convert.ToString(HttpContext.Current.Request.Headers["X-Forwarded-Proto"]).ToUpper() == "HTTPS")
                RetValue = true;
        }
        else
            RetValue = HttpContext.Current.Request.IsSecureConnection;

        return RetValue;
    }        

    public static string GetUserIP()
    {
        string RetValue = string.Empty;

        if (string.IsNullOrEmpty(HttpContext.Current.Request.Headers["X-Forwarded-For"]) == false)
        {
            RetValue = HttpContext.Current.Request.Headers["X-Forwarded-For"];
            if (string.IsNullOrEmpty(RetValue) == false)
            {
                int tmpInt;

                tmpInt = RetValue.IndexOf(",");
                if (tmpInt != -1)
                {
                    RetValue = RetValue.Substring(0, tmpInt);
                }
            }
        }
        else
        {
            RetValue = HttpContext.Current.Request.UserHostAddress;
        }

        // 濾除 port
        if (string.IsNullOrEmpty(RetValue) == false)
        {
            if (RetValue.IndexOf(".") != -1)
            {
                // ipv4
                int tmpIndex;

                tmpIndex = RetValue.IndexOf(":");
                if (tmpIndex != -1)
                {
                    RetValue = RetValue.Substring(0, tmpIndex);
                }
            }
        }

        return RetValue;
    }

    public static dynamic GetJSON(string s) {
        dynamic o = null;

        if (string.IsNullOrEmpty(s) == false) {
            dynamic o2 = null;

            try {
                o2 = Newtonsoft.Json.JsonConvert.DeserializeObject(s);
            } catch (Exception ex) {
            }

            if (o2 != null) {
                bool dKeyExist = false;

                if (o2 is System.Dynamic.ExpandoObject) {
                    if (((IDictionary<string, object>)o2).ContainsKey("d")) {
                        dKeyExist = true;
                    }
                } else if (o2 is Newtonsoft.Json.Linq.JObject) {
                    if (o2["d"] != null) {
                        dKeyExist = true;
                    }
                }

                if (dKeyExist) {

                    o = o2.d;
                } else {
                    o = o2;
                }
            }
        }

        return o;
    }

    public static string RandomPassword(int MaxPasswordChars)
    {
        Random R2 = new Random();

        return RandomPassword(R2, MaxPasswordChars);
    }

    public static string RandomPassword(Random R, int MaxPasswordChars)
    {
        string PasswordString;

        PasswordString = "1234567890ABCDEFGHJKLMNPQRSTUVWXYZ";

        return RandomPassword(R, MaxPasswordChars, PasswordString);
    }

    public static string RandomPassword(Random R, int MaxPasswordChars, string AvailableCharList)
    {
        int I;
        int CharIndex;
        string PasswordString;
        string RetValue;

        RetValue = string.Empty;
        PasswordString = AvailableCharList;
        for (I = 1; I <= MaxPasswordChars; I++)
        {
            CharIndex = R.Next(0, PasswordString.Length - 1);

            RetValue = RetValue + PasswordString.Substring(CharIndex, 1);
        }

        return RetValue;
    }

    public static string GetQueryString()
    {
        string QueryString;
        int QueryStringIndex;

        QueryStringIndex = HttpContext.Current.Request.RawUrl.IndexOf("?");
        QueryString = string.Empty;
        if (QueryStringIndex > 0)
            QueryString = HttpContext.Current.Request.RawUrl.Substring(QueryStringIndex + 1);

        return QueryString;
    }

    public static bool FormSubmit()
    {
        if (HttpContext.Current.Request.HttpMethod.Trim().ToUpper() == "POST")
            return true;
        else
            return false;
    }
    public static void CheckingLanguage(string Lang)
    {
        try
        {
            if (HttpContext.Current.Request["BackendLang"] != null)
            {
                System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.CreateSpecificCulture(Lang);
                System.Threading.Thread.CurrentThread.CurrentUICulture = new System.Globalization.CultureInfo(Lang);
            }
            else
            {
                System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.CreateSpecificCulture(GetDefaultLanguage());
                System.Threading.Thread.CurrentThread.CurrentUICulture = new System.Globalization.CultureInfo(GetDefaultLanguage());
            }
        }
        catch (Exception ex)
        {

        }
    }
    public static string GetDefaultLanguage()
    {
        // 取得使用者的語言
        // 傳回: 字串, 代表使用者預設的語言集
        string[] LangArr;
        string Temp;
        string[] TempArr;
        string RetValue;

        Temp = HttpContext.Current.Request.ServerVariables["HTTP_ACCEPT_LANGUAGE"];
        if (string.IsNullOrEmpty(Temp) == false)
        {
            TempArr = Temp.Split(';');

            LangArr = TempArr[0].Split(',');

            if (LangArr[0].Trim() == string.Empty)
                RetValue = "en-us";
            else
                RetValue = LangArr[0];
        }
        else
        {
            RetValue = "en-us";
        }

        return RetValue;
    }

    public static byte[] GetWebBinaryContent(string URL)
    {
        byte[] HttpContent;
        System.Net.WebClient HttpClient;

        HttpClient = new System.Net.WebClient();
        HttpContent = HttpClient.DownloadData(URL);

        return HttpContent;
    }

    public static dynamic GetWebJSONContent(string URL, string Method = "GET", string SendData = "", string CustomHeader = null, string ContentType = null, System.Text.Encoding TextEncoding = null, int Timeout = 30000) {
        System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;

        string HttpContent;
        dynamic o = null;
        string defaultContentType = "application/json";

        if (ContentType != null)
            defaultContentType = ContentType;

        HttpContent = GetWebTextContent(URL, Method, SendData, CustomHeader, defaultContentType, TextEncoding, Timeout);
        if (string.IsNullOrEmpty(HttpContent) == false) {
            o = GetJSON(HttpContent);
        }

        return o;
    }

    public static string GetWebTextContent(string URL, string Method = "GET", string SendData = "", string CustomHeader = null, string ContentType = null, System.Text.Encoding TextEncoding = null, int Timeout = 30000)
    {
        System.Net.HttpWebRequest HttpClient;
        System.Net.HttpWebResponse HttpResponse;
        System.IO.Stream Stm;
        System.IO.StreamReader SR;
        string RetValue = string.Empty;
        byte[] SendBytes;
        bool ResponseGZip = false;
        System.IO.Compression.GZipStream GZ = null;

        System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
        System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

        HttpClient = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
        HttpClient.Method = Method;
        HttpClient.Accept = "*/*";
        HttpClient.UserAgent = "Sender";
        HttpClient.KeepAlive = false;
        HttpClient.ContinueTimeout = Timeout;
        HttpClient.ReadWriteTimeout = Timeout;
        HttpClient.Timeout = Timeout;
        HttpClient.ServicePoint.Expect100Continue = false;

        if (CustomHeader != null)
        {
            foreach (string EachHead in CustomHeader.Split('\r', '\n'))
            {
                if (string.IsNullOrEmpty(EachHead) == false)
                {
                    string TmpString = EachHead.Replace("\r", "").Replace("\n", "");
                    int tmpIndex = -1;
                    string cmd = null;
                    string value = null;

                    tmpIndex = TmpString.IndexOf(":");
                    if (tmpIndex != -1)
                    {
                        cmd = TmpString.Substring(0, tmpIndex).Trim();
                        value = TmpString.Substring(tmpIndex + 1).Trim();

                        if (string.IsNullOrEmpty(cmd) == false)
                        {
                            HttpClient.Headers.Set(cmd, value);
                        }
                    }
                }
            }
        }

        switch (Method.ToUpper())
        {
            case "POST":
                {
                    System.Text.Encoding TE = TextEncoding;

                    if (TextEncoding == null)
                        TE = System.Text.Encoding.Default;

                    SendBytes = TE.GetBytes(SendData);

                    if (ContentType == null)
                        HttpClient.ContentType = "application/x-www-form-urlencoded";
                    else
                        HttpClient.ContentType = ContentType;

                    HttpClient.ContentLength = SendBytes.Length;
                    HttpClient.GetRequestStream().Write(SendBytes, 0, SendBytes.Length);
                    break;
                }
        }

        try
        {
            HttpResponse = (System.Net.HttpWebResponse)HttpClient.GetResponse();
        }
        catch (System.Net.WebException ex)
        {
            HttpResponse = (System.Net.HttpWebResponse)ex.Response;
        }

        if (HttpResponse != null)
        {
            if (HttpResponse.Headers != null)
            {
                foreach (string Key in HttpResponse.Headers.AllKeys)
                {
                    if (string.IsNullOrWhiteSpace(Key) == false)
                    {
                        if (ResponseGZip)
                            break;

                        if (Key.ToUpper() == "Content-Encoding".ToUpper())
                        {
                            string EncodingType = HttpResponse.Headers[Key];

                            foreach (string EachString in EncodingType.Split(','))
                            {
                                if (string.IsNullOrWhiteSpace(EachString) == false)
                                {
                                    if (EachString.Trim().ToUpper() == "gzip".ToUpper())
                                    {
                                        ResponseGZip = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Stm = HttpResponse.GetResponseStream();

        if (ResponseGZip)
        {
            GZ = new System.IO.Compression.GZipStream(Stm, System.IO.Compression.CompressionMode.Decompress);
            SR = new System.IO.StreamReader(GZ);
        }
        else
            SR = new System.IO.StreamReader(Stm);

        RetValue = SR.ReadToEnd();

        if (GZ != null)
        {
            try { GZ.Close(); }
            catch (Exception ex) { }
        }

        if (Stm != null)
        {
            try { Stm.Close(); }
            catch (Exception ex) { }
        }

        if (HttpResponse != null)
        {
            try { HttpResponse.Close(); }
            catch (System.Net.WebException ex) { }

            HttpClient = null;
        }

        return RetValue;
    }


    public static string UserIP()
    {
        // 取得使用者的 IP Address
        return HttpContext.Current.Request.UserHostAddress;
    }

    public static int GetStringLength(string S)
    {
        return System.Text.Encoding.Default.GetByteCount(S);
    }

    public static string XMLSerial(object obj)
    {
        System.Xml.Serialization.XmlSerializer XMLSer;
        System.IO.MemoryStream Stm;
        byte[] XMLArray;
        string RetValue;

        XMLSer = new System.Xml.Serialization.XmlSerializer(obj.GetType());
        Stm = new System.IO.MemoryStream();
        XMLSer.Serialize(Stm, obj);

        Stm.Position = 0;

        XMLArray = new byte[Stm.Length - 1 + 1];
        Stm.Read(XMLArray, 0, XMLArray.Length);
        Stm.Dispose();
        Stm = null;

        RetValue = System.Text.Encoding.UTF8.GetString(XMLArray);

        return RetValue;
    }

    public static object XMLDeserial(string xmlContent, Type objType)
    {
        System.Xml.Serialization.XmlSerializer XMLSer;
        System.IO.MemoryStream Stm;
        byte[] XMLArray;
        object RetValue = null;

        if (xmlContent != string.Empty)
        {
            XMLArray = System.Text.Encoding.UTF8.GetBytes(xmlContent);

            Stm = new System.IO.MemoryStream();
            Stm.Write(XMLArray, 0, XMLArray.Length);
            Stm.Position = 0;
            XMLSer = new System.Xml.Serialization.XmlSerializer(objType);

            RetValue = XMLSer.Deserialize(Stm);

            Stm.Dispose();
            Stm = null;
        }

        return RetValue;
    }

    public static string AESEncrypt(byte[] data, string Key)
    {
        byte[] KeyData = System.Text.Encoding.UTF8.GetBytes(Key);
        byte[] AES_IV = new byte[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; //Encoding.UTF8.GetBytes("0000000000000000");
        byte[] RetData;

        System.Security.Cryptography.AesCryptoServiceProvider aes = new System.Security.Cryptography.AesCryptoServiceProvider();
        System.Security.Cryptography.ICryptoTransform Enc = aes.CreateEncryptor(KeyData, AES_IV);
        RetData = Enc.TransformFinalBlock(data, 0, data.Length);

        return Convert.ToBase64String(RetData);
    }

    public static byte[] AESDecrypt(string s, string Key)
    {
        byte[] KeyData = System.Text.Encoding.UTF8.GetBytes(Key);
        byte[] AES_IV = new byte[] { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; //Encoding.UTF8.GetBytes("0000000000000000");
        byte[] SourceData;

        SourceData = Convert.FromBase64String(s);
        System.Security.Cryptography.AesCryptoServiceProvider aes = new System.Security.Cryptography.AesCryptoServiceProvider();
        System.Security.Cryptography.ICryptoTransform Dec = aes.CreateDecryptor(KeyData, AES_IV);

        return Dec.TransformFinalBlock(SourceData, 0, SourceData.Length);
    }

    public static string GetSHA256(string data, bool Base64Encoding = true)
    {
        return GetSHA256(System.Text.Encoding.UTF8.GetBytes(data), Base64Encoding);
    }

    public static string GetSHA256(byte[] data, bool Base64Encoding = true)
    {
        System.Security.Cryptography.SHA256 sha256 = new System.Security.Cryptography.SHA256CryptoServiceProvider();
        byte[] hash;
        System.Text.StringBuilder RetValue = new System.Text.StringBuilder();

        hash = sha256.ComputeHash(data);

        if (Base64Encoding)
        {
            RetValue.Append(System.Convert.ToBase64String(hash));
        }
        else
        {
            foreach (byte EachByte in hash)
            {
                string ByteStr = EachByte.ToString("x");

                ByteStr = new string('0', 2 - ByteStr.Length) + ByteStr;
                RetValue.Append(ByteStr);
            }
        }

        sha256.Dispose();
        sha256 = null;

        return RetValue.ToString();
    }

    public static string GetMD5(string DataString, bool Base64Encoding = true)
    {
        return GetMD5(System.Text.Encoding.UTF8.GetBytes(DataString), Base64Encoding);
    }

    public static string GetMD5(byte[] Data, bool Base64Encoding = true)
    {
        System.Security.Cryptography.MD5CryptoServiceProvider MD5Provider = new System.Security.Cryptography.MD5CryptoServiceProvider();
        byte[] hash;
        System.Text.StringBuilder RetValue = new System.Text.StringBuilder();

        hash = MD5Provider.ComputeHash(Data);
        MD5Provider = null;

        if (Base64Encoding)
        {
            RetValue.Append(System.Convert.ToBase64String(hash));
        }
        else
        {
            foreach (byte EachByte in hash)
            {
                string ByteStr = EachByte.ToString("x");

                ByteStr = new string('0', 2 - ByteStr.Length) + ByteStr;
                RetValue.Append(ByteStr);
            }
        }


        return RetValue.ToString();
    }

    public class TrustAllCertificatePolicy : System.Net.ICertificatePolicy
    {
        public bool CheckValidationResult(System.Net.ServicePoint srvPoint, System.Security.Cryptography.X509Certificates.X509Certificate certificate, System.Net.WebRequest request, int certificateProblem)
        {
            return true;
        }
    }

    public enum enumSendMailType {
        Register = 0,
        ForgetPassword = 1,
        ThanksLetter = 2
    }

}
