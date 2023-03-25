/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict
#property description "AMBV"

extern double lot = 1;
extern int timeframe = 0;
//ADX
extern int adx_break = 25;
extern int adx_period = 14;
//MA
extern int imaFast_period = 13;
extern int imaSlow_period = 34;
//Bollinger
extern int bollinger_ima = 21;
//Volume
extern int vol_lo = 1;
extern int vol_mid = 5;
extern int vol_high = 60;

extern int bar = 1;
extern bool legacy = false; 
extern bool entropy = false;

double pips;


//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
int OnInit()                                                                                     //0
  {                                                                                              //0
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
   
   return(INIT_SUCCEEDED);
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
void OnDeinit(const int reason)                                                                  //0
  {                                                                                              //0
   
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
void OnTick()                                                                                    //0
  {                                                                                              //0
   //ADX                                                                                             
   double adx = iADX(Symbol(),timeframe,adx_period,PRICE_CLOSE,MODE_MAIN,1);
   //IMA
   double imaFast = iMA(Symbol(),timeframe,imaFast_period,0,MODE_SMA,PRICE_CLOSE,1);
   double imaSlow = iMA(Symbol(),timeframe,imaSlow_period,0,MODE_SMA,PRICE_CLOSE,1);
   //Bollinger
   double bollinger = iBands(Symbol(),timeframe,bollinger_ima,2,0,PRICE_CLOSE,0,1);
   double bollinger_lo = iBands(Symbol(),timeframe,bollinger_ima,2,0,PRICE_CLOSE,2,1);
   double bollinger_hi = iBands(Symbol(),timeframe,bollinger_ima,2,0,PRICE_CLOSE,1,1);
   //Volume
   long vol_lobar = iVolume(Symbol(),vol_lo,0);
   long vol_midbar = iVolume(Symbol(),vol_mid,0);
   long vol_hibar = iVolume(Symbol(),vol_high,0);
   //Price
   double price_close = iClose(Symbol(),timeframe,bar);
   
   static bool trade_allowed = true;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;

   if(legacy)
      if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
        {
         trade_allowed = false;
        }

     
   if(!trade_allowed && (!paper_buy || !paper_sell))
     {
      if(adx > adx_break)
        {
         if(imaFast > imaSlow)
           {
            if(price_close > bollinger_hi)
               if(bar == 1)
                    {
                     if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                       {
                        paper_buy = true;
                        if(paper_buy == true)
                          {
                           paper_buy_price = iClose(Symbol(),0,1);
                          }
                       }
                    }
                  else
                     if(Minute() == 55)
                       {
                        if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                          {
                           paper_buy = true;
                           if(paper_buy == true)
                             {
                              paper_buy_price = iClose(Symbol(),0,1);
                             }
                          }
                       }
           }
         if(imaFast < imaSlow)
           {
            if(price_close < bollinger_lo)
               if(bar == 1)
                 {
                  if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                    {
                     paper_sell = true;
                     if(paper_sell == true)
                       {
                        paper_sell_price = iClose(Symbol(),0,1);
                       }
                    }
                 }
               else
                  if(Minute() == 55)
                    {
                        if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                          {
                           paper_sell = true;
                           if(paper_sell)
                             {
                              paper_sell_price = iClose(Symbol(),0,1);
                             }
                          }
                    }
           }
        }
     }
   if(paper_buy) 
     {
      if(price_close < bollinger)
        {
         paper_buy = false;
           {
            if(!paper_buy) 
              {
               if(price_close > paper_buy_price)
                 {
                  trade_allowed = true;
                 }
              }
           }
        }
     }
   if(paper_sell) 
     {
      if(price_close > bollinger)
        {
         paper_sell = false;
           {
            if(!paper_sell) 
              {
               if(price_close < paper_sell_price)
                 {
                  trade_allowed = true;
                 }
              }
           }
        }
     }
   
   if(trade_allowed && OrdersTotal() < 1)
     {
      if(adx > adx_break)
        {
         if(imaFast > imaSlow)
           {
            if(price_close > bollinger_hi)
               if(bar == 1)
                    {
                     if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                       {
                        buy= OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0100,0,clrNONE);
                       }
                    }
                  else
                     if(Minute() == 55)
                       {
                           if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                             {
                              buy= OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0100,0,clrNONE);
                             }
                       }
           }
         if(imaFast < imaSlow)
           {
            if(price_close < bollinger_lo)
               if(bar == 1)
                 {
                  if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                    {
                     sell= OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0100,0,clrNONE);
                    }
                 }
               else
                  if(Minute() == 55)
                    {
                        if(vol_lobar/vol_lo > vol_midbar/vol_mid)
                          {
                           sell= OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0100,0,clrNONE);
                          }
                    }
           }
        }
     }
   for(int i=0; i < OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) 
        {
         if(OrderMagicNumber() == 0100)
           {
            if(OrderType() == OP_BUY && price_close < bollinger)
                 {
                  double close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0)
                     trade_allowed = true;
                 }
              
           
         
            if(OrderType() == OP_SELL && price_close > bollinger)
              
                 {
                  double close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(OrderProfit() > 0)
                     trade_allowed = true;
                 }
              
           }
        }
     } 
  }
//+------------------------------------------------------------------+
