//NOTE: ExpertRemove() function activates after closing 1st trade

/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG    N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I     G  G   NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I     G      N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I     G GG   N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG    N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "Copyright 2021, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define bollinger 121721                 

input double lot = .1;
input int deviation_go = 1, deviation_turn = 3, period = 21, bands_shift = 0;
input double high_band_value = 1;
input double low_band_value = .3;
input int time_1 = 0;
input int MA_smoothed_price = 3;
input int MA_fast = 13;
input int MA_mid = 21;
input int MA_slow = 34;
input int bar_interval = 60;

double pips;

bool CheckOpenOrders()
  { 
   for( int i = 0 ; i < OrdersTotal() ; i++ ) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == bollinger) return(true); 
     } 
      return(false); 
  }




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double double_lot = lot * 2;

   double price_0 = iClose(Symbol(),bar_interval,0);
   double price_1 = iClose(Symbol(),bar_interval,1);
   double price_2 = iClose(Symbol(),bar_interval,2);
   double price_3 = iClose(Symbol(),bar_interval,3);
   long volume_0 = iVolume(Symbol(),bar_interval,0);
   long volume_1 = iVolume(Symbol(),bar_interval,1);
   long volume_2 = iVolume(Symbol(),bar_interval,2);
   long volume_3 = iVolume(Symbol(),bar_interval,3);
   long volume_4 = iVolume(Symbol(),bar_interval,4);
   
   
   double bollinger_go_top = iBands(Symbol(),0,period,deviation_go,bands_shift,PRICE_CLOSE,1,1);
   double bollinger_go_middle = iBands(Symbol(),0,period,deviation_go,bands_shift,PRICE_CLOSE,0,1);
   double bollinger_go_bottom = iBands(Symbol(),0,period,deviation_go,bands_shift,PRICE_CLOSE,2,1);
   
   double bollinger_turn_top = iBands(Symbol(),0,period,deviation_turn,bands_shift,PRICE_CLOSE,1,1);
   //double bollinger_turn_middle = iBands(Symbol(),0,period,deviation_turn,bands_shift,PRICE_CLOSE,0,1);
   double bollinger_turn_bottom = iBands(Symbol(),0,period,deviation_turn,bands_shift,PRICE_CLOSE,2,1);
   
   //double go_sum = bollinger_go_top + bollinger_go_middle + bollinger_go_bottom;
   //double turn_sum = bollinger_turn_top + bollinger_turn_middle + bollinger_turn_bottom;
   
   double price_1_multiple = price_1 *3;
   //double band1 = ((bollinger_go_top - bollinger_go_bottom)/bollinger_go_middle)*100;
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891 
   double smoothed_price = iMA(Symbol(),time_1,MA_smoothed_price,0,MODE_SMA,PRICE_CLOSE,0); 
   double ima1_fast = iMA(Symbol(),time_1,MA_fast,0,MODE_SMA,PRICE_CLOSE,1);
   double ima1_mid = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,1);
   double ima1_slow = iMA(Symbol(),time_1,MA_slow,0,MODE_SMA,PRICE_CLOSE,1);
   
   double ima2_mid = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,2);
   
   if(CheckOpenOrders() == false)
     {
      if(price_1 > ima1_mid && ima1_mid > ima2_mid && ima1_fast > ima1_mid)
        {
         if(price_1 > bollinger_go_top)
           {
            if(price_0 > smoothed_price && price_1 > price_2 && price_2 > price_3 )
              {
               if(volume_1 > volume_2 && volume_2 > volume_3)
                 {
                  double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,bollinger,0,clrNONE);
                 }
              }
           }
        }
      if(price_1 < ima1_mid && ima1_mid < ima2_mid && ima1_fast < ima1_mid)
        {
         if(price_1 < bollinger_go_bottom)
           {
            if(price_0 < smoothed_price && price_1 < price_2 && price_2 < price_3)
              {
               if(volume_1 > volume_2 && volume_2 > volume_3)
                 {
                  double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,bollinger,0,clrNONE);
                 }
              }
           }
        }
     }
 
   if(CheckOpenOrders() == true)
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == bollinger)
              {
               if((OrderType() == OP_BUY) && price_1 < price_2 && (price_1 < bollinger_go_middle))
                 {
                  //if(price_1_hour > price_2_hour)
                    //{
                     double buy_close = OrderClose(OrderTicket(),lot,Bid,0,clrNONE);
                    //}
                       {
                        if(buy_close > -1) 
                          {
                           ExpertRemove();
                          }
                       }
                 }
              
            
               if((OrderType() == OP_SELL) && price_1 > price_2 && (price_1 > bollinger_go_middle))
                 {
                  //if(price_1_hour < price_2_hour)
                    
                    //{
                     double sell_close = OrderClose(OrderTicket(),lot,Ask,0,clrNONE);
                    //}
                    {
                        if(sell_close > -1) 
                          {
                           ExpertRemove();
                          }
                       }
                 } 
              } 
           }
        }
     }
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
