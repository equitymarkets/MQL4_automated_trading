/*
 L         A      SSSS   EEEEE   RRR     DD    EEEEE   SSSS   IIIII    GG     N   N     IIIII    OO
 L        A A     S      E       R  R    D D   E       S        I     G  G    NN  N       I     O  O
 L       AAAAA     SS    EEE     RRR     D D   EEE      SS      I     G       N NNN       I     O  O
 L      A     A      S   E       R  R    D D   E          S     I     G GG    N  NN       I     O  O
 LLLL  A       A  SSSS   EEEEE   R   R   DD    EEEEE   SSSS   IIIII    GG     N   N  O  IIIII    OO
*/
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891

#property copyright "Copyright 2022, laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"

#define sand 222222
extern double MACD_fast = 12, MACD_slow = 26, MACD_signal = 9;
int array[4];
input int timeframe = 240;
extern int query = 54;
void OrderHistoryTimeUp()
  {
   for(int i = 0; i < OrdersHistoryTotal(); i++)
     {
      bool checker = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        {
           {
            Alert( "Order ", i, " time was ",  OrderCloseTime() - OrderOpenTime());
           }
        }
     }
  }
bool time_to_trade()
  {
   long go_trade = iTime(Symbol(),timeframe,1) + (MathRand()/2.2755);
   if(TimeLocal() >= go_trade) return(true); else return(false);
  }
void OrderHistoryTimeDown()
  {
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      bool checker = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
        {
         Alert( "Order ", i, " time was ",  OrderCloseTime() - OrderOpenTime());
        }
     }
  }
void OpenOrderTime()
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      bool timedecider = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         Alert(i, " - Order open time: ",  OrderOpenTime(), ". Time in seconds: ", TimeCurrent()-OrderOpenTime(),  ". Profit: ", OrderProfit(), ".");
         Sleep(13000);
        }
     }
  }
/*void arrayPush(int & array[] , int dataToPush){
    int count = ArrayResize(array, ArraySize(array) + 1);
    array[ArraySize(array) - 1] = dataToPush;
}*/

/*void arrayPush(int & array[], int dataToPush)
  {
   int count = ArrayResize(array, ArraySize(array) + 1);
   array[ArraySize(array) - 1] = dataToPush;
  }*/
/*void OpenOrderTime()
  {
   int i = OrdersTotal();
   long trades[];
   for(i; i > 0; i--)
     {
      bool timedecider = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         long trade_time = TimeCurrent()-OrderOpenTime();
         trade_time = trades[i];
        }
      Alert(trades[i]);
     }
   
  }
/*double price()
     {
      for(int i = 0; i < 30; i++)
        {
         if(High[i] > High[i-1])
           {
            double High_Price = High[i];
           }
         return(High_Price);
        }
      return(0);
     } */
       
int OnInit()
  {
   /*long volume_array[];
   int volume_array_size = Bars;
   ArrayResize(volume_array,volume_array_size);
   for(int i = 0; i < Bars; i++)
     {
      volume_array[i] = iVolume(Symbol(),240,i);
      
     }*/
   /*double arr[];
   int bar_array_size = Bars;
   ArrayResize(arr,bar_array_size);
      
   for(int i = 1; i < Bars; i++)
     {
      arr[i] = MathAbs(iClose(Symbol(),60,i) - iOpen(Symbol(),60,i));
      Alert(i);
      Alert(arr[i]);
   Sleep(500);
     }
   
   return(INIT_SUCCEEDED);*/
  }

void OnDeinit(const int reason)
  {

   
  }
bool Randomizer()
  {
   //if((TimeCurrent() + MathRand()) > iTime(Symbol(),timeframe,1))
   if(TimeCurrent() + MathRand() > MarketInfo(Symbol(),MODE_TIME))
     {
      return(true);
     }
   return(false);
  }  
/*int OnCalculate(const double& past[])
  {
   return(0);
  }*/

void OnTick()
  {
   /*long volume_array[];
   int volume_array_size = Bars;
   ArrayResize(volume_array,volume_array_size);
   for(int i = 0; i < Bars; i++)
     {
      volume_array[i] = iVolume(Symbol(),240,i);
      //Alert(volume_array[i]);
      
     }
    
   double RSI_array[];
   int RSI_array_size = Bars;
   ArrayResize(RSI_array,RSI_array_size);
   for(int j = 0; j < Bars; j++)
     {
      RSI_array[j] = iRSI(Symbol(),240,14,PRICE_CLOSE,j);
     }

   double MA_array[];
   int MA_array_size = Bars;
   ArrayResize(MA_array,MA_array_size);
   for(int k = 0; k < Bars; k++)
     {
      MA_array[k] = iMA(Symbol(),240,21,0,MODE_SMA,PRICE_CLOSE,k);
     }
 
   long go_trade = iTime(Symbol(),timeframe,1) + (MathRand()/2.28);*/
   /*Alert(MathRand());
   Alert(MathRand()/2.8);
   //Alert(go_trade);
   //Alert(time_to_trade());
   
   
   Alert(TimeCurrent());
   Sleep(9000);*/
   
   //Alert(NormalizeDouble(MathRand()/2.8,0));
   
   //A;LSKJFED
   /*Alert(NormalizeDouble(TimeCurrent() + (MathRand()/2.8),0));
   Alert(TimeCurrent());
   
   Alert(MarketInfo(Symbol(),MODE_TIME));
   Sleep(25000);*/
   //OIWUERKMNVC
   /*int i = 0;
   while(i < 10)
     {
      i++;
      if(i == 6 || i == 8) { continue; }
      if(i == 10)  { break; }
      Alert(i);
      
     }*/
   /*double arr[];
   int bar_array_size = Bars;
   ArrayResize(arr,bar_array_size);
      
   for(int i = 1; i < Bars; i++)
     {
      arr[i] = MathAbs(iClose(Symbol(),60,i)-iOpen(Symbol(),60,i));
     }
   Alert(arr[query]);*/
   Alert(iMACD(Symbol(),timeframe,MACD_fast,MACD_slow,MACD_signal,PRICE_CLOSE,MODE_SIGNAL,0));
   Sleep(4000);
   //iCustom(Symbol(),240,MarketProfile,1,
   /*double times[];
   int input_variable = OrdersTotal();
   ArrayResize(times,input_variable);
   //const double & last[];
   for(int i = 0; i < OrdersTotal(); i++)
     {
      bool time_in_trade = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         times[i] = TimeCurrent() - OrderOpenTime();
           {
            Alert(times[i]);
            
           }
        }
     
     }*/
   
   
   /*double price_1 = iClose(Symbol(),0,1);
     double price_2 = iClose(Symbol(),0,2);
     
     
     Alert(price_1);
     
     Sleep(10000);
     
     ZeroMemory(price_1);
     
     Alert(price_1);
        
     
     
     
     Sleep(10000);
     
     if(price_1 == 0)
        {
         ExpertRemove();
        }*/
     
   //Alert(Money());
   /*Alert(Bars);
   
   for(int i = 0; i <=Bars; i++)
     {
      Alert(High[i]);
      Sleep(10000);
     }
   
   Alert(_LastError);
   Sleep(3000);
   Alert(_Symbol);
   Sleep(3000);
   Alert(High[1]);
   Sleep(3000);
   Alert(Low[1]);
   Sleep(3000);
   ExpertRemove();*/
   //Alert(TimeCurrent());
   /*OrderHistoryTimeUp();
   Sleep(10000);
   OrderHistoryTimeDown();
   Sleep(10000);
   //Comment(iTime(Symbol(),0,0));*/
   
   //OpenOrderTime();
   
  }
//+------------------------------------------------------------------+
