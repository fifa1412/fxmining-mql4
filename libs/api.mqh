//+------------------------------------------------------------------+
//|                                                          api.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

class API{
   public:
      static string appendOrSendParams(string total_params, string symbol, string timeframe, string indicator_name, string indicator_settings, string value){
         string params = "{\"symbol\":\""+symbol+"\",\"timeframe\":\""+timeframe+"\",\"indicator_name\":\""+indicator_name+"\",\"indicator_settings\":"+indicator_settings+",\"value\":"+value+"}";
         string return_params = "";
         if(total_params!=""){
            return_params = total_params + "," + params;
         }else{
            return_params = params;
         }
         
         if(StringLen(return_params) > 800){
            API::systemUpsertIndicatorDataList("["+return_params+"]");
            return "";
         }else{
            return return_params;
         }
      }
         
      static string callAPI(string strUrl) {
         string headers;  
         char post[],result[];
         int timeout = 5000;
         int res = WebRequest("GET",strUrl,NULL,timeout,post,result,headers);
         if (res < 0) { 
              printf("Cannot Connect API Server." );
              return("");
         } 
         return(CharArrayToString(result,0,-1));
      }
      
      /* Deprecated (2020-01-07)
      static void systemUpsertIndicatorData(string symbol, string timeframe, string indicator_name, string indicator_settings, string value){
         string url = ENV::getConfig("API_SERVER_URL") + "Indicator/systemUpsertIndicatorData?symbol="+symbol+"&timeframe="+timeframe+"&indicator_name="+indicator_name+"&indicator_settings="+indicator_settings+"&value="+value;
         API::callAPI(url);
      }*/
      
      static void systemUpsertIndicatorDataList(string total_params){
         string url = ENV::getConfig("API_SERVER_URL") + "Indicator/systemUpsertIndicatorDataList?data=" + total_params;
         API::callAPI(url);
      }
};
 