//+------------------------------------------------------------------+
//|                                                       tester.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
     /*double price_0 = iClose(Symbol(),1,0);
     double price_1 = iClose(Symbol(),1,1);
     double price_2 = iClose(Symbol(),1,2);*/
     
     /*double MACD_0_sig = iMACD(Symbol(),60,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
     double MACD_0_main = iMACD(Symbol(),60,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
     
     Alert(MACD_0_sig);
     Alert(MACD_0_main);*/
     /*static short k = 5;
     if(price_1 > price_2) k++;
     else k--;*/
     int k = (rand()%(240 * 60));
     
     Alert(k);
     Sleep(2000);
     /*Sleep(10000);
     
     ZeroMemory(price_1);
     
     Alert(price_1);
        
     
     
     
     Sleep(10000);
     
     if(price_1 == 0)
        {
         ExpertRemove();
        }*/
     
    
  }
//+------------------------------------------------------------------+
