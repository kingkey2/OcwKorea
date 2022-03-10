using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

public class WebController : ApiController
{
    // GET api/<controller>


    // POST api/<controller>
    public ReturnValue SendMail([FromBody] SnedMailBody body)
    {
        ReturnValue ret = new ReturnValue();
        string Subject;
        string SendBody;
        if (body.SendType == 0)
        {
            Subject = "Verify Code";
            SendBody = " 您的驗證碼為 " + body.ValidateCode + "，" + "請您於10分鐘內驗證，如超過時間，請重新發送驗證碼。 <br/><br/>" +
                   " 您的验证码为 " + body.ValidateCode + "，" + "请您于10分钟内验证，如超过时间，请重新发送验证码。 <br/><br/>" +
                   " Your verification code is " + body.ValidateCode + "，" + "Please verify within 10 minutes. If the time is exceeded, please resend the verification code. <br/><br/>" +
                   " 인증 코드는_______ 입니다. " + body.ValidateCode + "，" + "10분 내에 인증을 완료하여야 합니다. 10분 내에 인증하지 않을 시 인증코드를 재 발송 신청을 부탁드립니다. <br/><br/>";
            try{
                CodingControl.SendMail("smtp.gmail.com", new System.Net.Mail.MailAddress("Service <mail@ewin-soft.com>"), new System.Net.Mail.MailAddress(body.EMail), Subject, SendBody, "noel@kingkey.com.tw", "KK780507#", "utf-8", true);
                ret.ResultCode = 0;
                ret.Message = "";

            }
            catch (Exception ex){
                ret.ResultCode = 1;
                ret.Message = ex.ToString();
            }

        }
        return ret;
    }

    public class ReturnValue
    {
        public int ResultCode { get; set; }
        public string Message { get; set; }
    }

    public class SnedMailBody
    {
        public string EMail { get; set; }

        public string ValidateCode { get; set; }

        public int SendType { get; set; }
    }

}
