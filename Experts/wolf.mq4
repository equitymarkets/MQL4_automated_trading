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

#define wolf 020922       

extern double lot = .5;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false, atv = false;
extern bool stop_extremes = false;     //must also select stops to true!
extern bool limit_edge = false;         //must also selest limits to true!
extern double stop_extremes_adj = 4.0, limit_edge_adj = 1.5;
extern short hour_begin = 10, hour_end = 15, timeframe = 240, stop_loss = 30, limit_entry = 30;
extern short what_minute = 0, array_lookback_period = 100;

extern short ATR_timeframe = 5, OBV_timeframe = 60, ATR_period = 13, ATV_break = 600;
extern static bool trade_allowed = false;

extern short MACD_fast = 8, MACD_slow = 15, MACD_signal = 5;
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
double ATV_0(short atr_timeframe, short obv_timeframe, short atr_period)
  {
   double ATR_0 = iATR(Symbol(),atr_timeframe,atr_period,0);
   double OBV_0 = iOBV(Symbol(),obv_timeframe,PRICE_CLOSE,0); 
   return(ATR_0 * OBV_0);
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
   Alert("wolf.ex4 deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   double double_lot = lot * 2;
   double buy, sell, buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   double MACD_0 = iMACD(Symbol(),timeframe,MACD_fast,MACD_slow,MACD_signal,PRICE_CLOSE,MODE_SIGNAL,0);
   double MACD_1 = iMACD(Symbol(),timeframe,MACD_fast,MACD_slow,MACD_signal,PRICE_CLOSE,MODE_SIGNAL,1);
   double MACD_2 = iMACD(Symbol(),timeframe,MACD_fast,MACD_slow,MACD_signal,PRICE_CLOSE,MODE_SIGNAL,2);
   
   double OBV_0 = iOBV(Symbol(),timeframe,PRICE_CLOSE,0);
   double OBV_1 = iOBV(Symbol(),timeframe,PRICE_CLOSE,1);
   double OBV_2 = iOBV(Symbol(),timeframe,PRICE_CLOSE,2);
   
   static double random_trade_time = MathRand()/2.8;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
    
   if(((OBV_0 + OBV_1)/2 > OBV_2) && MACD_1 > MACD_2) bool buyer = true;
   if(((OBV_0 + OBV_1)/2 < OBV_2) && MACD_1 < MACD_2) bool seller = true;
   if(((OBV_0 + OBV_1)/2 < OBV_2) && MACD_1 < MACD_2) bool buy_closer = true;
   if(((OBV_0 + OBV_1)/2 > OBV_2) && MACD_1 > MACD_2) bool sell_closer = true;
   
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
               buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,wolf,0,clrNONE);
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
               sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,wolf,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && (OrderMagicNumber() == wolf))
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  
                 }
               if(OrderType() == OP_SELL && sell_closer)
                 {
                  sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  
                 }
              }      
           }
        }
     }
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
