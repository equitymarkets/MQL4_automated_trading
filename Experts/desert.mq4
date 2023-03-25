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
#define desert 061422

extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false, atv = false;
extern bool stop_extremes = false;     //must also select stops to true!
extern bool limit_edge = false;         //must also selest limits to true!
extern double stop_extremes_adj = 4.0, limit_edge_adj = 1.5;
extern short hour_begin = 10, hour_end = 15, timeframe = 240, stop_loss = 30, limit_entry = 30;
extern short what_minute = 0, array_lookback_period = 100;
extern double lot = .5;
extern short gate_timeframe = 30, ATR_gate_period = 14;
extern short ATR_timeframe = 5, OBV_timeframe = 60, ATR_period = 13, ATV_break = 600;
extern static bool trade_allowed = false;
extern bool cease_trade_time = 30000;
extern short fast_period = 8, slow_period = 10, signal_period = 3;
extern short ma_timeframe = 30, MA_period = 21;
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
int i;

double pips;

bool CheckOpenOrders()
  {
   for(i = 0; i < OrdersTotal(); i++)
     {
      bool check = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol() == Symbol()) return(true);
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
   Comment(WindowExpertName() + " initialized ");
   return(INIT_SUCCEEDED);
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
void OnDeinit(const int reason)
  {
   Alert(WindowExpertName() + " deinitialized!");
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
void OnTick()
  {
   double buy_close, sell_close;
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   double smoothed_price_0 = iMA(Symbol(),1,3,0,MODE_SMA,PRICE_CLOSE,0);
   double smoothed_price_1 = iMA(Symbol(),1,3,0,MODE_SMA,PRICE_CLOSE,1);
   double ATR_0 = iATR(Symbol(),gate_timeframe,ATR_gate_period,0);
   double ATR_1 = iATR(Symbol(),gate_timeframe,ATR_gate_period,1);
   double ATR_2 = iATR(Symbol(),gate_timeframe,ATR_gate_period,2);
   double ATR_3 = iATR(Symbol(),gate_timeframe,ATR_gate_period,3);
   double MA_1 = iMA(Symbol(),ma_timeframe,MA_period,0,MODE_SMA,PRICE_CLOSE,1);
   double MA_2 = iMA(Symbol(),ma_timeframe,MA_period,0,MODE_SMA,PRICE_CLOSE,2);
   double MA_3 = iMA(Symbol(),ma_timeframe,MA_period,0,MODE_SMA,PRICE_CLOSE,3);
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   
   if((Minute() >= what_minute && (ATR_0 + ATR_1 + ATR_2)/3 > (ATR_1 + ATR_2 + ATR_3)/3)) bool confidence = true;
   
   if(MA_1 > MA_2 && price_1 > MA_1 && price_1 > price_2 && smoothed_price_0 > smoothed_price_1) bool buyer = true;
   if(MA_1 < MA_2 && price_1 < MA_1 && price_1 < price_2  && smoothed_price_0 < smoothed_price_1) bool seller = true;
   if(MA_1 < MA_2 && price_1 < MA_1 && price_1 < price_2  && smoothed_price_0 < smoothed_price_1) bool buy_closer = true;
   if(MA_1 > MA_2 && price_1 > MA_1 && price_1 > price_2 && smoothed_price_0 > smoothed_price_1) bool sell_closer = true;
   
   if(confidence)
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
            else
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
            if(!paper_sell) 
              {
               if(seller)   //paper sell
                 {
                  paper_sell = true;
                  paper_sell_price = price_1;
                 }
              }
            else
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
        }
      if(!weekend_breaker || trade_allowed)
        {
         if(!CheckOpenOrders())
           {
            static int random_trade_time = rand()%(timeframe * 60);
            if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
              {
               if(!time || (Hour() >= hour_begin && Hour() <= hour_end)) 
                 {
                  if(buyer)
                    {
                     if(limits) 
                       { 
                        buy_order = OP_BUYLIMIT;
                        if(limit_edge_adj)
                          {
                           buy_limit = (iLow(Symbol(),timeframe,iLowest(Symbol(),timeframe,MODE_LOW,10,0)) + (limit_edge_adj * pips));
                          }
                        else buy_limit = Ask - (limit_entry * pips);
                       }
                     if(stops) 
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iLow(Symbol(),timeframe,iLowest(Symbol(),timeframe,MODE_LOW,10,0)) - (stop_extremes_adj * pips));
                          }  
                        else stop_trade = Ask - (stop_loss * pips);
                       }
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,desert,0,clrNONE);
                    }
                  if(seller)
                    {
                     if(limits)
                       {
                        sell_order = OP_SELLLIMIT;
                        if(limit_edge)
                          {
                           sell_limit = (iHigh(Symbol(),timeframe,iHighest(Symbol(),timeframe,MODE_HIGH,10,0)) - (limit_edge_adj * pips));
                          }
                        else sell_limit = Bid + (limit_entry * pips);
                       }
                     if(stops)
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iHigh(Symbol(),timeframe,iHighest(Symbol(),timeframe,MODE_HIGH,10,0)) + (stop_extremes_adj * pips));
                          }
                        else stop_trade = Bid + (stop_loss * pips);
                       }
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,desert,0,clrNONE);
                    }
                 }
              }
           }
        }
     }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == desert)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < ATV_break)
                    {
                     buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     random_trade_time = rand()%(timeframe * 60);
                     if(OrderProfit() > 0) 
                       {
                        trade_allowed = true;
                       }
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe,ATR_period) > -ATV_break)
                    {
                     sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                     random_trade_time = rand()%(timeframe * 60);
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
