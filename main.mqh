//+------------------------------------------------------------------+
//|                                                       main.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

#include "libs/api.mqh"
#include "libs/indicator.mqh"

class Main{
   public:
         static void updateIndicatorData(string& forex_pair[], string& tf_list[]){
            // Loop Each Symbol Pair & Timeframe //
            string total_params = "";
            string indicator_name = "";
            string indicator_settings_json = "";
            string indicator_settings = "";
            string value = "";
            string params = "";
            string symbol = "";
            string timeframe = "";
            int timeframe_int = 0;
            
            for(int i=0;i<ArraySize(forex_pair);i++){
               for(int j=0;j<ArraySize(tf_list);j++){

                  symbol = forex_pair[i];
                  timeframe = tf_list[j];
                  timeframe_int = Formatter::getTimeframeInt(timeframe);

                  // Update ADX //
                  indicator_name = "ADX";
                  indicator_settings_json = "[{\"period\":\"14\",\"apply_to\":\"PRICE_CLOSE\"}]";
                  indicator_settings = ADX::buildJSONSettings(indicator_settings_json);
                  value = ADX::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendOrSendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
        
                  // Update Stochastic // 
                  indicator_name = "STOCHASTIC";
                  indicator_settings_json = "[{\"k_period\":\"5\",\"d_period\":\"3\",\"slowing\":\"3\",\"price_field\":\"LOW_HIGH\",\"method\":\"MODE_SMA\"}]";
                  indicator_settings = Stochastic::buildJSONSettings(indicator_settings_json);
                  value = Stochastic::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendOrSendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  
                  // Update CCI
                  indicator_name = "CCI";
                  indicator_settings_json = "[{\"period\":\"14\",\"apply_to\":\"PRICE_CLOSE\"}]";
                  indicator_settings = CCI::buildJSONSettings(indicator_settings_json);
                  value = CCI::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendOrSendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                      
                  //API::systemUpsertIndicatorData(symbol,timeframe,indicator_name,indicator_settings,value); // single insert (deprecated cuz too slow.)
                  
               }
            }
            API::systemUpsertIndicatorDataList("["+total_params+"]");
            printf("updateIndicatorData: success.");
         }
};
 