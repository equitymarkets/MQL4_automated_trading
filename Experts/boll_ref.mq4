//polish up stop and limit logic, trade entry and exit times, compare old system and ATV issue
//H4 vs. H1
/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//confidence and gate basic model
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define boll 070420

extern bool weekend_breaker = false, atv = false, random = false, time = false,  
            stops = false, limits = false;
extern bool stop_extremes = false;        //must also select stops to true!
extern bool limit_edge = false;           //must also selest limits to true!
extern double stop_extremes_adj = 4.0, limit_edge_adj = 1.5;
extern short hour_begin = 10, hour_end = 15;
extern short ATR_timeframe = 5, OBV_timeframe = 60, ATR_period = 13, ATV_break = 600;
extern short stop_loss = 30, limit_entry = 30;
extern short what_minute = 4;


extern int moving_average_calc = 21;
extern double high_band_value = 1;
extern double low_band_value = .3;

extern double take_profit = 250;
extern int timeframe = 240;
input int long_chart = 240;
input int mid_chart = 60;
input int short_chart = 5;
input double limit_pips = 1;
extern static bool trade_allowed = false;
extern double lot = .5;
double pips;

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

void OrderHistory()
  {
   for(i = 0; i < OrdersHistoryTotal(); i++)
     {
      bool checker = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        {
         Alert( "Order ", i, " time was ",  OrderCloseTime() - OrderOpenTime());
        }
     }
  }
  
double ATV_0(short atr_timeframe, short obv_timeframe, short atr_period)
  {
   double ATR_0 = iATR(Symbol(),atr_timeframe,atr_period,0);
   double OBV_0 = iOBV(Symbol(),obv_timeframe,PRICE_CLOSE,0); 
   return(ATR_0 * OBV_0);
  } 


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

void OnDeinit(const int reason)
  {
   Alert("Boll_ref.ex4 deinialized:" + reason);   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   static double random_trade_time = MathRand()/2.8;
   
   double Boll_higher = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,1,1);
   double Boll_middle = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,0,1);
   double Boll_lower = iBands(Symbol(),0,moving_average_calc,2,0,PRICE_CLOSE,2,1);
   double band1 = ((Boll_higher - Boll_lower)/Boll_middle)*100;

   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
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
   
   if(Minute() >= what_minute && vol_short0/3 > vol_short/5) bool confidence = true;
     
   if(band1 > high_band_value && price_1 > Boll_higher && price_1 > price_2 && vol_short0/3 > vol_short/5) bool buyer = true;
   if(band1 < low_band_value && price_1 < Boll_lower && price_1 < price_2 && vol_short0/3 > vol_short/5) bool seller = true;
   if(price_1 < Boll_middle) bool buy_closer = true;
   if(price_1 > Boll_middle) bool sell_closer = true;

   if(confidence)
     {
      if(!CheckOpenOrders())
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,Ask + (take_profit * pips),NULL,boll,0,clrNONE);
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
                        sell_limit = Bid + (limit_entry * pips);
                       }
                     if(stops)
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iHigh(Symbol(),timeframe,iHighest(Symbol(),timeframe,MODE_HIGH,10,0)) + (stop_extremes_adj * pips));
                          }
                        else stop_trade = Bid + (stop_loss * pips);
                       }
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,Bid - (take_profit * pips),NULL,boll,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == boll)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < ATV_break)
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
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe,ATR_period) > -ATV_break)
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
//+--------------------------------------------------------------+
