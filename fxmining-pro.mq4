//+------------------------------------------------------------------+
//|                                                 fxmining-pro.mq4 |
//|                            Copyright 2021, PKONEZ Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PKONEZ Software Corp."
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include "main.mqh"
#include "env.mqh"

int OnInit(){
   // Initialize Variable & Timeframe //
   string major_pair[] = {"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
   string forex_pair[29];
   int counter = 0;
   for(int i=0;i<ArraySize(major_pair);i++){
      for(int j=i+1;j<ArraySize(major_pair);j++){
         forex_pair[counter++] = major_pair[i]+major_pair[j];
      }
   } 
   forex_pair[counter] = "GOLD"; 
   //string tf_list[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
   string tf_list[] = {"M30","H1","H4","D1"};
   // End Initialize Variable & Timeframe //  
      
   while (!IsStopped()) {
      // Call Main Function Loop //
      Main::updateSymbolData(forex_pair);
      Main::updateIndicatorData(forex_pair, tf_list);
      Main::updateActiveOrderData();
      Main::checkRequestOrder();
      Sleep(5000);
   }   
   
   return(INIT_SUCCEEDED);
}