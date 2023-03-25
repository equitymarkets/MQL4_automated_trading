//how to avoid changing chart twice???
/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
//confidence/gate method for old layers trading idea
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property description "Let's experiment with a 3 dimensional (3 layer) trading system."

#define layers2022b 012822
extern short VMA_Period = 21;
extern short VMA_Method = 0;
extern short VMA_Shift = 0;


extern double lot = .5;
extern short long_chart = 1440, mid_chart = 30, short_chart = 15, MA_fast = 5, MA_slow = 55;
extern bool time = false, random = false, stops = false, limits = false, weekend_breaker = false, atv = true;
extern bool stop_extremes = false;     //must also select stops to true!
extern bool limit_edge = false;         //must also selest limits to true!
extern double stop_extremes_adj = 4.0, limit_edge_adj = 1.5;
extern short hour_begin = 10, hour_end = 15, stop_loss = 30, limit_entry = 30;
extern short what_minute = 0;

extern short ATR_timeframe = 15, OBV_timeframe = 30, ATR_period = 14, ATV_break = 225;
extern static bool trade_allowed = false;
extern bool cease_trade_time = 30000;
int i;
double pips;

double ExtMapBuffer[];

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
  
bool CheckOpenOrders()
  {
   for(i = 0; i < OrdersTotal(); i++)
     {
      bool check = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == layers2022b) return(true);
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
   //--- indicators
int draw_begin;
   string short_name;
//--- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,VMA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(VMA_Period<2) VMA_Period = 13;
   draw_begin = VMA_Period - 1;
   switch(VMA_Method) 
     {
      case 1 : short_name = "EMA("; draw_begin = 0; break;
      default :
         VMA_Method = 0;
         short_name = "SMA(";
     }
//--- compile check
//--- indicator short name
   IndicatorShortName(short_name + VMA_Period + ")");
   SetIndexDrawBegin(0,draw_begin);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   
//--- 
   return(0);
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
   Comment("layers2022b");
   return(INIT_SUCCEEDED);
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("EA layers2022b experiencing recompile");
   
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   
   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
   static double buy, sell;
   double buy_close, sell_close;
   double price_0 = iClose(Symbol(),mid_chart,0);
   double price_1 = iClose(Symbol(),mid_chart,1);
   double price_2 = iClose(Symbol(),mid_chart,2);
   double close_price_long = iClose(Symbol(),long_chart,1);
   double close_price_mid = iClose(Symbol(),mid_chart,1);
   double close_price_short0 = iClose(Symbol(),short_chart,0);
   double close_price_short1 = iClose(Symbol(),short_chart,1);
   
   double ima_slow0 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,0);
   double ima_slow1 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_slow2 = iMA(Symbol(),mid_chart,MA_slow,0,MODE_SMA,PRICE_CLOSE,2);
   double ima_fast0 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,0);
   double ima_fast1 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,1);
   double ima_fast2 = iMA(Symbol(),mid_chart,MA_fast,0,MODE_SMA,PRICE_CLOSE,2);
  
   long vol_long = iVolume(Symbol(),long_chart,1);
   long vol_mid = iVolume(Symbol(),mid_chart,1);
   long vol_short = iVolume(Symbol(),short_chart,1);
   long vol_short0 = iVolume(Symbol(),short_chart,0);
   
   double stop_trade = 0, buy_limit = Ask, sell_limit = Bid;
   string buy_order = OP_BUY, sell_order = OP_SELL;
   
   double VMA = iCustom(Symbol(),0,"_EURUSD_layers2022_VMA_",VMA_Period,VMA_Method,VMA_Shift,MODE_MAIN,10);
   
   Alert(VMA);
   
   if(Minute() >= what_minute && ((vol_short0 + vol_short) * ((mid_chart/short_chart)/2)) > vol_mid) bool confidence = true;
     
   if(price_1 > price_2 && (close_price_short0 + close_price_short1 + close_price_mid)/3 > close_price_long 
      && ((ima_fast0 + ima_fast1 + ima_fast2)/3 > (ima_slow0 + ima_slow1 + ima_slow2)/3)) bool buyer = true;
   if(price_1 < price_2 && (close_price_short0 + close_price_short1 + close_price_mid)/3 < close_price_long
      && ((ima_fast0 + ima_fast1 + ima_fast2)/3 < (ima_slow0 + ima_slow1 + ima_slow2)/3)) bool seller = true;
   if(price_1 < price_2 && (close_price_short0 + close_price_short1 + close_price_mid)/3 < close_price_long
      && ((ima_fast0 + ima_fast1 + ima_fast2)/3 < (ima_slow0 + ima_slow1 + ima_slow2)/3)) bool buy_closer = true;
   if(price_1 > price_2 && (close_price_short0 + close_price_short1 + close_price_mid)/3 > close_price_long
      && ((ima_fast0 + ima_fast1 + ima_fast2)/3 > (ima_slow0 + ima_slow1 + ima_slow2)/3)) bool sell_closer = true;
   
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
            static int random_trade_time = rand()%(mid_chart * 60);
            if(!random || MarketInfo(Symbol(),MODE_TIME) >= (iTime(Symbol(),mid_chart,0) + random_trade_time))
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
                           buy_limit = (iLow(Symbol(),mid_chart,iLowest(Symbol(),mid_chart,MODE_LOW,10,0)) + (limit_edge_adj * pips));
                          }
                        else buy_limit = Ask - (limit_entry * pips);
                       }
                     if(stops) 
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iLow(Symbol(),mid_chart,iLowest(Symbol(),mid_chart,MODE_LOW,10,0)) - (stop_extremes_adj * pips));
                          }  
                        else stop_trade = Ask - (stop_loss * pips);
                       }
                     buy = OrderSend(Symbol(),buy_order,lot,buy_limit,0,stop_trade,0,NULL,layers2022b,0,clrNONE);
                    }
                  if(seller)
                    {
                     if(limits)
                       {
                        sell_order = OP_SELLLIMIT;
                        if(limit_edge)
                          {
                           sell_limit = (iHigh(Symbol(),mid_chart,iHighest(Symbol(),mid_chart,MODE_HIGH,10,0)) - (limit_edge_adj * pips));
                          }
                        else sell_limit = Bid + (limit_entry * pips);
                       }
                     if(stops)
                       {
                        if(stop_extremes)
                          {
                           stop_trade = (iHigh(Symbol(),mid_chart,iHighest(Symbol(),mid_chart,MODE_HIGH,10,0)) + (stop_extremes_adj * pips));
                          }
                        else stop_trade = Bid + (stop_loss * pips);
                       }
                     sell = OrderSend(Symbol(),sell_order,lot,sell_limit,0,stop_trade,0,NULL,layers2022b,0,clrNONE);
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
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == layers2022b)
              {
               if(OrderType() == OP_BUY && buy_closer)
                 {
                  if(!atv || ATV_0(ATR_timeframe,OBV_timeframe, ATR_period) < ATV_break)
                    {
                     buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     random_trade_time = rand()%(mid_chart * 60);
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
                     random_trade_time = rand()%(mid_chart * 60);
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

