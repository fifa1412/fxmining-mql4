//+------------------------------------------------------------------+
//|                                                          env.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

class ENV{
   public:
        static void getConfig(string configName){
            if(configName == "API_SERVER_URL"){
                return "https://45.154.24.224:8000/"; // ReadyIDC VM //
            }else{
                return  "";
            }
        }
     
};
 