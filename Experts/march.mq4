/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//confidence gate style ... confH4- widening ATR , gateH1 - OBV , MA cross
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define march 032320

extern double lot = .5;
extern short hour_begin = 10, hour_end = 15, ATR_period = 21, confidence_timeframe = 240, timeframe = 240, gate_timeframe = 60, stop_loss = 30, limit_entry = 30;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false;
extern short what_minute = 0;
extern short fast_MA = 21, slow_MA = 55;
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
   Comment("march.ex4");
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("march.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   //confidence variables
   double ATR_0 = iATR(Symbol(),confidence_timeframe,ATR_period,0);
   double ATR_1 = iATR(Symbol(),confidence_timeframe,ATR_period,1);
   double ATR_2 = iATR(Symbol(),confidence_timeframe,ATR_period,2);
   double ATR_3 = iATR(Symbol(),confidence_timeframe,ATR_period,3);
   //gate variables
   double fast_MA_1 = iMA(Symbol(),gate_timeframe,fast_MA,0,MODE_SMA,PRICE_CLOSE,1);
   double slow_MA_1 = iMA(Symbol(),gate_timeframe,slow_MA,0,MODE_SMA,PRICE_CLOSE,1);
   //double IMA_0 = iMA(Symbol(),timeframe
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   //confidence
   if(ATR_1 > ATR_2) bool confidence = true;
   
   //gate  
   if(fast_MA_1 > slow_MA_1 && Minute() >= what_minute) bool buyer = true;
   if(fast_MA_1 < slow_MA_1&& Minute() >= what_minute) bool seller = true;
   if(fast_MA_1 < slow_MA_1 && Minute() >= what_minute) bool buy_closer = true;
   if(fast_MA_1 > slow_MA_1 && Minute() >= what_minute)bool sell_closer = true;
   
   if(confidence)
     { 
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,march,0,clrNONE);
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
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,march,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == march)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  if(OrderProfit() > 0) 
                    {
                     trade_allowed = true;
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
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
