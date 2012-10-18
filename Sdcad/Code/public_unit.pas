unit public_unit;
interface

uses Graphics,SysUtils,forms,windows,messages,DB, ADODB,
     stdctrls,comctrls,Classes, dialogs,
     Grids,
      rxToolEdit, rxCurrEdit, math, strUtils, Inifiles;

const HINT_TEXT         :PAnsiChar='��ʾ';
const TABLE_ERROR       :PAnsiChar='���ݿ�������޷��������ݣ�';
const DBERR_NOTSAVE     :PAnsiChar='���ݿ�����޷�����/�������ݣ�';
const DBERR_NOTREAD     :PAnsiChar='���ݿ�����޷���ȷ��ȡ���ݣ�';
const DBERR_NOTDEL      :PAnsiChar='���ݿ�����޷�ɾ�����ݣ�';
const DEL_CONFIRM       :PAnsiChar='ȷ��ɾ����ǰ��¼��';
const REPORT_SUCCESS    :PAnsiChar='�ɹ����ɾ��㱨����';
const REPORT_FAIL       :PAnsiChar='���㱨������ʧ�ܣ�';
const REPORT_OPEN_FAIL  :PAnsiChar='���㱨����ʧ�ܣ�';
const EXCEL_NOTINSTALL  :PAnsiChar='δ��װExcel!';
const REPORT_PROCCESS   :PAnsiChar='�������ɾ��㱨�������Ժ�...';
const FILE_SAVE_TITLE   :PAnsiChar='���㱨������';
const FILE_SAVE_TITLE_GZL :PAnsiChar='������ͳ�Ʊ�����';
const FILE_SAVE_FILTER  :PAnsiChar='Excel�ļ�(*.csv;*.xls)|*.xls;*.csv|Excel�ļ�(*.xls)|*.xls|Excel�ļ�(*.csv)|*.csv';
const FILE_NOTEXIST     :PAnsiChar='�ļ������ڣ�';
const FILE_EXIST        :PAnsiChar='�ļ��Ѿ����ڣ��Ƿ񸲸Ǹ��ļ���';
const FILE_DELERR       :PAnsiChar='�޷�ɾ��(����)�ļ���';
const EXCEL_ERROR       :PAnsiChar='EXCEL�����г������޷����ɱ�����';
const REPORT_TITLE      :String   ='�������̿�������';
const BACKUP_PROJECT_FILE_EXT:string='bak';

const REPORT_PRINT_SPLIT_CHAR: string='^'; //
//Ϊ����Ӧ�����Ա�������Ҫ����дINI�ļ�ʱ��
//�������������ļӷָ��������ģ����磺������^plain fill

type TTongJiFlags = set of (tfTuYang, tfJingTan, tfBiaoGuan, tfTeShuYang, tfTeShuYangBiaoZhuZhi, tfOther);

//����������tezhengshuTmp��v_id�ֶζ�Ӧ��ֵ
const TEZHENSHU_Flag_PingJunZhi : string='1';
const TEZHENSHU_Flag_BiaoZhunCha: string='2';
const TEZHENSHU_Flag_BianYiXiShu: string='3';
const TEZHENSHU_Flag_MaxValue   : string='4';
const TEZHENSHU_Flag_MinValue   : string='5';
const TEZHENSHU_Flag_SampleNum  : string='6';
const TEZHENSHU_Flag_BiaoZhunZhi: string='7';

//���������ݱ��д����Ƿ���ֶζ�Ӧ��ֵ�����ǣ�ֵ��0������ֵ��1��
const BOOLEAN_True : string = '0';
const BOOLEAN_False: string = '1';

type
  TAnalyzeResult=record
    PingJunZhi: double; //ƽ��ֵ
    BiaoZhunCha: double;//��׼��
    BianYiXiShu: double;//����ϵ��
    MaxValue: double;//���ֵ
    MinValue: double;//��Сֵ
    SampleNum: integer;//������
    BiaoZhunZhi:double;//��׼ֵ
    FormatString: string; //��ʽ���ַ�,��'0.00','0.0'
    lstValues: TStringList; //�������е�ֵ�������������ã���Ϊ�в���������ֵ�ᱻ����ֵ������Ҫ����һ��StringList������ͬ����ֵ��
    lstValuesForPrint: TStringList;
    FieldName: String;  //
    //�ֶ��������������ֲ��ܱ�������������ʱ����Ϊ�й����޳�������ѹ��Ҫ����������ǣ��������ļ�����Բ����ֵ
//yys 2005/06/15 add, ��һ��ֻ��һ����ʱ����׼��ͱ���ϵ������Ϊ0����ӡ����ʱҪ�ÿո�������ѧ��Ҳһ����
    //strBiaoZhunCha: string;
    //strBianYiXiShu: string;
//yys 2005/06/15
  end;

//������ӡʱ�����ԣ���ʱ�����ĺ�Ӣ������
type TReportLanguage =(trChineseReport, trEnglishReport); //

const GongMinJian ='0'; //����
const LuQiao ='1'; //·��

const JiZuanQuTuKong = '1'; ////����ȡ����

//��ӡ��MiniCAD��ͼ����ı����ı�ʶ
const PrintChart_Section         :PAnsiChar='1'; //���̵�������ͼ
const PrintChart_ZhuZhuangTu     :PAnsiChar='2'; //�����״ͼ ����
const PrintChart_CPT_ShuangQiao  :PAnsiChar='3'; //˫����׾�����̽�ɹ���
const PrintChart_Buzhitu         :PAnsiChar='4'; //���̿����ƽ�沼��ͼ
const PrintChart_Legend          :PAnsiChar='5'; //ͼ����ӡ
const PrintChart_CrossBoard      :PAnsiChar='6'; //ʮ�ְ������������ͼ
const PrintChart_CPT_DanQiao     :PAnsiChar='7'; //������׾�����̽�ɹ���
const PrintChart_FenCengYaSuo    :PAnsiChar='8'; //�ֲ�ѹ������
const PrintChart_ZhuZhuangTuZhiFangTu     :PAnsiChar='9'; ////�����״ͼ,��ֱ��ͼ��ʽ ����
const PrintChart_ZhuZhuangTuShuangDa2        :PAnsiChar='10'; ////�����״ͼ,��ֱ��ͼ��ʽ �����ײ��Ŵ�ӡ
const PrintChart_ZhuZhuangTuShuangDa1        :PAnsiChar='11'; ////�����״ͼ,��ֱ��ͼ��ʽ ���ײ��Ŵ�ӡ

type
  TProjectInfo=class(TObject)
  private
    FPrj_no: string;
    FPrj_no_ForSQL: string;
    FPrj_name: string;
    FPrj_name_en:string;
    FPrj_type: string;
    FPrj_ReportLanguage: TReportLanguage;
    FPrj_ReportLanguageString: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure setProjectInfo(aPrj_no,aPrj_name,aPrj_name_en,aPrj_type: string);
    procedure setReportLanguage(aReportLanguage: TReportLanguage);
    property prj_no :string read FPrj_no;       //���̱��
    property prj_no_ForSQL:string read FPrj_no_ForSQL; //���̱�ţ�Ϊ�˲������ݿ��У��滻���������̱���еĵ�����
    property prj_name:string read FPrj_name;      //��������
    property prj_name_en:string read FPrj_name_en;      //����Ӣ������
    property prj_type:string read FPrj_type;      //��������
    property prj_ReportLanguage: TReportLanguage read FPrj_ReportLanguage;
    property prj_ReportLanguage_String: string read FPrj_ReportLanguageString;
end;

type TZKLXBianHao=record  //������ͱ��
  ShuangQiao: string;  //˫�ű��
  DanQiao   : string;  //���ű��
  XiaoZuanKong:string; //С������ף�Ҳ�����黨�꣩
  end;  

type TAppInfo=record
  PathOfReports: string;     //�����ļ���ŵ�·��
  PathOfChartFile: string;  //����ͼ�ȵ��ı��ļ����·��
  CadExeName: string;        //��CADͼ��Ӧ�ó����·��+������(f:\minicad.exe)
  CadExeNameEn:string;       //��CADͼ��Ӧ�ó����·��+Ӣ�ĳ�����(f:\minicad_en.exe)
  PathOfIniFile: string;    //Server.ini �ļ��Ĵ��·��(f:\server.ini)
end;
const g_cptIncreaseDepth=0.1;  //������̽ÿ�ν�������Ϊ0.1m

var
  g_ProjectInfo : TProjectInfo; //���浱ǰ�򿪵Ĺ��̵Ĺ�����Ϣ
  //g_Project_no:string;  //���浱ǰ�򿪵Ĺ��̵Ĺ��̱��
  g_AppInfo : TAppInfo; //����Ӧ�ó����һЩ��Ϣ��
  g_ZKLXBianHao: TZKLXBianHao;  //����������ͱ��е���ױ��

  //�������ϵ�����Label��Transparent������ΪTrue
  procedure setLabelsTransparent(aForm: TForm);
  //�����ڴ����ϵİ�����ͬ���ı佹��λ�á�
  procedure change_focus(key:word;frmCurrent: TCustomForm);
  //ɾ��һ��StringGrid��һ�С�
  procedure DeleteStringGridRow(aStringGrid:TStringGrid;aRow:integer);
  
  //��������һЩ���͵Ŀؼ����ݣ���Edit.Text='',ComboBox.ItemIndex=-1
  procedure Clear_Data(frmCurrent: TCustomForm);
  
  //���ƴ����һЩ�ؼ����ò����á�
  procedure Enable_Components(frmCurrent:TCustomForm;bEnable:boolean);

  //AlignGridCell,�ı�StringGrid��ĳһCELL�е�����ˮƽ�������з�ʽ,ͬʱ�ڴ�ֱ�������.
  procedure AlignGridCell(AStringGrid:TObject;ACol, ARow:Integer;
   ARect: TRect; Alignment: TAlignment);
  
  //�������ݿ��ɾ�������ӡ��޸Ĳ�����
  function Delete_oneRecord(aADOQuery: TADOQuery;strSQL:string):boolean;
  function Update_oneRecord(aADOQuery: TADOQuery;strSQL:string):boolean;
  function Insert_oneRecord(aADOQuery: TADOQuery;strSQL:string):boolean;
  //�ж�һ�ʼ�¼�����ݿ����Ƿ���ڡ�
  function isExistedRecord(aADOQuery: TADOQuery;strSQL:string): boolean; 

  //NumberKeyPress ����edit�ؼ��ĵ����룬edit�е�����ֻ���������򸡵�����.
  //Senderһ��ΪTEdit�ؼ���KeyΪ���µļ�ֵ,yunshufuhao�Ƿ��������븺��
  procedure NumberKeyPress(Sender: TObject;var Key: Char; yunshufuhao : boolean);

  //��ʮ�������ַ���ת��ΪTBits
  function HexToBits(aStr:string):TBits;
  //���Էָ����ֿ����ַ����ֿ�����StringList�С�
  procedure DivideString(str,separate:string;var str_list:TStringList);
  
  //���Էָ����ֿ����ַ����ֿ�����StringList��,����Ϊ�յ��ַ���������.
  //��'1,2,,3'����ַ�������������̷ֿ��Ļ���õ�һ�������е�StringList
  procedure DivideStringNoEmpty(str,separate:string;var str_list:TStringList);
  function isFloat(ANumber: string): boolean;
  function isInteger(ANumber: string): boolean;
  procedure SetListBoxHorizonbar(aListBox: TCustomListBox);
  
  //�ж�һ������һ���ַ����б��е�λ�ã�������λ��ֵ��-1--��ʾ�б���û�д˴���
  function PosStrInList(aStrList:TStrings;aStr:string):integer;

  //����һ���ַ�������һ���ַ����������ֵ�λ��
  function PosRightEx(const SubStr,S:AnsiString;const Offset:Cardinal=MaxInt):Integer;

  function ComSrtring(aValue,aLen:integer):string;
  function ReopenQryFAcount(aQuery:tadoquery;aSQLStr:string):boolean;
  function SumMoney(aADOQry:tadoquery;aFieldName:string):double;
  procedure EditFormat(aEdit:tedit);
  procedure SetCBWidth(aCBox:tcombobox);

  function getCadExcuteName: string;
  //getCptAverageByDrill
  //�Ӿ�̽���м���һ���׵�ÿһ���qc��fs��ƽ��ֵ�������������ַ����У�ÿ��ֵ�ö��Ÿ���
  procedure getCptAverageByDrill(aDrillNo:string;var aQcAverage,aFsAverage:
  string);
  function AddFuHao(aStr:string):string;
  procedure FenXiFenCeng_TuYiangJiSuan;
  procedure FenXiFenCeng_TeShuYiangJiSuan;
  //������汾�� Delphi Pascal �������У�Round �������� CPU �� FPU (���㲿��) ������Ϊ�����ġ�
  //���ִ�������������ν�� "���м����뷨"�������м�ֵ (�� 5.5��6.5) ʵʩ Round ����ʱ��
  //����������С����ǰ���ֵ��桢ż����ȷ����������� 5.5 Round ���Ϊ 6���� 6.5 Round ���ҲΪ 6, ��Ϊ 6 ��ż����
  function DoRound(Value: Extended):Int64;

  function iif(ATest: Boolean; const ATrue: Integer; const AFalse: Integer): Integer; overload;
  function iif(ATest: Boolean; const ATrue: string;  const AFalse: string): string; overload;
  function iif(ATest: Boolean; const ATrue: Boolean; const AFalse: Boolean): Boolean; overload;


implementation

uses MainDM,SdCadMath;

//Delphi �� Round ����ʹ�õ������м��㷨(Banker's Rounding)
//Round() �Ľ������ͨ�������ϵ���������
//If X is exactly halfway between two whole numbers,
//the result is always the even number.
//���� XXX.5 �������������������������ô�� Round Up��ż���� Round Down�����磺
//x:= Round(17.5) �൱�� x = 18
//x:= Round(12.5) �൱�� x = 12
//���������봦��ʱ��ʹ�� DRound �������� Round
function DoRound(Value: Extended): Int64;
begin
  if Value >= 0 then Result := Trunc(Value + 0.5)
  else Result := Trunc(Value - 0.5);
end;

function iif(ATest: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
begin
  if ATest then begin
    Result := ATrue;
  end else begin
    Result := AFalse;
  end;
end;

function iif(ATest: Boolean; const ATrue: string; const AFalse: string): string;
begin
  if ATest then begin
    Result := ATrue;
  end else begin
    Result := AFalse;
  end;
end;

function iif(ATest: Boolean; const ATrue: Boolean; const AFalse: Boolean): Boolean;
begin
  if ATest then begin
    Result := ATrue;
  end else begin
    Result := AFalse;
  end;
end;

function getCadExcuteName: string;
begin
  if g_ProjectInfo.prj_ReportLanguage= trChineseReport then
    result := g_AppInfo.CadExeName
  else if g_ProjectInfo.prj_ReportLanguage= trEnglishReport then
    result := g_AppInfo.CadExeNameEn;
end;

procedure setLabelsTransparent(aForm: TForm);
var
  i: integer;
  myComponent: TComponent;
begin
  for i:=0 to aForm.ComponentCount-1 do
  begin
    myComponent:= aForm.Components[i]; 
    if myComponent is TLabel then
      TLabel(myComponent).Transparent := True;    
  end;
end;

//�����س������¼�ͷʱ�ƶ���굽��һ�ؼ������ϼ�ͷʱ�ƶ���굽��һ�ؼ���
procedure change_focus(key:word;frmCurrent: TCustomForm);
begin
  if (key=VK_DOWN) or (key=VK_RETURN) then
    postMessage(frmCurrent.Handle, wm_NextDlgCtl,0,0);
  if key=VK_UP then
    postmessage(frmCurrent.handle,wm_nextdlgctl,1,0);
end;

procedure DeleteStringGridRow(aStringGrid:TStringGrid;aRow:integer);
const
 MaxColCount=100; //һ��˵����������StringGrid���г���100�У�
                       //����������Ϊ��ʱ�������г�����ColCount,ɾ������ʱ����ȫ;
var
  iCol, iRow:integer;
begin
  if (aRow<1) or (aRow>aStringGrid.RowCount-1) then exit;
  if aStringGrid.RowCount =2 then
  begin
    for iCol:= 0 to MaxColCount do
      aStringGrid.cells[iCol,1] :=''; 
    exit;
  end; 
  if aRow <> aStringGrid.RowCount -1 then
    for iRow := aRow to aStringGrid.RowCount  - 2 do
      for iCol:= 0 to MaxColCount -1 do
        aStringGrid.Cells[iCol,iRow] := aStringGrid.Cells[iCol,iRow+1];
  aStringGrid.RowCount := aStringGrid.RowCount -1;
end;

procedure Clear_Data(frmCurrent: TCustomForm);
var 
  i: integer;
begin
  with frmCurrent do
    for i:=0 to frmCurrent.ComponentCount-1 do
      begin
        if components[i] is TEdit then
          TEdit(components[i]).text:=''
        else if components[i] is TComboBox then
            TComboBox(components[i]).ItemIndex := -1
        else if components[i] is TMemo then
          TMemo(components[i]).Text := ''          
        else if components[i] is TCurrencyEdit then
          TCurrencyEdit(components[i]).Text := ''          
        else if components[i] is TDateTimePicker then
          TDateTimePicker(components[i]).Date :=Now; 
      end;
end;

procedure Enable_Components(frmCurrent:TCustomForm;bEnable:boolean);
var 
  i: integer;
begin
  with frmCurrent do
    for i:=0 to frmCurrent.ComponentCount-1 do
      begin
        if components[i] is TEdit then
          TEdit(components[i]).Enabled := bEnable
        else if components[i] is TCurrencyEdit then
          TCurrencyEdit(components[i]).Enabled := bEnable
        else if components[i] is TComboBox then
          TComboBox(components[i]).Enabled := bEnable
        else if components[i] is TMemo then
          TMemo(components[i]).Enabled := bEnable
        else if components[i] is TListBox then
          TListBox(components[i]).Enabled := bEnable
        else if components[i] is TDateTimePicker then
          TDateTimePicker(components[i]).Enabled :=bEnable
        else if components[i] is TRadioButton then
          TRadioButton(components[i]).Enabled := bEnable
        else if components[i] is TCheckBox then
          TCheckBox(components[i]).Enabled := bEnable
        else if components[i] is TLabel then
          TLabel(components[i]).Enabled := bEnable;

      end;
end;

function Delete_oneRecord(aADOQuery: TADOQuery;strSQL: string): boolean;
begin
  with aADOQuery do
    begin
      close;
      sql.Clear;
      sql.Add(strSQL);

      try
        try
          ExecSQL;
          //MessageBox(application.Handle,'ɾ���ɹ���','ɾ������',MB_OK+MB_ICONINFORMATION);
          result := true;
        except
          MessageBox(application.Handle,'���ݿ���󣬲���ɾ����ѡ���ݡ�','���ݿ����',MB_OK+MB_ICONERROR);
          result := false;
        end;
      finally
        close;
      end;
    end;
end;

function Update_oneRecord(aADOQuery: TADOQuery;strSQL:string):boolean;
begin
  with aADOQuery do
    begin
      close;
      sql.Clear;
      sql.Add(strSQL);
      try
        try
          ExecSQL;
          //MessageBox(application.Handle,'�������ݳɹ���','��������',MB_OK+MB_ICONINFORMATION);
          result := true;
        except
          //MessageBox(application.Handle,'���ݿ���󣬸�������ʧ�ܡ�','���ݿ����',MB_OK+MB_ICONERROR);
          result:= false;
        end;
      finally
        close;
      end;
    end;
end;

function Insert_oneRecord(aADOQuery: TADOQuery;strSQL:string):boolean;
var
  ini_file:TInifile;
begin
  with aADOQuery do
    begin
      close;
      sql.Clear;
      sql.Add(strSQL);
      try
        try
          ExecSQL;
          //MessageBox(application.Handle,'�������ݳɹ���','��������',MB_OK+MB_ICONINFORMATION);
          result := true;
        except
          MessageBox(application.Handle,'���ݿ������������ʧ�ܡ�','���ݿ����',MB_OK+MB_ICONERROR);
  ini_file := TInifile.Create(g_AppInfo.PathOfIniFile);
  ini_file.WriteString('SQL','error',strSQL);
  ini_file.Free;
          result:= false;
        end;
      finally
        close;
      end;
    end;
end;


function isExistedRecord(aADOQuery: TADOQuery;strSQL:string): boolean;
begin
  with aADOQuery do
    begin
      close;
      sql.Clear;
      sql.Add(strSQL);
      try
        try
          Open;
          if eof then 
            result:=false
          else
            result:=true;
        except
          result:=false;
        end;
      finally
        close;
      end;
    end;  
end;

procedure NumberKeyPress(Sender: TObject;var Key: Char; yunshufuhao : boolean);
var
  strHead,strEnd,strAll,strFraction:string;
  iDecimalSeparator:integer;
  
begin
  //�����������ֱ�����ε�С���㡣
  if (TEdit(Sender).Tag=0) and (key='.') then
  begin
    key:=#0;
    exit;
  end;
  //���ε����š�
  if (not yunshufuhao) and (key='-') then 
  begin
    key:=#0;
    exit;
  end;
  //���ε���ѧ��������
  if (lowercase(key)='e') or (key=' ') or(key='+') then
  begin
    key:=#0;
    exit;
  end;

  if key =chr(vk_back) then exit;
  
  try
    strHead := copy(TEdit(Sender).Text,1,TEdit(Sender).SelStart);
    strEnd  := copy(TEdit(Sender).Text,TEdit(Sender).SelStart+TEdit(Sender).SelLength+1,length(TEdit(Sender).Text));
    strAll := strHead+key+strEnd;
    
    if (strAll)='-' then
      begin
         TEdit(Sender).Text :='-';
         TEdit(Sender).SelStart :=2;
         key:=#0;
         exit;
      end;
      
    strtofloat(strAll);
    iDecimalSeparator:= pos('.',strAll);
    if iDecimalSeparator>0 then
      begin
        strFraction:= copy(strall,iDecimalSeparator+1,length(strall));
        if (iDecimalSeparator>0) and (length(strFraction)>TEdit(Sender).Tag) then
          key:=#0;
      end;
  except
    key:=#0;
  end;

end;

function HexToBits(aStr:string):TBits;
var
   i,data,j,rst,inx,l:integer;
   aBits:TBits;
   c:char;
begin
   aBits:=TBits.Create ;
   aBits.Size :=1024;
   inx:=0;
   l:=length(aStr);
   for i:=1 to l do
   begin
      c:=aStr[i];
      case c of
         'f','F':data:=15;
         'e','E':data:=14;
         'd','D':data:=13;
         'c','C':data:=12;
         'b','B':data:=11;
         'a','A':data:=10
      else
         data:=byte(c)-48;
      end;
      rst:=data;
      for j:=0 to 3 do
         begin
         if rst mod 2=1 then
            aBits[inx+3-j]:=true
         else
            aBits[inx+3-j]:=false;
         rst:=rst Div 2;
         end;
      inx:=inx+4;
   end;
   result:=aBits;
end;

//���Էָ����ֿ����ַ����ֿ�����StringList�С�
procedure DivideString(str,separate:string;var str_list:TStringList);
var
  position:integer;
  strTemp:string;
begin
  str_list.Clear;
  while length(str)>0 do
  begin
    position:=pos(separate,str);
    if position=0 then position:=length(str)+1;
    strTemp:=copy(str,1,position-1);
    str_list.Add(trim(strTemp));
    delete(str,1,position);
  end;
end;


procedure DivideStringNoEmpty(str,separate:string;var str_list:TStringList);
var
  position:integer;
  strTemp:string;
begin
  str_list.Clear;
  while length(trim(str))>0 do
  begin
    position:=pos(separate,str);
    if position=0 then position:=length(str)+1;
    strTemp:=copy(str,1,position-1);
    if length(trim(strTemp))>0 then
      str_list.Add(trim(strTemp));
    delete(str,1,position);
  end;
end;

function isFloat(ANumber: string): boolean;
begin
  result:= true;
  try
    StrToFloat(ANumber);
  except
    result:= false;
  end;
end;

function isInteger(ANumber: string): boolean;
begin
  result:= true;
  try
    StrToInt(ANumber);
  except
    result:= false;
  end;
end;

procedure AlignGridCell(AStringGrid:TObject;ACol, ARow:Integer;
   ARect: TRect; Alignment: TAlignment);
var
  strText:String; 
  iLeft,iTop:integer;
begin
  With AStringGrid as TStringGrid do 
  begin
    strText:=Cells[ACol,ARow]; 
    Canvas.FillRect(ARect);
     
    iTop := ARect.Top +(ARect.bottom-ARect.top-Canvas.TextHeight(strText)) shr 1;
    case Alignment of
      taLeftJustify:
        iLeft := ARect.Left + 2;
      taRightJustify:
        iLeft := ARect.Right - Canvas.TextWidth(strText) - 3;
      else { taCenter }
        iLeft := ARect.Left + (ARect.Right - ARect.Left) shr 1
          - (Canvas.TextWidth(strText) shr 1);
    end;
    Canvas.TextOut(iLeft,iTop,strText);
  end;
end;
procedure SetListBoxHorizonbar(aListBox: TCustomListBox);
var 
  i, MaxWidth: integer;
begin
  MaxWidth:=0;
  for i:=0 to aListBox.Count-1 do
    MaxWidth:=Max(MaxWidth,aListBox.Canvas.TextWidth(aListBox.Items[i]));
  SendMessage(aListBox.Handle, LB_SETHORIZONTALEXTENT, MaxWidth+4, 0);
      
end;

function PosRightEx(const SubStr,S:AnsiString;const Offset:Cardinal=MaxInt):Integer;
var
  iPos: Integer;
  i, j,Len,LenS,LenSub: Integer;
  PCharS, PCharSub: PChar;
begin
  Result := 0;
  LenS:=Length(S);
  lenSub := length(Substr);
  if (LenS=0) Or (lenSub=0) then Exit;
  if Offset<LenSub then Exit;

  PCharS := PChar(s);
  PCharSub := PChar(Substr);

  Len:=Offset;
  if Len>LenS then
     Len:=LenS;

  for I := Len-1 downto 0 do
  begin
    if I<LenSub-1 then Exit;
    for j := lenSub - 1 downto 0 do
    if PCharS[i -lenSub+j+1] <> PCharSub[j] then
      break
    else if J=0 then
    begin
      Result:=I-lenSub+2;
      Exit;
    end;
  end;
end;

function PosStrInList(aStrList:TStrings;aStr:string):integer;
var
   i,j:integer;
begin
   j:=-1;
   for i:=0 to aStrList.Count-1 do
   if aStrList[i]=aStr then
      begin
      j:=i;
      break;
      end;
   result:=j;
end;

//�����ݱ� �����ؽ��true--�ɹ�,false--ʧ��
function ReopenQryFAcount(aQuery:tadoquery;aSQLStr:string):boolean;
begin
   aQuery.Close ;
   aQuery.SQL.Clear ;
   aQuery.SQL.Add(aSQLStr);
   try
      aQuery.Open ;
   except
      result:=false;
      exit;
   end;
   result:=true;
end;
function ComSrtring(aValue,aLen:integer):string;
var
   aStr:string;
   slen,i:integer;
begin
   aStr:=inttostr(aValue);
   slen:=length(aStr);
   for i:=1 to aLen-slen do
      aStr:='0'+aStr;
   result:=aStr;
end;
//�ֶ�ֵ���
function SumMoney(aADOQry:tadoquery;aFieldName:string):double;
var
   asum:double;
   aBMark:tbookmark;
begin
   aSum:=0;
   aBMark:=aADOQry.GetBookmark;
   aADOQry.First ;
   while not aADOQry.Eof do
      begin
      aSum:=aSum+aADOQry.fieldbyname(aFieldName).AsFloat;
      aADOQry.Next ;
      end;
   aADOQry.GotoBookmark(aBMark);
   result:=asum;
end;

procedure SetCBWidth(aCBox:tcombobox);
var
   i,maxLen:integer;
begin
   maxLen:=0;
   for i:=0 to acbox.Items.Count-1 do
      if aCBox.Canvas.TextWidth(aCBox.Items[i])>maxLen then maxLen:=aCBox.Canvas.TextWidth(aCBox.Items[i]);
   sendmessage(aCBox.Handle,CB_SETDROPPEDWIDTH,maxLen+55,0);
end;

procedure EditFormat(aEdit:tedit);
begin
   if aEdit.Width>80 then
      aEdit.Text :=stringofchar(' ',((aEdit.Width DIV 6)-length(trim(aEdit.Text)))*2-2)+trim(aEdit.Text)
   else
      aEdit.Text :=stringofchar(' ',((aEdit.Width DIV 6)-length(trim(aEdit.Text)))*2-1)+trim(aEdit.Text);
end;


{ TProjectInfo }

constructor TProjectInfo.Create;
begin
    inherited Create;
    FPrj_ReportLanguage := trChineseReport;
end;

destructor TProjectInfo.Destroy;
begin

  inherited;
end;

procedure TProjectInfo.setProjectInfo(aPrj_no, aPrj_name,aPrj_name_en,
  aPrj_type: string);
begin
  FPrj_no := aPrj_no;
  FPrj_name := aPrj_name;
  FPrj_name_en := aPrj_name_en;
  FPrj_type := aPrj_type;
  FPrj_no_ForSQL := stringReplace(aPrj_no ,'''','''''',[rfReplaceAll]);
end;

procedure TProjectInfo.setReportLanguage(aReportLanguage: TReportLanguage);
begin
  FPrj_ReportLanguage := aReportLanguage;
  if aReportLanguage = trChineseReport then
    FPrj_ReportLanguageString  := 'cn'
  else if aReportLanguage = trEnglishReport then
    FPrj_ReportLanguageString  := 'en';
    
end;

procedure getCptAverageByDrill(aDrillNo:string;var aQcAverage,aFsAverage: string);
var
  iStratumCount,i,j, iCanJoinJiSuanCount:integer;     //iCanJoinJiSuanCount �ܲμӼ����ÿ�����ݵĸ�������Ϊһ�����治һ���У�����/0.1����ô�����ݣ�����Ϊ�յ�����Ҫȥ��
  dBottom: double;
  strSQL, strTmp: string;
  lstStratumNo,lstSubNo,
  lstStratumDepth,lstStratumBottDepth:TStringList;

  strQcAll,strFsAll: String;  //����׶�������Ͳ��Ħ�����������ַ�����
  qcList,fsList: TStringList; //����׶�������Ͳ��Ħ����
  dBeginDepth,dEndDepth:double; //���濪ʼ��Ⱥͽ������
  dqcTotal, dfsTotal, dqcAverage,dfsAverage: double;

  procedure GetStramDepth(const aDrillNo: string;
   var AStratumNoList, ASubNoList, ABottList: TStringList);
  begin
    AStratumNoList.Clear;
    ASubNoList.Clear;
    ABottList.Clear;
    strSQL:='select drl_no,stra_no,sub_no, stra_depth '
        +' FROM stratum ' 
        +' WHERE '
        +' prj_no='+''''+g_ProjectInfo.prj_no_ForSQL+''''
        +' AND drl_no ='+''''+aDrillNo+''''
        +' ORDER BY stra_depth';
        //+' ORDER BY d.drl_no,s.top_elev';
    with MainDataModule.qryStratum do
      begin
        close;
        sql.Clear;
        sql.Add(strSQL);
        open;
        while not eof do
          begin
            AStratumNoList.Add(FieldByName('stra_no').AsString);
            ASubNoList.Add(FieldByName('sub_no').AsString);
            ABottList.Add(FieldByName('stra_depth').AsString);
            next; 
          end;
        close;
      end;
  end;
  procedure FreeStringList;
  begin
    lstStratumNo.Free;
    lstSubNo.Free;
    lstStratumDepth.Free;
    lstStratumBottDepth.Free;
    qcList.Free;
    fsList.Free;
  end;
  
begin

  lstStratumNo:= TStringList.Create;
  lstSubNo:= TStringList.Create;
  lstStratumDepth:= TStringList.Create;
  lstStratumBottDepth:= TStringList.Create;  
  qcList:= TStringList.Create;
  fsList:= TStringList.Create;
  dBeginDepth:=0;
  dEndDepth:=0;
  try      
    GetStramDepth(aDrillNo,
      lstStratumNo, lstSubNo, lstStratumBottDepth);
    if lstStratumNo.Count =0 then exit;

    //��ʼȡ�þ�����̽�����ݡ�
    qcList.Clear;
    fsList.Clear; 
    strSQL:='SELECT prj_no,drl_no,begin_depth,end_depth,qc,fs '
             +'FROM cpt '
             +' WHERE prj_no=' +''''+g_ProjectInfo.prj_no_ForSQL +''''
             +' AND drl_no='  +''''+aDrillNo+'''';
    with MainDataModule.qryCPT do
      begin
        close;
        sql.Clear;
        sql.Add(strSQL);
        open;
        i:=0;
        if not Eof then
          begin
            i:=i+1;
            strQcAll := FieldByName('qc').AsString;
            strFsAll := FieldByName('fs').AsString;
            dBeginDepth := FieldByName('begin_depth').AsFloat;
            dEndDepth := FieldByName('end_depth').AsFloat;
            Next ;
          end;
        close;
      end;
    if i>0 then
    begin
      DivideString(strQcAll,',',qcList);
      DivideString(strFsAll,',',fsList);  
    end
    else
      exit; 

    //��ʼ�ֲ�,�����㚰���qc��fs��ƽ��ֵ
    for iStratumCount:=0 to lstStratumNo.Count -1 do
    begin
      dBottom:= strtofloat(lstStratumBottDepth.Strings[iStratumCount]);
      if (dBottom-dBeginDepth)>=g_cptIncreaseDepth then
      begin
        if dEndDepth>dBottom then
          j:= round((dBottom - dBeginDepth) / g_cptIncreaseDepth)
        else
          j:= round((dEndDepth - dBeginDepth) / g_cptIncreaseDepth);
        dqcTotal:=0;
        dfsTotal:=0;
        iCanJoinJiSuanCount := 0;
        for i:= 1 to j do
        begin
          strTmp:= trim(qcList.Strings[0]);
          if isFloat(strTmp) then
          begin
            dqcTotal:= dqcTotal + strtofloat(strTmp);
            iCanJoinJiSuanCount := iCanJoinJiSuanCount +1;
          end;
          if qcList.Count>0 then
            qcList.Delete(0);
          if fsList.Count>0 then
          begin
            strTmp:= trim(fsList.Strings[0]);
            if isFloat(strTmp) then
              dfsTotal:= dfsTotal + strtofloat(strTmp);
            fsList.Delete(0);
          end;
        end;
        if iCanJoinJiSuanCount > 0 then
        begin
          dqcAverage:= dqcToTal / iCanJoinJiSuanCount;
          dfsAverage:= dfsToTal / iCanJoinJiSuanCount;
          aQcAverage:= aQcAverage + FormatFloat('0.00',dqcAverage) + ',';
          aFsAverage:= aFsAverage + FormatFloat('0.00',dfsAverage) + ',';
        end;
        dBeginDepth:= dBottom;
        if dEndDepth <= dBottom then 
          Break;
                        
      end;
    end;
  finally
    FreeStringList;
    if copy(aQcAverage,length(aQcAverage),1)=',' then
      aQcAverage:= copy(aQcAverage,1,length(aQcAverage)-1);
    if copy(aFsAverage,length(aFsAverage),1)=',' then
      aFsAverage:= copy(aFsAverage,1,length(aFsAverage)-1);      
  end;

end;


  //���ַ�����ȥһ��1000��������ֵ�͸��ıȽ϶��ˣ��ڴ�ӡʱ�жϣ����С��-500��������ӡʱ���԰���ֵ����1000������ǰ��Ӹ�*��ǰ��
  //Ŀ�ľ��ǰѴ�ӡʱ���޳���������23���*23����ȥ10000��Ŀ������Ϊ������ֵ�������и�������Χ�� -100����200
function AddFuHao(aStr:string):string;
  begin
//    if Pos('-',aStr)<1 then
//      Result := '-' + aStr
//    else
//      Result := aStr;
    Result := FloatToStr(StrToFloat(aStr)-1000) ;
  end;


procedure FenXiFenCeng_TuYiangJiSuan;
type TGuanLianFlags = set of (tgHanShuiLiang, tgYeXian, tgYaSuoXiShu, tgNingJuLi_ZhiKuai, tgMoCaJiao_ZhiKuai,
  tgNingJuLi_GuKuai, tgMoCaJiao_GuKuai);
  //yys 20040610 modified
//const AnalyzeCount=17;
  const AnalyzeCount=26;
//yys 20040610 modified
var
  //���          �ǲ��
  lstStratumNo, lstSubNo: TStringList;
  //��׺�   �������   ��ʼ���        �������
  lstDrl_no, lstS_no, lstBeginDepth, lstEndDepth: TStringList;
  //��������      ɰ����(%)    ɰ����(%)      ɰ��ϸ(%)  
  lstShear_type, lstSand_big, lstSand_middle,lstSand_small:Tstringlist;
  //������(%)        ����ϸ(%)     ճ��(%)        ������ϵ��         ����ϵ��         ������ ��������
  lstPowder_big, lstPowder_small, lstClay_grain, lstAsymmetry_coef,lstCurvature_coef, lstEa_name: TStringList;
  //����ѹ��  ����ѹ���±�����  ��϶��         ѹ��ϵ��     ѹ��ģ��
  lstYssy_yali, lstYssy_bxl, lstYssy_kxb, lstYssy_ysxs, lstYssy_ysml: TStringList;

  i,j,iRecordCount,iCol: integer;
  strSQL, strFieldNames, strFieldValues , strTmp, strSubNo,strStratumNo,strPrjNo: string;
  aAquiferous_rate: TAnalyzeResult;//��ˮ��     0
  aWet_density    : TAnalyzeResult;//ʪ�ܶ�     1
  aDry_density    : TAnalyzeResult;//���ܶ�     2
  aSoil_proportion: TAnalyzeResult;//��������   3
  aGap_rate       : TAnalyzeResult;//��϶��     4
  aGap_degree     : TAnalyzeResult;//��϶��     5
  aSaturation     : TAnalyzeResult;//���϶�     6
  aLiquid_limit   : TAnalyzeResult;//Һ��       7
  aShape_limit    : TAnalyzeResult;//����       8
  aShape_index    : TAnalyzeResult;//����ָ��   9
  aLiquid_index   : TAnalyzeResult;//Һ��ָ��   10
  aZip_coef       : TAnalyzeResult;//ѹ��ϵ��   11
  aZip_modulus    : TAnalyzeResult;//ѹ��ģ��   12
  aCohesion       : TAnalyzeResult;//������ֱ�� 13
  aFriction_angle : TAnalyzeResult;//Ħ����ֱ�� 14
//yys 20040610 modified  
  aCohesion_gk    : TAnalyzeResult;//�������̿� 15
  aFriction_gk    : TAnalyzeResult;//Ħ���ǹ̿� 16
//yys 20040610 modified  
  aWcx_yuanz      : TAnalyzeResult;//�޲��޿�ѹǿ��ԭ״   17
  aWcx_chsu       : TAnalyzeResult;//�޲��޿�ѹǿ������   18
  aWcx_lmd        : TAnalyzeResult;//�޲��޿�ѹǿ�������� 19

 	aSand_big       : TAnalyzeResult;//ɰ���� 20
	aSand_middle    : TAnalyzeResult;//ɰ���� 21
	aSand_small     : TAnalyzeResult;//ɰ��ϸ 22
	aPowder_big     : TAnalyzeResult;//������ 23
	aPowder_small   : TAnalyzeResult;//����ϸ 24
	aClay_grain     : TAnalyzeResult;//ճ�� 25
  
  ArrayAnalyzeResult: Array[0..AnalyzeCount-1] of TAnalyzeResult;  // ����Ҫ�μ�ͳ�Ƶ�TAnalyzeResult
  ArrayFieldNames: Array[0..AnalyzeCount-1] of String; // ����Ҫ�μ�ͳ�Ƶ��ֶ���,��ArrayAnalyzeResult������һһ��Ӧ

  //��ʼ���˹����еı���
  procedure InitVar;
  var 
    iCount: integer;
  begin
    ArrayAnalyzeResult[0]:= aAquiferous_rate;
    ArrayAnalyzeResult[1]:= aWet_density;
    ArrayAnalyzeResult[2]:= aDry_density;
    ArrayAnalyzeResult[3]:= aSoil_proportion;
    ArrayAnalyzeResult[4]:= aGap_rate;
    ArrayAnalyzeResult[5]:= aGap_degree;
    ArrayAnalyzeResult[6]:= aSaturation;
    ArrayAnalyzeResult[7]:= aLiquid_limit;
    ArrayAnalyzeResult[8]:= aShape_limit;
    ArrayAnalyzeResult[9]:= aShape_index;
    ArrayAnalyzeResult[10]:= aLiquid_index;
    ArrayAnalyzeResult[11]:= aZip_coef;
    ArrayAnalyzeResult[12]:= aZip_modulus;
    ArrayAnalyzeResult[13]:= aCohesion;
    ArrayAnalyzeResult[14]:= aFriction_angle;
//yys 20040610 modified 
    //ArrayAnalyzeResult[14]:= aWcx_yuanz;
    //ArrayAnalyzeResult[15]:= aWcx_chsu;
    //ArrayAnalyzeResult[16]:= aWcx_lmd;
    ArrayAnalyzeResult[15]:= aCohesion_gk;
    ArrayAnalyzeResult[16]:= aFriction_gk;
    ArrayAnalyzeResult[17]:= aWcx_yuanz;
    ArrayAnalyzeResult[18]:= aWcx_chsu;
    ArrayAnalyzeResult[19]:= aWcx_lmd;

    ArrayAnalyzeResult[20]:= aSand_big;
    ArrayAnalyzeResult[21]:= aSand_middle;
    ArrayAnalyzeResult[22]:= aSand_small;
    ArrayAnalyzeResult[23]:= aPowder_big;
    ArrayAnalyzeResult[24]:= aPowder_small;
    ArrayAnalyzeResult[25]:= aClay_grain;
//yys 20040610 modified

    ArrayFieldNames[0]:= 'aquiferous_rate';
    ArrayFieldNames[1]:= 'wet_density';
    ArrayFieldNames[2]:= 'dry_density';
    ArrayFieldNames[3]:= 'soil_proportion';
    ArrayFieldNames[4]:= 'gap_rate';
    ArrayFieldNames[5]:= 'gap_degree';
    ArrayFieldNames[6]:= 'saturation';
    ArrayFieldNames[7]:= 'liquid_limit';
    ArrayFieldNames[8]:= 'shape_limit';
    ArrayFieldNames[9]:= 'shape_index';
    ArrayFieldNames[10]:= 'liquid_index';
    ArrayFieldNames[11]:= 'zip_coef';
    ArrayFieldNames[12]:= 'zip_modulus';
    ArrayFieldNames[13]:= 'cohesion';
    ArrayFieldNames[14]:= 'friction_angle'; 
//yys 20040610 modified
    //ArrayFieldNames[14]:= 'wcx_yuanz';
    //ArrayFieldNames[15]:= 'wcx_chsu';
    //ArrayFieldNames[16]:= 'wcx_lmd';      
    ArrayFieldNames[15]:= 'cohesion_gk';
    ArrayFieldNames[16]:= 'friction_gk';      
    ArrayFieldNames[17]:= 'wcx_yuanz';
    ArrayFieldNames[18]:= 'wcx_chsu';
    ArrayFieldNames[19]:= 'wcx_lmd';

    ArrayFieldNames[20]:= 'sand_big';
    ArrayFieldNames[21]:= 'sand_middle';
    ArrayFieldNames[22]:= 'sand_small';
    ArrayFieldNames[23]:= 'powder_big';
    ArrayFieldNames[24]:= 'powder_small';
    ArrayFieldNames[25]:= 'clay_grain';
//yys 20040610 modified
    
    lstStratumNo:= TStringList.Create;
    lstSubNo:= TStringList.Create;
    lstBeginDepth:= TStringList.Create;
    lstEndDepth:= TStringList.Create;
    lstDrl_no:= TStringList.Create;
    lstS_no:= TStringList.Create;
    lstShear_type:= TStringList.Create;
    lstsand_big:= TStringList.Create;
    lstsand_middle:= TStringList.Create;
    lstsand_small:= TStringList.Create;
    lstPowder_big:= TStringList.Create;
    lstPowder_small:= TStringList.Create;
    lstClay_grain:= TStringList.Create;
    lstAsymmetry_coef:= TStringList.Create;
    lstCurvature_coef:= TStringList.Create;
    lstEa_name:= TStringList.Create;
    lstYssy_yali:= TStringList.Create;
    lstYssy_bxl:= TStringList.Create;
    lstYssy_kxb:= TStringList.Create;
    lstYssy_ysxs:= TStringList.Create;
    lstYssy_ysml:= TStringList.Create;

    for iCount:=0 to AnalyzeCount-1 do
    begin
      ArrayAnalyzeResult[iCount].lstValues := TStringList.Create;
      ArrayAnalyzeResult[iCount].lstValuesForPrint := TStringList.Create;
    end;
    aAquiferous_rate.FormatString := '0.0';
    aWet_density.FormatString := '0.00';
    aDry_density.FormatString := '0.00';
    aSoil_proportion.FormatString := '0.00';
    aGap_rate.FormatString := '0.000';
    aGap_degree.FormatString := '0.0';
    aSaturation.FormatString := '0';
    aLiquid_limit.FormatString := '0.0';
    aShape_limit.FormatString := '0.0';
    aShape_index.FormatString := '0.0';
    aLiquid_index.FormatString := '0.00';
    aZip_coef.FormatString := '0.000';
    aZip_modulus.FormatString := '0.00';
    aCohesion.FormatString := '0.00';
    aFriction_angle.FormatString := '0.00';
//yys 20040610 modified 
    aCohesion_gk.FormatString := '0.00';
    aFriction_gk.FormatString := '0.00';
//yys 20040610 modified
    aWcx_yuanz.FormatString := '0.0';
    aWcx_chsu.FormatString := '0.0';
    aWcx_lmd.FormatString := '0.0';

    aSand_big.FormatString := '0.00';
    aSand_middle.FormatString := '0.00';
    aSand_small.FormatString := '0.00';
    aPowder_big.FormatString := '0.00';
    aPowder_small.FormatString := '0.00';
    aClay_grain.FormatString := '0.00';
  end;
  
  //�ͷŴ˹����еı���
  procedure FreeStringList;
  var
    iCount: integer;
  begin
    lstStratumNo.Free;
    lstSubNo.Free;
    lstBeginDepth.Free;
    lstEndDepth.Free;
    lstDrl_no.Free;
    lstS_no.Free;
    lstShear_type.Free;
    lstsand_big.Free;
    lstsand_middle.Free;
    lstsand_small.Free;
    lstPowder_big.Free;
    lstPowder_small.Free;
    lstClay_grain.Free;
    lstAsymmetry_coef.Free;
    lstCurvature_coef.Free;
    lstEa_name.Free;
    lstYssy_yali.Free;
    lstYssy_bxl.Free;
    lstYssy_kxb.Free;
    lstYssy_ysxs.Free;
    lstYssy_ysml.Free;

    for iCount:=0 to AnalyzeCount-1 do
    begin
      ArrayAnalyzeResult[iCount].lstValues.Free;
      ArrayAnalyzeResult[iCount].lstValuesForPrint.Free;
    end;
  end;

    //�����ٽ�ֵ
  function CalculateCriticalValue(aValue, aPingjunZhi, aBiaoZhunCha: double): double;
  begin
    if aBiaoZhunCha = 0 then
    begin
      result:= 0;
      exit;
    end;
    result := (aValue - aPingjunZhi) / aBiaoZhunCha;
  end;


  //����ƽ��ֵ����׼�����ϵ��������ֵ�������޳� ����һ���޳�ʱ����һ��Ҳ�޳�
  //1��ѹ��ϵ�� ���޳�ʱҪͬʱ��ѹ��ģ���޳� ��ѹ��ģ���ڼ���ʱ�������޳�����
  //2����������Ħ���� ����Ҫ�޳��������޳�
  //3����ˮ����Һ�� ������Ҫ�޳���ͬʱ������ָ����Һ��ָ���޳� ��
  //   3���б�˳���ǣ����жϺ�ˮ�������޳�ʱҲҪ��Һ���޳������ж�Һ�ޣ����޳�ʱ����Ҫ�Ѻ�ˮ���޳���
  //���⣬2009/12/29����Ժ�޸�Ҫ��ֻ����������Ħ���ǡ���ᡢ��̽��Ҫ�����׼ֵ�����������ڼ����׼ֵ��ͬʱ��������Щ��Ҫ�����׼ֵ��Ҫ�հ���ʾ��
  procedure GetTeZhengShuGuanLian(var aAnalyzeResult : TAnalyzeResult;Flags: TGuanLianFlags);
  var
    i,iCount,iFirst,iMax:integer;
    dTotal,dValue,dTotalFangCha,dCriticalValue:double;
    strValue: string;
    TiChuGuo: boolean; //�����ڼ���ʱ�Ƿ��й��޳�������У���ô�漰�������޳������������ҲҪ���¼���
  begin
    iMax:=0;
    dTotal:= 0;
    iFirst:= 0;
    TiChuGuo := false;
    dTotalFangCha:=0;
    aAnalyzeResult.PingJunZhi := -1;
    aAnalyzeResult.BiaoZhunCha := -1;
    aAnalyzeResult.BianYiXiShu := -1;
    aAnalyzeResult.MaxValue := -1;
    aAnalyzeResult.MinValue := -1;
    aAnalyzeResult.SampleNum := -1;
    aAnalyzeResult.BiaoZhunZhi:= -1;
    if aAnalyzeResult.lstValues.Count<1 then exit;
    strValue := '';
    for i:= 0 to aAnalyzeResult.lstValues.Count-1 do
        strValue:=strValue + aAnalyzeResult.lstValues.Strings[i];
    strValue := trim(strValue);
    if strValue='' then exit;

  //yys 2005/06/15
    iCount:= aAnalyzeResult.lstValues.Count;
    for i:= 0 to aAnalyzeResult.lstValues.Count-1 do
      begin
        strValue:=aAnalyzeResult.lstValues.Strings[i];
        if strValue='' then
        begin
          iCount:=iCount-1;
        end
        else
        begin
          inc(iFirst);
          dValue:= StrToFloat(strValue);
          if iFirst=1 then
            begin
              aAnalyzeResult.MinValue:= dValue;
              aAnalyzeResult.MaxValue:= dValue;

              iMax := i;
            end
          else
            begin
              if aAnalyzeResult.MinValue>dValue then
              begin
                aAnalyzeResult.MinValue:= dValue;

              end;
              if aAnalyzeResult.MaxValue<dValue then
              begin
                aAnalyzeResult.MaxValue:= dValue;
                iMax := i;
              end;
            end;           
          dTotal:= dTotal + dValue;          
        end;
      end;
    //dTotal:= dTotal - aAnalyzeResult.MinValue - aAnalyzeResult.MaxValue;
    //iCount := iCount - 2;
    if iCount>=1 then
      aAnalyzeResult.PingJunZhi := dTotal/iCount
    else
      aAnalyzeResult.PingJunZhi := dTotal;
    //aAnalyzeResult.lstValues.Strings[iMin]:= '';
    //aAnalyzeResult.lstValues.Strings[iMax]:= '';

    //iCount:= aAnalyzeResult.lstValues.Count;
    for i:= 0 to aAnalyzeResult.lstValues.Count-1 do
    begin
      strValue:=aAnalyzeResult.lstValues.Strings[i];
      if strValue<>'' then
      begin
        dValue := StrToFloat(strValue);
        dTotalFangCha := dTotalFangCha + sqr(dValue-aAnalyzeResult.PingJunZhi);
      end
      //else iCount:= iCount -1;
    end;
    if iCount>1 then
      dTotalFangCha:= dTotalFangCha/(iCount-1);
    aAnalyzeResult.SampleNum := iCount;
    if iCount >1 then
      aAnalyzeResult.BiaoZhunCha := sqrt(dTotalFangCha)
    else
      aAnalyzeResult.BiaoZhunCha := sqrt(dTotalFangCha);
    if not iszero(aAnalyzeResult.PingJunZhi) then
      aAnalyzeResult.BianYiXiShu := strtofloat(formatfloat(aAnalyzeResult.FormatString,aAnalyzeResult.BiaoZhunCha / aAnalyzeResult.PingJunZhi))
    else
      aAnalyzeResult.BianYiXiShu:= 0;
    if iCount>=6 then
    begin //2009/12/29����Ժ�޸�Ҫ��ֻ����������Ħ������Ҫ�����׼ֵ�����������ڼ����׼ֵ��ͬʱ��������Щ��Ҫ�����׼ֵ��Ҫ�հ���ʾ��
        if (tgNingJuLi_ZhiKuai in Flags) or (tgMoCaJiao_ZhiKuai in Flags) or (tgNingJuLi_GuKuai in Flags) or (tgMoCaJiao_GuKuai in Flags) then
          aAnalyzeResult.BiaoZhunZhi := GetBiaoZhunZhi(aAnalyzeResult.SampleNum , aAnalyzeResult.BianYiXiShu, aAnalyzeResult.PingJunZhi);
    end;
    dValue:= CalculateCriticalValue(aAnalyzeResult.MaxValue, aAnalyzeResult.PingJunZhi,aAnalyzeResult.BiaoZhunCha);
    dCriticalValue := GetCriticalValue(iCount);

  //2005/07/25 yys edit ���������޳�ʱ����6�����Ͳ����޳����޳�ʱҪ���޳��������ݣ�ͬʱ��������������һ���޳�

    if (iCount> 6) AND (dValue > dCriticalValue) then
      begin
        aAnalyzeResult.lstValues.Strings[iMax]:= '';
        //if pos('-',aAnalyzeResult.lstValuesForPrint.Strings[iMax])>0 then  //��������Ǹ��� ���ȥ1000
        //if (ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax]<>'')  then
        if (aAnalyzeResult.lstValuesForPrint.Strings[iMax]<>'')  then
          aAnalyzeResult.lstValuesForPrint.Strings[iMax] := AddFuHao(aAnalyzeResult.lstValuesForPrint.Strings[iMax]) ;
        //else
        //  aAnalyzeResult.lstValuesForPrint.Strings[iMax]:= '-'+aAnalyzeResult.lstValuesForPrint.Strings[iMax];

        TiChuGuo := true;
        if tgHanShuiLiang in Flags then
        begin
          ArrayAnalyzeResult[7].lstValues.Strings[iMax]:= ''; //Һ��
          ArrayAnalyzeResult[8].lstValues.Strings[iMax]:= ''; //���� Shape_limit;
          ArrayAnalyzeResult[9].lstValues.Strings[iMax]:= ''; //����ָ�� Shape_index;
          ArrayAnalyzeResult[10].lstValues.Strings[iMax]:= ''; //Һ��ָ�� Liquid_index;
          //��ӡʱ����ת����*������ ��-10 ��ӡʱ��ת����*10 ,���ǣ��������и�����Һ�ޣ����ޣ� ����ָ����Һ��ָ������������-1000����ӡʱҲ��������<-500ʱ��*�ټ���1000

          if (ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax]<>'')  then
            ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax]); //Һ��
          if ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]:=AddFuHao(ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]); //���� Shape_limit;
          if ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]:=AddFuHao(ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]); //����ָ�� Shape_index;
          if ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]:=AddFuHao(ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]); //Һ��ָ�� Liquid_index;
        end
        else if tgYeXian in Flags then
        begin
          ArrayAnalyzeResult[8].lstValues.Strings[iMax]:= ''; //���� Shape_limit;
          ArrayAnalyzeResult[9].lstValues.Strings[iMax]:= ''; //����ָ�� Shape_index;
          ArrayAnalyzeResult[10].lstValues.Strings[iMax]:= ''; //Һ��ָ�� Liquid_index;

          if ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]:= AddFuHao(ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]); //���� Shape_limit;
          if ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]:= AddFuHao(ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]); //����ָ�� Shape_index;
          if ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]); //Һ��ָ�� Liquid_index;
        end
        else if tgYaSuoXiShu in Flags then
        begin
          ArrayAnalyzeResult[12].lstValues.Strings[iMax]:= ''; //ѹ��ģ�� Zip_modulus;
          if ArrayAnalyzeResult[12].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[12].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[12].lstValuesForPrint.Strings[iMax]);
        end
        else if tgNingJuLi_ZhiKuai in Flags then    //������ֱ��
        begin
          ArrayAnalyzeResult[14].lstValues.Strings[iMax]:= ''; //Ħ����ֱ�� Friction_angle
          if ArrayAnalyzeResult[14].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[14].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[14].lstValuesForPrint.Strings[iMax]);
        end
        else if tgMoCaJiao_ZhiKuai in Flags then
        begin
          ArrayAnalyzeResult[13].lstValues.Strings[iMax]:= ''; //������ֱ�� Cohesion
          if ArrayAnalyzeResult[13].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[13].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[13].lstValuesForPrint.Strings[iMax]);
        end
        else if tgNingJuLi_GuKuai in Flags then    //�������̿�
        begin
          ArrayAnalyzeResult[16].lstValues.Strings[iMax]:= ''; //Ħ���ǹ̿� Friction_gk
          if ArrayAnalyzeResult[16].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[16].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[16].lstValuesForPrint.Strings[iMax]);
        end
        else if tgMoCaJiao_GuKuai in Flags then
        begin
          ArrayAnalyzeResult[15].lstValues.Strings[iMax]:= ''; //�������̿� Cohesion_gk
          if ArrayAnalyzeResult[15].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[15].lstValuesForPrint.Strings[iMax] := AddFuHao(ArrayAnalyzeResult[15].lstValuesForPrint.Strings[iMax]);
        end;
        GetTeZhengShuGuanLian(aAnalyzeResult, Flags);
      end;

    if TiChuGuo then
    begin
      if tgNingJuLi_ZhiKuai in Flags then    //������ֱ��
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[14], [tgMoCaJiao_ZhiKuai]); //Ħ����ֱ�� Friction_angle
      end
      else if tgMoCaJiao_ZhiKuai in Flags then
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[13], [tgNingJuLi_ZhiKuai]);//������ֱ�� Cohesion
      end
      else if tgNingJuLi_GuKuai in Flags then    //�������̿�
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[16], [tgMoCaJiao_GuKuai]);//Ħ���ǹ̿� Friction_gk
      end
      else if tgMoCaJiao_GuKuai in Flags then
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[15], [tgNingJuLi_GuKuai]);//�������̿� Cohesion_gk
      end;
    end;

  //yys 2005/06/15 add, ��һ��ֻ��һ����ʱ����׼��ͱ���ϵ������Ϊ0����ӡ����ʱҪ�ÿո�������ѧ��Ҳһ����������-1����ʾ��ֵ������Ϊ�ڱ������ʱ����ͨ���ж�����ʾΪ�ա�
    if  iCount=1 then
    begin
       //aAnalyzeResult.strBianYiXiShu  := 'null';
       //aAnalyzeResult.strBiaoZhunCha  := 'null';
       aAnalyzeResult.BianYiXiShu := -1;
       aAnalyzeResult.BiaoZhunCha := -1;
       aAnalyzeResult.BiaoZhunZhi := -1;
    end
    else begin
       //aAnalyzeResult.strBianYiXiShu := FloatToStr(aAnalyzeResult.BianYiXiShu);
      // aAnalyzeResult.strBiaoZhunCha := FloatToStr(aAnalyzeResult.BiaoZhunCha);
    end;
  //yys 2005/06/15 add
  end;

   //ȡ��һ�����������еĲ�ź��ǲ�ź��������ƣ�����������TStringList�����С�
  procedure GetAllStratumNo(var AStratumNoList, ASubNoList, AEaNameList: TStringList);
  var
    strSQL: string;
  begin
    AStratumNoList.Clear;
    ASubNoList.Clear;
    AEaNameList.Clear;
    strSQL:='SELECT id,prj_no,stra_no,sub_no,ISNULL(ea_name,'''') as ea_name FROM stratum_description'
        +' WHERE prj_no='+''''+g_ProjectInfo.prj_no_ForSQL+''''
        +' ORDER BY id';
    with MainDataModule.qryStratum do
      begin
        close;
        sql.Clear;
        sql.Add(strSQL);
        open;
        while not eof do
          begin
            AStratumNoList.Add(FieldByName('stra_no').AsString);
            ASubNoList.Add(FieldByName('sub_no').AsString);
            AEaNameList.Add(FieldByName('ea_name').AsString);
            next;
          end;
        close;
      end;
  end;

begin
   try
    //��ʼ�������ֲ� ,�˴�ע�͵���������Ϊ�Ѿ��������ط��ֲ��ˡ�
    //SetTuYangCengHao;

    //��ʼ�����ʱͳ�Ʊ��ĵ�ǰ��������
    //strSQL:= 'TRUNCATE TABLE stratumTmp; TRUNCATE TABLE TeZhengShuTmp; TRUNCATE TABLE earthsampleTmp; TRUNCATE TABLE earthsampleTmp ';
    strSQL:= 'DELETE FROM stratumTmp WHERE prj_no = '+''''+g_ProjectInfo.prj_no_ForSQL+''''+';'
            +'DELETE FROM TeZhengShuTmp WHERE prj_no = '+''''+g_ProjectInfo.prj_no_ForSQL+''''+';'
            +'DELETE FROM earthsampleTmp WHERE prj_no = '+''''+g_ProjectInfo.prj_no_ForSQL+'''';
    if not Delete_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
    begin
      exit;
    end;

    InitVar;
    GetAllStratumNo(lstStratumNo, lstSubNo, lstEa_name);
    if lstStratumNo.Count = 0 then 
    begin
      //FreeStringList;
      exit;
    end;

    {//����ź��ǲ�ź��������Ʋ�����ʱ����
    for i:=0 to lstStratumNo.Count-1 do
    begin
      strSQL:='INSERT INTO stratumTmp (prj_no,stra_no,sub_no,ea_name) VALUES('
        +''''+g_ProjectInfo.prj_no_ForSQL+''''+','
        +''''+lstStratumNo.Strings[i]+'''' +','
        +''''+lstSubNo.Strings[i]+''''+','
        +''''+lstEa_name.Strings[i]+''''+')';
      Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL);   
    end;}
    strPrjNo := g_ProjectInfo.prj_no_ForSQL;
    for i:=0 to lstStratumNo.Count-1 do
    begin
      strSubNo := stringReplace(lstSubNo.Strings[i],'''','''''',[rfReplaceAll]);
      strStratumNo := lstStratumNo.Strings[i];
      //2008/11/21 yys edit ����ѡ����������ײ���ͳ��
      strSQL:='SELECT es.*,et.ea_name_en FROM (SELECT * FROM earthsample '
          +' WHERE prj_no='+''''+strPrjNo+''''
          +' AND stra_no='+''''+strStratumNo+''''
          +' AND sub_no='+''''+strSubNo+''''
          +' AND if_statistic=1 and drl_no in (select drl_no from drills where can_tongji=0 '
          +' AND prj_no='+''''+strPrjNo+''''
          +')) as es '
          +' Left Join earthtype et on es.ea_name=et.ea_name';

      iRecordCount := 0;
      lstBeginDepth.Clear;
      lstEndDepth.Clear;
      lstDrl_no.Clear;
      lstS_no.Clear;
      lstShear_type.Clear;
      lstsand_big.Clear;
      lstsand_middle.Clear;
      lstsand_small.Clear;
      lstPowder_big.Clear;
      lstPowder_small.Clear;
      lstClay_grain.Clear;
      lstAsymmetry_coef.Clear;
      lstCurvature_coef.Clear;
      lstEa_name.Clear;
      lstYssy_yali.Clear;
      lstYssy_bxl.Clear;
      lstYssy_kxb.Clear;
      lstYssy_ysxs.Clear;
      lstYssy_ysml.Clear;
    
      for j:=0 to AnalyzeCount-1 do
      begin
        ArrayAnalyzeResult[j].lstValues.Clear;
        ArrayAnalyzeResult[j].lstValuesForPrint.Clear;
      end;
          
      with MainDataModule.qryEarthSample do
        begin
          close;
          sql.Clear;
          sql.Add(strSQL);
          open;
          while not eof do
            begin
              inc(iRecordCount);
              lstDrl_no.Add(FieldByName('drl_no').AsString);
              lstS_no.Add(FieldByName('s_no').AsString);            
              lstBeginDepth.Add(FieldByName('s_depth_begin').AsString);
              lstEndDepth.Add(FieldByName('s_depth_end').AsString); 
              lstShear_type.Add(FieldByName('shear_type').AsString);
              lstsand_big.Add(FieldByName('sand_big').AsString);
              lstsand_middle.Add(FieldByName('sand_middle').AsString);
              lstsand_small.Add(FieldByName('sand_small').AsString);
              lstPowder_big.Add(FieldByName('powder_big').AsString);
              lstPowder_small.Add(FieldByName('powder_small').AsString);
              lstClay_grain.Add(FieldByName('clay_grain').AsString);
              lstAsymmetry_coef.Add(FieldByName('asymmetry_coef').AsString);
              lstCurvature_coef.Add(FieldByName('curvature_coef').AsString);
              if g_ProjectInfo.prj_ReportLanguage= trChineseReport then
                lstEa_name.Add(FieldByName('ea_name').AsString)
              else if g_ProjectInfo.prj_ReportLanguage= trEnglishReport then
                lstEa_name.Add(FieldByName('ea_name_en').AsString);

              lstYssy_yali.Add(FieldByName('Yssy_yali').AsString);
              lstYssy_bxl.Add(FieldByName('Yssy_bxl').AsString);
              lstYssy_kxb.Add(FieldByName('Yssy_kxb').AsString);
              lstYssy_ysxs.Add(FieldByName('Yssy_ysxs').AsString);
              lstYssy_ysml.Add(FieldByName('Yssy_ysml').AsString);
              for j:=0 to AnalyzeCount-1 do
              begin
                ArrayAnalyzeResult[j].lstValues.Add(FieldByName(ArrayFieldNames[j]).AsString);
                ArrayAnalyzeResult[j].lstValuesForPrint.Add(FieldByName(ArrayFieldNames[j]).AsString);
              end;
              next;
            end;
          close;
        end;
      if iRecordCount=0 then //���û��������Ϣ��������ֵ������������
      begin                  //����Ϊ���Ժ�����������TeZhengShuTmp���뾲����̽�ͱ������ʱ��ֻ��UPDATE���Ϳ�����
        for j:= 1 to 7 do
        begin 
          strSQL:='INSERT INTO TeZhengShuTmp '
            +'VALUES ('+''''+strPrjNo+''''+','
            +''''+strStratumNo+'''' +','
            +''''+strSubNo+''''+','''+InttoStr(j)+'''' + DupeString(',-1', 33)+')';  //�˴�27��TezhengShuTmp��ȥ��ǰ��4���к�����
          Insert_oneRecord(MainDataModule.qryPublic, strSQL);
        end;
        continue;
      end;
     

      //ȡ��������
//2007/01/24 ����������ע����������Ϊ
//      for j:=0 to AnalyzeCount-1 do
//        getTeZhengShu(ArrayAnalyzeResult[j], [tfTuYang]);
     GetTeZhengShuGuanLian(ArrayAnalyzeResult[0],[tgHanShuiLiang]); //��ˮ��     0
     GetTeZhengShuGuanLian(ArrayAnalyzeResult[7],[tgYeXian]);       //Һ��       7
     for j:=1 to 6 do
       getTeZhengShu(ArrayAnalyzeResult[j], [tfTuYang]);
     for j:=8 to 10 do  //����       8 ����ָ��   9  Һ��ָ��   10   �������޳�
       getTeZhengShu(ArrayAnalyzeResult[j], [tfOther]);
     GetTeZhengShuGuanLian(ArrayAnalyzeResult[11],[tgYaSuoXiShu]);   //ѹ��ϵ��   11
     getTeZhengShu(ArrayAnalyzeResult[12], [tfOther]);              //ѹ��ģ��   12   �������޳�

     GetTeZhengShuGuanLian(ArrayAnalyzeResult[13],[tgNingJuLi_ZhiKuai]);   //������ֱ�� 13
     GetTeZhengShuGuanLian(ArrayAnalyzeResult[14],[tgMoCaJiao_ZhiKuai]);   //Ħ����ֱ�� 14
     GetTeZhengShuGuanLian(ArrayAnalyzeResult[15],[tgNingJuLi_GuKuai]);   //�������̿� 15
     GetTeZhengShuGuanLian(ArrayAnalyzeResult[16],[tgMoCaJiao_GuKuai]);   //Ħ���ǹ̿� 16

     for j:=17 to 19 do
       getTeZhengShu(ArrayAnalyzeResult[j], [tfTuYang]);
     for j:=20 to AnalyzeCount-1 do
       getTeZhengShu(ArrayAnalyzeResult[j], [tfOther]);

//2007/01/24
//      for j:=0 to ArrayAnalyzeResult[15].lstValues.count-1 do
//         caption:= caption + ArrayAnalyzeResult[15].lstValues[j]; 

    {******��ƽ��ֵ����׼�����ϵ�������ֵ��**********}
    {******��Сֵ������ֵ����׼ֵ�Ȳ�����������TeZhengShuTmp ****}
      //��ʼȡ��Ҫ������ֶ����ơ�
      strFieldNames:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldNames:= strFieldNames + ArrayFieldNames[j] + ',';
      strFieldNames:= strFieldNames + 'prj_no, stra_no, sub_no, v_id';

      //��ʼ����ƽ��ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].PingJunZhi)+',';
      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_PingJunZhi;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        continue;
      
      //��ʼ�����׼��
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].BiaoZhunCha)+',';
        //strFieldValues:= strFieldValues +ArrayAnalyzeResult[j].strBiaoZhunCha+',';

      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_BiaoZhunCha;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ�������ϵ��
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].BianYiXiShu)+',';
        //strFieldValues:= strFieldValues + ArrayAnalyzeResult[j].strBianYiXiShu+',';
      strFieldValues:= strFieldValues 
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_BianYiXiShu;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ�������ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].MaxValue)+',';
      strFieldValues:= strFieldValues 
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_MaxValue;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ������Сֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].MinValue)+',';
      strFieldValues:= strFieldValues 
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_MinValue;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ��������ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].SampleNum)+',';
      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_SampleNum;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        continue;

      //��ʼ�����׼ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].BiaoZhunZhi)+',';
      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_BiaoZhunZhi;
      strSQL:='INSERT INTO TeZhengShuTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        continue;
                  
      {********�Ѿ�����������ֵ������ʱ������**********}
      for j:=0 to iRecordCount-1 do
      begin
        strFieldNames:= '';
        strFieldValues:= '';
        strSQL:= '';
        strFieldNames:='drl_no, s_no, s_depth_begin, s_depth_end,'
          +'shear_type, sand_big, sand_middle, sand_small, powder_big,'
          +'powder_small, clay_grain, asymmetry_coef, curvature_coef,ea_name,';
        if lstDrl_no.Strings[j]='' then continue;
        strFieldNames:= 'drl_no';
        strFieldValues:= strFieldValues +'''' + stringReplace(lstDrl_no.Strings[j] ,'''','''''',[rfReplaceAll]) +'''';

        if lstS_no.Strings[j]='' then continue;
        strFieldNames:= strFieldNames + ',s_no';
        strFieldValues:= strFieldValues +','+'''' + lstS_no.Strings[j] +''''; 

        if lstBeginDepth.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',s_depth_begin';
          strFieldValues:= strFieldValues +','+'''' + lstBeginDepth.Strings[j] +'''' ;
        end;

        if lstEndDepth.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',s_depth_end';
          strFieldValues:= strFieldValues +','+'''' + lstEndDepth.Strings[j] +'''' ;
        end;
//yys 20040610 modified
        //if lstShear_type.Strings[j]<>'' then
        //  strFieldValues:= strFieldValues +'''' + lstShear_type.Strings[j] +'''' +','
        //else
        //  strFieldValues:= strFieldValues + 'NULL' +',';
//yys 20040610 modified
        if lstsand_big.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',sand_big';
          strFieldValues:= strFieldValues +','+'''' + lstsand_big.Strings[j] +'''';
        end;
        
        if lstsand_middle.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',sand_middle';
          strFieldValues:= strFieldValues +','+'''' + lstsand_middle.Strings[j] +'''';
        end;
        if lstsand_small.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',sand_small';
          strFieldValues:= strFieldValues +','+'''' + lstsand_small.Strings[j] +'''' ;
        end;

        if lstPowder_big.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Powder_big';
          strFieldValues:= strFieldValues +','+'''' + lstPowder_big.Strings[j] +'''' ;
        end;

        if lstPowder_small.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Powder_small';
          strFieldValues:= strFieldValues +','+'''' + lstPowder_small.Strings[j] +'''' ;
        end;
        if lstClay_grain.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Clay_grain';
          strFieldValues:= strFieldValues +','+''''  + lstClay_grain.Strings[j] +'''';
        end;

        if lstAsymmetry_coef.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Asymmetry_coef';
          strFieldValues:= strFieldValues  +','+'''' + lstAsymmetry_coef.Strings[j] +'''';
        end;

        if lstCurvature_coef.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Curvature_coef';
          strFieldValues:= strFieldValues +','+'''' + lstCurvature_coef.Strings[j] +'''' ;
        end;

        if lstEa_name.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Ea_name';
          strFieldValues:= strFieldValues  +','+'''' + lstEa_name.Strings[j] +'''';
        end;

        if lstYssy_yali.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Yssy_yali';
          strFieldValues:= strFieldValues  +','+'''' + lstYssy_yali.Strings[j] +'''';
        end;

        if lstYssy_bxl.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Yssy_bxl';
          strFieldValues:= strFieldValues  +','+'''' + lstYssy_bxl.Strings[j] +'''';
        end;

        if lstYssy_kxb.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Yssy_kxb';
          strFieldValues:= strFieldValues  +','+'''' + lstYssy_kxb.Strings[j] +'''';
        end;

        if lstYssy_ysxs.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Yssy_ysxs';
          strFieldValues:= strFieldValues  +','+'''' + lstYssy_ysxs.Strings[j] +'''';
        end;

        if lstYssy_ysml.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Yssy_ysml';
          strFieldValues:= strFieldValues  +','+'''' + lstYssy_ysml.Strings[j] +'''';
        end;


        for iCol:=0 to 19 do  // for iCol:=0 to AnalyzeCount-1 do ��Ҫ���Ͽŷ����ݣ������Ѿ�����
        begin
          strTmp := ArrayAnalyzeResult[iCol].lstValuesForPrint.Strings[j];
          if strTmp <> '' then 
          begin
            strFieldNames:= strFieldNames + ','+ ArrayFieldNames[iCol] ;
            strFieldValues:= strFieldValues +','+ strTmp ;
          end;
        end;
        strFieldNames:= strFieldNames + ',prj_no, stra_no, sub_no';
        strFieldValues:= strFieldValues +','+''''
          +strPrjNo+''''+','
          +''''+strStratumNo+'''' +','
          +''''+strSubNo+'''';

        strSQL:='INSERT INTO earthsampleTmp (' + strFieldNames + ')'
          +'VALUES('+strFieldValues+')';
        if Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        else;
      
      end;
       
    end;  // end of for i:=0 to lstStratumNo.Count-1 do
  finally
    FreeStringList;

  end;
end;

procedure FenXiFenCeng_TeShuYiangJiSuan;
type TGuanLianFlags = set of (tgHanShuiLiang, tgYeXian, tgYaSuoXiShu, tgNingJuLi_ZhiKuai, tgMoCaJiao_ZhiKuai,
  tgNingJuLi_GuKuai, tgMoCaJiao_GuKuai);
  //yys 20040610 modified
//const AnalyzeCount=17;
  const AnalyzeCount=44;
//yys 20040610 modified
var
  //���          �ǲ��
  lstStratumNo, lstSubNo: TStringList;
  //��׺�   �������   ��ʼ���        �������
  lstDrl_no, lstS_no, lstBeginDepth, lstEndDepth: TStringList;
  //��������      ɰ����(%)    ɰ����(%)      ɰ��ϸ(%)
  lstShear_type, lstsand_big, lstsand_middle,lstsand_small:Tstringlist;
  //������(%)        ����ϸ(%)     ճ��(%)        ������ϵ��         ����ϵ��         ������ ��������
  lstPowder_big, lstPowder_small, lstClay_grain, lstAsymmetry_coef,lstCurvature_coef, lstEa_name: TStringList;
  //����ѹ��  ����ѹ���±�����  ��϶��         ѹ��ϵ��     ѹ��ģ��
  lstYssy_yali, lstYssy_bxl, lstYssy_kxb, lstYssy_ysxs, lstYssy_ysml: TStringList;
  i,j,iRecordCount,iCol: integer;
  strSQL, strFieldNames, strFieldValues , strTmp, strSubNo,strStratumNo,strPrjNo: string;
  aGygj_pc    : TAnalyzeResult;//���ڹ̽�ѹ��     0
  aGygj_cc    : TAnalyzeResult;//ѹ��ָ��     1
  aGygj_cs    : TAnalyzeResult;//�ص�ָ��     2
  aHtml       : TAnalyzeResult;//�ص�ģ��            3
  aGjxs50_1   : TAnalyzeResult;//�̽�ϵ��50     4
  aGjxs100_1  : TAnalyzeResult;//�̽�ϵ��100     5
  aGjxs200_1   : TAnalyzeResult;//�̽�ϵ��200     6
  aGjxs400_1   : TAnalyzeResult;//�̽�ϵ��400       7
  aGjxs50_2    : TAnalyzeResult;//�̽�ϵ��50       8
  aGjxs100_2   : TAnalyzeResult;//�̽�ϵ��100   9
  aGjxs200_2   : TAnalyzeResult;//�̽�ϵ��200   10
  aGjxs400_2   : TAnalyzeResult;//�̽�ϵ��400   11

  aJcxs_v_005_01    : TAnalyzeResult;//����ϵ������ֱ��0.05��0.1   12
  aJcxs_v_01_02     : TAnalyzeResult;//����ϵ������ֱ��0.1��0.2 13
  aJcxs_v_02_04     : TAnalyzeResult;//����ϵ������ֱ��0.05��0.1 14
  aJcxs_h_005_01    : TAnalyzeResult;//����ϵ����ˮƽ��0.05��0.1 15
  aJcxs_h_01_02     : TAnalyzeResult;//����ϵ����ˮƽ��0.1��0.2 16
  aJcxs_h_02_04     : TAnalyzeResult;//����ϵ����ˮƽ��0.2��0.4   17

  aJzcylxs          :TAnalyzeResult;  //��ֹ��ѹ��ϵ��  18

  aWcxkyqd_yz       :TAnalyzeResult; //�޲��޿�ѹǿ�� ԭ״     19
  aWcxkyqd_cs       :TAnalyzeResult; //�޲��޿�ѹǿ�� ����     20
  aWcxkyqd_lmd      :TAnalyzeResult; //�޲��޿�ѹǿ�� ������   21

  aSzsy_zyl_njl_UU  :TAnalyzeResult;  //��Ӧ��ճ����UU     22
  aSzsy_zyl_nmcj_UU :TAnalyzeResult;  //��Ӧ����Ħ����UU     23
  aSzsy_zyl_njl_CU  :TAnalyzeResult;  //��Ӧ�� ճ����CU        24
  aSzsy_zyl_nmcj_CU :TAnalyzeResult;  //��Ӧ����Ħ����CU      25
  aSzsy_yxyl_njl    :TAnalyzeResult;  //��ЧӦ��ճ����               26
  aSzsy_yxyl_nmcj   :TAnalyzeResult;  //��ЧӦ����Ħ����              27

  aStxs_kv          : TAnalyzeResult;//��͸ϵ��Kv   28
  aStxs_kh          : TAnalyzeResult;//��͸ϵ��KH   29

  aTrpj_g       : TAnalyzeResult;//��Ȼ�½�  ��   30
  aTrpj_sx      : TAnalyzeResult;//��Ȼ�½�  ˮ�� 31

  aKlzc_li              : TAnalyzeResult;//������ɣ�����>2 32
  aKlzc_sha_2_05        : TAnalyzeResult;//������ɣ�ɰ��2��0.5           33
  aKlzc_sha_05_025      : TAnalyzeResult;//������ɣ�ɰ��0.5��0.25        34
  aKlzc_sha_025_0075    : TAnalyzeResult;//������ɣ�ɰ��0.25��0.075      35
  aKlzc_fl          :TAnalyzeResult;     //������ɣ�������0.075��0.005   36
  aKlzc_nl          :TAnalyzeResult;     //������ɣ�ճ���� <0.005        37

  aLj_yxlj          :TAnalyzeResult;//��Ч����     38
  aLj_pjlj          :TAnalyzeResult; //ƽ������        39
  aLj_xzlj          :TAnalyzeResult;  //��������      40
  aLj_d70           :TAnalyzeResult; //               41

  aBjyxs   :TAnalyzeResult; //������ϵ��              42
  aQlxs    :TAnalyzeResult;//����ϵ��                43
  
  ArrayAnalyzeResult: Array[0..AnalyzeCount-1] of TAnalyzeResult;  // ����Ҫ�μ�ͳ�Ƶ�TAnalyzeResult
  ArrayFieldNames: Array[0..AnalyzeCount-1] of String; // ����Ҫ�μ�ͳ�Ƶ��ֶ���,��ArrayAnalyzeResult������һһ��Ӧ
  ArrayToFieldNames: Array[0..AnalyzeCount-1] of String; // ����Ҫ���뵽TeShuYangTzsTmp�����ֶ�������Ҫ��Ϊ�˼���ʵ���UU��CU����Ӧ��
  //��ʼ���˹����еı���
  procedure InitVar;
  var 
    iCount: integer;
  begin
    ArrayAnalyzeResult[0]:= aGygj_pc;                               ArrayFieldNames[0]:= 'Gygj_pc';
    ArrayAnalyzeResult[1]:= aGygj_cc;                               ArrayFieldNames[1]:= 'Gygj_cc';
    ArrayAnalyzeResult[2]:= aGygj_cs;                               ArrayFieldNames[2]:= 'Gygj_cs';
    ArrayAnalyzeResult[3]:= aHtml;                                  ArrayFieldNames[3]:= 'Html';
    ArrayAnalyzeResult[4]:= aGjxs50_1;                              ArrayFieldNames[4]:= 'Gjxs50_1';
    ArrayAnalyzeResult[5]:= aGjxs100_1;                             ArrayFieldNames[5]:= 'Gjxs100_1';
    ArrayAnalyzeResult[6]:= aGjxs200_1;                             ArrayFieldNames[6]:= 'Gjxs200_1';
    ArrayAnalyzeResult[7]:= aGjxs400_1;                             ArrayFieldNames[7]:= 'Gjxs400_1';
    ArrayAnalyzeResult[8]:= aGjxs50_2;                              ArrayFieldNames[8]:= 'Gjxs50_2';
    ArrayAnalyzeResult[9]:= aGjxs100_2;                             ArrayFieldNames[9]:= 'Gjxs100_2';
    ArrayAnalyzeResult[10]:= aGjxs200_2;                            ArrayFieldNames[10]:= 'Gjxs200_2';
    ArrayAnalyzeResult[11]:= aGjxs400_2;                            ArrayFieldNames[11]:= 'Gjxs400_2';
    ArrayAnalyzeResult[12]:= aJcxs_v_005_01;                        ArrayFieldNames[12]:= 'Jcxs_v_005_01';
    ArrayAnalyzeResult[13]:= aJcxs_v_01_02;                         ArrayFieldNames[13]:= 'Jcxs_v_01_02';
    ArrayAnalyzeResult[14]:= aJcxs_v_02_04;                         ArrayFieldNames[14]:= 'Jcxs_v_02_04';
    ArrayAnalyzeResult[15]:= aJcxs_h_005_01;                        ArrayFieldNames[15]:= 'Jcxs_h_005_01';
    ArrayAnalyzeResult[16]:= aJcxs_h_01_02;                         ArrayFieldNames[16]:= 'Jcxs_h_01_02';
    ArrayAnalyzeResult[17]:= aJcxs_h_02_04;                         ArrayFieldNames[17]:= 'Jcxs_h_02_04';
    ArrayAnalyzeResult[18]:= aJzcylxs;                              ArrayFieldNames[18]:= 'Jzcylxs';
    ArrayAnalyzeResult[19]:= aWcxkyqd_yz;                           ArrayFieldNames[19]:= 'Wcxkyqd_yz';
    ArrayAnalyzeResult[20]:= aWcxkyqd_cs;                           ArrayFieldNames[20]:= 'Wcxkyqd_cs';
    ArrayAnalyzeResult[21]:= aWcxkyqd_lmd;                          ArrayFieldNames[21]:= 'Wcxkyqd_lmd';
    ArrayAnalyzeResult[22]:= aSzsy_zyl_njl_UU;                      ArrayFieldNames[22]:= 'Szsy_zyl_njl_UU';
    ArrayAnalyzeResult[23]:= aSzsy_zyl_nmcj_UU;                     ArrayFieldNames[23]:= 'Szsy_zyl_nmcj_UU';
    ArrayAnalyzeResult[24]:= aSzsy_zyl_njl_CU;                      ArrayFieldNames[24]:= 'Szsy_zyl_njl_CU';
    ArrayAnalyzeResult[25]:= aSzsy_zyl_nmcj_CU;                     ArrayFieldNames[25]:= 'Szsy_zyl_nmcj_CU';
    ArrayAnalyzeResult[26]:= aSzsy_yxyl_njl;                        ArrayFieldNames[26]:= 'Szsy_yxyl_njl';
    ArrayAnalyzeResult[27]:= aSzsy_yxyl_nmcj;                       ArrayFieldNames[27]:= 'Szsy_yxyl_nmcj';
    ArrayAnalyzeResult[28]:= aStxs_kv;                              ArrayFieldNames[28]:= 'Stxs_kv';
    ArrayAnalyzeResult[29]:= aStxs_kh;                              ArrayFieldNames[29]:= 'Stxs_kh';
    ArrayAnalyzeResult[30]:= aTrpj_g;                               ArrayFieldNames[30]:= 'Trpj_g';
    ArrayAnalyzeResult[31]:= aTrpj_sx;                              ArrayFieldNames[31]:= 'Trpj_sx';
    ArrayAnalyzeResult[32]:= aKlzc_li;                              ArrayFieldNames[32]:= 'Klzc_li';
    ArrayAnalyzeResult[33]:= aKlzc_sha_2_05;                        ArrayFieldNames[33]:= 'Klzc_sha_2_05';
    ArrayAnalyzeResult[34]:= aKlzc_sha_05_025;                      ArrayFieldNames[34]:= 'Klzc_sha_05_025';
    ArrayAnalyzeResult[35]:= aKlzc_sha_025_0075;                    ArrayFieldNames[35]:= 'Klzc_sha_025_0075';
    ArrayAnalyzeResult[36]:= aKlzc_fl;                              ArrayFieldNames[36]:= 'Klzc_fl';
    ArrayAnalyzeResult[37]:= aKlzc_nl;                              ArrayFieldNames[37]:= 'Klzc_nl';
    ArrayAnalyzeResult[38]:= aLj_yxlj;                              ArrayFieldNames[38]:= 'Lj_yxlj';
    ArrayAnalyzeResult[39]:= aLj_pjlj;                              ArrayFieldNames[39]:= 'Lj_pjlj';
    ArrayAnalyzeResult[40]:= aLj_xzlj;                              ArrayFieldNames[40]:= 'Lj_xzlj';
    ArrayAnalyzeResult[41]:= aLj_d70;                               ArrayFieldNames[41]:= 'Lj_d70';
    ArrayAnalyzeResult[42]:= aBjyxs;                                ArrayFieldNames[42]:= 'bjyxs';
    ArrayAnalyzeResult[43]:= aQlxs;                                 ArrayFieldNames[43]:= 'qlxs';



    lstStratumNo:= TStringList.Create;
    lstSubNo:= TStringList.Create;
    lstBeginDepth:= TStringList.Create;
    lstEndDepth:= TStringList.Create;
    lstDrl_no:= TStringList.Create;
    lstS_no:= TStringList.Create;
    lstShear_type:= TStringList.Create;
    lstsand_big:= TStringList.Create;
    lstsand_middle:= TStringList.Create;
    lstsand_small:= TStringList.Create;
    lstPowder_big:= TStringList.Create;
    lstPowder_small:= TStringList.Create;
    lstClay_grain:= TStringList.Create;
    lstAsymmetry_coef:= TStringList.Create;
    lstCurvature_coef:= TStringList.Create;
    lstEa_name:= TStringList.Create;
    lstYssy_yali:= TStringList.Create;
    lstYssy_bxl:= TStringList.Create;
    lstYssy_kxb:= TStringList.Create;
    lstYssy_ysxs:= TStringList.Create;
    lstYssy_ysml:= TStringList.Create;
    
    for iCount:=0 to AnalyzeCount-1 do
    begin
      ArrayAnalyzeResult[iCount].lstValues := TStringList.Create;
      ArrayAnalyzeResult[iCount].lstValuesForPrint := TStringList.Create;
    end;
    aGygj_pc.FormatString := '0.0';
    aGygj_cc.FormatString := '0.0000';
    aGygj_cs.FormatString := '0.0000';
    aHtml.FormatString := '0.0';
    aGjxs50_1.FormatString := '0.000';
    aGjxs100_1.FormatString := '0.000';
    aGjxs200_1.FormatString := '0.000';
    aGjxs400_1.FormatString := '0.000';
    aGjxs50_2.FormatString := '0.000';                   aStxs_kv.FormatString := '0.0000';
    aGjxs100_2.FormatString := '0.000';                  aStxs_kh.FormatString := '0.0000';
    aGjxs200_2.FormatString := '0.000';                  aTrpj_g.FormatString := '0';
    aGjxs400_2.FormatString := '0.000';                  aTrpj_sx.FormatString := '0';
    aJcxs_v_005_01.FormatString := '0.00';
    aJcxs_v_01_02.FormatString := '0.00';                aKlzc_li.FormatString := '0.0';
    aJcxs_v_02_04.FormatString := '0.00';                aKlzc_sha_2_05.FormatString := '0.0';
    aJcxs_h_005_01.FormatString := '0.00';               aKlzc_sha_05_025.FormatString := '0.0';
    aJcxs_h_01_02.FormatString := '0.00';                aKlzc_sha_025_0075.FormatString := '0.0';
    aJcxs_h_02_04.FormatString := '0.00';                aKlzc_fl.FormatString := '0.0';
    aJzcylxs.FormatString := '0.000';                    aKlzc_nl.FormatString := '0.0';
    aWcxkyqd_yz.FormatString := '0.0';
    aWcxkyqd_cs.FormatString := '0.0';                   aLj_yxlj.FormatString := '0.000';
    aWcxkyqd_lmd.FormatString:= '0.00';                  aLj_pjlj.FormatString := '0.000';
    aSzsy_zyl_njl_UU.FormatString := '0.0';              aLj_xzlj.FormatString := '0.000';
    aSzsy_zyl_nmcj_UU.FormatString := '0.0';             aLj_d70.FormatString := '0.000';
    aSzsy_zyl_njl_CU.FormatString := '0.0';
    aSzsy_zyl_nmcj_CU.FormatString := '0.0';             aBjyxs.FormatString := '0.00';
    aSzsy_yxyl_njl.FormatString := '0.0';                aQlxs.FormatString := '0.00';
    aSzsy_yxyl_nmcj.FormatString := '0.0';
    


  end;
  
  //�ͷŴ˹����еı���
  procedure FreeStringList;
  var
    iCount: integer;
  begin
    lstStratumNo.Free;        lstPowder_big.Free;
    lstSubNo.Free;            lstPowder_small.Free;
    lstBeginDepth.Free;       lstClay_grain.Free;
    lstEndDepth.Free;         lstAsymmetry_coef.Free;
    lstDrl_no.Free;           lstCurvature_coef.Free;
    lstS_no.Free;             lstEa_name.Free;
    lstShear_type.Free;       lstYssy_yali.Free;
    lstsand_big.Free;         lstYssy_bxl.Free;
    lstsand_middle.Free;      lstYssy_kxb.Free;
    lstsand_small.Free;       lstYssy_ysxs.Free;
                              lstYssy_ysml.Free;

    for iCount:=0 to AnalyzeCount-1 do
    begin
      ArrayAnalyzeResult[iCount].lstValues.Free;
      ArrayAnalyzeResult[iCount].lstValuesForPrint.Free;
    end;
  end;

    //�����ٽ�ֵ
  function CalculateCriticalValue(aValue, aPingjunZhi, aBiaoZhunCha: double): double;
  begin
    if aBiaoZhunCha = 0 then
    begin
      result:= 0;
      exit;
    end;
    result := (aValue - aPingjunZhi) / aBiaoZhunCha;
  end;



  //����ƽ��ֵ����׼�����ϵ��������ֵ�������޳� ����һ���޳�ʱ����һ��Ҳ�޳�
  //1��ѹ��ϵ�� ���޳�ʱҪͬʱ��ѹ��ģ���޳� ��ѹ��ģ���ڼ���ʱ�������޳�����
  //2����������Ħ���� ����Ҫ�޳��������޳�
  //3����ˮ����Һ�� ������Ҫ�޳���ͬʱ������ָ����Һ��ָ���޳� ��
  //   3���б�˳���ǣ����жϺ�ˮ�������޳�ʱҲҪ��Һ���޳������ж�Һ�ޣ����޳�ʱ����Ҫ�Ѻ�ˮ���޳���
  //���⣬2009/12/29����Ժ�޸�Ҫ��ֻ����������Ħ���ǡ���ᡢ��̽��Ҫ�����׼ֵ�����������ڼ����׼ֵ��ͬʱ��������Щ��Ҫ�����׼ֵ��Ҫ�հ���ʾ��
  //2011/03/09 ����Ժ�޸�Ҫ�������ֶζ�Ҫ�����׼ֵ����Ϊ�������ֲ�ͳ�Ʊ�ֻ���ڲ������������ݶ�Ҫ��
  procedure GetTeZhengShuGuanLian(var aAnalyzeResult : TAnalyzeResult;Flags: TGuanLianFlags);
  var
    i,iCount,iFirst,iMax:integer;
    dTotal,dValue,dTotalFangCha,dCriticalValue:double;
    strValue: string;
    TiChuGuo: boolean; //�����ڼ���ʱ�Ƿ��й��޳�������У���ô�漰�������޳������������ҲҪ���¼���
  begin
    iMax:=0;
    dTotal:= 0;
    iFirst:= 0;
    TiChuGuo := false;
    dTotalFangCha:=0;
    aAnalyzeResult.PingJunZhi := -1;
    aAnalyzeResult.BiaoZhunCha := -1;
    aAnalyzeResult.BianYiXiShu := -1;
    aAnalyzeResult.MaxValue := -1;
    aAnalyzeResult.MinValue := -1;
    aAnalyzeResult.SampleNum := -1;
    aAnalyzeResult.BiaoZhunZhi:= -1;
    if aAnalyzeResult.lstValues.Count<1 then exit;
    strValue := '';
    for i:= 0 to aAnalyzeResult.lstValues.Count-1 do
        strValue:=strValue + aAnalyzeResult.lstValues.Strings[i];
    strValue := trim(strValue);
    if strValue='' then exit;

  //yys 2005/06/15
    iCount:= aAnalyzeResult.lstValues.Count;
    for i:= 0 to aAnalyzeResult.lstValues.Count-1 do
      begin
        strValue:=aAnalyzeResult.lstValues.Strings[i];
        if strValue='' then
        begin
          iCount:=iCount-1;
        end
        else
        begin
          inc(iFirst);
          dValue:= StrToFloat(strValue);
          if iFirst=1 then
            begin
              aAnalyzeResult.MinValue:= dValue;
              aAnalyzeResult.MaxValue:= dValue;

              iMax := i;
            end
          else
            begin
              if aAnalyzeResult.MinValue>dValue then
              begin
                aAnalyzeResult.MinValue:= dValue;

              end;
              if aAnalyzeResult.MaxValue<dValue then
              begin
                aAnalyzeResult.MaxValue:= dValue;
                iMax := i;
              end;                            
            end;           
          dTotal:= dTotal + dValue;          
        end;
      end;
    //dTotal:= dTotal - aAnalyzeResult.MinValue - aAnalyzeResult.MaxValue;
    //iCount := iCount - 2;
    if iCount>=1 then
      aAnalyzeResult.PingJunZhi := dTotal/iCount
    else
      aAnalyzeResult.PingJunZhi := dTotal;
    //aAnalyzeResult.lstValues.Strings[iMin]:= '';
    //aAnalyzeResult.lstValues.Strings[iMax]:= '';

    //iCount:= aAnalyzeResult.lstValues.Count;
    for i:= 0 to aAnalyzeResult.lstValues.Count-1 do
    begin
      strValue:=aAnalyzeResult.lstValues.Strings[i];
      if strValue<>'' then
      begin
        dValue := StrToFloat(strValue);
        dTotalFangCha := dTotalFangCha + sqr(dValue-aAnalyzeResult.PingJunZhi);
      end
      //else iCount:= iCount -1;
    end;
    if iCount>1 then
      dTotalFangCha:= dTotalFangCha/(iCount-1);
    aAnalyzeResult.SampleNum := iCount;
    if iCount >1 then
      aAnalyzeResult.BiaoZhunCha := sqrt(dTotalFangCha)
    else
      aAnalyzeResult.BiaoZhunCha := sqrt(dTotalFangCha);
    if not iszero(aAnalyzeResult.PingJunZhi) then
      aAnalyzeResult.BianYiXiShu := strtofloat(formatfloat(aAnalyzeResult.FormatString,aAnalyzeResult.BiaoZhunCha / aAnalyzeResult.PingJunZhi))
    else
      aAnalyzeResult.BianYiXiShu:= 0;
    if iCount>=6 then
    begin //2009/12/29����Ժ�޸�Ҫ��ֻ����������Ħ������Ҫ�����׼ֵ�����������ڼ����׼ֵ��ͬʱ��������Щ��Ҫ�����׼ֵ��Ҫ�հ���ʾ��
          //2011/03/09 ����Ժ�޸�Ҫ��,���е��ֶζ�Ҫ�����׼ֵ
        //if (tgNingJuLi_ZhiKuai in Flags) or (tgMoCaJiao_ZhiKuai in Flags) or (tgNingJuLi_GuKuai in Flags) or (tgMoCaJiao_GuKuai in Flags) then
          aAnalyzeResult.BiaoZhunZhi := GetBiaoZhunZhi(aAnalyzeResult.SampleNum , aAnalyzeResult.BianYiXiShu, aAnalyzeResult.PingJunZhi);
    end;
    dValue:= CalculateCriticalValue(aAnalyzeResult.MaxValue, aAnalyzeResult.PingJunZhi,aAnalyzeResult.BiaoZhunCha);
    dCriticalValue := GetCriticalValue(iCount);

  //2005/07/25 yys edit ���������޳�ʱ����6�����Ͳ����޳����޳�ʱҪ���޳��������ݣ�ͬʱ��������������һ���޳�

    if (iCount> 6) AND (dValue > dCriticalValue) then
      begin
        aAnalyzeResult.lstValues.Strings[iMax]:= '';
        aAnalyzeResult.lstValuesForPrint.Strings[iMax]:= '-'
          +aAnalyzeResult.lstValuesForPrint.Strings[iMax];
        TiChuGuo := true;
        if tgHanShuiLiang in Flags then
        begin
          ArrayAnalyzeResult[7].lstValues.Strings[iMax]:= ''; //Һ��
          ArrayAnalyzeResult[8].lstValues.Strings[iMax]:= ''; //���� Shape_limit;
          ArrayAnalyzeResult[9].lstValues.Strings[iMax]:= ''; //����ָ�� Shape_index;
          ArrayAnalyzeResult[10].lstValues.Strings[iMax]:= ''; //Һ��ָ�� Liquid_index;
          //��ӡʱ����ת����*������ ��-10 ��ӡʱ��ת����*10
          if ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[7].lstValuesForPrint.Strings[iMax]; //Һ��
          if ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]; //���� Shape_limit;
          if ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]; //����ָ�� Shape_index;
          if ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]; //Һ��ָ�� Liquid_index;
        end
        else if tgYeXian in Flags then
        begin
          ArrayAnalyzeResult[8].lstValues.Strings[iMax]:= ''; //���� Shape_limit;
          ArrayAnalyzeResult[9].lstValues.Strings[iMax]:= ''; //����ָ�� Shape_index;
          ArrayAnalyzeResult[10].lstValues.Strings[iMax]:= ''; //Һ��ָ�� Liquid_index;

          if ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[8].lstValuesForPrint.Strings[iMax]; //���� Shape_limit;
          if ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[9].lstValuesForPrint.Strings[iMax]; //����ָ�� Shape_index;
          if ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]<>'' then
          ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]:= '-'
            +ArrayAnalyzeResult[10].lstValuesForPrint.Strings[iMax]; //Һ��ָ�� Liquid_index;
        end
        else if tgYaSuoXiShu in Flags then
        begin
          ArrayAnalyzeResult[12].lstValues.Strings[iMax]:= ''; //ѹ��ģ�� Zip_modulus;
          if ArrayAnalyzeResult[12].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[12].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[12].lstValuesForPrint.Strings[iMax];
        end
        else if tgNingJuLi_ZhiKuai in Flags then    //������ֱ��
        begin
          ArrayAnalyzeResult[14].lstValues.Strings[iMax]:= ''; //Ħ����ֱ�� Friction_angle
          if ArrayAnalyzeResult[14].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[14].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[14].lstValuesForPrint.Strings[iMax];
        end
        else if tgMoCaJiao_ZhiKuai in Flags then
        begin
          ArrayAnalyzeResult[13].lstValues.Strings[iMax]:= ''; //������ֱ�� Cohesion
          if ArrayAnalyzeResult[13].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[13].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[13].lstValuesForPrint.Strings[iMax];
        end
        else if tgNingJuLi_GuKuai in Flags then    //�������̿�
        begin
          ArrayAnalyzeResult[16].lstValues.Strings[iMax]:= ''; //Ħ���ǹ̿� Friction_gk
          if ArrayAnalyzeResult[16].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[16].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[16].lstValuesForPrint.Strings[iMax];
        end
        else if tgMoCaJiao_GuKuai in Flags then
        begin
          ArrayAnalyzeResult[15].lstValues.Strings[iMax]:= ''; //�������̿� Cohesion_gk
          if ArrayAnalyzeResult[15].lstValuesForPrint.Strings[iMax]<>'' then
            ArrayAnalyzeResult[15].lstValuesForPrint.Strings[iMax]:= '-'
              +ArrayAnalyzeResult[15].lstValuesForPrint.Strings[iMax];
        end;
        GetTeZhengShuGuanLian(aAnalyzeResult, Flags);
      end;

    if TiChuGuo then
    begin
      if tgNingJuLi_ZhiKuai in Flags then    //������ֱ��
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[14], [tgMoCaJiao_ZhiKuai]); //Ħ����ֱ�� Friction_angle
      end
      else if tgMoCaJiao_ZhiKuai in Flags then
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[13], [tgNingJuLi_ZhiKuai]);//������ֱ�� Cohesion
      end
      else if tgNingJuLi_GuKuai in Flags then    //�������̿�
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[16], [tgMoCaJiao_GuKuai]);//Ħ���ǹ̿� Friction_gk
      end
      else if tgMoCaJiao_GuKuai in Flags then
      begin
        GetTeZhengShuGuanLian(ArrayAnalyzeResult[15], [tgNingJuLi_GuKuai]);//�������̿� Cohesion_gk
      end;
    end;

  //yys 2005/06/15 add, ��һ��ֻ��һ����ʱ����׼��ͱ���ϵ������Ϊ0����ӡ����ʱҪ�ÿո�������ѧ��Ҳһ����������-1����ʾ��ֵ������Ϊ�ڱ������ʱ����ͨ���ж�����ʾΪ�ա�
    if  iCount=1 then
    begin
       //aAnalyzeResult.strBianYiXiShu  := 'null';
       //aAnalyzeResult.strBiaoZhunCha  := 'null';
       aAnalyzeResult.BianYiXiShu := -1;
       aAnalyzeResult.BiaoZhunCha := -1;
       aAnalyzeResult.BiaoZhunZhi := -1;
    end
    else begin
       //aAnalyzeResult.strBianYiXiShu := FloatToStr(aAnalyzeResult.BianYiXiShu);
      // aAnalyzeResult.strBiaoZhunCha := FloatToStr(aAnalyzeResult.BiaoZhunCha);
    end;
  //yys 2005/06/15 add
  end;

   //ȡ��һ�����������еĲ�ź��ǲ�ź��������ƣ�����������TStringList�����С�
  procedure GetAllStratumNo(var AStratumNoList, ASubNoList, AEaNameList: TStringList);
  var
    strSQL: string;
  begin
    AStratumNoList.Clear;
    ASubNoList.Clear;
    AEaNameList.Clear;
    strSQL:='SELECT id,prj_no,stra_no,sub_no,ISNULL(ea_name,'''') as ea_name FROM stratum_description'
        +' WHERE prj_no='+''''+g_ProjectInfo.prj_no_ForSQL+''''
        +' ORDER BY id';
    with MainDataModule.qryStratum do
      begin
        close;
        sql.Clear;
        sql.Add(strSQL);
        open;
        while not eof do
          begin
            AStratumNoList.Add(FieldByName('stra_no').AsString);
            ASubNoList.Add(FieldByName('sub_no').AsString);
            AEaNameList.Add(FieldByName('ea_name').AsString);
            next;
          end;
        close;
      end;
  end;

begin
  try
    //��ʼ�������ֲ� ,�˴�ע�͵���������Ϊ�Ѿ������������޸�ʱ�ֲ��ˡ�
    //SetTuYangCengHao;

    //��ʼ�����ʱͳ�Ʊ��ĵ�ǰ��������
    //strSQL:= 'TRUNCATE TABLE stratumTmp; TRUNCATE TABLE TeZhengShuTmp; TRUNCATE TABLE earthsampleTmp; TRUNCATE TABLE earthsampleTmp ';
    strSQL:= 'DELETE FROM stratumTmp WHERE prj_no = '+''''+g_ProjectInfo.prj_no_ForSQL+''''+';'
            +'DELETE FROM TeShuYangTzsTmp WHERE prj_no = '+''''+g_ProjectInfo.prj_no_ForSQL+''''+';'
            +'DELETE FROM TeShuYangTmp WHERE prj_no = '+''''+g_ProjectInfo.prj_no_ForSQL+'''';
    if not Delete_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
    begin
      exit;
    end;

    InitVar;
    GetAllStratumNo(lstStratumNo, lstSubNo, lstEa_name);
    if lstStratumNo.Count = 0 then 
    begin
      //FreeStringList;
      exit;
    end;

    {//����ź��ǲ�ź��������Ʋ�����ʱ����
    for i:=0 to lstStratumNo.Count-1 do
    begin
      strSQL:='INSERT INTO stratumTmp (prj_no,stra_no,sub_no,ea_name) VALUES('
        +''''+g_ProjectInfo.prj_no_ForSQL+''''+','
        +''''+lstStratumNo.Strings[i]+'''' +','
        +''''+lstSubNo.Strings[i]+''''+','
        +''''+lstEa_name.Strings[i]+''''+')';
      Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL);   
    end;}
    strPrjNo := g_ProjectInfo.prj_no_ForSQL;
    for i:=0 to lstStratumNo.Count-1 do
    begin
      strSubNo := stringReplace(lstSubNo.Strings[i],'''','''''',[rfReplaceAll]);
      strStratumNo := lstStratumNo.Strings[i];
      //2008/11/21 yys edit ����ѡ����������ײ���ͳ��
      strSQL:='SELECT es.*,et.ea_name_en FROM (SELECT * FROM TeShuYang '
          +' WHERE prj_no='+''''+strPrjNo+''''
          +' AND stra_no='+''''+strStratumNo+''''
          +' AND sub_no='+''''+strSubNo+''''
          +' AND if_statistic=1 and drl_no in (select drl_no from drills where can_tongji=0 '
          +' AND prj_no='+''''+strPrjNo+''''
          +')) as es '
          +' Left Join earthtype et on es.ea_name=et.ea_name';

      iRecordCount := 0;
      lstBeginDepth.Clear;
      lstEndDepth.Clear;
      lstDrl_no.Clear;
      lstS_no.Clear;
      lstShear_type.Clear;
      lstsand_big.Clear;
      lstsand_middle.Clear;
      lstsand_small.Clear;
      lstPowder_big.Clear;
      lstPowder_small.Clear;
      lstClay_grain.Clear;
      lstAsymmetry_coef.Clear;
      lstCurvature_coef.Clear;
      lstEa_name.Clear;
      lstYssy_yali.Clear;
      lstYssy_bxl.Clear;
      lstYssy_kxb.Clear;
      lstYssy_ysxs.Clear;
      lstYssy_ysml.Clear;
    
      for j:=0 to AnalyzeCount-1 do
      begin
        ArrayAnalyzeResult[j].lstValues.Clear;
        ArrayAnalyzeResult[j].lstValuesForPrint.Clear;
      end;
          
      with MainDataModule.qryEarthSample do
        begin
          close;
          sql.Clear;
          sql.Add(strSQL);
          open;
          while not eof do
            begin
              inc(iRecordCount);
              lstDrl_no.Add(FieldByName('drl_no').AsString);
              lstS_no.Add(FieldByName('s_no').AsString);            
              lstBeginDepth.Add(FieldByName('s_depth_begin').AsString);
              lstEndDepth.Add(FieldByName('s_depth_end').AsString);
//              lstShear_type.Add(FieldByName('shear_type').AsString);
//              lstsand_big.Add(FieldByName('sand_big').AsString);
//              lstsand_middle.Add(FieldByName('sand_middle').AsString);
//              lstsand_small.Add(FieldByName('sand_small').AsString);
//              lstPowder_big.Add(FieldByName('powder_big').AsString);
//              lstPowder_small.Add(FieldByName('powder_small').AsString);
//              lstClay_grain.Add(FieldByName('clay_grain').AsString);
//              lstAsymmetry_coef.Add(FieldByName('asymmetry_coef').AsString);
//              lstCurvature_coef.Add(FieldByName('curvature_coef').AsString);
              if g_ProjectInfo.prj_ReportLanguage= trChineseReport then
                lstEa_name.Add(FieldByName('ea_name').AsString)
              else if g_ProjectInfo.prj_ReportLanguage= trEnglishReport then
                lstEa_name.Add(FieldByName('ea_name_en').AsString);

//              lstYssy_yali.Add(FieldByName('Yssy_yali').AsString);
//              lstYssy_bxl.Add(FieldByName('Yssy_bxl').AsString);
//              lstYssy_kxb.Add(FieldByName('Yssy_kxb').AsString);
//              lstYssy_ysxs.Add(FieldByName('Yssy_ysxs').AsString);
//              lstYssy_ysml.Add(FieldByName('Yssy_ysml').AsString);
              for j:=0 to AnalyzeCount-1 do
              begin
                ArrayAnalyzeResult[j].lstValues.Add(FieldByName(ArrayFieldNames[j]).AsString);
                ArrayAnalyzeResult[j].lstValuesForPrint.Add(FieldByName(ArrayFieldNames[j]).AsString);
              end;

//              if FieldByName('szsy_syff').AsString = 'UU' then //������鷽����UU����ôCU�е���Ӧ������ЧӦ����Ӧ���ǿգ������CU����ôUU����Ӧ����Ҫ��Ϊ�յ�
//              begin
////                    ArrayAnalyzeResult[21]:= aSzsy_zyl_njl_CU;
////                    ArrayAnalyzeResult[22]:= aSzsy_zyl_nmcj_CU;
////                    ArrayAnalyzeResult[23]:= aSzsy_yxyl_njl;
////                    ArrayAnalyzeResult[24]:= aSzsy_yxyl_nmcj;
//                ArrayAnalyzeResult[21].lstValues[ArrayAnalyzeResult[21].lstValues.Count-1] := '';
//                ArrayAnalyzeResult[22].lstValues[ArrayAnalyzeResult[22].lstValues.Count-1] := '';
//                ArrayAnalyzeResult[23].lstValues[ArrayAnalyzeResult[23].lstValues.Count-1] := '';
//                ArrayAnalyzeResult[24].lstValues[ArrayAnalyzeResult[24].lstValues.Count-1] := '';
//              end
//              else if FieldByName('szsy_syff').AsString = 'CU' then
//              begin
//                ArrayAnalyzeResult[19].lstValues[ArrayAnalyzeResult[21].lstValues.Count-1] := '';
//                ArrayAnalyzeResult[20].lstValues[ArrayAnalyzeResult[22].lstValues.Count-1] := '';
//              end;


              next;
            end;
          close;
        end;
      if iRecordCount=0 then //���û��������Ϣ��������ֵ������������
      begin                  //����Ϊ���Ժ�����������TeShuYangTzsTmp���뾲����̽�ͱ������ʱ��ֻ��UPDATE���Ϳ�����
        for j:= 1 to 7 do
        begin 
          strSQL:='INSERT INTO TeShuYangTzsTmp '
            +'VALUES ('+''''+strPrjNo+''''+','
            +''''+strStratumNo+'''' +','
            +''''+strSubNo+''''+','''+InttoStr(j)+'''' + DupeString(',-1', 46)+')';
          Insert_oneRecord(MainDataModule.qryPublic, strSQL);
        end;
        continue;
      end;
     

      //ȡ��������
//2007/01/24 ����������ע����������Ϊ
//      for j:=0 to AnalyzeCount-1 do
//        getTeZhengShu(ArrayAnalyzeResult[j], [tfTuYang]);
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[0],[tgHanShuiLiang]); //��ˮ��     0
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[7],[tgYeXian]);       //Һ��       7
//     for j:=1 to 6 do
//       getTeZhengShu(ArrayAnalyzeResult[j], [tfTuYang]);
//     for j:=8 to 10 do  //����       8 ����ָ��   9  Һ��ָ��   10   �������޳�
//       getTeZhengShu(ArrayAnalyzeResult[j], [tfOther]);
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[11],[tgYaSuoXiShu]);   //ѹ��ϵ��   11
//     getTeZhengShu(ArrayAnalyzeResult[12], [tfOther]);              //ѹ��ģ��   12   �������޳�
//
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[13],[tgNingJuLi_ZhiKuai]);   //������ֱ�� 13
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[14],[tgMoCaJiao_ZhiKuai]);   //Ħ����ֱ�� 14
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[15],[tgNingJuLi_GuKuai]);   //�������̿� 15
//     GetTeZhengShuGuanLian(ArrayAnalyzeResult[16],[tgMoCaJiao_GuKuai]);   //Ħ���ǹ̿� 16
//     ArrayFieldNames[18]:= 'Jzcylxs';                  ArrayToFieldNames[18]:= 'Jzcylxs';
//    ArrayFieldNames[19]:= 'Szsy_zyl_njl_uu';          ArrayToFieldNames[19]:= 'Szsy_zyl_njl_uu';
//    ArrayFieldNames[20]:= 'Szsy_zyl_nmcj_uu';         ArrayToFieldNames[20]:= 'Szsy_zyl_nmcj_uu';
//    ArrayFieldNames[21]:= 'Szsy_zyl_njl_cu';          ArrayToFieldNames[21]:= 'Szsy_zyl_njl_cu';
//    ArrayFieldNames[22]:= 'Szsy_zyl_nmcj_cu';         ArrayToFieldNames[22]:= 'Szsy_zyl_nmcj_cu';
//    ArrayFieldNames[23]:= 'Szsy_yxyl_njl';            ArrayToFieldNames[23]:= 'Szsy_yxyl_njl';
//    ArrayFieldNames[24]:= 'Szsy_yxyl_nmcj';           ArrayToFieldNames[24]:= 'Szsy_yxyl_nmcj';
//    ArrayFieldNames[25]:= 'Stxs_kv';                  ArrayToFieldNames[25]:= 'Stxs_kv';
//    ArrayFieldNames[26]:= 'Stxs_kh';                  ArrayToFieldNames[26]:= 'Stxs_kh';
     for j:=0 to 21 do
       getTeZhengShu(ArrayAnalyzeResult[j], [tfTeShuYang]);  //1��21����Ŀ����Ҫ�޳�
     for j:=22 to 27 do
       getTeZhengShu(ArrayAnalyzeResult[j], [tfTeShuYangBiaoZhuZhi]); //ֻ��UU��CU����Ӧ������ЧӦ����Ҫ�޳�
     for j:=28 to 43 do
       getTeZhengShu(ArrayAnalyzeResult[j], [tfTeShuYang]);  //��͸ϵ��Ҳ����Ҫ�޳�

//2007/01/24
//      for j:=0 to ArrayAnalyzeResult[15].lstValues.count-1 do
//         caption:= caption + ArrayAnalyzeResult[15].lstValues[j]; 

    {******��ƽ��ֵ����׼�����ϵ�������ֵ��**********}
    {******��Сֵ������ֵ����׼ֵ�Ȳ�����������TeZhengShuTmp ****}
      //��ʼȡ��Ҫ������ֶ����ơ�
      strFieldNames:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldNames:= strFieldNames + ArrayFieldNames[j] + ',';
      strFieldNames:= strFieldNames + 'prj_no, stra_no, sub_no, v_id';

      //��ʼ����ƽ��ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].PingJunZhi)+',';
      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_PingJunZhi;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ�����׼��
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].BiaoZhunCha)+',';
        //strFieldValues:= strFieldValues +ArrayAnalyzeResult[j].strBiaoZhunCha+',';

      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_BiaoZhunCha;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ�������ϵ��
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].BianYiXiShu)+',';
        //strFieldValues:= strFieldValues + ArrayAnalyzeResult[j].strBianYiXiShu+',';
      strFieldValues:= strFieldValues 
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_BianYiXiShu;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ�������ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].MaxValue)+',';
      strFieldValues:= strFieldValues 
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_MaxValue;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ������Сֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].MinValue)+',';
      strFieldValues:= strFieldValues 
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_MinValue;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then 
        continue;
      
      //��ʼ��������ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].SampleNum)+',';
      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_SampleNum;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        continue;

      //��ʼ�����׼ֵ
      strFieldValues:= '';
      strSQL:= '';
      for j:=0 to AnalyzeCount-1 do
        strFieldValues:= strFieldValues +FloatToStr(ArrayAnalyzeResult[j].BiaoZhunZhi)+',';
      strFieldValues:= strFieldValues
        +''''+strPrjNo+''''+','
        +''''+strStratumNo+'''' +','
        +''''+strSubNo+''''+','+TEZHENSHU_Flag_BiaoZhunZhi;
      strSQL:='INSERT INTO TeShuYangTzsTmp (' + strFieldNames + ')'
        +'VALUES('+strFieldValues+')';
      if not Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        continue;
                  
      {********�Ѿ�����������ֵ������ʱ������**********}
      for j:=0 to iRecordCount-1 do
      begin
        strFieldNames:= '';
        strFieldValues:= '';
        strSQL:= '';
        strFieldNames:='drl_no, s_no, s_depth_begin, s_depth_end,ea_name,';
        if lstDrl_no.Strings[j]='' then continue;
        strFieldNames:= 'drl_no';
        strFieldValues:= strFieldValues +'''' + stringReplace(lstDrl_no.Strings[j] ,'''','''''',[rfReplaceAll]) +'''';

        if lstS_no.Strings[j]='' then continue;
        strFieldNames:= strFieldNames + ',s_no';
        strFieldValues:= strFieldValues +','+'''' + lstS_no.Strings[j] +''''; 

        if lstBeginDepth.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',s_depth_begin';
          strFieldValues:= strFieldValues +','+'''' + lstBeginDepth.Strings[j] +'''' ;
        end;

        if lstEndDepth.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',s_depth_end';
          strFieldValues:= strFieldValues +','+'''' + lstEndDepth.Strings[j] +'''' ;
        end;

        if lstEa_name.Strings[j]<>'' then
        begin
          strFieldNames:= strFieldNames + ',Ea_name';
          strFieldValues:= strFieldValues  +','+'''' + lstEa_name.Strings[j] +'''';
        end;


        for iCol:=0 to AnalyzeCount-1 do
        begin
          strTmp := ArrayAnalyzeResult[iCol].lstValuesForPrint.Strings[j];
          if strTmp <> '' then
          begin
            strFieldNames:= strFieldNames + ','+ ArrayFieldNames[iCol] ;
            strFieldValues:= strFieldValues +','+ strTmp ;
          end;
        end;
        strFieldNames:= strFieldNames + ',prj_no, stra_no, sub_no';
        strFieldValues:= strFieldValues +','+''''
          +strPrjNo+''''+','
          +''''+strStratumNo+'''' +','
          +''''+strSubNo+'''';

        strSQL:='INSERT INTO TeShuYangTmp (' + strFieldNames + ')'
          +'VALUES('+strFieldValues+')';
        if Insert_oneRecord(MainDataModule.qrySectionTotal, strSQL) then
        else;
      
      end;
       
    end;  // end of for i:=0 to lstStratumNo.Count-1 do
  finally
    FreeStringList;

  end;
end;

end.