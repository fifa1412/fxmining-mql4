//+------------------------------------------------------------------+
//|                                                    indicator.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

#include "formatter.mqh"
#include "JAson.mqh"

class ADX{
   public: 
      static string buildJSONSettings(string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         return "{\"period\":"+json[0]["period"].ToStr()+",\"apply_to\":\""+json[0]["apply_to"].ToStr()+"\"}";
      }
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
      static string buildJSONSettings(string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         return "{\"k_period\":"+json[0]["k_period"].ToStr()+",\"d_period\":"+json[0]["d_period"].ToStr()+",\"slowing\":"+json[0]["slowing"].ToStr()+",\"price_field\":\""+json[0]["price_field"].ToStr()+"\",\"method\":\""+json[0]["method"].ToStr()+"\"}";
      }
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
      static string buildJSONSettings(string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         return "{\"period\":"+json[0]["period"].ToStr()+",\"apply_to\":\""+json[0]["apply_to"].ToStr()+"\"}";
      }
      static string buildValue(string symbol,int timeframe_int,string indicator_settings){
         CJAVal json;
         json.Deserialize(indicator_settings);
         int period = (int)json[0]["period"].ToStr();
         int apply_to_int = Formatter::getApplyPriceInt(json[0]["apply_to"].ToStr());
         double icci = iCCI(symbol,timeframe_int,period,apply_to_int,0);    
         return "{\"main_value\":"+(string)icci+"}";
      }
     
};