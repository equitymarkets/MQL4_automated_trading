//+------------------------------------------------------------------+
//|                                         Demo_FileWriteStruct.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- show the window of input parameters when launching the script
#property script_show_inputs
#property strict
//--- parameters for receiving data from the terminal
input string          InpSymbolName="EURUSD";           // currency pair
input ENUM_TIMEFRAMES InpSymbolPeriod=PERIOD_H1;        // time frame
input datetime        InpDateStart=D'2013.01.01 00:00'; // data copying start date
//--- parameters for writing data to the file
input string          InpFileName="EURUSD.txt";         // file name
input string          InpDirectoryName="Data";          // directory name
//+------------------------------------------------------------------+
//| Structure for storing candlestick data                           |
//+------------------------------------------------------------------+
struct candlesticks
  {
   double            open;  // open price
   double            close; // close price
   double            high;  // high price
   double            low;   // low price
   datetime          date;  // date
  };
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   datetime     date_finish=TimeCurrent();
   int          size;
   datetime     time_buff[];
   double       open_buff[];
   double       close_buff[];
   double       high_buff[];
   double       low_buff[];
   candlesticks cand_buff[];
//--- reset the error value
   ResetLastError();
//--- receive the time of the arrival of the bars from the range
   if(CopyTime(InpSymbolName,InpSymbolPeriod,InpDateStart,date_finish,time_buff)==-1)
     {
      PrintFormat("Failed to copy time values. Error code = %d",GetLastError());
      return;
     }
//--- receive high prices of the bars from the range
   if(CopyHigh(InpSymbolName,InpSymbolPeriod,InpDateStart,date_finish,high_buff)==-1)
     {
      PrintFormat("Failed to copy values of high prices. Error code = %d",GetLastError());
      return;
     }
//--- receive low prices of the bars from the range
   if(CopyLow(InpSymbolName,InpSymbolPeriod,InpDateStart,date_finish,low_buff)==-1)
     {
      PrintFormat("Failed to copy values of low prices. Error code = %d",GetLastError());
      return;
     }
//--- receive open prices of the bars from the range
   if(CopyOpen(InpSymbolName,InpSymbolPeriod,InpDateStart,date_finish,open_buff)==-1)
     {
      PrintFormat("Failed to copy values of open prices. Error code = %d",GetLastError());
      return;
     }
//--- receive close prices of the bars from the range
   if(CopyClose(InpSymbolName,InpSymbolPeriod,InpDateStart,date_finish,close_buff)==-1)
     {
      PrintFormat("Failed to copy values of close prices. Error code = %d",GetLastError());
      return;
     }
//--- define dimension of the arrays
   size=ArraySize(time_buff);
//--- save all data in the structure array
   ArrayResize(cand_buff,size);
   for(int i=0;i<size;i++)
     {
      cand_buff[i].open=open_buff[i];
      cand_buff[i].close=close_buff[i];
      cand_buff[i].high=high_buff[i];
      cand_buff[i].low=low_buff[i];
      cand_buff[i].date=time_buff[i];
     }
//--- open the file for writing the structure array to the file (if the file is absent, it will be created automatically)
   ResetLastError();
   int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is open for writing",InpFileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_COMMONDATA_PATH));
      //--- prepare the counter of the number of bytes
      uint counter=0;
      //--- write array values in the loop
      for(int i=0;i<size;i++)
        {
         uint byteswritten=FileWriteStruct(file_handle,cand_buff[i]);
         //--- check the number of bytes written
         if(byteswritten!=sizeof(candlesticks))
           {
            PrintFormat("Error read data. Error code=%d",GetLastError());
            //--- close the file
            FileClose(file_handle);
            return;
           }
         else
            counter+=byteswritten;
        }
      PrintFormat("%d bytes of information is written to %s file",InpFileName,counter);
      PrintFormat("Total number of bytes: %d * %d * %d = %d, %s",size,5,8,size*5*8,size*5*8==counter ? "Correct" : "Error");
      //--- close the file
      FileClose(file_handle);
      PrintFormat("Data is written, %s file is closed",InpFileName);
     }
   else
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
  }
