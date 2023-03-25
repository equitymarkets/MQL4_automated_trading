#define     MName       "Constant Range Channel"
#define     MVersion    "1.0"
#define     MBuild      "2022-05-11 11:31 WEST"
#define     MCopyright  "Copyright \x00A9 2022"
#define     MProfile    "https//www.mql5.com/en/users/FMIC"

#property   strict 
#property   version     MVersion     
#property   description "Metatrader Indicator (Build "MBuild")"
#property   copyright   MCopyright
#property   link        MProfile

#property indicator_chart_window

#define  MPlots    3
#define  MBuffers  3
#ifndef  __MQL4__
   #property indicator_buffers   MBuffers
   #property indicator_plots     MPlots
#else 
   #property indicator_buffers   MPlots
#endif 

#define     MClrUpper         C'38, 166,154'
#define     MClrMiddle        C'239,166,154'
#define     MClrLower         C'239, 83, 80'
#property   indicator_label1  "Upper"
#property   indicator_label2  "Middle"
#property   indicator_label3  "Lower"
#property   indicator_color1  MClrUpper
#property   indicator_color2  MClrMiddle
#property   indicator_color3  MClrLower
#property   indicator_width1  1
#property   indicator_width2  1
#property   indicator_width3  1
#property   indicator_style1  STYLE_SOLID
#property   indicator_style2  STYLE_DOT
#property   indicator_style3  STYLE_SOLID
#property   indicator_type1   DRAW_LINE
#property   indicator_type2   DRAW_LINE
#property   indicator_type3   DRAW_LINE

input uint i_nStepTicks = 50;

#ifdef __MQL4__
      #define MOnCalcNext( _index ) ( _index--)
      #define MOnCalcBack( _index, _offset ) ( _index + _offset )
      #define MOnCalcCheck( _index ) ( _index >= 0 )
      #define MOnCalcValid ( _index ) ( _index < rates_total ) 
      #define MOnCalcStart \ 
         ( rates_total - prev_calculated < 1 ? 1 : prev_calculated ) )
      
      #define MOnCalcNext ( _index ) ( _index++ )
      #define MOnCalcBack ( _index ) ( _index - _offset )
      #define MOnCalcCheck( _index ) ( _index < rates_total )
      #define MOnCalcValid( _index ) ( _index >= 0 )
      #define MOnCalcStart \
         ( prev_calculated < 1 ? 0 : prev_calculated - 1 )
         
      #endif 
      
      #define MCheckParameter( _condition, text ) if( _condition ) \
         { Print( "Error: Invalid ", _text ); return INIT_PARAMETERS_INCORRECT; }
         
      
      
      double
         g_dbStepRange,
         g_adbUpper[],
         g_adbMiddle[],
         g_adbLower[];
         
      int OnInit(void)  
        {
         MCheckParameter( i_nStepTicks < 1, "Range step size!" );
         
         g_dbStepRange = WRONG_VALUE;
         
         IndicatorSetInteger( INDICATOR_DIGITS, _Digits );
         
         #ifdef _MQL4_
            IndicatorBuffers( MBuffers );
            
         #endif 
         int iBuffer = 0;
         SetIndexBuffer( iBuffer++, g_adbUpper, INDICATOR_DATA );
         SetIndexBuffer( iBuffer++, g_adbMiddle, INDICATOR_DATA);
         SetIndexBuffer( iBuffer++, g_adbLower, INDICATOR_DATA);
         
         IndicatorSetString( INDICATOR_SHORTNAME,
            MName + "(" + (string) i_nStepTicks + ")" );
         return INIT_SUCCEEDED;    
        };
//34567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891
      int OnCalculate(
         const int      rates_total,
         const int      prev_calculated,
         const datetime &time[],
         const double   &open[],
         const double   &high[],
         const double   &low[],
         const double   &close[],
         const long     &tick_volume[],
         const long     &volume[],
         const int      &spread[]
         )
        {
         if (( g_dbStepRange < 0) && (rates_total > 0 ))
         
           {
            double dbTickSize = WRONG_VALUE;
            if( SymbolInfoDouble( _Symbol, SYMBOL_TRADE_TICK_SIZE, dbTickSize ) && (dbTickSize > 0))
               g_dbStepRange = dbTickSize * i_nStepTicks;
            else return 0;
           }; 
         for( int iCur = MOnCalcStart, iPrev = MOnCalcBack( iCur, 1 );
            !IsStopped() && MOnCalcCheck ( iCur );
            MOnCalcNext( iCur ), MOnCalcNext( iPrev ))
            
           {
            double dbLow   = low[ iCur ],
                  dbHigh   = high[ iCur ],
                  dbMiddle = MOnCalcValid( iPrev )
                           ? (dbLow > g_adbUpper[ iPrev ] ? dbLow
                              : dbHigh < g_adbLower [ iPrev ] ? dbHigh : g_adbMiddle[ iPrev ] )
                           : close[ iCur ];        
            g_adbMiddle[ iCur ] = dbMiddle;
            g_adbUpper[ iCur ] = dbMiddle + g_dbStepRange;
            g_adbLower[ iCur ] = dbMiddle - g_dbStepRange;
           };
         return rates_total;
     };                              