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

#define oppo 043021


double pips;
 
 
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

int OnInit()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
      pips = tick * 10;
   else pips = tick;
   Comment("oppo_EA.ex4 initialized!");
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("oppo_EA.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);

   double MACD_1 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,1);
   double MACD_2 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,2);
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
     
   if(price_1 > price_2 && (MACD_1 > MACD_2) && Minute() >= what_minute) bool buyer = true;
   if(price_1 < price_2 && (MACD_1 < MACD_2) && Minute() >= what_minute) bool seller = true;
   if(price_1 < price_2 && (MACD_1 < MACD_2) && Minute() >= what_minute && ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < ATV_break) bool buy_closer = true;
   if(price_1 > price_2 && (MACD_1 > MACD_2) && Minute() >= what_minute && ATV_0(ATR_timeframe,OBV_timeframe,ATR_period) > -ATV_break) bool sell_closer = true;
    
   if(weekend_breaker)        //breaker is for testing only
     {
      if(!trade_allowed && !paper_buy) 
        {
         if(buyer)   //paper buy
           {
            paper_buy = true;
            paper_buy_price = price_1;
           }
        }
      if(paper_buy) 
        {
         if(buy_closer)                        //paper close
           {
            paper_buy = false;
            if(price_1 > paper_buy_price)             //profit?
              {
               trade_allowed = true;
              }
           }
        }
      if(seller) 
        {
         if(price_0 < price_1 && price_1 < price_2)   //paper sell
           {
            paper_sell = true;
            paper_sell_price = price_1;
           }
        }
      if(paper_sell) 
        {
         if(sell_closer)                        //paper close
           {
            paper_sell = false;
            if(price_1 < paper_sell_price)            //profit?
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
         if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
           {
            if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
              {
               if(buyer)
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
                  buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,oppo,0,clrNONE);
                 }
               if(seller)
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
                  sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,oppo,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == oppo)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  //if(ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < ATV_break)
                    {
                     buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     if(OrderProfit() > 0) 
                       {
                        trade_allowed = true;
                       }
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
                 {
                  //if(ATV_0(ATR_timeframe,OBV_timeframe,ATR_period) > -ATV_break) 
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
  }
extern double lot = .5, MACD_change = .005;
extern short hour_begin = 0, hour_end = 11, timeframe = 240, stop_loss = 100, limit_entry = 30;
extern bool time = true, random = false, stops = true, limits = false, weekend_breaker = false;
extern short fast_period = 8, slow_period = 10, signal_period = 3;
input short what_minute = 4;
input short ATR_timeframe = 5, OBV_timeframe = 60, ATR_period = 13, ATV_break = 600;
int i; 

bool CheckOpenOrders()
  { 
   for(i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol()) return(true); 
     } 
   return(false); 
  }

double ATV_0(short atr_timeframe, short obv_timeframe, short atr_period)
  {
   double ATR_0 = iATR(Symbol(),atr_timeframe,atr_period,0);
   double OBV_0 = iOBV(Symbol(),obv_timeframe,PRICE_CLOSE,0); 
   return(ATR_0 * OBV_0);
  }  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891