<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EWinPaymentCallBack.aspx.cs" Inherits="Payment_EWinPaymentCallBack" %>

<%
    PaymentCallbackResult R = new PaymentCallbackResult() { Result = 1 };
    string GUID = System.Guid.NewGuid().ToString();

    if (CodingControl.FormSubmit()) {
        string PostBody = String.Empty;
        PaymentCallbackInfo BodyObj = new PaymentCallbackInfo();
        string Path = "C:\\inetpub\\Dev\\Casino3651\\Files\\EWinCallBack";

         using (System.IO.StreamReader reader = new System.IO.StreamReader(Request.InputStream)) {
            PostBody = reader.ReadToEnd();
        };

        try { System.IO.File.AppendAllText(Path + "\\" + System.DateTime.Now.ToString("yyyy/MM/dd") + ".log", "PostBody=" + PostBody + "\r\n"); } catch (Exception ex) { }

        if (string.IsNullOrEmpty(PostBody) == false) {
            try { BodyObj = Newtonsoft.Json.JsonConvert.DeserializeObject<PaymentCallbackInfo>(PostBody); } catch (Exception ex) {
                BodyObj = null;
            }

            if (BodyObj != null) {

                EWin.Payment.PaymentAPI paymentAPI = new EWin.Payment.PaymentAPI();
                var a = GetToken();
                EWin.Payment.PaymentResult paymentResult = paymentAPI.GetPaymentByClientOrderNumber(a, GUID, BodyObj.ClientOrderNumber);
                //回去EWin確認該筆訂單存在

                if (paymentResult.ResultStatus == EWin.Payment.enumResultStatus.OK) {
                    if (BodyObj.DirectionType == "Deposit") {
                        if (BodyObj.Action == "Create") {
                            R.Result = 0;
                        } else if (BodyObj.Action == "Finished") {
                            EWinTagInfoData tagInfoData;
                            //訂單完成，先處理入金產生的門檻

                            try { tagInfoData = Newtonsoft.Json.JsonConvert.DeserializeObject<EWinTagInfoData>(BodyObj.TagInfo); } catch (Exception ex) {
                                tagInfoData = null;
                            }

                            if (tagInfoData != null) {
                                EWin.Lobby.LobbyAPI lobbyAPI = new EWin.Lobby.LobbyAPI();
                                EWin.Lobby.APIResult addThresholdResult;
                                string description;
                                string transactionCode;

                                transactionCode = BodyObj.PaymentSerial;
                                description = "Deposit, PaymentCode=" + tagInfoData.PaymentCode + ", Amount=" + BodyObj.Amount;
                                addThresholdResult = lobbyAPI.AddThreshold(GetToken(), GUID, transactionCode, BodyObj.LoginAccount, EWinWeb.MainCurrencyType, tagInfoData.ThresholdValue, description, false);

                                if (addThresholdResult.Result == EWin.Lobby.enumResult.OK || addThresholdResult.Message == "-2") {
                                    string TotalErrorMsg = string.Empty;

                                    if (tagInfoData.IsJoinDepositActivity) {
                                        //有參加入金活動
                                        foreach (var activityData in tagInfoData.ActivityDatas) {
                                            transactionCode = BodyObj.PaymentSerial + "_" + activityData.ActivityName;
                                            description = "DepositActivity, PaymentCode=" + tagInfoData.PaymentCode + ", BonusValue=" + activityData.BonusValue;
                                            addThresholdResult = lobbyAPI.AddThreshold(GetToken(), System.Guid.NewGuid().ToString(), transactionCode, BodyObj.LoginAccount, EWinWeb.MainCurrencyType, activityData.ThresholdValue, description, false);

                                            if (addThresholdResult.Result == EWin.Lobby.enumResult.OK) {
                                                //新增領取紀錄
                                                var EventBonusHistoryID = EWinWebDB.UserAccountEventBonusHistory.InsertEventBonusHistory(BodyObj.LoginAccount, activityData.ActivityName, BodyObj.ClientOrderNumber, activityData.BonusRate, activityData.BonusValue, activityData.ThresholdRate, activityData.ThresholdValue, EWinWebDB.UserAccountEventBonusHistory.EventType.Deposit);
                                                if (EventBonusHistoryID != 0) {
                                                    ReportSystem.UserAccountEventBonusHistory.CreateUserAccountEventBonusHistory(EventBonusHistoryID);
                                                }
                                            } else {
                                                if (addThresholdResult.Message != "-2") {
                                                    TotalErrorMsg += "ActivityName=" + activityData.ActivityName + " AddThresholdError Msg=" + addThresholdResult.Message + ",";
                                                }
                                            }
                                        }
                                    } else {
                                        TotalErrorMsg = string.Empty;
                                    }

                                    if (string.IsNullOrEmpty(TotalErrorMsg)) {
                                        var allParentBonusAfterDepositResult = ActivityCore.GetAllParentBonusAfterDepositResult(BodyObj.LoginAccount);
                                        TotalErrorMsg = string.Empty;

                                        if (allParentBonusAfterDepositResult.Result == ActivityCore.enumActResult.OK) {
                                            EWin.OCW.OCW ocwApi = new EWin.OCW.OCW();


                                            foreach (var activityData in allParentBonusAfterDepositResult.DataList) {
                                                transactionCode = BodyObj.PaymentSerial + "_" + activityData.ActivityName;
                                                description = "ParentBonusAfterDeposit, ChildLoginAccount=" + activityData.LoginAccount;
                                                EWin.OCW.APIResult ocwResult = ocwApi.AddBonusValue(GetToken(), System.Guid.NewGuid().ToString(), transactionCode, activityData.ParentLoginAccount, EWinWeb.MainCurrencyType, activityData.BonusValue, activityData.ThresholdValue, description, description + ", BonusValue" + activityData.BonusValue.ToString());

                                                if (ocwResult.ResultState == EWin.OCW.enumResultState.OK) {

                                                } else {
                                                    TotalErrorMsg += "ActivityName=" + activityData.ActivityName + " AddThresholdError Msg=" + addThresholdResult.Message + ",";
                                                }
                                            }

                                            if (string.IsNullOrEmpty(TotalErrorMsg)) {
                                                int FinishPaymentRet;

                                                FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Success, BodyObj.PaymentSerial);

                                                if (FinishPaymentRet == 0) {
                                                    R.Result = 0;
                                                    RedisCache.PaymentContent.DeletePaymentContent(BodyObj.ClientOrderNumber);
                                                    ReportSystem.UserAccountPayment.CreateUserAccountPayment(BodyObj.ClientOrderNumber);
                                                    RedisCache.UserAccountTotalSummary.UpdateUserAccountTotalSummaryByLoginAccount(BodyObj.LoginAccount);
                                                    RedisCache.UserAccountSummary.UpdateUserAccountSummary(BodyObj.LoginAccount, DateTime.Now.Date);
                                                } else {
                                                    SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                                                }
                                            } else {
                                                SetResultException(R, TotalErrorMsg.Substring(0, TotalErrorMsg.Length - 1));
                                            }
                                        } else {
                                            SetResultException(R, "AllParentBonusAfterDepositResultError,Msg=" + allParentBonusAfterDepositResult.Message);
                                        }


                                    } else {
                                        SetResultException(R, TotalErrorMsg.Substring(0, TotalErrorMsg.Length - 1));
                                    }
                                } else {
                                    SetResultException(R, "AddThresholdError,Msg=" + addThresholdResult.Message);
                                }
                            } else {
                                SetResultException(R, "TagInfoFormatError");
                            }
                        } else if (BodyObj.Action == "Cancel") {
                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Cancel, BodyObj.PaymentSerial);

                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                RedisCache.PaymentContent.DeletePaymentContent(BodyObj.ClientOrderNumber);
                                ReportSystem.UserAccountPayment.CreateUserAccountPayment(BodyObj.ClientOrderNumber);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else if (BodyObj.Action == "Reject") {

                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Reject, BodyObj.PaymentSerial);

                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                RedisCache.PaymentContent.DeletePaymentContent(BodyObj.ClientOrderNumber);
                                ReportSystem.UserAccountPayment.CreateUserAccountPayment(BodyObj.ClientOrderNumber);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else if (BodyObj.Action == "Accept") {
                            R.Result = 0;

                            //int FinishPaymentRet;

                            //FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Accept, BodyObj.PaymentSerial);

                            //if (FinishPaymentRet == 0) {
                            //    R.Result = 0;
                            //} else {
                            //    SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            //}
                        } else if (BodyObj.Action == "CancelResume") {
                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.ResumePaymentFlowStatus(BodyObj.ClientOrderNumber, BodyObj.PaymentSerial);


                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                var DT = EWinWebDB.UserAccountPayment.GetPaymentByOrderNumber(BodyObj.ClientOrderNumber);
                                var Data = CovertFromRow(DT.Rows[0]);
                                ReportSystem.UserAccountPayment.ResetUserAccountPayment(BodyObj.LoginAccount, DateTime.Now.Date);
                                RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(Data), Data.OrderNumber, Data.ExpireSecond);
                                RedisCache.PaymentContent.KeepPaymentContents(Data, BodyObj.LoginAccount);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else {
                            SetResultException(R, "UnknownAction");
                        }
                    } else if (BodyObj.DirectionType == "Withdrawal") {
                        if (BodyObj.Action == "Create") {
                            R.Result = 0;
                        } else if (BodyObj.Action == "Finished") {
                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Success, BodyObj.PaymentSerial);

                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                RedisCache.PaymentContent.DeletePaymentContent(BodyObj.ClientOrderNumber);
                                ReportSystem.UserAccountPayment.CreateUserAccountPayment(BodyObj.ClientOrderNumber);
                                RedisCache.UserAccountTotalSummary.UpdateUserAccountTotalSummaryByLoginAccount(BodyObj.LoginAccount);
                                RedisCache.UserAccountSummary.UpdateUserAccountSummary(BodyObj.LoginAccount, DateTime.Now.Date);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else if (BodyObj.Action == "Cancel") {
                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Cancel, BodyObj.PaymentSerial);

                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                RedisCache.PaymentContent.DeletePaymentContent(BodyObj.ClientOrderNumber);
                                ReportSystem.UserAccountPayment.CreateUserAccountPayment(BodyObj.ClientOrderNumber);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else if (BodyObj.Action == "Reject") {

                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Reject, BodyObj.PaymentSerial);

                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                RedisCache.PaymentContent.DeletePaymentContent(BodyObj.ClientOrderNumber);
                                ReportSystem.UserAccountPayment.CreateUserAccountPayment(BodyObj.ClientOrderNumber);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else if (BodyObj.Action == "Accept") {
                            R.Result = 0;
                            //int FinishPaymentRet;

                            //FinishPaymentRet = EWinWebDB.UserAccountPayment.FinishPaymentFlowStatus(BodyObj.ClientOrderNumber, EWinWebDB.UserAccountPayment.FlowStatus.Accept, BodyObj.PaymentSerial);

                            //if (FinishPaymentRet == 0) {
                            //    R.Result = 0;
                            //} else {
                            //    SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            //}
                        } else if (BodyObj.Action == "CancelResume") {
                            int FinishPaymentRet;

                            FinishPaymentRet = EWinWebDB.UserAccountPayment.ResumePaymentFlowStatus(BodyObj.ClientOrderNumber, BodyObj.PaymentSerial);


                            if (FinishPaymentRet == 0) {
                                R.Result = 0;
                                var DT = EWinWebDB.UserAccountPayment.GetPaymentByOrderNumber(BodyObj.ClientOrderNumber);
                                var Data = CovertFromRow(DT.Rows[0]);
                                ReportSystem.UserAccountPayment.ResetUserAccountPayment(BodyObj.LoginAccount, DateTime.Now.Date);
                                RedisCache.PaymentContent.UpdatePaymentContent(Newtonsoft.Json.JsonConvert.SerializeObject(Data), Data.OrderNumber, Data.ExpireSecond);
                                RedisCache.PaymentContent.KeepPaymentContents(Data, BodyObj.LoginAccount);
                            } else {
                                SetResultException(R, "FinishOrderFailure, Msg=" + FinishPaymentRet.ToString());
                            }
                        } else {
                            SetResultException(R, "UnknownAction");
                        }
                    } else {
                        SetResultException(R, "UnknownDirectionType");
                    }
                } else {
                    SetResultException(R, "NoExist");
                }


            } else {
                SetResultException(R, "BodyFormatError");
            }
        } else {
            SetResultException(R, "NoBody");
        }
    } else {
        SetResultException(R, "NotPost");
    }


    if (R != null) {
        Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(R));
        Response.ContentType = "application/json";
        Response.Flush();
        Response.End();
    }
%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
</body>
</html>
