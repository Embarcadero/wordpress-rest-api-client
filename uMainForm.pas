unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FMX.Controls.Presentation, FMX.MultiView, REST.Client,
  REST.Authenticator.Basic, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Response.Adapter, Data.Bind.Components, Data.Bind.ObjectScope,
  FMX.Layouts, FMX.StdCtrls, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, FMX.ScrollBox,
  FMX.Memo, Data.Bind.DBScope, FMX.WebBrowser, FMX.ListView, FMX.Edit,
  System.ImageList, FMX.ImgList, FMX.Grid.Style, Fmx.Bind.Grid, Data.Bind.Grid,
  FMX.Grid, FMX.TabControl, uAddFrame, FireDAC.Stan.StorageBin, FMX.Memo.Types;

type
  TMainForm = class(TForm)
    MultiView1: TMultiView;
    Button1: TButton;
    ClientLayout: TLayout;
    ContentListView: TListView;
    WebBrowser: TWebBrowser;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    Memo1: TMemo;
    LinkControlToField1: TLinkControlToField;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    HTTPBasicAuthenticator1: THTTPBasicAuthenticator;
    SearchEdit: TEdit;
    LeftLayout: TLayout;
    SearchEditButton1: TSearchEditButton;
    LinkControlToField2: TLinkControlToField;
    Splitter1: TSplitter;
    ImageList: TImageList;
    ToolBar1: TToolBar;
    RefreshButton: TButton;
    Timer: TTimer;
    MemoDefaultDark: TMemo;
    TabControl1: TTabControl;
    ViewContentTab: TTabItem;
    AddContentTab: TTabItem;
    Layout1: TLayout;
    ViewContentIconButton: TButton;
    ViewLabel: TLabel;
    Layout2: TLayout;
    AddContentIconButton: TButton;
    PostLabel: TLabel;
    AddContentButton: TButton;
    ViewContentButton: TButton;
    Layout3: TLayout;
    SettingsButton: TButton;
    SettingsIconButton: TButton;
    SettingsLabel: TLabel;
    SettingsTab: TTabItem;
    Label4: TLabel;
    Layout4: TLayout;
    Label5: TLabel;
    UsernameEdit: TEdit;
    Layout5: TLayout;
    Label6: TLabel;
    EndPointEdit: TEdit;
    Layout6: TLayout;
    Label7: TLabel;
    PasswordEdit: TEdit;
    SettingsBindSourceDB: TBindSourceDB;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    TabsFDMemTable: TFDMemTable;
    SaveButton: TButton;
    PostButton: TButton;
    BindSourceDB2: TBindSourceDB;
    LinkPropertyToFieldVisible: TLinkPropertyToField;
    LinkPropertyToFieldVisible2: TLinkPropertyToField;
    LinkPropertyToFieldVisible3: TLinkPropertyToField;
    LinkPropertyToFieldVisible4: TLinkPropertyToField;
    HelpMemo: TMemo;
    MaterialOxfordBlueSB: TStyleBook;
    FrameAdd: TAddFrame;
    Layout7: TLayout;
    ActionButton: TButton;
    ActionIconButton: TButton;
    ActionLabel: TLabel;
    RSSToPostTab: TTabItem;
    FeedBS: TBindSourceDB;
    ListView1: TListView;
    ImageList1: TImageList;
    LinkListControlToField2: TLinkListControlToField;
    Layout8: TLayout;
    Label1: TLabel;
    RSSFeedEdit: TEdit;
    FeedsBindSourceDB: TBindSourceDB;
    LinkControlToField6: TLinkControlToField;
    Layout9: TLayout;
    Label2: TLabel;
    FeaturedImageEdit: TEdit;
    VertScrollBox1: TVertScrollBox;
    LinkControlToField7: TLinkControlToField;
    procedure MultiView1Enter(Sender: TObject);
    procedure MultiView1Exit(Sender: TObject);
    procedure ContentListViewItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure SearchEditKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure ContentListViewUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure RefreshButtonClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ViewContentButtonClick(Sender: TObject);
    procedure AddContentButtonClick(Sender: TObject);
    procedure SettingsButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure PostButtonClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MultiView1StartShowing(Sender: TObject);
    procedure MultiView1Hidden(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ActionButtonClick(Sender: TObject);
    procedure ListView1UpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
  private
    { Private declarations }
{$IFDEF MSWINDOWS}
    procedure SetPermissions;
{$ENDIF}
  public
    { Public declarations }
    procedure LoadFeeds;
    procedure UpdateListView(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
{$IFDEF MSWINDOWS}
  System.Win.Registry,
{$ENDIF}
  uDM;

{$IFDEF MSWINDOWS}
procedure TMainForm.SetPermissions;
const
  cHomePath = 'SOFTWARE';
  cFeatureBrowserEmulation =
    'Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\';
  cIE11 = 11001;

var
  Reg: TRegIniFile;
  sKey: string;
begin

  sKey := ExtractFileName(ParamStr(0));
  Reg := TRegIniFile.Create(cHomePath);
  try
    if Reg.OpenKey(cFeatureBrowserEmulation, True) and
      not(TRegistry(Reg).KeyExists(sKey) and (TRegistry(Reg).ReadInteger(sKey)
      = cIE11)) then
      TRegistry(Reg).WriteInteger(sKey, cIE11);
  finally
    Reg.Free;
  end;

end;
{$ENDIF}

procedure TMainForm.SearchEditKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key=vkRETURN then
    SearchEditButton1Click(Sender);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if DM.SettingsFDTable.State=TDataSetState.dsEdit then
    DM.SettingsFDTable.Post;
  if DM.FeedsFDTable.State=TDataSetState.dsEdit then
    DM.FeedsFDTable.Post;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  SetPermissions;
{$ENDIF}
  WebBrowser.LoadFromStrings(MemoDefaultDark.Lines.Text.Replace('%s',Memo1.Lines.Text),'about:blank');

  FeedBS.DataSet := DM.FDTable1;

  DM.InitializeDatabase;
  if EndPointEdit.Text='' then
    begin
      Timer.Enabled := False;
      TabControl1.ActiveTab := SettingsTab;
    end
  else
    TabControl1.ActiveTab := ViewContentTab;
  FrameAdd.Initialize;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if MainForm.Width<445 then
    begin
      if LeftLayout.Align=TAlignLayout.Left then
        begin
          LeftLayout.Align := TAlignLayout.Top;
          LeftLayout.Height := Trunc(ContentListView.ItemAppearance.ItemHeight*3);
          SearchEdit.Align := TAlignLayout.Client;
        end;
    end
  else
    begin
      if LeftLayout.Align<>TAlignLayout.Left then
      begin
        LeftLayout.Align := TAlignLayout.Left;
        LeftLayout.Width := 395;
        SearchEdit.Align := TAlignLayout.Left;
        SearchEdit.Width := 397;
      end;
    end;
end;

procedure TMainForm.ActionButtonClick(Sender: TObject);
begin
  TabControl1.ActiveTab := RSSToPostTab;
end;

procedure TMainForm.AddContentButtonClick(Sender: TObject);
begin
  TabControl1.ActiveTab := AddContentTab;
end;

procedure TMainForm.ContentListViewItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  WebBrowser.LoadFromStrings(MemoDefaultDark.Lines.Text.Replace('%s',Memo1.Lines.Text),'about:blank');
end;

procedure TMainForm.ContentListViewUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if AItem.ImageIndex<>1 then AItem.ImageIndex := 0;
end;

procedure TMainForm.MultiView1Enter(Sender: TObject);
begin
  MultiView1.Mode := TMultiViewMode.Panel;
end;

procedure TMainForm.MultiView1Exit(Sender: TObject);
begin
  MultiView1.Mode := TMultiViewMode.NavigationPane;
end;

procedure TMainForm.MultiView1Hidden(Sender: TObject);
begin
  ViewLabel.Visible := False;
  PostLabel.Visible := False;
  SettingsLabel.Visible := False;
end;

procedure TMainForm.MultiView1StartShowing(Sender: TObject);
begin
  ViewLabel.Visible := True;
  PostLabel.Visible := True;
  SettingsLabel.Visible := True;
end;

procedure TMainForm.UpdateListView(Sender: TObject);
begin
  LinkListControlToField2.Active := False;
  LinkListControlToField2.Active := True;
end;

procedure TMainForm.PostButtonClick(Sender: TObject);
begin
  case TabControl1.TabIndex of
    3:
      begin
       FrameAdd.CreateRSSPost(Sender, FeedsBindSourceDB.Dataset.FieldByName('FeaturedImage').AsString, UpdateListView);
      end
  else
    begin
      FrameAdd.CreatePost(Sender);
    end;
  end;
end;

procedure TMainForm.RefreshButtonClick(Sender: TObject);
begin
  case TabControl1.TabIndex of
    3:
      begin
       DM.RefreshFeeds;
      end
  else
    begin
      TLinkObservers.ControlChanged(SearchEdit);
      if FDMemTable1.Active then
        FDMemTable1.EmptyDataSet;
      HTTPBasicAuthenticator1.Username := DM.SettingsFDTable.FieldByName('Username').AsString;
      HTTPBasicAuthenticator1.Password := DM.SettingsFDTable.FieldByName('Password').AsString;
      RESTClient1.BaseURL := DM.SettingsFDTable.FieldByName('Endpoint').AsString;
      RESTRequest1.ExecuteAsync;
    end;
  end;

end;

procedure TMainForm.SaveButtonClick(Sender: TObject);
begin
  FrameAdd.SaveImage;
end;

procedure TMainForm.SearchEditButton1Click(Sender: TObject);
begin
  RefreshButtonClick(Sender);
end;

procedure TMainForm.SettingsButtonClick(Sender: TObject);
begin
  TabControl1.ActiveTab := SettingsTab;
end;

procedure TMainForm.TabControl1Change(Sender: TObject);
begin
  TabsFDMemTable.Locate('Id',VarArrayOf([TabControl1.TabIndex]));
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  RefreshButtonClick(Sender);
end;

procedure TMainForm.ViewContentButtonClick(Sender: TObject);
begin
  TabControl1.ActiveTab := ViewContentTab;
end;

procedure TMainForm.ListView1UpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
 // if AItem.ImageIndex<>0 then AItem.ImageIndex := 2;
end;

procedure TMainForm.LoadFeeds;
begin
  UpdateListView(Self);
end;

initialization
  Randomize;

end.
