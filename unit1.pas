unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  StdCtrls, Grids;

type
  TBook = record
    InvNumber: string[20];
    Author: string[100];
    Title: string[150];
    Year: Integer;
    Pages: Integer;
    InStock: Boolean;
  end;

  TBookArray = array of TBook;

  { TfMain }

  TfMain = class(TForm)
    cbInStock: TCheckBox;
    eInvNumber: TEdit;
    eAuthor: TEdit;
    eTitle: TEdit;
    eYear: TEdit;
    ePages: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    miAddRecord: TMenuItem;
    miEditRecord: TMenuItem;
    miDeleteRecord: TMenuItem;
    miSort: TMenuItem;
    miSearchRecord: TMenuItem;
    miClearRecord: TMenuItem;
    miSortAsc: TMenuItem;
    miSortDesc: TMenuItem;
    miRecord: TMenuItem;
    miNewFile: TMenuItem;
    miOpenFile: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miFile: TMenuItem;
    miCloseFile: TMenuItem;
    miExit: TMenuItem;
    PanelInput: TPanel;
    SG: TStringGrid;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure miNewFileClick(Sender: TObject);
    procedure miOpenFileClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure miCloseFileClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);

    procedure miAddRecordClick(Sender: TObject);
    procedure miEditRecordClick(Sender: TObject);
    procedure miDeleteRecordClick(Sender: TObject);
    procedure miSortAscClick(Sender: TObject);
    procedure miSortDescClick(Sender: TObject);
    procedure miSearchRecordClick(Sender: TObject);
    procedure miClearRecordClick(Sender: TObject);

    procedure SGSelectCell(Sender: TObject; aCol, aRow: Integer;
              var CanSelect: Boolean);
    procedure SGClick(Sender: TObject);

  private
    Books: TBookArray;
    CurrentFileName: string;
    Modified: Boolean;
    SelectedIndex: Integer;

    procedure InitGrid;
    procedure RefreshGrid;
    procedure ClearInputs;
    procedure FillInputsFromRow(Row: Integer);
    function GetBookFromInputs(out B: TBook): Boolean;

    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
    function AskSaveIfModified: Boolean;

    function ChooseSortField: Integer;
    function CompareBooks(const A, B: TBook; Field: Integer): Integer;
    procedure SortBooks(Field: Integer; Ascending: Boolean);

  public

  end;

var
  fMain: TfMain;

implementation

{$R *.lfm}

{ TfMain }

procedure TfMain.FormCreate(Sender: TObject);
begin
  Caption := 'Книги в библиотеке';

  CurrentFileName := ExtractFilePath(ParamStr(0)) + 'books.dat';
  Modified := False;
  SelectedIndex := -1;

  InitGrid;

  if FileExists(CurrentFileName) then
    LoadFromFile(CurrentFileName)
  else
    SaveToFile(CurrentFileName);
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := AskSaveIfModified;
end;

procedure TfMain.InitGrid;
begin
  SG.ColCount := 6;
  SG.RowCount := 1;
  SG.FixedRows := 1;
  SG.FixedCols := 0;

  SG.Cells[0, 0] := 'Инв. номер';
  SG.Cells[1, 0] := 'Автор';
  SG.Cells[2, 0] := 'Название';
  SG.Cells[3, 0] := 'Год';
  SG.Cells[4, 0] := 'Страниц';
  SG.Cells[5, 0] := 'В фонде';

  SG.ColWidths[0] := 100;
  SG.ColWidths[1] := 170;
  SG.ColWidths[2] := 250;
  SG.ColWidths[3] := 80;
  SG.ColWidths[4] := 80;
  SG.ColWidths[5] := 90;
end;

procedure TfMain.RefreshGrid;
var
  i: Integer;
begin
  SG.RowCount := Length(Books) + 1;

  for i := 0 to High(Books) do
  begin
    SG.Cells[0, i + 1] := Books[i].InvNumber;
    SG.Cells[1, i + 1] := Books[i].Author;
    SG.Cells[2, i + 1] := Books[i].Title;
    SG.Cells[3, i + 1] := IntToStr(Books[i].Year);
    SG.Cells[4, i + 1] := IntToStr(Books[i].Pages);

    if Books[i].InStock then
      SG.Cells[5, i + 1] := 'Да'
    else
      SG.Cells[5, i + 1] := 'Нет';
  end;

  SelectedIndex := -1;
end;

procedure TfMain.ClearInputs;
begin
  eInvNumber.Clear;
  eAuthor.Clear;
  eTitle.Clear;
  eYear.Clear;
  ePages.Clear;
  cbInStock.Checked := False;
  SelectedIndex := -1;
end;

procedure TfMain.FillInputsFromRow(Row: Integer);
begin
  if (Row < 1) or (Row > Length(Books)) then Exit;

  eInvNumber.Text := Books[Row - 1].InvNumber;
  eAuthor.Text := Books[Row - 1].Author;
  eTitle.Text := Books[Row - 1].Title;
  eYear.Text := IntToStr(Books[Row - 1].Year);
  ePages.Text := IntToStr(Books[Row - 1].Pages);
  cbInStock.Checked := Books[Row - 1].InStock;
end;

function TfMain.GetBookFromInputs(out B: TBook): Boolean;
begin
  Result := False;

  if Trim(eInvNumber.Text) = '' then
  begin
    ShowMessage('Введите инвентарный номер.');
    eInvNumber.SetFocus;
    Exit;
  end;

  if Trim(eAuthor.Text) = '' then
  begin
    ShowMessage('Введите автора.');
    eAuthor.SetFocus;
    Exit;
  end;

  if Trim(eTitle.Text) = '' then
  begin
    ShowMessage('Введите название книги.');
    eTitle.SetFocus;
    Exit;
  end;

  if Trim(eYear.Text) = '' then
  begin
    ShowMessage('Введите год издания.');
    eYear.SetFocus;
    Exit;
  end;

  if Trim(ePages.Text) = '' then
  begin
    ShowMessage('Введите количество страниц.');
    ePages.SetFocus;
    Exit;
  end;

  if not TryStrToInt(eYear.Text, B.Year) then
  begin
    ShowMessage('Год издания должен быть числом.');
    eYear.SetFocus;
    Exit;
  end;

  if not TryStrToInt(ePages.Text, B.Pages) then
  begin
    ShowMessage('Количество страниц должно быть числом.');
    ePages.SetFocus;
    Exit;
  end;

  if (B.Year < 1000) or (B.Year > 2100) then
  begin
    ShowMessage('Год издания должен быть в диапазоне от 1000 до 2100.');
    eYear.SetFocus;
    Exit;
  end;

  if B.Pages <= 0 then
  begin
    ShowMessage('Количество страниц должно быть больше нуля.');
    ePages.SetFocus;
    Exit;
  end;

  B.InvNumber := Trim(eInvNumber.Text);
  B.Author := Trim(eAuthor.Text);
  B.Title := Trim(eTitle.Text);
  B.InStock := cbInStock.Checked;

  Result := True;
end;

procedure TfMain.SaveToFile(const FileName: string);
var
  f: file of TBook;
  i: Integer;
begin
  try
    AssignFile(f, FileName);
    Rewrite(f);

    try
      for i := 0 to High(Books) do
        Write(f, Books[i]);
    finally
      CloseFile(f);
    end;

    CurrentFileName := FileName;
    Modified := False;

    //ShowMessage('Файл сохранён.');
  except
    on E: EInOutError do
      ShowMessage(
        'Ошибка ввода-вывода при сохранении файла.' + LineEnding +
        'Проверьте, есть ли место на диске, права на запись, ' +
        'и не открыт ли файл другой программой.' + LineEnding +
        'Подробности: ' + E.Message
      );

    on E: Exception do
      ShowMessage(
        'Не удалось сохранить файл.' + LineEnding +
        'Подробности: ' + E.Message
      );
  end;
end;

procedure TfMain.LoadFromFile(const FileName: string);
var
  f: file of TBook;
  B: TBook;
begin
  if not FileExists(FileName) then
  begin
    if MessageDlg(
      'Файл не найден. Создать новый файл?',
      mtConfirmation,
      [mbYes, mbNo],
      0
    ) = mrYes then
    begin
      SetLength(Books, 0);
      CurrentFileName := FileName;
      SaveToFile(CurrentFileName);
      RefreshGrid;
      ClearInputs;
    end;

    Exit;
  end;

  try
    SetLength(Books, 0);

    AssignFile(f, FileName);
    Reset(f);

    try
      while not Eof(f) do
      begin
        Read(f, B);

        SetLength(Books, Length(Books) + 1);
        Books[High(Books)] := B;
      end;
    finally
      CloseFile(f);
    end;

    CurrentFileName := FileName;
    Modified := False;
    RefreshGrid;
    ClearInputs;

    //ShowMessage('Файл открыт.');
  except
    on E: EInOutError do
    begin
      ShowMessage(
        'Ошибка ввода-вывода при открытии файла.' + LineEnding +
        'Возможно, файл открыт другой программой, нет прав доступа ' +
        'или файл повреждён.' + LineEnding +
        'Подробности: ' + E.Message
      );

      SetLength(Books, 0);
      RefreshGrid;
    end;

    on E: Exception do
    begin
      ShowMessage(
        'Файл имеет некорректный формат или повреждён.' + LineEnding +
        'Файл не открыт.' + LineEnding +
        'Подробности: ' + E.Message
      );

      SetLength(Books, 0);
      RefreshGrid;
    end;
  end;
end;

function TfMain.AskSaveIfModified: Boolean;
var
  Answer: Integer;
begin
  Result := True;

  if not Modified then Exit;

  Answer := MessageDlg(
    'Есть несохранённые изменения. Сохранить?',
    mtConfirmation,
    [mbYes, mbNo, mbCancel],
    0
  );

  if Answer = mrYes then
    SaveToFile(CurrentFileName)
  else if Answer = mrCancel then
    Result := False;
end;

procedure TfMain.miNewFileClick(Sender: TObject);
begin
  if not AskSaveIfModified then Exit;

  SetLength(Books, 0);
  CurrentFileName := ExtractFilePath(ParamStr(0)) + 'books.dat';
  Modified := False;

  RefreshGrid;
  ClearInputs;
end;

procedure TfMain.miOpenFileClick(Sender: TObject);
var
  OD: TOpenDialog;
begin
  if not AskSaveIfModified then Exit;

  OD := TOpenDialog.Create(Self);
  try
    OD.Filter := 'Файлы данных (*.dat)|*.dat|Все файлы (*.*)|*.*';
    OD.InitialDir := ExtractFilePath(ParamStr(0));

    if OD.Execute then
      LoadFromFile(OD.FileName);
  finally
    OD.Free;
  end;
end;

procedure TfMain.miSaveClick(Sender: TObject);
begin
  SaveToFile(CurrentFileName);
end;

procedure TfMain.miSaveAsClick(Sender: TObject);
var
  SD: TSaveDialog;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.Filter := 'Файлы данных (*.dat)|*.dat|Все файлы (*.*)|*.*';
    SD.DefaultExt := 'dat';
    SD.InitialDir := ExtractFilePath(ParamStr(0));

    if SD.Execute then
      SaveToFile(SD.FileName);
  finally
    SD.Free;
  end;
end;

procedure TfMain.miCloseFileClick(Sender: TObject);
begin
  if not AskSaveIfModified then Exit;

  SetLength(Books, 0);
  RefreshGrid;
  ClearInputs;
  Modified := False;
end;

procedure TfMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfMain.miAddRecordClick(Sender: TObject);
var
  B: TBook;
begin
  if not GetBookFromInputs(B) then Exit;

  SetLength(Books, Length(Books) + 1);
  Books[High(Books)] := B;

  Modified := True;
  RefreshGrid;
  SaveToFile(CurrentFileName);
  ClearInputs;
end;

procedure TfMain.miEditRecordClick(Sender: TObject);
var
  B: TBook;
begin
  if (SelectedIndex < 0) or (SelectedIndex > High(Books)) then
  begin
    ShowMessage('Выберите запись для редактирования.');
    Exit;
  end;

  if not GetBookFromInputs(B) then Exit;

  Books[SelectedIndex] := B;

  Modified := True;
  RefreshGrid;
  SaveToFile(CurrentFileName);
  ClearInputs;
end;

function TfMain.ChooseSortField: Integer;
var
  S: string;
begin
  Result := -1;

  S := InputBox(
    'Сортировка',
    'Введите номер поля:' + LineEnding +
    '1 - Инвентарный номер' + LineEnding +
    '2 - Автор' + LineEnding +
    '3 - Название' + LineEnding +
    '4 - Год издания' + LineEnding +
    '5 - Количество страниц' + LineEnding +
    '6 - Наличие в фонде',
    '1'
  );

  if not TryStrToInt(S, Result) then
  begin
    ShowMessage('Нужно ввести число от 1 до 6.');
    Result := -1;
    Exit;
  end;

  if (Result < 1) or (Result > 6) then
  begin
    ShowMessage('Нужно ввести число от 1 до 6.');
    Result := -1;
  end;
end;

function TfMain.CompareBooks(const A, B: TBook; Field: Integer): Integer;
begin
  Result := 0;

  case Field of
    1: Result := CompareText(A.InvNumber, B.InvNumber);
    2: Result := CompareText(A.Author, B.Author);
    3: Result := CompareText(A.Title, B.Title);
    4:
      if A.Year < B.Year then Result := -1
      else if A.Year > B.Year then Result := 1;
    5:
      if A.Pages < B.Pages then Result := -1
      else if A.Pages > B.Pages then Result := 1;
    6:
      if A.InStock = B.InStock then Result := 0
      else if A.InStock = False then Result := -1
      else Result := 1;
  end;
end;

procedure TfMain.SortBooks(Field: Integer; Ascending: Boolean);
var
  i, j: Integer;
  Temp: TBook;
  C: Integer;
begin
  for i := 0 to High(Books) - 1 do
    for j := i + 1 to High(Books) do
    begin
      C := CompareBooks(Books[i], Books[j], Field);

      if (Ascending and (C > 0)) or
         ((not Ascending) and (C < 0)) then
      begin
        Temp := Books[i];
        Books[i] := Books[j];
        Books[j] := Temp;
      end;
    end;

  Modified := True;
  RefreshGrid;
  SaveToFile(CurrentFileName);
end;

procedure TfMain.miSortAscClick(Sender: TObject);
var
  Field: Integer;
begin
  if Length(Books) = 0 then
  begin
    ShowMessage('Нет записей для сортировки.');
    Exit;
  end;

  Field := ChooseSortField;
  if Field <> -1 then
    SortBooks(Field, True);
end;

procedure TfMain.miSortDescClick(Sender: TObject);
var
  Field: Integer;
begin
  if Length(Books) = 0 then
  begin
    ShowMessage('Нет записей для сортировки.');
    Exit;
  end;

  Field := ChooseSortField;
  if Field <> -1 then
    SortBooks(Field, False);
end;

procedure TfMain.miSearchRecordClick(Sender: TObject);
var
  Query: string;
  i: Integer;
begin
  Query := InputBox('Поиск записи', 'Введите текст для поиска:', '');

  if Query = '' then Exit;

  Query := AnsiLowerCase(Query);

  for i := 0 to High(Books) do
  begin
    if (Pos(Query, AnsiLowerCase(Books[i].InvNumber)) > 0) or
       (Pos(Query, AnsiLowerCase(Books[i].Author)) > 0) or
       (Pos(Query, AnsiLowerCase(Books[i].Title)) > 0) or
       (Pos(Query, AnsiLowerCase(IntToStr(Books[i].Year))) > 0) or
       (Pos(Query, AnsiLowerCase(IntToStr(Books[i].Pages))) > 0) then
    begin
     SG.Row := i + 1;
      SelectedIndex := i;
      FillInputsFromRow(i + 1);
      ShowMessage('Запись найдена.');
      Exit;
    end;
  end;

  ShowMessage('Запись не найдена.');
end;

procedure TfMain.miClearRecordClick(Sender: TObject);
begin
  ClearInputs;
end;

procedure TfMain.SGSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if aRow >= 1 then
  begin
    SelectedIndex := aRow - 1;
    FillInputsFromRow(aRow);
  end
  else
    SelectedIndex := -1;
end;

procedure TfMain.miDeleteRecordClick(Sender: TObject);
var
  i: Integer;
begin
  if (SelectedIndex < 0) or (SelectedIndex > High(Books)) then
  begin
    ShowMessage('Выберите запись для удаления.');
    Exit;
  end;

  if MessageDlg('Удалить выбранную запись?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then Exit;

  for i := SelectedIndex to High(Books) - 1 do
    Books[i] := Books[i + 1];

  SetLength(Books, Length(Books) - 1);

  Modified := True;
  RefreshGrid;
  SaveToFile(CurrentFileName);
  ClearInputs;
end;

procedure TfMain.SGClick(Sender: TObject);
begin
  if (SG.Row >= 1) and (SG.Row <= Length(Books)) then
  begin
    SelectedIndex := SG.Row - 1;
    FillInputsFromRow(SG.Row);
  end
  else
    SelectedIndex := -1;
end;

end.
