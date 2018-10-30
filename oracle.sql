-- 1. tabele

create table participants
(
  id int generated always as identity not null,
  first_name varchar2(50),
  last_name varchar2(50),
  pesel varchar2(11),
  outreach varchar2(100),
  constraint participant_pkey primary key
    (
      id
    )
  enable
);

create table travels
(
  id int generated always as identity not null,
  name varchar2(100),
  country varchar2(50),
  "date" date,
  info varchar2(200),
  rooms int,
  constraint travel_pkey primary key
    (
      id
    )
  enable
);

create table bookings
(
  id int generated always as identity not null,
  travel_id int,
  person_id int,
  status char(1),
  constraint booking_pkey primary key
    (
      id
    )
  enable
);

alter table bookings
  add constraint booking_participant_id_fkey foreign key
  (
    person_id
  )
references participants
  (
    id
  )
enable;

alter table bookings
  add constraint booking_travel_id_fkey foreign key
  (
    travel_id
  )
references travels
  (
    id
  )
enable;

alter table bookings
  add constraint reservation_status_chk check
(status in ( 'N', 'P', 'Z', 'A' ))
enable;

-- 2. Wypełniamy tabele przykładowymi danymi danymi
-- 4 wycieczki
-- 10 osób
-- 10 rezerwacji
begin
  insert into travels (name, country, "date", info, rooms)
  values ( 'Wieliczka', 'Polska', TO_DATE( '2018-11-06', 'YYYY-MM-DD' ), 'Zadziwiająca kopalnia ...', 2 );
  insert into travels (name, country, "date", info, rooms)
  values ( 'Kraków', 'Polska', TO_DATE( '2019-05-14', 'YYYY-MM-DD' ), 'Smog ...', 1 );
  insert into travels (name, country, "date", info, rooms)
  values ( 'Katowice', 'Polska', TO_DATE( '2017-12-12', 'YYYY-MM-DD' ), 'Smog ...', 3 );
  insert into travels (name, country, "date", info, rooms)
  values ( 'Warszawa', 'Polska', TO_DATE( '2019-12-12', 'YYYY-MM-DD' ), 'Smog ...', 7 );
end;

begin
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Anna', 'Anielewicz', '73051839705', 'tel: 721449160' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Bartosz', 'Bant', '82051808004', 'tel: 781081453' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Cecylia', 'Czulenko', '90051813205', 'tel: 723070265' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Dawid', 'Dawidowicz', '37051887403', 'tel: 694560394' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Ela', 'Elowicz', '21051883408', 'tel: 796764534' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Fatryl', 'Fontecki', '20051855312', 'tel: 724044449' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Gertruda', 'Gombrowicz', '31051836214', 'tel: 696334854' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Henryk', 'Horoboro', '44051805610', 'tel: 609797116' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Ignacy', 'Iguana', '51051839413', 'tel: 722076790' );
  insert into participants (first_name, last_name, pesel, outreach)
  values ( 'Juzew', 'Jelowicz', '66051827818', 'tel: 699142008' );
end;

begin
  insert into bookings (travel_id, person_id, status)
  values ( 3, 3, 'P' );
  insert into bookings (travel_id, person_id, status)
  values ( 4, 4, 'P' );
  insert into bookings (travel_id, person_id, status)
  values ( 1, 5, 'P' );
  insert into bookings (travel_id, person_id, status)
  values ( 1, 6, 'N' );
  insert into bookings (travel_id, person_id, status)
  values ( 2, 7, 'P' );
  insert into bookings (travel_id, person_id, status)
  values ( 2, 8, 'P' );
  insert into bookings (travel_id, person_id, status)
  values ( 2, 9, 'P' );
  insert into bookings (travel_id, person_id, status)
  values ( 2, 10, 'N' );
  insert into bookings (travel_id, person_id, status)
  values ( 2, 1, 'N' );
  insert into bookings (travel_id, person_id, status)
  values ( 2, 2, 'N' );
end;

--3.  Tworzenie widoków. Należy przygotować kilka widoków ułatwiających dostęp do danych
-- wycieczki_osoby(kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
create or replace view travels_participants as
  select
    t.id travel_id,
    t.name,
    t.country,
    t."date",
    p.id person_id,
    p.first_name,
    p.last_name,
    r.status
  from travels t
    join bookings r on t.id = r.travel_id
    join participants p on p.id = r.person_id;
-- wycieczki_osoby_potwierdzone (kraj,data, nazwa_wycieczki, imie,nazwisko,status_rezerwacji)
create or replace view travels_participants_positive as
  select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants pt
  where pt.status = 'P';
--  wycieczki_przyszle (kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
create or replace view future_travels as
  select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants pt
  where pt."date" >= current_date;
-- wycieczki_miejsca(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
create or replace view travels_destinations as
  select
    t.id,
    t.country,
    t."date",
    t.name,
    t.rooms,
    t.rooms - ( select COALESCE( COUNT( r.id ), 0 )
    from bookings r
    where t.id = r.travel_id
      and r.status != 'A' ) as available_space
  from travels t;

--dostępne_wyciezki(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
create or replace view available_travels as
  select
    pt.id, pt.country, pt."date", pt.name, pt.rooms, pt.available_space
  from travels_destinations pt
  where pt.available_space > 0
    and pt."date" >= current_date;

--rezerwacje_do_ anulowania – lista niepotwierdzonych rezerwacji które powinne zostać anulowane, rezerwacje przygotowywane są do anulowania na tydzień przed wyjazdem)
create or replace view bookings_to_be_canceled as
  select
    r.id reservation_id, r.travel_id, r.person_id, t."date"
  from bookings r
    inner join travels t on t.id = r.travel_id
  where t."date" >= current_date
    and t."date" - current_date <= 7
    and r.status = 'N';

-- 3 Tworzenie procedur/funkcji pobierających dane. Podobnie jak w poprzednim przykładzie należy przygotować kilka procedur ułatwiających dostęp do danych
-- wycieczki_osoby(kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
create or replace type travel_participants_row as object (
  travel_id number,
  name varchar2(100),
  country varchar2(50),
  "date" date,
  paticipaint_id number,
  first_name varchar2(50),
  last_name varchar2(50),
  status char
);

create or replace type travel_participants_table
as table of travel_participants_row;

create or replace function travel_participants(
  travel_id travels.id%type
)
  return travel_participants_table pipelined
as
  cursor cond is select t.id
  from travels t
  where t.id = travel_id;
  cond_res number;
  cursor cur is select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants pt
  where pt.travel_id = travel_id;
  tmp cur%rowtype;
  begin
    open cond;
    fetch cond into cond_res;
    close cond;
    if cond_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    end if;

    for tmp in cur loop
      pipe row (TRAVEL_PARTICIPANTS_ROW( tmp.travel_id, tmp.name, tmp.country,
                                         tmp."date", tmp.person_id, tmp.first_name,
                                         tmp.last_name, tmp.status ));
    end loop;
  end;

-- rezerwacje_osoby(id_osoby), procedura ma zwracać podobny zestaw danych jak widok wycieczki_osoby
create or replace function reservations_of_participant(
  participant_id participants.id%type
)
  return travel_participants_table pipelined
as
  cursor cond is select p.id
  from participants p
  where p.id = participant_id;
  cond_res number;
  cursor cur is select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants pt
  where pt.person_id = participant_id;
  tmp cur%rowtype;
  begin
    open cond;
    fetch cond into cond_res;
    close cond;
    if cond_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    end if;

    for tmp in cur
    loop
      pipe row (TRAVEL_PARTICIPANTS_ROW( tmp.travel_id, tmp.name, tmp.country,
                                         tmp."date", tmp.person_id, tmp.first_name,
                                         tmp.last_name, tmp.status ));
    end loop;
  end;

-- przyszle_rezerwacje_osoby(id_osoby)
create or replace function future_travels_of_participants(
  participant_id participants.id%type
)
  return travel_participants_table pipelined
as
  cursor cond is select p.id
  from participants p
  where p.id = participant_id;
  cond_res number;
  cursor cur is select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants pt
  where pt.person_id = participant_id
    and pt."date" > CURRENT_DATE;
  tmp cur%rowtype;
  begin
    open cond;
    fetch cond into cond_res;
    close cond;
    if cond_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    end if;

    for tmp in cur
    loop
      pipe row (TRAVEL_PARTICIPANTS_ROW( tmp.travel_id, tmp.name, tmp.country,
                                         tmp."date", tmp.person_id, tmp.first_name,
                                         tmp.last_name, tmp.status ));
    end loop;
  end;

-- dostepne_wycieczki(kraj, data_od, data_do)
create or replace type travel_places_row as object (
  id number,
  name varchar2(100),
  country varchar2(50),
  trip_date date,
  space number,
  available_space number
);

create or replace type travel_places_table as table of travel_places_row;

create or replace function available_travels_fun(
  country travels.country%type,
  "from" date,
  "to" date
)
  return travel_places_table pipelined
as
  cursor cur is select
    td.id, td.name, td.country, td."date", td.rooms, td.available_space
  from travels_destinations td
  where td.country = country
    and td.available_space > 0
    and td."date" between "from" and "to";
  tmp cur%rowtype;
  begin
    for tmp in cur
    loop
      pipe row (travel_places_row( tmp.id, tmp.name, tmp.country, tmp."date", tmp.rooms,
                                   tmp.available_space ));
    end loop;

  end;

-- 5. Tworzenie procedur modyfikujących dane. Należy przygotować zestaw procedur pozwalających na modyfikację danych oraz kontrolę poprawności ich wprowadzania
-- dodaj_rezerwacje(id_wycieczki, id_osoby), procedura powinna kontrolować czy wycieczka jeszcze się nie odbyła, i czy sa wolne miejsca
create or replace procedure add_booking(
  travel_id travels.id%type,
  participant_id participants.id%type
)
as
  cursor participant_exists is select p.id
  from participants p
  where p.id = participant_id;
  cursor is_available is select a.id
  from available_travels a
  where a.id = travel_id;
  is_available_res number;
  participant_exists_res number;
  id number;
  begin
    open is_available;
    fetch is_available into is_available_res;
    close is_available;
    open participant_exists;
    fetch participant_exists into participant_exists_res;
    close participant_exists;
    if is_available_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif participant_exists_res is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    end if;

    insert into bookings (travel_id, person_id, status)
    values ( travel_id, participant_id, 'N' ) returning id into id;
  end;

-- zmien_status_rezerwacji(id_rezerwacji, status), procedura kontrolować czy możliwa jestzmiana statusu, np. zmiana statusu już anulowanej wycieczki (przywrócenie do stanu aktywnego nie zawsze jest możliwe)
create or replace procedure change_booking_status(
  booking_id bookings.id%type,
  status char
)
as

  cursor cur is select
    td.available_space, r.status, td.id
  from bookings r
    inner join travels_destinations td on r.id = td.id
  where r.id = booking_id
    and td."date" >= CURRENT_DATE;
  space number;
  travel_id travels.id%type;
  old_status char;
  begin
    open cur;
    fetch cur into space, old_status, travel_id;
    close cur;
    if status not in ( 'N', 'P', 'Z', 'A' )
    then
      RAISE_APPLICATION_ERROR( -20000, 'Error Status' );
    elsif travel_id is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    elsif status != 'A' and old_status = 'A' and space = 0
      then
        RAISE_APPLICATION_ERROR( -20002, 'No room' );
    end if;

    update bookings r set r.status = status where r.id = booking_id;
  end;

-- zmien_liczbe_miejsc(id_wycieczki, liczba_miejsc), nie wszystkie zmiany liczby miejsc są dozwolone, nie można zmniejszyć liczby miesc na wartość poniżej liczby zarezerwowanych miejsc
create or replace procedure change_rooms_amount(
  travel_id in travels.id%type,
  rooms in number
)
as

  cursor count_rooms is select td.rooms - td.available_space
  from travels_destinations td
  where td.id = travel_id
    and td."date" >= CURRENT_DATE;
  booked_rooms number;

  begin
    open count_rooms;
    fetch count_rooms into booked_rooms;
    close count_rooms;
    if booked_rooms is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif booked_rooms > rooms
      then
        RAISE_APPLICATION_ERROR( -20001, 'Overbooked' );
    end if;
    update travels t
    set t.rooms = rooms
    where t.id = travel_id;
  end;

-- 6. Dodajemy tabelę dziennikującą zmiany statusu rezerwacji
create table bookings_log
(
  id int generated always as identity not null,
  booking_id int,
  log_date date,
  status char(1),
  constraint reservation_log_pkey primary key
    (
      id
    )
  enable
);

alter table bookings_log
  add constraint reservation_log_reservation_id_fkey foreign key
  (
    booking_id
  )
references bookings
  (
    id
  )
enable;


create or replace procedure add_booking(
  travel_id travels.id%type,
  participant_id participants.id%type
)
as
  cursor participant_exists is select p.id
  from participants p
  where p.id = participant_id;
  cursor is_available is select a.id
  from available_travels a
  where a.id = travel_id;
  is_available_res number;
  participant_exists_res number;
  id number;
  begin
    open is_available;
    fetch is_available into is_available_res;
    close is_available;
    open participant_exists;
    fetch participant_exists into participant_exists_res;
    close participant_exists;
    if is_available_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif participant_exists_res is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    end if;

    insert into bookings (travel_id, person_id, status)
    values ( travel_id, participant_id, 'N' ) returning id into id;

    insert into bookings_log (booking_id, log_date, status)
    values ( id, CURRENT_DATE, 'N' );
  end;


create or replace procedure change_booking_status(
  booking_id bookings.id%type,
  status char
)
as

  cursor cur is select
    td.available_space, r.status, td.id
  from bookings r
    inner join travels_destinations td on r.id = td.id
  where r.id = booking_id
    and td."date" >= CURRENT_DATE;
  space number;
  travel_id travels.id%type;
  old_status char;
  begin
    open cur;
    fetch cur into space, old_status, travel_id;
    close cur;
    if status not in ( 'N', 'P', 'Z', 'A' )
    then
      RAISE_APPLICATION_ERROR( -20000, 'Error Status' );
    elsif travel_id is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    elsif status != 'A' and old_status = 'A' and space = 0
      then
        RAISE_APPLICATION_ERROR( -20002, 'No room' );
    end if;

    update bookings r set r.status = status where r.id = booking_id;

    insert into bookings_log (booking_id, log_date, status)
    values ( booking_id, CURRENT_DATE, status );
  end;

-- 7. Zmiana struktury bazy danych, w tabeli wycieczki dodajemy redundantne pole liczba_wolnych_miejsc

alter table travels
  add available_rooms int;

create or replace view travels_participants_2 as
  select
    t.id travel_id,
    t.name,
    t.available_rooms,
    t.country,
    t."date",
    p.id person_id,
    p.first_name,
    p.last_name,
    r.status
  from travels t
    join bookings r on t.id = r.travel_id
    join participants p on p.id = r.person_id;


create or replace view future_travels_2 as
  select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.available_rooms,
    pt.status
  from travels_participants_2 pt
  where pt."date" >= current_date;

create or replace view travels_destinations_2 as
  select
    t.id,
    t.country,
    t."date",
    t.name,
    t.rooms,
    t.available_rooms
  from travels t;

create or replace procedure parse
as
  free_rooms number;
  begin
    for tr in (select * from travels)
    loop
      select tr.rooms - COALESCE( COUNT( r.id ), 0 ) into free_rooms
      from bookings r
      where tr.id = r.travel_id
        and r.status != 'A';
      update travels t set t.available_rooms = free_rooms where t.id = tr.id;
    end loop;
  end;


create or replace function travel_participants_2(
  travel_id travels.id%type
)
  return travel_participants_table pipelined
as
  cursor cond is select t.id
  from travels t
  where t.id = travel_id;
  cond_res number;
  cursor cur is select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants_2 pt
  where pt.travel_id = travel_id;
  tmp cur%rowtype;
  begin
    open cond;
    fetch cond into cond_res;
    close cond;
    if cond_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    end if;

    for tmp in cur loop
      pipe row (TRAVEL_PARTICIPANTS_ROW( tmp.travel_id, tmp.name, tmp.country,
                                         tmp."date", tmp.person_id, tmp.first_name,
                                         tmp.last_name, tmp.status ));
    end loop;
  end;

-- b rezerwacje_osoby(id_osoby), procedura ma zwracać podobny zestaw danych jak widok wycieczki_osoby
create or replace function reservations_of_participant_2(
  participant_id participants.id%type
)
  return travel_participants_table pipelined
as
  cursor cond is select p.id
  from participants p
  where p.id = participant_id;
  cond_res number;
  cursor cur is select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants_2 pt
  where pt.person_id = participant_id;
  tmp cur%rowtype;
  begin
    open cond;
    fetch cond into cond_res;
    close cond;
    if cond_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    end if;

    for tmp in cur
    loop
      pipe row (TRAVEL_PARTICIPANTS_ROW( tmp.travel_id, tmp.name, tmp.country,
                                         tmp."date", tmp.person_id, tmp.first_name,
                                         tmp.last_name, tmp.status ));
    end loop;
  end;

-- c. przyszle_rezerwacje_osoby(id_osoby)
create or replace function future_travels_of_participants_2(
  participant_id participants.id%type
)
  return travel_participants_table pipelined
as
  cursor cond is select p.id
  from participants p
  where p.id = participant_id;
  cond_res number;
  cursor cur is select
    pt.travel_id,
    pt.name,
    pt.country,
    pt."date",
    pt.person_id,
    pt.first_name,
    pt.last_name,
    pt.status
  from travels_participants_2 pt
  where pt.person_id = participant_id
    and pt."date" > CURRENT_DATE;
  tmp cur%rowtype;
  begin
    open cond;
    fetch cond into cond_res;
    close cond;
    if cond_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    end if;

    for tmp in cur
    loop
      pipe row (TRAVEL_PARTICIPANTS_ROW( tmp.travel_id, tmp.name, tmp.country,
                                         tmp."date", tmp.person_id, tmp.first_name,
                                         tmp.last_name, tmp.status ));
    end loop;
  end;

-- d dostepne_wycieczki(kraj, data_od, data_do)
create or replace function available_travels_fun_2(
  country travels.country%type,
  "from" date,
  "to" date
)
  return travel_places_table pipelined
as
  cursor cur is select
    td.id, td.name, td.country, td."date", td.rooms, td.available_space
  from travels_destinations_2 td
  where td.country = country
    and td.available_space > 0
    and td."date" between "from" and "to";
  tmp cur%rowtype;
  begin
    for tmp in cur
    loop
      pipe row (travel_places_row( tmp.id, tmp.name, tmp.country, tmp."date", tmp.rooms,
                                   tmp.available_space ));
    end loop;

  end;


create or replace procedure add_booking_2(
  travel_id travels.id%type,
  participant_id participants.id%type
)
as
  cursor participant_exists is select p.id
  from participants p
  where p.id = participant_id;
  cursor is_available is select a.id
  from available_travels a
  where a.id = travel_id;
  is_available_res number;
  participant_exists_res number;
  id number;
  begin
    open is_available;
    fetch is_available into is_available_res;
    close is_available;
    open participant_exists;
    fetch participant_exists into participant_exists_res;
    close participant_exists;
    if is_available_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif participant_exists_res is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    end if;

    insert into bookings (travel_id, person_id, status)
    values ( travel_id, participant_id, 'N' ) returning id into id;

    insert into bookings_log (booking_id, log_date, status)
    values ( id, CURRENT_DATE, 'N' );

    update travels t set t.available_rooms = t.available_rooms - 1 where t.id = travel_id;
  end;


create or replace procedure change_booking_status_2(
  booking_id bookings.id%type,
  status char
)
as

  cursor cur is select
    td.available_space, r.status, td.id
  from bookings r
    inner join travels_destinations td on r.id = td.id
  where r.id = booking_id
    and td."date" >= CURRENT_DATE;
  space number;
  travel_id travels.id%type;
  old_status char;
  begin
    open cur;
    fetch cur into space, old_status, travel_id;
    close cur;
    if status not in ( 'N', 'P', 'Z', 'A' )
    then
      RAISE_APPLICATION_ERROR( -20000, 'Error Status' );
    elsif travel_id is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    elsif status != 'A' and old_status = 'A' and space = 0
      then
        RAISE_APPLICATION_ERROR( -20002, 'No room' );
    end if;

    update bookings r set r.status = status where r.id = booking_id;

    insert into bookings_log (booking_id, log_date, status)
    values ( booking_id, CURRENT_DATE, status );

    if status = 'A' and old_status != 'A'
    then
      update travels t set t.available_space = t.available_space + 1 where t.id = travel_id;
    elsif status != 'A' and old_status = 'A'
      then
        update travels t set t.available_space = t.available_space - 1 where t.id = travel_id;
    end if;
  end;


create or replace procedure change_rooms_amount_2(
  travel_id in travels.id%type,
  travel_id in travels.id%type,
  rooms in number
)
as

  cursor count_rooms is select td.rooms - td.available_space
  from travels_destinations td
  where td.id = travel_id
    and td."date" >= CURRENT_DATE;
  booked_rooms number;

  begin
    open count_rooms;
    fetch count_rooms into booked_rooms;
    close count_rooms;
    if booked_rooms is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif booked_rooms > rooms
      then
        RAISE_APPLICATION_ERROR( -20001, 'Overbooked' );
    end if;
    update travels t
    set t.rooms = rooms, t.available_rooms = space - booked_rooms
    where t.id = travel_id;
  end;


--- 8. Zmiana strategii zapisywania do dziennika rezerwacji. Realizacja przy pomocy triggerów
create or replace trigger booking_trigger
after insert or update of status
  on bookings
for each row
  begin
    insert into bookings_log (booking_id, log_date, status)
    values ( :new.id, CURRENT_DATE, :new.status );
  end;


create or replace trigger reservation_guard
before delete
  on bookings
  begin
    RAISE_APPLICATION_ERROR( -20000, 'Not allowed' );
  end;


create or replace procedure add_booking_3(
  travel_id travels.id%type,
  participant_id participants.id%type
)
as
  cursor participant_exists is select p.id
  from participants p
  where p.id = participant_id;
  cursor is_available is select a.id
  from available_travels a
  where a.id = travel_id;
  is_available_res number;
  participant_exists_res number;
  id number;
  begin
    open is_available;
    fetch is_available into is_available_res;
    close is_available;
    open participant_exists;
    fetch participant_exists into participant_exists_res;
    close participant_exists;
    if is_available_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif participant_exists_res is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    end if;

    insert into bookings (travel_id, person_id, status)
    values ( travel_id, participant_id, 'N' ) returning id into id;

    --INSERT INTO bookings_log (booking_id, log_date, status)
    --VALUES ( id, CURRENT_DATE, 'N' );

    update travels t set t.available_rooms = t.available_rooms - 1 where t.id = travel_id;
  end;


create or replace procedure change_booking_status_3(
  booking_id bookings.id%type,
  status char
)
as

  cursor cur is select
    td.available_space, r.status, td.id
  from bookings r
    inner join travels_destinations td on r.id = td.id
  where r.id = booking_id
    and td."date" >= CURRENT_DATE;
  space number;
  travel_id travels.id%type;
  old_status char;
  begin
    open cur;
    fetch cur into space, old_status, travel_id;
    close cur;
    if status not in ( 'N', 'P', 'Z', 'A' )
    then
      RAISE_APPLICATION_ERROR( -20000, 'Error Status' );
    elsif travel_id is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    elsif status != 'A' and old_status = 'A' and space = 0
      then
        RAISE_APPLICATION_ERROR( -20002, 'No room' );
    end if;

    update bookings r set r.status = status where r.id = booking_id;

    --INSERT INTO bookings_log (booking_id, log_date, status)
    --VALUES ( booking_id, CURRENT_DATE, status );

    if status = 'A' and old_status != 'A'
    then
      update travels t set t.available_space = t.available_space + 1 where t.id = travel_id;
    elsif status != 'A' and old_status = 'A'
      then
        update travels t set t.available_space = t.available_space - 1 where t.id = travel_id;
    end if;

  end;



-- 9. Zmiana strategii obsługi redundantnego pola liczba_wolnych_miejsc . realizacja przy pomocy trigerów

create or replace trigger available_rooms_trigger
after insert
  on bookings
for each row
  begin
    update travels t set t.available_rooms = t.available_rooms - 1 where t.id = :new.travel_id;
  end;


create or replace trigger change_status_trigger
before update of status
  on bookings
for each row
  declare
    old_available_space number;
  begin
    if :new.status = 'A' and :old.status != 'A'
    then
      update travels t set t.available_rooms = t.available_rooms + 1 where t.id = :new.travel_id;
    elsif :new.status != 'A' and :old.status = 'A'
      then
        select t.available_rooms into old_available_space from travels t where t.id = :new.travel_id;
        if old_available_space = 0
        then
          RAISE_APPLICATION_ERROR( -20000, 'No rooms' );
        end if;
        update travels t set t.available_rooms = t.available_rooms - 1 where t.id = :new.travel_id;
    end if;
  end;


create or replace trigger change_rooms_on_travel
before update of rooms
  on travels
for each row
  begin
    if :old.rooms - :old.available_rooms > :new.rooms
    then
      RAISE_APPLICATION_ERROR( -20001, 'Too many reservations to lower space' );
    end if;
    update travels t set t.available_rooms = :new.rooms - ( :old.rooms - :old.available_rooms )
    where t.id = :new.id;
  end;


create or replace procedure add_booking_4(
  travel_id travels.id%type,
  participant_id participants.id%type
)
as
  cursor participant_exists is select p.id
  from participants p
  where p.id = participant_id;
  cursor is_available is select a.id
  from available_travels a
  where a.id = travel_id;
  is_available_res number;
  participant_exists_res number;
  id number;
  begin
    open is_available;
    fetch is_available into is_available_res;
    close is_available;
    open participant_exists;
    fetch participant_exists into participant_exists_res;
    close participant_exists;
    if is_available_res is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif participant_exists_res is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    end if;

    insert into bookings (travel_id, person_id, status)
    values ( travel_id, participant_id, 'N' ) returning id into id;

    --INSERT INTO bookings_log (booking_id, log_date, status)
    --VALUES ( id, CURRENT_DATE, 'N' );

    -- UPDATE travels t SET t.available_rooms = t.available_rooms - 1 WHERE t.id = travel_id;
  end;


create or replace procedure change_booking_status_4(
  booking_id bookings.id%type,
  status char
)
as

  cursor cur is select
    td.available_space, r.status, td.id
  from bookings r
    inner join travels_destinations td on r.id = td.id
  where r.id = booking_id
    and td."date" >= CURRENT_DATE;
  space number;
  travel_id travels.id%type;
  old_status char;
  begin
    open cur;
    fetch cur into space, old_status, travel_id;
    close cur;
    if status not in ( 'N', 'P', 'Z', 'A' )
    then
      RAISE_APPLICATION_ERROR( -20000, 'Error Status' );
    elsif travel_id is null
      then
        RAISE_APPLICATION_ERROR( -20001, 'NOT FOUND' );
    elsif status != 'A' and old_status = 'A' and space = 0
      then
        RAISE_APPLICATION_ERROR( -20002, 'No room' );
    end if;

    update bookings r set r.status = status where r.id = booking_id;

    --INSERT INTO bookings_log (booking_id, log_date, status)
    --VALUES ( booking_id, CURRENT_DATE, status );

    -- IF status = 'A' AND old_status != 'A'
    --THEN
    --  UPDATE travels t SET t.available_space = t.available_space + 1 WHERE t.id = travel_id;
    --ELSIF status != 'A' AND old_status = 'A'
    --  THEN
    --   UPDATE travels t SET t.available_space = t.available_space - 1 WHERE t.id = travel_id;
    --END IF;

  end;


create or replace procedure change_rooms_amount_4(
  travel_id in travels.id%type,
  travel_id in travels.id%type,
  rooms in number
)
as

  cursor count_rooms is select td.rooms - td.available_space
  from travels_destinations td
  where td.id = travel_id
    and td."date" >= CURRENT_DATE;
  booked_rooms number;

  begin
    open count_rooms;
    fetch count_rooms into booked_rooms;
    close count_rooms;
    if booked_rooms is null
    then
      RAISE_APPLICATION_ERROR( -20000, 'NOT FOUND' );
    elsif booked_rooms > rooms
      then
        RAISE_APPLICATION_ERROR( -20001, 'Overbooked' );
    end if;
    --UPDATE travels t
    --SET t.rooms = rooms, t.available_rooms = space - booked_rooms
    --WHERE t.id = travel_id;
  end;



-- Podsumowanie
-- Cwiczenie zapoznalo mnie z podstawowym syntexem BD Oracle. Interesującą częścią było dołożenie triggerów, które pozwoliły
-- nałożyć znaczącą warstwę abstrakcji na wykonywane procedury


