CREATE TABLE greylist (
    id serial NOT NULL,
    relay_ip character varying(20),
    sender_type character varying(6) DEFAULT 'NORMAL'::character varying NOT NULL,
    sender character varying(150),
    recipient character varying(150),
    block_expires timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    record_expires timestamp without time zone DEFAULT '9999-12-31 23:59:59'::timestamp without time zone NOT NULL,
    create_time timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    "type" character varying(6) DEFAULT 'MANUAL'::character varying NOT NULL,
    passcount bigint DEFAULT 0::bigint NOT NULL,
    last_pass timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    blockcount bigint DEFAULT 0::bigint NOT NULL,
    last_block timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL,
    CONSTRAINT greylist_sender_type_check CHECK ((((sender_type)::text = 'NORMAL'::text) OR ((sender_type)::text = 'BOUNCE'::text))),
    CONSTRAINT greylist_type_check CHECK (((("type")::text = 'AUTO'::text) OR (("type")::text = 'MANUAL'::text)))
);
