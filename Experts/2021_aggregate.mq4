/*
 L        A     SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII     GG     N   N     IIIII     OO
 L       A A    S      E       R  R    D D   E       S        I      G  G    NN  N       I      O  O
 L      AAAAA    SS    EEE     RRR     D D   EEE      SS      I      G       N NNN       I      O  O
 L     A     A     S   E       R  R    D D   E          S     I      G GG    N  NN       I      O  O
 LLLL A       A SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII     GG     N   N  O  IIIII     OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "MarketProfile"
#import

input double lot = .1;
input int RSI_period = 14;
input double RSI_top = 70;
input double RSI_middle = 50;
input double RSI_bottom = 30;
input double middle_adj = 0;        //adjusts middle value, buy or sell adjustment
input double stop_loss = 50;

double pips;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     {
      double tick = MarketInfo(Symbol(), MODE_TICKSIZE);
      if(tick == .00001 || tick == .001)
        {
         pips = tick * 10;
        }
   else pips = tick; 
     }  
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
   double double_lot = lot * 2;
   
   double price = iClose(Symbol(),0,0);
   double price_1 = iClose(Symbol(),0,1);
   double price_2 = iClose(Symbol(),0,2);

   if((price > price_1 && price_1 > price_2) && OrdersTotal() < 1 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)<RSI_top)
     {
      if(iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)<RSI_bottom)
        {
         double buy = OrderSend(Symbol(),OP_BUY,double_lot,Ask,0,Ask - (stop_loss * pips),0,NULL,0,0,clrNONE);
        }
      else
        {
         double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,0,0,clrNONE);
        }
    } 
   if((price < price_1 && price_1 < price_2) && OrdersTotal() < 1 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)>RSI_bottom)
    {
     if(iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)>RSI_top)
        {
         double sell = OrderSend(Symbol(),OP_SELL,double_lot,Bid,0,Bid + (stop_loss * pips),0,NULL,0,0,clrNONE);
        }
     else
        {
         double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,0,0,clrNONE);
        }
    }       
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
        
         if((OrderType() == OP_BUY) && price_1 < price_2 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)>(RSI_middle + middle_adj))
           {
            double buy_close = OrderClose(OrderTicket(),lot,Bid,0,clrNONE);
           }             
         if((OrderType() == OP_SELL) && price_1 > price_2 && iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1)<(RSI_middle - middle_adj))
           {
            double sell_close = OrderClose(OrderTicket(),lot,Ask,0,clrNONE);
           }
        }
     }
  }
//+------------------------------------------------------------------+
