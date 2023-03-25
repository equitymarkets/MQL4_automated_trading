//+------------------------------------------------------------------+
//|                                                    legacy_wi.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int MA_fast = 13;
input int MA_mid = 21;
input int MA_slow = 34;
input int time_1 = 60;
input double lots = .1;

double pips;

bool CheckOpenOrders(){ 
        
        for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
                OrderSelect( i, SELECT_BY_POS, MODE_TRADES ); 
                if (OrderSymbol() == Symbol()) return(true); 
        } 
        
        return(false); 
  }
   
void NormalizeTicks()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick; 
  } 
  
bool Legacy() 
  {
   if(iTime(Symbol(),0,0)-iTime(Symbol(),0,1) > 25200)
     {
      return(false);
     }
   return(true);
  }

bool Paper()
  {
   if(((iClose(Symbol(),time_1,1)) > (iClose(Symbol(),time_1,2))) && (iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,1) >= iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,2)) 
   && ((iClose(Symbol(),time_1,1)) >= iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,1)))
     {
      return(true);
     }
   return(false);
  }
   
void OnTick()
  {
   double ima1 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,1);
   double ima2 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,2);
   double close_price1 = (iClose(Symbol(),time_1,1));
   double close_price2 = (iClose(Symbol(),time_1,2));
  
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double actual_buy_open, actual_sell_open;
   
   
   
   if(iTime(Symbol(),time_1,0) - iTime(Symbol(),time_1,1) > 25200) 
     {
      trade_allowed = false;
     }
   
   if(trade_allowed == false && paper_buy == false) 
     {
      if((close_price1 > close_price2) && (ima1 >= ima2) && (close_price1 >= ima1))
        {
         paper_buy = true;
        
         if(paper_buy == true) 
           {
            paper_buy_price = close_price1;
           }
        }
     }
     
   if(paper_buy == true) 
     {
      if(close_price1 <= ima1)
        {
         paper_buy = false;
           {
            if(paper_buy == false) 
              {
               if(close_price1 > paper_buy_price)
                 {
                  trade_allowed = true;
                 }
              }
           }
        }
     }
   
   if(trade_allowed == false && paper_sell == false) 
     {
      if((close_price1 < close_price2) && (ima1 <= ima2) && (close_price1 <= ima1))
        {
         paper_sell = true;
        
         if(paper_sell == true) 
           {
            paper_sell_price = close_price1;
           }
        }
     }
     
   if(paper_sell == true) 
     {
      if(close_price1 >= ima1)
        {
         paper_sell = false;
           {
            if(paper_sell == false) 
              {
               if(close_price1 < paper_sell_price)
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
      if(trade_allowed == true)
        {
         if((close_price1 > close_price2) && (ima1 >= ima2) && (close_price1 >= ima1))
           {
            actual_buy_open = OrderSend(Symbol(),OP_BUY,lots,Ask,0,0,0,NULL,0,0,clrNONE);
            
           }
        }
     }
     
//SELL
   if(OrdersTotal()<1)
     {
      if(trade_allowed == true)
        {
         if((close_price1 < close_price2) && (ima1 <= ima2) && (close_price1 <= ima1))
           {
            actual_sell_open = OrderSend(Symbol(),OP_SELL,lots,Bid,0,0,0,NULL,0,0,clrNONE);
           }
        }
     }
     
//CLOSE TRADE
     for(int i=0; i<OrdersTotal(); i++) 
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) 
              {
               if(OrderType()==OP_BUY && (close_price1 <= ima1))
               {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(long_close>-1) 
                    {
                     Alert("Trade Executed");
                     if(long_close>-1) 
                       {
                        double actual_buy_close = close_price1;
                        if(OrderProfit() > 0) 
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
               if(OrderType()==OP_SELL && (close_price1 >= ima1))
               {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(short_close>-1)
                    {
                     Alert("Trade Executed");
                     if(short_close>-1)
                       {
                        double actual_sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                        if(OrderProfit() > 0) 
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
  

   
//------------------------------------------------------------------------------+
