//+------------------------------------------------------------------+
//|                                           standard_deviation.mq4 |
//|                                   Copyright 2022, laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#define SD 062022

extern short short_timeframe = 5, long_timeframe = 34, SD_lookback = 13;

short pips;

int i;

bool CheckOpenOrders()
  {
   for(i = 0; i < OrdersTotal(); i ++)
     {
      bool check = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol() == Symbol()) return(true);
     }
   return(false);
  }     

int OnInit()
  {
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   pips = ((tick == .00001 || tick == .001) ? tick * 10 : tick);

   Comment(WindowExpertName() + " initialized ");     
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   string output;
   
   switch(reason)
     {
      case(0): output = "EA terminated using ExpertRemove()."; break;
      case(1): output = "EA deleted from chart."; break;
      case(2): output = "Program recompiled."; break;
      case(3): output = "Period changed."; break;
      case(4): output = "Chart closed."; break;
      case(5): output = "Input parameters changed."; break;
      case(6): output = "Change in account settings."; break;
      case(7): output = "New template applied."; break;
      case(8): output = "OnInit() != 0."; break;
      case(9): output = "Terminal closed."; break;
     }
   Alert(WindowExpertName() + " has been closed. Reason: " + reason + ": " + output); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double price_1 = iClose(Symbol(),long_timeframe,1);
   double price_2 = iClose(Symbol(),long_timeframe,2);
   
   double smoothed_price_short_0 = iMA(Symbol(),short_timeframe,3,0,MODE_SMA,PRICE_MEDIAN,0);
   double smoothed_price_short_1 = iMA(Symbol(),short_timeframe,3,0,MODE_SMA,PRICE_MEDIAN,1);

   //indicator_timeframe_period_shift
   double SD1_top_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,1,0,PRICE_CLOSE,1,1);
   double SD1_middle_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,1,0,PRICE_CLOSE,0,1);
   double SD1_bottom_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,1,0,PRICE_CLOSE,2,1);
   double SD1_top_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,1,0,PRICE_CLOSE,1,1);
   double SD1_middle_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,1,0,PRICE_CLOSE,0,1);
   double SD1_bottom_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,1,0,PRICE_CLOSE,2,1);
   double SD2_top_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,2,0,PRICE_CLOSE,1,1);
   double SD2_middle_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,2,0,PRICE_CLOSE,0,1);
   double SD2_bottom_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,2,0,PRICE_CLOSE,2,1);
   double SD2_top_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,2,0,PRICE_CLOSE,1,1);
   double SD2_middle_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,2,0,PRICE_CLOSE,0,1);
   double SD2_bottom_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,2,0,PRICE_CLOSE,2,1);
   double SD3_top_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,3,0,PRICE_CLOSE,1,1);
   double SD3_middle_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,3,0,PRICE_CLOSE,0,1);
   double SD3_bottom_short_1 = iBands(Symbol(),short_timeframe,SD_lookback,3,0,PRICE_CLOSE,2,1);
   double SD3_top_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,3,0,PRICE_CLOSE,1,1);
   double SD3_middle_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,3,0,PRICE_CLOSE,0,1);
   double SD3_bottom_long_1 = iBands(Symbol(),long_timeframe,SD_lookback,3,0,PRICE_CLOSE,2,1);
   
   //+---tripwire verifies buy and sell signals and insures against infinite looping 
   //if OrderType() == buy?
   bool tripwire;
   //if(smoothed_price_short_0 > smoothed_price_short_1) tripwire = 
   //OrderType()
   
   
   
   if(price_1 > price_2) bool buyer = true;
   if(price_1 < price_2) bool seller = true;
   
   
   Alert(sizeof(int));
  }


