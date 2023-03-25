/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define eleven 012622


input double lot = .1;
input short short_period = 3, timeframe = 240, period = 3, bands_shift = 0, minDelay = 60;
input bool time_randomizer = false, stops = false;
input int stop_loss = 30;

double pips;

bool CheckOpenOrders()
  { 
   for( int i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol()) return(true); 
     } 
      return(false); 
  }
  
bool OrderDelay()
  {
   int duration = 60 * minDelay;
   for(int i = (OrdersHistoryTotal()-1); i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         datetime close = OrderCloseTime();
         int open = close + duration;
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == eleven)
           {
            if(TimeCurrent() < open && OrderProfit() < 0)
              {
               return(false);
              }
           }
        }
     }
   return(true);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

int OnInit()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
   
   
   return(INIT_SUCCEEDED);
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("EA eleven.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double quad_lot = lot * 4;
   
   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
   
   double Bollinger_SD1_Upper = iBands(Symbol(),timeframe,period,1,bands_shift,PRICE_CLOSE,1,1);
   double Bollinger_SD1_Lower = iBands(Symbol(),timeframe,period,1,bands_shift,PRICE_CLOSE,2,1);
   double Bollinger_SD2_Upper = iBands(Symbol(),timeframe,period,2,bands_shift,PRICE_CLOSE,1,1);
   double Bollinger_SD2_Lower = iBands(Symbol(),timeframe,period,2,bands_shift,PRICE_CLOSE,2,1);
   double Bollinger_SD3_Upper = iBands(Symbol(),timeframe,period,3,bands_shift,PRICE_CLOSE,1,1);
   double Bollinger_SD3_Lower = iBands(Symbol(),timeframe,period,3,bands_shift,PRICE_CLOSE,2,1);
   
   double Vol_5min_0 = iVolume(Symbol(),5,0);
   double Vol_timeframe_1 = iVolume(Symbol(),timeframe,1);
   double Vol_timeframe_2 = iVolume(Symbol(),timeframe,2);
   
   double MA_standard = iMA(Symbol(),timeframe,period,bands_shift,MODE_SMA,PRICE_CLOSE,1);
   double MA_low = iMA(Symbol(),timeframe,short_period,bands_shift,MODE_SMA,PRICE_CLOSE,1);
   double buy, sell;
   int i;
   static double random_long = MathRand()/2.8, random_short = MathRand()/2.8;
   
   if(!CheckOpenOrders())
     {
      if(!stops)
        {
         if(!time_randomizer)
           {
            if((price_1 > Bollinger_SD1_Upper && price_1 < Bollinger_SD3_Upper) || (price_1 < Bollinger_SD3_Lower))
              {
               buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",eleven,0,clrNONE);
              }
            if((price_1 < Bollinger_SD1_Lower && price_1 > Bollinger_SD3_Lower) || (price_1 > Bollinger_SD3_Upper))
              {
               sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",eleven,0,clrNONE);
              }       
           }
         else 
           {
            if((price_1 > Bollinger_SD1_Upper && price_1 < Bollinger_SD3_Upper) || (price_1 < Bollinger_SD3_Lower))
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",eleven,0,clrNONE);
                    {
                     if(buy > -1)
                       {
                        random_long = MathRand()/2.8;
                       }
                    }
                 }
              }
            if((price_1 < Bollinger_SD1_Lower && price_1 > Bollinger_SD3_Lower) || (price_1 > Bollinger_SD3_Upper))
              {
               if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",eleven,0,clrNONE);
                    {
                     if(sell > -1)
                       {
                        random_short = MathRand()/2.8;
                       }
                    }
                 }
              }
           }
        }
      else
        {
         if(OrderDelay())
           {
            if(!time_randomizer)
              {
               if((price_1 > Bollinger_SD1_Upper && price_1 < Bollinger_SD3_Upper) || (price_1 < Bollinger_SD3_Lower))
                 {
                  buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",eleven,0,clrNONE);
                 }
               if((price_1 < Bollinger_SD1_Lower && price_1 > Bollinger_SD3_Lower) || (price_1 > Bollinger_SD3_Upper))
                 {
                  sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",eleven,0,clrNONE);
                 }       
              }
            else 
              {
               if((price_1 > Bollinger_SD1_Upper && price_1 < Bollinger_SD3_Upper) || (price_1 < Bollinger_SD3_Lower))
                 {
                  if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_long))
                    {
                     buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,Ask - (stop_loss * pips),0," ",eleven,0,clrNONE);
                       {
                        if(buy > -1)
                          {
                           random_long = MathRand()/2.8;
                          }
                       }
                    }
                 }
               if((price_1 < Bollinger_SD1_Lower && price_1 > Bollinger_SD3_Lower) || (price_1 > Bollinger_SD3_Upper))
                 {
                  if(MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_short))
                    {
                     sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,Bid + (stop_loss * pips),0," ",eleven,0,clrNONE);
                       {
                        if(sell > -1)
                          {
                           random_short = MathRand()/2.8;
                          }
                       }
                    }
                 }
              }
           }
        }
     }
     
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == true)
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == eleven)
              {
               if(OrderType() == OP_BUY)
                  if((price_1 > Bollinger_SD3_Upper) || (price_1 > Bollinger_SD1_Lower && price_1 < Bollinger_SD1_Upper)) 
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if(OrderType() == OP_SELL)
                 if((price_1 < Bollinger_SD3_Lower) || (price_1 < Bollinger_SD1_Upper && price_1 > Bollinger_SD1_Lower)) 
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }      
           }
        }
     }
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
