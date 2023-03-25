/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define layers 110120

input double lot = .1;

input int long_chart = 1440;
input int mid_chart = 240;
input int short_chart = 60;
input int MA_fast = 34;
input int MA_slow = 70;



double pips;

bool CheckOpenOrders()
  { 
   for( int i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == layers) return(true); 
     } 
      return(false); 
  }

int OnInit()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
   
   Comment("Layers EA initialized, tick normalized.");
   
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {

   
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double double_lot = lot * 2;
   
   double close_price_long = iClose(Symbol(),long_chart,1);
   double close_price_mid1 = iClose(Symbol(),mid_chart,1);
   double close_price_mid2 = iClose(Symbol(),mid_chart,2);
   
   double close_price_short0 = iClose(Symbol(),short_chart,0);
   double close_price_short1 = iClose(Symbol(),short_chart,1);
   double close_price_short2 = iClose(Symbol(),short_chart,2);
   
   double ima_slow0 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,0);
   double ima_slow1 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_slow2 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,2);
   double ima_fast0 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,0);
   double ima_fast1 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_fast2 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,2);
  
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid = iVolume(Symbol(),mid_chart,1);
   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
//Opening Orders    
   if(CheckOpenOrders() == false)
     {
      if(close_price_mid1 > close_price_mid2)
        {
         if((close_price_mid1 > close_price_long) && (ima_fast1 > ima_slow1) && (ima_slow1 > ima_slow2) && (vol_short/short_chart > vol_mid/mid_chart) && (vol_mid/mid_chart > vol_long/long_chart))
           {
            if(close_price_short0 > close_price_short1)
              {
               double buy_order = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,layers,0,clrNONE);
              }
           }
        } 
      if(close_price_mid1 < close_price_mid2)
        {
         if((close_price_mid1 < close_price_long) && (ima_fast1 < ima_slow1) && (ima_slow1 < ima_slow2) && (vol_short/short_chart > vol_mid/mid_chart) && (vol_mid/mid_chart > vol_long/long_chart))
           {
            if(close_price_short0 < close_price_short1)
              {
               double sell_order = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,layers,0,clrNONE);
             
              }
           } 
        }
     }   
      
//Closing Orders
   if(CheckOpenOrders() == true)
     {
      for(int i = 0; i < OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == layers)
              {
               if((OrderType() == OP_BUY) && ((close_price_mid1 < close_price_long) && (ima_fast1 < ima_slow1) && (ima_slow1 < ima_slow2)))
                 {
                  double long_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if((OrderType() == OP_SELL) && ((close_price_mid1 > close_price_long) && (ima_fast1 > ima_slow1) && (ima_slow1 > ima_slow2)))
                 {
                  double short_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
           }
        }
      
     }
  }
//+------------------------------------------------------------------+
