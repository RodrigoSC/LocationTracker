create table if not exists track (
    id integer primary key,
    name text
);

create table if not exists point (
    id integer primary key,
    track_id integer,
    nbr integer,
    time integer,
    lat real,
    lon real,
    alt real,
    foreign key (track_id) references track(id) on delete cascade 
);