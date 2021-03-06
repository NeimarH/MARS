(*
  Copyright 2016, MARS-Curiosity - REST Library

  Home: https://github.com/andrea-magni/MARS
*)
unit Server.Forms.Main;

interface

uses Classes, SysUtils, Forms, ActnList, ComCtrls, StdCtrls, Controls, ExtCtrls
  , Diagnostics

  , MARS.Core.Engine
  , MARS.http.Server.Indy

  , MARS.Core.Application
  , System.Actions
  ;

type
  TMainForm = class(TForm)
    TopPanel: TPanel;
    StartButton: TButton;
    StopButton: TButton;
    MainActionList: TActionList;
    StartServerAction: TAction;
    StopServerAction: TAction;
    StatusLabel: TLabel;
    procedure StartServerActionExecute(Sender: TObject);
    procedure StartServerActionUpdate(Sender: TObject);
    procedure StopServerActionExecute(Sender: TObject);
    procedure StopServerActionUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FServer: TMARShttpServerIndy;
    FEngine: TMARSEngine;
    procedure UpdateStatusLabel;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
    MARS.Core.MessageBodyWriter
  , MARS.Core.MessageBodyWriters
  , MARS.Utils.Parameters.IniFile
  ;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  StartServerAction.Execute;
end;

procedure TMainForm.StartServerActionExecute(Sender: TObject);
begin
  FEngine := TMARSEngine.Create;
  try
    // Engine configuration
    FEngine.Parameters.LoadFromIniFile;

    // Application configuration
    FEngine.AddApplication('DefaultApp', '/default', [ 'Server.Resources.*']);

    // Create http server
    FServer := TMARShttpServerIndy.Create(FEngine);
    try
      if not FServer.Active then
        FServer.Active := True;

      UpdateStatusLabel;
    except
      FreeAndNil(FServer);
      raise;
    end;
  except
    FreeAndNil(FEngine);
    raise;
  end;
end;

procedure TMainForm.StartServerActionUpdate(Sender: TObject);
begin
  StartServerAction.Enabled := (FServer = nil) or (FServer.Active = False);
end;

procedure TMainForm.StopServerActionExecute(Sender: TObject);
begin
  FServer.Active := False;
  FreeAndNil(FServer);

  FreeAndNil(FEngine);

  UpdateStatusLabel;
end;

procedure TMainForm.StopServerActionUpdate(Sender: TObject);
begin
  StopServerAction.Enabled := Assigned(FServer) and (FServer.Active = True);
end;

procedure TMainForm.UpdateStatusLabel;
begin
  if Assigned(FServer) and FServer.Active then
    StatusLabel.Caption := 'Listening on port ' + FEngine.Port.ToString
  else
    StatusLabel.Caption := 'Not active';
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
