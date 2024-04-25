//+------------------------------------------------------------------+
//|                                                          api.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

class API{
   public:
      static string appendParams(string total_params, string symbol, string timeframe, string indicator_name, string indicator_settings, string value){
         string params = "{\"symbol\":\""+symbol+"\",\"timeframe\":\""+timeframe+"\",\"indicator_name\":\""+indicator_name+"\",\"indicator_settings\":"+indicator_settings+",\"value\":"+value+"}";
         string return_params = "";
         if(total_params!=""){
            return_params = total_params + "," + params;
         }else{
            return_params = params;
         }
         
         return return_params;
         
         /* /* Deprecate 2021-10-02 (Change Send Method From GET -> POST)
         if(StringLen(return_params) > 800){
            API::systemUpsertIndicatorDataList("["+return_params+"]");
            return "";
         }else{
            return return_params;
         }*/
      }
      
      static string appendParamsSymbol(string total_params, string symbol, string value){
         string params = "{\"symbol\":\""+symbol+"\",\"value\":"+value+"}";
         string return_params = "";
         if(total_params!=""){
            return_params = total_params + "," + params;
         }else{
            return_params = params;
         }
         
         return return_params;
         
         /* Deprecate 2021-10-02 (Change Send Method From GET -> POST)
         if(StringLen(return_params) > 800){
            API::systemUpsertSymbolDataList("["+return_params+"]");
            return "";
         }else{
            return return_params;
         }*/
      }
         
      static void callAPI(string strUrl,string total_params) {
         string headers;  
         char post[],result[];
         
         string strJsonText = "total_params="+total_params;
         uchar jsonData[];
         StringToCharArray(strJsonText, jsonData, 0, StringLen(strJsonText));
         
         int timeout = 5000;
         int res_code = WebRequest("POST",strUrl,"","",timeout,jsonData,ArraySize(jsonData),result,headers);
         if (res_code == 200) { 
              printf(strUrl+": Success.");
         }else{
              printf(strUrl+": Cannot Connect API Server.");
         }
      }
      
      static string callAPIWithResponse(string strUrl,string total_params) {
          string headers;  
          char post[],result[];
            
          string strJsonText = "total_params="+total_params;
          uchar jsonData[];
          StringToCharArray(strJsonText, jsonData, 0, StringLen(strJsonText));
            
          int timeout = 5000;
          int res_code = WebRequest("POST",strUrl,"","",timeout,jsonData,ArraySize(jsonData),result,headers);
            
          return CharArrayToString(result);
      }
      
      static void sendDataToAPI(string url,string total_params){
         API::callAPI(ENV::getConfig("API_SERVER_URL") + url,"["+total_params+"]");
      }
      
      /* Deprecated (2020-01-07)
      static void systemUpsertIndicatorData(string symbol, string timeframe, string indicator_name, string indicator_settings, string value){
         string url = ENV::getConfig("API_SERVER_URL") + "Indicator/systemUpsertIndicatorData?symbol="+symbol+"&timeframe="+timeframe+"&indicator_name="+indicator_name+"&indicator_settings="+indicator_settings+"&value="+value;
         API::callAPI(url);
      }*/
      
      static void systemUpsertIndicatorDataList(string total_params){
         string url = ENV::getConfig("API_SERVER_URL") + "api/Expert/systemUpsertIndicatorData";
         API::callAPI(url,total_params);
      }
      
      static void systemUpsertSymbolDataList(string total_params){
         string url = ENV::getConfig("API_SERVER_URL") + "api/Expert/systemUpsertPairData";
         API::callAPI(url,total_params);
      }
      
};
 