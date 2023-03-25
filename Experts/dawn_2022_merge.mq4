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

#define dawn_2022 033122 

extern double lot = .25;
extern short hour_begin = 10, hour_end = 15, stop_loss = 75, limit_entry = 30;
extern bool time = false, random = false, stops = true, limits = false, weekend_breaker = false;


extern int volume_timeframe = 60; 
extern int ATR_timeframe = 240, ATR_fast = 3, ATR_slow = 20;

int i;
double pips;

bool CheckOpenOrders()
  { 
   for(i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol()) return(true); 
     } 
      return(false); 
  }

void OrderHistory()
  {
   for(i = 0; i < OrdersHistoryTotal(); i++)
     {
      bool checker = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        {
           {
            Alert( "Order ", i, " time was ",  OrderCloseTime() - OrderOpenTime());
           }
        }
     }
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
   Comment("EA.ex4");
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("EA.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   
   
   //Price
   double price_0 = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);
      
   //Momentum
   long volume_0 = iVolume(Symbol(),volume_timeframe,0);
   long volume_1 = iVolume(Symbol(),volume_timeframe,1);
   long volume_2 = iVolume(Symbol(),volume_timeframe,2);
   
   //Volume
   double OBV_1 = iOBV(Symbol(),volume_timeframe,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),volume_timeframe,PRICE_CLOSE,2);
   
   //Trend 
   double ATR_fast_calc_1 = iATR(Symbol(),ATR_timeframe,ATR_fast,1);
   double ATR_slow_calc_1 = iATR(Symbol(),ATR_timeframe,ATR_slow,1);
   
   double ATR_fast_calc_2 = iATR(Symbol(),ATR_timeframe,ATR_fast,2);
   double ATR_slow_calc_2 = iATR(Symbol(),ATR_timeframe,ATR_slow,2);
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   if(iTime(Symbol(),ATR_timeframe,0) - iTime(Symbol(),ATR_timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
     
   if(weekend_breaker)        //breaker is for testing only
     {
      if(!trade_allowed && !paper_buy) 
        {
         if(price_0 > price_1 && price_1 > price_2)
           {
            paper_buy = true;
            paper_buy_price = price_1;
           }
        }
      if(paper_buy) 
        {
         if(price_1 < price_2)
           {
            paper_buy = false;
            if(price_1 > paper_buy_price)
              {
               trade_allowed = true;
              }
           }
        }
      if(!trade_allowed && !paper_sell) 
        {
         if(price_0 < price_1 && price_1 < price_2)
           {
            paper_sell = true;
            paper_sell_price = price_1;
           }
        }
      if(paper_sell) 
        {
         if(price_1 > price_2)
           {
            paper_sell = false;
            if(price_1 < paper_sell_price)
              {
               trade_allowed = true;
              }
           }
        }
     }
  
   if(!weekend_breaker || trade_allowed)
     {
      if(!CheckOpenOrders())
        {
         if(ATR_fast_calc_1 > ATR_slow_calc_1 && ATR_fast_calc_1 > ATR_fast_calc_2 && ATR_slow_calc_1 > ATR_slow_calc_2)
           {
            if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),ATR_timeframe,0) + random_trade_time))
              {
               if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
                 {
                  if(price_1 > price_2 && OBV_1 > OBV_2 && OBV_1 > 0)
                    {
                     if(limits) 
                       { 
                        buy_order = OP_BUYLIMIT;
                        buy_limit = Ask - (limit_entry * pips);
                       }
                     if(stops) 
                       {
                        stop_trade = Ask - (stop_loss * pips);
                       }
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,dawn_2022,0,clrNONE);
                    }
                  if(price_1 < price_2 && OBV_1 < OBV_2 && OBV_1 < 0)
                    {
                     if(limits)
                       {
                        sell_order = OP_SELLLIMIT;
                        sell_limit = Bid + (limit_entry * pips);
                       }
                     if(stops)
                       {
                        stop_trade = Bid + (stop_loss * pips);
                       }
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,dawn_2022,0,clrNONE);
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
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == dawn_2022)
              {
               if(OrderType() == OP_BUY && price_1 < price_2 && ATR_fast_calc_1 < ATR_slow_calc_1 && ATR_fast_calc_1 < ATR_fast_calc_2 && ATR_slow_calc_1 < ATR_slow_calc_2)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
               if(OrderType() == OP_SELL && price_1 > price_2 && ATR_fast_calc_1 < ATR_slow_calc_1 && ATR_fast_calc_1 < ATR_fast_calc_2 && ATR_slow_calc_1 < ATR_slow_calc_2)
                 {
                  sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
              }      
           }
        }
     }
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
