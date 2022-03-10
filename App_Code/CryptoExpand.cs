using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// CryptoExpand 的摘要描述
/// </summary>
public static class CryptoExpand
{
    public static decimal GetCryptoExchangeRate(string CurrencyType)
    {
     
        string TargetCurrencyType;
        decimal ExchangeRate;
        decimal Price = 0;
        Newtonsoft.Json.Linq.JArray CryptoArrays;

        if (CurrencyType == "JKC") {
            TargetCurrencyType = "ETH";
        } else {
            TargetCurrencyType = CurrencyType;
        }

        string BasicTradeUrl = "https://api.nomics.com/v1/currencies/ticker?key=df6c6e3b0b12a416d08079b30118c78a7a07e403&ids=" + TargetCurrencyType + "&interval=1d&convert=" + EWinWeb.ConvertCurrencyType + "&per-page=100&page=1";

        var ReturnBodyStr = CodingControl.GetWebJSONContent(BasicTradeUrl);
        CryptoArrays = JArray.Parse(ReturnBodyStr.ToString());

        foreach (var Crypto in CryptoArrays) {
            if (Crypto["currency"].ToString() == TargetCurrencyType) {
                Price = (decimal)Crypto["price"];
                break;
            }
        }

        if (Price == 0) {
            ExchangeRate = 0;
        } else {
            if (CurrencyType == "JKC") {
                ExchangeRate = 1 / (Price / 3000);
            } else {
                ExchangeRate = 1 / Price;
            }
        }

        return ExchangeRate;
    }

    public static string GetAllCryptoExchangeRate() {
        Newtonsoft.Json.Linq.JArray CryptoArrays;

        string BasicTradeUrl = "https://api.nomics.com/v1/currencies/ticker?key=df6c6e3b0b12a416d08079b30118c78a7a07e403&ids=HLN,USDT,USDC,XRP,BTC,ETH&interval=1d,30d&convert=" + EWinWeb.ConvertCurrencyType + "&per-page=100&page=1";

        var ReturnBodyStr = CodingControl.GetWebJSONContent(BasicTradeUrl);
        CryptoArrays = JArray.Parse(ReturnBodyStr.ToString());

        return CryptoArrays.ToString();
    }
}