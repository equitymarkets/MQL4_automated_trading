//RSI and new MA/price event
/*

*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define layers_new 012822

//input double lot = .1;
input short long_chart = 1440, mid_chart = 240, short_chart = 60, MA_fast = 34, MA_slow = 70;
input short volume_value = 10, MA_value = 10, price_value = 10, RSI_value = 10, confidence_breakpoint = 50;
input short ma_method = 0, RSI_period = 14;
input double volume_multipier = 2.25;                //multiply by existing volume quotient
input double volume_gate_multiplier = 1.2;
input double confidence_divisor = 2.5;
double pips;
int i;

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

bool CheckOpenOrders()
  {
   for(i = 0; i < OrdersTotal(); i++)
     {
      bool check = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == layers_new) return(true);
     }
      return(false);
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
   Comment("layers2022");
   return(INIT_SUCCEEDED);
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnDeinit(const int reason)
  {
   Alert("EA layers2022 disconnected from chart!");
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

void OnTick()
  {
   //Size
   double lot = .1;
   double double_lot = lot * 2; 
   double quad_lot = lot * 4;
   //Price
   double price_long_0 = iClose(Symbol(),long_chart,0);
   double price_long_1 = iClose(Symbol(),long_chart,1);
   double price_long_2 = iClose(Symbol(),long_chart,2);
   double price_long_3 = iClose(Symbol(),long_chart,3);
   double price_mid_0 = iClose(Symbol(),mid_chart,0);
   double price_mid_1 = iClose(Symbol(),mid_chart,1);
   double price_mid_2 = iClose(Symbol(),mid_chart,2);
   double price_mid_3 = iClose(Symbol(),mid_chart,3);
   double price_short_0 = iClose(Symbol(),short_chart,0);
   double price_short_1 = iClose(Symbol(),short_chart,1);
   double price_short_2 = iClose(Symbol(),short_chart,2);
   double price_short_3 = iClose(Symbol(),short_chart,3);
   //Indicators
   double fastMA_long_1 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_long_2 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double fastMA_long_3 = iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,3);
   double fastMA_mid_1 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_mid_2 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double fastMA_mid_3 = iMA(Symbol(),mid_chart,MA_fast,0,ma_method,PRICE_CLOSE,3);
   double fastMA_short_1 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,1);
   double fastMA_short_2 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,2);
   double fastMA_short_3 = iMA(Symbol(),short_chart,MA_fast,0,ma_method,PRICE_CLOSE,3);
   double slowMA_long_1 = iMA(Symbol(),long_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_long_2 = iMA(Symbol(),long_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   double slowMA_long_3 = iMA(Symbol(),long_chart,MA_slow,0,ma_method,PRICE_CLOSE,3);
   double slowMA_mid_1 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_mid_2 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   double slowMA_mid_3 = iMA(Symbol(),mid_chart,MA_slow,0,ma_method,PRICE_CLOSE,3);
   double slowMA_short_1 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,1);
   double slowMA_short_2 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,2);
   double slowMA_short_3 = iMA(Symbol(),short_chart,MA_slow,0,ma_method,PRICE_CLOSE,3);
   //Volume
   long volume_long_0 = iVolume(Symbol(),long_chart,0);
   long volume_long_1 = iVolume(Symbol(),long_chart,1);
   long volume_long_2 = iVolume(Symbol(),long_chart,2);
   long volume_long_3 = iVolume(Symbol(),long_chart,3);
   long volume_mid_0 = iVolume(Symbol(),mid_chart,0);
   long volume_mid_1 = iVolume(Symbol(),mid_chart,1);
   long volume_mid_2 = iVolume(Symbol(),mid_chart,2);
   long volume_mid_3 = iVolume(Symbol(),mid_chart,3);
   long volume_short_0 = iVolume(Symbol(),short_chart,0);
   long volume_short_1 = iVolume(Symbol(),short_chart,1);
   long volume_short_2 = iVolume(Symbol(),short_chart,2);
   long volume_short_3 = iVolume(Symbol(),short_chart,3);
   //Oscillator
   double RSI_long_1 = iRSI(Symbol(),long_chart,RSI_period,PRICE_CLOSE,1);
   double RSI_long_2 = iRSI(Symbol(),long_chart,RSI_period,PRICE_CLOSE,2);
   double RSI_long_3 = iRSI(Symbol(),long_chart,RSI_period,PRICE_CLOSE,3);
   double RSI_mid_1 = iRSI(Symbol(),mid_chart,RSI_period,PRICE_CLOSE,1);
   double RSI_mid_2 = iRSI(Symbol(),mid_chart,RSI_period,PRICE_CLOSE,2);
   double RSI_mid_3 = iRSI(Symbol(),mid_chart,RSI_period,PRICE_CLOSE,3);
   double RSI_short_1 = iRSI(Symbol(),short_chart,RSI_period,PRICE_CLOSE,1);
   double RSI_short_2 = iRSI(Symbol(),short_chart,RSI_period,PRICE_CLOSE,2);
   double RSI_short_3 = iRSI(Symbol(),short_chart,RSI_period,PRICE_CLOSE,3);
   
   int confidence_level = 0;
   
      //1
      if(iMA(Symbol(),mid_chart,3,0,ma_method,PRICE_CLOSE,0)>(iMA(Symbol(),long_chart,3,0,ma_method,PRICE_CLOSE,1)))
        {
         confidence_level = confidence_level + price_value;
        }
      if(iMA(Symbol(),mid_chart,3,0,ma_method,PRICE_CLOSE,0)<(iMA(Symbol(),long_chart,3,0,ma_method,PRICE_CLOSE,1)))
        {
         confidence_level = confidence_level - price_value;
        }
      //2
      if(fastMA_short_1 > slowMA_short_1)
        {
         confidence_level = confidence_level + price_value;
        }
      if(fastMA_short_1 < slowMA_short_1)
        {
         confidence_level = confidence_level - price_value;
        }
      //3
      if(iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,0) > slowMA_long_1)
        {
         confidence_level = confidence_level + price_value;
        }
      if(iMA(Symbol(),long_chart,MA_fast,0,ma_method,PRICE_CLOSE,0) < slowMA_long_1)
        {
         confidence_level = confidence_level - price_value;
        }
      //4
      if(fastMA_mid_1 > slowMA_mid_1)
        {
         confidence_level = confidence_level + MA_value;
        }
      if(fastMA_mid_1 < slowMA_mid_1)
        {
         confidence_level = confidence_level - MA_value;
        }
      //5
      /*if((volume_mid_0 > (volume_long_1/6 * volume_multipier)) && iMA(Symbol(),short_chart,3,0,ma_method,PRICE_CLOSE,0) > price_mid_1 && price_mid_1 > price_mid_2)
        {
         confidence_level = confidence_level + volume_value;
        }
      if((volume_mid_0 > (volume_long_1/6 * volume_multipier)) && iMA(Symbol(),short_chart,3,0,ma_method,PRICE_CLOSE,0) < price_mid_1 && price_mid_1 < price_mid_2)
        {
         confidence_level = confidence_level - volume_value;
        }*/
      //6
      if(iMA(Symbol(),mid_chart,2,0,ma_method,PRICE_CLOSE,0) > fastMA_mid_1)
        {
         confidence_level = confidence_level + MA_value;
        }
      if(iMA(Symbol(),mid_chart,2,0,ma_method,PRICE_CLOSE,0) < fastMA_mid_1)
        {
         confidence_level = confidence_level - MA_value;
        }
      //7
      if(RSI_mid_1 > 50 && RSI_mid_1 < 70)
        {
         confidence_level = confidence_level + RSI_value;
        }
      if(RSI_mid_1 < 50 && RSI_mid_1 > 30)
        {
         confidence_level = confidence_level - RSI_value;
        }
      //8
      if(iLow(Symbol(),short_chart,0) > iLow(Symbol(),short_chart,1) && iLow(Symbol(),short_chart,1) > iLow(Symbol(),short_chart,2) && iLow(Symbol(),short_chart,2) > iLow(Symbol(),short_chart,3))
        {
         confidence_level = confidence_level + price_value;
        }
      if(iHigh(Symbol(),short_chart,0) < iHigh(Symbol(),short_chart,1) && iHigh(Symbol(),short_chart,1) < iHigh(Symbol(),short_chart,2) && iHigh(Symbol(),short_chart,2) < iHigh(Symbol(),short_chart,3))
        {
         confidence_level = confidence_level - price_value;
        }
     
   
   if(!CheckOpenOrders())
     {
      if(confidence_level > 0 && confidence_level >= confidence_breakpoint && (volume_mid_0 > (((volume_long_1 + volume_long_2 + volume_long_3)/18)*volume_gate_multiplier) && (price_mid_1 > fastMA_mid_1)))
        {
         double buy_order = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0," ",layers_new,0,clrNONE);
        }
      if(confidence_level < 0 && confidence_level <= confidence_breakpoint && (volume_mid_0 > (((volume_long_1 + volume_long_2 + volume_long_3)/18)*volume_gate_multiplier) && (price_mid_1 < fastMA_mid_1)))
        {
         double sell_order = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0," ",layers_new,0,clrNONE);
        }
     }
   if(CheckOpenOrders())
     {
      for(i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == layers_new)
              {
               if ((OrderType() == OP_BUY) && confidence_level < (confidence_breakpoint/confidence_divisor))
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
               if((OrderType() == OP_SELL) && confidence_level > (confidence_breakpoint/confidence_divisor))
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
              }
           }
        }
     }
  }

//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
