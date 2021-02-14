//+------------------------------------------------------------------+
//|                                                    indicator.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

#include "JAson.mqh"

class Symbol{
   public:
      static string buildValue(double price_bid, double price_ask,double swap_long,double swap_short, double spread, 
         double today_adr, double adr_1, double adr_5, double adr_10, double adr_20,bool trade_allowed){
         return "{\"price_bid\":"+(string)price_bid
         +",\"price_ask\":"+(string)price_ask
         +",\"swap_long\":"+(string)swap_long
         +",\"swap_short\":"+(string)swap_short
         +",\"spread\":"+(string)spread
         +",\"today_adr\":"+(string)today_adr
         +",\"adr_1\":"+(string)adr_1
         +",\"adr_5\":"+(string)adr_5
         +",\"adr_10\":"+(string)adr_10
         +",\"adr_20\":"+(string)adr_20
         +",\"trade_allowed\":"+(string)trade_allowed
         +"}";
      }
};

class Indicator{
   public:
      static string buildJSONSettings(string indicator_name,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         if(indicator_name == "ADX" || indicator_name == "CCI" || indicator_name == "RSI"){
            return "{\"period\":"+json[0]["period"].ToStr()+",\"apply_to\":\""+json[0]["apply_to"].ToStr()+"\"}";
         }else if(indicator_name == "STOCHASTIC"){
            return "{\"k_period\":"+json[0]["k_period"].ToStr()+",\"d_period\":"+json[0]["d_period"].ToStr()+",\"slowing\":"+json[0]["slowing"].ToStr()+",\"price_field\":\""+json[0]["price_field"].ToStr()+"\",\"method\":\""+json[0]["method"].ToStr()+"\"}";
         }else if(indicator_name == "MA"){
            return "{\"period\":"+json[0]["period"].ToStr()+",\"apply_to\":\""+json[0]["apply_to"].ToStr()+"\",\"method\":\""+json[0]["method"].ToStr()+"\"}";
         }else{
            return "";
         } 
      }
};

class ADR{
   public:
      static double calculateADR(string symbol, int day){
         double adr_sum = 0;
         for(int i=1;i<=day;i++){
            adr_sum+=(iHigh(symbol,PERIOD_D1,i)-iLow(symbol,PERIOD_D1,i))*MathPow(10,MarketInfo(symbol,MODE_DIGITS));
         }
         return adr_sum/day;
      }
};

class ADX{
   public: 
      static string buildValue(string symbol,int timeframe_int,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         int period = (int)json[0]["period"].ToStr();
         int apply_to_int = Formatter::getApplyPriceInt(json[0]["apply_to"].ToStr());
         double iadx_mode_main = iADX(symbol,timeframe_int,period,apply_to_int,MODE_MAIN,0);
         double iadx_mode_plusdi = iADX(symbol,timeframe_int,period,apply_to_int,MODE_PLUSDI,0);
         double iadx_mode_minusdi = iADX(symbol,timeframe_int,period,apply_to_int,MODE_MINUSDI,0);       
         return "{\"mode_main\":"+(string)iadx_mode_main+",\"mode_plusdi\":"+(string)iadx_mode_plusdi+",\"mode_minusdi\":"+(string)iadx_mode_minusdi+"}";
      }
};

class Stochastic{
   public:
      static string buildValue(string symbol,int timeframe_int ,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         int k_period = (int)json[0]["k_period"].ToStr();
         int d_period = (int)json[0]["d_period"].ToStr();
         int slowing = (int)json[0]["slowing"].ToStr();
         int price_field = Formatter::getPriceFieldInt(json[0]["price_field"].ToStr());
         int method = Formatter::getMAMethodsInt(json[0]["method"].ToStr());
         double istoch_mode_main = iStochastic(symbol,timeframe_int,k_period,d_period,slowing,method,price_field,MODE_MAIN,0);
         double istoch_mode_signal = iStochastic(symbol,timeframe_int,k_period,d_period,slowing,method,price_field,MODE_SIGNAL,0);  
         return "{\"mode_main\":"+(string)istoch_mode_main+",\"mode_signal\":"+(string)istoch_mode_signal+"}";
      }
      
};

class CCI{
   public:
      static string buildValue(string symbol,int timeframe_int,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         int period = (int)json[0]["period"].ToStr();
         int apply_to_int = Formatter::getApplyPriceInt(json[0]["apply_to"].ToStr());
         double icci = iCCI(symbol,timeframe_int,period,apply_to_int,0);    
         return "{\"main_value\":"+(string)icci+"}";
      }
     
};

class RSI{
   public:
      static string buildValue(string symbol,int timeframe_int,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         int period = (int)json[0]["period"].ToStr();
         int apply_to_int = Formatter::getApplyPriceInt(json[0]["apply_to"].ToStr());
         double irsi = iRSI(symbol,timeframe_int,period,apply_to_int,0);    
         return "{\"main_value\":"+(string)irsi+"}";
      }
     
};

class MA{
   public:
      static string buildValue(string symbol,int timeframe_int,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         int period = (int)json[0]["period"].ToStr();
         int method = Formatter::getMAMethodsInt(json[0]["method"].ToStr());
         int apply_to_int = Formatter::getApplyPriceInt(json[0]["apply_to"].ToStr());
         double ima = iMA(symbol,timeframe_int,period,0,method,apply_to_int,0);    
         return "{\"main_value\":"+(string)ima+"}";
      }
};