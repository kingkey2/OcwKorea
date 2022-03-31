﻿var LobbyAPI = function (APIUrl) {
    this.HeartBeat = function (GUID, Echo, cb) {
        var url = APIUrl + "/HeartBeat";
        var postData;

        postData = {
            GUID: GUID,
            Echo: Echo
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.UserAccountTransfer = function (WebSID, GUID, DstLoginAccount, DstCurrencyType, SrcCurrencyType, TransOutValue, WalletPassword, Description, cb) {
        var url = APIUrl + "/UserAccountTransfer";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            DstLoginAccount: DstLoginAccount,
            DstCurrencyType: DstCurrencyType,
            SrcCurrencyType: SrcCurrencyType,
            TransOutValue: TransOutValue,
            WalletPassword: WalletPassword,
            Description: Description
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.ConfirmUserAccountTransfer = function (WebSID, GUID, TransferGUID, cb) {
        var url = APIUrl + "/ConfirmUserAccountTransfer";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            TransferGUID: TransferGUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetTransferHistory = function (WebSID, GUID, BeginDate, EndDate, cb) {
        var url = APIUrl + "/GetTransferHistory";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            BeginDate: BeginDate,
            EndDate: EndDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.AddUserBankCard = function (WebSID, GUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, Description, cb) {
        var url = APIUrl + "/AddUserBankCard";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            CurrencyType: CurrencyType,
            PaymentMethod: PaymentMethod,
            BankName: BankName,
            BranchName: BranchName,
            BankNumber: BankNumber,
            AccountName: AccountName,
            Description: Description
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetUserBankCardState = function (WebSID, GUID, BankCardGUID, BankCardState, cb) {
        var url = APIUrl + "/SetUserBankCardState";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            BankCardGUID: BankCardGUID,
            BankCardState: BankCardState
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.RemoveUserBankCard = function (WebSID, GUID, BankCardGUID, cb) {
        var url = APIUrl + "/RemoveUserBankCard";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            BankCardGUID: BankCardGUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.UpdateUserBankCard = function (WebSID, GUID, BankCardGUID, CurrencyType, PaymentMethod, BankName, BranchName, BankNumber, AccountName, Description, cb) {
        var url = APIUrl + "/UpdateUserBankCard";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            BankCardGUID: BankCardGUID,
            CurrencyType: CurrencyType,
            PaymentMethod: PaymentMethod,
            BankName: BankName,
            BranchName: BranchName,
            BankNumber: BankNumber,
            AccountName: AccountName,
            Description: Description
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetUserBankCard = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetUserBankCard";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    }

    this.GetSIDParam = function (WebSID, GUID, ParamName, cb) {
        var url = APIUrl + "/GetSIDParam";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            ParamName: ParamName,
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetSIDParam = function (WebSID, GUID, ParamName, ParamValue, cb) {
        var url = APIUrl + "/SetSIDParam";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            ParamName: ParamName,
            ParamValue: ParamValue
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.KeepSID = function (WebSID, GUID, cb) {
        var url = APIUrl + "/KeepSID";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SendCSMail = function (WebSID, GUID, EMail, Topic, SendBody, cb) {
        var url = APIUrl + "/SendCSMail";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            EMail: EMail,
            Topic: Topic,
            SendBody: SendBody
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckAccountExistByContactPhoneNumber = function (GUID, PhonePrefix, PhoneNumber, cb) {
        var url = APIUrl + "/CheckAccountExistByContactPhoneNumber";
        var postData;

        postData = {
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckUserAccountByPhoneNumberAndLoginAccount = function (GUID, LoginAccount, PhonePrefix, PhoneNumber, cb) {
        var url = APIUrl + "/CheckUserAccountByPhoneNumberAndLoginAccount";
        var postData;

        postData = {
            LoginAccount: LoginAccount,
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckAccountExist = function (GUID, LoginAccount, cb) {
        var url = APIUrl + "/CheckAccountExist";
        var postData;

        postData = {
            LoginAccount: LoginAccount,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.RequireRegister = function (GUID, ParentPersonCode, PS, UBC, cb) {
        var url = APIUrl + "/RequireRegister";
        var postData;

        postData = {
            GUID: GUID,
            ParentPersonCode: ParentPersonCode,
            PS: PS,
            UBC: UBC
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    }

    this.CreateAccount = function (GUID, LoginAccount, LoginPassword, ParentPersonCode, CurrencyList, PS, cb) {
        var url = APIUrl + "/CreateAccount";
        var postData;

        postData = {
            GUID: GUID,
            LoginAccount: LoginAccount,
            LoginPassword: LoginPassword,
            ParentPersonCode: ParentPersonCode,
            CurrencyList: CurrencyList,
            PS: PS
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetLoginAccount = function (GUID, PhonePrefix, PhoneNumber, cb) {
        var url = APIUrl + "/GetLoginAccount";
        var postData;

        postData = {
            GUID: GUID,
            PhonePrefix: PhonePrefix,
            PhoneNumber: PhoneNumber
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.UserLogin = function (GUID, LoginAccount, LoginPassword, CompanyCode, cb) {
        var url = APIUrl + "/UserLogin";
        var postData;

        postData = {
            GUID: GUID,
            LoginAccount: LoginAccount,
            LoginPassword: LoginPassword,
            CompanyCode: CompanyCode
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.RecoverLogin = function (GUID, RecoverToken, UserIP, cb) {
        var url = APIUrl + "/RecoverLogin";
        var postData;

        postData = {
            RecoverToken: RecoverToken,
            GUID: GUID,
            UserIP: UserIP,
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetLoginMessage = function (WebSID,GUID, cb) {
        var url = APIUrl + "/GetLoginMessage";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetCompanySite = function (GUID, cb) {
        var url = APIUrl + "/GetCompanySite";
        var postData;

        postData = {
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetCompanyGameCodeExchange = function (GUID, CurrencyType, GameBrand, GameCode, cb) {
        var url = APIUrl + "/GetCompanyGameCodeExchange";
        var postData;

        postData = {
            GUID: GUID,
            CurrencyType: CurrencyType,
            GameBrand: GameBrand,
            GameCode: GameCode
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetParentPersonCode = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetParentPersonCode";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetUserInfo = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetUserInfo";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetUserBalance = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetUserBalance";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetCompanyGameCode = function (GUID, cb) {
        var url = APIUrl + "/GetCompanyGameCode";
        var postData;

        postData = {
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetCompanyMarqueeText = function (GUID, cb) {
        var url = APIUrl + "/GetCompanyMarqueeText";
        var postData;

        postData = {
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetGameOrderDetailHistoryBySummaryDate = function (WebSID, GUID, QueryDate, cb) {
        var url = APIUrl + "/GetGameOrderDetailHistoryBySummaryDate";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            QueryDate: QueryDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetGameOrderHistoryBySummaryDateAndGameCode = function (WebSID, GUID, QueryDate, cb) {
        var url = APIUrl + "/GetGameOrderHistoryBySummaryDateAndGameCode";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            QueryDate: QueryDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };


    this.GetGameOrderSummaryHistory = function (WebSID, GUID, QueryBeginDate, QueryEndDate, cb) {
        var url = APIUrl + "/GetGameOrderSummaryHistory";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            QueryBeginDate: QueryBeginDate,
            QueryEndDate: QueryEndDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetGameOrderSummaryHistoryGroupGameCode = function (WebSID, GUID, QueryBeginDate, QueryEndDate, cb) {
        var url = APIUrl + "/GetGameOrderSummaryHistoryGroupGameCode";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            QueryBeginDate: QueryBeginDate,
            QueryEndDate: QueryEndDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetWalletPassword = function (WebSID, GUID, LoginPassword, NewWalletPassword, cb) {
        var url = APIUrl + "/SetWalletPassword";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            LoginPassword: LoginPassword,
            NewWalletPassword: NewWalletPassword
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetUserPassword = function (WebSID, GUID, OldPassword, NewPassword, cb) {
        var url = APIUrl + "/SetUserPassword";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OldPassword: OldPassword,
            NewPassword: NewPassword
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetUserPasswordByValidateCode = function (GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, NewPassword, cb) {
        var url = APIUrl + "/SetUserPasswordByValidateCode";
        var postData;

        postData = {
            GUID: GUID,
            ValidateType: ValidateType,
            EMail: EMail,
            ContactPhonePrefix: ContactPhonePrefix,
            ContactPhoneNumber: ContactPhoneNumber,
            ValidateCode: ValidateCode,
            NewPassword: NewPassword
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetValidateCode = function (GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, cb) {
        var url = APIUrl + "/SetValidateCode";
        var postData;

        postData = {
            GUID: GUID,
            ValidateType: ValidateType,
            EMail: EMail,
            ContactPhonePrefix: ContactPhonePrefix,
            ContactPhoneNumber: ContactPhoneNumber,
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetValidateCodeByMail = function (GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, SendMailType, cb) {
        var url = APIUrl + "/SetValidateCodeByMail";
        var postData;

        postData = {
            GUID: GUID,
            ValidateType: ValidateType,
            EMail: EMail,
            ContactPhonePrefix: ContactPhonePrefix,
            ContactPhoneNumber: ContactPhoneNumber,
            SendMailType: SendMailType
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.SetUserMail = function (GUID, ValidateType, SendMailType, EMail, ContactPhonePrefix, ContactPhoneNumber, SMSContent, cb) {
        var url = APIUrl + "/SetUserMail";
        var postData;

        postData = {
            GUID: GUID,
            ValidateType: ValidateType,
            SendMailType: SendMailType,
            EMail: EMail,
            ContactPhonePrefix: ContactPhonePrefix,
            ContactPhoneNumber: ContactPhoneNumber,
            SMSContent: SMSContent
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CheckValidateCode = function (GUID, ValidateType, EMail, ContactPhonePrefix, ContactPhoneNumber, ValidateCode, cb) {
        var url = APIUrl + "/CheckValidateCode";
        var postData;

        postData = {
            GUID: GUID,
            ValidateType: ValidateType,
            EMail: EMail,
            ContactPhonePrefix: ContactPhonePrefix,
            ContactPhoneNumber: ContactPhoneNumber,
            ValidateCode: ValidateCode,
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetPaymentHistory = function (WebSID, GUID, BeginDate, EndDate, cb) {
        var url = APIUrl + "/GetPaymentHistory";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            BeginDate: BeginDate,
            EndDate: EndDate
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetBulletinBoard = function (GUID, cb) {
        var url = APIUrl + "/GetBulletinBoard";
        var postData;

        postData = {
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.GetCompanyExchange = function (GUID, cb) {
        var url = APIUrl + "/GetCompanyExchange";
        var postData;

        postData = {
            GUID: GUID
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    this.CreateBigEagle = function (LoginAccount, cb) {
        var url = APIUrl + "/CreateBigEagle";
        var postData;

        postData = {
            LoginAccount: LoginAccount
        };

        callService(url, postData, 10000, function (success, text) {
            if (success == true) {
                var obj = getJSON(text);

                if (cb)
                    cb(true, obj);
            } else {
                if (cb)
                    cb(false, text);
            }
        });
    };

    function callService(URL, postObject, timeoutMS, cb) {
        var xmlHttp = new XMLHttpRequest;
        var postData;

        if (postObject)
            postData = JSON.stringify(postObject);

        xmlHttp.open("POST", URL, true);
        xmlHttp.onreadystatechange = function () {
            if (this.readyState == 4) {
                var contentText = this.responseText;

                if (this.status == "200") {
                    if (cb) {
                        cb(true, contentText);
                    }
                } else {
                    cb(false, contentText);
                }
            }
        };

        xmlHttp.timeout = timeoutMS;
        xmlHttp.ontimeout = function () {
            /*
            timeoutTryCount += 1;

            if (timeoutTryCount < 2)
                xmlHttp.send(postData);
            else*/
            if (cb)
                cb(false, "Timeout");
        };

        xmlHttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
        xmlHttp.send(postData);
    }

    function getJSON(text) {
        var obj = JSON.parse(text);

        if (obj) {
            if (obj.hasOwnProperty('d')) {
                return obj.d;
            } else {
                return obj;
            }
        }
    }
}