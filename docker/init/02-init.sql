-- races
create table dev.race
(
    id   uuid primary key,
    name text not null unique
);

-- populate races
insert into dev.race (id, name)
values (uuid_generate_v4(), 'night_elf'),
       (uuid_generate_v4(), 'human'),
       (uuid_generate_v4(), 'gnome'),
       (uuid_generate_v4(), 'dwarf'),
       (uuid_generate_v4(), 'orc'),
       (uuid_generate_v4(), 'troll'),
       (uuid_generate_v4(), 'tauren'),
       (uuid_generate_v4(), 'undead');

-- classes
create table dev.class
(
    id   uuid primary key,
    name text not null unique
);

-- populate classes
insert into dev.class (id, name)
values (uuid_generate_v4(), 'warrior'),
       (uuid_generate_v4(), 'paladin'),
       (uuid_generate_v4(), 'shaman'),
       (uuid_generate_v4(), 'hunter'),
       (uuid_generate_v4(), 'rogue'),
       (uuid_generate_v4(), 'druid'),
       (uuid_generate_v4(), 'mage'),
       (uuid_generate_v4(), 'warlock'),
       (uuid_generate_v4(), 'priest');

-- factions
create table dev.faction
(
    id   uuid primary key,
    name text not null unique
);

-- populate factions
insert into dev.faction (id, name)
values (uuid_generate_v4(), 'alliance'),
       (uuid_generate_v4(), 'horde');

-- allowed races
create table dev.allowed_races
(
    id         uuid primary key default uuid_generate_v4(),
    race_id    uuid not null,
    faction_id uuid not null,
    constraint fk_race foreign key (race_id) references dev.race (id),
    constraint fk_faction foreign key (faction_id) references dev.faction (id),
    constraint unique_race_faction unique (race_id, faction_id)
);

-- allowed races for horde
insert into dev.allowed_races (race_id, faction_id)
select id, (select id from dev.faction where name = 'horde')
from dev.race
where name in ('undead', 'troll', 'orc', 'tauren');

-- allowed races for alliance
insert into dev.allowed_races (race_id, faction_id)
select id, (select id from dev.faction where name = 'alliance')
from dev.race
where name in ('human', 'night_elf', 'dwarf', 'gnome');

-- allowed classes
create table dev.allowed_classes
(
    id         uuid primary key default uuid_generate_v4(),
    race_id    uuid not null,
    faction_id uuid not null,
    class_id   uuid not null,
    constraint fk_race foreign key (race_id) references dev.race (id),
    constraint fk_faction foreign key (faction_id) references dev.faction (id),
    constraint fk_class foreign key (class_id) references dev.class (id),
    constraint unique_race_faction_class unique (race_id, faction_id, class_id)
);

-- allowed faction and races for warrior class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         cross join dev.faction f
         join dev.class c on c.name = 'warrior';

-- allowed faction and races for paladin class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         join dev.faction f on f.name = 'alliance'
         join dev.class c on c.name = 'paladin'
where r.name in ('human', 'dwarf');

-- allowed faction and races for shaman class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         join dev.faction f on f.name = 'horde'
         join dev.class c on c.name = 'shaman'
where r.name in ('orc', 'troll', 'tauren');

-- allowed faction and races for hunter class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         join dev.faction f on f.name in ('horde', 'alliance')
         join dev.class c on c.name = 'hunter'
where r.name in ('night_elf', 'dwarf', 'tauren', 'troll', 'orc');

-- allowed faction and races for rogue class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         cross join dev.faction f
         join dev.class c on c.name = 'rogue'
where r.name != 'tauren';

-- allowed faction and races for druid class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         cross join dev.faction f
         join dev.class c on c.name = 'druid'
where r.name in ('night_elf', 'tauren');

-- allowed faction and races for warlock class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         cross join dev.faction f
         join dev.class c on c.name = 'warlock'
where r.name in ('human', 'gnome', 'orc', 'undead');

-- allowed faction and races for mage class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         cross join dev.faction f
         join dev.class c on c.name = 'mage'
where r.name in ('human', 'gnome', 'troll', 'undead');

-- allowed faction and races for priest class
insert into dev.allowed_classes (race_id, faction_id, class_id)
select r.id, f.id, c.id
from dev.race r
         cross join dev.faction f
         join dev.class c on c.name = 'priest'
where r.name in ('human', 'dwarf', 'night_elf', 'troll', 'undead');

-- player
create table dev.player
(
    id         uuid primary key                   default uuid_generate_v4(),
    name       text    not null unique,
    race_id    uuid    not null,
    class_id   uuid    not null,
    faction_id uuid    not null,
    level      integer not null check (level > 0) default 1,
    is_enabled boolean not null                   default true,
    created_at timestamp                          default current_timestamp,
    updated_at timestamp                          default current_timestamp,
    constraint fk_race foreign key (race_id) references dev.race (id),
    constraint fk_class foreign key (class_id) references dev.class (id),
    constraint fk_faction foreign key (faction_id) references dev.faction (id),
    constraint fk_allowed_classes foreign key (race_id, faction_id, class_id) references dev.allowed_classes (race_id, faction_id, class_id)
);

-- Inserting 5 players into the dev.player table

-- Horde Orc Warrior Level 1
insert into dev.player (name, race_id, class_id, faction_id, level)
select 'Horde Orc Warrior Level 1', r.id, c.id, f.id, 1
from dev.race r
         join dev.class c on c.name = 'warrior'
         join dev.faction f on f.name = 'horde'
where r.name = 'orc';

-- Horde Troll Shaman Level 1
insert into dev.player (name, race_id, class_id, faction_id, level)
select 'Horde Troll Shaman Level 1', r.id, c.id, f.id, 1
from dev.race r
         join dev.class c on c.name = 'shaman'
         join dev.faction f on f.name = 'horde'
where r.name = 'troll';

-- Horde Tauren Druid Level 1
insert into dev.player (name, race_id, class_id, faction_id, level)
select 'Horde Tauren Druid Level 1', r.id, c.id, f.id, 1
from dev.race r
         join dev.class c on c.name = 'druid'
         join dev.faction f on f.name = 'horde'
where r.name = 'tauren';

-- Alliance Human Rogue Level 1
insert into dev.player (name, race_id, class_id, faction_id, level)
select 'Alliance Human Rogue Level 1', r.id, c.id, f.id, 1
from dev.race r
         join dev.class c on c.name = 'rogue'
         join dev.faction f on f.name = 'alliance'
where r.name = 'human';

-- Alliance Gnome Warlock level 1
insert into dev.player (name, race_id, class_id, faction_id, level)
select 'Alliance Gnome Warlock Level 1', r.id, c.id, f.id, 1
from dev.race r
         join dev.class c on c.name = 'warlock'
         join dev.faction f on f.name = 'alliance'
where r.name = 'gnome';

