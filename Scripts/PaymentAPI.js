var PaymentAPI = function (APIUrl) {
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

    this.GetClosePayment = function (WebSID, GUID, startDate, endDate, cb) {
        var url = APIUrl + "/GetClosePayment";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            StartDate: startDate,
            EndDate: endDate
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

    this.GetAgentWithdrawalPayment = function (WebSID, GUID, startDate, cb) {
        var url = APIUrl + "/GetAgentWithdrawalPayment";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            SearchDate: startDate
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

    this.GetPaymentMethodByCategory = function (WebSID, GUID, PaymentCategoryCode, PaymentType, cb) {
        var url = APIUrl + "/GetPaymentMethodByCategory";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            PaymentCategoryCode: PaymentCategoryCode,
            PaymentType: PaymentType
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

    this.GetDepositActivityInfoByOrderNumber = function (WebSID, GUID, OrderNumber, cb) {
        var url = APIUrl + "/GetDepositActivityInfoByOrderNumber";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OrderNumber: OrderNumber
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

    this.CreateCryptoDeposit = function (WebSID, GUID, Amount, PaymentMethodID, cb) {
        var url = APIUrl + "/CreateCryptoDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            Amount: Amount,
            PaymentMethodID: PaymentMethodID
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

    this.ConfirmCryptoDeposit = function (WebSID, GUID, OrderNumber, ActivityNames, cb) {
        var url = APIUrl + "/ConfirmCryptoDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OrderNumber: OrderNumber,
            ActivityNames: ActivityNames
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

    this.CreateCommonDeposit = function (WebSID, GUID, Amount, PaymentMethodID, cb) {
        var url = APIUrl + "/CreateCommonDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            Amount: Amount,
            PaymentMethodID: PaymentMethodID
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

    this.ConfirmCommonDeposit = function (WebSID, GUID, OrderNumber, ActivityNames, cb) {
        var url = APIUrl + "/ConfirmCommonDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OrderNumber: OrderNumber,
            ActivityNames: ActivityNames
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

    this.CreateEPayDeposit = function (WebSID, GUID, Amount, PaymentMethodID, cb) {
        var url = APIUrl + "/CreateEPayDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            Amount: Amount,
            PaymentMethodID: PaymentMethodID
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

    this.ConfirmEPayDeposit = function (WebSID, GUID, OrderNumber, ActivityNames, Lang, cb) {
        var url = APIUrl + "/ConfirmEPayDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OrderNumber: OrderNumber,
            ActivityNames: ActivityNames,
            Lang: Lang
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


    this.CreatePayPalDeposit = function (WebSID, GUID, Amount, PaymentMethodID, cb) {
        var url = APIUrl + "/CreatePayPalDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            Amount: Amount,
            PaymentMethodID: PaymentMethodID
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

    this.ConfirmPayPalDeposit = function (WebSID, GUID, OrderNumber, ActivityNames, Lang, cb) {
        var url = APIUrl + "/ConfirmPayPalDeposit";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OrderNumber: OrderNumber,
            ActivityNames: ActivityNames,
            Lang: Lang
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
    this.CreateAgentWithdrawal = function (WebSID, GUID, Amount, BankName, BankBranchName, BankCard, BankCardName ,cb) {
        var url = APIUrl + "/CreateAgentWithdrawal";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            Amount: Amount,
            BankName: BankName,
            BankBranchName: BankBranchName,
            BankCard: BankCard,
            BankCardName: BankCardName
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
  
    this.CreateCryptoWithdrawal = function (WebSID, GUID, Amount, PaymentMethodID, ToWalletAddress, cb) {
        var url = APIUrl + "/CreateCryptoWithdrawal";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            Amount: Amount,
            PaymentMethodID: PaymentMethodID,
            ToWalletAddress: ToWalletAddress
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

    this.ConfirmCryptoWithdrawal = function (WebSID, GUID, OrderNumber, cb) {
        var url = APIUrl + "/ConfirmCryptoWithdrawal";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            OrderNumber: OrderNumber
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

    this.GetPaymentByNonFinished = function (WebSID, GUID, cb) {
        var url = APIUrl + "/GetPaymentByNonFinished";
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

    this.GetPaymentByPaymentSerial = function (WebSID, GUID, PaymentSerial, cb) {
        var url = APIUrl + "/GetPaymentByPaymentSerial";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            PaymentSerial: PaymentSerial
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

    this.GetInProgressPaymentByLoginAccount = function (WebSID, GUID, LoginAccount, PaymentType, cb) {
        var url = APIUrl + "/GetInProgressPaymentByLoginAccount";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            PaymentType: PaymentType
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

    this.GetInProgressPaymentByLoginAccountPaymentMethodID = function (WebSID, GUID, LoginAccount, PaymentType, PaymentMethodID, cb) {
        var url = APIUrl + "/GetInProgressPaymentByLoginAccountPaymentMethodID";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            LoginAccount: LoginAccount,
            PaymentType: PaymentType,
            PaymentMethodID: PaymentMethodID
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

    this.GetPaymentByClientOrderNumber = function (WebSID, GUID, ClientOrderNumber, cb) {
        var url = APIUrl + "/GetPaymentByClientOrderNumber";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            ClientOrderNumber: ClientOrderNumber
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

    this.CancelPayment = function (WebSID, GUID, PaymentSerial, OrderNumber, cb) {
        var url = APIUrl + "/CancelPayment";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            PaymentSerial: PaymentSerial,
            OrderNumber: OrderNumber
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

    this.GetExchangeRateFromNomics = function (WebSID, GUID, cb) {

        var url = APIUrl + "/GetExchangeRateFromNomics";
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

        //var xmlHttp = new XMLHttpRequest;

        //xmlHttp.open("GET", "https://api.nomics.com/v1/currencies/ticker?key=df6c6e3b0b12a416d08079b30118c78a7a07e403&ids=HLN,USDT,USDC,XRP,BTC,ETH&interval=1d,30d&convert=JPY&per-page=100&page=1", true);
        //xmlHttp.onreadystatechange = function () {
        //    if (this.readyState == 4) {
        //        var contentText = this.responseText;

        //        if (this.status == "200") {
        //            if (cb) {
        //                cb(true, getJSON(contentText));
        //            }
        //        } else {
        //            cb(false, contentText);
        //        }
        //    }
        //};

        //xmlHttp.timeout = 10000;
        //xmlHttp.ontimeout = function () {
        //    /*
        //    timeoutTryCount += 1;

        //    if (timeoutTryCount < 2)
        //        xmlHttp.send(postData);
        //    else*/
        //    if (cb)
        //        cb(false, "Timeout");
        //};

        //xmlHttp.send();
    }

    this.GetUserAccountEventBonusHistoryByLoginAccount = function (WebSID, GUID, startDate, endDate, cb) {
        var url = APIUrl + "/GetUserAccountEventBonusHistoryByLoginAccount";
        var postData;

        postData = {
            WebSID: WebSID,
            GUID: GUID,
            StartDate: startDate,
            EndDate: endDate
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