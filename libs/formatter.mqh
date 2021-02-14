//+------------------------------------------------------------------+
//|                                                    formatter.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

class Formatter{
   public:
      static int getTimeframeInt(string tf){
         if(tf == "M1")         return 1;
         else if(tf == "M5")    return 5;
         else if(tf == "M15")   return 15;
         else if(tf == "M30")   return 30;
         else if(tf == "H1")    return 60;
         else if(tf == "H4")    return 240;
         else if(tf == "D1")    return 1440;
         else if(tf == "W1")    return 10080;
         else if(tf == "MN1")   return 43200;
         else                   return 0;
      }
      
      static string fJSON(string name, string value){
         return "\""+name+"\":\""+(string)value+"\"";
      }
      
      static string fJSONObj(string name, string value){
         return "\""+name+"\":"+(string)value;
      }
      
      static int getMAMethodsInt(string methods){
         if(methods == "MODE_SMA")        return 0;
         else if(methods == "MODE_EMA")   return 1;
         else if(methods == "MODE_SMMA")  return 2;
         else if(methods == "MODE_LWMA")  return 3;
         else                             return 99;
      }
      
      static int getPriceFieldInt(string methods){
         if(methods == "LOW_HIGH")           return 0;
         else if(methods == "CLOSE_CLOSE")   return 1;
         else                                return 99;
      }
      
      static int getApplyPriceInt(string apply_to){
         if(apply_to == "PRICE_CLOSE")          return 0;
         else if(apply_to == "PRICE_OPEN")      return 1;
         else if(apply_to == "PRICE_HIGH")      return 2;
         else if(apply_to == "PRICE_LOW")       return 3;
         else if(apply_to == "PRICE_MEDIAN")    return 4;
         else if(apply_to == "PRICE_TYPICAL")   return 5;
         else if(apply_to == "PRICE_WEIGHTED")  return 6;
         else                                   return 99;
      }
      

};
