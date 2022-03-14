<%@ WebService Language="C#" Class="LobbyAPI" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Collections;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using System.Linq;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允許使用 ASP.NET AJAX 從指令碼呼叫此 Web 服務，請取消註解下列一行。
// [System.Web.Script.Services.ScriptService]
[System.ComponentModel.ToolboxItem(false)]
[System.Web.Script.Services.ScriptService]
public class LobbyAPI : System.Web.Services.WebService {



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult HeartBeat(string GUID, string Echo) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();

        return lobbyAPI.HeartBeat(GUID, Echo);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult AddUserBankCard(string WebSID, string GUID, string CurrencyType, int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string Description) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.AddUserBankCard(GetToken(), SI.EWinSID, GUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, Description);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserBankCardState(string WebSID, string GUID, string BankCardGUID, int BankCardState) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.SetUserBankCardState(GetToken(), SI.EWinSID, GUID, BankCardGUID, BankCardState);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult UserAccountTransfer(string WebSID, string GUID, string DstLoginAccount, string DstCurrencyType, string SrcCurrencyType, decimal TransOutValue, string WalletPassword, string Description) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.UserAccountTransfer(GetToken(), SI.EWinSID, GUID, DstLoginAccount, DstCurrencyType, SrcCurrencyType, TransOutValue, WalletPassword, Description);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult ConfirmUserAccountTransfer(string WebSID, string GUID, string TransferGUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.ConfirmUserAccountTransfer(GetToken(), SI.EWinSID, GUID, TransferGUID);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.TransferHistoryResult GetTransferHistory(string WebSID, string GUID, string BeginDate, string EndDate) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetTransferHistory(GetToken(), SI.EWinSID, GUID, BeginDate, EndDate);
        } else {
            var R = new EWin.Lobby.TransferHistoryResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult RemoveUserBankCard(string WebSID, string GUID, string BankCardGUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.RemoveUserBankCard(GetToken(), SI.EWinSID, GUID, BankCardGUID);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult UpdateUserBankCard(string WebSID, string GUID, string BankCardGUID, string CurrencyType, int PaymentMethod, string BankName, string BranchName, string BankNumber, string AccountName, string Description) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.UpdateUserBankCard(GetToken(), SI.EWinSID, GUID, BankCardGUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, Description);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.UserBankCardListResult GetUserBankCard(string WebSID, string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetUserBankCard(GetToken(), SI.EWinSID, GUID);
        } else {
            var R = new EWin.Lobby.UserBankCardListResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetSIDParam(string WebSID, string GUID, string ParamName) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetSIDParam(GetToken(), SI.EWinSID, GUID, ParamName);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetSIDParam(string WebSID, string GUID, string ParamName, string ParamValue) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.SetSIDParam(GetToken(), SI.EWinSID, GUID, ParamName, ParamValue);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult KeepSID(string WebSID, string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            if (RedisCache.SessionContext.RefreshSID(WebSID) == true) {
                return lobbyAPI.KeepSID(GetToken(), SI.EWinSID, GUID);
            } else {
                var R = new EWin.Lobby.APIResult() {
                    Result = EWin.Lobby.enumResult.ERR,
                    Message = "InvalidWebSID",
                    GUID = GUID
                };

                return R;
            }
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };

            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckAccountExist(string GUID, string LoginAccount) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CheckAccountExist(GetToken(), GUID, LoginAccount);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult RequireRegister(string GUID, string ParentPersonCode, EWin.Lobby.PropertySet[] PS, EWin.Lobby.UserBankCard[] UBC) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.RequireRegister(GetToken(), GUID, ParentPersonCode, PS, UBC);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CreateAccount(string GUID, string LoginAccount, string LoginPassword, string ParentPersonCode, string CurrencyList, EWin.Lobby.PropertySet[] PS) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CreateAccount(GetToken(), GUID, LoginAccount, LoginPassword, ParentPersonCode, CurrencyList, PS);
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetLoginAccount(string GUID, string PhonePrefix, string PhoneNumber) {
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() {
            Result = EWin.Lobby.enumResult.ERR
        };

        TelPhoneNormalize telPhoneNormalize = new TelPhoneNormalize(PhonePrefix, PhoneNumber);

        if (telPhoneNormalize.PhoneIsValid) {
            R.Result = EWin.Lobby.enumResult.OK;
            R.Message = telPhoneNormalize.PhonePrefix + telPhoneNormalize.PhoneNumber;

        } else {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "NormalizeError";
        }

        return R;
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.CompanySiteResult GetCompanySite(string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.GetCompanySite(GetToken(), GUID);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public LoginMessageResult GetLoginMessage(string WebSID, string GUID)
    {
        RedisCache.SessionContext.SIDInfo SI;
        LoginMessageResult R = new LoginMessageResult() { Result = EWin.Lobby.enumResult.ERR };
        Newtonsoft.Json.Linq.JObject SettingData;
        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID))
        {
            SettingData = EWinWeb.GetSettingJObj();
            if (SettingData != null)
            {
                if (SettingData["LoginMessage"] != null)
                {
                    R.Message = SettingData["LoginMessage"]["Message"].ToString();
                    R.Version = SettingData["LoginMessage"]["Version"].ToString();
                    R.Result = EWin.Lobby.enumResult.OK;
                }
                else
                {
                    R.Result = EWin.Lobby.enumResult.ERR;
                    R.Message = "NoData";
                }
            }
            else
            {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        }
        else
        {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "InvalidWebSID";
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.CompanyGameCodeExchangeResult GetCompanyGameCodeExchange(string GUID, string CurrencyType, string GameBrand, string GameCode) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        var aa = GetToken();
        return lobbyAPI.GetCompanyGameCodeExchange(GetToken(), GUID, CurrencyType, GameBrand, GameCode);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.UserInfoResult GetUserInfo(string WebSID, string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetUserInfo(GetToken(), SI.EWinSID, GUID);
        } else {
            var R = new EWin.Lobby.UserInfoResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.UserBalanceResult GetUserBalance(string WebSID, string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetUserBalance(GetToken(), SI.EWinSID, GUID);
        } else {
            var R = new EWin.Lobby.UserBalanceResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.CompanyGameCodeResult GetCompanyGameCode(string GUID) {
        EWin.Lobby.CompanyGameCodeResult R = new EWin.Lobby.CompanyGameCodeResult();

        var CompanyGameCodeString = RedisCache.Company.GetCompanyGameCodeString();
        if (CompanyGameCodeString != null && CompanyGameCodeString != string.Empty) {
            R.Result = EWin.Lobby.enumResult.OK;
            R.GameCodeList = Newtonsoft.Json.JsonConvert.DeserializeObject<EWin.Lobby.GameCodeItem[]>(CompanyGameCodeString);
        } else {
            EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
            R = lobbyAPI.GetCompanyGameCode(GetToken(), GUID);

            RedisCache.Company.UpdateCompanyGameCode(Newtonsoft.Json.JsonConvert.SerializeObject(R.GameCodeList));
        }
        return R;

    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult GetCompanyMarqueeText(string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.GetCompanyMarqueeText(GetToken(), GUID);
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.GameOrderDetailListResult GetGameOrderDetailHistoryBySummaryDate(string WebSID, string GUID, string QueryDate) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetGameOrderDetailHistoryBySummaryDate(GetToken(), SI.EWinSID, GUID, QueryDate);
        } else {
            var R = new EWin.Lobby.GameOrderDetailListResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.GameOrderDetailListResult GetGameOrderHistoryBySummaryDateAndGameCode(string WebSID, string GUID, string QueryDate) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.GameOrderDetailListResult callResult = new EWin.Lobby.GameOrderDetailListResult();
        EWin.Lobby.GameOrderDetailListResult R;
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            callResult = lobbyAPI.GetGameOrderDetailHistoryBySummaryDate(GetToken(), SI.EWinSID, GUID, QueryDate);
            if (callResult.Result == EWin.Lobby.enumResult.OK) {
                R = new EWin.Lobby.GameOrderDetailListResult() {
                    Result = EWin.Lobby.enumResult.OK,
                    GUID = GUID
                };

                R.DetailList = callResult.DetailList.GroupBy(x => new { x.GameCode, x.CurrencyType, x.SummaryDate }, x => x, (key, detail) => new EWin.Lobby.GameOrderDetail {
                    GameCode = key.GameCode,
                    ValidBetValue = detail.Sum(y => y.ValidBetValue),
                    BuyChipValue = detail.Sum(y => y.BuyChipValue),
                    RewardValue = detail.Sum(y => y.RewardValue),
                    OrderValue = detail.Sum(y => y.OrderValue),
                    SummaryType = detail.FirstOrDefault().SummaryType,
                    GameAccountingCode = detail.FirstOrDefault().GameAccountingCode,
                    CurrencyType = key.CurrencyType,
                    LoginAccount = detail.FirstOrDefault().LoginAccount,
                    RealName = detail.FirstOrDefault().RealName,
                    SummaryDate = key.SummaryDate
                }).ToArray();

            } else {
                R = callResult;
            }
        } else {
            R = new EWin.Lobby.GameOrderDetailListResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.OrderSummaryResult GetGameOrderSummaryHistoryGroupGameCode(string WebSID, string GUID, string QueryBeginDate, string QueryEndDate) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.OrderSummaryResult callResult = new EWin.Lobby.OrderSummaryResult();
        EWin.Lobby.OrderSummaryResult R;
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            callResult = lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, GUID, QueryBeginDate, QueryEndDate);
            if (callResult.Result == EWin.Lobby.enumResult.OK) {
                R = new EWin.Lobby.OrderSummaryResult() {
                    Result = EWin.Lobby.enumResult.OK,
                    GUID = GUID
                };

                R.SummaryList = callResult.SummaryList.GroupBy(x => new { x.CurrencyType, x.SummaryDate }, x => x, (key, sum) => new EWin.Lobby.OrderSummary {
                    ValidBetValue = sum.Sum(y => y.ValidBetValue),
                    RewardValue = sum.Sum(y => y.RewardValue),
                    OrderValue = sum.Sum(y => y.OrderValue),
                    TotalValidBetValue = sum.Sum(y => y.TotalValidBetValue),
                    TotalRewardValue = sum.Sum(y => y.TotalRewardValue),
                    TotalOrderValue = sum.Sum(y => y.TotalOrderValue),
                    CurrencyType = key.CurrencyType,
                    LoginAccount = sum.FirstOrDefault().LoginAccount,
                    SummaryDate = key.SummaryDate
                }).ToArray();

            } else {
                R = callResult;
            }
        } else {
            R = new EWin.Lobby.OrderSummaryResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
        }

        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.OrderSummaryResult GetGameOrderSummaryHistory(string WebSID, string GUID, string QueryBeginDate, string QueryEndDate) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetGameOrderSummaryHistory(GetToken(), SI.EWinSID, GUID, QueryBeginDate, QueryEndDate);
        } else {
            var R = new EWin.Lobby.OrderSummaryResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetWalletPassword(string WebSID, string GUID, string LoginPassword, string NewWalletPassword) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.SetWalletPassword(GetToken(), SI.EWinSID, GUID, LoginPassword, NewWalletPassword);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserPassword(string WebSID, string GUID, string OldPassword, string NewPassword) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.SetUserPassword(GetToken(), SI.EWinSID, GUID, OldPassword, NewPassword);
        } else {
            var R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SendCSMail(string WebSID, string GUID, string EMail, string Topic, string SendBody) {
        EWin.Lobby.APIResult R;

        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID) || string.IsNullOrEmpty(EMail) == false) {
            if (string.IsNullOrEmpty(Topic) == false && string.IsNullOrEmpty(SendBody) == false) {
                string returnMail = string.IsNullOrEmpty(EMail) ? SI.LoginAccount : EMail;
                string returnLoginAccount = string.IsNullOrEmpty(SI.LoginAccount) ? "" : SI.LoginAccount;
                //string subjectString = String.Format("問題分類：{0},回覆信箱：{1}", Topic, returnMail);
                //string bodyString = String.Format("問題分類：{0}\r\n"
                //                        + "問題內容：{1}\r\n"
                //                        + "回覆信箱：{2}\r\n"
                //                        + "相關帳號：{3}\r\n"
                //                        + "詢問時間：{4}\r\n"
                //                        , Topic, SendBody, returnMail, returnLoginAccount, DateTime.Now);
                string subjectString = String.Format("お問い合わせ類型：{0},お返事のメールアドレス：{1}", Topic, returnMail);
                string bodyString = String.Format("お問い合わせ類型：{0}\r\n"
                                        + "お問い合わせ内容：{1}\r\n"
                                        + "お返事のメールアドレス：{2}\r\n"
                                        + "アカウント：{3}\r\n"
                                        + "お問い合わせ時間：{4}\r\n"
                                        , Topic, SendBody, returnMail, returnLoginAccount, DateTime.Now);

                /*
                お問い合わせ類型:
                お問い合わせ内容:
                お返事のメールアドレス:
                アカウント:
                お問い合わせ時間:
                */
                CodingControl.SendMail("smtp.gmail.com", new System.Net.Mail.MailAddress("Service <service@casino-maharaja.com>"), new System.Net.Mail.MailAddress("service@casino-maharaja.com"), subjectString, bodyString, "service@casino-maharaja.com", "goufeeqyyyerefjn", "utf-8", true);

                R = new EWin.Lobby.APIResult() {
                    Result = EWin.Lobby.enumResult.OK,
                    Message = "",
                    GUID = GUID
                };
            } else {
                R = new EWin.Lobby.APIResult() {
                    Result = EWin.Lobby.enumResult.ERR,
                    Message = "SubjectOrSendBodyIsEmpty",
                    GUID = GUID
                };
            }
        } else {
            R = new EWin.Lobby.APIResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "EMailNotFind",
                GUID = GUID
            };
        }

        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserPasswordByValidateCode(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode, string NewPassword) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.SetUserPasswordByValidateCode(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.ValidateCodeResult SetValidateCode(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetValidateCodeByMail(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, CodingControl.enumSendMailType SendMailType) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.ValidateCodeResult validateCodeResult;
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { GUID = GUID, Result = EWin.Lobby.enumResult.ERR };

        validateCodeResult = lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);

        if (validateCodeResult.Result == EWin.Lobby.enumResult.OK) {
            R = SendMail(EMail, validateCodeResult.ValidateCode, R, SendMailType);
        } else {
            R.Result = validateCodeResult.Result;
            R.Message = validateCodeResult.Message;
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CheckValidateCode(string GUID, EWin.Lobby.enumValidateType ValidateType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber, string ValidateCode) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.CheckValidateCode(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode);
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.PaymentResult GetPaymentHistory(string WebSID, string GUID, string BeginDate, string EndDate) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return lobbyAPI.GetPaymentHistory(GetToken(), SI.EWinSID, GUID, BeginDate, EndDate);
        } else {
            var R = new EWin.Lobby.PaymentResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.CompanyExchangeResult GetCompanyExchange(string GUID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        return lobbyAPI.GetCompanyExchange(GetToken(), GUID);
    }

    private EWin.Lobby.APIResult SendMail(string EMail, string ValidateCode, EWin.Lobby.APIResult result, CodingControl.enumSendMailType SendMailType) {
        string Subject = string.Empty;
        string SendBody = string.Empty;
        Subject = "Verify Code";

        SendBody = CodingControl.GetEmailTemp(EMail, ValidateCode, SendMailType);

        try {
            //CodingControl.SendMail("smtp.gmail.com", new System.Net.Mail.MailAddress("Service <service@OCW888.com>"), new System.Net.Mail.MailAddress(EMail), Subject, SendBody, "service@OCW888.com", "koajejksxfyiwixx", "utf-8", true);
            CodingControl.SendMail("smtp.gmail.com", new System.Net.Mail.MailAddress("Service <service@casino-maharaja.com>"), new System.Net.Mail.MailAddress(EMail), Subject, SendBody, "service@casino-maharaja.com", "goufeeqyyyerefjn", "utf-8", true);
            result.Result = EWin.Lobby.enumResult.OK;
            result.Message = "";

        } catch (Exception ex) {
            result.Result = EWin.Lobby.enumResult.ERR;
            result.Message = "";
        }
        return result;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SetUserMail(string GUID, EWin.Lobby.enumValidateType ValidateType, CodingControl.enumSendMailType SendMailType, string EMail, string ContactPhonePrefix, string ContactPhoneNumber) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.ValidateCodeResult validateCodeResult;
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { GUID = GUID, Result = EWin.Lobby.enumResult.ERR };
        string ValidateCode = string.Empty;
        TelPhoneNormalize telPhoneNormalize = new TelPhoneNormalize(ContactPhonePrefix, ContactPhoneNumber);
        if (telPhoneNormalize != null) {
            ContactPhonePrefix = telPhoneNormalize.PhonePrefix;
            ContactPhoneNumber = telPhoneNormalize.PhoneNumber;
        }

        switch (SendMailType) {
            case CodingControl.enumSendMailType.Register:
                validateCodeResult = lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);
                if (validateCodeResult.Result == EWin.Lobby.enumResult.OK) {
                    ValidateCode = validateCodeResult.ValidateCode;
                }
                break;
            case CodingControl.enumSendMailType.ForgetPassword:
                validateCodeResult = lobbyAPI.SetValidateCodeOnlyNumber(GetToken(), GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber);
                if (validateCodeResult.Result == EWin.Lobby.enumResult.OK) {
                    ValidateCode = validateCodeResult.ValidateCode;
                }
                break;
            case CodingControl.enumSendMailType.ThanksLetter:

                break;
        }

        switch (ValidateType) {
            case EWin.Lobby.enumValidateType.EMail:
                R = SendMail(EMail, ValidateCode, R, SendMailType);
                break;
            case EWin.Lobby.enumValidateType.PhoneNumber:
                string smsContent = "新規登録確認コード(" + ValidateCode + "）" + "\r\n" + "カジノマハラジャをお選びいただき、ありがとうございます。";
                R = SendSMS(GUID, "0", 0, ContactPhonePrefix + ContactPhoneNumber, smsContent);
                break;
            default:
                break;
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult SendSMS(string GUID, string SMSTypeCode, int RecvUserAccountID, string ContactNumber, string SendContent) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        EWin.Lobby.APIResult R = new EWin.Lobby.APIResult() { GUID = GUID, Result = EWin.Lobby.enumResult.ERR };
        string ValidateCode = string.Empty;

        R = lobbyAPI.SendSMS(GetToken(), GUID, SMSTypeCode, RecvUserAccountID, ContactNumber, SendContent);

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.PaymentResult CreatePayment(string WebSID, string GUID, decimal Value, int PaymentMethodID) {
        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            return null;
        } else {
            var R = new EWin.Lobby.PaymentResult() {
                Result = EWin.Lobby.enumResult.ERR,
                Message = "InvalidWebSID",
                GUID = GUID
            };
            return R;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public BulletinBoardResult GetBulletinBoard(string GUID) {

        BulletinBoardResult R = new BulletinBoardResult() { Datas = new List<BulletinBoard>(), Result = EWin.Lobby.enumResult.ERR };
        System.Data.DataTable DT;
        RedisCache.SessionContext.SIDInfo SI;

        DT = RedisCache.BulletinBoard.GetBulletinBoard();
        if (DT != null && DT.Rows.Count > 0) {
            for (int i = 0; i < DT.Rows.Count; i++) {
                var data = new BulletinBoard();
                if ((int)DT.Rows[i]["State"] == 0) {
                    data.BulletinBoardID = (int)DT.Rows[i]["BulletinBoardID"];
                    data.BulletinTitle = (string)DT.Rows[i]["BulletinTitle"];
                    data.BulletinContent = (string)DT.Rows[i]["BulletinContent"];
                    data.CreateDate = (DateTime)DT.Rows[i]["CreateDate"];
                    data.State = (int)DT.Rows[i]["State"];
                    R.Datas.Add(data);
                }
            }

            if (R.Datas.Count > 0) {
                R.Result = (int)EWin.Lobby.enumResult.OK;
            } else {
                R.Result = EWin.Lobby.enumResult.ERR;
                R.Message = "NoData";
            }
        } else {
            R.Result = EWin.Lobby.enumResult.ERR;
            R.Message = "NoData";
        }


        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public EWin.Lobby.APIResult CreateBigEagle(string LoginAccount) {
        EWin.OCW.OCW OCWAPI = new EWin.OCW.OCW();
        EWin.OCW.APIResult OcwAPIResult = OCWAPI.CreateBigEagle(LoginAccount);
        EWin.Lobby.APIResult result = new EWin.Lobby.APIResult();

        if (OcwAPIResult.ResultState == EWin.OCW.enumResultState.OK) {
            result.Result = EWin.Lobby.enumResult.OK;
        } else {
            result.Result = EWin.Lobby.enumResult.ERR;
            result.Message = OcwAPIResult.Message;
        }

        return result;
    }

    private string GetToken() {
        string Token;
        int RValue;
        Random R = new Random();
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        return Token;
    }

    public class BulletinBoardResult : EWin.Lobby.APIResult {
        public List<BulletinBoard> Datas { get; set; }
    }

    public class BulletinBoard {
        public int BulletinBoardID { get; set; }
        public string BulletinTitle { get; set; }
        public string BulletinContent { get; set; }
        public DateTime CreateDate { get; set; }
        public int State { get; set; }
    }

    public class LoginMessageResult : EWin.Lobby.APIResult
    {
        public string Message { get; set; }
        public string Version { get; set; }
    }
}