//+------------------------------------------------------------------+
//|                                                old_ma_system.mq4 |
//|                                   Copyright 2020, laserdesign.io |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

input int MA1 = 5;
input int MA2 = 8;
input int MA3 = 21;
input double lot = 1;


int i;


int OnInit()
  {
   Comment("old_ma_system.mq4 Initialized");
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   
  }

void OnTick()
  {
   int Magic = 4589;
   double ma1 = iMA(Symbol(),PERIOD_CURRENT,MA1,0,MODE_EMA,PRICE_CLOSE,1);
   double ma2 = iMA(Symbol(),PERIOD_CURRENT,MA2,0,MODE_EMA,PRICE_CLOSE,1);
   double ma3 = iMA(Symbol(),PERIOD_CURRENT,MA3,0,MODE_EMA,PRICE_CLOSE,1);
   double price_time0 = iClose(Symbol(),5,0);
   double price_time1 = iClose(Symbol(),5,1);
   double price_time2 = iClose(Symbol(),5,2);
   double price_time3 = iClose(Symbol(),5,3);
   long vol1 = iVolume(Symbol(),5,1);
   long vol2 = iVolume(Symbol(),5,2);
   long vol3 = iVolume(Symbol(),5,3);
   long vol_short1 = iVolume(Symbol(),1,1);
   long vol_short2 = iVolume(Symbol(),1,2);
   long vol_short3 = iVolume(Symbol(),1,3);
   double long_pos, short_pos, long_close, short_close;
  
     {
      if((price_time1>price_time2) && (vol1>vol2) && (vol2>vol3) && (vol_short1 > vol_short2) && (ma1>ma2) && (OrdersTotal()<1))
         
           {
            long_pos = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,Magic,0,clrNONE);
               if(OrderSelect(Magic,SELECT_BY_POS) == false) 
                 {
                  Alert(GetLastError());
                 }
           } 
      if((price_time1<price_time2) && (vol1>vol2) && (vol2>vol3) && (vol_short1 > vol_short2) && (ma1<ma2) && (OrdersTotal()<1))
           {
            short_pos = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,Magic,0,clrNONE);
               if(OrderSelect(Magic,SELECT_BY_POS) == false)
                 {
                  Alert(GetLastError());
                 }
           }  
      for(i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY && (ma1<ma2))
               {
                  long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1)
                     Alert("Trade Executed");
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_SELL && (ma1>ma2))
               {
                  short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(short_close>-1)
                    
                     Alert("Trade Executed");
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
              
           }
        }
     } 
  
//+------------------------------------------------------------------+
