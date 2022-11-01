unit uFirstLoading;

interface

uses
  System.Classes, Datasnap.DBClient, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFirstLoading = class(TThread)
  private
    FProc : TFDStoredProc;
    FConnect : TFDConnection;
    FLog : TStrings;
    FQry: TFDQuery;

    { Private declarations }
  protected
    procedure TestCheck_Date(var aCheck_date : TDateTime);
    procedure CreateFlatMeasurer(aStreet : string; aHouse_number, aFlat_number : integer; aFactory_number : string; aCheck_date, aNext_Check_date : TDateTime);
    function CreateMeasurerFlats : boolean;
    function WriteMeasureValues : boolean;
    procedure Execute; override;

  public
    destructor Destroy; override;
    function Init(const AConnect : TFDConnection; const ALog : TStrings):boolean;
  end;

implementation

uses System.SysUtils, System.DateUtils, DM, Vcl.Forms,
System.Variants;

const max_dif_value = 20; //������������ �������� ��������� �������� �� �����

{ TFirstLoading }

//�������� ��������� � �������
procedure TFirstLoading.CreateFlatMeasurer(aStreet: string; aHouse_number, aFlat_number: integer;
  aFactory_number: string; aCheck_date, aNext_Check_date: TDateTime);
begin
  if Assigned(FProc) then
  with FProc do
  begin
    ParamByName('STREET').AsString := aStreet;
    ParamByName('HOUSE_NUMBER').AsInteger := aHouse_number;
    ParamByName('FLAT_NUMBER').AsInteger := aFlat_number;
    ParamByName('FACTORY_NUMBER_NEW').AsString := aFactory_number;
    ParamByName('INSTALL_DATE').AsDate := aCheck_date + 14;
    ParamByName('CHECK_DATE').AsDate := aCheck_date;
    ParamByName('NEXT_CHECK_DATE').AsDate := aNext_Check_date;
  end;
end;

function TFirstLoading.CreateMeasurerFlats: boolean;
var lstStreet : array [1..7] of string;
  i, j, k, measurer_count : integer;
  stFactory_number : string;
  DayCheck, DayNextCheck : TDateTime;
  yDayCheck, mDayCheck, dDayCheck : word;

begin
  Result := False;
  //�������� ������ ����
  lstStreet[1] := '��. ����';
  lstStreet[2] := '��. �������';
  lstStreet[3] := '��. ��������������';
  lstStreet[4] := '��. ������';
  lstStreet[5] := '��. �������';
  lstStreet[6] := '�. �����������';
  lstStreet[7] := '��. ���������';

  try
    //�������� ����������� � ��
    if not FConnect.Connected then
      FConnect.Open();

    //������� �������� ���������
    FProc.StoredProcName := 'CHANGE$MEASURER';
    //�������� ������ ����������
    FProc.Prepare;
    //������� ���
    FLog.Clear;

    //������� �������� � ��������
    for i := 1 to 7 do     //not terminated
    begin
      //����
      for j := 1 to 100 do
      begin
      //��������
        for k := 1 to 80 do
        begin
          stFactory_number := Format('00%d000%d000%d00',[i,j,k]);
          //������� ��������� ���� �������
          DayCheck := EncodeDate(2019, 1, 14) + Random(340);
          TestCheck_Date(DayCheck);
          //������� ��������� ���� �������, ������ ������� = 3 ����
          DecodeDate(DayCheck,yDayCheck, mDayCheck, dDayCheck);
          DayNextCheck := EncodeDate(yDayCheck + 3, mDayCheck, dDayCheck);
          //�������� ���� ��������� �������
          TestCheck_Date(DayNextCheck);
          //��������� ��������� ���������
          CreateFlatMeasurer(lstStreet[i],j, k, stFactory_number,
            DayCheck, DayNextCheck);
          //�������� ������� � ��������
          try
            FConnect.StartTransaction;
            FProc.ExecProc;
            //��������� ���������� �������� � �������� ������� � ���
            FLog.Add('Street = ' + lstStreet[i] + ', house_number = ' + IntToStr(j) +
            ', flat_number = ' + IntToStr(k) +', ID =' +
            FProc.ParamByName('ID$STR').AsString + ', Error = ' +
            FProc.ParamByName('ERROR$STR').AsString);
            if FConnect.InTransaction then
              FConnect.Commit;
          except
            if FConnect.InTransaction then
              FConnect.Rollback;
            raise;
          end;
        end;
      end;
    end;

    measurer_count := 0;
    //������� ������ ��������
    while measurer_count < 1000 do
    begin
      //��������� ������ �����
      i := 1 + Random(7);
      //��������� ����� ����
      j := 1 + Random(100);
      //��������� ����� ��������
      k := 1 + Random(80);
      //��������� ����� ��������
      stFactory_number := Format('0%d00%d000%d0000',[i,j,k]);
      //������� ��������� ���� �������
      DayCheck := EncodeDate(2019, 1, 14) + Random(340);
      TestCheck_Date(DayCheck);
      //������� ��������� ���� �������, ������ ������� = 3 ����
      DecodeDate(DayCheck,yDayCheck, mDayCheck, dDayCheck);
      DayNextCheck := EncodeDate(yDayCheck + 3, mDayCheck, dDayCheck);
      TestCheck_Date(DayNextCheck);
      try
        FConnect.StartTransaction;
        FProc.ExecProc;
        //��������� �������� ����������
        CreateFlatMeasurer(lstStreet[i],j, k, stFactory_number, DayCheck, DayNextCheck);
        //��������� ���������� �������� � �������� ������� � ���
        FLog.Add('Street = ' + lstStreet[i] + ', house_number = ' + IntToStr(j) +
        ', flat_number = ' + IntToStr(k) +', ID =' +
        FProc.ParamByName('ID$STR').AsString + ', Error = ' +
        FProc.ParamByName('ERROR$STR').AsString);
        if FConnect.InTransaction then
          FConnect.Commit;

        Inc(measurer_count);
      except
        if FConnect.InTransaction then
          FConnect.Rollback;
        raise;
      end;
    end;

    Result := True;
  except
    on e: EDatabaseError do
      Synchronize(
        procedure
        begin
          Application.MessageBox('������ ������� � ���� ������','������!', 0);
        end);
  end;
end;

destructor TFirstLoading.Destroy;
begin
  if Assigned(Fproc) then Fproc.Free;
  if Assigned(FQry) then FQry.Free;
  if Assigned(FConnect) then FConnect.Free;
  inherited;
end;

procedure TFirstLoading.Execute;
begin
  //�������� ��������
 // CreateMeasurerFlats;
 // FLog.SaveToFile('CreateMeasureFlats.txt', TEncoding.UTF8);
  //������� ��������� ���������
  WriteMeasureValues;
 // FLog.SaveToFile('WriteMeasureValues.txt', TEncoding.UTF8);
end;

function TFirstLoading.Init(const AConnect: TFDConnection; const ALog: TStrings):boolean;
begin
  Result := False;
  try
    if Assigned(ALog) then
      FLog := ALog;
    if Assigned(AConnect) then
    begin
      FConnect := TFDConnection(AConnect.CloneConnection);
      FConnect.LoginPrompt := False;
      FQry := TFDQuery.Create(nil);
      FQry.Connection := FConnect;
      Fproc := TFDStoredProc.Create(nil);
      Fproc.Connection := FConnect;
      Result := True;
    end;
  except
    on e: EDatabaseError do
      Synchronize(
        procedure
        begin
          Application.MessageBox('������ ������� � ���� ������','������!', 0);
        end);
  end;
end;

procedure TFirstLoading.TestCheck_Date(var aCheck_date: TDateTime);
begin
  //�������� �� ��������� �� ��������
  if DayOfWeek(aCheck_date) > 5 then
    aCheck_date := aCheck_date - DayOfWeek(aCheck_date) + 5;
  //�������� ��������� �� ���������
  if (aCheck_date = EncodeDate(2019, 2, 22)) or
    (aCheck_date = EncodeDate(2019, 3, 8)) or
    (aCheck_date = EncodeDate(2019, 6, 12)) then
      aCheck_date := aCheck_date - 1
  else
   if (aCheck_date > EncodeDate(2019, 4, 30)) and
    (aCheck_date < EncodeDate(2019, 5, 14))
    then aCheck_date := EncodeDate(2019, 4, 30)
    else
    if aCheck_date = EncodeDate(2019, 11, 4)
      then aCheck_date := aCheck_date + 1;
end;

function TFirstLoading.WriteMeasureValues: boolean;
var idmeasurer : String;
    {dtNext_Check_date,} dtValue_date : TDateTime;
    y, m, d : word;
    measure_value : single;
    error_str, id_str : String;

begin
  Result := False;
  try
    //�������� ����������� � ��
    if not FConnect.Connected then
      FConnect.Open();

    FProc.StoredProcName := 'MEASURE$VALUE$NEW';
    //�������� ������ ����������
    FProc.Prepare;
    //������� ���
    FLog.Clear;

    FQry.SQL.Text :=
    'select ID, FACTORY_NUMBER, CHECK_DATE, NEXT_CHECK_DATE from VWMEASURERS';

    if FQry.Active then
     FQry.Close;
    FQry.Open;
    try
      //���� �� ���������
      with FQry do
      begin
        First;
        while not Eof or not self.Terminated do
        begin
          //id ��������
          idmeasurer := FieldByName('ID').AsString;
          //���� ������� dtCheck_date
          dtValue_date := FieldByName('CHECK_DATE').AsDateTime;
          if DayOfTheMonth(dtValue_date) > 26 then
          //���� ������� ���� � ����� ������, �� ��������� ����� � ���������
            dtValue_date := dtValue_date + 14;

          //���� ��������� �������
          //dtNext_Check_date := FieldByName('NEXT_CHECK_DATE').AsDateTime;
          //�������������� ��������� ��������
          measure_value := 0;
          //����� �������� ��������� ��������� ������� � ���������� ����� ������,
          //� ������� ���� ������� �� ������� ����
          DecodeDate(dtValue_date, y, m, d);

          while dtValue_date < Date + 31 do  //dtNext_Check_date + 31 do
          begin
            //�������� ���� ������ ��������� - ��������� ���� ������
            if m < 12 then m := m +1
            else
            begin
              y := y + 1;
              m := 1;
            end;
            dtValue_date := EncodeDate(y, m, 1) - 1;
            //�������� ��������� �������� ��������� ��������
            measure_value := measure_value + max_dif_value*Random;
            with FProc do
            begin
            //������� ��������� ���������
              ParamByName('IDMEASURER$STR').AsString := idmeasurer;
              ParamByName('MEASURE$DATE').AsDateTime := dtValue_date;
              ParamByName('MEASURE$VALUE').AsSingle := measure_value;
            end;
            try
              FConnect.StartTransaction;
              FProc.ExecProc;
              FConnect.Commit;
              //��������� ���������� �������� � �������� ������� � ���
              if FProc.ParamByName('ID$STR').IsNull then id_str := ''
                else id_str := FProc.ParamByName('ID$STR').AsString;
              if FProc.ParamByName('ERROR$STR').IsNull then error_str := ''
              else error_str := FProc.ParamByName('ERROR$STR').AsString;

              Queue(procedure
              begin
                FLog.Add('ID = ' + id_str + ', Error = ' + error_str);
              end);
            except
              on E : EVariantTypeCastError do
              Synchronize(
                procedure
                begin
                  Application.MessageBox(PChar('������ �������������� �����: ' +
                  e.Message), '������', 0);
                end);
              else
              if FConnect.InTransaction then
                  FConnect.Rollback;
              raise;
            end;
            //dtValue_date := dtValue_date + 27;
          end;
          Next;
        end;
      end;
    finally
      FQry.Close;
    end;
  except
    on e: EDatabaseError do
      Synchronize(
        procedure
        begin
         Application.MessageBox(PChar('������ ������� � ���� ������: ' +
         e.Message), '������', 0);
        end);
  end;
end;

end.
