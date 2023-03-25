//+------------------------------------------------------------------+
//|                                                       Legacy.mq4 |
//|                                  Copyright 2020, laserdesign.io. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020 laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "10.00"
#property strict

extern int hour_init = 11;

void OnTick()
  {
   static bool trade_allowed;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double actual_buy_open, actual_sell_open;
   
   if(iTime(Symbol(),60,0) - iTime(Symbol(),60,1) > 25200) 
     {
      trade_allowed = false;
     }
   
   if(trade_allowed == false && paper_buy == false) 
     {
      if((iClose(Symbol(),60,1) > iClose(Symbol(),60,2)) && (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)) >= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,2)) && (iClose(Symbol(),60,1)) >= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
        {
         paper_buy = true;
        
         if(paper_buy == true) 
           {
            paper_buy_price = iClose(Symbol(),60,1);
           }
        }
     }
     
   if(paper_buy == true) 
     {
      if(iClose(Symbol(),60,1) <= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
        {
         paper_buy = false;
           {
            if(paper_buy == false) 
              {
               if((iClose(Symbol(),60,1)) > paper_buy_price)
                 {
                  trade_allowed = true;
                 }
              }
           }
        }
     }
   
   if(trade_allowed == false && paper_sell == false) 
     {
      if((iClose(Symbol(),60,1) < iClose(Symbol(),60,2)) && (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)) <= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,2)) && (iClose(Symbol(),60,1)) <= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
        {
         paper_sell = true;
        
         if(paper_sell == true) 
           {
            paper_sell_price = iClose(Symbol(),60,1);
           }
        }
     }
     
   if(paper_sell == true) 
     {
      if(iClose(Symbol(),60,1) >= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
        {
         paper_sell = false;
           {
            if(paper_sell == false) 
              {
               if((iClose(Symbol(),60,1)) < paper_sell_price)
                 {
                  trade_allowed = true;
                 }
              }
           }
        }
     }
      
   
//------------------------------------------------------------------------------+
//BUY
   if(OrdersTotal()<1)
     {
      if((hour_init-1 == Hour() || hour_init == Hour()) && trade_allowed == true)
        {
         if((iClose(Symbol(),60,1) > iClose(Symbol(),60,2)) && (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)) >= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,2)) && (iClose(Symbol(),60,1)) >= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
           {
            actual_buy_open = OrderSend(Symbol(),OP_BUY,.1,Ask,0,0,0,NULL,0,0,clrNONE);
            
           }
        }
     }
//SELL
   if(OrdersTotal()<1)
     {
      if((hour_init-1 == Hour() || hour_init == Hour()) && trade_allowed == true)
        {
         if((iClose(Symbol(),60,1) < iClose(Symbol(),60,2)) && (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)) <= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,2)) && (iClose(Symbol(),60,1)) <= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
           {
            actual_sell_open = OrderSend(Symbol(),OP_SELL,.1,Bid,0,0,0,NULL,0,0,clrNONE);
           }
        }
     }
     for(int i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY && (iClose(Symbol(),60,1)) <= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
               {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1) 
                    {
                     Alert("Trade Executed");
                     if(long_close>-1) 
                       {
                        double actual_buy_close = iClose(Symbol(),0,1);
                        if((long_close>-1) && (actual_buy_close - actual_buy_open) >= 0) 
                          {
                           trade_allowed = true;
                          }
                       }
                    }
                  else 
                     Alert("Order not executed: ", GetLastError());
                }
              
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_SELL && (iClose(Symbol(),60,1)) >= (iMA(Symbol(),60,21,0,MODE_SMA,PRICE_CLOSE,1)))
               {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(short_close>-1)
                    {
                     Alert("Trade Executed");
                     if(short_close>-1)
                       {
                        double actual_sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                        if((short_close>-1) && (actual_sell_close - actual_sell_open) >= 0) 
                          {
                           trade_allowed = true;
                          }
                       }
                    }
                   
                        
                 }
                 else 
                     Alert("Order not executed: ", GetLastError());
                }
              }
              
           }
   }
  
//CLOSE TRADE
   
//------------------------------------------------------------------------------+
