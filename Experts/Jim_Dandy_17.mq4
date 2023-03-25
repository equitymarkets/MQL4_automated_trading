//+------------------------------------------------------------------+
//|                                  Jim Dandy Moving Average EA.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
extern int TakeProfit=500; 
extern int StopLoss=150;
extern double LotSize = .01;

extern bool UseMoveToBreakeven=true;
extern int WhenToMoveToBE=100;
extern int PipsToLockIn=5;

extern bool UseTrailingStop=true;
extern int WhenToTrail=200;
extern int TrailAmount=200;
extern bool UseCandleTrail=false;
extern int PadAmount=10;
extern int StopCandle=3;
extern int CandlesBack=5;
extern int FastMA=5;
extern int FastMaShift=0;
extern int FastMaMethod=1;
extern int FastMaAppliedTo=0;

extern int SlowMA=21;
extern int SlowMaShift=0;
extern int SlowMaMethod=0;
extern int SlowMaAppliedTo=0;

extern int MagicNumber = 1234;
double pips;

                   




void OnInit()
  {
   double ticksize = MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize == 0.00001 || ticksize == 0.001)
   pips = ticksize*10;
   else pips = ticksize;
  }

int deinit()
  {

   return(0);
  }

void OnTick()
  {
   if(OpenOrdersThisPair(Symbol())>=1)
     {
      if(UseMoveToBreakeven)MoveToBreakeven();
      if(UseTrailingStop)AdjustTrail();
     }
   if(IsNewCandle())CheckForMaTrade();  
   
  
  }

void MoveToBreakeven()
  {
   for(int b=OrdersTotal()-1; b>=0; b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber)   
            if(OrderType()==OP_BUY)
               if(Bid-OrderOpenPrice()>WhenToMoveToBE*pips)
                  if(OrderOpenPrice()>OrderStopLoss())
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PipsToLockIn*pips),OrderTakeProfit(),0,clrNONE);
     }   
  

   for (int s=OrdersTotal()-1; s >= 0; s--)
     {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()== MagicNumber)
            if(OrderSymbol()==Symbol())
               if(OrderType()==OP_SELL)
                  if(OrderOpenPrice()-Ask>WhenToMoveToBE*pips)
                     if(OrderOpenPrice()<OrderStopLoss())
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PipsToLockIn*pips),OrderTakeProfit(),0,clrNONE);
     }
  }  
bool IsNewCandle()
  {
   static int BarsOnChart=0;
   if (Bars == BarsOnChart)
   return (false);
   BarsOnChart = Bars;
   return(true);
  }

void CheckForMaTrade()
  {
   double FourHourMa = iMA(NULL,240, FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,2);
   double PreviousFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,2);
   double CurrentFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,1);
   double PreviousSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,2);
   double CurrentSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,1);
   if(PreviousFast<PreviousSlow && CurrentFast>CurrentSlow &&Bid>FourHourMa) OrderEntry(0);
  }

void OrderEntry(int direction)
  {
   if(direction==0)
      if(OpenOrdersThisPair(Symbol())==0)
         OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,Ask-(StopLoss*pips),Ask+(TakeProfit*pips),NULL,MagicNumber,0,Green);
   if(direction==0)
      if(OpenOrdersThisPair(Symbol())==0)
         OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,Bid+(StopLoss*pips),Bid-(TakeProfit*pips),NULL,MagicNumber,0,Red);
  }
  
int OpenOrdersThisPair (string pair)
  {
   int total=0;
   for(int i=OrdersTotal()-1; i >= 0; i--)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==pair) total++;
     }
     return(total);
  } 
void AdjustTrail()   
  {
   for(int b=OrdersTotal()-1; b>=0;b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
            if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
               if(OrderMagicNumber()==MagicNumber)
                  if(OrderSymbol()==Symbol())
                     if(OrderType()==OP_BUY)
                        if(Bid-OrderOpenPrice()>WhenToTrail*pips)
                           if(OrderStopLoss()<Bid-pips*TrailAmount)
                              OrderModify(OrderTicket(),OrderOpenPrice()),
     //sell order section
     for(int s=OrdersTotal()-1; s>=0; s--)
      {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber)
            if(OrderSymbol()==Symbol())
               if(OrderType()==OP_SELL)
                  if(UseCandleTrail)
                    {
                     if(IsNewCandle())
                        if(OrderStopLoss()>High[sellStopCandle]+PadAmount*pips)
                           OrderModify(OrderTicket(),OrderOpenPrice(),High[sellStopCandle]+PadAmount*pips,OrderTakeProfit(),0,clrNONE);
                    }     
                  else
                  if(OrderOpenPrice()-Ask>WhenToTrail*pips)
                     if(OrderStopLoss()>Ask+TrailAmount*pips)
                        OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(TrailAmount*pips),OrderTakeProfit(),0,clrNONE);
        }               
     }
                        
                         