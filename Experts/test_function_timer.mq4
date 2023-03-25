//+------------------------------------------------------------------+
//|                                     legacy_with_legacy_flag.mql4 |
//|                                   Copyright 2020, laserdesign.io |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

extern int moving_average_period = 21;
extern double lot = .1;


static bool actual_buy = false; 

static bool actual_sell = false;
static bool weekend_open = false;
static double actual_buy_open, actual_sell_open;
double actual_buy_close, actual_sell_close;
int i;
int OnInit()
  {
   int x = 4;
   if(x == 5)
     {
      Alert("INIT_FAILED, reason: " + "x = " + x);
      return(INIT_FAILED);
     }
   
   Alert("INIT_SUCCEEDED, reason: " + "x = " + x);
   return(INIT_SUCCEEDED);
  }
void OnTick()
  {
   Comment("INIT succeeded");
//---
   /*double price_time_0 = iClose(Symbol(),PERIOD_CURRENT,0); 
   double price_time_1 = iClose(Symbol(),PERIOD_CURRENT,1);
   double price_time_2 = iClose(Symbol(),PERIOD_CURRENT,2);
   double ma1 = iMA(Symbol(),PERIOD_CURRENT,moving_average_period,0,MODE_SMA,PRICE_CLOSE,1);
   double ma2 = iMA(Symbol(),PERIOD_CURRENT,moving_average_period,0,MODE_SMA,PRICE_CLOSE,2);
   int magic = 4321;
   
   static bool trade_allowed = true;

     

   
   
   if((price_time_1 > ma1) && (price_time_1 > price_time_2) && (ma1 > ma2) && (OrdersTotal()<1))
      
        {
         double long_pos = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,magic,0,clrNONE);
            if(OrderSelect(magic,SELECT_BY_POS) == false) 
              {
               Alert(GetLastError());
              }
             else actual_buy_open = iOpen(Symbol(),0,0);
             
           }
   
   if((price_time_1 < ma1) && (price_time_1 < price_time_2) && (ma1 < ma2) && (OrdersTotal()<1))
      
        {
         double short_pos = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,magic,0,clrNONE);
            if(OrderSelect(magic,SELECT_BY_POS) == false) 
              {
               Alert(GetLastError());
              }
            else actual_sell_open = iOpen(Symbol(),0,0);
        }
   for(i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY && (price_time_1 < ma1))
               {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1) {
                     Alert("Trade Executed");
                     if(long_close>-1) {actual_buy_close = iOpen(Symbol(),0,0);} }
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_SELL && (price_time_1 > ma1))
               {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(short_close>-1) {
                     Alert("Trade Executed");
                     if(short_close>-1) {actual_sell_close = iOpen(Symbol(),0,0);} 
                 
                 if(OrderCloseTime()-OrderOpenTime() < 36000) 
                    {
                     trade_allowed = false;
                    }
                 }
                  
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }*/
              
           }
     void OnDeinit(const int reason)
     {
      Alert("ea deinitialized!");
     } 

  
//+------------------------------------------------------------------+

