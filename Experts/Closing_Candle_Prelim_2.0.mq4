/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2020, laserdesign.io"                                             //0
#property link      "https://www.laserdesign.io"                                                 //0
#property version   "1.00"
#property strict
#property description "fade the closing candles"


extern double lot = 1; 

extern int RSI_period = 14;
extern int RSI_price = 0; 
extern int MA_fast = 13;
extern int MA_mid = 21;
extern int ADXbreak = 25;
extern int MA_slow = 34;
extern int time_1 = 60;
extern int in_time = 50;
extern int out_time = 0;
extern double limit_amount = 1;

double pips;
//int i;
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

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double ADX0 = iADX(Symbol(),0,14,PRICE_CLOSE,MODE_MAIN,0);
   double ADX1 = iADX(Symbol(),0,14,PRICE_CLOSE,MODE_MAIN,1);
   double ADX2 = iADX(Symbol(),0,14,PRICE_CLOSE,MODE_MAIN,2);
   
   double RSI0 = iRSI(Symbol(),60,RSI_period,RSI_price,0);
   
   double ima0 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,0);
   double ima1 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,1);
   double ima2 = iMA(Symbol(),time_1,MA_mid,0,MODE_SMA,PRICE_CLOSE,2);
   
   double close_price0 = (iClose(Symbol(),time_1,0));
   double close_price1 = (iClose(Symbol(),time_1,1));
   double close_price2 = (iClose(Symbol(),time_1,2));
   
 
   //if the time is around the hour...
   if(Minute() == in_time || Minute() == in_time + 1 || Minute() == in_time + 2)
      if(OrdersTotal() < 1)
         if(ADX0 < ADXbreak)  
           {
            if(close_price0 > close_price1)   
               if(ima0 >= ima1)
                  if(close_price0 >= ima0)
                    {
                     double trend_sell = OrderSend(Symbol(),OP_SELLLIMIT,lot,Bid + (limit_amount * pips),0,0,0,NULL,0100,TimeCurrent() + 600,clrNONE);
                    }
         if(ADX0 < ADXbreak)
            if(close_price0 < close_price1)   
               if(ima0 <= ima1)
                  if(close_price0 <= ima0)  
                    {
                     double trend_buy = OrderSend(Symbol(),OP_BUYLIMIT,lot,Ask - (limit_amount * pips),0,0,0,NULL,0100,TimeCurrent() + 600,clrNONE);
                    }  
           }     
   for(int i; i < OrdersTotal(); i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber() == 0100)
            if(Minute() == out_time)
              {
               if(OrderType()==OP_SELL)
                 {
                  double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                 }
               if(OrderType()==OP_BUY)
                 {
                  double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                 }
              }
  }
//+------------------------------------------------------------------+
