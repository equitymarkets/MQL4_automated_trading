//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
#property copyright "laserdesign.io"
#property link      "https://www.laserdesign.io"
#property version   "1.00"
#property strict

#include <Controls/Button.mqh>
#include <Controls/Label.mqh>
#include <Controls/Edit.mqh>

CButton obj_Btn_MAIN;

CLabel obj_Lbl_HEADER;

CButton obj_Btn_PAIR;
CButton obj_Btn_ASK;
CButton obj_Btn_BID;
CButton obj_Btn_SPREAD;
CButton obj_Btn_BIAS;
CButton obj_Btn_WINLOSS;

CLabel obj_Lbl_ASK;
CLabel obj_Lbl_BID;
CLabel obj_Lbl_SPREAD;
CLabel obj_Lbl_BIAS;

CEdit obj_Edit_PAIR;
CEdit obj_Edit_ASK;
CEdit obj_Edit_BID;
CEdit obj_Edit_SPREAD;
CEdit obj_Edit_BIAS;
CEdit obj_Edit_WINLOSS;

#define Btn_MAIN "Btn_MAIN"

#define Lbl_HEADER "Lbl_HEADER"

#define Btn_PAIR "Btn_PAIR"
#define Btn_ASK "Btn_ASK"
#define Btn_BID "Btn_BID"
#define Btn_SPREAD "Btn_SPREAD"
#define Btn_WINLOSS "Btn_WINLOSS"
#define Btn_BIAS "Btn_BIAS"


#define Edit_PAIR "Edit_PAIR"
#define Edit_ASK "Edit_ASK"
#define Edit_BID "Edit_BID"
#define Edit_SPREAD "Edit_SPREAD"
#define Edit_WINLOSS "Edit_WINLOSS"
#define Edit_BIAS "Edit_BIAS"


//User Input Variables

extern double LotSize = .04;
extern int MagicNumber = 5173926;
extern double TP1Percent = 50;
extern double TP2Percent = 25;
extern double TP1RiskReward = 1.0;
extern double TP2RiskReward = 2.0;


extern int LowTimeframe = 1;
extern int HighTimeframe = 5;

extern int FastMovingAveragePeriod = 21;
extern int SlowMovingAveragePeriod = 50;
extern int MovingAverageType = MODE_EMA;

extern int RSIPeriod = 14;

extern bool VWAPToggle = true;
extern bool SuperTrendToggle = true;

extern bool Stoplosses = true;


extern int SuperTrendPeriod = 10;
input double SuperTrendMultiplier = 4.0;

extern bool EngulfingOrPinToggle = true;
extern double PinWickRatio = 2.0;
extern int EngulfingOrPinTimeframe = 1;

extern bool TimeLimit = false;

extern bool TimeEntry = true;

extern string TradeSession1Start = "14:30";
extern string TradeSession1End = "15:30";

extern string TradeSession2Start = "18:15";
extern string TradeSession2End = "20:00";

extern string TradeSession3Start = "10:30";
extern string TradeSession3End = "11:45";

extern string TradeSession4Start = "06:30"; 
extern string TradeSession4End = "07:40";

//No-Trade Zone Based on Times
extern bool timestampShutoff = false;                        
extern datetime StartDate = D'2025.08.01 00:00:00'; 
extern datetime EndDate = D'2025.08.02 00:00:00'; 

//Win/Loss Ratio
extern int lookbackForWinLoss = 1000; 

//News Stoppage
input string NewsURL          = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
input int    PauseBeforeMins  = 30;   // suspend N minutes BEFORE news
input int    PauseAfterMins   = 30;   // suspend N minutes AFTER news
input bool   AvoidCPI         = true;
input bool   AvoidNFP         = true;
input bool   AvoidFOMC        = true;

//Parabolic SAR Filter

input bool ParabolicSAR = true;
input double ParabolicStep = .02;
input double ParabolicMax = .2;
input int ParabolicCandle = 1;
int IST_Server_Offset_Minutes = -150; // IST → Server offset (IST - 150 mins = server)

//+------------------------------------------------------------------+
//| Utility: Convert "HH:MM" -> minutes since midnight               |
//+------------------------------------------------------------------+
int TimeStringToMinutes(string t)
{
   int hh = StrToInteger(StringSubstr(t,0,2));
   int mm = StrToInteger(StringSubstr(t,3,2));
   return (hh*60 + mm);
}

//+------------------------------------------------------------------+
//| Adjust IST minutes to Server minutes (apply offset)              |
//+------------------------------------------------------------------+
int ISTtoServerMinutes(int minsIST)
{
   int mins = minsIST + IST_Server_Offset_Minutes;

   // Wrap into [0,1440) range
   while(mins < 0) mins += 1440;
   while(mins >= 1440) mins -= 1440;

   return mins;
}

//+------------------------------------------------------------------+
//| Core Function: Weighted Win/Loss Ratio for a Session             |
//+------------------------------------------------------------------+
//double GetSessionWinLossRatio(string startStr, string endStr)
//{
//   // convert IST → server time
//   int startMins = ISTtoServerMinutes(TimeStringToMinutes(startStr));
//   int endMins   = ISTtoServerMinutes(TimeStringToMinutes(endStr));
//
//   double totalWin  = 0.0;
//   double totalLoss = 0.0;
//
//   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
//   {
//      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
//      if(OrderSymbol() != Symbol()) continue;
//      //if(magic != -1 && OrderMagicNumber() != magic) continue;
//
//      datetime ct = OrderCloseTime();
//      if(ct <= 0) continue;
//
//      // extract close time (minutes since midnight, server time)
//      MqlDateTime td;
//      TimeToStruct(ct, td);
//      int mins = td.hour*60 + td.min;
//
//      // check if trade closed during session window
//      bool inSession = false;
//      if(startMins <= endMins) // same-day window
//         inSession = (mins >= startMins && mins <= endMins);
//      else // overnight window (e.g. 22:00–02:00)
//         inSession = (mins >= startMins || mins <= endMins);
//
//      if(!inSession) continue;
//
//      double pl = OrderProfit() + OrderSwap() + OrderCommission();
//      if(pl > 0) totalWin += pl;
//      else if(pl < 0) totalLoss += MathAbs(pl);
//   }
//
//   if(totalLoss == 0)
//   {
//      if(totalWin == 0) return 0.0;   // no trades
//      return DBL_MAX;                 // all wins
//   }
//   return totalWin / totalLoss;
//}

double GetSessionWinLossRatio(string startStr, string endStr)
{
   int startMins = ISTtoServerMinutes(TimeStringToMinutes(startStr));
   int endMins   = ISTtoServerMinutes(TimeStringToMinutes(endStr));

   double totalWin  = 0.0;
   double totalLoss = 0.0;

   // loop history + trades
   for(int mode=0; mode<2; mode++)
   {
      int total = (mode==0) ? OrdersHistoryTotal() : OrdersTotal();
      int selectMode = (mode==0) ? MODE_HISTORY : MODE_TRADES;

      for(int i=total-1; i>=0; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, selectMode)) continue;
         if(OrderSymbol() != Symbol()) continue;
         
         datetime ct = OrderCloseTime();
         if(ct <= 0) continue;   // still open or not finalized

         MqlDateTime td;
         TimeToStruct(ct, td);
         int mins = td.hour*60 + td.min;

         bool inSession = (startMins <= endMins)
                          ? (mins >= startMins && mins <= endMins)
                          : (mins >= startMins || mins <= endMins);

         if(!inSession) continue;

         double pl = OrderProfit() + OrderSwap() + OrderCommission();
         if(pl > 0) totalWin += pl;
         else if(pl < 0) totalLoss += MathAbs(pl);
      }
   }

   if(totalLoss == 0)
   {
      if(totalWin == 0) return 0.0;   // no trades
      return 999.99;                  // all wins
   }
   return totalWin / totalLoss;
}



//+------------------------------------------------------------------+
//| Convenience wrappers for each session (IST inputs)               |
//+------------------------------------------------------------------+
double Session1WinLoss() { return GetSessionWinLossRatio(TradeSession1Start, TradeSession1End); }
double Session2WinLoss() { return GetSessionWinLossRatio(TradeSession2Start, TradeSession2End); }
double Session3WinLoss() { return GetSessionWinLossRatio(TradeSession3Start, TradeSession3End); }
double Session4WinLoss() { return GetSessionWinLossRatio(TradeSession4Start, TradeSession4End); }

//Global Variables  

int SuperTrendTimeframe = PERIOD_M1;
int SuperTrendWickWidth = 1;
int SuperTrendBodyWidth = 2;
bool SuperTrendAutoWidth = true;


double new_lot_size_1,new_lot_size_2,new_lot_size_3;

bool IsWithinShutoffWindow()
{
   datetime now = TimeCurrent();
   return (now > StartDate && now < EndDate);
} 


//Custom functions

//Time Filter
int TimeToMinutes(string t) 
  {
   string parts[];
   int count = StringSplit(t, ':', parts);
   if(count==2)
     {
      int h = int(parts[0]);
      int m = int(parts[1]);
      return h * 60 + m;
     }
   else { Print("Invalid"); return -1; }
  }
  
bool IsISTTimeAllowed() 
  {
   int ISTOffsetMinutes;
   if(AccountCompany()=="Exness Technologies Ltd")
     {
      ISTOffsetMinutes = 330; // India Standard Time = UTC+5:30
     }
   else
     {
      ISTOffsetMinutes = 150; // Standard MT Server Time
     }
   datetime serverTime = TimeCurrent();
   datetime istTime = serverTime + ISTOffsetMinutes * 60;
   
   int currentMinutes = TimeHour(istTime) * 60 + TimeMinute(istTime);
   
   int start1 = TimeToMinutes(TradeSession1Start);
   int end1 = TimeToMinutes(TradeSession1End);
   
   int start2 = TimeToMinutes(TradeSession2Start);
   int end2 = TimeToMinutes(TradeSession2End);
   
   int start3 = TimeToMinutes(TradeSession3Start);
   int end3 = TimeToMinutes(TradeSession3End);
   
   
   int start4 = TimeToMinutes(TradeSession4Start);
   int end4 = TimeToMinutes(TradeSession4End);
   
   if(currentMinutes >= start1 && currentMinutes < end1) 
     {
      return true;
     }
   if(currentMinutes >= start2 && currentMinutes < end2)
     {
      return true;
     }
   if(currentMinutes >= start3 && currentMinutes < end3) 
     {
      return true;
     }
   if(currentMinutes >= start4 && currentMinutes < end4)
     {
      return true;
     }
   return false;
  }

//Checks logic once per bar to save system resources
bool IsNewBar()
{
   static datetime lastbar;
   datetime curbar = iTime(_Symbol, PERIOD_M1, 0);
   if(lastbar != curbar)
   {
      lastbar = curbar;
      return true;
   }
   return false;
}

//M5 Trend Bias
bool MovingAverageCrossover()
  {
   double fast_ma = iMA(_Symbol,HighTimeframe,FastMovingAveragePeriod,0,MovingAverageType,PRICE_CLOSE,1);
   double slow_ma = iMA(_Symbol,HighTimeframe,SlowMovingAveragePeriod,0,MovingAverageType,PRICE_CLOSE,1);
  
   if(fast_ma > slow_ma) { return true; }
   return false;
  }
bool MovingAverageCrossunder()
  {
   double fast_ma = iMA(_Symbol,HighTimeframe,FastMovingAveragePeriod,0,MovingAverageType,PRICE_CLOSE,1);
   double slow_ma = iMA(_Symbol,HighTimeframe,SlowMovingAveragePeriod,0,MovingAverageType,PRICE_CLOSE,1);
     
   if(fast_ma < slow_ma) { return true; }
   return false;
  }

//M1 Price Position
bool UpPricePosition()
  {
   double close_1 = iClose(_Symbol,LowTimeframe,1);
   double low_ma = iMA(_Symbol,LowTimeframe,FastMovingAveragePeriod,0,MovingAverageType,PRICE_CLOSE,1);
   
   if(close_1 > low_ma) { return true; }
   return false;
  }
  
bool DownPricePosition()
  {
   double close_1 = iClose(_Symbol,LowTimeframe,1);
   double low_ma = iMA(_Symbol,LowTimeframe,FastMovingAveragePeriod,0,MovingAverageType,PRICE_CLOSE,1);
   
   if(close_1 < low_ma) { return true; }
   return false;
  }

//RSI Filter
bool RSIFilter() 
  {
   double rsi_value = iRSI(_Symbol,LowTimeframe,RSIPeriod,PRICE_CLOSE,1);
   if(rsi_value > 30 && rsi_value < 70) { return true; }
   return false;
  }

//MACD Filter
bool MACDBull()
  {
   double macd_main = iMACD(_Symbol,LowTimeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_signal = iMACD(_Symbol,LowTimeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);   
   
   if(macd_main > macd_signal) { return true; }
  
   return false;
  }
bool MACDBear()
  {
   double macd_main = iMACD(_Symbol,LowTimeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_signal = iMACD(_Symbol,LowTimeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
  
   if(macd_main < macd_signal) { return true; }
   
   return false;
  }
  
bool VWAPFilterBull() 
  {
   if(iClose(_Symbol,LowTimeframe,1) > iCustom(_Symbol,LowTimeframe,"VWAP",0,1))
     {
      return true;
     }
   return false;
  } 
  
bool VWAPFilterBear()
  {
   if(iClose(_Symbol,LowTimeframe,1) < iCustom(_Symbol,LowTimeframe,"VWAP",0,1))
     {
      return true;
     }
   return false;
  }

bool SuperTrendBull()
  {
   double super_trend_value = iCustom(_Symbol,LowTimeframe,"Supertrend",SuperTrendTimeframe,SuperTrendPeriod,SuperTrendMultiplier,SuperTrendWickWidth,SuperTrendBodyWidth,SuperTrendAutoWidth,7,1);
   
   if(super_trend_value == 1) { return true; }
   
   return false;
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
bool SuperTrendBear()
  {
   double super_trend_value = iCustom(_Symbol,LowTimeframe,"Supertrend",SuperTrendTimeframe,SuperTrendPeriod,SuperTrendMultiplier,SuperTrendWickWidth,SuperTrendBodyWidth,SuperTrendAutoWidth,7,1);

   if(super_trend_value == -1) { return true; }
   
   return false;
  }

//Engulfing Bars 
bool IsEngulfing(int direction, int tf = 0)
  {
   int shift = 1; // last closed candle
   double openPrev = iOpen(Symbol(), tf, shift+1);
   double closePrev = iClose(Symbol(), tf, shift+1);
   double openCurr = iOpen(Symbol(), tf, shift);
   double closeCurr = iClose(Symbol(), tf, shift);

   if(direction == 1) // Bullish Engulfing
     {
      if(closePrev < openPrev && closeCurr > openCurr && closeCurr > openPrev && openCurr < closePrev)
      return true;
     }
   if(direction == -1) // Bearish Engulfing
     {
      if(closePrev > openPrev && closeCurr < openCurr && closeCurr < openPrev && openCurr > closePrev)
      return true;
     }
      return false;
  }
//Pin Bars 
bool IsPinBar(int direction, double wickRatio = 2.0, int tf = 0)
  {
   int shift = 1; // last closed candle
   double highC = iHigh(Symbol(), tf, shift);
   double lowC = iLow(Symbol(), tf, shift);
   double openC = iOpen(Symbol(), tf, shift);
   double closeC= iClose(Symbol(), tf, shift);

   double body = MathAbs(closeC - openC);
   double upperWick = highC - MathMax(openC, closeC);
   double lowerWick = MathMin(openC, closeC) - lowC;

   if(body < Point) body = Point;



   if(direction == 1) // Bullish Pin (long lower wick)
     {
      if(lowerWick/body >= wickRatio && closeC > openC)
      return true;
     }
   if(direction == -1) // Bearish Pin (long upper wick)
     {
      if(upperWick/body >= wickRatio && closeC < openC)
      return true;
     }
   return false;
  }

//double GetWeightedWinLossRatio(int lookbackBars=500)
//{
//   datetime cutoffTime = iTime(Symbol(), PERIOD_CURRENT, lookbackBars);
//   double totalWin = 0.0;
//   double totalLoss = 0.0;
//
//   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
//   {
//      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
//      {
//         if(OrderSymbol() != Symbol()) continue;
//         //if(magic != -1 && OrderMagicNumber() != magic) continue;
//         if(OrderCloseTime() < cutoffTime) continue;
//
//         double pl = OrderProfit() + OrderSwap() + OrderCommission();
//
//         if(pl > 0)
//            totalWin += pl;
//         else if(pl < 0)
//            totalLoss += MathAbs(pl);
//      }
//   }
//
//   if(totalLoss == 0)
//   {
//      if(totalWin == 0) return 0.0;   // no trades
//      return DBL_MAX;                 // all wins, no losses
//   }
//
//   return totalWin / totalLoss;
//}

double GetWeightedWinLossRatio(int lookbackBars=500)
{
   datetime cutoffTime = iTime(Symbol(), PERIOD_CURRENT, lookbackBars);
   double totalWin  = 0.0;
   double totalLoss = 0.0;

   // loop history + trades
   for(int mode=0; mode<2; mode++)
   {
      int total = (mode==0) ? OrdersHistoryTotal() : OrdersTotal();
      int selectMode = (mode==0) ? MODE_HISTORY : MODE_TRADES;

      for(int i=total-1; i>=0; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, selectMode)) continue;
         if(OrderSymbol() != Symbol()) continue;
         // if(magic != -1 && OrderMagicNumber() != magic) continue;

         datetime ct = OrderCloseTime();
         if(ct <= 0) continue;   // skip open trades
         if(ct < cutoffTime) continue;

         double pl = OrderProfit() + OrderSwap() + OrderCommission();
         if(pl > 0)
            totalWin += pl;
         else if(pl < 0)
            totalLoss += MathAbs(pl);
      }
   }

   if(totalLoss == 0)
   {
      if(totalWin == 0) return 0.0;   // no trades
      return 999.99;                  // all wins, no losses
   }

   return totalWin / totalLoss;
}


void DashboardInit() 
  {
    //CONTAINER
   obj_Btn_MAIN.Create(0,Btn_MAIN,0,30,250,0,0);
   obj_Btn_MAIN.Size(195,275);
   obj_Btn_MAIN.ColorBackground(C'00,00,139');
   obj_Btn_MAIN.ColorBorder(clrGreen);
   
   //HEADER LABEL
   obj_Lbl_HEADER.Create(0,Lbl_HEADER,0,35,255,0,0);
   obj_Lbl_HEADER.Text("Trend Momentum Scalper");
   obj_Lbl_HEADER.Color(clrWhite);
   obj_Lbl_HEADER.Font("Times new roman bold");
   obj_Lbl_HEADER.FontSize(11);
   
   //PRICE ID
   obj_Btn_PAIR.Create(0,Btn_PAIR,0,30+5,250+5+30,0,0);
   obj_Btn_PAIR.Size(75,35);
   obj_Btn_PAIR.ColorBackground(clrBlue);
   obj_Btn_PAIR.ColorBorder(clrBlack);
   obj_Btn_PAIR.Text("W/L S1");
   obj_Btn_PAIR.Color(clrWhite);
   
   obj_Btn_ASK.Create(0,Btn_ASK,0,30+5,250+5+35+5+30,0,0);
   obj_Btn_ASK.Size(75,35);
   obj_Btn_ASK.ColorBackground(clrGreen);
   obj_Btn_ASK.ColorBorder(clrBlack);
   obj_Btn_ASK.Text("W/L S2");
   obj_Btn_ASK.Color(clrWhite);
   
   obj_Btn_BID.Create(0,Btn_BID,0,30+5,250+5+35+5+35+5+30,0,0);
   obj_Btn_BID.Size(75,35);
   obj_Btn_BID.ColorBackground(clrRed);
   obj_Btn_BID.ColorBorder(clrBlack);
   obj_Btn_BID.Text("W/L S3");
   obj_Btn_BID.Color(clrWhite);
   
   obj_Btn_SPREAD.Create(0,Btn_SPREAD,0,30+5,250+5+35+5+35+5+30+5+35,0,0);
   obj_Btn_SPREAD.Size(75,35);
   obj_Btn_SPREAD.ColorBackground(clrTeal);
   obj_Btn_SPREAD.ColorBorder(clrBlack);
   obj_Btn_SPREAD.Text("W/L S4");
   obj_Btn_SPREAD.Color(clrWhite);
   
   obj_Btn_WINLOSS.Create(0,Btn_BIAS,0,30+5,250+5+35+5+35+5+30+5+35 + 30 + 5 + 5,0,0);
   obj_Btn_WINLOSS.Size(75,35);
   obj_Btn_WINLOSS.ColorBackground(clrPurple);
   obj_Btn_WINLOSS.ColorBorder(clrBlack);
   obj_Btn_WINLOSS.Text("Total W/L");
   obj_Btn_WINLOSS.Color(clrWhite);
   
   obj_Btn_BIAS.Create(0,Btn_WINLOSS,0,30+5,250+5+35+5+35+5+30+5+35 + 30 + 5 + 5 + 30 + 10,0,0);
   obj_Btn_BIAS.Size(75,35);
   obj_Btn_BIAS.ColorBackground(clrYellow);
   obj_Btn_BIAS.ColorBorder(clrBlack);
   obj_Btn_BIAS.Text("Bias");
   obj_Btn_BIAS.Color(clrBlack);
  } 

void DashboardTick() 
  {
   //PRICE INFO
   obj_Edit_PAIR.Create(0,Edit_PAIR,0,30+5+75+10,250+5+30,0,0);
   obj_Edit_PAIR.Text(string(Session1WinLoss()));
   obj_Edit_PAIR.Size(100,35);
   obj_Edit_PAIR.Color(clrBlack);
   obj_Edit_PAIR.ColorBackground(clrWhite);
   obj_Edit_PAIR.Font("Times new roman bold");
   obj_Edit_PAIR.FontSize(16);
   
   obj_Edit_ASK.Create(0,Edit_ASK,0,30+5+75+10,250+5+35+5+30,0,0);
   obj_Edit_ASK.Text(string(Session2WinLoss()));
   obj_Edit_ASK.Size(100,35);
   obj_Edit_ASK.Color(clrBlack);
   obj_Edit_ASK.ColorBackground(clrWhite);
   obj_Edit_ASK.Font("Times new roman bold");
   obj_Edit_ASK.FontSize(16);

   obj_Edit_BID.Create(0,Edit_BID,0,30+5+75+10,250+5+35+5+35+5+30,0,0);
   obj_Edit_BID.Text(string(Session3WinLoss()));
   obj_Edit_BID.Size(100,35);
   obj_Edit_BID.Color(clrBlack);
   obj_Edit_BID.ColorBackground(clrWhite);
   obj_Edit_BID.Font("Times new roman bold");
   obj_Edit_BID.FontSize(16);
   
   obj_Edit_SPREAD.Create(0,Edit_SPREAD,0,30+5+75+10,250+5+35+5+35+5+30+5+30+5,0,0);
   obj_Edit_SPREAD.Text(string(Session4WinLoss()));
   obj_Edit_SPREAD.Size(100,35);
   obj_Edit_SPREAD.Color(clrBlack);
   obj_Edit_SPREAD.ColorBackground(clrWhite);
   obj_Edit_SPREAD.Font("Times new roman bold");
   obj_Edit_SPREAD.FontSize(16);
   
   
   obj_Edit_WINLOSS.Create(0,Edit_BIAS,0,30+5+75+10,250+5+35+5+35+5+30+5+30+5 + 30 + 5 + 5,0,0);
   obj_Edit_WINLOSS.Text(string(GetWeightedWinLossRatio(lookbackForWinLoss)));
   obj_Edit_WINLOSS.Size(100,35);
   obj_Edit_WINLOSS.Color(clrBlack);
   obj_Edit_WINLOSS.ColorBackground(clrWhite);
   obj_Edit_WINLOSS.Font("Times new roman bold");
   obj_Edit_WINLOSS.FontSize(16);
    
   obj_Edit_BIAS.Create(0,Edit_WINLOSS,0,30+5+75+10,250+5+35+5+35+5+30+5+30+5 + 30 + 5 + 5 + 30 + 10,0,0);
   string bias = MovingAverageCrossover() ? "Bullish" : "Bearish";
   color color_ = MovingAverageCrossover() ? clrGreen : clrRed;
   obj_Edit_BIAS.Text(bias);
   obj_Edit_BIAS.Size(100,35);
   obj_Edit_BIAS.Color(clrWhite);
   obj_Edit_BIAS.ColorBackground(color_);
   obj_Edit_BIAS.Font("Times new roman bold");
   obj_Edit_BIAS.FontSize(16); 

  }

struct NewsEvent {
   datetime time;
   string   title;
   string   impact;
};

NewsEvent events[200];
int newsCount = 0;

void ParseNews(string xml) {
   newsCount = 0;
   while(StringFind(xml, "<event>") != -1 && newsCount < 200) {
      int start = StringFind(xml, "<event>");
      int end   = StringFind(xml, "</event>") + 8;
      string block = StringSubstr(xml, start, end - start);
      xml = StringSubstr(xml, end);

      string title   = ExtractTag(block, "title");
      string impact  = ExtractTag(block, "impact");
      string dateStr = ExtractTag(block, "date");
      string timeStr = ExtractTag(block, "time");

      datetime eventTime = StrToTime(dateStr + " " + timeStr);

      if(StringFind(block, "United States") != -1 && StringFind(impact, "High") != -1) {
         events[newsCount].time   = eventTime;
         events[newsCount].title  = title;
         events[newsCount].impact = impact;
         newsCount++;
      }
   }
}

string ExtractTag(string src, string tag) {
   string open  = "<" + tag + ">";
   string close = "</" + tag + ">";
   int start = StringFind(src, open);
   int end   = StringFind(src, close);
   if(start == -1 || end == -1) return "";
   start += StringLen(open);
   return StringSubstr(src, start, end - start);
}

bool FetchNews() {
   char data[]; 
   char result[];  
   string headers;
   int timeout = 5000;

   int res = WebRequest("GET", NewsURL, "", "", timeout, data, 0, result, headers);

   if(res == -1 || ArraySize(result) == 0) {
      Print("WebRequest failed. Error: ", GetLastError());
      return false;
   }

   string xml = CharArrayToString(result, 0, ArraySize(result));
   ParseNews(xml);
   return (newsCount > 0);
}

bool IsTradingSuspended() {
   datetime now = TimeCurrent();
   for(int i=0; i<newsCount; i++) {
      if(IsRelevant(events[i].title)) {
         datetime startTime = events[i].time - PauseBeforeMins*60;
         datetime endTime   = events[i].time + PauseAfterMins*60;
         if(now >= startTime && now <= endTime) {
            return true;   
         }
      }
   }
   return false;  
}

bool IsRelevant(string title) {
   string t = title;
   StringToUpper(t);

   if (AvoidCPI  && StringFind(t, "CPI")      != -1) return true;
   if (AvoidNFP  && StringFind(t, "NON-FARM") != -1) return true;
   if (AvoidFOMC && StringFind(t, "FOMC")     != -1) return true;

   return false;
}

// Global/static variables
int lastStopOrTPBar = -100; // store bar index when SL/TP was hit


void CheckClosedOrders()
{
   for(int i = OrdersHistoryTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == _Symbol && OrderCloseTime() > 0)
         {
            // Check if order closed by SL or TP
            if(OrderClosePrice() == OrderStopLoss() || OrderClosePrice() == OrderTakeProfit())
            {
               // Store the bar index when it closed
               lastStopOrTPBar = iBarShift(_Symbol, PERIOD_CURRENT, OrderCloseTime(), true);
               break; // only need the most recent
            }
         }
      }
   }
}

bool CheckOpenOrders()
  { 
   for(int i = OrdersTotal()-1; i >= 0; i--) 
     { 
      bool check = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
      if (OrderSymbol() == _Symbol) return(true); 
     } 
      return(false); 
  }

//Parabolic SAR Filters
bool ParabolicSARBuyFilter()
  {
   double SAR = iSAR(_Symbol,LowTimeframe,ParabolicStep,ParabolicMax,ParabolicCandle); 
   //long entry = PSAR < low
   if(SAR < iLow(_Symbol,LowTimeframe,1))
   //if(SAR < Close[1])
     {
      return true;
     }
   return false;
  }
bool ParabolicSARSellFilter()
  { 
   double SAR = iSAR(_Symbol,LowTimeframe,ParabolicStep,ParabolicMax,ParabolicCandle); 
   //short entry = PSAR > high
   if(SAR > iHigh(_Symbol,LowTimeframe,1))
   //if(SAR > Close[1])
     {
      return true;
     }
   return false;
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
int OnInit()
  {
   DashboardInit();
   
   FetchNews(); 
   
   new_lot_size_1 = NormalizeDouble(LotSize * (TP1Percent * .01),3);
   if(TP2Percent > 0)
     {
      new_lot_size_2 = NormalizeDouble(LotSize * (TP2Percent * .01),3);
      new_lot_size_3 = NormalizeDouble(LotSize - (new_lot_size_1 + new_lot_size_2),3);
     }
   else
     {
      new_lot_size_2 = NormalizeDouble((LotSize * (TP1Percent * .01))/2,3);
      new_lot_size_3 = NormalizeDouble((LotSize * (TP1Percent * .01))/2,3);
     }
     
   return(INIT_SUCCEEDED);
  }
  
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
void OnDeinit(const int reason)
  {

   
  }


//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
void OnTick()
  {
   DashboardTick();

   int magic_number_1 = MagicNumber;
   int magic_number_2 = MagicNumber + 2;
   int magic_number_3 = MagicNumber + 4;
   
   int mod;
   double stop_loss, take_profit_1, take_profit_2;

   static datetime trade_time = 0;
   static datetime exit_time = 0; 
   static bool two_minute = true;
   
   static double modified_stop_on_buy_2 = 0; 
   static double modified_stop_on_buy_3 = 0; 
   static double modified_stop_on_sell_2 = 0;
   static double modified_stop_on_sell_3 = 0;
   static bool stage_3 = false;
   
   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY))
     {
      if(_Symbol == OrderSymbol())
        {
         if(TimeCurrent() < (OrderCloseTime() + 120))
           {
            two_minute = false;
           }
         else two_minute = true;
        }
     }
     
   CheckClosedOrders();
   
   if(IsNewBar())
     {
      //Order Close / Modify Loop
      if(CheckOpenOrders())
        {
         for(int i = OrdersTotal()-1; i >= 0; i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol() == _Symbol)
                 {
                  if(OrderMagicNumber() == magic_number_1 || OrderMagicNumber() == magic_number_2 || OrderMagicNumber() == magic_number_3)
                    {
                     
                     if(OrderType()==OP_BUY)
                       {
                        if(MovingAverageCrossunder())
                          {
                           //Close long positions when PSAR flips above price.
                           if(ParabolicSARSellFilter())
                             {
                              if(!EngulfingOrPinToggle || IsEngulfing(-1,EngulfingOrPinTimeframe) || IsPinBar(-1,PinWickRatio))
                                {
                                 int buy_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrBlue);
                                 trade_time = 0;
                                 
                                }
                             }
                          }
                        if(TimeLimit && TimeCurrent() > (trade_time + 900))
                          {
                           int time_close = OrderClose(OrderTicket(),OrderLots(),Bid,0,clrAquamarine);
                           trade_time = 0;
                          }
                        
                        if(!stage_3 && (OrderMagicNumber()==magic_number_2) && (Bid > OrderOpenPrice() + iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP1RiskReward)) 
                          {
                           mod = OrderModify(OrderTicket(),0,OrderOpenPrice() + (10 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_buy_2 = Bid;
                           stage_3 = true;
                          }
                        if(!stage_3 && (OrderMagicNumber()==magic_number_3) && (Bid > OrderOpenPrice() + iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP1RiskReward))
                          {
                           mod = OrderModify(OrderTicket(),0,OrderOpenPrice() + (10 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_buy_3 = Bid;
                          }
                        
                       }
                     if(OrderType()==OP_SELL)
                       {
                        if(MovingAverageCrossover())
                          {
                           //Close short positions when PSAR flips below price.
                           if(ParabolicSARBuyFilter())
                             {
                              if(!EngulfingOrPinToggle || IsEngulfing(1,EngulfingOrPinTimeframe) || IsPinBar(1,PinWickRatio))
                                {
                                 int sell_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrBlue);
                                 trade_time = 0;
                                 //exit_time = TimeCurrent();
                                }
                             }
                          }
                        if(TimeLimit && TimeCurrent() > (trade_time + 900))
                          {
                           int time_close = OrderClose(OrderTicket(),OrderLots(),Ask,0,clrAquamarine);
                           trade_time = 0;
                          }
                        if(!stage_3 && (OrderMagicNumber()==magic_number_2) && (Ask < OrderOpenPrice() - iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP1RiskReward))
                          {
                           mod = OrderModify(OrderTicket(),0,OrderOpenPrice() - (10 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_sell_2 = Ask;
                           stage_3 = true;
                          }
                        if(!stage_3 && (OrderMagicNumber()==magic_number_3) && (Ask < OrderOpenPrice() - iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP1RiskReward))  
                          {
                           mod = OrderModify(OrderTicket(),0,OrderOpenPrice() - (10 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_sell_3 = Ask;
                          }
                       }
                    } 
                 }   
              }
           }
        }
      //Second Modify
      if(stage_3)
        {
         for(int i = OrdersTotal()-1; i >= 0; i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol() == _Symbol)
                 {
                  if(OrderMagicNumber() == magic_number_2 || OrderMagicNumber()== magic_number_3)
                    {
                     if(OrderType()==OP_BUY)
                       {
                        if(Bid > modified_stop_on_buy_2 + (10 * _Point))
                          {
                           mod = OrderModify(OrderTicket(),OrderOpenPrice(),modified_stop_on_buy_2 + (5 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_buy_2 = Bid;
                          }
                        if(Bid > modified_stop_on_buy_3 + (10 * _Point))
                          {
                           mod = OrderModify(OrderTicket(),OrderOpenPrice(),modified_stop_on_buy_3 + (5 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_buy_3 = Bid;
                          }
                       }
                     if(OrderType()==OP_SELL)
                       {
                        if(Ask < modified_stop_on_sell_2 - (10 * _Point))
                          {
                           mod = OrderModify(OrderTicket(),OrderOpenPrice(),modified_stop_on_sell_2 - (5 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_sell_2 = Ask;
                          }
                        if(Ask < modified_stop_on_sell_3 - (10 * _Point))
                          {
                           mod = OrderModify(OrderTicket(),OrderOpenPrice(),modified_stop_on_sell_3 - (5 * _Point),OrderTakeProfit(),0,clrYellow);
                           modified_stop_on_sell_3 = Ask;
                          }
                       }
                    }
                 }
              }
           }
        }     
      //New Order Block
      if(IsTradingSuspended()) 
        {
         Comment("Trading paused due to upcoming US news event.");
        }
      else
        {
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
         if(!CheckOpenOrders() && two_minute==true)
           {
            modified_stop_on_buy_2 = 0;
            modified_stop_on_buy_3 = 0;
            modified_stop_on_sell_2 = 0;
            modified_stop_on_sell_3 = 0;
            stage_3 = false;
              {
               if(!timestampShutoff || !IsWithinShutoffWindow())
                 {
                  if(!TimeEntry || IsISTTimeAllowed())
                    {
                     if(RSIFilter())
                       {
                        if(MovingAverageCrossover())
                          {
                           if(!ParabolicSAR || ParabolicSARBuyFilter())
                             {
                              if(UpPricePosition())
                                {
                                 if(MACDBull())
                                   {
                                    if(!VWAPToggle || VWAPFilterBull())
                                      {
                                       if(!SuperTrendToggle || SuperTrendBull())
                                         {
                                          stop_loss = Stoplosses ? Bid - (iATR(_Symbol,LowTimeframe,14,1) * 1.5) : 0;
                                          take_profit_1 = TP1Percent > 0 ? Ask + iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP1RiskReward : 0;
                                          take_profit_2 = TP2Percent > 0 ? Ask + iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP2RiskReward : 0;
                                          
                                          int buy_trade_1 = OrderSend(_Symbol,OP_BUY,new_lot_size_1,Ask,0,stop_loss,take_profit_1,NULL,magic_number_1,0,clrGreen);
                                          int buy_trade_2 = OrderSend(_Symbol,OP_BUY,new_lot_size_2,Ask,0,stop_loss,take_profit_2,NULL,magic_number_2,0,clrGreen);
                                          int buy_trade_3 = OrderSend(_Symbol,OP_BUY,new_lot_size_3,Ask,0,stop_loss,0,NULL,magic_number_3,0,clrGreen);
                                          trade_time = TimeCurrent();
                                         }
                                      }
                                   }
                                }
                             }
                          }
                        if(MovingAverageCrossunder())
                          {
                           if(!ParabolicSAR || ParabolicSARSellFilter())
                             {
                              if(DownPricePosition())
                                {
                                 if(MACDBear())
                                   {
                                    if(!VWAPToggle || VWAPFilterBear())
                                      {
                                       if(!SuperTrendToggle || SuperTrendBear())
                                         {
                                          stop_loss = Stoplosses ? Ask + (iATR(_Symbol,LowTimeframe,14,1) * 1.5) : 0;
                                          take_profit_1 = TP1Percent > 0 ? Bid - iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP1RiskReward : 0;
                                          take_profit_2 = TP2Percent > 0 ? Bid - iATR(_Symbol,LowTimeframe,14,1) * 1.5 * TP2RiskReward : 0;
                                          
                                          int sell_trade_1 = OrderSend(_Symbol,OP_SELL,new_lot_size_1,Bid,0,stop_loss,take_profit_1,NULL,magic_number_1,0,clrRed);
                                          int sell_trade_2 = OrderSend(_Symbol,OP_SELL,new_lot_size_2,Bid,0,stop_loss,take_profit_2,NULL,magic_number_2,0,clrRed);
                                          int sell_trade_3 = OrderSend(_Symbol,OP_SELL,new_lot_size_3,Bid,0,stop_loss,0,NULL,magic_number_3,0,clrRed);
                                          trade_time = TimeCurrent();
                                         }
                                      }
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              }
           } 
        }
     }
  }
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
