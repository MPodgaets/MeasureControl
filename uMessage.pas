unit uMessage;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants;

const WM_MEASURE_VALUE_INPUT = WM_APP + 1;
      WM_LOGIN = WM_APP + 2;
      WM_NEW_MEASURER = WM_APP + 3;
      WM_CHOICE_MEASURER = WM_APP + 4;
      WM_RECONNECT = WM_APP + 5;
      WM_CREATE_USER = WM_APP + 6;
      WM_MODIFY_USER = WM_APP + 7;
      WM_CLOSE_MEASURER = WM_APP + 8;

implementation

end.
