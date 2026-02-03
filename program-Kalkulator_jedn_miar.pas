program Kalkulator_jedn_miar;
{$AT TStringGrid}
{$AT TButton}
{$AT TComboBox}
{$AT TfWindowPlugins}
{$AT TWindowPlugins}

var my_Form1: TForm;
  my_Label0,my_Label00,my_Label1,my_Label2: TLabel;
  my_Edit1: TEdit;
  my_ComboBox0, my_ComboBox2: TComboBox;
  my_Button1,my_Button2,my_Button3,my_Button4,my_Button5: TButton;
  my_StringGrid4: TStringGrid;
  my_PopupMenu4: TPopupMenu;
  my_MenuItem4: TMenuItem;
  numer: integer;
  id_kartoteka1: INTEGER;
  okno: TWindowPlugins;
  ilosc: currency;
  id_jm: string;
  t1: boolean;
  Component1: TComponent;
  pierwszy_raz: boolean;

procedure wypelnij_Combo(var my_Combo: TComboBox);
var
  my_query1: TDataSource;
  a: string;
begin
  my_Combo.Items.clear;
  a:=getfromquerysql('SELECT J.JM FROM KARTOTEKA KJ join JM J on J.ID_JM=KJ.ID_JM'
  +' where KJ.ID_KARTOTEKA='+inttostr(id_kartoteka1),0);
  my_Combo.Items.Add(a);
  my_query1:=OpenQuerysql('SELECT J.JM FROM KARTZASTJM KJ join JM J on J.ID_JM=KJ.ID_JM'
  +' where KJ.ID_KARTOTEKA='+inttostr(id_kartoteka1),0);
  if my_query1<>nil then begin
    my_query1.Dataset.First;
    while not my_query1.dataset.Eof do begin
      my_Combo.Items.Add(my_query1.DataSet.FIELDBYNAME('JM').asstring);
      my_query1.dataset.Next;
    end;
    closequerysql(my_query1);
  end;
  my_Combo.Text:=a;
end;

procedure czysc_stringGrid;
var j: integer;
begin
    my_StringGrid4.rowcount:=15;
    j:=10;
    while j>0 do begin dec(j)
      my_stringGrid4.setcells(0,j,'');
      my_stringGrid4.setcells(1,j,'');
      my_stringGrid4.setcells(2,j,'');
    end;

    my_stringGrid4.setcells(0,0,'Jm');
    my_stringGrid4.setcells(1,0,'Opis');
    my_stringGrid4.setcells(2,0,'Ilość');
end;

procedure zmien_dane;
var my_query1: TDataSource;
  i: integer;
begin
  if t1 then begin
    czysc_stringGrid;
    i:=0;
    my_query1:=openquerysql('select XXX.ID_JM2,XXX.JM2,XXX.OPISJM2,XXX.ILOSC2'
    +' from SP$_XXX_MK_OBLICZJM('+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+','+id_jm+','+inttostr(id_kartoteka1)+') XXX',0);
    if my_query1<>nil then begin
      my_query1.dataset.first;
      while not my_query1.dataset.Eof do begin
        inc(i);
        my_stringGrid4.setcells(0,i,my_query1.dataset.fieldbyname('JM2').asstring);
        my_stringGrid4.setcells(1,i,my_query1.dataset.fieldbyname('OPISJM2').asstring);
        my_stringGrid4.setcells(2,i,my_query1.dataset.fieldbyname('ILOSC2').asstring);

        my_query1.dataset.Next;
      end;
      closequerysql(my_query1);
      my_stringGrid4.rowcount:=i+1;
    end;

    (*
    if TfWindowPlugins(okno).DS_main<>nil then begin
      TfWindowPlugins(okno).DS_main.Dataset.close;
      TfWindowPlugins(okno).DS_main.Dataset.open;
    end;
    *)
  end;

end;

procedure zatwierdzenie_danych(asender: TObject);
var sql: string;
begin
  t1:=True;
  try
    ilosc:=strtocurr(stringreplace(my_Edit1.Text,'.',',',[rfReplaceall]));
  except
    t1:=False;
    inf300('Nieprawidłowa ilość');
  end;
  if t1 then begin
    sql:='select j.id_jm from jm j where j.jm='''+my_ComboBox2.Text+''''
    //inf300(sql);
    id_jm:=getfromquerysql(sql,0);
  end;

  if t1 then begin
      zmien_dane;
  end;
end;



procedure my_ComboBox0_OnChange(asender: TObject);
var
  ComboBox: TComboBox;
  a: string;
begin
  my_ComboBox2.Clear;
  my_Edit1.text:='';
  ComboBox:=TComboBox(asender);
  a:=ComboBox.Text;
  //inf300('a='+a);
  id_kartoteka1:=strtoint('0'+getfromquerysql('select id_kartoteka from Kartoteka where indeks='''+a+'''',0));
  //inf300('id_kartoteka='+inttostr(id_kartoteka1))

  wypelnij_combo(my_ComboBox2);
  czysc_stringGrid;
  my_Label00.Caption:=getfromquerysql('select nazwadl from kartoteka where id_kartoteka='+inttostr(id_kartoteka1),0);

  //my_Edit1.SetFocus;


  {
  b:=getfromquerysql('SELECT J.JM FROM KARTOTEKA KJ join JM J on J.ID_JM=KJ.ID_JM'
  +' where KJ.ID_KARTOTEKA='+inttostr(id_kartoteka1),0);
  inf300('b='+b);
  my_ComboBox2.items.add(b);
  my_ComboBox2.Text:=b;
  }



end;

procedure Edit1KeyPress (Sender: TObject; var Key: Char) ;
begin
   If Key = #13 Then Begin
     Key := #0
     zatwierdzenie_danych(Sender);
   end;
end;


procedure my_MenuItem4OnClick(asender: TObject);
var acol,arow: integer;
  a: string;
  rect1: Trect;
begin
  a:='';
  rect1:=my_StringGrid4.selection;
  for aRow:=rect1.top to rect1.bottom do begin
    for acol:=rect1.left to rect1.right do begin
      a:=a+my_StringGrid4.GetCells(ACol,ARow)+#9;
    end;
    a:=a+#13+#10;
  end;
  Clipboard.AsText:=a;
end;

procedure pobierz_dane;//(ID_KARTOTEKA: integer;var ilosc: currency;var id_jm: string);
var
  //i: integer;
  my_query1: TDataSource;
begin
  t1:=False;
  if Component1<>nil then begin
      my_Button1:=Component1.FindComponent('my_Button5') as TButton; //close dataset
      (***
      if my_Button1=nil then begin
        inf300('brak przycisku na '+Component1.Name);
      end else begin
        inf300('JEST przycisk na '+Component1.Name);

      end;
      ***)
      my_Button2:=Component1.FindComponent('my_Button6') as TButton; //open dataset

      my_Button4:=Component1.FindComponent('my_Button7') as TButton; //open dataset
      my_Button5:=Component1.FindComponent('my_Button8') as TButton; //open dataset
  end;

  my_Form1:=TForm.Create(self);
  try
    my_Form1.Caption:='Kalkulator jednostek miar';
    my_Form1.Height:=500;
    my_Form1.Width:=600;

    my_Label0:=TLabel.Create(my_Form1);
    my_Label0.Parent:=my_Form1;
    my_Label0.Caption:='Indeks';
    my_Label0.Left:=10;
    my_Label0.Top:=15+2;
    my_Label0.Width:=55;

    my_ComboBox0:=TComboBox.Create(my_Form1);
    my_ComboBox0.Parent:=my_Form1;
    my_ComboBox0.Left:=80;
    my_ComboBox0.Top:=15+25-25;
    my_ComboBox0.Width:=400+90;
    //my_ComboBox0.MaxLength:=20;
    my_ComboBox0.sorted:=True;
    my_ComboBox0.Onchange:=@my_ComboBox0_Onchange;

    my_Label00:=TLabel.Create(my_Form1);
    my_Label00.Parent:=my_Form1;
    my_Label00.Caption:='';
    my_Label00.Left:=80; //290;
    my_Label00.Top:=15+2+25;
    my_Label00.Width:=350;

    my_Label2:=TLabel.Create(my_Form1);
    my_Label2.Parent:=my_Form1;
    my_Label2.Caption:='Jednostka';
    my_Label2.Left:=10;
    my_Label2.Top:=15+25+2+25;
    my_Label2.Width:=55;

    my_ComboBox2:=TComboBox.Create(my_Form1);
    my_ComboBox2.Parent:=my_Form1;
    my_ComboBox2.Left:=80;
    my_ComboBox2.Top:=15+25+25;
    my_ComboBox2.Width:=80;
    wypelnij_Combo(my_ComboBox2);

    my_Label1:=TLabel.Create(my_Form1);
    my_Label1.Parent:=my_Form1;
    my_Label1.Caption:='Ilość';
    my_Label1.Left:=10;
    my_Label1.Top:=15+25+2+25+50;
    my_Label1.Width:=55;

    My_Edit1:=TEdit.Create(my_Form1);
    my_Edit1.Parent:=my_Form1;
    my_Edit1.Left:=80;
    my_Edit1.Top:=15+25+25+50;
    my_Edit1.Width:=80;
    my_Edit1.OnKeyPress:=@Edit1KeyPress;

    my_Button3:=TButton.Create(my_Form1);
    my_Button3.Parent:=my_Form1;
    my_Button3.Caption:='Ok';
    my_Button3.Left:=80;
    my_Button3.Top:=15+25+25+25+75;
    my_Button3.Width:=70;
    my_Button3.OnClick:=@zatwierdzenie_danych;

    my_PopupMenu4:=TPopupMenu.Create(my_Form1);
    my_MenuItem4:=TMenuItem.Create(my_Form1);
    my_MenuItem4.Caption:='Kopiuj';
    my_MenuItem4.ShortCut:=TextToShortCut('Ctrl+C');
    my_MenuItem4.OnClick:=@my_MenuItem4OnClick;
    my_PopupMenu4.Items.Add(my_MenuItem4);

    my_StringGrid4:=TStringGrid.Create(my_Form1);
    my_StringGrid4.Parent:=my_Form1;
    my_StringGrid4.Anchors:=[akLeft, akRight, akTop, akBottom];
    my_StringGrid4.Left:=170;
    my_StringGrid4.Top:=15+25+25;
    my_StringGrid4.Width:=400;
    my_StringGrid4.Height:=385;
    my_StringGrid4.colcount:=3;
    my_StringGrid4.rowcount:=15;
    my_StringGrid4.FixedRows:=0;
    my_StringGrid4.FixedCols:=0;
    my_StringGrid4.DefaultColWidth:=100;
    my_StringGrid4.PopupMenu:=my_PopupMenu4;
    my_StringGrid4.Options := my_StringGrid4.Options + [goRangeSelect];
    //goEditing,goAlwaysShowEditor
    my_query1:=openquerysql('select INDEKS from kartoteka where nazwadl like ''Sklejka%''',0);
    if my_query1<>nil then begin
      my_query1.dataset.First;
      while not my_query1.dataset.Eof do begin
        my_ComboBox0.Items.add(my_query1.dataset.FIELDBYNAME('INDEKS').asstring);
        my_query1.dataset.Next;
      end;
      closequerysql(my_query1);
    end;


    //my_StringGrid4.SelectCell(ACol:LongInt; ARow:LongInt)
    //my_StringGrid4.get
    //my_StringGrid4.Align:=alRight;

    //numer:=my_Form1.Showmodal;
    my_Form1.Show;

  finally

    //ilosc:=1;
    //id_jm:='10018';

    {
    if my_SpinEdit1<>nil then WIERSZ_DANE:=my_SpinEdit1.Value;
    if my_SpinEdit2<>nil then KOLUMNA_INDEKS:=my_SpinEdit2.Value;
    if my_SpinEdit3<>nil then KOLUMNA_ILOSC:=my_SpinEdit3.Value;
    if my_SpinEdit4<>nil then KOLUMNA_CENA:=my_SpinEdit4.Value;
    }
    //my_Form1.Free;
  end;
end;

procedure ustaw_przyciski_close_open;
var i: integer;
begin
  i:=0; component1:=nil;
  while i<application.ComponentCount do begin
    inc(i);
    if Application.Components[i-1]<>nil
    then begin
      if Application.Components[i-1].Name='fWindowPlugins' then begin
        Component1:=Application.Components[i-1];
      end;
    end;
  end;
  if Component1<>nil then begin
    //inf300('jest komponent - ' + TfWindowPlugins(Component1).Caption+' - WindowId='+inttostr(TfWindowPlugins(Component1).WindowId));

  end;
end;


procedure zmiana_danych(asender: TObject);
begin
  //daj_kartoteke;
  //id_kartoteka1:=Slownik('KARTOTEKA')
  //okno.Refresh;
  pobierz_dane;
end;

procedure daj_okno;
var
  i: integer;
begin
  okno:=TWindowPlugins.Create(7);
  try
    okno.Caption:='Ilości w różnych jednostkach';
    okno.IdColumns:='ID_JM2'
    //okno.sqlset('J.ID_JM','JM J','','','','');
    {
    okno.sqlset('K.ID_JM,K.LICZNIK,K.MIANOWNIK,J.JM,J.OPISJM,'+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+' ILOSC'
    ,'KARTZASTJM K'
    +' join JM J on J.ID_JM=K.ID_JM'
    ,'K.ID_KARTOTEKA='+inttostr(id_kartoteka)
    ,'','','');
    }
    zmien_dane;

    okno.AddFieldsXXX('SP$_XXX_MK_OBLICZJM('+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+','+id_jm+','+inttostr(id_kartoteka1)+')','ID_JM2','id_jm','XXX');
    //okno.LastField.VISIBLE:=False;

     okno.AddFieldsXXX('SP$_XXX_MK_OBLICZJM('+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+','+id_jm+','+inttostr(id_kartoteka1)+')','JM2','Jm','XXX');
     okno.AddFieldsXXX('SP$_XXX_MK_OBLICZJM('+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+','+id_jm+','+inttostr(id_kartoteka1)+')','OPISJM2','Nazwa jm','XXX');
     okno.AddFieldsXXX('SP$_XXX_MK_OBLICZJM('+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+','+id_jm+','+inttostr(id_kartoteka1)+')','ILOSC2','Ilość','XXX');


    pierwszy_raz:=True;

    ustaw_przyciski_close_open;

    if my_Button5<>nil then my_Button5.Click; //szerokości kolumn

    (***
    okno.sqlset('XXX.ID_JM2,XXX.JM2,XXX.OPISJM2,XXX.ILOSC2'
    ,'SP$_XXX_MK_OBLICZJM('+stringreplace(currtostr(ilosc),',','.',[rfReplaceall])+','+id_jm+','+inttostr(id_kartoteka1)+') XXX'
    ,'','','','');
    ***)

{
     my_okno.AddFields('KARTOTEKA','ID_KARTOTEKA','K');
     my_okno.LastField.VISIBLE:=False;
     my_okno.AddFields('KARTOTEKA','INDEKS','K');
     my_okno.AddFields('KARTOTEKA','NAZWASKR','K');
     my_okno.AddFields('KARTOTEKA','NAZWADL','K');
     my_okno1.AddFieldsXXX('XXX_PRZEKLADNIE7_MK('+inttostr(id_grupakart1)+my_sql31+')','CECHA'+inttostr(k),b,'X');
}
    okno.AddAction('Zmień dane','calculator_invoice_24',@zmiana_danych);

    if okno.ShowWindow(i) then begin
    end;
  finally
    //if okno<>nil then okno.Free;
  end;
end;

procedure daj_kartoteke;
//var
//  ilosc: currency; id_jm: string;
begin
  //id_kartoteka1:=Slownik('KARTOTEKA')
  //jm:='10007'
  //if id_kartoteka1<>0 then begin

    pobierz_dane;//(id_kartoteka1,ilosc,id_jm);
    //ilosc:=1.00;
    //if t1 then daj_okno;//(id_kartoteka1,ilosc,id_jm);
  //end;
end;

begin
  daj_kartoteke;
end.