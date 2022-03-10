<%@ WebService Language="C#" Class="PaymentAPI" %>

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
public class PaymentAPI : System.Web.Services.WebService
{
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult HeartBeat(string GUID, string Echo)
    {
        APIResult R = new APIResult();
        R.Result = enumResult.OK;
        R.Message = Echo;

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentMethodResult GetPaymentMethodByCategory(string WebSID, string GUID, string PaymentCategoryCode, int PaymentType)
    {
        RedisCache.SessionContext.SIDInfo SI;
        PaymentMethodResult R = new PaymentMethodResult() { GUID = GUID, Result = enumResult.ERR, PaymentMethodResults = new List<PaymentMethod>() };
        System.Data.DataTable DT = new System.Data.DataTable();
        DT = RedisCache.PaymentMethod.GetPaymentMethodByCategory(PaymentCategoryCode);

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            if (DT != null) {
                if (DT.Rows.Count > 0) {
                    R.Result = enumResult.OK;
                    R.PaymentMethodResults = EWinWeb.ToList<PaymentMethod>(DT).Where(x => x.PaymentType == PaymentType).ToList();
                } else {
                    SetResultException(R, "NoData");
                }
            } else {
                SetResultException(R, "NoData");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ActivityCore.DepositActivitiesResult GetDepositActivityInfoByOrderNumber(string WebSID, string GUID, string OrderNumber)
    {
        RedisCache.SessionContext.SIDInfo SI;
        ActivityCore.DepositActivitiesResult R = new ActivityCore.DepositActivitiesResult() { GUID = GUID, Result = ActivityCore.enumActResult.ERR };
        PaymentCommonData TempCryptoData;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            TempCryptoData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);

            if (TempCryptoData != null) {
                R = ActivityCore.GetDepositAllResult(TempCryptoData.Amount, TempCryptoData.PaymentCode, TempCryptoData.LoginAccount);
            } else {
                ActivityCore.SetResultException(R, "OrderNotExist");
            }
        } else {
            ActivityCore.SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonResult CreateCryptoDeposit(string WebSID, string GUID, decimal Amount, int PaymentMethodID)
    {
        PaymentCommonResult R = new PaymentCommonResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData PaymentCommonData = new PaymentCommonData() { PaymentCryptoDetailList = new List<CryptoDetail>() };


        RedisCache.SessionContext.SIDInfo SI;
        string PaymentMethodName;
        string PaymentCode;
        string ReceiveCurrencyType;
        string MultiCurrencyInfo;
        int MinLimit;
        int MaxLimit;
        int DailyMaxAmount;
        int DailyMaxCount;
        decimal ReceiveTotalAmount;
        decimal HandingFeeRate;
        int HandingFeeAmount;
        decimal ThresholdRate;
        int WalletType;
        decimal DepositAmountByDay;
        int DepositCountByDay;
        int ExpireSecond;
        bool GetExchangeRateSuccess = true;
        System.Data.DataTable PaymentMethodDT;


        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            PaymentMethodDT = RedisCache.PaymentMethod.GetPaymentMethodByID(PaymentMethodID);

            if (PaymentMethodDT != null && PaymentMethodDT.Rows.Count > 0) {
                if ((int)PaymentMethodDT.Rows[0]["State"] == 0) {
                    if ((int)PaymentMethodDT.Rows[0]["PaymentType"] == 0) {
                        MinLimit = (int)PaymentMethodDT.Rows[0]["MinLimit"];
                        MaxLimit = (int)PaymentMethodDT.Rows[0]["MaxLimit"];
                        DailyMaxCount = (int)PaymentMethodDT.Rows[0]["DailyMaxCount"];
                        DailyMaxAmount = (int)PaymentMethodDT.Rows[0]["DailyMaxAmount"];

                        if (Amount >= MinLimit) {
                            if (Amount <= MaxLimit || MaxLimit == 0) {
                                System.Data.DataTable SummaryDT = RedisCache.UserAccountSummary.GetUserAccountSummary(SI.LoginAccount, DateTime.Now);

                                if (SummaryDT != null && SummaryDT.Rows.Count > 0) {
                                    DepositAmountByDay = (decimal)SummaryDT.Rows[0]["DepositAmount"];
                                    DepositCountByDay = (int)SummaryDT.Rows[0]["DepositCount"];
                                } else {
                                    DepositAmountByDay = 0;
                                    DepositCountByDay = 0;
                                }

                                if (DailyMaxCount == 0 || (DepositCountByDay + 1) <= DailyMaxCount) {
                                    if (DailyMaxAmount == 0 || (DepositAmountByDay + Amount) <= DailyMaxAmount) {
                                        if ((int)PaymentMethodDT.Rows[0]["EWinPaymentType"] == 2) {
                                            PaymentMethodName = (string)PaymentMethodDT.Rows[0]["PaymentName"];
                                            PaymentCode = (string)PaymentMethodDT.Rows[0]["PaymentCode"];
                                            ReceiveCurrencyType = (string)PaymentMethodDT.Rows[0]["CurrencyType"];
                                            ThresholdRate = (decimal)PaymentMethodDT.Rows[0]["ThresholdRate"];
                                            HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                                            HandingFeeAmount = (int)PaymentMethodDT.Rows[0]["HandingFeeAmount"];
                                            ExpireSecond = (int)PaymentMethodDT.Rows[0]["ExpireSecond"];
                                            WalletType = (int)PaymentMethodDT.Rows[0]["EWinCryptoWalletType"];
                                            MultiCurrencyInfo = (string)PaymentMethodDT.Rows[0]["MultiCurrencyInfo"];
                                            ReceiveTotalAmount = (Amount * (1 + HandingFeeRate)) + HandingFeeAmount;


                                            if (!string.IsNullOrEmpty(MultiCurrencyInfo)) {
                                                Newtonsoft.Json.Linq.JArray MultiCurrency = Newtonsoft.Json.Linq.JArray.Parse(MultiCurrencyInfo);

                                                foreach (var item in MultiCurrency) {
                                                    string TokenCurrency;
                                                    decimal ExchangeRate;
                                                    decimal PartialRate;

                                                    TokenCurrency = item["Currency"].ToString();
                                                    ExchangeRate = CryptoExpand.GetCryptoExchangeRate(TokenCurrency);

                                                    if (ExchangeRate == 0) {
                                                        //表示取得匯率失敗
                                                        GetExchangeRateSuccess = false;
                                                        break;
                                                    } else {
                                                        PartialRate = (decimal)item["Rate"];

                                                        CryptoDetail Dcd = new CryptoDetail() {
                                                            TokenCurrencyType = TokenCurrency,
                                                            TokenContractAddress = item["TokenContractAddress"].ToString(),
                                                            ExchangeRate = CodingControl.FormatDecimal(ExchangeRate, 6),
                                                            PartialRate = PartialRate,
                                                            ReceiveAmount = CodingControl.FormatDecimal(ReceiveTotalAmount * PartialRate * ExchangeRate, 6),
                                                        };

                                                        PaymentCommonData.PaymentCryptoDetailList.Add(Dcd);
                                                    }
                                                }
                                            } else {
                                                decimal ExchangeRate;
                                                decimal ReceiveAmount;

                                                ExchangeRate = CryptoExpand.GetCryptoExchangeRate(ReceiveCurrencyType);
                                                ReceiveAmount = Amount * ExchangeRate;

                                                if (ExchangeRate == 0) {
                                                    //表示取得匯率失敗
                                                    GetExchangeRateSuccess = false;
                                                } else {
                                                    CryptoDetail Dcd = new CryptoDetail() {
                                                        TokenCurrencyType = ReceiveCurrencyType,
                                                        TokenContractAddress = (string)PaymentMethodDT.Rows[0]["TokenContractAddress"],
                                                        ExchangeRate = CodingControl.FormatDecimal(ExchangeRate, 6),
                                                        PartialRate = 1,
                                                        ReceiveAmount = CodingControl.FormatDecimal(ReceiveTotalAmount * 1 * ExchangeRate, 6),
                                                    };

                                                    PaymentCommonData.PaymentCryptoDetailList.Add(Dcd);
                                                }
                                            }

                                            if (GetExchangeRateSuccess) {
                                                string OrderNumber = System.Guid.NewGuid().ToString();
                                                int InsertRet;

                                                PaymentCommonData.PaymentType = 0;
                                                PaymentCommonData.BasicType = 2;
                                                PaymentCommonData.WalletType = WalletType;
                                                PaymentCommonData.OrderNumber = OrderNumber;
                                                PaymentCommonData.LoginAccount = SI.LoginAccount;
                                                PaymentCommonData.Amount = Amount;
                                                PaymentCommonData.ReceiveTotalAmount = ReceiveTotalAmount;
                                                PaymentCommonData.HandingFeeRate = HandingFeeRate;
                                                PaymentCommonData.HandingFeeAmount = HandingFeeAmount;
                                                PaymentCommonData.ExpireSecond = ExpireSecond;
                                                PaymentCommonData.PaymentMethodID = PaymentMethodID;
                                                PaymentCommonData.PaymentMethodName = PaymentMethodName;
                                                PaymentCommonData.PaymentCode = PaymentCode;
                                                PaymentCommonData.ThresholdRate = ThresholdRate;
                                                PaymentCommonData.ThresholdValue = Amount * ThresholdRate;
                                                PaymentCommonData.CreateDate = DateTime.Now.ToString("yyyy/MM/dd hh:mm");

                                                InsertRet = EWinWebDB.UserAccountPayment.InsertPayment(OrderNumber, PaymentCommonData.PaymentType, 2, PaymentCommonData.LoginAccount, PaymentCommonData.Amount, PaymentCommonData.HandingFeeRate, PaymentCommonData.HandingFeeAmount, PaymentCommonData.ThresholdRate, PaymentCommonData.ThresholdValue, PaymentCommonData.PaymentMethodID, "", "", Newtonsoft.Json.JsonConvert.SerializeObject(PaymentCommonData.PaymentCryptoDetailList), PaymentCommonData.ExpireSecond);

                                                if (InsertRet == 1) {
                                                    R.Result = enumResult.OK;
                                                    R.Data = PaymentCommonData;
                                                    RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(PaymentCommonData), PaymentCommonData.OrderNumber);
                                                } else {
                                                    SetResultException(R, "InsertFailure");
                                                }
                                            } else {
                                                SetResultException(R, "GetExchangeFailed");
                                            }
                                        } else {
                                            SetResultException(R, "PaymentMethodNotCrypto");
                                        }
                                    } else {
                                        SetResultException(R, "DailyAmountGreaterThanMaxlimit");
                                    }
                                } else {
                                    SetResultException(R, "DailyCountGreaterThanMaxlimit");
                                }
                            } else {
                                SetResultException(R, "AmountGreaterThanMaxlimit");
                            }
                        } else {
                            SetResultException(R, "AmountLessThanMinLimit");
                        }
                    } else {
                        SetResultException(R, "PaymentMethodNotSupportDeposit");
                    }
                } else {
                    SetResultException(R, "PaymentMethodDisable");
                }
            } else {
                SetResultException(R, "PaymentMethodNotExist");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult ConfirmCryptoDeposit(string WebSID, string GUID, string OrderNumber, string[] ActivityNames)
    {
        APIResult R = new APIResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData TempCryptoData;
        RedisCache.SessionContext.SIDInfo SI;
        EWinTagInfoData tagInfoData = new EWinTagInfoData() { };
        string JoinActivityFailedMsg = string.Empty;
        decimal PointValue;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            //取得Temp(未確認)訂單
            TempCryptoData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);

            if (TempCryptoData != null) {
                tagInfoData.PaymentMethodID = TempCryptoData.PaymentMethodID;
                tagInfoData.PaymentCode = TempCryptoData.PaymentCode;
                tagInfoData.PaymentMethodName = TempCryptoData.PaymentMethodName;
                tagInfoData.ThresholdRate = TempCryptoData.ThresholdRate;
                tagInfoData.ThresholdValue = TempCryptoData.ThresholdValue;
                PointValue = TempCryptoData.Amount;

                if (ActivityNames.Length > 0) {
                    tagInfoData.IsJoinDepositActivity = true;
                    tagInfoData.ActivityDatas = new List<EWinTagInfoActivityData>();
                    //有儲值參加活動
                    foreach (var ActivityName in ActivityNames) {
                        ActivityCore.DepositActivityResult activityDepositResult = ActivityCore.GetDepositResult(ActivityName, TempCryptoData.Amount, TempCryptoData.PaymentCode, TempCryptoData.LoginAccount);

                        if (activityDepositResult.Result == ActivityCore.enumActResult.OK) {
                            EWinTagInfoActivityData infoActivityData = new EWinTagInfoActivityData() {
                                ActivityName = ActivityName,
                                BonusRate = activityDepositResult.Data.BonusRate,
                                BonusValue = activityDepositResult.Data.BonusValue,
                                ThresholdRate = activityDepositResult.Data.ThresholdRate,
                                ThresholdValue = activityDepositResult.Data.ThresholdValue,
                            };
                            PointValue += activityDepositResult.Data.BonusValue;
                            tagInfoData.ActivityDatas.Add(infoActivityData);
                        } else {
                            JoinActivityFailedMsg += "Join " + ActivityName + " Failed,";
                            break;
                        }
                    }
                } else {
                    tagInfoData.IsJoinDepositActivity = false;
                    //沒參加儲值活動
                }

                if (string.IsNullOrEmpty(JoinActivityFailedMsg)) {
                    //準備送出至EWin

                    EWin.OCW.OCW ocwAPI = new EWin.OCW.OCW();
                    EWin.OCW.CompanyWalletResult walletDepositResult = ocwAPI.GetAvailableWalletDeposit(SI.EWinCT, (EWin.OCW.enumWalletType)TempCryptoData.WalletType);

                    if (walletDepositResult.ResultState == EWin.OCW.enumResultState.OK) {

                        EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                        EWin.Payment.PaymentResult paymentResult;
                        List<EWin.Payment.PaymentDetailWallet> paymentDetailWallets = new List<EWin.Payment.PaymentDetailWallet>();

                        //Description待實際測試後調整
                        string Decription = TempCryptoData.PaymentMethodName;

                        foreach (var paymentCryptoDetail in TempCryptoData.PaymentCryptoDetailList) {
                            EWin.Payment.PaymentDetailWallet paymentDetailWallet = new EWin.Payment.PaymentDetailWallet() {
                                WalletType = (EWin.Payment.enumWalletType)TempCryptoData.WalletType,
                                Status = EWin.Payment.enumDetailWalletStatus.DetailCreated,
                                ToWalletAddress = walletDepositResult.WalletPublicAddress,
                                TokenName = paymentCryptoDetail.TokenCurrencyType,
                                TokenContractAddress = paymentCryptoDetail.TokenContractAddress,
                                TokenAmount = paymentCryptoDetail.ReceiveAmount
                            };

                            Decription += ", TokenName=" + paymentCryptoDetail.TokenCurrencyType + " TokenAmount=" + paymentCryptoDetail.ReceiveAmount.ToString("F10");
                            paymentDetailWallets.Add(paymentDetailWallet);
                        }
                        paymentResult = paymentAPI.CreatePaymentDeposit(GetToken(), TempCryptoData.LoginAccount, GUID, EWinWeb.MainCurrencyType, OrderNumber, TempCryptoData.Amount, Decription, true, PointValue, TempCryptoData.PaymentCode, CodingControl.GetUserIP(), TempCryptoData.ExpireSecond, paymentDetailWallets.ToArray());
                        if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                            EWin.Payment.Result updateTagResult = paymentAPI.UpdateTagInfo(GetToken(), GUID, paymentResult.PaymentSerial, Newtonsoft.Json.JsonConvert.SerializeObject(tagInfoData));

                            if (updateTagResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {

                                int UpdateRet = EWinWebDB.UserAccountPayment.ConfirmPayment(OrderNumber, walletDepositResult.WalletPublicAddress, paymentResult.PaymentSerial, PointValue, Newtonsoft.Json.JsonConvert.SerializeObject(tagInfoData.ActivityDatas));

                                if (UpdateRet == 1) {
                                    TempCryptoData.PointValue = PointValue;
                                    TempCryptoData.ActivityDatas = tagInfoData.ActivityDatas;
                                    TempCryptoData.PaymentSerial = paymentResult.PaymentSerial;
                                    TempCryptoData.ToWalletAddress = walletDepositResult.WalletPublicAddress;
                                    RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(TempCryptoData), OrderNumber, TempCryptoData.ExpireSecond);
                                    RedisCache.PaymentContent.KeepPaymentContents(TempCryptoData, SI.LoginAccount, TempCryptoData.ExpireSecond);
                                    R.Result = enumResult.OK;
                                    Newtonsoft.Json.Linq.JObject ret = new Newtonsoft.Json.Linq.JObject();
                                    ret["WalletPublicAddress"] = walletDepositResult.WalletPublicAddress;
                                    ret["PaymentSerial"] = paymentResult.PaymentSerial;
                                    R.Message = ret.ToString();
                                } else {
                                    SetResultException(R, "UpdateFailure");
                                }

                            } else {
                                SetResultException(R, updateTagResult.ResultMessage);
                                paymentAPI.CancelPayment(GetToken(), GUID, paymentResult.PaymentSerial);
                                ocwAPI.FinishCompanyWallet(SI.EWinCT, (EWin.OCW.enumWalletType)TempCryptoData.WalletType, walletDepositResult.WalletPublicAddress);
                            }
                        } else {
                            SetResultException(R, paymentResult.ResultMessage);
                        }

                    } else {
                        SetResultException(R, "WalletAddressCanNotUse");
                    }
                } else {
                    JoinActivityFailedMsg = JoinActivityFailedMsg.Substring(0, JoinActivityFailedMsg.Length - 1);
                    SetResultException(R, JoinActivityFailedMsg);
                }
            } else {
                SetResultException(R, "OrderNotExist");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonResult CreateCommonDeposit(string WebSID, string GUID, decimal Amount, int PaymentMethodID)
    {
        PaymentCommonResult R = new PaymentCommonResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData paymentCommonData = new PaymentCommonData() { };

        RedisCache.SessionContext.SIDInfo SI;
        string PaymentMethodName;
        string PaymentCode;
        string ReceiveCurrencyType;
        int MinLimit;
        int MaxLimit;
        int DailyMaxAmount;
        int DailyMaxCount;
        decimal ReceiveTotalAmount;
        decimal HandingFeeRate;
        int HandingFeeAmount;
        decimal ThresholdRate;
        decimal DepositAmountByDay;
        int DepositCountByDay;
        int ExpireSecond;
        System.Data.DataTable PaymentMethodDT;


        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            PaymentMethodDT = RedisCache.PaymentMethod.GetPaymentMethodByID(PaymentMethodID);

            if (PaymentMethodDT != null && PaymentMethodDT.Rows.Count > 0) {
                if ((int)PaymentMethodDT.Rows[0]["State"] == 0) {
                    if ((int)PaymentMethodDT.Rows[0]["PaymentType"] == 0) {
                        MinLimit = (int)PaymentMethodDT.Rows[0]["MinLimit"];
                        MaxLimit = (int)PaymentMethodDT.Rows[0]["MaxLimit"];
                        DailyMaxCount = (int)PaymentMethodDT.Rows[0]["DailyMaxCount"];
                        DailyMaxAmount = (int)PaymentMethodDT.Rows[0]["DailyMaxAmount"];

                        if (Amount >= MinLimit) {
                            if (Amount <= MaxLimit || MaxLimit == 0) {
                                System.Data.DataTable SummaryDT = RedisCache.UserAccountSummary.GetUserAccountSummary(SI.LoginAccount, DateTime.Now);

                                if (SummaryDT != null && SummaryDT.Rows.Count > 0) {
                                    DepositAmountByDay = (decimal)SummaryDT.Rows[0]["DepositAmount"];
                                    DepositCountByDay = (int)SummaryDT.Rows[0]["DepositCount"];
                                } else {
                                    DepositAmountByDay = 0;
                                    DepositCountByDay = 0;
                                }


                                if (DailyMaxCount == 0 || (DepositCountByDay + 1) <= DailyMaxCount) {
                                    if (DailyMaxAmount == 0 || (DepositAmountByDay + Amount) <= DailyMaxAmount) {
                                        if ((int)PaymentMethodDT.Rows[0]["EWinPaymentType"] == 0) {
                                            string OrderNumber = System.Guid.NewGuid().ToString();
                                            int InsertRet;

                                            PaymentMethodName = (string)PaymentMethodDT.Rows[0]["PaymentName"];
                                            PaymentCode = (string)PaymentMethodDT.Rows[0]["PaymentCode"];
                                            ReceiveCurrencyType = (string)PaymentMethodDT.Rows[0]["CurrencyType"];
                                            ThresholdRate = (decimal)PaymentMethodDT.Rows[0]["ThresholdRate"];
                                            ExpireSecond = (int)PaymentMethodDT.Rows[0]["ExpireSecond"];
                                            HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                                            HandingFeeAmount = (int)PaymentMethodDT.Rows[0]["HandingFeeAmount"];
                                            ReceiveTotalAmount = (Amount * (1 + (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"])) + HandingFeeAmount;

                                            paymentCommonData.PaymentType = 0;
                                            paymentCommonData.BasicType = 0;
                                            paymentCommonData.OrderNumber = System.Guid.NewGuid().ToString();
                                            paymentCommonData.LoginAccount = SI.LoginAccount;
                                            paymentCommonData.Amount = Amount;
                                            paymentCommonData.HandingFeeRate = HandingFeeRate;
                                            paymentCommonData.HandingFeeAmount = HandingFeeAmount;
                                            paymentCommonData.ReceiveTotalAmount = ReceiveTotalAmount;
                                            paymentCommonData.ExpireSecond = ExpireSecond;
                                            paymentCommonData.PaymentMethodID = PaymentMethodID;
                                            paymentCommonData.PaymentMethodName = PaymentMethodName;
                                            paymentCommonData.PaymentCode = PaymentCode;
                                            paymentCommonData.ThresholdRate = ThresholdRate;
                                            paymentCommonData.ThresholdValue = Amount * ThresholdRate;


                                            InsertRet = EWinWebDB.UserAccountPayment.InsertPayment(OrderNumber, paymentCommonData.PaymentType, 2, paymentCommonData.LoginAccount, paymentCommonData.Amount, paymentCommonData.HandingFeeRate, paymentCommonData.HandingFeeAmount, paymentCommonData.ThresholdRate, paymentCommonData.ThresholdValue, paymentCommonData.PaymentMethodID, "", "", "", paymentCommonData.ExpireSecond);

                                            if (InsertRet == 1) {
                                                R.Result = enumResult.OK;
                                                R.Data = paymentCommonData;
                                                RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(R), paymentCommonData.OrderNumber);
                                            } else {
                                                SetResultException(R, "InsertFailure");
                                            }
                                        } else {
                                            SetResultException(R, "PaymentMethodNotCrypto");
                                        }
                                    } else {
                                        SetResultException(R, "DailyAmountGreaterThanMaxlimit");
                                    }
                                } else {
                                    SetResultException(R, "DailyCountGreaterThanMaxlimit");
                                }
                            } else {
                                SetResultException(R, "AmountGreaterThanMaxlimit");
                            }
                        } else {
                            SetResultException(R, "AmountLessThanMinLimit");
                        }
                    } else {
                        SetResultException(R, "PaymentMethodNotSupportDeposit");
                    }
                } else {
                    SetResultException(R, "PaymentMethodDisable");
                }
            } else {
                SetResultException(R, "PaymentMethodNotExist");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult ConfirmCommonDeposit(string WebSID, string GUID, string OrderNumber, string[] ActivityNames)
    {
        APIResult R = new APIResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData TempCommonData;
        RedisCache.SessionContext.SIDInfo SI;
        EWinTagInfoData tagInfoData = new EWinTagInfoData() { };
        string JoinActivityFailedMsg = string.Empty;
        decimal PointValue;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            //取得Temp(未確認)訂單
            TempCommonData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);

            if (TempCommonData != null) {
                tagInfoData.PaymentMethodID = TempCommonData.PaymentMethodID;
                tagInfoData.PaymentCode = TempCommonData.PaymentCode;
                tagInfoData.PaymentMethodName = TempCommonData.PaymentMethodName;
                tagInfoData.ThresholdRate = TempCommonData.ThresholdRate;
                tagInfoData.ThresholdValue = TempCommonData.ThresholdValue;
                PointValue = TempCommonData.Amount;

                if (ActivityNames.Length > 0) {
                    tagInfoData.IsJoinDepositActivity = true;
                    tagInfoData.ActivityDatas = new List<EWinTagInfoActivityData>();
                    //有儲值參加活動
                    foreach (var ActivityName in ActivityNames) {
                        ActivityCore.DepositActivityResult activityDepositResult = ActivityCore.GetDepositResult(ActivityName, TempCommonData.Amount, TempCommonData.PaymentCode, TempCommonData.LoginAccount);

                        if (activityDepositResult.Result == ActivityCore.enumActResult.OK) {
                            EWinTagInfoActivityData infoActivityData = new EWinTagInfoActivityData() {
                                ActivityName = ActivityName,
                                BonusRate = activityDepositResult.Data.BonusRate,
                                BonusValue = activityDepositResult.Data.BonusValue,
                                ThresholdRate = activityDepositResult.Data.ThresholdRate,
                                ThresholdValue = activityDepositResult.Data.ThresholdValue,
                            };
                            PointValue += activityDepositResult.Data.BonusValue;
                            tagInfoData.ActivityDatas.Add(infoActivityData);
                        } else {
                            JoinActivityFailedMsg += "Join " + ActivityName + " Failed,";
                            break;
                        }
                    }
                } else {
                    tagInfoData.IsJoinDepositActivity = false;
                    //沒參加儲值活動
                }

                if (string.IsNullOrEmpty(JoinActivityFailedMsg)) {

                    //準備送出至EWin

                    EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                    EWin.Payment.PaymentResult paymentResult;
                    string Decription = TempCommonData.PaymentMethodName + ", ReceiveTotalAmount=" + TempCommonData.ReceiveTotalAmount.ToString("F10");

                    paymentResult = paymentAPI.CreatePaymentDeposit(GetToken(), TempCommonData.LoginAccount, GUID, EWinWeb.MainCurrencyType, OrderNumber, TempCommonData.Amount, Decription, true, PointValue, TempCommonData.PaymentCode, CodingControl.GetUserIP(), TempCommonData.ExpireSecond, null);
                    if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                        EWin.Payment.Result updateTagResult = paymentAPI.UpdateTagInfo(GetToken(), GUID, paymentResult.PaymentSerial, Newtonsoft.Json.JsonConvert.SerializeObject(tagInfoData));

                        if (updateTagResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                            int UpdateRet = EWinWebDB.UserAccountPayment.ConfirmPayment(OrderNumber, "", paymentResult.PaymentSerial, PointValue, Newtonsoft.Json.JsonConvert.SerializeObject(tagInfoData.ActivityDatas));

                            if (UpdateRet == 1) {
                                R.Result = enumResult.OK;
                                TempCommonData.PaymentSerial = paymentResult.PaymentSerial;
                                TempCommonData.ActivityDatas = tagInfoData.ActivityDatas;
                                TempCommonData.PointValue = PointValue;
                                RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(TempCommonData), OrderNumber, TempCommonData.ExpireSecond);
                                RedisCache.PaymentContent.KeepPaymentContents(TempCommonData, SI.LoginAccount, TempCommonData.ExpireSecond);
                            } else {
                                SetResultException(R, "UpdateFailure");
                            }

                        } else {
                            SetResultException(R, updateTagResult.ResultMessage);
                            paymentAPI.CancelPayment(GetToken(), GUID, paymentResult.PaymentSerial);
                        }
                    } else {
                        SetResultException(R, paymentResult.ResultMessage);
                    }

                } else {
                    JoinActivityFailedMsg = JoinActivityFailedMsg.Substring(0, JoinActivityFailedMsg.Length - 1);
                    SetResultException(R, JoinActivityFailedMsg);
                }
            } else {
                SetResultException(R, "OrderNotExist");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonResult CreatePayPalDeposit(string WebSID, string GUID, decimal Amount, int PaymentMethodID)
    {
        PaymentCommonResult R = new PaymentCommonResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData paymentCommonData = new PaymentCommonData() { };

        RedisCache.SessionContext.SIDInfo SI;
        string PaymentMethodName;
        string PaymentCode;
        string ReceiveCurrencyType;
        string ExtraData;
        int MinLimit;
        int MaxLimit;
        decimal ReceiveTotalAmount;
        decimal ThresholdRate;
        decimal HandingFeeRate;
        int ExpireSecond;
        System.Data.DataTable PaymentMethodDT;


        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            PaymentMethodDT = RedisCache.PaymentMethod.GetPaymentMethodByID(PaymentMethodID);

            if (PaymentMethodDT != null && PaymentMethodDT.Rows.Count > 0) {
                if ((int)PaymentMethodDT.Rows[0]["State"] == 0) {
                    if ((int)PaymentMethodDT.Rows[0]["PaymentType"] == 0) {
                        MinLimit = (int)PaymentMethodDT.Rows[0]["MinLimit"];
                        MaxLimit = (int)PaymentMethodDT.Rows[0]["MaxLimit"];

                        if (Amount >= MinLimit) {
                            if (Amount <= MaxLimit || MaxLimit == 0) {
                                if ((int)PaymentMethodDT.Rows[0]["EWinPaymentType"] == 0) {
                                    string OrderNumber = System.Guid.NewGuid().ToString();
                                    int InsertRet;

                                    PaymentMethodName = (string)PaymentMethodDT.Rows[0]["PaymentName"];
                                    PaymentCode = (string)PaymentMethodDT.Rows[0]["PaymentCode"];
                                    ReceiveCurrencyType = (string)PaymentMethodDT.Rows[0]["CurrencyType"];

                                    ThresholdRate = (decimal)PaymentMethodDT.Rows[0]["ThresholdRate"];
                                    ExpireSecond = (int)PaymentMethodDT.Rows[0]["ExpireSecond"];
                                    ExtraData = (string)PaymentMethodDT.Rows[0]["ExtraData"];

                                    if (string.IsNullOrEmpty(ExtraData)) {
                                        HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                                    } else {
                                        HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                                        try {
                                            Newtonsoft.Json.Linq.JArray rangeRates = Newtonsoft.Json.Linq.JArray.Parse(ExtraData);
                                            foreach (var rangeRate in rangeRates) {
                                                decimal RangeMinValuie = (decimal)rangeRate["RangeMinValuie"];
                                                decimal RangeMaxValuie = (decimal)rangeRate["RangeMaxValuie"];

                                                if (RangeMaxValuie != 0) {
                                                    if (RangeMinValuie <= Amount && Amount < RangeMaxValuie) {
                                                        HandingFeeRate = (decimal)rangeRate["RangeRate"];
                                                        break;
                                                    }
                                                } else {
                                                    if (RangeMinValuie <= Amount) {
                                                        HandingFeeRate = (decimal)rangeRate["RangeRate"];
                                                        break;
                                                    }
                                                }
                                            }
                                        } catch (Exception) {
                                            HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                                        }
                                    }
                                    ReceiveTotalAmount = Amount * (1 + HandingFeeRate);

                                    paymentCommonData.PaymentType = 0;
                                    paymentCommonData.BasicType = 0;
                                    paymentCommonData.OrderNumber = OrderNumber;
                                    paymentCommonData.LoginAccount = SI.LoginAccount;
                                    paymentCommonData.Amount = Amount;
                                    paymentCommonData.HandingFeeRate = HandingFeeRate;
                                    paymentCommonData.HandingFeeAmount = 0;
                                    paymentCommonData.ReceiveCurrencyType = ReceiveCurrencyType;
                                    paymentCommonData.ReceiveTotalAmount = ReceiveTotalAmount;
                                    paymentCommonData.ExpireSecond = ExpireSecond;
                                    paymentCommonData.PaymentMethodID = PaymentMethodID;
                                    paymentCommonData.PaymentMethodName = PaymentMethodName;
                                    paymentCommonData.PaymentCode = PaymentCode;
                                    paymentCommonData.ThresholdRate = ThresholdRate;
                                    paymentCommonData.ThresholdValue = Amount * ThresholdRate;
                                    paymentCommonData.CreateDate = DateTime.Now.ToString("yyyy/MM/dd hh:mm");


                                    InsertRet = EWinWebDB.UserAccountPayment.InsertPayment(OrderNumber, paymentCommonData.PaymentType, 0, paymentCommonData.LoginAccount, paymentCommonData.Amount, paymentCommonData.HandingFeeRate, paymentCommonData.HandingFeeAmount, paymentCommonData.ThresholdRate, paymentCommonData.ThresholdValue, paymentCommonData.PaymentMethodID, "", "", "", paymentCommonData.ExpireSecond);

                                    if (InsertRet == 1) {
                                        R.Result = enumResult.OK;
                                        R.Data = paymentCommonData;
                                        RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(paymentCommonData), paymentCommonData.OrderNumber);
                                    } else {
                                        SetResultException(R, "InsertFailure");
                                    }
                                } else {
                                    SetResultException(R, "PaymentMethodNotCrypto");
                                }
                            } else {
                                SetResultException(R, "AmountGreaterThanMaxlimit");
                            }
                        } else {
                            SetResultException(R, "AmountLessThanMinLimit");
                        }
                    } else {
                        SetResultException(R, "PaymentMethodNotSupportDeposit");
                    }
                } else {
                    SetResultException(R, "PaymentMethodDisable");
                }
            } else {
                SetResultException(R, "PaymentMethodNotExist");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult ConfirmPayPalDeposit(string WebSID, string GUID, string OrderNumber, string[] ActivityNames, string Lang)
    {
        APIResult R = new APIResult() { GUID = GUID, Result = enumResult.ERR };
        Payment.APIResult R_PayPal = new Payment.APIResult() { ResultState = Payment.APIResult.enumResultCode.ERR };
        PaymentCommonData TempCommonData;
        RedisCache.SessionContext.SIDInfo SI;
        EWinTagInfoData tagInfoData = new EWinTagInfoData() { };
        string JoinActivityFailedMsg = string.Empty;
        decimal PointValue;
        string ReceiveCurrencyType;
        string strPayPalMsg;
        dynamic o = null;
        string PayPalTransactionID;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            //取得Temp(未確認)訂單
            TempCommonData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);

            if (TempCommonData != null) {
                tagInfoData.PaymentMethodID = TempCommonData.PaymentMethodID;
                tagInfoData.PaymentCode = TempCommonData.PaymentCode;
                tagInfoData.PaymentMethodName = TempCommonData.PaymentMethodName;
                tagInfoData.ThresholdRate = TempCommonData.ThresholdRate;
                tagInfoData.ThresholdValue = TempCommonData.ThresholdValue;
                PointValue = TempCommonData.Amount;
                ReceiveCurrencyType = TempCommonData.ReceiveCurrencyType;

                if (ActivityNames.Length > 0) {
                    tagInfoData.IsJoinDepositActivity = true;
                    tagInfoData.ActivityDatas = new List<EWinTagInfoActivityData>();
                    //有儲值參加活動
                    foreach (var ActivityName in ActivityNames) {
                        ActivityCore.DepositActivityResult activityDepositResult = ActivityCore.GetDepositResult(ActivityName, TempCommonData.Amount, TempCommonData.PaymentCode, TempCommonData.LoginAccount);

                        if (activityDepositResult.Result == ActivityCore.enumActResult.OK) {
                            EWinTagInfoActivityData infoActivityData = new EWinTagInfoActivityData() {
                                ActivityName = ActivityName,
                                BonusRate = activityDepositResult.Data.BonusRate,
                                BonusValue = activityDepositResult.Data.BonusValue,
                                ThresholdRate = activityDepositResult.Data.ThresholdRate,
                                ThresholdValue = activityDepositResult.Data.ThresholdValue,
                            };
                            PointValue += activityDepositResult.Data.BonusValue;
                            tagInfoData.ActivityDatas.Add(infoActivityData);
                        } else {
                            JoinActivityFailedMsg += "Join " + ActivityName + " Failed,";
                            break;
                        }
                    }
                } else {
                    tagInfoData.IsJoinDepositActivity = false;
                    //沒參加儲值活動
                }

                if (string.IsNullOrEmpty(JoinActivityFailedMsg)) {

                    //準備送出至EWin

                    EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                    EWin.Payment.PaymentResult paymentResult;
                    string Decription = TempCommonData.PaymentMethodName + ", ReceiveTotalAmount=" + TempCommonData.ReceiveTotalAmount.ToString("F10");

                    paymentResult = paymentAPI.CreatePaymentDeposit(GetToken(), TempCommonData.LoginAccount, GUID, EWinWeb.MainCurrencyType, OrderNumber, TempCommonData.Amount, Decription, true, PointValue, TempCommonData.PaymentCode, CodingControl.GetUserIP(), TempCommonData.ExpireSecond, null);
                    if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                        EWin.Payment.Result updateTagResult = paymentAPI.UpdateTagInfo(GetToken(), GUID, paymentResult.PaymentSerial, Newtonsoft.Json.JsonConvert.SerializeObject(tagInfoData));

                        if (updateTagResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {

                            //paypal建單
                            R_PayPal = Payment.PayPal.CreatePayPalPayment(ReceiveCurrencyType, TempCommonData.ReceiveTotalAmount, Lang, OrderNumber);

                            if (R_PayPal.ResultState == Payment.APIResult.enumResultCode.OK) {
                                strPayPalMsg = R_PayPal.Message;
                                o = Newtonsoft.Json.JsonConvert.DeserializeObject(strPayPalMsg);
                                PayPalTransactionID = (string)o.PayPalTransactionID;

                                int UpdateRet = EWinWebDB.UserAccountPayment.ConfirmPayment(OrderNumber, "", paymentResult.PaymentSerial, PayPalTransactionID, PointValue, Newtonsoft.Json.JsonConvert.SerializeObject(tagInfoData.ActivityDatas));

                                if (UpdateRet == 1) {
                                    R.Result = enumResult.OK;
                                    R.Message = (string)o.href;
                                    TempCommonData.PaymentSerial = paymentResult.PaymentSerial;
                                    TempCommonData.ActivityDatas = tagInfoData.ActivityDatas;
                                    TempCommonData.PointValue = PointValue;

                                    RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(TempCommonData), OrderNumber, TempCommonData.ExpireSecond);
                                    RedisCache.PaymentContent.KeepPaymentContents(TempCommonData, SI.LoginAccount, TempCommonData.ExpireSecond);
                                } else {
                                    SetResultException(R, "UpdateFailure");
                                }

                            } else {
                                SetResultException(R, R_PayPal.Message);
                                paymentAPI.CancelPayment(GetToken(), GUID, paymentResult.PaymentSerial);
                            }
                        } else {
                            SetResultException(R, updateTagResult.ResultMessage);
                            paymentAPI.CancelPayment(GetToken(), GUID, paymentResult.PaymentSerial);
                        }
                    } else {
                        SetResultException(R, paymentResult.ResultMessage);
                    }

                } else {
                    JoinActivityFailedMsg = JoinActivityFailedMsg.Substring(0, JoinActivityFailedMsg.Length - 1);
                    SetResultException(R, JoinActivityFailedMsg);
                }
            } else {
                SetResultException(R, "OrderNotExist");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonResult CreateCryptoWithdrawal(string WebSID, string GUID, decimal Amount, int PaymentMethodID, string ToWalletAddress) {
        PaymentCommonResult R = new PaymentCommonResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData PaymentCommonData = new PaymentCommonData() { PaymentCryptoDetailList = new List<CryptoDetail>() };

        RedisCache.SessionContext.SIDInfo SI;
        string PaymentMethodName;
        string PaymentCode;
        string ReceiveCurrencyType;
        string MultiCurrencyInfo;
        int MinLimit;
        int MaxLimit;
        int DailyMaxAmount;
        int DailyMaxCount;
        decimal ReceiveTotalAmount;
        decimal HandingFeeRate;
        int HandingFeeAmount;
        int WalletType;
        decimal WithdrawalAmountByDay;
        int WithdrawalCountByDay;
        int ExpireSecond;
        bool GetExchangeRateSuccess = true;
        System.Data.DataTable PaymentMethodDT;


        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            if (EWinWeb.CheckInWithdrawalTime()) {
                if (!EWinWeb.IsWithdrawlTemporaryMaintenance()) {
                    PaymentMethodDT = RedisCache.PaymentMethod.GetPaymentMethodByID(PaymentMethodID);

                    if (PaymentMethodDT != null && PaymentMethodDT.Rows.Count > 0) {
                        if ((int)PaymentMethodDT.Rows[0]["State"] == 0) {
                            if ((int)PaymentMethodDT.Rows[0]["PaymentType"] == 1) {
                                MinLimit = (int)PaymentMethodDT.Rows[0]["MinLimit"];
                                MaxLimit = (int)PaymentMethodDT.Rows[0]["MaxLimit"];
                                DailyMaxCount = (int)PaymentMethodDT.Rows[0]["DailyMaxCount"];
                                DailyMaxAmount = (int)PaymentMethodDT.Rows[0]["DailyMaxAmount"];

                                if (Amount >= MinLimit) {
                                    if (Amount <= MaxLimit || MaxLimit == 0) {
                                        System.Data.DataTable SummaryDT = RedisCache.UserAccountSummary.GetUserAccountSummary(SI.LoginAccount, DateTime.Now);

                                        if (SummaryDT != null && SummaryDT.Rows.Count > 0) {
                                            WithdrawalAmountByDay = (decimal)SummaryDT.Rows[0]["DepositAmount"];
                                            WithdrawalCountByDay = (int)SummaryDT.Rows[0]["DepositCount"];
                                        } else {
                                            WithdrawalAmountByDay = 0;
                                            WithdrawalCountByDay = 0;
                                        }

                                        if (DailyMaxCount == 0 || (WithdrawalCountByDay + 1) <= DailyMaxCount) {
                                            if (DailyMaxAmount == 0 || (WithdrawalAmountByDay + Amount) <= DailyMaxAmount) {
                                                if ((int)PaymentMethodDT.Rows[0]["EWinPaymentType"] == 2) {
                                                    //Check ThresholdValue
                                                    EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
                                                    EWin.Lobby.UserInfoResult userInfoResult = lobbyAPI.GetUserInfo(GetToken(), SI.EWinSID, GUID);
                                                    EWin.Lobby.ThresholdInfo thresholdInfo;
                                                    decimal thresholdValue;

                                                    if (userInfoResult.Result == EWin.Lobby.enumResult.OK) {
                                                        thresholdInfo = userInfoResult.ThresholdInfo.Where(x => x.CurrencyType.ToUpper() == EWinWeb.MainCurrencyType.ToUpper()).FirstOrDefault();

                                                        if (thresholdInfo != null) {
                                                            thresholdValue = thresholdInfo.ThresholdValue;
                                                        } else {
                                                            thresholdValue = 0;
                                                        }
                                                        if (thresholdValue == 0) {
                                                            PaymentMethodName = (string)PaymentMethodDT.Rows[0]["PaymentName"];
                                                            PaymentCode = (string)PaymentMethodDT.Rows[0]["PaymentCode"];
                                                            ReceiveCurrencyType = (string)PaymentMethodDT.Rows[0]["CurrencyType"];
                                                            ExpireSecond = (int)PaymentMethodDT.Rows[0]["ExpireSecond"];
                                                            HandingFeeRate = (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"];
                                                            HandingFeeAmount = (int)PaymentMethodDT.Rows[0]["HandingFeeAmount"];
                                                            WalletType = (int)PaymentMethodDT.Rows[0]["EWinCryptoWalletType"];
                                                            MultiCurrencyInfo = (string)PaymentMethodDT.Rows[0]["MultiCurrencyInfo"];
                                                            ReceiveTotalAmount = (Amount * (1 - (decimal)PaymentMethodDT.Rows[0]["HandingFeeRate"])) - HandingFeeAmount;
                                                            if (!string.IsNullOrEmpty(MultiCurrencyInfo)) {
                                                                Newtonsoft.Json.Linq.JArray MultiCurrency = Newtonsoft.Json.Linq.JArray.Parse(MultiCurrencyInfo);

                                                                foreach (var item in MultiCurrency) {
                                                                    string TokenCurrency;
                                                                    decimal ExchangeRate;
                                                                    decimal PartialRate;

                                                                    TokenCurrency = item["Currency"].ToString();
                                                                    ExchangeRate = CryptoExpand.GetCryptoExchangeRate(TokenCurrency);

                                                                    if (ExchangeRate == 0) {
                                                                        //表示取得匯率失敗
                                                                        GetExchangeRateSuccess = false;
                                                                        break;
                                                                    } else {
                                                                        PartialRate = (decimal)item["Rate"];

                                                                        CryptoDetail Dcd = new CryptoDetail() {
                                                                            TokenCurrencyType = TokenCurrency,
                                                                            TokenContractAddress = item["TokenContractAddress"].ToString(),
                                                                            ExchangeRate = CodingControl.FormatDecimal(ExchangeRate, 6),
                                                                            PartialRate = PartialRate,
                                                                            ReceiveAmount = CodingControl.FormatDecimal(ReceiveTotalAmount * PartialRate * ExchangeRate, 6)
                                                                        };

                                                                        PaymentCommonData.PaymentCryptoDetailList.Add(Dcd);

                                                                    }
                                                                }
                                                            } else {
                                                                decimal ExchangeRate;
                                                                decimal ReceiveAmount;

                                                                ExchangeRate = CryptoExpand.GetCryptoExchangeRate(ReceiveCurrencyType);
                                                                ReceiveAmount = Amount * ExchangeRate;

                                                                if (ExchangeRate == 0) {
                                                                    //表示取得匯率失敗
                                                                    GetExchangeRateSuccess = false;
                                                                } else {
                                                                    CryptoDetail Dcd = new CryptoDetail() {
                                                                        TokenCurrencyType = ReceiveCurrencyType,
                                                                        TokenContractAddress = (string)PaymentMethodDT.Rows[0]["TokenContractAddress"],
                                                                        ExchangeRate = CodingControl.FormatDecimal(ExchangeRate, 6),
                                                                        PartialRate = 1,
                                                                        ReceiveAmount = CodingControl.FormatDecimal(ReceiveTotalAmount * 1 * ExchangeRate, 6),
                                                                    };

                                                                    PaymentCommonData.PaymentCryptoDetailList.Add(Dcd);
                                                                }
                                                            }

                                                            if (GetExchangeRateSuccess) {
                                                                string OrderNumber = System.Guid.NewGuid().ToString();
                                                                int InsertRet;

                                                                PaymentCommonData.PaymentType = 1;
                                                                PaymentCommonData.BasicType = 2;
                                                                PaymentCommonData.WalletType = WalletType;
                                                                PaymentCommonData.OrderNumber = OrderNumber;
                                                                PaymentCommonData.LoginAccount = SI.LoginAccount;
                                                                PaymentCommonData.Amount = Amount;
                                                                PaymentCommonData.ReceiveTotalAmount = ReceiveTotalAmount;
                                                                PaymentCommonData.HandingFeeRate = HandingFeeRate;
                                                                PaymentCommonData.HandingFeeAmount = HandingFeeAmount;
                                                                PaymentCommonData.ExpireSecond = ExpireSecond;
                                                                PaymentCommonData.PaymentMethodID = PaymentMethodID;
                                                                PaymentCommonData.PaymentMethodName = PaymentMethodName;
                                                                PaymentCommonData.PaymentCode = PaymentCode;
                                                                PaymentCommonData.ToWalletAddress = ToWalletAddress;
                                                                PaymentCommonData.CreateDate = DateTime.Now.ToString("yyyy/MM/dd hh:mm");

                                                                InsertRet = EWinWebDB.UserAccountPayment.InsertPayment(OrderNumber, PaymentCommonData.PaymentType, 2, PaymentCommonData.LoginAccount, PaymentCommonData.Amount, PaymentCommonData.HandingFeeRate, PaymentCommonData.HandingFeeAmount, 0, 0, PaymentCommonData.PaymentMethodID, "", "", Newtonsoft.Json.JsonConvert.SerializeObject(PaymentCommonData.PaymentCryptoDetailList), PaymentCommonData.ExpireSecond);

                                                                if (InsertRet == 1) {
                                                                    R.Result = enumResult.OK;
                                                                    R.Data = PaymentCommonData;
                                                                    RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(R.Data), PaymentCommonData.OrderNumber);
                                                                } else {
                                                                    SetResultException(R, "InsertFailure");
                                                                }
                                                            } else {
                                                                SetResultException(R, "GetExchangeFailed");
                                                            }
                                                        } else {
                                                            SetResultException(R, "ThresholdLimit");
                                                        }
                                                    } else {
                                                        SetResultException(R, "GetInfoError");
                                                    }

                                                } else {
                                                    SetResultException(R, "PaymentMethodNotCrypto");
                                                }

                                            } else {
                                                SetResultException(R, "DailyAmountGreaterThanMaxlimit");
                                            }
                                        } else {
                                            SetResultException(R, "DailyCountGreaterThanMaxlimit");
                                        }
                                    } else {
                                        SetResultException(R, "AmountGreaterThanMaxlimit");
                                    }
                                } else {
                                    SetResultException(R, "AmountLessThanMinLimit");
                                }
                            } else {
                                SetResultException(R, "PaymentMethodNotSupportDeposit");
                            }
                        } else {
                            SetResultException(R, "PaymentMethodDisable");
                        }
                    } else {
                        SetResultException(R, "PaymentMethodNotExist");
                    }
                } else {
                    SetResultException(R, "WithdrawlTemporaryMaintenance");
                }
            } else {
                SetResultException(R, "NotInOpenTime");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult ConfirmCryptoWithdrawal(string WebSID, string GUID, string OrderNumber) {
        APIResult R = new APIResult() { GUID = GUID, Result = enumResult.ERR };
        PaymentCommonData TempCryptoData;
        RedisCache.SessionContext.SIDInfo SI;
        decimal PointValue;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            if (EWinWeb.CheckInWithdrawalTime()) {
                if (!EWinWeb.IsWithdrawlTemporaryMaintenance()) {
                    //取得Temp(未確認)訂單
                    TempCryptoData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);

                    if (TempCryptoData != null) {
                        EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
                        EWin.Lobby.UserInfoResult userInfoResult = lobbyAPI.GetUserInfo(GetToken(), SI.EWinSID, GUID);
                        EWin.Lobby.ThresholdInfo thresholdInfo;


                        if (userInfoResult.Result == EWin.Lobby.enumResult.OK) {
                            thresholdInfo = userInfoResult.ThresholdInfo.Where(x => x.CurrencyType.ToUpper() == EWinWeb.MainCurrencyType.ToUpper()).FirstOrDefault();

                            if (thresholdInfo != null) {
                                if (thresholdInfo.ThresholdValue == 0) {
                                    PointValue = TempCryptoData.Amount;

                                    //準備送出至EWin

                                    EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                                    EWin.Payment.PaymentResult paymentResult;
                                    List<EWin.Payment.PaymentDetailWallet> paymentDetailWallets = new List<EWin.Payment.PaymentDetailWallet>();

                                    //Description待實際測試後調整
                                    string Decription = TempCryptoData.PaymentMethodName;

                                    foreach (var paymentCryptoDetail in TempCryptoData.PaymentCryptoDetailList) {
                                        EWin.Payment.PaymentDetailWallet paymentDetailWallet = new EWin.Payment.PaymentDetailWallet() {
                                            WalletType = (EWin.Payment.enumWalletType)TempCryptoData.WalletType,
                                            Status = EWin.Payment.enumDetailWalletStatus.DetailCreated,
                                            ToWalletAddress = TempCryptoData.ToWalletAddress,
                                            TokenName = paymentCryptoDetail.TokenCurrencyType,
                                            TokenContractAddress = paymentCryptoDetail.TokenContractAddress,
                                            TokenAmount = paymentCryptoDetail.ReceiveAmount
                                        };

                                        Decription += ", TokenName=" + paymentCryptoDetail.TokenCurrencyType + " TokenAmount=" + paymentCryptoDetail.ReceiveAmount.ToString("F10");
                                        paymentDetailWallets.Add(paymentDetailWallet);
                                    }

                                    paymentResult = paymentAPI.CreatePaymentWithdrawal(GetToken(), TempCryptoData.LoginAccount, GUID, EWinWeb.MainCurrencyType, OrderNumber, TempCryptoData.Amount, Decription, true, PointValue * -1, TempCryptoData.PaymentCode, CodingControl.GetUserIP(), TempCryptoData.ExpireSecond, paymentDetailWallets.ToArray());
                                    if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {

                                        int UpdateRet = EWinWebDB.UserAccountPayment.ConfirmPayment(OrderNumber, TempCryptoData.ToWalletAddress, paymentResult.PaymentSerial, PointValue, "");

                                        if (UpdateRet == 1) {
                                            R.Result = enumResult.OK;
                                            R.Message = paymentResult.PaymentSerial;
                                            TempCryptoData.PaymentSerial = paymentResult.PaymentSerial;
                                            TempCryptoData.PointValue = PointValue;
                                            RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(TempCryptoData), OrderNumber, TempCryptoData.ExpireSecond);
                                            RedisCache.PaymentContent.KeepPaymentContents(TempCryptoData, SI.LoginAccount, TempCryptoData.ExpireSecond);
                                        } else {
                                            SetResultException(R, "UpdateFailure");
                                        }

                                    } else {
                                        SetResultException(R, paymentResult.ResultMessage);
                                    }

                                } else {
                                    SetResultException(R, "ThresholdLimit");
                                }
                            } else {
                                SetResultException(R, "CurrencyNotFound");
                            }
                        } else {
                            SetResultException(R, "GetThresholdError");
                        }
                    } else {
                        SetResultException(R, "OrderNotExist");
                    }
                } else {
                    SetResultException(R, "WithdrawlTemporaryMaintenance");
                }
            } else {
                SetResultException(R, "NotInOpenTime");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }
        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonListResult GetPaymentByNonFinished(string WebSID, string GUID)
    {
        PaymentCommonListResult R = new PaymentCommonListResult() { Result = enumResult.ERR };
        EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            List<PaymentCommonData> payments = RedisCache.PaymentContent.GetPaymentContents<PaymentCommonData>(SI.LoginAccount);

            if (payments != null && payments.Count > 0) {
                R.Result = enumResult.OK;
                R.Datas = payments;
            } else {
                SetResultException(R, "NoData");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonListResult GetClosePayment(string WebSID, string GUID, DateTime StartDate, DateTime EndDate)
    {
        PaymentCommonListResult R = new PaymentCommonListResult() { Result = enumResult.ERR };
        EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            R.Datas = new List<PaymentCommonData>();
            R.Result = enumResult.OK;

            for (int i = 0; i <= EndDate.Subtract(StartDate).TotalDays; i++) {
                var QueryDate = StartDate.AddDays(i);
                string Content = string.Empty;
                Content = ReportSystem.UserAccountPayment.GetUserAccountPayment(QueryDate, SI.LoginAccount);

                foreach (string EachString in Content.Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries)) {
                    PaymentCommonData data = null;
                    try { data = Newtonsoft.Json.JsonConvert.DeserializeObject<PaymentCommonData>(EachString); } catch (Exception ex) { }
                    if (data != null) {
                        R.Datas.Add(data);
                    }
                }
            }

            if (R.Datas.Count > 0) {
                R.Result = enumResult.OK;
            } else {
                SetResultException(R, "NoData");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonResult GetPaymentByOrderNumber(string WebSID, string GUID, string OrderNumber)
    {
        PaymentCommonResult R = new PaymentCommonResult();
        RedisCache.SessionContext.SIDInfo SI;
        System.Data.DataTable DT;


        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            DT = EWinWebDB.UserAccountPayment.GetPaymentByOrderNumber(OrderNumber);

            if (DT != null && DT.Rows.Count > 0) {
                R.Result = enumResult.OK;
                R.Data = CovertFromRow(DT.Rows[0]);
            } else {
                SetResultException(R, "InvalidWebSID");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public PaymentCommonResult GetPaymentByPaymentSerial(string WebSID, string GUID, string PaymentSerial)
    {
        PaymentCommonResult R = new PaymentCommonResult();
        RedisCache.SessionContext.SIDInfo SI;
        System.Data.DataTable DT;


        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            DT = EWinWebDB.UserAccountPayment.GetPaymentByPaymentSerial(PaymentSerial);

            if (DT != null && DT.Rows.Count > 0) {
                R.Result = enumResult.OK;
                R.Data = CovertFromRow(DT.Rows[0]);
            } else {
                SetResultException(R, "InvalidWebSID");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult CancelPayment(string WebSID, string GUID, string PaymentSerial, string OrderNumber)
    {
        APIResult R = new APIResult() { Result = enumResult.ERR, GUID = GUID };
        EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
        RedisCache.SessionContext.SIDInfo SI;

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {


            PaymentCommonData paymentCommonData = RedisCache.PaymentContent.GetPaymentContent<PaymentCommonData>(OrderNumber);
            if (paymentCommonData != null) {
                if (paymentCommonData.PaymentType == 0) {
                    if (paymentCommonData.BasicType == 2) {
                        new EWin.OCW.OCW().FinishCompanyWallet(SI.EWinCT, (EWin.OCW.enumWalletType)paymentCommonData.WalletType, paymentCommonData.ToWalletAddress);
                    }

                    var paymentResult = paymentAPI.CancelPayment(GetToken(), GUID, PaymentSerial);
                    if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                        R.Result = enumResult.OK;
                    } else {
                        SetResultException(R, paymentResult.ResultMessage);
                    }
                } else {
                    SetResultException(R, "OnlyDepositCanCancel");
                }
            } else {
                SetResultException(R, "NotFoundData");
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ActivityCore.DepositActivitiesResult GetDepositInfo(string WebSID, string GUID, decimal Amount, string PaymentCode, string LoginAccount)
    {
        RedisCache.SessionContext.SIDInfo SI;
        ActivityCore.DepositActivitiesResult R = new ActivityCore.DepositActivitiesResult() {
            GUID = GUID,
            Result = ActivityCore.enumActResult.ERR
        };

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            R = ActivityCore.GetDepositAllResult(Amount, PaymentCode, LoginAccount);
        } else {
            ActivityCore.SetResultException(R, "InvalidWebSID");
        }

        return R;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public APIResult GetExchangeRateFromNomics(string WebSID, string GUID) {
        string RedisReturn = string.Empty;
        string strCryptoExchangeRateFromNomics;
        RedisCache.SessionContext.SIDInfo SI;
        APIResult R = new APIResult() {
            GUID = GUID,
            Result = enumResult.ERR
        };

        SI = RedisCache.SessionContext.GetSIDInfo(WebSID);

        if (SI != null && !string.IsNullOrEmpty(SI.EWinSID)) {
            RedisReturn = RedisCache.CryptoExchangeRate.GetCryptoExchangeRate();

            if (string.IsNullOrEmpty(RedisReturn)) {
                strCryptoExchangeRateFromNomics = CryptoExpand.GetAllCryptoExchangeRate();
                if (!string.IsNullOrEmpty(strCryptoExchangeRateFromNomics)) {
                    RedisCache.CryptoExchangeRate.UpdateCryptoExchangeRate(strCryptoExchangeRateFromNomics);
                    R.Message = strCryptoExchangeRateFromNomics;
                    R.Result = enumResult.OK;
                } else {
                    SetResultException(R, "InvalidCryptoExchangeRate");
                }
            } else {
                R.Message = RedisReturn;
                R.Result = enumResult.OK;
            }
        } else {
            SetResultException(R, "InvalidWebSID");
        }
        return R;
    }

    private PaymentCommonData CovertFromRow(System.Data.DataRow row) {
        string DetailDataStr = row["DetailData"].ToString();
        string ActivityDataStr = row["ActivityData"].ToString();


        if (string.IsNullOrEmpty(DetailDataStr)) {
            PaymentCommonData result = new PaymentCommonData() {
                PaymentType = (int)row["PaymentType"],
                BasicType = (int)row["BasicType"],
                LoginAccount = (string)row["LoginAccount"],
                OrderNumber = (string)row["OrderNumber"],
                Amount = (decimal)row["Amount"],
                HandingFeeRate = (decimal)row["HandingFeeRate"],
                //ReceiveTotalAmount = (decimal)row["ReceiveTotalAmount"],
                ThresholdValue = (decimal)row["ThresholdValue"],
                ThresholdRate = (decimal)row["ThresholdRate"],
                CreateDate = ((DateTime)row["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss"),
                LimitDate = ((DateTime)row["CreateDate"]).AddSeconds((int)row["ExpireSecond"]).ToString("yyyy/MM/dd HH:mm:ss"),
                ExpireSecond = (int)row["ExpireSecond"],
                PaymentMethodID = (int)row["PaymentMethodID"],
                PaymentMethodName = (string)row["PaymentName"],
                PaymentCode = (string)row["PaymentCode"]
            };

            return result;
        } else {
            PaymentCommonData result = new PaymentCommonData() {
                PaymentType = (int)row["PaymentType"],
                BasicType = (int)row["BasicType"],
                LoginAccount = (string)row["LoginAccount"],
                OrderNumber = (string)row["OrderNumber"],
                Amount = (decimal)row["Amount"],
                HandingFeeRate = (decimal)row["HandingFeeRate"],
                //ReceiveTotalAmount = (decimal)row["ReceiveTotalAmount"],
                ThresholdValue = (decimal)row["ThresholdValue"],
                ThresholdRate = (decimal)row["ThresholdRate"],
                CreateDate = ((DateTime)row["CreateDate"]).ToString("yyyy/MM/dd HH:mm:ss"),
                LimitDate = ((DateTime)row["CreateDate"]).AddSeconds((int)row["ExpireSecond"]).ToString("yyyy/MM/dd HH:mm:ss"),
                ExpireSecond = (int)row["ExpireSecond"],
                PaymentMethodID = (int)row["PaymentMethodID"],
                PaymentMethodName = (string)row["PaymentName"],
                PaymentCode = (string)row["PaymentCode"],
                ToWalletAddress = (string)row["ToInfo"],
                WalletType = (int)row["EWinCryptoWalletType"],
            };

            result.PaymentCryptoDetailList = Newtonsoft.Json.JsonConvert.DeserializeObject<List<CryptoDetail>>(DetailDataStr);

            if (!string.IsNullOrEmpty(ActivityDataStr)) {
                result.ActivityDatas = Newtonsoft.Json.JsonConvert.DeserializeObject<List<EWinTagInfoActivityData>>(ActivityDataStr);
            }

            return result;
        }
    }

    private void SetResultException(APIResult R, string Msg)
    {
        if (R != null) {
            R.Result = enumResult.ERR;
            R.Message = Msg;
        }
    }

    private string GetToken()
    {
        string Token;
        int RValue;
        Random R = new Random();
        RValue = R.Next(100000, 9999999);
        Token = EWinWeb.CreateToken(EWinWeb.PrivateKey, EWinWeb.APIKey, RValue.ToString());

        return Token;
    }

    public class APIResult
    {
        public enumResult Result { get; set; }
        public string GUID { get; set; }
        public string Message { get; set; }
    }

    public enum enumResult
    {
        OK = 0,
        ERR = 1
    }

    public class PaymentCommonResult : APIResult
    {
        public PaymentCommonData Data { get; set; }
    }

    public class PaymentCommonListResult : APIResult
    {
        public List<PaymentCommonData> Datas { get; set; }
    }

    public class PaymentCommonData
    {
        public int PaymentType { get; set; } // 0=入金,1=出金
        public int BasicType { get; set; } // 0=一般/1=銀行卡/2=區塊鏈
        public int PaymentFlowType { get; set; } // 0=建立/1=進行中/2=成功/3=失敗
        public string LoginAccount { get; set; }
        public string PaymentSerial { get; set; }
        public string OrderNumber { get; set; }
        public string ReceiveCurrencyType { get; set; }
        public decimal Amount { get; set; }
        public decimal PointValue { get; set; }
        public decimal HandingFeeRate { get; set; }
        public int HandingFeeAmount { get; set; }
        public decimal ReceiveTotalAmount { get; set; }
        public decimal ThresholdValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public int ExpireSecond { get; set; }
        public int PaymentMethodID { get; set; }
        public string PaymentMethodName { get; set; }
        public string PaymentCode { get; set; }
        public string CreateDate { get; set; }
        public string FinishDate { get; set; }
        public string LimitDate { get; set; }
        public int WalletType { get; set; } // 0=ERC,1=XRP
        public string ToWalletAddress { get; set; }
        public List<CryptoDetail> PaymentCryptoDetailList { get; set; }
        public List<EWinTagInfoActivityData> ActivityDatas { get; set; }
        public string ActivityData { get; set; }
    }

    public class CryptoDetail
    {
        public string TokenCurrencyType { get; set; }
        public string TokenContractAddress { get; set; }
        public decimal ReceiveAmount { get; set; }
        public decimal ExchangeRate { get; set; }
        public decimal PartialRate { get; set; }
    }


    public class EWinTagInfoData
    {
        public int PaymentMethodID { get; set; }
        public string PaymentCode { get; set; }
        public string PaymentMethodName { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
        public bool IsJoinDepositActivity { get; set; }
        public List<EWinTagInfoActivityData> ActivityDatas { get; set; }
    }

    public class EWinTagInfoActivityData
    {
        public string ActivityName { get; set; }
        public decimal BonusRate { get; set; }
        public decimal BonusValue { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal ThresholdValue { get; set; }
    }


    public class PaymentMethodResult : APIResult
    {
        public List<PaymentMethod> PaymentMethodResults { get; set; }
    }

    public class PaymentMethod
    {
        public int PaymentMethodID { get; set; }
        public int PaymentType { get; set; }
        public string PaymentName { get; set; }
        public string PaymentCode { get; set; }
        public string PaymentCategoryCode { get; set; }
        public int State { get; set; }
        public string EwinPayServiceType { get; set; }
        public int EWinPaymentType { get; set; }
        public int EWinCryptoWalletType { get; set; }
        public decimal ThresholdRate { get; set; }
        public decimal MinLimit { get; set; }
        public decimal MaxLimit { get; set; }
        public decimal HandingFeeRate { get; set; }
        public decimal HandingFeeAmount { get; set; }
        public string CurrencyType { get; set; }
        public string MultiCurrencyInfo { get; set; }
        public string ExtraData { get; set; }
        public string HintText { get; set; }
    }


}