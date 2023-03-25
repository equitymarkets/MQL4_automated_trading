
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
#property link      "https://www.metatrader5.com/en/terminal/help/charts_analysis/indicators"   //reference
//#property strict

#define   MOT 062322

extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false, atv = false;
extern bool stop_extremes = false;     //must also select stops to true!
extern bool limit_edge = false;         //must also selest limits to true!
extern double stop_extremes_adj = 4.0, limit_edge_adj = 1.5;
extern short timeframe = 60, stop_loss = 30, limit_entry = 30;
extern short what_minute = 0, array_lookback_period = 100;
extern double lot = .5;
extern short ATR_timeframe = 5, OBV_timeframe = 60, ATR_period = 13, ATV_break = 600;
extern static bool trade_allowed = false;
extern short fast_period = 8, slow_period = 10, signal_period = 3;

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

int Entropy(int minutes)
  {
   int time_addition = rand()%(minutes * 60);
   return(time_addition);
  }

bool IsNewCandle()
  {
   static datetime saved_candle_time;
   if(Time[0] == saved_candle_time)
     {
      return(false);
     }
   else
      saved_candle_time = Time[0];
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
   Alert(WindowExpertName() + " deinitialized!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   Comment("Tokyo " + (TimeCurrent() + (6 * 60 * 60)) + "\nServer " + (TimeCurrent()) 
      + "\nGMT " + (TimeCurrent() - (3 * 60 * 60)) + "\nLondon " + (TimeCurrent() - (2 * 60 * 60)) 
      + "\nNew York " + (TimeCurrent() - (7 * 60 * 60)) + "\nLocal " 
      + (TimeCurrent() - (9 * 60 * 60)));
    
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),timeframe,0);
   double price_1 = iClose(Symbol(),timeframe,1);
   double price_2 = iClose(Symbol(),timeframe,2);
   
   double MACD_0 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,0);
   double MACD_1 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,1);
   double MACD_2 = iMACD(Symbol(),timeframe,fast_period,slow_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,2);
   
  
   static double buy, sell;
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   int buy_order = OP_BUY, sell_order = OP_SELL;
   
   double price_array[];           //remove if not needed
   int price_array_size = array_lookback_period;
   ArrayResize(price_array,array_lookback_period);
   
   for(i = 0; i < array_lookback_period; i++)   //sub any data
     {
      price_array[i] = iClose(Symbol(),timeframe,i);
     }
  
   
   if(iTime(Symbol(),timeframe,0) - iTime(Symbol(),timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
   
   bool buyer, seller, buy_closer, sell_closer, confidence; 
   if(Minute() >= what_minute) confidence = true;
     
   if(price_1 > price_2 && (MACD_1 > MACD_2) ) buyer = true;
   if(price_1 < price_2 && (MACD_1 < MACD_2) ) seller = true;
   if(price_1 < price_2 && (MACD_1 < MACD_2) ) buy_closer = true;
   if(price_1 > price_2 && (MACD_1 > MACD_2) ) sell_closer = true;
   
   if(confidence)
     { 
      if(trade_allowed)
        {
         if(!CheckOpenOrders())
           {
            //static int random_trade_time = rand()%(timeframe * 60);
            static int random_trade_time = Entropy(timeframe);
            if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),timeframe,0) + random_trade_time))
              {
               if(!time || (Hour() != 0)) 
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
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL, MOT ,0,clrNONE);
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
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL, MOT ,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MOT )
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < ATV_break)
                    {
                     buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     
                    }
                 }
               if(OrderType() == OP_SELL && sell_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe,ATR_period) > -ATV_break)
                    {
                     sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                    }
                 }
              }      
           }
        }
     }
  }
 
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
