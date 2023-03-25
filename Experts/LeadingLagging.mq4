//+------------------------------------------------------------------+
//|                                               LeadingLagging.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int DIPlus = 0;
extern int DIMinus = 0;
extern int ADX = 14;

extern int MAInput = 21;
extern int LongMAInput = 34;
extern double lot = 1;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   
  }
void FreeFlowCap();
void OnTick()
  {
   double MA1 = iMA(NULL,0,MAInput,1,MODE_SMA,PRICE_CLOSE,0);
   double MA2 = iMA(NULL,0,MAInput,2,MODE_SMA,PRICE_CLOSE,0);
   double MA1long = iMA(NULL,0,LongMAInput,1,MODE_SMA,PRICE_CLOSE,0);
   double MA2long = iMA(NULL,0,LongMAInput,2,MODE_SMA,PRICE_CLOSE,0);
   double AD_MAIN = iADX(NULL,0,14,PRICE_CLOSE,0,0);
   double AD_PLUS = iADX(NULL,0,14,PRICE_CLOSE,0,0);
   double AD_MINUS = iADX(NULL,0,14,PRICE_CLOSE,0,0);
   double price1 = iClose(Symbol(),0,1);
   double price2 = iClose(Symbol(),0,2);
   int i;
   
   if(iADX(NULL,0,13,PRICE_HIGH,MODE_MAIN,0)>iADX(NULL,0,13,PRICE_HIGH,MODE_PLUSDI,0) && iADX(NULL,0,13,PRICE_HIGH,MODE_MAIN,0)- iADX(NULL,0,13,PRICE_HIGH,MODE_PLUSDI,0)>= 13 && (MA1 > MA2) && OrdersTotal()<1)
     {
      double buy = OrderSend(Symbol(),OP_BUY,lot,Ask,0,0,0,"Buy here",0,0,clrNONE);
      
      if(buy>-1)
         Print("Order executed.");
      else
         Print("Order not executed: ", GetLastError());
     }  
   if(iADX(NULL,0,13,PRICE_HIGH,MODE_MAIN,0)>iADX(NULL,0,13,PRICE_HIGH,MODE_MINUSDI,0) && iADX(NULL,0,13,PRICE_HIGH,MODE_MAIN,0)- iADX(NULL,0,13,PRICE_HIGH,MODE_PLUSDI,0)>= 13 && (MA1 < MA2) && OrdersTotal()<1)
     {
      double sell = OrderSend(Symbol(),OP_SELL,lot,Bid,0,0,0,"Sell here",0,0,clrNONE);
      
      if(sell>-1)
         Print("Order executed.");
      else
         Print("Order not executed: ", GetLastError());
     }
   for(i=0; i<OrdersTotal(); i++)
     {                                               
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true )
        {
         if( OrderType()==OP_BUY && MA1<MA2)
           {
            double close_buy = OrderClose(OrderTicket(),OrderLots(),Bid,0,CLR_NONE);
            
            if(close_buy>-1)
               Print("Order executed.");
            else
               Print("Order not executed: ", GetLastError());
           }

         if( OrderType()==OP_SELL && MA1>MA2)
            //double close_sell = OrderClose(OrderTicket(),OrderLots(),Ask,0,CLR_NONE);
           {
            double close_sell = OrderClose(OrderTicket(),OrderLots(),Ask,0,CLR_NONE);
            
            if(close_sell>-1)
               Print("Order executed.");
            else
               Print("Order not executed: ", GetLastError());
           }
        }   
     }
  }