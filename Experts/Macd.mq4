
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property  indicator_separate_window
#property  indicator_buffers    7
#property  indicator_color1     LimeGreen
#property  indicator_color2     C'0,66,0' //DarkGreen
#property  indicator_color3     Red
#property  indicator_color4     C'83,0,0' //Maroon
#property  indicator_color5     DarkGray
#property  indicator_color6     DodgerBlue
#property  indicator_color7     DarkOrange
#property  indicator_width1     2
#property  indicator_width2     2
#property  indicator_width3     2
#property  indicator_width4     2
#property  indicator_width5     1
#property  indicator_width6     1
#property  indicator_width7     1
#property  indicator_level1     0.0
#property  indicator_levelcolor Gold

//
//
//
//
//

extern string          TimeFrame        = "Current time frame";
extern int             FastMaPeriod     = 12;
extern int             FastMaMode       = 1;
extern int             FastMaPrice      = 0;
extern int             SlowMaPeriod     = 26;
extern int             SlowMaMode       = 1;
extern int             SlowMaPrice      = 0;
extern int             SignalMaPeriod   = 9;
extern int             SignalMaMode     = 1;
extern int             OsmaMultiplier   = 2;
extern bool            HistogramOnSlope = true;
input bool             alertsOn         = true;              // Alerts true/false?
input bool             alertsOnCurrent  = false;             // Alerts open bar true/false?
input bool             alertsMessage    = true;              // Alerts pop-up message true/false?
input bool             alertsSound      = false;             // Alerts sound true/false?
input bool             alertsNotify     = false;             // Alerts push notification true/false?
input bool             alertsEmail      = false;             // Alerts email true/false?
input string           soundFile        = "alert2.wav";      // Sound file
input bool             arrowsVisible    = false;             // Arrows visible true/false?
input bool             arrowsOnNewest   = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string           arrowsIdentifier = "tvi Arrows1";     // Unique ID for arrows
input double           arrowsUpperGap   = 0.5;               // Upper arrow gap
input double           arrowsLowerGap   = 0.5;               // Lower arrow gap
input color            arrowsUpColor    = clrBlue;           // Up arrow color
input color            arrowsDnColor    = clrCrimson;        // Down arrow color
enum  enArrowsUp
      {
         arr_00 = 108,                                       // Ball
         arr_01 = 159,                                       // Dot
         arr_02 = 217,                                       // Fractal up
         arr_03 = 241,                                       // Hollow up
         arr_04 = 246,                                       // Hollow right up
         arr_05 = 225,                                       // Thin up
         arr_06 = 228,                                       // Thin right up
         arr_07 = 233,                                       // Heavy up
         arr_08 = 236,                                       // Heavy right up
         arr_09 = 200,                                       // Curled up
         arr_10 = 221                                        // Up in a circle
      };
input int              arrowsUpCode     = arr_10;            // Up Arrow code
enum  enArrowsDn
      {
         ard_00 = 108,                                       // Ball
         ard_01 = 159,                                       // Dot
         ard_02 = 218,                                       // Fractal down
         ard_03 = 242,                                       // Hollow down
         ard_04 = 248,                                       // Hollow right down
         ard_05 = 226,                                       // Thin down
         ard_06 = 230,                                       // Thin right down
         ard_07 = 234,                                       // Heavy down
         ard_08 = 238,                                       // Heavy right down
         ard_09 = 202,                                       // Curled down
         ard_10 = 222                                        // Down in a circle
      };
input int              arrowsDnCode     = ard_10;            // Down arrow code
input int              arrowsUpSize     = 2;                 // Up arrow size
input int              arrowsDnSize     = 2;                 // Down arrow size

//
//
//
//
//

double osma[];
double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double macd[];
double sig[];
double trend[];
double slope[],valt[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,buffer1);   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buffer2);   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,buffer3);   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,buffer4);   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,osma);
   SetIndexBuffer(5,macd);
   SetIndexBuffer(6,sig);
   SetIndexBuffer(7,valt);
   
   //
   //
   //
   //
   //
   
     FastMaPeriod   = MathMax(FastMaPeriod,1);
     SlowMaPeriod   = MathMax(SlowMaPeriod,1);
     SignalMaPeriod = MathMax(SignalMaPeriod,1); 
     indicatorFileName = WindowExpertName();
     calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
     returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
     timeFrame         = stringToTimeFrame(TimeFrame);
      
   //
   //
   //
   //
   //
   
   IndicatorShortName(timeFrameToString(timeFrame)+"  Macd_Osma ("+FastMaPeriod+","+SlowMaPeriod+","+SignalMaPeriod+")");
   return(0);
}
void OnDeinit(const int reason)
{ 
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
       string objectName = ObjectName(i);
       if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
}


//
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


int start()
  {
   
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit=MathMin(Bars-counted_bars,Bars-1);
         if (returnBars)  { buffer1[0] = limit+1; return(0); }
   
   //
   //
   //
   //
   //
   
  
      
   
   if (calculateValue || timeFrame == Period())
   {
     if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);
     if (ArrayRange(slope,0)!=Bars) ArrayResize(slope,Bars);   
     for(i=limit, r=Bars-i-1; i>=0; i--,r++) macd[i] = iMA(NULL,0,FastMaPeriod,0,FastMaMode,FastMaPrice,i)-iMA(NULL,0,SlowMaPeriod,0,SlowMaMode,SlowMaPrice,i);
     for(i=limit, r=Bars-i-1; i>=0; i--,r++)
         if (SignalMaMode==4)
               sig[i] = iHull(macd[i],SignalMaPeriod,i);
         else  sig[i] = iMAOnArray(macd,Bars,SignalMaPeriod,0,SignalMaMode,i);
     for(i=limit, r=Bars-i-1; i>=0; i--,r++)
     { 
        if (OsmaMultiplier<=0)OsmaMultiplier=1;  
        osma[i]   = (macd[i]-sig[i])*OsmaMultiplier;
        buffer1[i]=EMPTY_VALUE;        
        buffer2[i]=EMPTY_VALUE;       
        buffer3[i]=EMPTY_VALUE;       
        buffer4[i]=EMPTY_VALUE;   
        valt[i] = (macd[i]<0 && macd[i]>sig[i]) ? 1 : (macd[i]>0 && macd[i]<sig[i]) ? -1 : 0; 
        trend[r]  = trend[r-1];
        slope[r]  = slope[r-1];
        
        if (osma[i] > 0)         trend[r] =  1;
        if (osma[i] < 0)         trend[r] = -1;
        if (osma[i] > osma[i+1]) slope[r] =  1;
        if (osma[i] < osma[i+1]) slope[r] = -1;
            
        if (HistogramOnSlope)
        {
          if (trend[r] ==  1 && slope[r] ==  1) buffer1[i] = osma[i];
          if (trend[r] ==  1 && slope[r] == -1) buffer2[i] = osma[i];
          if (trend[r] == -1 && slope[r] == -1) buffer3[i] = osma[i];
          if (trend[r] == -1 && slope[r] ==  1) buffer4[i] = osma[i];
        }
        else
        {                  
          if (trend[r] ==  1) buffer1[i] = osma[i];
          if (trend[r] == -1) buffer3[i] = osma[i];
        }
        
        //
        //
        //
               
         if (arrowsVisible)
         {
            string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
            if (i<(Bars-1) && valt[i] != valt[i+1])
             {
               if (valt[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
               if (valt[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
             }
         }  
   }
   if (alertsOn)
   {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (valt[whichBar] != valt[whichBar+1])
         {
            if (valt[whichBar] == 1) doAlert(" up");
            if (valt[whichBar] ==-1) doAlert(" down");       
         }         
   } 
   return(0);
   } 
        
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
             
          if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);
          if (ArrayRange(slope,0)!=Bars) ArrayResize(slope,Bars);   
          for (i=limit, r=Bars-i-1; i>=0; i--,r++)
          { 
             int y = iBarShift(NULL,timeFrame,Time[i]);
                osma[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastMaPeriod,FastMaMode,FastMaPrice,SlowMaPeriod,SlowMaMode,SlowMaPrice,SignalMaPeriod,SignalMaMode,OsmaMultiplier,HistogramOnSlope,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,4,y);
                macd[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastMaPeriod,FastMaMode,FastMaPrice,SlowMaPeriod,SlowMaMode,SlowMaPrice,SignalMaPeriod,SignalMaMode,OsmaMultiplier,HistogramOnSlope,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,5,y);
                sig[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastMaPeriod,FastMaMode,FastMaPrice,SlowMaPeriod,SlowMaMode,SlowMaPrice,SignalMaPeriod,SignalMaMode,OsmaMultiplier,HistogramOnSlope,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,6,y);
                buffer1[i] = EMPTY_VALUE;
                buffer2[i] = EMPTY_VALUE;
                buffer3[i] = EMPTY_VALUE;
                buffer4[i] = EMPTY_VALUE;
                trend[r]  = trend[r-1];
                slope[r]  = slope[r-1];
        
                if (osma[i] > 0)         trend[r] =  1;
                if (osma[i] < 0)         trend[r] = -1;
                if (osma[i] > osma[i+1]) slope[r] =  1;
                if (osma[i] < osma[i+1]) slope[r] = -1;
            
                if (HistogramOnSlope)
                {
                  if (trend[r] ==  1 && slope[r] ==  1) buffer1[i] = osma[i];
                  if (trend[r] ==  1 && slope[r] == -1) buffer2[i] = osma[i];
                  if (trend[r] == -1 && slope[r] == -1) buffer3[i] = osma[i];
                  if (trend[r] == -1 && slope[r] ==  1) buffer4[i] = osma[i];
                }
                else
                {                  
                  if (trend[r] ==  1) buffer1[i] = osma[i];
                  if (trend[r] == -1) buffer3[i] = osma[i];
                }
   }
 return(0);
 } 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double workHull[][2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars); r=Bars-r-1;

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" macd osma "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" macd osma ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //

      datetime atime = Time[i]; if (arrowsOnNewest) atime += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}     