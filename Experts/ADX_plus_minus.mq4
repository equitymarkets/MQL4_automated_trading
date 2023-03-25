//+------------------------------------------------------------------+
//|                                                           EA.mq4 |
//|                                   Copyright 2020 laserdesign.io. |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+



#property copyright "Copyright 2020, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#define ADX_pm 07042002

extern double lot = .1;
extern double stop_loss = 50;
extern double take_profit = 100;

//////ADX variables
extern int timeFrame = 240;
extern int ADXma = 8;
extern int ADXPLUSma = 55;
extern int ADXMINUSma = 55;
extern int k_period = 21,d_period = 34 ,slowing = 3;
extern bool price_field = 0;  

double pips;

bool CheckOpenOrders() {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol()) return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double tick = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(tick == .00001 || tick == .001)
     {
      pips = tick * 10;
     }
   else pips = tick;
//---
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
   //iADX(NULL,0,14,PRICE_HIGH,MODE_PLUSDI,0)
   double ADX1 = iADX(Symbol(),timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,1);
   double ADX2 = iADX(Symbol(),timeFrame,ADXma,PRICE_CLOSE,MODE_MAIN,2);
   double ADX_PLUS1 = iADX(Symbol(),timeFrame,ADXPLUSma,PRICE_CLOSE,MODE_PLUSDI,1);
   double ADX_MINUS1 = iADX(Symbol(),timeFrame,ADXMINUSma,PRICE_CLOSE,MODE_MINUSDI,1);
   
   double stoch = iStochastic(Symbol(),0,k_period,d_period,slowing,MODE_SMA,price_field,MODE_MAIN,1);
   
   if(CheckOpenOrders() == false)
     {
      if(ADX1 > ADX2)
        {
         if(ADX_PLUS1 > ADX_MINUS1)
           {
            //if(stoch < 85) 
              {
               double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,NULL,ADX_pm,0,clrNONE);
              }
           }
         if(ADX_PLUS1 < ADX_MINUS1)
           {
            //if(stoch > 15)
              {
               double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,NULL,ADX_pm,0,clrNONE);
              }
           }
        }
     }
     
     
     
     
     
     
     
     
     
     
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == ADX_pm)
           {
            
            if(OrderType() == OP_BUY && ADX1 < ADX2 && ADX_PLUS1 < ADX_MINUS1)
              {
               double buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
              }
            
            if(OrderType() == OP_SELL && ADX1 < ADX2 && ADX_PLUS1 > ADX_MINUS1)
              {
               double sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
              }
           }
        }
     }      
     
     
     
     
     
     
     
  }

