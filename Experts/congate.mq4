//work on weekend breaker and nesting under confidence, model from actual trades, then compile
/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//confidence gate method identifies trade favorability (confidence) before considering trade (gate)

#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define congate 052622

extern double lot = .5;
extern short hour_begin = 10, hour_end = 15, confidence_timeframe = 240, gate_timeframe = 15;
extern short ATR_confidence_period = 34;
extern short MACD_slow = 55, MACD_fast = 34, MACD_signal = 5;
extern short MA_fast = 13, MA_slow = 21;
extern short stop_loss = 30, limit_entry = 30;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false;
extern short what_minute = 4;
extern int ATR_lookback_shift = 5;
int i;

double pips;
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
bool CheckOpenOrders()
  { 
   for(i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol()) return(true); 
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
   
   
   static double random_trade_time = MathRand()/2.8;
   static bool trade_allowed = false;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   //confidence
   double ATR_0 = iATR(Symbol(),confidence_timeframe,ATR_confidence_period,0);
   double ATR_1 = iATR(Symbol(),confidence_timeframe,ATR_confidence_period,1);
   double ATR_2 = iATR(Symbol(),confidence_timeframe,ATR_confidence_period,2);
   double ATR_3 = iATR(Symbol(),confidence_timeframe,ATR_confidence_period,3);
   double ATR_4 = iATR(Symbol(),confidence_timeframe,ATR_confidence_period,4);
   //gate
   double price_0 = iClose(Symbol(),gate_timeframe,0);
   double price_1 = iClose(Symbol(),gate_timeframe,1);
   double price_2 = iClose(Symbol(),gate_timeframe,2);
   
   //macd 05262201
   double MACD_1 = iMACD(Symbol(),gate_timeframe,MACD_fast,MACD_slow,MACD_signal,PRICE_CLOSE,MODE_MAIN,1);
   double MACD_2 = iMACD(Symbol(),gate_timeframe,MACD_fast,MACD_slow,MACD_signal,PRICE_CLOSE,MODE_SIGNAL,1);
   
   //ma_cross 05262202
   double MA_fast_1 = iMA(Symbol(),gate_timeframe,MA_fast,0,MODE_SMA,PRICE_CLOSE,1);
   double MA_slow_1 = iMA(Symbol(),gate_timeframe,MA_slow,0,MODE_SMA,PRICE_CLOSE,1);
   
   //obv 05262203
   double OBV_1 = iOBV(Symbol(),gate_timeframe,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),gate_timeframe,PRICE_CLOSE,2);
   double OBV_3 = iOBV(Symbol(),gate_timeframe,PRICE_CLOSE,3);
   
   
   if(iTime(Symbol(),confidence_timeframe,0) - iTime(Symbol(),confidence_timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   
   //confidence - greenlights open but forces close 
   //if((OBV_1 > OBV_2) && Minute() == what_minute) bool confidence = true;
   //gate  
   if((MACD_1 > MACD_2 || MA_fast_1 > MA_slow_1 || (OBV_1 > OBV_2 && OBV_2 > OBV_3)) && price_1 > price_2) bool buyer = true;
   if((MACD_1 < MACD_2 || MA_fast_1 < MA_slow_1 || (OBV_1 < OBV_2 && OBV_2 < OBV_3)) && price_1 < price_2) bool seller = true;
   
   
   if(weekend_breaker)
     {
      if(ATR_1 > ATR_2)
        {
         if(!trade_allowed)
           {
            if(!paper_buy)
              {
               if(buyer)
                 {
                  paper_buy = true;
                  paper_buy_price = price_1;
                 }
              }
            if(!paper_sell)
              {
               if(seller)
                 {
                  paper_sell = true;
                  paper_buy_price = price_1;
                 }
              }
           }
        }
      if(paper_buy || paper_sell)
        {
         if(ATR_1 < ATR_2)
           {
            if(paper_buy)
              {
               paper_buy = false;
               if(price_1 > paper_buy_price)
                 {
                  trade_allowed = true;
                 }
              }
            if(paper_sell)
              {
               paper_sell = false;
               if(price_1 < paper_sell_price)
                 {
                  trade_allowed = true;
                 }
              }
           }
        }
     }
               
                     
   /*if(confidence)
     { 
      if(weekend_breaker)        //breaker is for testing only
        {
         if(!trade_allowed)
           {
            if(!paper_buy) 
              {
               if(buyer)   //paper buy
                 {
                  paper_buy = true;
                  paper_buy_price = price_1;
                 }
              }
            if(!paper_sell) 
              {
               if(seller)   //paper sell
                 {
                  paper_sell = true;
                  paper_sell_price = price_1;
                 }
              }
           }
        }
     }
   if(!confidence)                        
     {
      if(paper_buy)
        {
         paper_buy = false;
           {
            if(price_1 > paper_buy_price)            
              {
               trade_allowed = true;
              }
           }
        }
      if(paper_sell)
        {
         paper_sell = false;
           {
            if(price_1 < paper_sell_price)         
              {
               trade_allowed = true;
              }
           }
        }
     }*/
   if(ATR_1 > ATR_2)
     {
      if(!weekend_breaker || trade_allowed)
        {
         if(!CheckOpenOrders())
           {
            if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),confidence_timeframe,0) + random_trade_time))
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,congate,0,clrNONE);
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
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,congate,0,clrNONE);
                    }
                 }
              }
           }
        }
     }
     
   if(ATR_1 < ATR_2)
     {
      if(CheckOpenOrders())
        {
         for(i = 0; i < OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol() == Symbol() && OrderMagicNumber() == congate)
                 {
                  if(OrderType() == OP_BUY)
                    {
                     buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     if(OrderProfit() > 0) 
                       {
                        trade_allowed = true;
                       }
                    }
                  if(OrderType() == OP_SELL)
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
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
