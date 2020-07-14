unit uDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Def,
  FireDAC.FMXUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.UI.Intf, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Stan.StorageBin, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Phys.SQLiteWrapper.Stat;

type
  TDM = class(TDataModule)
    SettingsFDTable: TFDTable;
    FDSQLiteSecurity1: TFDSQLiteSecurity;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDConnection1: TFDConnection;
    SettingsFDMemTable: TFDMemTable;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitializeDatabase;
  end;
  const
    DB_FILENAME = 'wpsettings.s3db';
    DB_PASSWORD = '#@IPHi25bhqIb1ibgi4q3';
    DB_ENCRYPTION = 'aes-256';
    DB_TABLE = 'Settings';

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  System.IOUtils;

procedure TDM.InitializeDatabase;
begin
  FDConnection1.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, DB_FILENAME);

  SettingsFDTable.TableName := DB_TABLE;
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
end;

end.
