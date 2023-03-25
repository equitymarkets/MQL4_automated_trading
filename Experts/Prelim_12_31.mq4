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
#property description "4-dimensional short-term EA"

extern double ADX_break = 25;
extern double lot = 1; 
extern int moving_average_lo = 21;
extern int moving_average_hi = 34;

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
   if(OrdersTotal() < 1)
      if(iADX(Symbol(),0,14,PRICE_CLOSE,MODE_MAIN,1) > ADX_break)
         if(iClose(Symbol(),0,1) > iClose(Symbol(),0,1))
           {
            double trend_buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0100,0,clrNONE);
           }
         
         if(iClose(Symbol(),0,1) < iClose(Symbol(),0,1))
           {
            double trend_sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0100,0,clrNONE);
           }       
   for(int i; i < OrdersTotal(); i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber() == 0100)
            //making this up for now
            if(iClose(Symbol(),0,1) < moving_average_hi)
              {
               double trend_buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
              }
            if(iClose(Symbol(),0,1) > moving_average_hi)
              {
               double trend_sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
              }
  }
//+------------------------------------------------------------------+
