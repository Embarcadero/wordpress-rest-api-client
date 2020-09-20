unit uDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Def,
  FireDAC.FMXUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.UI.Intf, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Stan.StorageBin, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Phys.SQLiteWrapper.Stat, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, Xml.xmldom, Xml.XMLIntf, Data.Bind.Components,
  Data.Bind.DBScope, Xml.omnixmldom, Xml.XMLDoc, System.Threading;

type
  TDM = class(TDataModule)
    SettingsFDTable: TFDTable;
    FDSQLiteSecurity1: TFDSQLiteSecurity;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDConnection1: TFDConnection;
    SettingsFDMemTable: TFDMemTable;
    FeedsFDMemTable: TFDMemTable;
    NetHTTPClient1: TNetHTTPClient;
    XMLDocument1: TXMLDocument;
    FDTable1: TFDTable;
    FeedBS: TBindSourceDB;
    FDMemTable1: TFDMemTable;
    FeedsFDTable: TFDTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FTasks: array of ITask;
    function MD5(const AString: String): String;
    procedure InitializeDatabase;
    procedure DownloadFeed(const AName, AURL: String);
    procedure RefreshFeeds;
    procedure ImportFeed(const AName, AFilename: String);
  end;
  const
    DB_FILENAME = 'wpsettings.s3db';
    DB_PASSWORD = '#@IPHi25bhqIb1ibgi4q3';
    DB_ENCRYPTION = 'aes-256';
    DB_TABLE = 'Settings';
    DB_DATATABLE = 'NewsFeed';
    DB_FEEDSTABLE = 'Feeds';

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  uMainForm, System.IOUtils, Soap.XSBuiltIns, IdGlobalProtocols, System.Variants,
  IdHash, IdHashMessageDigest, System.StrUtils, System.DateUtils;

function TDM.MD5(const AString: String): String;
var
  LHash: TIdHashMessageDigest5;
begin
  LHash := TIdHashMessageDigest5.Create;
  try
    Result := LHash.HashStringAsHex(AString);
  finally
    LHash.Free;
  end;
end;

procedure TDM.InitializeDatabase;
begin
  FDConnection1.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, DB_FILENAME);

  SettingsFDTable.TableName := DB_TABLE;
  FeedsFDTable.TableName := DB_FEEDSTABLE;
  FDTable1.TableName := DB_DATATABLE;
  if TFile.Exists(FDConnection1.Params.Values['Database'])=True then
    begin
      FDSQLiteSecurity1.Database := FDConnection1.Params.Values['Database'];
    end
  else
    begin
      FDConnection1.Open;
      // initialize table
      try
        SettingsFDTable.FieldDefs.Clear;
        SettingsFDTable.FieldDefs.Assign(SettingsFDMemTable.FieldDefs);
        SettingsFDTable.CreateTable(False);
        SettingsFDTable.CopyDataSet(SettingsFDMemTable, [coStructure, coRestart, coAppend]);
        FeedsFDTable.FieldDefs.Clear;
        FeedsFDTable.FieldDefs.Assign(FeedsFDMemTable.FieldDefs);
        FeedsFDTable.CreateTable(False);
        FeedsFDTable.CopyDataSet(FeedsFDMemTable, [coStructure, coRestart, coAppend]);
        FDTable1.FieldDefs.Clear;
        FDTable1.FieldDefs.Assign(FDMemTable1.FieldDefs);
        FDTable1.CreateTable(False);
      finally
        FDConnection1.Close;
      end;
      // encrypt database
      FDSQLiteSecurity1.Database := FDConnection1.Params.Values['Database'];
      FDSQLiteSecurity1.Password := DB_ENCRYPTION + ':' + DB_PASSWORD;
      FDSQLiteSecurity1.SetPassword;
    end;

  FDConnection1.Params.Values['Encrypt'] := DB_ENCRYPTION;
  FDConnection1.Params.Password := DB_PASSWORD;
  FDConnection1.Open;
  SettingsFDTable.Open;
  SettingsFDMemTable.Free;
  FeedsFDTable.Open;
  FeedsFDMemTable.Free;
  FDTable1.IndexFieldNames := 'DateTime:D;';
  FDTable1.Open;
  FDMemTable1.Free;
end;


function StripHTML(AHTMLString: String): string;
var
  LBegin, LEnd, LLength: Integer;
begin

  LBegin := AHTMLString.IndexOf('<');

  while (LBegin > -1) do
    begin
      LEnd := AHTMLString.IndexOf('>');
      LLength := LEnd - LBegin + 1;
      AHTMLString := AHTMLString.Remove(LBegin, LLength);
      LBegin := AHTMLString.IndexOf('<');
    end;

  Result := AHTMLString.Replace(#10,'',[rfReplaceAll]).Substring(0,256);
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  FeedBS.DataSet := FDTable1;
end;

procedure TDM.DownloadFeed(const AName, AURL: String);
begin
  FTasks := FTasks + [TTask.Create(procedure var LNet: TNetHTTPClient; LStream: TMemoryStream; LFileAge: TDateTime; begin
     FileAge(TPath.Combine(TPath.GetDocumentsPath,MD5(AURL) + '.xml'), LFileAge);
     if HoursBetween(LFileAge,Now)>1 then
       begin
         LNet := TNetHTTPClient.Create(nil);
         LStream := TMemoryStream.Create;
         try
           LNet.Get(AURL,LStream);
           LStream.Position := 0;
           LStream.SaveToFile(TPath.Combine(TPath.GetDocumentsPath,MD5(AURL) + '.xml'));
         finally
           LStream.Free;
           LNet.Free;
         end;
       end;

     TThread.Synchronize(nil, procedure begin
       if TFile.Exists(TPath.Combine(TPath.GetDocumentsPath,MD5(AURL) + '.xml'))=True then
         ImportFeed(AName, TPath.Combine(TPath.GetDocumentsPath,MD5(AURL) + '.xml'));
     end);
  end)];
  FTasks[High(FTasks)].Start;
end;

procedure TDM.RefreshFeeds;
begin

  FTasks := [];

  FeedsFDTable.First;
  while not FeedsFDTable.Eof do
    begin
      DownloadFeed(FeedsFDTable.FieldByName('Name').AsWideString, FeedsFDTable.FieldByName('URL').AsWideString);

      FeedsFDTable.Next;
    end;

  TTask.Run(procedure begin
    TTask.WaitForAll(FTasks,60000);
    MainForm.LoadFeeds;
  end);

end;

procedure TDM.ImportFeed(const AName, AFilename: String);
var
LXMLDocument: TXMLDocument;
LStartItemNode: IXMLNode;
LNode: IXMLNode;
LTitle, LDesc, LLink, LAuthor, LGuid: String;
begin
  LXMLDocument := TXMLDocument.Create(Self);
  LXMLDocument.DOMVendor := XMLDocument1.DOMVendor;
  LXMLDocument.FileName := AFilename;
  LXMLDocument.Active := True;
  LStartItemNode := LXMLDocument.DocumentElement.ChildNodes.FindNode('entry') ;
  if LStartItemNode<>nil then
  begin
    LNode := LStartItemNode;
    repeat
    LNode.NodeName;
      LTitle := LNode.ChildNodes.FindNode('title').Text;
      LLink := LNode.ChildNodes.FindNode('link').Attributes['href'];
      LDesc := LNode.ChildNodes.FindNode('content').Text;
      LGuid := IfThen(LNode.ChildNodes.FindNode('id').Text<>'',LNode.ChildNodes.FindNode('id').Text,LNode.ChildNodes.FindNode('link').Text);
      if LNode.ChildNodes.FindNode('author')<>nil then
        if LNode.ChildNodes.FindNode('author').ChildNodes.FindNode('name')<>nil then
          LAuthor := LNode.ChildNodes.FindNode('author').ChildNodes.FindNode('name').Text
      else
        LAuthor := 'Author';

      if VarIsNull(FeedBS.DataSet.Lookup('Guid', VarArrayOf([LGuid]),'Id')) then
        FeedBS.DataSet.AppendRecord([nil,StrInternetToDateTime(LNode.ChildNodes['published'].Text),LTitle,LLink,LDesc,LAuthor,LGuid,AName]);
      LNode := LNode.NextSibling;
    until LNode = nil;
  end
  else
  begin
    LStartItemNode := LXMLDocument.DocumentElement.ChildNodes.First.ChildNodes.FindNode('item') ;
    LNode := LStartItemNode;
    repeat
      LTitle := LNode.ChildNodes['title'].Text;
      LLink := LNode.ChildNodes['link'].Text;
      LDesc := LNode.ChildNodes['description'].Text;
      LGuid := IfThen(LNode.ChildNodes['guid'].Text<>'',LNode.ChildNodes['guid'].Text,LNode.ChildNodes['link'].Text);
      if LNode.ChildNodes.FindNode('dc:creator')<>nil then
        LAuthor := LNode.ChildNodes['dc:creator'].Text
      else
        LAuthor := 'Author';

      if VarIsNull(FeedBS.DataSet.Lookup('Guid', VarArrayOf([LGuid]),'Id')) then
        FeedBS.DataSet.AppendRecord([nil,StrInternetToDateTime(LNode.ChildNodes['pubDate'].Text),LTitle,LLink,LDesc,LAuthor,LGuid,AName]);
      LNode := LNode.NextSibling;
    until LNode = nil;
  end;

  LXMLDocument.Free;
end;



end.
