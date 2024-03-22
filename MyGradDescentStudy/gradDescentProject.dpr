program gradDescentProject;

uses
  Forms,
  gradDescentStudy in 'gradDescentStudy.pas' {GradientDescendForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGradientDescendForm, GradientDescendForm);
  Application.Run;
end.
