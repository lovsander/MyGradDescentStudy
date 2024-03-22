unit gradDescentStudy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TeEngine, Series, ExtCtrls, TeeProcs, Chart, Math, OleCtrls, VCFI,
  StdCtrls, BubbleCh, jpeg;

type
  TGradientDescendForm = class(TForm)
    Chart1: TChart;
    Series1: TPointSeries;
    Series2: TPointSeries;
    ITERATE: TButton;
    Series3: TPointSeries;
    HandMode: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button1: TButton;
    Button2: TButton;
    Button0: TButton;
    xAvgLabel: TLabel;
    yAvgLabel: TLabel;
    AUTO_DECART: TButton;
    EditYconst: TEdit;
    EditXconst: TEdit;
    EditEpsilon: TEdit;
    Label1: TLabel;
    AUTO_VECTORS: TButton;
    Chart2: TChart;
    VectClear: TButton;
    Series5: TLineSeries;
    Chart3: TChart;
    Series6: TPointSeries;
    Series4: TPointSeries;
    ErrCostMethodRadioGroup: TRadioGroup;
    Series7: TPointSeries;
    Sin45RadioGroup: TRadioGroup;
    ellipsnostEdit: TEdit;
    RadiusEdit: TEdit;
    Series8: TPointSeries;
    GrowBtn: TButton;
    GradDescent: TButton;
    procedure FormActivate(Sender: TObject);
    procedure ITERATEClick(Sender: TObject);
    procedure HandModeClick(Sender: TObject);
    function errFunc(dx, dy: Extended): Extended;
    procedure quadroScope();
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure AUTO_DECARTClick(Sender: TObject);
    procedure EditYconstChange(Sender: TObject);
    procedure EditXconstChange(Sender: TObject);
    procedure AUTO_VECTORSClick(Sender: TObject);
    procedure VectClearClick(Sender: TObject);
    function errVectFunc(centrX, centrY: Extended): Extended;
    procedure vectJustDraw(centrX, centrY: Extended);
    procedure Button0Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure GrowBtnClick(Sender: TObject);
    procedure GradDescentClick(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  GradientDescendForm: TGradientDescendForm;
  xArrRaw: array[0..359] of Extended;
  yArrRaw: array[0..359] of Extended;
  xArrNew: array[0..359] of Extended;
  yArrNew: array[0..359] of Extended;
  errorArr: array[0..39] of array[0..39] of Real;
  xmin, xmax, ymin, ymax: Extended;
  xShift, yShift: Extended;

implementation

{$R *.dfm}

procedure TGradientDescendForm.FormActivate(Sender: TObject);
var
  angle: Integer;
begin
  Randomize;
  Series1.clear;
  Series2.clear;
  Series3.clear;
  yShift := strtofloat(EditYconst.text);
  xShift := strtofloat(EditXconst.text);
  Series8.AddXY(xShift, yShift);
  Series8.AddXY(0, 0);
  AUTO_DECART.Caption := 'AUTO_DECART';
  AUTO_VECTORS.Caption := 'AUTO_VECTORS';
  for angle := 0 to 359 do
  begin
    xArrRaw[angle] := strtofloat(RadiusEdit.Text) * strtofloat(ellipsnostEdit.Text) * (0.001 * Random + Cos(degToRad(angle + 0.1 * Random)));
    yArrRaw[angle] := strtofloat(RadiusEdit.Text) * (0.001 * Random + sin(degToRad(angle + 0.1 * Random)));
    Series1.AddXY(xArrRaw[angle], yArrRaw[angle]);

    xArrNew[angle] := xArrRaw[angle] + xShift;
    yArrNew[angle] := yArrRaw[angle] + yShift;
    Series2.AddXY(xArrNew[angle], yArrNew[angle]);
  end;
  ITERATEClick(owner);
end;

//спуск простыми итерациями
procedure TGradientDescendForm.ITERATEClick(Sender: TObject);
var
  dX, dY: Extended;
  errorFunc: Extended;
  stop: Boolean;
  intX, intY: Integer;
begin
  stop := False;
  dX := -2;
  dY := -2;
  intX := 0;
  intY := 0;
  Series3.clear;
  while (stop = False) and (dX <= 2) do
  begin
    while (stop = False) and (dY <= 2) do
    begin
    //выбор метода оценки ошибки
      if ErrCostMethodRadioGroup.ItemIndex = 0 then
      begin
        errorFunc := errFunc(dX, dY);
        errorArr[intX, intY] := errorFunc;
        if (errorFunc > 5) and (errorFunc < 10) then
          Series3.AddXY(dX, dY);
        if (Round(errorFunc) div 100 = 1) then
          Series3.AddXY(dX, dY);
        if (Round(errorFunc) div 500 = 1) then
          Series3.AddXY(dX, dY);
      end
      else
      begin
        errorFunc := errVectFunc(dX, dY);
        errorArr[intX, intY] := errorFunc;
        if (errorFunc > 1) and (errorFunc < 2) then
          Series3.AddXY(dX, dY);
      end;
      if errorFunc <= 0.1 then
      begin
        //stop := True;
        FloatToStrF(dX, ffFixed, 4, 2);
        ITERATE.Caption := 'dX ' + FloatToStrF(dX, ffFixed, 4, 2) + ' dY ' + FloatToStrF(dY, ffFixed, 4, 2);
      end;
      dY := dY + 0.1;
      Inc(intY);
    end;
    dY := -2;
    intY := 0;
    dX := dX + 0.1;
    Inc(intX);
  end;

end;

function TGradientDescendForm.errFunc(dx, dy: Extended): Extended;
var
  errorFunc: Extended;
  i: Integer;
begin
  errorFunc := 0;
  for i := 0 to 359 do
  begin
    errorFunc := errorFunc + Power(xArrRaw[i] - xArrNew[i] + dx, 2);
    errorFunc := errorFunc + Power(yArrRaw[i] - yArrNew[i] + dy, 2);
  end;
  Result := errorFunc;
end;

//ручной спуск
procedure TGradientDescendForm.quadroScope();
const
  sin45 = 0.7071067812;
var
  e0, e1, e2, e3, e4, e5, e6, e7, e8: Extended;
  xavg, yavg: Extended;
begin
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  Series7.Clear;
  Series7.AddXY(xmin, ymin);
  Series7.AddXY(xmin, ymax);
  Series7.AddXY(xmax, ymin);
  Series7.AddXY(xmax, ymax);
  Series7.AddXY(xavg, yavg);
  Series7.AddXY(xmin, xavg);
  Series7.AddXY(xavg, ymax);
  Series7.AddXY(xavg, ymin);
  Series7.AddXY(xmax, xavg);
  if ErrCostMethodRadioGroup.ItemIndex = 0 then
  begin
    //диагональный крест
    if Sin45RadioGroup.ItemIndex = 0 then
    begin
      Series7.AddXY(xavg - sin45 * (xavg - xmin), yavg - sin45 * (yavg - ymin)); //e6
      Series7.AddXY(xavg - sin45 * (xavg - xmin), yavg + sin45 * (ymax - yavg)); //e1
      Series7.AddXY(xavg + sin45 * (xmax - xavg), yavg - sin45 * (yavg - ymin)); //e8
      Series7.AddXY(xavg + sin45 * (xmax - xavg), yavg + sin45 * (ymax - yavg)); //e3

      e1 := errFunc(xavg - sin45 * (xavg - xmin), yavg + sin45 * (ymax - yavg));
      e3 := errFunc(xavg + sin45 * (xmax - xavg), yavg + sin45 * (ymax - yavg));
      e6 := errFunc(xavg - sin45 * (xavg - xmin), yavg - sin45 * (yavg - ymin));
      e8 := errFunc(xavg + sin45 * (xmax - xavg), yavg - sin45 * (yavg - ymin));
    end
    else if Sin45RadioGroup.ItemIndex = 1 then
    // если используем в углах значения самих углов
    begin
      e1 := errFunc(xmin, ymax);
      e3 := errFunc(xmax, ymax);
      e6 := errFunc(xmin, ymin);
      e8 := errFunc(xmax, ymin);
    end;

    // прямой крест
    e0 := errFunc(xavg, yavg);
    e2 := errFunc(xavg, ymax);
    e4 := errFunc(xmin, yavg);
    e5 := errFunc(xmax, yavg);
    e7 := errFunc(xavg, ymin);

    Button0.Caption := FloatToStrF(e0, ffFixed, 4, 2);
    Button1.Caption := FloatToStrF(e1, ffFixed, 4, 2);
    Button2.Caption := FloatToStrF(e2, ffFixed, 4, 2);
    Button3.Caption := FloatToStrF(e3, ffFixed, 4, 2);
    Button4.Caption := FloatToStrF(e4, ffFixed, 4, 2);
    Button5.Caption := FloatToStrF(e5, ffFixed, 4, 2);
    Button6.Caption := FloatToStrF(e6, ffFixed, 4, 2);
    Button7.Caption := FloatToStrF(e7, ffFixed, 4, 2);
    Button8.Caption := FloatToStrF(e8, ffFixed, 4, 2);
  end
  else if ErrCostMethodRadioGroup.ItemIndex = 1 then
  begin

    if Sin45RadioGroup.ItemIndex = 0 then
    begin
      Series7.AddXY(xavg - sin45 * (xavg - xmin), yavg - sin45 * (yavg - ymin)); //e6
      Series7.AddXY(xavg - sin45 * (xavg - xmin), yavg + sin45 * (ymax - yavg)); //e1
      Series7.AddXY(xavg + sin45 * (xmax - xavg), yavg - sin45 * (yavg - ymin)); //e8
      Series7.AddXY(xavg + sin45 * (xmax - xavg), yavg + sin45 * (ymax - yavg)); //e3

      e1 := errVectFunc(xavg - sin45 * (xavg - xmin), yavg + sin45 * (ymax - yavg));
      e3 := errVectFunc(xavg + sin45 * (xmax - xavg), yavg + sin45 * (ymax - yavg));
      e6 := errVectFunc(xavg - sin45 * (xavg - xmin), yavg - sin45 * (yavg - ymin));
      e8 := errVectFunc(xavg + sin45 * (xmax - xavg), yavg - sin45 * (yavg - ymin));
    end
    else if Sin45RadioGroup.ItemIndex = 1 then
    // если используем в углах значения самих углов
    begin
      e1 := errVectFunc(xmin, ymax);
      e3 := errVectFunc(xmax, ymax);
      e6 := errVectFunc(xmin, ymin);
      e8 := errVectFunc(xmax, ymin);
    end;

   // прямой крест
    e0 := errVectFunc(xavg, yavg);
    e2 := errVectFunc(xavg, ymax);
    e4 := errVectFunc(xmin, yavg);
    e5 := errVectFunc(xmax, yavg);
    e7 := errVectFunc(xavg, ymin);

    Button0.Caption := FloatToStrF(e0, ffFixed, 6, 6);
    Button1.Caption := FloatToStrF(e1, ffFixed, 6, 6);
    Button2.Caption := FloatToStrF(e2, ffFixed, 6, 6);
    Button3.Caption := FloatToStrF(e3, ffFixed, 6, 6);
    Button4.Caption := FloatToStrF(e4, ffFixed, 6, 6);
    Button5.Caption := FloatToStrF(e5, ffFixed, 6, 6);
    Button6.Caption := FloatToStrF(e6, ffFixed, 6, 6);
    Button7.Caption := FloatToStrF(e7, ffFixed, 6, 6);
    Button8.Caption := FloatToStrF(e8, ffFixed, 6, 6);
  end;
  vectJustDraw(xavg, yavg); //нарисуем центральную точку в векторах
  Series6.AddY(e0);
  xAvgLabel.Caption := FloatToStrF(xavg, ffFixed, 4, 5);
  yAvgLabel.Caption := FloatToStrF(yavg, ffFixed, 4, 5);
end;

// вход в ручной спуск
procedure TGradientDescendForm.HandModeClick(Sender: TObject);
begin
//задаем границы
  xmin := -2;
  xmax := 2;
  ymin := -2;
  ymax := 2;
  //вручную
  quadroScope();
end;

procedure TGradientDescendForm.Button1Click(Sender: TObject);
begin
  xmin := xmin;
  xmax := (xmin + xmax) / 2;
  ymin := (ymin + ymax) / 2;
  ymax := ymax;
  quadroScope();
end;

procedure TGradientDescendForm.Button3Click(Sender: TObject);
begin

  xmin := (xmin + xmax) / 2;
  xmax := xmax;
  ymin := (ymin + ymax) / 2;
  ymax := ymax;
  quadroScope();
end;

procedure TGradientDescendForm.Button6Click(Sender: TObject);
begin
  xmin := xmin;
  xmax := (xmin + xmax) / 2;
  ymin := ymin;
  ymax := (ymin + ymax) / 2;
  quadroScope();
end;

procedure TGradientDescendForm.Button8Click(Sender: TObject);
begin
  xmin := (xmin + xmax) / 2;
  xmax := xmax;
  ymin := ymin;
  ymax := (ymin + ymax) / 2;
  quadroScope();
end;

//Декартов спуск
procedure TGradientDescendForm.AUTO_DECARTClick(Sender: TObject);
var
  e0, e1, e2, e3, e4, e5, e6, e7, e8: Extended;
  xavg, yavg: Extended;
  next: boolean; // флаг что какое то условие уже выполнено, и можно остальные не проверять. можно заменить на ELSE
begin
//задаем границы
  xmin := -2;
  xmax := 2;
  ymin := -2;
  ymax := 2;
  //первично
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  e0 := errFunc(xavg, yavg);
  Series6.clear;
  Series4.clear;
  //рекурсивно
  while e0 > strToFloat(EditEpsilon.Text) do
  begin
    xavg := (xmin + xmax) / 2;
    yavg := (ymin + ymax) / 2;
// диагональный крест
    e0 := errFunc(xavg, yavg);
    vectJustDraw(xavg, yavg); //нарисуем центральную точку в векторах
    Series7.AddXY(xavg, yavg);
    e1 := errFunc(xmin, ymax);
    e3 := errFunc(xmax, ymax);
    e6 := errFunc(xmin, ymin);
    e8 := errFunc(xmax, ymin);
    next := false;
    if (e1 <= e3) and (e1 <= e6) and (e1 <= e8) and (next = false) then
    begin
      xmin := xmin;
      xmax := (xmin + xmax) / 2;
      ymin := (ymin + ymax) / 2;
      ymax := ymax;
      next := true;
    end;

    if (e3 <= e1) and (e3 <= e6) and (e3 <= e8) and (next = false) then
    begin
      xmin := (xmin + xmax) / 2;
      xmax := xmax;
      ymin := (ymin + ymax) / 2;
      ymax := ymax;
      next := true;
    end;

    if (e6 <= e1) and (e6 <= e3) and (e6 <= e8) and (next = false) then
    begin
      xmin := xmin;
      xmax := (xmin + xmax) / 2;
      ymin := ymin;
      ymax := (ymin + ymax) / 2;
      next := true;
    end;

    if (e8 <= e1) and (e8 <= e3) and (e8 <= e6) and (next = false) then
    begin
      xmin := (xmin + xmax) / 2;
      xmax := xmax;
      ymin := ymin;
      ymax := (ymin + ymax) / 2;
      next := true;
    end;
    Series6.AddY(e0);
  end;
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  AUTO_DECART.Caption := 'DONE!';
  e0 := errFunc(xavg, yavg);
  e1 := errFunc(xmin, ymax);
  e2 := errFunc(xavg, ymax);
  e3 := errFunc(xmax, ymax);
  e4 := errFunc(xmin, yavg);
  e5 := errFunc(xmax, yavg);
  e6 := errFunc(xmin, ymin);
  e7 := errFunc(xavg, ymin);
  e8 := errFunc(xmax, ymin);
  xAvgLabel.Caption := FloatToStrF(xavg, ffFixed, 4, 4);
  yAvgLabel.Caption := FloatToStrF(yavg, ffFixed, 4, 4);
  Button0.Caption := FloatToStrF(e0, ffFixed, 4, 4);
  Button1.Caption := FloatToStrF(e1, ffFixed, 4, 4);
  Button2.Caption := FloatToStrF(e2, ffFixed, 4, 4);
  Button3.Caption := FloatToStrF(e3, ffFixed, 4, 4);
  Button4.Caption := FloatToStrF(e4, ffFixed, 4, 4);
  Button5.Caption := FloatToStrF(e5, ffFixed, 4, 4);
  Button6.Caption := FloatToStrF(e6, ffFixed, 4, 4);
  Button7.Caption := FloatToStrF(e7, ffFixed, 4, 4);
  Button8.Caption := FloatToStrF(e8, ffFixed, 4, 4);
end;

procedure TGradientDescendForm.EditYconstChange(Sender: TObject);
begin
  GradientDescendForm.FormActivate(owner);
end;

procedure TGradientDescendForm.EditXconstChange(Sender: TObject);
begin
  GradientDescendForm.FormActivate(owner);
end;

//отрисовкка векторов
procedure TGradientDescendForm.vectJustDraw(centrX, centrY: Extended);
var
  i: integer;
begin
  for i := 0 to 359 do
  begin
  //из найденной новой вероятной точки центра смещенной окружности,
  //строим радиус-вектор
    Series4.AddXY(i, Sqrt(Sqr(xArrNew[i] - centrX) + Sqr(yArrNew[i] - centrY)));
  end;
end;

//оценка ошибки радиус-векторного авто спуска
function TGradientDescendForm.errVectFunc(centrX, centrY: Extended): Extended;
var
  vectArr: array[0..359] of Double;
  angle: integer;
  StdDeviance: Extended;
begin
  for angle := 0 to 359 do
  begin
  //из найденной новой вероятной точки центра смещенной окружности,
  //строим радиус-вектор
    vectArr[angle] := Sqrt(Sqr(xArrNew[angle] - centrX) + Sqr(yArrNew[angle] - centrY));
    //Series4.AddXY(angle, vectArr[angle]);
  end;
  //Series5.clear;
  //Series5.AddXY(0, mean(vectArr));
  //Series5.AddXY(359, mean(vectArr));

  StdDeviance := StdDev(vectArr);

  Result := StdDeviance;
end;

procedure TGradientDescendForm.VectClearClick(Sender: TObject);
begin
  AUTO_DECART.Caption := 'AUTO_DECART';
  AUTO_VECTORS.Caption := 'AUTO_VECTORS';
  //Series1.clear;
  //Series2.clear;
  Series3.clear;
  Series4.clear;
  Series5.clear;
  Series6.clear;
  Series7.Clear;
  Series8.Clear;
  Series8.AddXY(xShift, yShift);
  Series8.AddXY(0, 0);
end;

//Радиус-Векторный спуск
procedure TGradientDescendForm.AUTO_VECTORSClick(Sender: TObject);
const
  sin45 = 0.7071067812;
var
  e0, e1, e2, e3, e4, e5, e6, e7, e8: Extended; //ошибки по 8ми направлениям и центральная
  xavg, yavg: Extended;
  errChange: Extended; // изменение центральной ошибки
  prevE0: Extended; //для радиус-векторного спуска. Оценка изменения ошибки
  e: array[0..8] of Extended;
  step, i, minDirection, smeznDir1, smeznDir2, takeDir: byte;
  min: Extended; // переменная для нахождения минимума из массива направлений
begin
//задаем границы
  xmin := -2;
  xmax := 2;
  ymin := -2;
  ymax := 2;
//первичноt присвоение

// 99 для отладки и контроля за переменными
  minDirection := 99;
  smeznDir1 := 99;
  smeznDir2 := 99;
  takeDir := 99;
// переменные для расчета ошибок
  errChange := 9999; // инициализация большим числом тк errChange идет на уменьшение
  prevE0 := 9999;
  //график девиации
  Series6.clear;
  Series7.Clear;
  //график радиус-векторов проведенных из разных центров
  Series4.clear;

  // ПОИСК
  // пока ошибка в центральной точке уменьшается, ищем дальше.
  // errChange это разница между предыдущей ошибкой и текущей.
  // характеризует скорость уменьшения ошибки.
  // если скорость снизилась, то можно останавливать процесс.
  while errChange > strToFloat(EditEpsilon.Text) do
  begin
    inc(step);
    xavg := (xmin + xmax) / 2;
    yavg := (ymin + ymax) / 2;
    e[0] := errVectFunc(xavg, yavg);
    //нарисуем распределение радиус-векторов для каждой центральной точки
    vectJustDraw(xavg, yavg);
    // добавим точу сделанного шага на Top view
    Series7.AddXY(xavg, yavg);
    // добавляем точку на график девиации
    Series6.AddY(e[0]);
{
|ось y
|e1 e2 e3
|e4 e0 e5
|e6 e7 e8
|========= ось x
 }
    // диагональный крест

    // если используем в углах значения не самих углов, а радиус-вектора,
    // равного вектору по осям х у ,то домножаем на  sin45 = 0.7071067812
    if Sin45RadioGroup.ItemIndex = 0 then
    begin
      e[1] := errFunc(xavg - sin45 * (xavg - xmin), yavg + sin45 * (ymax - yavg));
      e[3] := errFunc(xavg + sin45 * (xmax - xavg), yavg + sin45 * (ymax - yavg));
      e[6] := errFunc(xavg - sin45 * (xavg - xmin), yavg - sin45 * (yavg - ymin));
      e[8] := errFunc(xavg + sin45 * (xmax - xavg), yavg - sin45 * (yavg - ymin));
    end
    else if Sin45RadioGroup.ItemIndex = 1 then
    // если используем в углах значения самих углов
    begin
      e[1] := errVectFunc(xmin, ymax);
      e[3] := errVectFunc(xmax, ymax);
      e[6] := errVectFunc(xmin, ymin);
      e[8] := errVectFunc(xmax, ymin);
    end;
    // прямой крест
    e[2] := errVectFunc(xavg, ymax);
    e[4] := errVectFunc(xmin, yavg);
    e[5] := errVectFunc(xmax, yavg);
    e[7] := errVectFunc(xavg, ymin);

    // находим самое минимальное значение, кроме нулевого элемента, который в центре. Он часто бывает самым минимальным как раз
    min := e[1];
    minDirection := 1;
    for i := 1 to 8 do
    begin
      if min > e[i] then
      begin
        min := e[i];
        minDirection := i;
      end;
    end;
    // если минимум попал на прямой крест, то надо определиться с квадрантом
    if (minDirection = 2) or (minDirection = 4) or (minDirection = 5) or (minDirection = 7) then
    begin
    // выбираем смежные направления исходя из направления минимума по прямому кресту
      if minDirection = 2 then // верх
      begin
        smeznDir1 := 1;
        smeznDir2 := 3;
      end
      else if minDirection = 4 then  // лево
      begin
        smeznDir1 := 1;
        smeznDir2 := 6;
      end
      else if minDirection = 5 then //право
      begin
        smeznDir1 := 3;
        smeznDir2 := 8;
      end
      else if minDirection = 7 then  //низ
      begin
        smeznDir1 := 6;
        smeznDir2 := 8;
      end;
    //теперь выбираем минимальное
    //из 2х смежных направлений
      if e[smeznDir1] >= e[smeznDir2] then
        takeDir := smeznDir2
      else
        takeDir := smeznDir1;
     // takeDir это индекс той диагонали, куда нам делать шаг
     // ведь мы же в этом методе выбираем диагональные квадранты
     // и не ходим по прямому кресту :(
    end
    // если же минимум сразу попал чисто на диагональный крест
    else if (minDirection = 1) or (minDirection = 3) or (minDirection = 6) or (minDirection = 8) then
    begin
      // просто выбираем квадрант
      takeDir := minDirection;
    end;

    // теперь имея выбранный квадрант,
    // получим новые координаты для нового шага
    if takeDir = 1 then  // если лево-верх
    begin
      xmin := xmin;
      xmax := (xmin + xmax) / 2;
      ymin := (ymin + ymax) / 2;
      ymax := ymax;
    end
    else if takeDir = 3 then // если право-верх
    begin
      xmin := (xmin + xmax) / 2;
      xmax := xmax;
      ymin := (ymin + ymax) / 2;
      ymax := ymax;
    end
    else if takeDir = 6 then  // если лево-низ
    begin
      xmin := xmin;
      xmax := (xmin + xmax) / 2;
      ymin := ymin;
      ymax := (ymin + ymax) / 2;
    end
    else if takeDir = 8 then   // если право-низ
    begin
      xmin := (xmin + xmax) / 2;
      xmax := xmax;
      ymin := ymin;
      ymax := (ymin + ymax) / 2;
    end;

    //оцениваем изменение ошибки по сравнению с пердыдущим разом
    errChange := abs(e[0] - prevE0);
    prevE0 := e[0];
  end;
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  AUTO_VECTORS.Caption := 'DONE!';
  xAvgLabel.Caption := FloatToStrF(xavg, ffFixed, 6, 6);
  yAvgLabel.Caption := FloatToStrF(yavg, ffFixed, 6, 6);
  Button0.Caption := FloatToStrF(e[0], ffFixed, 4, 4);
  Button1.Caption := FloatToStrF(e[1], ffFixed, 4, 4);
  Button2.Caption := FloatToStrF(e[2], ffFixed, 4, 4);
  Button3.Caption := FloatToStrF(e[3], ffFixed, 4, 4);
  Button4.Caption := FloatToStrF(e[4], ffFixed, 4, 4);
  Button5.Caption := FloatToStrF(e[5], ffFixed, 4, 4);
  Button6.Caption := FloatToStrF(e[6], ffFixed, 4, 4);
  Button7.Caption := FloatToStrF(e[7], ffFixed, 4, 4);
  Button8.Caption := FloatToStrF(e[8], ffFixed, 4, 4);
end;

procedure TGradientDescendForm.Button0Click(Sender: TObject);
var
  xavg, yavg: Extended;
begin
//уменьшаем окно в 2 раза!
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  xmin := xmin + (xavg - xmin) / 2;
  xmax := xavg + (xmax - xavg) / 2;
  ymin := ymin + (yavg - ymin) / 2;
  ymax := yavg + (ymax - yavg) / 2;
  quadroScope();
end;

procedure TGradientDescendForm.Button5Click(Sender: TObject);
var
  step: Extended;
  xavg, yavg: Extended;
begin
//уменьшаем окно в 2 раза!
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  xmin := xmin + (xavg - xmin) / 2;
  xmax := xavg + (xmax - xavg) / 2;
  ymin := ymin + (yavg - ymin) / 2;
  ymax := yavg + (ymax - yavg) / 2;
  //шаг
  step := (xmax - xmin) / 2;
  xmin := xmin + step;
  xmax := xmax + step;
  quadroScope();
end;

procedure TGradientDescendForm.Button2Click(Sender: TObject);
var
  step: Extended;
  xavg, yavg: Extended;
begin
//уменьшаем окно в 2 раза!
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  xmin := xmin + (xavg - xmin) / 2;
  xmax := xavg + (xmax - xavg) / 2;
  ymin := ymin + (yavg - ymin) / 2;
  ymax := yavg + (ymax - yavg) / 2;
  //шаг
  step := (ymax - ymin) / 2;
  ymin := ymin + step;
  ymax := ymax + step;
  quadroScope();
end;

procedure TGradientDescendForm.Button4Click(Sender: TObject);
var
  step: Extended;
  xavg, yavg: Extended;
begin
//уменьшаем окно в 2 раза!
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  xmin := xmin + (xavg - xmin) / 2;
  xmax := xavg + (xmax - xavg) / 2;
  ymin := ymin + (yavg - ymin) / 2;
  ymax := yavg + (ymax - yavg) / 2;
  //шаг
  step := (xmax - xmin) / 2;
  xmin := xmin - step;
  xmax := xmax - step;
  quadroScope();
end;

procedure TGradientDescendForm.Button7Click(Sender: TObject);
var
  step: Extended;
  xavg, yavg: Extended;
begin
//уменьшаем окно в 2 раза!
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  xmin := xmin + (xavg - xmin) / 2;
  xmax := xavg + (xmax - xavg) / 2;
  ymin := ymin + (yavg - ymin) / 2;
  ymax := yavg + (ymax - yavg) / 2;
  //шаг
  step := (ymax - ymin) / 2;
  ymin := ymin - step;
  ymax := ymax - step;
  quadroScope();
end;

procedure TGradientDescendForm.GrowBtnClick(Sender: TObject);
var
  xavg, yavg: Extended;
begin
//увеличиваем окно в 4 раза!
  xavg := (xmin + xmax) / 2;
  yavg := (ymin + ymax) / 2;
  xmin := xmin - (xavg - xmin);
  xmax := xmax + xmax - xavg;
  ymin := ymin - (yavg - ymin);
  ymax := ymax + ymax - yavg;
  quadroScope();
end;

procedure TGradientDescendForm.GradDescentClick(Sender: TObject);
var
  alpha: Single;
  J, e, grad0, grad1: Double;
  xOut, yOut: Single;
  converged: Boolean;
  m, iter: Integer;
begin
  iter := 0;
  m := 360;
  xOut := 0;
  yOut := 0;
  J := errVectFunc(xOut, yOut);
  while  converged do
  begin
  //grad0:=
  end;
end;

end.

