unit uAddFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ListBox, FMX.Layouts, FMX.Edit, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, FMX.Effects, REST.Types, REST.Response.Adapter,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  REST.Authenticator.Basic, FMX.TabControl, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, FMX.Memo.Types,
  Data.Bind.DBScope;

type
  TAddFrame = class(TFrame)
    Rectangle1: TRectangle;
    Text1: TText;
    GlowEffect1: TGlowEffect;
    PaintBox1: TPaintBox;
    Rectangle2: TRectangle;
    SetTextButton: TButton;
    DescMemo: TMemo;
    Edit1: TEdit;
    BGPathEdit: TEdit;
    ComboBox1: TComboBox;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    ListBox1: TListBox;
    ListBoxItem9: TListBoxItem;
    Image9: TImage;
    ListBoxItem1: TListBoxItem;
    Image1: TImage;
    ListBoxItem2: TListBoxItem;
    Image2: TImage;
    ListBoxItem3: TListBoxItem;
    Image3: TImage;
    ListBoxItem4: TListBoxItem;
    Image4: TImage;
    ListBoxItem5: TListBoxItem;
    Image5: TImage;
    ListBoxItem6: TListBoxItem;
    Image6: TImage;
    ListBoxItem7: TListBoxItem;
    Image7: TImage;
    ListBoxItem8: TListBoxItem;
    Label2: TLabel;
    Layout2: TLayout;
    RefreshBGButton: TButton;
    OpenDialog3: TOpenDialog;
    OpenDialog4: TOpenDialog;
    Image8: TImage;
    Rectangle3: TRectangle;
    SaveDialog1: TSaveDialog;
    HTTPBasicAuthenticator1: THTTPBasicAuthenticator;
    RESTClient1: TRESTClient;
    AnyRequest: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    Layout3: TLayout;
    Layout4: TLayout;
    SearchEditButton1: TSearchEditButton;
    LoadBGButton: TSearchEditButton;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    RandomBGButton: TButton;
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequest: TNetHTTPRequest;
    TitleMemo: TMemo;
    Layout1: TLayout;
    Layout5: TLayout;
    ZoomInButton: TButton;
    ZoomOutButton: TButton;
    ContentLayout: TLayout;
    FeedBS: TBindSourceDB;
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure RefreshBGButtonClick(Sender: TObject);
    procedure ListBoxItem8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure LoadBGButtonClick(Sender: TObject);
    procedure RandomBGButtonClick(Sender: TObject);
    procedure NetHTTPRequestRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure TitleMemoChangeTracking(Sender: TObject);
    procedure SetTextButtonClick(Sender: TObject);
    procedure ZoomInButtonClick(Sender: TObject);
    procedure ZoomOutButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure DrawImage;
  public
    { Public declarations }
    procedure Initialize;
    procedure CreatePost(Sender: TObject);
    procedure CreateRSSPost(Sender: TObject; FMediaId: String; FNotifyEvent: TNotifyEvent);
    procedure SaveImage;
    function GetResolution: Integer;
  end;

implementation

{$R *.fmx}

uses
  uDM, System.Math, FMX.TextLayout, System.JSON, System.NetEncoding,
  System.DateUtils, System.IOUtils, System.Threading;

procedure TAddFrame.SaveImage;
begin
  if SaveDialog1.Execute then
   begin
    Rectangle1.MakeScreenshot.SaveToFile(SaveDialog1.Files[0]);
   end;
end;

procedure TAddFrame.CreateRSSPost(Sender: TObject; FMediaId: String; FNotifyEvent: TNotifyEvent);
var
  FileStream: TFileStream;
  CreatePostRequestObj: TJSONObject;
  CreatePostResultObj: TJSONObject;
  UpdatePostRequestObj: TJSONObject;
  CreateMediaResultObj : TJSONObject;
  UpdateMediaRequestObj: TJSONObject;
  PostIDAsStr: string;
  MediaIDAsStr: string;
  TestTime: string;
  MediaHTML: string;
begin
  HTTPBasicAuthenticator1.Username := DM.SettingsFDTable.FieldByName('Username').AsString;
  HTTPBasicAuthenticator1.Password := DM.SettingsFDTable.FieldByName('Password').AsString;

  RESTClient1.BaseURL := DM.SettingsFDTable.FieldByName('Endpoint').AsString;

  if Sender is TButton then
    TButton(Sender).Enabled := False;


  TTask.Run(procedure begin

    try

      PostIDAsStr := '';
      MediaIDAsStr := FMediaId;
      MediaHTML := '';
      TestTime := ' - '+FormatDateTime('dd-mm-yyyy hh:mm:ss', now);

      // Create new Post
      // https://developer.wordpress.org/rest-api/reference/posts/#create-a-post
      CreatePostRequestObj := TJSONObject.Create;
      try
        CreatePostRequestObj.AddPair('title', FeedBS.DataSet.FieldByName('title').AsWideString);

        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'posts';
        AnyRequest.AddParameter('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddBody(CreatePostRequestObj);
        AnyRequest.Execute;

        CreatePostResultObj := RESTResponse1.JSONValue as TJSONObject;
        PostIDAsStr := CreatePostResultObj.GetValue('id').ToString;
      finally
        FreeAndNil(CreatePostRequestObj);
      end;

      {Rectangle1.MakeScreenshot.SaveToFile(TPath.Combine(TPath.GetDocumentsPath,'post.png'));
      // Upload new image (will create new media item)
      FileStream := TFileStream.Create(TPath.Combine(TPath.GetDocumentsPath,'post.png'), fmOpenRead);
      try
        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'media';
        AnyRequest.AddParameter('Content-Type', 'application/binary', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Content-Disposition', 'attachment; filename=post.png', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.Params.AddItem('body', FileStream, pkREQUESTBODY, [poDoNotEncode], ctIMAGE_JPEG);
        AnyRequest.Execute;

        // parse response
        CreateMediaResultObj := RESTResponse1.JSONValue as TJSONObject;
        MediaIDAsStr := CreateMediaResultObj.GetValue('id').ToString;

        try
          MediaHTML := (CreateMediaResultObj.GetValue('description') as TJSONObject).GetValue('rendered').Value;
        except
          MediaHTML := '';
        end;
      finally
        FreeAndNil(FileStream);
        TFile.Delete(TPath.Combine(TPath.GetDocumentsPath,'post.png'));
      end;


      // Update a Media Item
      // https://developer.wordpress.org/rest-api/reference/media/#update-a-media-item
      UpdateMediaRequestObj := TJSONObject.Create;
      try
        UpdateMediaRequestObj.AddPair('id', MediaIDAsStr);
        UpdateMediaRequestObj.AddPair('title', TitleMemo.Lines.Text);
        UpdateMediaRequestObj.AddPair('description', '');
        UpdateMediaRequestObj.AddPair('post', PostIDAsStr); // The ID for the associated post of the attachment.

        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'media/'+MediaIDAsStr;
        AnyRequest.AddParameter('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddBody(UpdateMediaRequestObj);
        AnyRequest.Execute;
      finally
        FreeAndNil(UpdateMediaRequestObj);
      end;    }


      // Update a Post Item (update property featured_media)
      // https://developer.wordpress.org/rest-api/reference/posts/#update-a-post
      UpdatePostRequestObj := TJSONObject.Create;
      try
        UpdatePostRequestObj.AddPair('date', FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', FeedBS.DataSet.FieldByName('datetime').AsDateTime));
        UpdatePostRequestObj.AddPair('date_gmt', FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', FeedBS.DataSet.FieldByName('datetime').AsDateTime));
        UpdatePostRequestObj.AddPair('modified', FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', FeedBS.DataSet.FieldByName('datetime').AsDateTime));
        UpdatePostRequestObj.AddPair('modified_gmt', FormatDateTime('yyyy-mm-dd"T"hh:mm:ss', FeedBS.DataSet.FieldByName('datetime').AsDateTime));
        UpdatePostRequestObj.AddPair('id', PostIDAsStr);
        UpdatePostRequestObj.AddPair('featured_media', MediaIDAsStr); // The ID of the featured media for the object.
        UpdatePostRequestObj.AddPair('content', FeedBS.DataSet.FieldByName('description').AsWideString);
        UpdatePostRequestObj.AddPair('categories', '1');
        UpdatePostRequestObj.AddPair('status', 'publish');

        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'posts/'+PostIDAsStr;
        AnyRequest.AddParameter('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddBody(UpdatePostRequestObj);
        AnyRequest.Execute;

      finally
        FreeAndNil(UpdatePostRequestObj);
      end;

      FeedBS.DataSet.Edit;
      FeedBS.DataSet.FieldByName('posted').AsInteger := 1;
      FeedBS.DataSet.Post;

      FNotifyEvent(Sender);

    except
      on E: Exception do
      begin
        TThread.Synchronize(nil, procedure begin
          ShowMessage(E.Message);
        end);
      end;
    end;


    if Sender is TButton then
      TButton(Sender).Enabled := True;

  end);

end;

procedure TAddFrame.CreatePost(Sender: TObject);
var
  FileStream: TFileStream;
  CreatePostRequestObj: TJSONObject;
  CreatePostResultObj: TJSONObject;
  UpdatePostRequestObj: TJSONObject;
  CreateMediaResultObj : TJSONObject;
  UpdateMediaRequestObj: TJSONObject;
  PostIDAsStr: string;
  MediaIDAsStr: string;
  TestTime: string;
  MediaHTML: string;
begin
  HTTPBasicAuthenticator1.Username := DM.SettingsFDTable.FieldByName('Username').AsString;
  HTTPBasicAuthenticator1.Password := DM.SettingsFDTable.FieldByName('Password').AsString;

  RESTClient1.BaseURL := DM.SettingsFDTable.FieldByName('Endpoint').AsString;

  if Sender is TButton then
    TButton(Sender).Enabled := False;


  TTask.Run(procedure begin

    try

      PostIDAsStr := '';
      MediaIDAsStr := '';
      MediaHTML := '';
      TestTime := ' - '+FormatDateTime('dd-mm-yyyy hh:mm:ss', now);

      // Create new Post
      // https://developer.wordpress.org/rest-api/reference/posts/#create-a-post
      CreatePostRequestObj := TJSONObject.Create;
      try
        CreatePostRequestObj.AddPair('title', TitleMemo.Lines.Text);

        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'posts';
        AnyRequest.AddParameter('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddBody(CreatePostRequestObj);
        AnyRequest.Execute;

        CreatePostResultObj := RESTResponse1.JSONValue as TJSONObject;
        PostIDAsStr := CreatePostResultObj.GetValue('id').ToString;
      finally
        FreeAndNil(CreatePostRequestObj);
      end;

      Rectangle1.MakeScreenshot.SaveToFile(TPath.Combine(TPath.GetDocumentsPath,'post.png'));
      // Upload new image (will create new media item)
      FileStream := TFileStream.Create(TPath.Combine(TPath.GetDocumentsPath,'post.png'), fmOpenRead);
      try
        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'media';
        AnyRequest.AddParameter('Content-Type', 'application/binary', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Content-Disposition', 'attachment; filename=post.png', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.Params.AddItem('body', FileStream, pkREQUESTBODY, [poDoNotEncode], ctIMAGE_JPEG);
        AnyRequest.Execute;

        // parse response
        CreateMediaResultObj := RESTResponse1.JSONValue as TJSONObject;
        MediaIDAsStr := CreateMediaResultObj.GetValue('id').ToString;

        try
          MediaHTML := (CreateMediaResultObj.GetValue('description') as TJSONObject).GetValue('rendered').Value;
        except
          MediaHTML := '';
        end;
      finally
        FreeAndNil(FileStream);
        TFile.Delete(TPath.Combine(TPath.GetDocumentsPath,'post.png'));
      end;


      // Update a Media Item
      // https://developer.wordpress.org/rest-api/reference/media/#update-a-media-item
      UpdateMediaRequestObj := TJSONObject.Create;
      try
        UpdateMediaRequestObj.AddPair('id', MediaIDAsStr);
        UpdateMediaRequestObj.AddPair('title', TitleMemo.Lines.Text);
        UpdateMediaRequestObj.AddPair('description', '');
        UpdateMediaRequestObj.AddPair('post', PostIDAsStr); // The ID for the associated post of the attachment.

        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'media/'+MediaIDAsStr;
        AnyRequest.AddParameter('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddBody(UpdateMediaRequestObj);
        AnyRequest.Execute;
      finally
        FreeAndNil(UpdateMediaRequestObj);
      end;


      // Update a Post Item (update property featured_media)
      // https://developer.wordpress.org/rest-api/reference/posts/#update-a-post
      UpdatePostRequestObj := TJSONObject.Create;
      try
        UpdatePostRequestObj.AddPair('id', PostIDAsStr);
        UpdatePostRequestObj.AddPair('featured_media', MediaIDAsStr); // The ID of the featured media for the object.
        UpdatePostRequestObj.AddPair('content', DescMemo.Lines.Text+'<br/><br/>'+MediaHTML);
        UpdatePostRequestObj.AddPair('status', 'publish');

        AnyRequest.ClearBody;
        AnyRequest.Params.Clear;
        AnyRequest.Method := rmPOST;
        AnyRequest.Resource := 'posts/'+PostIDAsStr;
        AnyRequest.AddParameter('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddParameter('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
        AnyRequest.AddBody(UpdatePostRequestObj);
        AnyRequest.Execute;

      finally
        FreeAndNil(UpdatePostRequestObj);
      end;

    except
      on E: Exception do
      begin
        TThread.Synchronize(nil, procedure begin
          ShowMessage(E.Message);
        end);
      end;
    end;


    if Sender is TButton then
      TButton(Sender).Enabled := True;

  end);

end;

procedure TAddFrame.Image9Click(Sender: TObject);
begin
  Rectangle2.Fill.Bitmap.Bitmap.Assign(TImage(Sender).Bitmap);
end;

procedure TAddFrame.Initialize;
begin
  FeedBS.DataSet := DM.FDTable1;
  ComboBox1.ItemIndex := 2;
  DrawImage;
  Image9Click(Image9);
end;

procedure TAddFrame.ListBoxItem8Click(Sender: TObject);
begin
  Rectangle2.Fill.Bitmap.Bitmap.SetSize(0,0);
end;

procedure TAddFrame.RandomBGButtonClick(Sender: TObject);
begin
  NetHTTPRequest.URL := 'https://picsum.photos/' + GetResolution.ToString;
  NetHTTPRequest.Execute;
end;

procedure TAddFrame.RefreshBGButtonClick(Sender: TObject);
begin
  DrawImage;
end;

procedure TAddFrame.SearchEditButton1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
   begin
    Edit1.Text := OpenDialog1.Files[0];
    Rectangle2.Fill.Bitmap.Bitmap.LoadFromFile(Edit1.Text);
   end;
end;

procedure TAddFrame.SetTextButtonClick(Sender: TObject);
begin
  Text1.Text := TitleMemo.Lines.Text;
  GlowEffect1.UpdateParentEffects;
end;

procedure TAddFrame.LoadBGButtonClick(Sender: TObject);
begin
  if OpenDialog2.Execute then
   begin
    BGPathEdit.Text := OpenDialog2.Files[0];
    DrawImage;
   end;
end;

procedure TAddFrame.TitleMemoChangeTracking(Sender: TObject);
begin
  if TitleMemo.Lines.Text<>'' then
   Text1.Text := TitleMemo.Lines.Text
  else
   Text1.Text := 'Enter Title';
  GlowEffect1.UpdateParentEffects;
end;

procedure TAddFrame.ZoomInButtonClick(Sender: TObject);
begin
  ContentLayout.Scale.X := ContentLayout.Scale.X+0.1;
  ContentLayout.Scale.Y := ContentLayout.Scale.Y+0.1;
end;

procedure TAddFrame.ZoomOutButtonClick(Sender: TObject);
begin
  ContentLayout.Scale.X := ContentLayout.Scale.X-0.1;
  ContentLayout.Scale.Y := ContentLayout.Scale.Y-0.1;
end;

function TAddFrame.GetResolution: Integer;
begin
  case ComboBox1.ItemIndex of
    0: Result := 512;
    1: Result := 768;
    2: Result := 1024;
    3: Result := 1368;
    4: Result := 1536;
  else
    Result := 512;
  end;
end;

procedure TAddFrame.DrawImage;
var
B,B2: TBitmap;
R1,R2: Integer;
Res: Integer;
begin
  Res := GetResolution;
  B := TBitmap.Create;
  B2 := TBitmap.Create;
  if BGPathEdit.Text<>'' then
   begin
    B.LoadFromFile(BGPathEdit.Text);
   end
  else
   begin
    B.Assign(Image8.Bitmap);
   end;
  B2.SetSize(Res,Res);
  B2.Canvas.BeginScene();
  B2.Clear(TAlphaColorRec.Red);
  R1 := RandomRange(0,B.Width-Res);
  R2 := RandomRange(0,B.Height-res);
  B2.CopyFromBitmap(B,Rect(R1,R2,R1+Res,R2+Res),0,0);
  {B2.canvas.Stroke.Kind := TBrushKind.bkSolid;
  B2.canvas.StrokeThickness := 1;
  B2.Canvas.Fill.Color := TAlphaColors.Red;
  B2.Canvas.Font.Size := Text1.TextSettings.Font.Size;
  B2.Canvas.Font.Family := Text1.TextSettings.Font.Family;
  B2.Canvas.Font.StyleExt := Text1.TextSettings.Font.StyleExt;
  B2.Canvas.FillText(RectF(0,0,512,512), 'Hello Text!', false, 100, [TFillTextFlag.ftRightToLeft],
  TTextAlign.taCenter, TTextAlign.taCenter);}
  B2.Canvas.EndScene;
  Rectangle1.BeginUpdate;
  Rectangle1.Fill.Bitmap.Bitmap.Assign(B2);
  Rectangle1.EndUpdate;
  Rectangle1.Repaint;
  B2.Free;
  B.Free;
end;

procedure TAddFrame.NetHTTPRequestRequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
var
  MS: TMemoryStream;
  LFileName: String;
begin
    LFileName := TPath.Combine(TPath.GetDocumentsPath,'random.jpg');
    MS := TMemoryStream.Create;
    try
      MS.LoadFromStream(AResponse.ContentStream);
      MS.SaveToFile(LFileName);

      BGPathEdit.Text := LFileName;
      DrawImage;
    finally
      MS.Free;
    end;
end;

procedure TAddFrame.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var
 TextLayout: TTextLayout;
 TextPath: TPathData;
 //LWidth: string;
begin
 Canvas.Fill := Rectangle3.Fill;
 Canvas.Stroke.Assign( Rectangle3.Stroke );


 TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
 try
  TextPath := TPathData.Create;
  try
   TextLayout.Font := Text1.TextSettings.Font;
   if TitleMemo.Lines.Text<>'' then
    TextLayout.Text := TitleMemo.Lines.Text
   else
    TextLayout.Text := 'Enter Title';
   //TextLayout.HorizontalAlign := TTextAlign.Center;
   TextLayout.ConvertToPath(TextPath);
   //LWidth := TextPath.GetBounds.Width.ToString;
   PaintBox1.Width := TextPath.GetBounds.Width;
   PaintBox1.Position.X := (Text1.Width-PaintBox1.Width) / 2;
   PaintBox1.Position.Y := 45;
   if Self.Width>395 then
     Canvas.DrawPath(TextPath, 0.7);
   Canvas.FillPath(TextPath, 1);
  finally
   TextPath.Free;
  end;
 finally
  TextLayout.Free;
 end;
end;

end.
