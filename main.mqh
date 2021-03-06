//+------------------------------------------------------------------+
//|                                                       main.mqh |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property strict

#include "libs/api.mqh"
#include "libs/indicator.mqh"
#include "libs/formatter.mqh"

class Main{
   public:
         static void checkRequestOrder(){
            string url = ENV::getConfig("API_SERVER_URL") + "api/Expert/systemGetRequestOrderList";
            string total_params = "[{}]";
            string res = API::callAPIWithResponse(url,total_params);
            int slippage = 3;
            CJAVal json;
            json.Deserialize(res);
            
            // Start If Response Success.
            if(json["status"]["code"] == 200){
               // Loop Execute Each Request Order //
               int total_order = (int)json["data"]["count"].ToInt();
               for(int ii=0;ii<total_order;ii++){
                  string status = json["data"]["order_list"][ii]["status"].ToStr();
                  string symbol = json["data"]["order_list"][ii]["symbol"].ToStr();
                  string type = json["data"]["order_list"][ii]["type"].ToStr();
                  double lot = json["data"]["order_list"][ii]["lot"].ToDbl();
                  string order_id = json["data"]["order_list"][ii]["order_id"].ToStr();
                  string order_group_id = json["data"]["order_list"][ii]["order_group_id"].ToStr();
                  string comment = "s:apt,gid:"+order_group_id+",id:"+order_id;
                  
                  if(status=="request_open"){
                     int order_ticket = 0;
                     if(type=="BUY"){
                        order_ticket = OrderSend(symbol,OP_BUY,lot,NormalizeDouble(Ask,MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
                     }else{
                        order_ticket = OrderSend(symbol,OP_SELL,lot,NormalizeDouble(Bid,MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);   
                     }
                     if(order_ticket < 0){
                        string is_trade_allow = "";  //s:apt,gid:puWa,id:apuWa
                        if(IsTradeAllowed()==false){is_trade_allow = " => AutoTrading Disabled";}
                        printf("Cannot Execute Order: " + type + " " + symbol + " " + (string)lot + " " + comment + is_trade_allow);
                        // Send Failed Open Order Count => future  
                     }
                     else{
                        Print("Execute Order: " + type + " " + symbol + " " + (string)lot + " " + comment + " => Success. (Ticket: "+(string)order_ticket+")");
                        Main::updateOrderStatus(order_id,order_ticket,"opened");
                     }
                     
                  }else if(status=="request_close"){
                     int order_ticket = (int)json["data"]["order_list"][ii]["order_ticket"].ToStr();
                     if(OrderSelect(order_ticket,SELECT_BY_TICKET)){
                        if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
                           Print("Error Closing Order (Ticket: "+(string)order_ticket+")");
                        }else{
                           Main::updateOrderStatus(order_id,order_ticket,"closed");
                        }
                     }
                  }
               }
            }
         }
         
         static void updateOrderStatus(string order_id,int order_ticket,string status){
            string url = ENV::getConfig("API_SERVER_URL") + "api/Expert/systemUpdateOrderStatus";
            string total_params = "[{\"order_id\":\""+order_id+"\",\"order_ticket\":\""+(string)order_ticket+"\",\"status\":\""+status+"\"}]";
            string res = API::callAPIWithResponse(url,total_params);
            CJAVal json;
            json.Deserialize(res);
            
            if(json["status"]["code"] == 200){
               // Nothing To Do //
               printf("systemUpdateOrderStatus: " + json["status"]["description"].ToStr());
            }else{
               printf("systemUpdateOrderStatus: " + json["status"]["description"].ToStr());
            }
         }
         
         static void updateSymbolData(string& forex_pair[]){
            string symbol = "";
            string total_params = "";
            double price_ask = 0;
            double price_bid = 0;
            double swap_long = 0;
            double swap_short = 0;
            double spread = 0;
            double today_adr,adr_1,adr_5,adr_10,adr_20 = 0;
            bool trade_allowed = false;
            double digits = 0;
            datetime server_time;
            string server_name = "";
            string value = "";
    
            for(int i=0;i<ArraySize(forex_pair);i++){
               symbol = forex_pair[i];
               price_bid = MarketInfo(symbol,MODE_BID);
               price_ask = MarketInfo(symbol,MODE_ASK);
               swap_long = MarketInfo(symbol,MODE_SWAPLONG);
               swap_short = MarketInfo(symbol,MODE_SWAPSHORT);
               spread = MarketInfo(symbol,MODE_SPREAD);
               today_adr = (iHigh(symbol,PERIOD_D1,0)-iLow(symbol,PERIOD_D1,0))*MathPow(10,MarketInfo(symbol,MODE_DIGITS));
               adr_1 = ADR::calculateADR(symbol,1);
               adr_5 = ADR::calculateADR(symbol,5);
               adr_10 = ADR::calculateADR(symbol,10);
               adr_20 = ADR::calculateADR(symbol,20);
               trade_allowed = MarketInfo(symbol, MODE_TRADEALLOWED);
               digits = MarketInfo(symbol,MODE_DIGITS);
               server_name = AccountServer();
               server_time = TimeCurrent();
                 
               value = Symbol::buildValue(price_bid,price_ask,swap_long,swap_short,spread
                  ,today_adr,adr_1,adr_5,adr_10,adr_20,trade_allowed,digits,server_name,server_time);
               total_params = API::appendParamsSymbol(total_params, symbol, value);
            }
            API::systemUpsertSymbolDataList("["+total_params+"]");
            //printf("updateSymbolData: success.");
         }
         
         static void updateActiveOrderData(){
            string total_params = "";
            string order_value = "";
            string params = "";
            if(OrdersTotal() > 0){
               for(int order_pos = 0; order_pos < OrdersTotal(); order_pos++){
                  if(!OrderSelect(order_pos,SELECT_BY_POS,MODE_TRADES)){continue;}      
                  order_value = "{"+Formatter::fJSON("open_time",(string)OrderOpenTime())
                     +","+Formatter::fJSON("type",(string)OrderType())
                     +","+Formatter::fJSON("lot",(string)OrderLots())
                     +","+Formatter::fJSON("tp",(string)OrderTakeProfit())
                     +","+Formatter::fJSON("sl",(string)OrderStopLoss())
                     +","+Formatter::fJSON("symbol",(string)OrderSymbol())
                     +","+Formatter::fJSON("swap",(string)OrderSwap())
                     +","+Formatter::fJSON("profit",(string)OrderProfit())
                     +","+Formatter::fJSON("open_price",(string)OrderOpenPrice())
                     +","+Formatter::fJSON("current_price",(string)MarketInfo(OrderSymbol(),MODE_BID))
                     +","+Formatter::fJSON("comment",(string)OrderComment())
                     +"}";
                     
                  params = "{"+Formatter::fJSON("ticket",(string)OrderTicket())
                     +","+Formatter::fJSONObj("value",order_value)
                     +"}";
                     
                  if(total_params!=""){
                     total_params = total_params + "," + params;
                  }else{
                     total_params = params;
                  }
               }
               API::sendDataToAPI("api/Expert/systemInsertActiveOrderList",total_params);
            }
         }
         
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
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = ADX::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
        
                  // Update Stochastic // 
                  indicator_name = "STOCHASTIC";
                  indicator_settings_json = "[{\"k_period\":\"5\",\"d_period\":\"3\",\"slowing\":\"3\",\"price_field\":\"LOW_HIGH\",\"method\":\"MODE_SMA\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = Stochastic::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  
                  // Update CCI
                  indicator_name = "CCI";
                  indicator_settings_json = "[{\"period\":\"14\",\"apply_to\":\"PRICE_CLOSE\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = CCI::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  
                  // Update RSI
                  indicator_name = "RSI";
                  indicator_settings_json = "[{\"period\":\"14\",\"apply_to\":\"PRICE_CLOSE\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = RSI::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  // Update Moving Average 
                  // [1/5] EMA5 PRICE_WEIGHTED
                  indicator_name = "MA";
                  indicator_settings_json = "[{\"period\":\"5\",\"apply_to\":\"PRICE_WEIGHTED\",\"method\":\"MODE_EMA\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = MA::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  // [2/5] EMA21 PRICE_WEIGHTED
                  indicator_name = "MA";
                  indicator_settings_json = "[{\"period\":\"21\",\"apply_to\":\"PRICE_WEIGHTED\",\"method\":\"MODE_EMA\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = MA::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  // [3/5] SMA50 PRICE_CLOSE
                  indicator_name = "MA";
                  indicator_settings_json = "[{\"period\":\"50\",\"apply_to\":\"PRICE_CLOSE\",\"method\":\"MODE_SMA\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = MA::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  // [4/5] SMA100 PRICE_CLOSE
                  indicator_name = "MA";
                  indicator_settings_json = "[{\"period\":\"100\",\"apply_to\":\"PRICE_CLOSE\",\"method\":\"MODE_SMA\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = MA::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                  
                  // [5/5] SMA200 PRICE_CLOSE
                  indicator_name = "MA";
                  indicator_settings_json = "[{\"period\":\"200\",\"apply_to\":\"PRICE_CLOSE\",\"method\":\"MODE_SMA\"}]";
                  indicator_settings = Indicator::buildJSONSettings(indicator_name, indicator_settings_json);
                  value = MA::buildValue(symbol,timeframe_int,indicator_settings_json);
                  total_params = API::appendParams(total_params, symbol, timeframe, indicator_name, indicator_settings, value);
                      
                  //API::systemUpsertIndicatorData(symbol,timeframe,indicator_name,indicator_settings,value); // single insert (deprecated cuz too slow.)
                  
               }
            }
            API::systemUpsertIndicatorDataList("["+total_params+"]");
            //printf("updateIndicatorData: success.");
         }
};
 