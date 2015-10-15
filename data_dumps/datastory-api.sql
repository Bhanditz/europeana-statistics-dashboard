--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: dimension_or_metrics; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE dimension_or_metrics AS ENUM (
    'd',
    'm'
);


ALTER TYPE public.dimension_or_metrics OWNER TO postgres;

--
-- Name: sub_data_types; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE sub_data_types AS ENUM (
    'lat',
    'lng'
);


ALTER TYPE public.sub_data_types OWNER TO postgres;

--
-- Name: _final_median(anyarray); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION _final_median(anyarray) RETURNS double precision
    LANGUAGE sql IMMUTABLE
    AS $_$ 
  WITH q AS
  (
     SELECT val
     FROM unnest($1) val
     WHERE VAL IS NOT NULL
     ORDER BY 1
  ),
  cnt AS
  (
    SELECT COUNT(*) AS c FROM q
  )
  SELECT AVG(val)::float8
  FROM 
  (
    SELECT val FROM q
    LIMIT  2 - MOD((SELECT c FROM cnt), 2)
    OFFSET GREATEST(CEIL((SELECT c FROM cnt) / 2.0) - 1,0)  
  ) q2;
$_$;


ALTER FUNCTION public._final_median(anyarray) OWNER TO postgres;

--
-- Name: str_to_boolean(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION str_to_boolean(chartoconvert character varying) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT CASE WHEN lower(trim($1)) IN ('t', 'true', 'f', 'false', 'yes', 'no', 'y', 'n', '0', '1')
        THEN CAST(lower(trim($1)) AS boolean) 
    ELSE NULL END;

$_$;


ALTER FUNCTION public.str_to_boolean(chartoconvert character varying) OWNER TO postgres;

--
-- Name: str_to_float(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION str_to_float(chartoconvert character varying) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT CASE WHEN trim($1) SIMILAR TO '[-+]?[0-9]*\.?[0-9]+' 
        THEN CAST(trim($1) AS double precision) 
    ELSE NULL END;

$_$;


ALTER FUNCTION public.str_to_float(chartoconvert character varying) OWNER TO postgres;

--
-- Name: str_to_int(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION str_to_int(chartoconvert character varying) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT CASE WHEN trim($1) SIMILAR TO '[-+]?[0-9]*\.?[0-9]+' 
        THEN CAST(CAST(trim($1) AS double precision) as integer)
    ELSE NULL END;

$_$;


ALTER FUNCTION public.str_to_int(chartoconvert character varying) OWNER TO postgres;

--
-- Name: t1_dec(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION t1_dec(val integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN val - 1;
END; $$;


ALTER FUNCTION public.t1_dec(val integer) OWNER TO postgres;

--
-- Name: t1_inc(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION t1_inc(val integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN val + 1;
END; $$;


ALTER FUNCTION public.t1_inc(val integer) OWNER TO postgres;

--
-- Name: median(anyelement); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE median(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}',
    FINALFUNC = _final_median
);


ALTER AGGREGATE public.median(anyelement) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: column_meta; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE column_meta (
    id integer NOT NULL,
    table_name character varying(64),
    column_name character varying(64),
    pos smallint,
    original_column_name character varying(255) DEFAULT NULL::character varying,
    d_or_m dimension_or_metrics DEFAULT 'd'::dimension_or_metrics,
    sub_type sub_data_types
);


ALTER TABLE public.column_meta OWNER TO postgres;

--
-- Name: column_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE column_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.column_meta_id_seq OWNER TO postgres;

--
-- Name: column_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE column_meta_id_seq OWNED BY column_meta.id;


--
-- Name: fpvuhdtsqnbbrixsowqwwzmuftamkqlv; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE fpvuhdtsqnbbrixsowqwwzmuftamkqlv (
    id integer NOT NULL,
    alphabet_name character varying(255) DEFAULT NULL::character varying,
    column1 character varying(255) DEFAULT NULL::character varying,
    column2 character varying(255) DEFAULT NULL::character varying,
    column3 character varying(255) DEFAULT NULL::character varying,
    column4 character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE public.fpvuhdtsqnbbrixsowqwwzmuftamkqlv OWNER TO postgres;

--
-- Name: fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq OWNER TO postgres;

--
-- Name: fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq OWNED BY fpvuhdtsqnbbrixsowqwwzmuftamkqlv.id;


--
-- Name: nfpzglsypjyuhqausvglcsqzgdimaehl; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE nfpzglsypjyuhqausvglcsqzgdimaehl (
    id integer NOT NULL,
    districts character varying(255) DEFAULT NULL::character varying,
    total_number_of_works integer,
    total_number_of_completed_works integer,
    achievement__in_percent_ double precision
);


ALTER TABLE public.nfpzglsypjyuhqausvglcsqzgdimaehl OWNER TO postgres;

--
-- Name: nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq OWNER TO postgres;

--
-- Name: nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq OWNED BY nfpzglsypjyuhqausvglcsqzgdimaehl.id;


--
-- Name: oxvfmwsjsmespxihxfqzxpjzynyajche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE oxvfmwsjsmespxihxfqzxpjzynyajche (
    id integer NOT NULL,
    street character varying(255) DEFAULT NULL::character varying,
    city character varying(255) DEFAULT NULL::character varying,
    zip integer,
    state character varying(255) DEFAULT NULL::character varying,
    beds integer,
    baths integer,
    sq__ft integer,
    type character varying(255) DEFAULT NULL::character varying,
    sale_date character varying(255) DEFAULT NULL::character varying,
    price integer,
    latitude double precision,
    longitude double precision
);


ALTER TABLE public.oxvfmwsjsmespxihxfqzxpjzynyajche OWNER TO postgres;

--
-- Name: oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq OWNER TO postgres;

--
-- Name: oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq OWNED BY oxvfmwsjsmespxihxfqzxpjzynyajche.id;


--
-- Name: roujygtyrqhmfikbpoitmwbwdwzkggki; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roujygtyrqhmfikbpoitmwbwdwzkggki (
    id integer NOT NULL,
    street character varying(255) DEFAULT NULL::character varying,
    city character varying(255) DEFAULT NULL::character varying,
    zip integer,
    state character varying(255) DEFAULT NULL::character varying,
    beds integer,
    baths integer,
    sq__ft integer,
    type character varying(255) DEFAULT NULL::character varying,
    sale_date character varying(255) DEFAULT NULL::character varying,
    price integer,
    latitude double precision,
    longitude double precision
);


ALTER TABLE public.roujygtyrqhmfikbpoitmwbwdwzkggki OWNER TO postgres;

--
-- Name: roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq OWNER TO postgres;

--
-- Name: roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq OWNED BY roujygtyrqhmfikbpoitmwbwdwzkggki.id;


--
-- Name: zhdfdidvufqquhhowjjjfksukvgqbibm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE zhdfdidvufqquhhowjjjfksukvgqbibm (
    id integer NOT NULL,
    street character varying(255) DEFAULT NULL::character varying,
    city character varying(255) DEFAULT NULL::character varying,
    zip integer,
    state character varying(255) DEFAULT NULL::character varying,
    beds integer,
    baths integer,
    sq__ft integer,
    type character varying(255) DEFAULT NULL::character varying,
    sale_date character varying(255) DEFAULT NULL::character varying,
    price integer,
    latitude double precision,
    longitude double precision
);


ALTER TABLE public.zhdfdidvufqquhhowjjjfksukvgqbibm OWNER TO postgres;

--
-- Name: zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq OWNER TO postgres;

--
-- Name: zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq OWNED BY zhdfdidvufqquhhowjjjfksukvgqbibm.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY column_meta ALTER COLUMN id SET DEFAULT nextval('column_meta_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fpvuhdtsqnbbrixsowqwwzmuftamkqlv ALTER COLUMN id SET DEFAULT nextval('fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nfpzglsypjyuhqausvglcsqzgdimaehl ALTER COLUMN id SET DEFAULT nextval('nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY oxvfmwsjsmespxihxfqzxpjzynyajche ALTER COLUMN id SET DEFAULT nextval('oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY roujygtyrqhmfikbpoitmwbwdwzkggki ALTER COLUMN id SET DEFAULT nextval('roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY zhdfdidvufqquhhowjjjfksukvgqbibm ALTER COLUMN id SET DEFAULT nextval('zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq'::regclass);


--
-- Data for Name: column_meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY column_meta (id, table_name, column_name, pos, original_column_name, d_or_m, sub_type) FROM stdin;
1	fpvuhdtsqnbbrixsowqwwzmuftamkqlv	id	0	id	d	\N
2	fpvuhdtsqnbbrixsowqwwzmuftamkqlv	alphabet_name	1	Alphabet Name	d	\N
45	roujygtyrqhmfikbpoitmwbwdwzkggki	latitude	11	latitude	d	lat
46	roujygtyrqhmfikbpoitmwbwdwzkggki	longitude	12	longitude	d	lng
47	oxvfmwsjsmespxihxfqzxpjzynyajche	id	0	id	d	\N
48	oxvfmwsjsmespxihxfqzxpjzynyajche	street	1	street	d	\N
49	oxvfmwsjsmespxihxfqzxpjzynyajche	city	2	city	d	\N
51	oxvfmwsjsmespxihxfqzxpjzynyajche	state	4	state	d	\N
3	fpvuhdtsqnbbrixsowqwwzmuftamkqlv	column1	4	Column1	d	\N
6	fpvuhdtsqnbbrixsowqwwzmuftamkqlv	column4	9	Column4	d	\N
5	fpvuhdtsqnbbrixsowqwwzmuftamkqlv	column3	6	Column3	d	\N
55	oxvfmwsjsmespxihxfqzxpjzynyajche	type	8	type	d	\N
4	fpvuhdtsqnbbrixsowqwwzmuftamkqlv	column2	2	Column2	d	\N
21	zhdfdidvufqquhhowjjjfksukvgqbibm	id	0	id	d	\N
22	zhdfdidvufqquhhowjjjfksukvgqbibm	street	1	street	d	\N
23	zhdfdidvufqquhhowjjjfksukvgqbibm	city	2	city	d	\N
25	zhdfdidvufqquhhowjjjfksukvgqbibm	state	4	state	d	\N
29	zhdfdidvufqquhhowjjjfksukvgqbibm	type	8	type	d	\N
30	zhdfdidvufqquhhowjjjfksukvgqbibm	sale_date	9	sale_date	d	\N
24	zhdfdidvufqquhhowjjjfksukvgqbibm	zip	3	zip	m	\N
26	zhdfdidvufqquhhowjjjfksukvgqbibm	beds	5	beds	m	\N
27	zhdfdidvufqquhhowjjjfksukvgqbibm	baths	6	baths	m	\N
28	zhdfdidvufqquhhowjjjfksukvgqbibm	sq__ft	7	sq__ft	m	\N
31	zhdfdidvufqquhhowjjjfksukvgqbibm	price	10	price	m	\N
56	oxvfmwsjsmespxihxfqzxpjzynyajche	sale_date	9	sale_date	d	\N
32	zhdfdidvufqquhhowjjjfksukvgqbibm	latitude	11	latitude	d	lat
33	zhdfdidvufqquhhowjjjfksukvgqbibm	longitude	12	longitude	d	lng
34	roujygtyrqhmfikbpoitmwbwdwzkggki	id	0	id	d	\N
35	roujygtyrqhmfikbpoitmwbwdwzkggki	street	1	street	d	\N
36	roujygtyrqhmfikbpoitmwbwdwzkggki	city	2	city	d	\N
38	roujygtyrqhmfikbpoitmwbwdwzkggki	state	4	state	d	\N
42	roujygtyrqhmfikbpoitmwbwdwzkggki	type	8	type	d	\N
43	roujygtyrqhmfikbpoitmwbwdwzkggki	sale_date	9	sale_date	d	\N
37	roujygtyrqhmfikbpoitmwbwdwzkggki	zip	3	zip	m	\N
39	roujygtyrqhmfikbpoitmwbwdwzkggki	beds	5	beds	m	\N
40	roujygtyrqhmfikbpoitmwbwdwzkggki	baths	6	baths	m	\N
41	roujygtyrqhmfikbpoitmwbwdwzkggki	sq__ft	7	sq__ft	m	\N
44	roujygtyrqhmfikbpoitmwbwdwzkggki	price	10	price	m	\N
50	oxvfmwsjsmespxihxfqzxpjzynyajche	zip	3	zip	m	\N
52	oxvfmwsjsmespxihxfqzxpjzynyajche	beds	5	beds	m	\N
53	oxvfmwsjsmespxihxfqzxpjzynyajche	baths	6	baths	m	\N
54	oxvfmwsjsmespxihxfqzxpjzynyajche	sq__ft	7	sq__ft	m	\N
57	oxvfmwsjsmespxihxfqzxpjzynyajche	price	10	price	m	\N
58	oxvfmwsjsmespxihxfqzxpjzynyajche	latitude	11	latitude	d	lat
59	oxvfmwsjsmespxihxfqzxpjzynyajche	longitude	12	longitude	d	lng
60	nfpzglsypjyuhqausvglcsqzgdimaehl	id	0	id	d	\N
61	nfpzglsypjyuhqausvglcsqzgdimaehl	districts	1	Districts	d	\N
62	nfpzglsypjyuhqausvglcsqzgdimaehl	total_number_of_works	2	Total Number of Works	m	\N
63	nfpzglsypjyuhqausvglcsqzgdimaehl	total_number_of_completed_works	3	Total Number of Completed Works	m	\N
64	nfpzglsypjyuhqausvglcsqzgdimaehl	achievement__in_percent_	4	Achievement (in percent)	m	\N
\.


--
-- Name: column_meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('column_meta_id_seq', 64, true);


--
-- Data for Name: fpvuhdtsqnbbrixsowqwwzmuftamkqlv; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY fpvuhdtsqnbbrixsowqwwzmuftamkqlv (id, alphabet_name, column1, column2, column3, column4) FROM stdin;
1	Alpha	\N	\N	\N	\N
2	Beta	\N	\N	\N	\N
3	Gamma	\N	\N	\N	\N
4	Delta	\N	\N	\N	\N
5	Epsilon	\N	\N	\N	\N
6	Zeta	\N	\N	\N	\N
7	Eta	\N	\N	\N	\N
8	Theta	\N	\N	\N	\N
9	Iota	\N	\N	\N	\N
\.


--
-- Name: fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('fpvuhdtsqnbbrixsowqwwzmuftamkqlv_id_seq', 9, true);


--
-- Data for Name: nfpzglsypjyuhqausvglcsqzgdimaehl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY nfpzglsypjyuhqausvglcsqzgdimaehl (id, districts, total_number_of_works, total_number_of_completed_works, achievement__in_percent_) FROM stdin;
1	Sitapur	1155	1134	98.2000000000000028
2	Chandauli's	878	849	96.7000000000000028
3	Banswara	2073	2051	98.9000000000000057
4	Saraikela	467	465	99.5999999999999943
5	Chatra	461	448	97.0999999999999943
\.


--
-- Name: nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('nfpzglsypjyuhqausvglcsqzgdimaehl_id_seq', 5, true);


--
-- Data for Name: oxvfmwsjsmespxihxfqzxpjzynyajche; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY oxvfmwsjsmespxihxfqzxpjzynyajche (id, street, city, zip, state, beds, baths, sq__ft, type, sale_date, price, latitude, longitude) FROM stdin;
1	3526 HIGH ST	SACRAMENTO	95838	CA	2	1	836	Residential	Wed May 21 00:00:00 EDT 2008	59222	38.6319129999999973	-121.434878999999995
2	51 OMAHA CT	SACRAMENTO	95823	CA	3	1	1167	Residential	Wed May 21 00:00:00 EDT 2008	68212	38.4789019999999979	-121.431027999999998
3	2796 BRANCH ST	SACRAMENTO	95815	CA	2	1	796	Residential	Wed May 21 00:00:00 EDT 2008	68880	38.6183049999999994	-121.443838999999997
4	2805 JANETTE WAY	SACRAMENTO	95815	CA	2	1	852	Residential	Wed May 21 00:00:00 EDT 2008	69307	38.6168350000000018	-121.439145999999994
5	6001 MCMAHON DR	SACRAMENTO	95824	CA	2	1	797	Residential	Wed May 21 00:00:00 EDT 2008	81900	38.5194699999999983	-121.435767999999996
6	5828 PEPPERMILL CT	SACRAMENTO	95841	CA	3	1	1122	Condo	Wed May 21 00:00:00 EDT 2008	89921	38.6625950000000032	-121.327813000000006
7	6048 OGDEN NASH WAY	SACRAMENTO	95842	CA	3	2	1104	Residential	Wed May 21 00:00:00 EDT 2008	90895	38.6816590000000033	-121.351704999999995
8	2561 19TH AVE	SACRAMENTO	95820	CA	3	1	1177	Residential	Wed May 21 00:00:00 EDT 2008	91002	38.5350919999999988	-121.481367000000006
9	11150 TRINITY RIVER DR Unit 114	RANCHO CORDOVA	95670	CA	2	2	941	Condo	Wed May 21 00:00:00 EDT 2008	94905	38.6211879999999965	-121.270555000000002
10	7325 10TH ST	RIO LINDA	95673	CA	3	2	1146	Residential	Wed May 21 00:00:00 EDT 2008	98937	38.7009090000000029	-121.442978999999994
11	645 MORRISON AVE	SACRAMENTO	95838	CA	3	2	909	Residential	Wed May 21 00:00:00 EDT 2008	100309	38.6376630000000034	-121.451520000000002
12	4085 FAWN CIR	SACRAMENTO	95823	CA	3	2	1289	Residential	Wed May 21 00:00:00 EDT 2008	106250	38.4707459999999983	-121.458917999999997
13	2930 LA ROSA RD	SACRAMENTO	95815	CA	1	1	871	Residential	Wed May 21 00:00:00 EDT 2008	106852	38.618698000000002	-121.435833000000002
14	2113 KIRK WAY	SACRAMENTO	95822	CA	3	1	1020	Residential	Wed May 21 00:00:00 EDT 2008	107502	38.4822149999999965	-121.492603000000003
15	4533 LOCH HAVEN WAY	SACRAMENTO	95842	CA	2	2	1022	Residential	Wed May 21 00:00:00 EDT 2008	108750	38.6729139999999987	-121.359340000000003
16	7340 HAMDEN PL	SACRAMENTO	95842	CA	2	2	1134	Condo	Wed May 21 00:00:00 EDT 2008	110700	38.700051000000002	-121.351277999999994
17	6715 6TH ST	RIO LINDA	95673	CA	2	1	844	Residential	Wed May 21 00:00:00 EDT 2008	113263	38.6895910000000001	-121.452239000000006
18	6236 LONGFORD DR Unit 1	CITRUS HEIGHTS	95621	CA	2	1	795	Condo	Wed May 21 00:00:00 EDT 2008	116250	38.6797759999999968	-121.314088999999996
19	250 PERALTA AVE	SACRAMENTO	95833	CA	2	1	588	Residential	Wed May 21 00:00:00 EDT 2008	120000	38.6120990000000006	-121.469094999999996
20	113 LEEWILL AVE	RIO LINDA	95673	CA	3	2	1356	Residential	Wed May 21 00:00:00 EDT 2008	121630	38.6899990000000003	-121.463220000000007
21	6118 STONEHAND AVE	CITRUS HEIGHTS	95621	CA	3	2	1118	Residential	Wed May 21 00:00:00 EDT 2008	122000	38.707850999999998	-121.320706999999999
22	4882 BANDALIN WAY	SACRAMENTO	95823	CA	4	2	1329	Residential	Wed May 21 00:00:00 EDT 2008	122682	38.4681730000000002	-121.444070999999994
23	7511 OAKVALE CT	NORTH HIGHLANDS	95660	CA	4	2	1240	Residential	Wed May 21 00:00:00 EDT 2008	123000	38.7027920000000023	-121.382210000000001
24	9 PASTURE CT	SACRAMENTO	95834	CA	3	2	1601	Residential	Wed May 21 00:00:00 EDT 2008	124100	38.6286309999999986	-121.488096999999996
25	3729 BAINBRIDGE DR	NORTH HIGHLANDS	95660	CA	3	2	901	Residential	Wed May 21 00:00:00 EDT 2008	125000	38.7014989999999983	-121.376220000000004
26	3828 BLACKFOOT WAY	ANTELOPE	95843	CA	3	2	1088	Residential	Wed May 21 00:00:00 EDT 2008	126640	38.7097399999999965	-121.373769999999993
27	4108 NORTON WAY	SACRAMENTO	95820	CA	3	1	963	Residential	Wed May 21 00:00:00 EDT 2008	127281	38.5375259999999997	-121.478314999999995
28	1469 JANRICK AVE	SACRAMENTO	95832	CA	3	2	1119	Residential	Wed May 21 00:00:00 EDT 2008	129000	38.4764720000000011	-121.501711
29	9861 CULP WAY	SACRAMENTO	95827	CA	4	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	131200	38.5584229999999977	-121.327948000000006
30	7825 CREEK VALLEY CIR	SACRAMENTO	95828	CA	3	2	1248	Residential	Wed May 21 00:00:00 EDT 2008	132000	38.4721219999999988	-121.404199000000006
31	5201 LAGUNA OAKS DR Unit 140	ELK GROVE	95758	CA	2	2	1039	Condo	Wed May 21 00:00:00 EDT 2008	133000	38.4232510000000005	-121.444489000000004
32	6768 MEDORA DR	NORTH HIGHLANDS	95660	CA	3	2	1152	Residential	Wed May 21 00:00:00 EDT 2008	134555	38.691161000000001	-121.371920000000003
33	3100 EXPLORER DR	SACRAMENTO	95827	CA	3	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	136500	38.5666629999999984	-121.332644000000002
34	7944 DOMINION WAY	ELVERTA	95626	CA	3	2	1116	Residential	Wed May 21 00:00:00 EDT 2008	138750	38.7131820000000033	-121.411226999999997
35	5201 LAGUNA OAKS DR Unit 162	ELK GROVE	95758	CA	2	2	1039	Condo	Wed May 21 00:00:00 EDT 2008	141000	38.4232510000000005	-121.444489000000004
36	3920 SHINING STAR DR	SACRAMENTO	95823	CA	3	2	1418	Residential	Wed May 21 00:00:00 EDT 2008	146250	38.4874200000000002	-121.462458999999996
37	5031 CORVAIR ST	NORTH HIGHLANDS	95660	CA	3	2	1082	Residential	Wed May 21 00:00:00 EDT 2008	147308	38.6582459999999983	-121.375468999999995
38	7661 NIXOS WAY	SACRAMENTO	95823	CA	4	2	1472	Residential	Wed May 21 00:00:00 EDT 2008	148750	38.4795530000000028	-121.463317000000004
39	7044 CARTHY WAY	SACRAMENTO	95828	CA	4	2	1146	Residential	Wed May 21 00:00:00 EDT 2008	149593	38.4985700000000008	-121.420924999999997
40	2442 LARKSPUR LN	SACRAMENTO	95825	CA	1	1	760	Condo	Wed May 21 00:00:00 EDT 2008	150000	38.5851400000000027	-121.403735999999995
41	4800 WESTLAKE PKWY Unit 2109	SACRAMENTO	95835	CA	2	2	1304	Condo	Wed May 21 00:00:00 EDT 2008	152000	38.6588119999999975	-121.542344999999997
42	2178 63RD AVE	SACRAMENTO	95822	CA	3	2	1207	Residential	Wed May 21 00:00:00 EDT 2008	154000	38.4939549999999997	-121.489660000000001
43	8718 ELK WAY	ELK GROVE	95624	CA	3	2	1056	Residential	Wed May 21 00:00:00 EDT 2008	156896	38.4165300000000016	-121.379653000000005
44	5708 RIDGEPOINT DR	ANTELOPE	95843	CA	2	2	1043	Residential	Wed May 21 00:00:00 EDT 2008	161250	38.7202699999999993	-121.331554999999994
45	7315 KOALA CT	NORTH HIGHLANDS	95660	CA	4	2	1587	Residential	Wed May 21 00:00:00 EDT 2008	161500	38.6992509999999967	-121.371414000000001
46	2622 ERIN DR	SACRAMENTO	95833	CA	4	1	1120	Residential	Wed May 21 00:00:00 EDT 2008	164000	38.6137650000000008	-121.488693999999995
47	8421 SUNBLAZE WAY	SACRAMENTO	95823	CA	4	2	1580	Residential	Wed May 21 00:00:00 EDT 2008	165000	38.4505430000000032	-121.432537999999994
48	7420 ALIX PKWY	SACRAMENTO	95823	CA	4	1	1955	Residential	Wed May 21 00:00:00 EDT 2008	166357	38.4894049999999979	-121.452810999999997
49	3820 NATOMA WAY	SACRAMENTO	95838	CA	4	2	1656	Residential	Wed May 21 00:00:00 EDT 2008	166357	38.6367479999999972	-121.422158999999994
50	4431 GREEN TREE DR	SACRAMENTO	95823	CA	3	2	1477	Residential	Wed May 21 00:00:00 EDT 2008	168000	38.4999540000000025	-121.454469000000003
51	9417 SARA ST	ELK GROVE	95624	CA	3	2	1188	Residential	Wed May 21 00:00:00 EDT 2008	170000	38.4155179999999987	-121.370526999999996
52	8299 HALBRITE WAY	SACRAMENTO	95828	CA	4	2	1590	Residential	Wed May 21 00:00:00 EDT 2008	173000	38.4738139999999973	-121.400000000000006
53	7223 KALLIE KAY LN	SACRAMENTO	95823	CA	3	2	1463	Residential	Wed May 21 00:00:00 EDT 2008	174250	38.4775530000000003	-121.419462999999993
54	8156 STEINBECK WAY	SACRAMENTO	95828	CA	4	2	1714	Residential	Wed May 21 00:00:00 EDT 2008	174313	38.4748530000000031	-121.406326000000007
55	7957 VALLEY GREEN DR	SACRAMENTO	95823	CA	3	2	1185	Residential	Wed May 21 00:00:00 EDT 2008	178480	38.4651840000000007	-121.434925000000007
56	1122 WILD POPPY CT	GALT	95632	CA	3	2	1406	Residential	Wed May 21 00:00:00 EDT 2008	178760	38.2877889999999965	-121.294714999999997
57	4520 BOMARK WAY	SACRAMENTO	95842	CA	4	2	1943	Multi-Family	Wed May 21 00:00:00 EDT 2008	179580	38.6657239999999973	-121.358575999999999
58	9012 KIEFER BLVD	SACRAMENTO	95826	CA	3	2	1172	Residential	Wed May 21 00:00:00 EDT 2008	181000	38.5470109999999977	-121.366217000000006
59	5332 SANDSTONE ST	CARMICHAEL	95608	CA	3	1	1152	Residential	Wed May 21 00:00:00 EDT 2008	181872	38.6621049999999968	-121.313945000000004
60	5993 SAWYER CIR	SACRAMENTO	95823	CA	4	3	1851	Residential	Wed May 21 00:00:00 EDT 2008	182587	38.4472999999999985	-121.435218000000006
61	4844 CLYDEBANK WAY	ANTELOPE	95843	CA	3	2	1215	Residential	Wed May 21 00:00:00 EDT 2008	182716	38.7146090000000029	-121.347887
62	306 CAMELLIA WAY	GALT	95632	CA	3	2	1130	Residential	Wed May 21 00:00:00 EDT 2008	182750	38.2604430000000022	-121.297864000000004
63	9021 MADISON AVE	ORANGEVALE	95662	CA	4	2	1603	Residential	Wed May 21 00:00:00 EDT 2008	183200	38.6641860000000008	-121.217511000000002
64	404 6TH ST	GALT	95632	CA	3	1	1479	Residential	Wed May 21 00:00:00 EDT 2008	188741	38.2518079999999969	-121.302492999999998
65	8317 SUNNY CREEK WAY	SACRAMENTO	95823	CA	3	2	1420	Residential	Wed May 21 00:00:00 EDT 2008	189000	38.4590409999999991	-121.424644000000001
66	2617 BASS CT	SACRAMENTO	95826	CA	3	2	1280	Residential	Wed May 21 00:00:00 EDT 2008	192067	38.5607669999999985	-121.377471
67	7005 TIANT WAY	ELK GROVE	95758	CA	3	2	1586	Residential	Wed May 21 00:00:00 EDT 2008	194000	38.4228110000000029	-121.423285000000007
68	7895 CABER WAY	ANTELOPE	95843	CA	3	2	1362	Residential	Wed May 21 00:00:00 EDT 2008	194818	38.7112789999999976	-121.393449000000004
69	7624 BOGEY CT	SACRAMENTO	95828	CA	4	4	2162	Multi-Family	Wed May 21 00:00:00 EDT 2008	195000	38.480089999999997	-121.415102000000005
70	6930 HAMPTON COVE WAY	SACRAMENTO	95823	CA	3	2	1266	Residential	Wed May 21 00:00:00 EDT 2008	198000	38.4400400000000033	-121.421012000000005
71	8708 MESA BROOK WAY	ELK GROVE	95624	CA	4	2	1715	Residential	Wed May 21 00:00:00 EDT 2008	199500	38.4407599999999974	-121.385791999999995
72	120 GRANT LN	FOLSOM	95630	CA	3	2	1820	Residential	Wed May 21 00:00:00 EDT 2008	200000	38.6877420000000001	-121.171040000000005
73	5907 ELLERSLEE DR	CARMICHAEL	95608	CA	3	1	936	Residential	Wed May 21 00:00:00 EDT 2008	200000	38.6644679999999994	-121.326830000000001
74	17 SERASPI CT	SACRAMENTO	95834	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	206000	38.6314810000000008	-121.50188
75	170 PENHOW CIR	SACRAMENTO	95834	CA	3	2	1511	Residential	Wed May 21 00:00:00 EDT 2008	208000	38.6534389999999988	-121.535168999999996
76	8345 STAR THISTLE WAY	SACRAMENTO	95823	CA	4	2	1590	Residential	Wed May 21 00:00:00 EDT 2008	212864	38.4543490000000006	-121.439239000000001
77	9080 FRESCA WAY	ELK GROVE	95758	CA	4	2	1596	Residential	Wed May 21 00:00:00 EDT 2008	221000	38.427818000000002	-121.424025999999998
78	391 NATALINO CIR	SACRAMENTO	95835	CA	2	2	1341	Residential	Wed May 21 00:00:00 EDT 2008	221000	38.6730700000000027	-121.506372999999996
79	8373 BLACKMAN WAY	ELK GROVE	95624	CA	5	3	2136	Residential	Wed May 21 00:00:00 EDT 2008	223058	38.4354360000000028	-121.394536000000002
80	9837 CORTE DORADO CT	ELK GROVE	95624	CA	4	2	1616	Residential	Wed May 21 00:00:00 EDT 2008	227887	38.4006759999999971	-121.381010000000003
81	5037 J PKWY	SACRAMENTO	95823	CA	3	2	1478	Residential	Wed May 21 00:00:00 EDT 2008	231477	38.4913990000000013	-121.443546999999995
82	10245 LOS PALOS DR	RANCHO CORDOVA	95670	CA	3	2	1287	Residential	Wed May 21 00:00:00 EDT 2008	234697	38.5936990000000009	-121.310890000000001
83	6613 NAVION DR	CITRUS HEIGHTS	95621	CA	4	2	1277	Residential	Wed May 21 00:00:00 EDT 2008	235000	38.7028549999999996	-121.313079999999999
84	2887 AZEVEDO DR	SACRAMENTO	95833	CA	4	2	1448	Residential	Wed May 21 00:00:00 EDT 2008	236000	38.6184569999999994	-121.509439
85	9186 KINBRACE CT	SACRAMENTO	95829	CA	4	3	2235	Residential	Wed May 21 00:00:00 EDT 2008	236685	38.463355	-121.358936
86	4243 MIDDLEBURY WAY	MATHER	95655	CA	3	2	2093	Residential	Wed May 21 00:00:00 EDT 2008	237800	38.5479910000000032	-121.280483000000004
87	1028 FALLON PLACE CT	RIO LINDA	95673	CA	3	2	1193	Residential	Wed May 21 00:00:00 EDT 2008	240122	38.6938180000000003	-121.441153
88	4804 NORIKER DR	ELK GROVE	95757	CA	3	2	2163	Residential	Wed May 21 00:00:00 EDT 2008	242638	38.4009739999999979	-121.448424000000003
89	7713 HARVEST WOODS DR	SACRAMENTO	95828	CA	3	2	1269	Residential	Wed May 21 00:00:00 EDT 2008	244000	38.478197999999999	-121.412910999999994
90	2866 KARITSA AVE	SACRAMENTO	95833	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	244500	38.6266710000000018	-121.525970000000001
91	6913 RICHEVE WAY	SACRAMENTO	95828	CA	3	1	958	Residential	Wed May 21 00:00:00 EDT 2008	244960	38.5025189999999995	-121.420769000000007
92	8636 TEGEA WAY	ELK GROVE	95624	CA	5	3	2508	Residential	Wed May 21 00:00:00 EDT 2008	245918	38.4438320000000004	-121.382086999999999
93	5448 MAIDSTONE WAY	CITRUS HEIGHTS	95621	CA	3	2	1305	Residential	Wed May 21 00:00:00 EDT 2008	250000	38.6653949999999966	-121.293288000000004
94	18 OLLIE CT	ELK GROVE	95758	CA	4	2	1591	Residential	Wed May 21 00:00:00 EDT 2008	250000	38.4449090000000027	-121.412345000000002
95	4010 ALEX LN	CARMICHAEL	95608	CA	2	2	1326	Condo	Wed May 21 00:00:00 EDT 2008	250134	38.6370280000000008	-121.312962999999996
96	4901 MILLNER WAY	ELK GROVE	95757	CA	3	2	1843	Residential	Wed May 21 00:00:00 EDT 2008	254200	38.3869200000000035	-121.447349000000003
97	4818 BRITTNEY LEE CT	SACRAMENTO	95841	CA	4	2	1921	Residential	Wed May 21 00:00:00 EDT 2008	254200	38.6539169999999999	-121.342179999999999
98	5529 LAGUNA PARK DR	ELK GROVE	95758	CA	5	3	2790	Residential	Wed May 21 00:00:00 EDT 2008	258000	38.4256799999999998	-121.438062000000002
99	230 CANDELA CIR	SACRAMENTO	95835	CA	3	2	1541	Residential	Wed May 21 00:00:00 EDT 2008	260000	38.6562509999999975	-121.547572000000002
100	4900 71ST ST	SACRAMENTO	95820	CA	3	1	1018	Residential	Wed May 21 00:00:00 EDT 2008	260014	38.5315099999999973	-121.421088999999995
101	12209 CONSERVANCY WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	263500	38.5538669999999968	-121.219140999999993
102	4236 NATOMAS CENTRAL DR	SACRAMENTO	95834	CA	3	2	1672	Condo	Wed May 21 00:00:00 EDT 2008	265000	38.6488790000000009	-121.544022999999996
103	5615 LUPIN LN	POLLOCK PINES	95726	CA	3	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	265000	38.7083149999999989	-120.603871999999996
104	5625 JAMES WAY	SACRAMENTO	95822	CA	3	1	975	Residential	Wed May 21 00:00:00 EDT 2008	271742	38.5239469999999997	-121.484945999999994
105	7842 LAHONTAN CT	SACRAMENTO	95829	CA	4	3	2372	Residential	Wed May 21 00:00:00 EDT 2008	273750	38.4729760000000027	-121.318633000000005
106	6850 21ST ST	SACRAMENTO	95822	CA	3	2	1446	Residential	Wed May 21 00:00:00 EDT 2008	275086	38.5021940000000029	-121.490795000000006
107	2900 BLAIR RD	POLLOCK PINES	95726	CA	2	2	1284	Residential	Wed May 21 00:00:00 EDT 2008	280908	38.7548499999999976	-120.604759999999999
108	2064 EXPEDITION WAY	SACRAMENTO	95832	CA	4	3	3009	Residential	Wed May 21 00:00:00 EDT 2008	280987	38.4740990000000025	-121.490711000000005
109	2912 NORCADE CIR	SACRAMENTO	95826	CA	8	4	3612	Multi-Family	Wed May 21 00:00:00 EDT 2008	282400	38.5595050000000015	-121.364839000000003
110	9507 SEA CLIFF WAY	ELK GROVE	95758	CA	4	2	2056	Residential	Wed May 21 00:00:00 EDT 2008	285000	38.4109920000000002	-121.479043000000004
111	8882 AUTUMN GOLD CT	ELK GROVE	95624	CA	4	2	1993	Residential	Wed May 21 00:00:00 EDT 2008	287417	38.4438999999999993	-121.372550000000004
112	5322 WHITE LOTUS WAY	ELK GROVE	95757	CA	3	2	1857	Residential	Wed May 21 00:00:00 EDT 2008	291000	38.3915379999999971	-121.442595999999995
113	1838 CASTRO WAY	SACRAMENTO	95818	CA	2	1	1126	Residential	Wed May 21 00:00:00 EDT 2008	292024	38.5560979999999986	-121.490786999999997
114	10158 CRAWFORD WAY	SACRAMENTO	95827	CA	4	4	2213	Multi-Family	Wed May 21 00:00:00 EDT 2008	297000	38.5703000000000031	-121.315735000000004
115	7731 MASTERS ST	ELK GROVE	95758	CA	5	3	2494	Residential	Wed May 21 00:00:00 EDT 2008	297000	38.4420310000000001	-121.410872999999995
116	4925 PERCHERON DR	ELK GROVE	95757	CA	3	2	1843	Residential	Wed May 21 00:00:00 EDT 2008	298000	38.4015399999999971	-121.447648999999998
117	2010 PROMONTORY POINT LN	GOLD RIVER	95670	CA	2	2	1520	Residential	Wed May 21 00:00:00 EDT 2008	299000	38.6286899999999989	-121.261668999999998
118	4727 SAVOIE WAY	SACRAMENTO	95835	CA	5	3	2800	Residential	Wed May 21 00:00:00 EDT 2008	304037	38.6581819999999965	-121.549520999999999
119	8664 MAGNOLIA HILL WAY	ELK GROVE	95624	CA	4	2	2309	Residential	Wed May 21 00:00:00 EDT 2008	311000	38.4423519999999996	-121.389674999999997
120	9570 HARVEST ROSE WAY	SACRAMENTO	95827	CA	5	3	2367	Residential	Wed May 21 00:00:00 EDT 2008	315537	38.5559930000000008	-121.340351999999996
121	4359 CREGAN CT	RANCHO CORDOVA	95742	CA	5	4	3516	Residential	Wed May 21 00:00:00 EDT 2008	320000	38.5451279999999983	-121.224922000000007
122	5337 DUSTY ROSE WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	320000	38.5285749999999965	-121.2286
123	8929 SUTTERS GOLD DR	SACRAMENTO	95826	CA	4	3	1914	Residential	Wed May 21 00:00:00 EDT 2008	328360	38.550848000000002	-121.370223999999993
124	8025 PEERLESS AVE	ORANGEVALE	95662	CA	2	1	1690	Residential	Wed May 21 00:00:00 EDT 2008	334150	38.7114699999999985	-121.216213999999994
125	4620 WELERA WAY	ELK GROVE	95757	CA	3	3	2725	Residential	Wed May 21 00:00:00 EDT 2008	335750	38.3986090000000004	-121.450147999999999
126	9723 TERRAPIN CT	ELK GROVE	95757	CA	4	3	2354	Residential	Wed May 21 00:00:00 EDT 2008	335750	38.403492	-121.430223999999995
127	2115 SMOKESTACK WAY	SACRAMENTO	95833	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	339500	38.6024159999999981	-121.542964999999995
128	100 REBECCA WAY	FOLSOM	95630	CA	3	2	2185	Residential	Wed May 21 00:00:00 EDT 2008	344250	38.6847899999999996	-121.149198999999996
129	9488 OAK VILLAGE WAY	ELK GROVE	95758	CA	4	2	1801	Residential	Wed May 21 00:00:00 EDT 2008	346210	38.413330000000002	-121.404999000000004
130	8495 DARTFORD DR	SACRAMENTO	95823	CA	3	3	1961	Residential	Wed May 21 00:00:00 EDT 2008	347029	38.4485069999999993	-121.421346
131	6708 PONTA DO SOL WAY	ELK GROVE	95757	CA	4	2	3134	Residential	Wed May 21 00:00:00 EDT 2008	347650	38.3806349999999981	-121.425538000000003
132	4143 SEA MEADOW WAY	SACRAMENTO	95823	CA	4	3	1915	Residential	Wed May 21 00:00:00 EDT 2008	351300	38.4653399999999976	-121.457519000000005
133	3020 RICHARDSON CIR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Wed May 21 00:00:00 EDT 2008	352000	38.6912990000000008	-121.081751999999994
134	8082 LINDA ISLE LN	SACRAMENTO	95831	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	370000	38.4772000000000034	-121.521500000000003
135	15300 MURIETA SOUTH PKWY	RANCHO MURIETA	95683	CA	4	3	2734	Residential	Wed May 21 00:00:00 EDT 2008	370500	38.4874000000000009	-121.075129000000004
136	11215 SHARRMONT CT	WILTON	95693	CA	3	2	2110	Residential	Wed May 21 00:00:00 EDT 2008	372000	38.3506199999999993	-121.228348999999994
137	7105 DANBERG WAY	ELK GROVE	95757	CA	5	3	3164	Residential	Wed May 21 00:00:00 EDT 2008	375000	38.4018999999999977	-121.420388000000003
138	5579 JERRY LITELL WAY	SACRAMENTO	95835	CA	5	3	3599	Residential	Wed May 21 00:00:00 EDT 2008	381300	38.6771260000000012	-121.500518999999997
139	1050 FOXHALL WAY	SACRAMENTO	95831	CA	4	2	2054	Residential	Wed May 21 00:00:00 EDT 2008	381942	38.5098190000000002	-121.519660999999999
140	7837 ABBINGTON WAY	ANTELOPE	95843	CA	4	2	1830	Residential	Wed May 21 00:00:00 EDT 2008	387731	38.7098730000000018	-121.339472000000001
141	1300 F ST	SACRAMENTO	95814	CA	3	3	1627	Residential	Wed May 21 00:00:00 EDT 2008	391000	38.5835500000000025	-121.487289000000004
142	6801 RAWLEY WAY	ELK GROVE	95757	CA	4	3	3440	Residential	Wed May 21 00:00:00 EDT 2008	394470	38.4083510000000032	-121.423924999999997
143	1693 SHELTER COVE DR	GREENWOOD	95635	CA	3	2	2846	Residential	Wed May 21 00:00:00 EDT 2008	395000	38.9453570000000013	-120.908822000000001
144	9361 WADDELL LN	ELK GROVE	95624	CA	4	3	2359	Residential	Wed May 21 00:00:00 EDT 2008	400186	38.4508289999999988	-121.349928000000006
145	10 SEA FOAM CT	SACRAMENTO	95831	CA	3	3	2052	Residential	Wed May 21 00:00:00 EDT 2008	415000	38.4878849999999986	-121.545946999999998
146	6945 RIO TEJO WAY	ELK GROVE	95757	CA	5	3	3433	Residential	Wed May 21 00:00:00 EDT 2008	425000	38.3856380000000001	-121.422616000000005
147	4186 TULIP PARK WAY	RANCHO CORDOVA	95742	CA	5	3	3615	Residential	Wed May 21 00:00:00 EDT 2008	430000	38.5506170000000026	-121.235259999999997
148	9278 DAIRY CT	ELK GROVE	95624	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	445000	38.420338000000001	-121.363757000000007
\.


--
-- Name: oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('oxvfmwsjsmespxihxfqzxpjzynyajche_id_seq', 148, true);


--
-- Data for Name: roujygtyrqhmfikbpoitmwbwdwzkggki; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY roujygtyrqhmfikbpoitmwbwdwzkggki (id, street, city, zip, state, beds, baths, sq__ft, type, sale_date, price, latitude, longitude) FROM stdin;
1	3526 HIGH ST	SACRAMENTO	95838	CA	2	1	836	Residential	Wed May 21 00:00:00 EDT 2008	59222	38.6319129999999973	-121.434878999999995
2	51 OMAHA CT	SACRAMENTO	95823	CA	3	1	1167	Residential	Wed May 21 00:00:00 EDT 2008	68212	38.4789019999999979	-121.431027999999998
3	2796 BRANCH ST	SACRAMENTO	95815	CA	2	1	796	Residential	Wed May 21 00:00:00 EDT 2008	68880	38.6183049999999994	-121.443838999999997
4	2805 JANETTE WAY	SACRAMENTO	95815	CA	2	1	852	Residential	Wed May 21 00:00:00 EDT 2008	69307	38.6168350000000018	-121.439145999999994
5	6001 MCMAHON DR	SACRAMENTO	95824	CA	2	1	797	Residential	Wed May 21 00:00:00 EDT 2008	81900	38.5194699999999983	-121.435767999999996
6	5828 PEPPERMILL CT	SACRAMENTO	95841	CA	3	1	1122	Condo	Wed May 21 00:00:00 EDT 2008	89921	38.6625950000000032	-121.327813000000006
7	6048 OGDEN NASH WAY	SACRAMENTO	95842	CA	3	2	1104	Residential	Wed May 21 00:00:00 EDT 2008	90895	38.6816590000000033	-121.351704999999995
8	2561 19TH AVE	SACRAMENTO	95820	CA	3	1	1177	Residential	Wed May 21 00:00:00 EDT 2008	91002	38.5350919999999988	-121.481367000000006
9	11150 TRINITY RIVER DR Unit 114	RANCHO CORDOVA	95670	CA	2	2	941	Condo	Wed May 21 00:00:00 EDT 2008	94905	38.6211879999999965	-121.270555000000002
10	7325 10TH ST	RIO LINDA	95673	CA	3	2	1146	Residential	Wed May 21 00:00:00 EDT 2008	98937	38.7009090000000029	-121.442978999999994
11	645 MORRISON AVE	SACRAMENTO	95838	CA	3	2	909	Residential	Wed May 21 00:00:00 EDT 2008	100309	38.6376630000000034	-121.451520000000002
12	4085 FAWN CIR	SACRAMENTO	95823	CA	3	2	1289	Residential	Wed May 21 00:00:00 EDT 2008	106250	38.4707459999999983	-121.458917999999997
13	2930 LA ROSA RD	SACRAMENTO	95815	CA	1	1	871	Residential	Wed May 21 00:00:00 EDT 2008	106852	38.618698000000002	-121.435833000000002
14	2113 KIRK WAY	SACRAMENTO	95822	CA	3	1	1020	Residential	Wed May 21 00:00:00 EDT 2008	107502	38.4822149999999965	-121.492603000000003
15	4533 LOCH HAVEN WAY	SACRAMENTO	95842	CA	2	2	1022	Residential	Wed May 21 00:00:00 EDT 2008	108750	38.6729139999999987	-121.359340000000003
16	7340 HAMDEN PL	SACRAMENTO	95842	CA	2	2	1134	Condo	Wed May 21 00:00:00 EDT 2008	110700	38.700051000000002	-121.351277999999994
17	6715 6TH ST	RIO LINDA	95673	CA	2	1	844	Residential	Wed May 21 00:00:00 EDT 2008	113263	38.6895910000000001	-121.452239000000006
18	6236 LONGFORD DR Unit 1	CITRUS HEIGHTS	95621	CA	2	1	795	Condo	Wed May 21 00:00:00 EDT 2008	116250	38.6797759999999968	-121.314088999999996
19	250 PERALTA AVE	SACRAMENTO	95833	CA	2	1	588	Residential	Wed May 21 00:00:00 EDT 2008	120000	38.6120990000000006	-121.469094999999996
20	113 LEEWILL AVE	RIO LINDA	95673	CA	3	2	1356	Residential	Wed May 21 00:00:00 EDT 2008	121630	38.6899990000000003	-121.463220000000007
21	6118 STONEHAND AVE	CITRUS HEIGHTS	95621	CA	3	2	1118	Residential	Wed May 21 00:00:00 EDT 2008	122000	38.707850999999998	-121.320706999999999
22	4882 BANDALIN WAY	SACRAMENTO	95823	CA	4	2	1329	Residential	Wed May 21 00:00:00 EDT 2008	122682	38.4681730000000002	-121.444070999999994
23	7511 OAKVALE CT	NORTH HIGHLANDS	95660	CA	4	2	1240	Residential	Wed May 21 00:00:00 EDT 2008	123000	38.7027920000000023	-121.382210000000001
24	9 PASTURE CT	SACRAMENTO	95834	CA	3	2	1601	Residential	Wed May 21 00:00:00 EDT 2008	124100	38.6286309999999986	-121.488096999999996
25	3729 BAINBRIDGE DR	NORTH HIGHLANDS	95660	CA	3	2	901	Residential	Wed May 21 00:00:00 EDT 2008	125000	38.7014989999999983	-121.376220000000004
26	3828 BLACKFOOT WAY	ANTELOPE	95843	CA	3	2	1088	Residential	Wed May 21 00:00:00 EDT 2008	126640	38.7097399999999965	-121.373769999999993
27	4108 NORTON WAY	SACRAMENTO	95820	CA	3	1	963	Residential	Wed May 21 00:00:00 EDT 2008	127281	38.5375259999999997	-121.478314999999995
28	1469 JANRICK AVE	SACRAMENTO	95832	CA	3	2	1119	Residential	Wed May 21 00:00:00 EDT 2008	129000	38.4764720000000011	-121.501711
29	9861 CULP WAY	SACRAMENTO	95827	CA	4	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	131200	38.5584229999999977	-121.327948000000006
30	7825 CREEK VALLEY CIR	SACRAMENTO	95828	CA	3	2	1248	Residential	Wed May 21 00:00:00 EDT 2008	132000	38.4721219999999988	-121.404199000000006
31	5201 LAGUNA OAKS DR Unit 140	ELK GROVE	95758	CA	2	2	1039	Condo	Wed May 21 00:00:00 EDT 2008	133000	38.4232510000000005	-121.444489000000004
32	6768 MEDORA DR	NORTH HIGHLANDS	95660	CA	3	2	1152	Residential	Wed May 21 00:00:00 EDT 2008	134555	38.691161000000001	-121.371920000000003
33	3100 EXPLORER DR	SACRAMENTO	95827	CA	3	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	136500	38.5666629999999984	-121.332644000000002
34	7944 DOMINION WAY	ELVERTA	95626	CA	3	2	1116	Residential	Wed May 21 00:00:00 EDT 2008	138750	38.7131820000000033	-121.411226999999997
35	5201 LAGUNA OAKS DR Unit 162	ELK GROVE	95758	CA	2	2	1039	Condo	Wed May 21 00:00:00 EDT 2008	141000	38.4232510000000005	-121.444489000000004
36	3920 SHINING STAR DR	SACRAMENTO	95823	CA	3	2	1418	Residential	Wed May 21 00:00:00 EDT 2008	146250	38.4874200000000002	-121.462458999999996
37	5031 CORVAIR ST	NORTH HIGHLANDS	95660	CA	3	2	1082	Residential	Wed May 21 00:00:00 EDT 2008	147308	38.6582459999999983	-121.375468999999995
38	7661 NIXOS WAY	SACRAMENTO	95823	CA	4	2	1472	Residential	Wed May 21 00:00:00 EDT 2008	148750	38.4795530000000028	-121.463317000000004
39	7044 CARTHY WAY	SACRAMENTO	95828	CA	4	2	1146	Residential	Wed May 21 00:00:00 EDT 2008	149593	38.4985700000000008	-121.420924999999997
40	2442 LARKSPUR LN	SACRAMENTO	95825	CA	1	1	760	Condo	Wed May 21 00:00:00 EDT 2008	150000	38.5851400000000027	-121.403735999999995
41	4800 WESTLAKE PKWY Unit 2109	SACRAMENTO	95835	CA	2	2	1304	Condo	Wed May 21 00:00:00 EDT 2008	152000	38.6588119999999975	-121.542344999999997
42	2178 63RD AVE	SACRAMENTO	95822	CA	3	2	1207	Residential	Wed May 21 00:00:00 EDT 2008	154000	38.4939549999999997	-121.489660000000001
43	8718 ELK WAY	ELK GROVE	95624	CA	3	2	1056	Residential	Wed May 21 00:00:00 EDT 2008	156896	38.4165300000000016	-121.379653000000005
44	5708 RIDGEPOINT DR	ANTELOPE	95843	CA	2	2	1043	Residential	Wed May 21 00:00:00 EDT 2008	161250	38.7202699999999993	-121.331554999999994
45	7315 KOALA CT	NORTH HIGHLANDS	95660	CA	4	2	1587	Residential	Wed May 21 00:00:00 EDT 2008	161500	38.6992509999999967	-121.371414000000001
46	2622 ERIN DR	SACRAMENTO	95833	CA	4	1	1120	Residential	Wed May 21 00:00:00 EDT 2008	164000	38.6137650000000008	-121.488693999999995
47	8421 SUNBLAZE WAY	SACRAMENTO	95823	CA	4	2	1580	Residential	Wed May 21 00:00:00 EDT 2008	165000	38.4505430000000032	-121.432537999999994
48	7420 ALIX PKWY	SACRAMENTO	95823	CA	4	1	1955	Residential	Wed May 21 00:00:00 EDT 2008	166357	38.4894049999999979	-121.452810999999997
49	3820 NATOMA WAY	SACRAMENTO	95838	CA	4	2	1656	Residential	Wed May 21 00:00:00 EDT 2008	166357	38.6367479999999972	-121.422158999999994
50	4431 GREEN TREE DR	SACRAMENTO	95823	CA	3	2	1477	Residential	Wed May 21 00:00:00 EDT 2008	168000	38.4999540000000025	-121.454469000000003
51	9417 SARA ST	ELK GROVE	95624	CA	3	2	1188	Residential	Wed May 21 00:00:00 EDT 2008	170000	38.4155179999999987	-121.370526999999996
52	8299 HALBRITE WAY	SACRAMENTO	95828	CA	4	2	1590	Residential	Wed May 21 00:00:00 EDT 2008	173000	38.4738139999999973	-121.400000000000006
53	7223 KALLIE KAY LN	SACRAMENTO	95823	CA	3	2	1463	Residential	Wed May 21 00:00:00 EDT 2008	174250	38.4775530000000003	-121.419462999999993
54	8156 STEINBECK WAY	SACRAMENTO	95828	CA	4	2	1714	Residential	Wed May 21 00:00:00 EDT 2008	174313	38.4748530000000031	-121.406326000000007
55	7957 VALLEY GREEN DR	SACRAMENTO	95823	CA	3	2	1185	Residential	Wed May 21 00:00:00 EDT 2008	178480	38.4651840000000007	-121.434925000000007
56	1122 WILD POPPY CT	GALT	95632	CA	3	2	1406	Residential	Wed May 21 00:00:00 EDT 2008	178760	38.2877889999999965	-121.294714999999997
57	4520 BOMARK WAY	SACRAMENTO	95842	CA	4	2	1943	Multi-Family	Wed May 21 00:00:00 EDT 2008	179580	38.6657239999999973	-121.358575999999999
58	9012 KIEFER BLVD	SACRAMENTO	95826	CA	3	2	1172	Residential	Wed May 21 00:00:00 EDT 2008	181000	38.5470109999999977	-121.366217000000006
59	5332 SANDSTONE ST	CARMICHAEL	95608	CA	3	1	1152	Residential	Wed May 21 00:00:00 EDT 2008	181872	38.6621049999999968	-121.313945000000004
60	5993 SAWYER CIR	SACRAMENTO	95823	CA	4	3	1851	Residential	Wed May 21 00:00:00 EDT 2008	182587	38.4472999999999985	-121.435218000000006
61	4844 CLYDEBANK WAY	ANTELOPE	95843	CA	3	2	1215	Residential	Wed May 21 00:00:00 EDT 2008	182716	38.7146090000000029	-121.347887
62	306 CAMELLIA WAY	GALT	95632	CA	3	2	1130	Residential	Wed May 21 00:00:00 EDT 2008	182750	38.2604430000000022	-121.297864000000004
63	9021 MADISON AVE	ORANGEVALE	95662	CA	4	2	1603	Residential	Wed May 21 00:00:00 EDT 2008	183200	38.6641860000000008	-121.217511000000002
64	404 6TH ST	GALT	95632	CA	3	1	1479	Residential	Wed May 21 00:00:00 EDT 2008	188741	38.2518079999999969	-121.302492999999998
65	8317 SUNNY CREEK WAY	SACRAMENTO	95823	CA	3	2	1420	Residential	Wed May 21 00:00:00 EDT 2008	189000	38.4590409999999991	-121.424644000000001
66	2617 BASS CT	SACRAMENTO	95826	CA	3	2	1280	Residential	Wed May 21 00:00:00 EDT 2008	192067	38.5607669999999985	-121.377471
67	7005 TIANT WAY	ELK GROVE	95758	CA	3	2	1586	Residential	Wed May 21 00:00:00 EDT 2008	194000	38.4228110000000029	-121.423285000000007
68	7895 CABER WAY	ANTELOPE	95843	CA	3	2	1362	Residential	Wed May 21 00:00:00 EDT 2008	194818	38.7112789999999976	-121.393449000000004
69	7624 BOGEY CT	SACRAMENTO	95828	CA	4	4	2162	Multi-Family	Wed May 21 00:00:00 EDT 2008	195000	38.480089999999997	-121.415102000000005
70	6930 HAMPTON COVE WAY	SACRAMENTO	95823	CA	3	2	1266	Residential	Wed May 21 00:00:00 EDT 2008	198000	38.4400400000000033	-121.421012000000005
71	8708 MESA BROOK WAY	ELK GROVE	95624	CA	4	2	1715	Residential	Wed May 21 00:00:00 EDT 2008	199500	38.4407599999999974	-121.385791999999995
72	120 GRANT LN	FOLSOM	95630	CA	3	2	1820	Residential	Wed May 21 00:00:00 EDT 2008	200000	38.6877420000000001	-121.171040000000005
73	5907 ELLERSLEE DR	CARMICHAEL	95608	CA	3	1	936	Residential	Wed May 21 00:00:00 EDT 2008	200000	38.6644679999999994	-121.326830000000001
74	17 SERASPI CT	SACRAMENTO	95834	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	206000	38.6314810000000008	-121.50188
75	170 PENHOW CIR	SACRAMENTO	95834	CA	3	2	1511	Residential	Wed May 21 00:00:00 EDT 2008	208000	38.6534389999999988	-121.535168999999996
76	8345 STAR THISTLE WAY	SACRAMENTO	95823	CA	4	2	1590	Residential	Wed May 21 00:00:00 EDT 2008	212864	38.4543490000000006	-121.439239000000001
77	9080 FRESCA WAY	ELK GROVE	95758	CA	4	2	1596	Residential	Wed May 21 00:00:00 EDT 2008	221000	38.427818000000002	-121.424025999999998
78	391 NATALINO CIR	SACRAMENTO	95835	CA	2	2	1341	Residential	Wed May 21 00:00:00 EDT 2008	221000	38.6730700000000027	-121.506372999999996
79	8373 BLACKMAN WAY	ELK GROVE	95624	CA	5	3	2136	Residential	Wed May 21 00:00:00 EDT 2008	223058	38.4354360000000028	-121.394536000000002
80	9837 CORTE DORADO CT	ELK GROVE	95624	CA	4	2	1616	Residential	Wed May 21 00:00:00 EDT 2008	227887	38.4006759999999971	-121.381010000000003
81	5037 J PKWY	SACRAMENTO	95823	CA	3	2	1478	Residential	Wed May 21 00:00:00 EDT 2008	231477	38.4913990000000013	-121.443546999999995
82	10245 LOS PALOS DR	RANCHO CORDOVA	95670	CA	3	2	1287	Residential	Wed May 21 00:00:00 EDT 2008	234697	38.5936990000000009	-121.310890000000001
83	6613 NAVION DR	CITRUS HEIGHTS	95621	CA	4	2	1277	Residential	Wed May 21 00:00:00 EDT 2008	235000	38.7028549999999996	-121.313079999999999
84	2887 AZEVEDO DR	SACRAMENTO	95833	CA	4	2	1448	Residential	Wed May 21 00:00:00 EDT 2008	236000	38.6184569999999994	-121.509439
85	9186 KINBRACE CT	SACRAMENTO	95829	CA	4	3	2235	Residential	Wed May 21 00:00:00 EDT 2008	236685	38.463355	-121.358936
86	4243 MIDDLEBURY WAY	MATHER	95655	CA	3	2	2093	Residential	Wed May 21 00:00:00 EDT 2008	237800	38.5479910000000032	-121.280483000000004
87	1028 FALLON PLACE CT	RIO LINDA	95673	CA	3	2	1193	Residential	Wed May 21 00:00:00 EDT 2008	240122	38.6938180000000003	-121.441153
88	4804 NORIKER DR	ELK GROVE	95757	CA	3	2	2163	Residential	Wed May 21 00:00:00 EDT 2008	242638	38.4009739999999979	-121.448424000000003
89	7713 HARVEST WOODS DR	SACRAMENTO	95828	CA	3	2	1269	Residential	Wed May 21 00:00:00 EDT 2008	244000	38.478197999999999	-121.412910999999994
90	2866 KARITSA AVE	SACRAMENTO	95833	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	244500	38.6266710000000018	-121.525970000000001
91	6913 RICHEVE WAY	SACRAMENTO	95828	CA	3	1	958	Residential	Wed May 21 00:00:00 EDT 2008	244960	38.5025189999999995	-121.420769000000007
92	8636 TEGEA WAY	ELK GROVE	95624	CA	5	3	2508	Residential	Wed May 21 00:00:00 EDT 2008	245918	38.4438320000000004	-121.382086999999999
93	5448 MAIDSTONE WAY	CITRUS HEIGHTS	95621	CA	3	2	1305	Residential	Wed May 21 00:00:00 EDT 2008	250000	38.6653949999999966	-121.293288000000004
94	18 OLLIE CT	ELK GROVE	95758	CA	4	2	1591	Residential	Wed May 21 00:00:00 EDT 2008	250000	38.4449090000000027	-121.412345000000002
95	4010 ALEX LN	CARMICHAEL	95608	CA	2	2	1326	Condo	Wed May 21 00:00:00 EDT 2008	250134	38.6370280000000008	-121.312962999999996
96	4901 MILLNER WAY	ELK GROVE	95757	CA	3	2	1843	Residential	Wed May 21 00:00:00 EDT 2008	254200	38.3869200000000035	-121.447349000000003
97	4818 BRITTNEY LEE CT	SACRAMENTO	95841	CA	4	2	1921	Residential	Wed May 21 00:00:00 EDT 2008	254200	38.6539169999999999	-121.342179999999999
98	5529 LAGUNA PARK DR	ELK GROVE	95758	CA	5	3	2790	Residential	Wed May 21 00:00:00 EDT 2008	258000	38.4256799999999998	-121.438062000000002
99	230 CANDELA CIR	SACRAMENTO	95835	CA	3	2	1541	Residential	Wed May 21 00:00:00 EDT 2008	260000	38.6562509999999975	-121.547572000000002
100	4900 71ST ST	SACRAMENTO	95820	CA	3	1	1018	Residential	Wed May 21 00:00:00 EDT 2008	260014	38.5315099999999973	-121.421088999999995
101	12209 CONSERVANCY WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	263500	38.5538669999999968	-121.219140999999993
102	4236 NATOMAS CENTRAL DR	SACRAMENTO	95834	CA	3	2	1672	Condo	Wed May 21 00:00:00 EDT 2008	265000	38.6488790000000009	-121.544022999999996
103	5615 LUPIN LN	POLLOCK PINES	95726	CA	3	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	265000	38.7083149999999989	-120.603871999999996
104	5625 JAMES WAY	SACRAMENTO	95822	CA	3	1	975	Residential	Wed May 21 00:00:00 EDT 2008	271742	38.5239469999999997	-121.484945999999994
105	7842 LAHONTAN CT	SACRAMENTO	95829	CA	4	3	2372	Residential	Wed May 21 00:00:00 EDT 2008	273750	38.4729760000000027	-121.318633000000005
106	6850 21ST ST	SACRAMENTO	95822	CA	3	2	1446	Residential	Wed May 21 00:00:00 EDT 2008	275086	38.5021940000000029	-121.490795000000006
107	2900 BLAIR RD	POLLOCK PINES	95726	CA	2	2	1284	Residential	Wed May 21 00:00:00 EDT 2008	280908	38.7548499999999976	-120.604759999999999
108	2064 EXPEDITION WAY	SACRAMENTO	95832	CA	4	3	3009	Residential	Wed May 21 00:00:00 EDT 2008	280987	38.4740990000000025	-121.490711000000005
109	2912 NORCADE CIR	SACRAMENTO	95826	CA	8	4	3612	Multi-Family	Wed May 21 00:00:00 EDT 2008	282400	38.5595050000000015	-121.364839000000003
110	9507 SEA CLIFF WAY	ELK GROVE	95758	CA	4	2	2056	Residential	Wed May 21 00:00:00 EDT 2008	285000	38.4109920000000002	-121.479043000000004
111	8882 AUTUMN GOLD CT	ELK GROVE	95624	CA	4	2	1993	Residential	Wed May 21 00:00:00 EDT 2008	287417	38.4438999999999993	-121.372550000000004
112	5322 WHITE LOTUS WAY	ELK GROVE	95757	CA	3	2	1857	Residential	Wed May 21 00:00:00 EDT 2008	291000	38.3915379999999971	-121.442595999999995
113	1838 CASTRO WAY	SACRAMENTO	95818	CA	2	1	1126	Residential	Wed May 21 00:00:00 EDT 2008	292024	38.5560979999999986	-121.490786999999997
114	10158 CRAWFORD WAY	SACRAMENTO	95827	CA	4	4	2213	Multi-Family	Wed May 21 00:00:00 EDT 2008	297000	38.5703000000000031	-121.315735000000004
115	7731 MASTERS ST	ELK GROVE	95758	CA	5	3	2494	Residential	Wed May 21 00:00:00 EDT 2008	297000	38.4420310000000001	-121.410872999999995
116	4925 PERCHERON DR	ELK GROVE	95757	CA	3	2	1843	Residential	Wed May 21 00:00:00 EDT 2008	298000	38.4015399999999971	-121.447648999999998
117	2010 PROMONTORY POINT LN	GOLD RIVER	95670	CA	2	2	1520	Residential	Wed May 21 00:00:00 EDT 2008	299000	38.6286899999999989	-121.261668999999998
118	4727 SAVOIE WAY	SACRAMENTO	95835	CA	5	3	2800	Residential	Wed May 21 00:00:00 EDT 2008	304037	38.6581819999999965	-121.549520999999999
119	8664 MAGNOLIA HILL WAY	ELK GROVE	95624	CA	4	2	2309	Residential	Wed May 21 00:00:00 EDT 2008	311000	38.4423519999999996	-121.389674999999997
120	9570 HARVEST ROSE WAY	SACRAMENTO	95827	CA	5	3	2367	Residential	Wed May 21 00:00:00 EDT 2008	315537	38.5559930000000008	-121.340351999999996
121	4359 CREGAN CT	RANCHO CORDOVA	95742	CA	5	4	3516	Residential	Wed May 21 00:00:00 EDT 2008	320000	38.5451279999999983	-121.224922000000007
122	5337 DUSTY ROSE WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	320000	38.5285749999999965	-121.2286
123	8929 SUTTERS GOLD DR	SACRAMENTO	95826	CA	4	3	1914	Residential	Wed May 21 00:00:00 EDT 2008	328360	38.550848000000002	-121.370223999999993
124	8025 PEERLESS AVE	ORANGEVALE	95662	CA	2	1	1690	Residential	Wed May 21 00:00:00 EDT 2008	334150	38.7114699999999985	-121.216213999999994
125	4620 WELERA WAY	ELK GROVE	95757	CA	3	3	2725	Residential	Wed May 21 00:00:00 EDT 2008	335750	38.3986090000000004	-121.450147999999999
126	9723 TERRAPIN CT	ELK GROVE	95757	CA	4	3	2354	Residential	Wed May 21 00:00:00 EDT 2008	335750	38.403492	-121.430223999999995
127	2115 SMOKESTACK WAY	SACRAMENTO	95833	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	339500	38.6024159999999981	-121.542964999999995
128	100 REBECCA WAY	FOLSOM	95630	CA	3	2	2185	Residential	Wed May 21 00:00:00 EDT 2008	344250	38.6847899999999996	-121.149198999999996
129	9488 OAK VILLAGE WAY	ELK GROVE	95758	CA	4	2	1801	Residential	Wed May 21 00:00:00 EDT 2008	346210	38.413330000000002	-121.404999000000004
130	8495 DARTFORD DR	SACRAMENTO	95823	CA	3	3	1961	Residential	Wed May 21 00:00:00 EDT 2008	347029	38.4485069999999993	-121.421346
131	6708 PONTA DO SOL WAY	ELK GROVE	95757	CA	4	2	3134	Residential	Wed May 21 00:00:00 EDT 2008	347650	38.3806349999999981	-121.425538000000003
132	4143 SEA MEADOW WAY	SACRAMENTO	95823	CA	4	3	1915	Residential	Wed May 21 00:00:00 EDT 2008	351300	38.4653399999999976	-121.457519000000005
133	3020 RICHARDSON CIR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Wed May 21 00:00:00 EDT 2008	352000	38.6912990000000008	-121.081751999999994
134	8082 LINDA ISLE LN	SACRAMENTO	95831	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	370000	38.4772000000000034	-121.521500000000003
135	15300 MURIETA SOUTH PKWY	RANCHO MURIETA	95683	CA	4	3	2734	Residential	Wed May 21 00:00:00 EDT 2008	370500	38.4874000000000009	-121.075129000000004
136	11215 SHARRMONT CT	WILTON	95693	CA	3	2	2110	Residential	Wed May 21 00:00:00 EDT 2008	372000	38.3506199999999993	-121.228348999999994
137	7105 DANBERG WAY	ELK GROVE	95757	CA	5	3	3164	Residential	Wed May 21 00:00:00 EDT 2008	375000	38.4018999999999977	-121.420388000000003
138	5579 JERRY LITELL WAY	SACRAMENTO	95835	CA	5	3	3599	Residential	Wed May 21 00:00:00 EDT 2008	381300	38.6771260000000012	-121.500518999999997
139	1050 FOXHALL WAY	SACRAMENTO	95831	CA	4	2	2054	Residential	Wed May 21 00:00:00 EDT 2008	381942	38.5098190000000002	-121.519660999999999
140	7837 ABBINGTON WAY	ANTELOPE	95843	CA	4	2	1830	Residential	Wed May 21 00:00:00 EDT 2008	387731	38.7098730000000018	-121.339472000000001
141	1300 F ST	SACRAMENTO	95814	CA	3	3	1627	Residential	Wed May 21 00:00:00 EDT 2008	391000	38.5835500000000025	-121.487289000000004
142	6801 RAWLEY WAY	ELK GROVE	95757	CA	4	3	3440	Residential	Wed May 21 00:00:00 EDT 2008	394470	38.4083510000000032	-121.423924999999997
143	1693 SHELTER COVE DR	GREENWOOD	95635	CA	3	2	2846	Residential	Wed May 21 00:00:00 EDT 2008	395000	38.9453570000000013	-120.908822000000001
144	9361 WADDELL LN	ELK GROVE	95624	CA	4	3	2359	Residential	Wed May 21 00:00:00 EDT 2008	400186	38.4508289999999988	-121.349928000000006
145	10 SEA FOAM CT	SACRAMENTO	95831	CA	3	3	2052	Residential	Wed May 21 00:00:00 EDT 2008	415000	38.4878849999999986	-121.545946999999998
146	6945 RIO TEJO WAY	ELK GROVE	95757	CA	5	3	3433	Residential	Wed May 21 00:00:00 EDT 2008	425000	38.3856380000000001	-121.422616000000005
147	4186 TULIP PARK WAY	RANCHO CORDOVA	95742	CA	5	3	3615	Residential	Wed May 21 00:00:00 EDT 2008	430000	38.5506170000000026	-121.235259999999997
148	9278 DAIRY CT	ELK GROVE	95624	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	445000	38.420338000000001	-121.363757000000007
149	207 ORANGE BLOSSOM CIR Unit C	FOLSOM	95630	CA	5	3	2687	Residential	Wed May 21 00:00:00 EDT 2008	460000	38.6462730000000008	-121.175321999999994
150	6507 RIO DE ONAR WAY	ELK GROVE	95757	CA	4	3	2724	Residential	Wed May 21 00:00:00 EDT 2008	461000	38.3825300000000027	-121.428006999999994
151	7004 RAWLEY WAY	ELK GROVE	95757	CA	4	3	3440	Residential	Wed May 21 00:00:00 EDT 2008	489332	38.4064210000000017	-121.422081000000006
152	6503 RIO DE ONAR WAY	ELK GROVE	95757	CA	5	4	3508	Residential	Wed May 21 00:00:00 EDT 2008	510000	38.3825300000000027	-121.428038000000001
153	2217 APPALOOSA CT	FOLSOM	95630	CA	4	2	2462	Residential	Wed May 21 00:00:00 EDT 2008	539000	38.6551669999999987	-121.090177999999995
154	868 HILDEBRAND CIR	FOLSOM	95630	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	585000	38.6709469999999982	-121.097727000000006
155	6030 PALERMO WAY	EL DORADO HILLS	95762	CA	4	3	0	Residential	Wed May 21 00:00:00 EDT 2008	600000	38.6727610000000013	-121.050377999999995
156	4070 REDONDO DR	EL DORADO HILLS	95762	CA	4	3	0	Residential	Wed May 21 00:00:00 EDT 2008	606238	38.6668069999999986	-121.064830000000001
157	4004 CRESTA WAY	SACRAMENTO	95864	CA	3	3	2325	Residential	Wed May 21 00:00:00 EDT 2008	660000	38.5916179999999969	-121.370626000000001
158	315 JUMEL CT	EL DORADO HILLS	95762	CA	6	5	0	Residential	Wed May 21 00:00:00 EDT 2008	830000	38.6699309999999983	-121.059579999999997
159	6272 LONGFORD DR Unit 1	CITRUS HEIGHTS	95621	CA	2	1	795	Condo	Tue May 20 00:00:00 EDT 2008	69000	38.6809229999999999	-121.313945000000004
160	3432 Y ST	SACRAMENTO	95817	CA	4	2	1099	Residential	Tue May 20 00:00:00 EDT 2008	70000	38.5549669999999978	-121.468046000000001
161	9512 EMERALD PARK DR Unit 3	ELK GROVE	95624	CA	2	1	840	Condo	Tue May 20 00:00:00 EDT 2008	71000	38.4057299999999984	-121.369832000000002
162	3132 CLAY ST	SACRAMENTO	95815	CA	2	1	800	Residential	Tue May 20 00:00:00 EDT 2008	78000	38.624678000000003	-121.439203000000006
163	5221 38TH AVE	SACRAMENTO	95824	CA	2	1	746	Residential	Tue May 20 00:00:00 EDT 2008	78400	38.5180440000000033	-121.443555000000003
164	6112 HERMOSA ST	SACRAMENTO	95822	CA	3	1	1067	Residential	Tue May 20 00:00:00 EDT 2008	80000	38.5151249999999976	-121.480416000000005
165	483 ARCADE BLVD	SACRAMENTO	95815	CA	4	2	1316	Residential	Tue May 20 00:00:00 EDT 2008	89000	38.6235709999999983	-121.454884000000007
166	671 SONOMA AVE	SACRAMENTO	95815	CA	3	1	1337	Residential	Tue May 20 00:00:00 EDT 2008	90000	38.6229530000000025	-121.450142
167	5980 79TH ST	SACRAMENTO	95824	CA	2	1	868	Residential	Tue May 20 00:00:00 EDT 2008	90000	38.5183729999999969	-121.411778999999996
168	7607 ELDER CREEK RD	SACRAMENTO	95824	CA	3	1	924	Residential	Tue May 20 00:00:00 EDT 2008	92000	38.5105500000000021	-121.414767999999995
169	5028 14TH AVE	SACRAMENTO	95820	CA	2	1	610	Residential	Tue May 20 00:00:00 EDT 2008	93675	38.5394199999999998	-121.446894
170	14788 NATCHEZ CT	RANCHO MURIETA	95683	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	97750	38.4922869999999975	-121.100031999999999
171	1069 ACACIA AVE	SACRAMENTO	95815	CA	2	1	1220	Residential	Tue May 20 00:00:00 EDT 2008	98000	38.6219979999999978	-121.442238000000003
172	5201 LAGUNA OAKS DR Unit 199	ELK GROVE	95758	CA	1	1	722	Condo	Tue May 20 00:00:00 EDT 2008	98000	38.4232510000000005	-121.444489000000004
173	3847 LAS PASAS WAY	SACRAMENTO	95864	CA	3	1	1643	Residential	Tue May 20 00:00:00 EDT 2008	99000	38.5886720000000025	-121.373915999999994
174	5201 LAGUNA OAKS DR Unit 172	ELK GROVE	95758	CA	1	1	722	Condo	Tue May 20 00:00:00 EDT 2008	100000	38.4232510000000005	-121.444489000000004
175	1121 CREEKSIDE WAY	GALT	95632	CA	3	1	1080	Residential	Tue May 20 00:00:00 EDT 2008	106716	38.2415140000000022	-121.312199000000007
176	5307 CABRILLO WAY	SACRAMENTO	95820	CA	3	1	1039	Residential	Tue May 20 00:00:00 EDT 2008	111000	38.5271199999999965	-121.435348000000005
177	3725 DON JULIO BLVD	NORTH HIGHLANDS	95660	CA	3	1	1051	Residential	Tue May 20 00:00:00 EDT 2008	111000	38.6789500000000004	-121.379406000000003
178	4803 MCCLOUD DR	SACRAMENTO	95842	CA	2	2	967	Residential	Tue May 20 00:00:00 EDT 2008	114800	38.6822790000000012	-121.352817000000002
179	10542 SILVERWOOD WAY	RANCHO CORDOVA	95670	CA	3	1	1098	Residential	Tue May 20 00:00:00 EDT 2008	120108	38.5871560000000002	-121.295777999999999
180	6318 39TH AVE	SACRAMENTO	95824	CA	3	1	1050	Residential	Tue May 20 00:00:00 EDT 2008	123225	38.5189420000000027	-121.430158000000006
181	211 MCDANIEL CIR	SACRAMENTO	95838	CA	3	2	1110	Residential	Tue May 20 00:00:00 EDT 2008	123750	38.6365649999999974	-121.460382999999993
182	3800 LYNHURST WAY	NORTH HIGHLANDS	95660	CA	3	1	888	Residential	Tue May 20 00:00:00 EDT 2008	125000	38.6504449999999977	-121.374860999999996
183	6139 HERMOSA ST	SACRAMENTO	95822	CA	3	2	1120	Residential	Tue May 20 00:00:00 EDT 2008	125000	38.5146650000000008	-121.480411000000004
184	2505 RHINE WAY	ELVERTA	95626	CA	3	2	1080	Residential	Tue May 20 00:00:00 EDT 2008	126000	38.7179760000000002	-121.407684000000003
185	3692 PAYNE WAY	NORTH HIGHLANDS	95660	CA	3	1	957	Residential	Tue May 20 00:00:00 EDT 2008	129000	38.6665399999999977	-121.378298000000001
186	604 MORRISON AVE	SACRAMENTO	95838	CA	2	1	952	Residential	Tue May 20 00:00:00 EDT 2008	134000	38.6376780000000011	-121.452476000000004
187	648 SANTA ANA AVE	SACRAMENTO	95838	CA	3	2	1211	Residential	Tue May 20 00:00:00 EDT 2008	135000	38.6584780000000023	-121.450408999999993
188	14 ASHLEY OAKS CT	SACRAMENTO	95815	CA	3	2	1264	Residential	Tue May 20 00:00:00 EDT 2008	135500	38.6177899999999994	-121.436764999999994
189	3174 NORTHVIEW DR	SACRAMENTO	95833	CA	3	1	1080	Residential	Tue May 20 00:00:00 EDT 2008	140000	38.6238170000000025	-121.477827000000005
190	840 TRANQUIL LN	GALT	95632	CA	3	2	1266	Residential	Tue May 20 00:00:00 EDT 2008	140000	38.2706170000000014	-121.299205000000001
191	5333 PRIMROSE DR Unit 19A	FAIR OAKS	95628	CA	2	2	994	Condo	Tue May 20 00:00:00 EDT 2008	142500	38.6627849999999995	-121.276272000000006
192	1035 MILLET WAY	SACRAMENTO	95834	CA	3	2	1202	Residential	Tue May 20 00:00:00 EDT 2008	143500	38.6310560000000009	-121.485079999999996
193	5201 LAGUNA OAKS DR Unit 126	ELK GROVE	95758	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	145000	38.4232510000000005	-121.444489000000004
194	3328 22ND AVE	SACRAMENTO	95820	CA	2	1	722	Residential	Tue May 20 00:00:00 EDT 2008	145000	38.5327270000000013	-121.470782999999997
195	8001 HARTWICK WAY	SACRAMENTO	95828	CA	4	2	1448	Residential	Tue May 20 00:00:00 EDT 2008	145000	38.4886229999999969	-121.410582000000005
196	7812 HARTWICK WAY	SACRAMENTO	95828	CA	3	2	1188	Residential	Tue May 20 00:00:00 EDT 2008	145000	38.4886109999999988	-121.412807999999998
197	4207 PAINTER WAY	NORTH HIGHLANDS	95660	CA	4	2	1183	Residential	Tue May 20 00:00:00 EDT 2008	146000	38.6929149999999993	-121.367497
198	7458 WINKLEY WAY	SACRAMENTO	95822	CA	3	1	1320	Residential	Tue May 20 00:00:00 EDT 2008	148500	38.4874440000000035	-121.491365999999999
199	8354 SUNRISE WOODS WAY	SACRAMENTO	95828	CA	3	2	1117	Residential	Tue May 20 00:00:00 EDT 2008	149000	38.4732879999999966	-121.396299999999997
200	8116 COTTONMILL CIR	SACRAMENTO	95828	CA	3	2	1364	Residential	Tue May 20 00:00:00 EDT 2008	150000	38.4828759999999974	-121.405912000000001
201	4660 CEDARWOOD WAY	SACRAMENTO	95823	CA	4	2	1310	Residential	Tue May 20 00:00:00 EDT 2008	150000	38.4848339999999993	-121.449315999999996
202	9254 HARROGATE WAY	ELK GROVE	95758	CA	2	2	1006	Residential	Tue May 20 00:00:00 EDT 2008	152000	38.4201380000000015	-121.412178999999995
203	6716 TAREYTON WAY	CITRUS HEIGHTS	95621	CA	3	2	1104	Residential	Tue May 20 00:00:00 EDT 2008	156000	38.6937240000000031	-121.307169000000002
204	2028 ROBERT WAY	SACRAMENTO	95825	CA	2	1	810	Residential	Tue May 20 00:00:00 EDT 2008	156000	38.6099820000000022	-121.419263000000001
205	9346 AIZENBERG CIR	ELK GROVE	95624	CA	2	2	1123	Residential	Tue May 20 00:00:00 EDT 2008	156000	38.4187500000000028	-121.370018999999999
206	4524 LOCH HAVEN WAY	SACRAMENTO	95842	CA	2	1	904	Residential	Tue May 20 00:00:00 EDT 2008	157788	38.6727300000000014	-121.359645
207	7140 BLUE SPRINGS WAY	CITRUS HEIGHTS	95621	CA	3	2	1156	Residential	Tue May 20 00:00:00 EDT 2008	161653	38.7206529999999987	-121.302240999999995
208	4631 11TH AVE	SACRAMENTO	95820	CA	2	1	1321	Residential	Tue May 20 00:00:00 EDT 2008	161829	38.5419649999999976	-121.452132000000006
209	3228 BAGGAN CT	ANTELOPE	95843	CA	3	2	1392	Residential	Tue May 20 00:00:00 EDT 2008	165000	38.7153459999999967	-121.388163000000006
210	8515 DARTFORD DR	SACRAMENTO	95823	CA	3	2	1439	Residential	Tue May 20 00:00:00 EDT 2008	168000	38.448287999999998	-121.420719000000005
211	4500 TIPPWOOD WAY	SACRAMENTO	95842	CA	3	2	1159	Residential	Tue May 20 00:00:00 EDT 2008	169000	38.6995099999999965	-121.359988999999999
212	2460 EL ROCCO WAY	RANCHO CORDOVA	95670	CA	3	2	1671	Residential	Tue May 20 00:00:00 EDT 2008	175000	38.5914769999999976	-121.315340000000006
213	8244 SUNBIRD WAY	SACRAMENTO	95823	CA	3	2	1740	Residential	Tue May 20 00:00:00 EDT 2008	176250	38.457653999999998	-121.431381000000002
214	5841 VALLEY VALE WAY	SACRAMENTO	95823	CA	3	2	1265	Residential	Tue May 20 00:00:00 EDT 2008	179000	38.4612830000000017	-121.434321999999995
215	7863 CRESTLEIGH CT	ANTELOPE	95843	CA	2	2	1007	Residential	Tue May 20 00:00:00 EDT 2008	180000	38.7108890000000017	-121.358875999999995
216	7129 SPRINGMONT DR	ELK GROVE	95758	CA	3	2	1716	Residential	Tue May 20 00:00:00 EDT 2008	180400	38.4176489999999973	-121.420293999999998
217	8284 RED FOX WAY	ELK GROVE	95758	CA	4	2	1685	Residential	Tue May 20 00:00:00 EDT 2008	182000	38.4171819999999968	-121.397231000000005
218	2219 EL CANTO CIR	RANCHO CORDOVA	95670	CA	4	2	1829	Residential	Tue May 20 00:00:00 EDT 2008	184500	38.5923829999999981	-121.318669
219	8907 GEMWOOD WAY	ELK GROVE	95758	CA	3	2	1555	Residential	Tue May 20 00:00:00 EDT 2008	185000	38.4354709999999997	-121.441173000000006
220	5925 MALEVILLE AVE	CARMICHAEL	95608	CA	4	2	1120	Residential	Tue May 20 00:00:00 EDT 2008	189000	38.666564000000001	-121.325716999999997
221	7031 CANEVALLEY CIR	CITRUS HEIGHTS	95621	CA	3	2	1137	Residential	Tue May 20 00:00:00 EDT 2008	194000	38.7186930000000018	-121.303618999999998
222	3949 WILDROSE WAY	SACRAMENTO	95826	CA	3	1	1174	Residential	Tue May 20 00:00:00 EDT 2008	195000	38.5436970000000017	-121.366682999999995
223	4437 MITCHUM CT	ANTELOPE	95843	CA	3	2	1393	Residential	Tue May 20 00:00:00 EDT 2008	200000	38.7044070000000033	-121.361130000000003
224	2778 KAWEAH CT	CAMERON PARK	95682	CA	3	1	0	Residential	Tue May 20 00:00:00 EDT 2008	201000	38.6940519999999992	-120.995588999999995
225	1636 ALLENWOOD CIR	LINCOLN	95648	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	202500	38.8791920000000033	-121.309477000000001
226	8151 QUAIL RIDGE CT	SACRAMENTO	95828	CA	3	2	1289	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.4612959999999973	-121.390857999999994
227	4899 WIND CREEK DR	SACRAMENTO	95838	CA	4	2	1799	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.6558869999999999	-121.446118999999996
228	2370 BIG CANYON CREEK RD	PLACERVILLE	95667	CA	3	2	0	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.7445799999999991	-120.794253999999995
229	6049 HAMBURG WAY	SACRAMENTO	95823	CA	4	3	1953	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.4432529999999986	-121.431991999999994
230	4232 71ST ST	SACRAMENTO	95820	CA	2	1	723	Residential	Tue May 20 00:00:00 EDT 2008	207000	38.5367409999999992	-121.421149999999997
231	3361 BOW MAR CT	CAMERON PARK	95682	CA	2	2	0	Residential	Tue May 20 00:00:00 EDT 2008	210000	38.6943699999999993	-120.996601999999996
232	1889 COLD SPRINGS RD	PLACERVILLE	95667	CA	2	1	948	Residential	Tue May 20 00:00:00 EDT 2008	211500	38.739773999999997	-120.860242999999997
233	5805 HIMALAYA WAY	CITRUS HEIGHTS	95621	CA	4	2	1578	Residential	Tue May 20 00:00:00 EDT 2008	215000	38.6964889999999997	-121.328554999999994
234	7944 SYLVAN OAK WAY	CITRUS HEIGHTS	95610	CA	3	2	1317	Residential	Tue May 20 00:00:00 EDT 2008	215000	38.7103880000000018	-121.261095999999995
235	3139 SPOONWOOD WAY Unit 1	SACRAMENTO	95833	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	215500	38.6265819999999991	-121.521510000000006
236	6217 LEOLA WAY	SACRAMENTO	95824	CA	3	1	1360	Residential	Tue May 20 00:00:00 EDT 2008	222381	38.513066000000002	-121.451909000000001
237	2340 HURLEY WAY	SACRAMENTO	95825	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	225000	38.5888160000000013	-121.408548999999994
238	3035 BRUNNET LN	SACRAMENTO	95833	CA	3	2	1522	Residential	Tue May 20 00:00:00 EDT 2008	225000	38.6247619999999969	-121.522774999999996
239	3025 EL PRADO WAY	SACRAMENTO	95825	CA	4	2	1751	Residential	Tue May 20 00:00:00 EDT 2008	225000	38.6066029999999998	-121.394147000000004
240	9387 GRANITE FALLS CT	ELK GROVE	95624	CA	3	2	1465	Residential	Tue May 20 00:00:00 EDT 2008	225000	38.4192139999999966	-121.348533000000003
241	9257 CALDERA WAY	SACRAMENTO	95826	CA	4	2	1605	Residential	Tue May 20 00:00:00 EDT 2008	228000	38.5582100000000025	-121.355022000000005
242	441 ARLINGDALE CIR	RIO LINDA	95673	CA	4	2	1475	Residential	Tue May 20 00:00:00 EDT 2008	229665	38.7028930000000031	-121.454948999999999
243	2284 LOS ROBLES RD	MEADOW VISTA	95722	CA	3	1	1216	Residential	Tue May 20 00:00:00 EDT 2008	230000	39.0081589999999991	-121.036230000000003
244	8164 CHENIN BLANC LN	FAIR OAKS	95628	CA	2	2	1315	Residential	Tue May 20 00:00:00 EDT 2008	230000	38.6656440000000003	-121.259968999999998
245	4620 CHAMBERLIN CIR	ELK GROVE	95757	CA	3	2	1567	Residential	Tue May 20 00:00:00 EDT 2008	230000	38.3905570000000012	-121.449804999999998
246	5340 BIRK WAY	SACRAMENTO	95835	CA	3	2	1776	Residential	Tue May 20 00:00:00 EDT 2008	234000	38.6724949999999978	-121.515251000000006
247	51 ANJOU CIR	SACRAMENTO	95835	CA	3	2	2187	Residential	Tue May 20 00:00:00 EDT 2008	235000	38.6616580000000027	-121.540633
248	2125 22ND AVE	SACRAMENTO	95822	CA	3	1	1291	Residential	Tue May 20 00:00:00 EDT 2008	236250	38.5345960000000005	-121.493121000000002
249	611 BLOSSOM ROCK LN	FOLSOM	95630	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	240000	38.6456999999999979	-121.119699999999995
250	8830 ADUR RD	ELK GROVE	95624	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	242000	38.437420000000003	-121.372876000000005
251	7344 BUTTERBALL WAY	SACRAMENTO	95842	CA	3	2	1503	Residential	Tue May 20 00:00:00 EDT 2008	245000	38.6994889999999998	-121.361828000000003
252	8219 GWINHURST CIR	SACRAMENTO	95828	CA	4	3	2491	Residential	Tue May 20 00:00:00 EDT 2008	245000	38.4597109999999986	-121.384282999999996
253	3240 S ST	SACRAMENTO	95816	CA	2	1	1269	Residential	Tue May 20 00:00:00 EDT 2008	245000	38.5622960000000035	-121.467489
254	221 PICASSO CIR	SACRAMENTO	95835	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.6766580000000033	-121.528127999999995
255	5706 GREENACRES WAY	ORANGEVALE	95662	CA	3	2	1176	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.6698820000000012	-121.213532999999998
256	6900 LONICERA DR	ORANGEVALE	95662	CA	4	2	1456	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.6921990000000022	-121.250974999999997
257	419 DAWNRIDGE RD	ROSEVILLE	95678	CA	3	2	1498	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.7252829999999975	-121.297953000000007
258	5312 MARBURY WAY	ANTELOPE	95843	CA	3	2	1574	Residential	Tue May 20 00:00:00 EDT 2008	255000	38.7102209999999971	-121.341650999999999
259	6344 BONHAM CIR	CITRUS HEIGHTS	95610	CA	5	4	2085	Multi-Family	Tue May 20 00:00:00 EDT 2008	256054	38.6823580000000007	-121.272875999999997
260	8207 YORKTON WAY	SACRAMENTO	95829	CA	3	2	2170	Residential	Tue May 20 00:00:00 EDT 2008	257729	38.4596700000000027	-121.360461000000001
261	7922 MANSELL WAY	ELK GROVE	95758	CA	4	2	1595	Residential	Tue May 20 00:00:00 EDT 2008	260000	38.4096339999999969	-121.410786999999999
262	5712 MELBURY CIR	ANTELOPE	95843	CA	3	2	1567	Residential	Tue May 20 00:00:00 EDT 2008	261000	38.7058490000000006	-121.334700999999995
263	632 NEWBRIDGE LN	LINCOLN	95648	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	261800	38.8790839999999989	-121.298586
264	1570 GLIDDEN AVE	SACRAMENTO	95822	CA	4	2	1253	Residential	Tue May 20 00:00:00 EDT 2008	264469	38.4827039999999982	-121.500433000000001
265	8108 FILIFERA WAY	ANTELOPE	95843	CA	4	3	1768	Residential	Tue May 20 00:00:00 EDT 2008	265000	38.7170419999999993	-121.354680000000002
266	230 BANKSIDE WAY	SACRAMENTO	95835	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6769370000000023	-121.529244000000006
267	5342 CALABRIA WAY	SACRAMENTO	95835	CA	4	3	2030	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6718070000000012	-121.498273999999995
268	47 NAPONEE CT	SACRAMENTO	95835	CA	3	2	1531	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6657039999999981	-121.529095999999996
269	4236 ADRIATIC SEA WAY	SACRAMENTO	95834	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6479610000000022	-121.543161999999995
270	8864 REMBRANT CT	ELK GROVE	95624	CA	4	3	1653	Residential	Tue May 20 00:00:00 EDT 2008	275000	38.4352879999999999	-121.375703000000001
271	9455 SEA CLIFF WAY	ELK GROVE	95758	CA	4	2	2056	Residential	Tue May 20 00:00:00 EDT 2008	275000	38.4115219999999979	-121.481406000000007
272	9720 LITTLE HARBOR WAY	ELK GROVE	95624	CA	4	3	2494	Residential	Tue May 20 00:00:00 EDT 2008	280000	38.4049339999999972	-121.352405000000005
273	8806 PHOENIX AVE	FAIR OAKS	95628	CA	3	2	1450	Residential	Tue May 20 00:00:00 EDT 2008	286013	38.6603220000000007	-121.230101000000005
274	3578 LOGGERHEAD WAY	SACRAMENTO	95834	CA	4	2	2169	Residential	Tue May 20 00:00:00 EDT 2008	292000	38.633028000000003	-121.526754999999994
275	1416 LOCKHART WAY	ROSEVILLE	95747	CA	3	2	1440	Residential	Tue May 20 00:00:00 EDT 2008	292000	38.7523989999999969	-121.330327999999994
276	5413 BUENA VENTURA WAY	FAIR OAKS	95628	CA	3	2	1527	Residential	Tue May 20 00:00:00 EDT 2008	293993	38.6645520000000005	-121.255937000000003
277	37 WHITE BIRCH CT	ROSEVILLE	95678	CA	3	2	1401	Residential	Tue May 20 00:00:00 EDT 2008	294000	38.776327000000002	-121.284514000000001
278	405 MARLIN SPIKE WAY	SACRAMENTO	95838	CA	3	2	1411	Residential	Tue May 20 00:00:00 EDT 2008	296769	38.657829999999997	-121.456841999999995
279	1102 CHESLEY LN	LINCOLN	95648	CA	4	4	0	Residential	Tue May 20 00:00:00 EDT 2008	297500	38.8648639999999972	-121.313987999999995
280	11281 STANFORD COURT LN Unit 604	GOLD RIVER	95670	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	300000	38.6252890000000022	-121.260285999999994
281	7320 6TH ST	RIO LINDA	95673	CA	3	1	1284	Residential	Tue May 20 00:00:00 EDT 2008	300000	38.7005529999999993	-121.452223000000004
282	993 MANTON CT	GALT	95632	CA	4	3	2307	Residential	Tue May 20 00:00:00 EDT 2008	300000	38.2729420000000005	-121.289147999999997
283	4487 PANORAMA DR	PLACERVILLE	95667	CA	3	2	1329	Residential	Tue May 20 00:00:00 EDT 2008	300000	38.6945589999999982	-120.848157
284	5651 OVERLEAF WAY	SACRAMENTO	95835	CA	4	2	1910	Residential	Tue May 20 00:00:00 EDT 2008	300500	38.6774539999999973	-121.494791000000006
285	2015 PROMONTORY POINT LN	GOLD RIVER	95670	CA	3	2	1981	Residential	Tue May 20 00:00:00 EDT 2008	305000	38.6287319999999994	-121.261149000000003
286	3224 PARKHAM DR	ROSEVILLE	95747	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	306500	38.7727709999999988	-121.364877000000007
287	15 VANESSA PL	SACRAMENTO	95835	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	312500	38.6686920000000001	-121.545490000000001
288	1312 RENISON LN	LINCOLN	95648	CA	5	3	0	Residential	Tue May 20 00:00:00 EDT 2008	315000	38.8664089999999973	-121.308485000000005
289	8 RIVER RAFT CT	SACRAMENTO	95823	CA	4	2	2205	Residential	Tue May 20 00:00:00 EDT 2008	319789	38.4473529999999997	-121.434968999999995
290	2251 LAMPLIGHT LN	LINCOLN	95648	CA	2	2	1449	Residential	Tue May 20 00:00:00 EDT 2008	330000	38.8499240000000015	-121.275728999999998
291	106 FARHAM DR	FOLSOM	95630	CA	3	2	1258	Residential	Tue May 20 00:00:00 EDT 2008	330000	38.6678339999999992	-121.168577999999997
292	5405 NECTAR CIR	ELK GROVE	95757	CA	3	2	2575	Residential	Tue May 20 00:00:00 EDT 2008	331000	38.3870140000000006	-121.440967000000001
293	5411 10TH AVE	SACRAMENTO	95820	CA	2	1	539	Residential	Tue May 20 00:00:00 EDT 2008	334000	38.5427269999999993	-121.442448999999996
294	3512 RAINSONG CIR	RANCHO CORDOVA	95670	CA	4	3	2208	Residential	Tue May 20 00:00:00 EDT 2008	336000	38.5734879999999976	-121.282809
295	1106 55TH ST	SACRAMENTO	95819	CA	3	1	1108	Residential	Tue May 20 00:00:00 EDT 2008	339000	38.5638050000000021	-121.436395000000005
296	411 ILLSLEY WAY	FOLSOM	95630	CA	4	2	1595	Residential	Tue May 20 00:00:00 EDT 2008	339000	38.6520020000000031	-121.129503999999997
297	796 BUTTERCUP CIR	GALT	95632	CA	4	2	2159	Residential	Tue May 20 00:00:00 EDT 2008	345000	38.2795810000000003	-121.300827999999996
298	1230 SANDRA CIR	PLACERVILLE	95667	CA	4	3	2295	Residential	Tue May 20 00:00:00 EDT 2008	350000	38.7381409999999988	-120.784144999999995
299	318 ANACAPA DR	ROSEVILLE	95678	CA	3	2	1838	Residential	Tue May 20 00:00:00 EDT 2008	356000	38.7820940000000007	-121.297133000000002
300	3975 SHINING STAR DR	SACRAMENTO	95823	CA	4	2	1900	Residential	Tue May 20 00:00:00 EDT 2008	361745	38.4874089999999995	-121.461412999999993
301	1620 BASLER ST	SACRAMENTO	95811	CA	4	2	1718	Residential	Tue May 20 00:00:00 EDT 2008	361948	38.5918220000000005	-121.478644000000003
302	9688 NATURE TRAIL WAY	ELK GROVE	95757	CA	5	3	3389	Residential	Tue May 20 00:00:00 EDT 2008	370000	38.4052239999999969	-121.479275000000001
303	5924 TANUS CIR	ROCKLIN	95677	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	380000	38.778691000000002	-121.204291999999995
304	9629 CEDAR OAK WAY	ELK GROVE	95757	CA	5	4	3260	Residential	Tue May 20 00:00:00 EDT 2008	385000	38.4055269999999993	-121.431746000000004
305	3429 FERNBROOK CT	CAMERON PARK	95682	CA	3	2	2016	Residential	Tue May 20 00:00:00 EDT 2008	399000	38.6642250000000018	-121.007172999999995
306	2121 HANNAH WAY	ROCKLIN	95765	CA	4	2	2607	Residential	Tue May 20 00:00:00 EDT 2008	402000	38.8057489999999987	-121.280930999999995
307	10104 ANNIE ST	ELK GROVE	95757	CA	4	3	2724	Residential	Tue May 20 00:00:00 EDT 2008	406026	38.390464999999999	-121.443478999999996
308	1092 MAUGHAM CT	GALT	95632	CA	5	4	3746	Residential	Tue May 20 00:00:00 EDT 2008	420000	38.2716459999999969	-121.286848000000006
309	5404 ALMOND FALLS WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	425000	38.5275019999999984	-121.233491999999998
310	6306 CONEJO	RANCHO MURIETA	95683	CA	4	2	3192	Residential	Tue May 20 00:00:00 EDT 2008	425000	38.5126020000000011	-121.087232999999998
311	14 CASA VATONI PL	SACRAMENTO	95834	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	433500	38.6502210000000019	-121.551704000000001
312	1456 EAGLESFIELD LN	LINCOLN	95648	CA	4	3	0	Residential	Tue May 20 00:00:00 EDT 2008	436746	38.8576350000000019	-121.311374999999998
313	4100 BOTHWELL CIR	EL DORADO HILLS	95762	CA	5	3	0	Residential	Tue May 20 00:00:00 EDT 2008	438700	38.6791359999999997	-121.034329
314	427 21ST ST	SACRAMENTO	95811	CA	2	1	1247	Residential	Tue May 20 00:00:00 EDT 2008	445000	38.5826040000000035	-121.475759999999994
315	1044 GALSTON DR	FOLSOM	95630	CA	4	2	2581	Residential	Tue May 20 00:00:00 EDT 2008	450000	38.6763059999999967	-121.099540000000005
316	4440 SYCAMORE AVE	SACRAMENTO	95841	CA	3	1	2068	Residential	Tue May 20 00:00:00 EDT 2008	460000	38.6463740000000016	-121.353657999999996
317	1032 SOUZA DR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Tue May 20 00:00:00 EDT 2008	460000	38.6682389999999998	-121.064436999999998
318	9760 LAZULITE CT	ELK GROVE	95624	CA	4	3	3992	Residential	Tue May 20 00:00:00 EDT 2008	460000	38.403609000000003	-121.335541000000006
319	241 LANFRANCO CIR	SACRAMENTO	95835	CA	4	4	3397	Residential	Tue May 20 00:00:00 EDT 2008	465000	38.665695999999997	-121.549436999999998
320	5559 NORTHBOROUGH DR	SACRAMENTO	95835	CA	5	3	3881	Residential	Tue May 20 00:00:00 EDT 2008	471750	38.677225	-121.519687000000005
321	2125 BIG SKY DR	ROCKLIN	95765	CA	5	3	0	Residential	Tue May 20 00:00:00 EDT 2008	480000	38.8016369999999995	-121.278797999999995
322	2109 HAMLET PL	CARMICHAEL	95608	CA	2	2	1598	Residential	Tue May 20 00:00:00 EDT 2008	484000	38.6027539999999973	-121.329325999999995
323	9970 STATE HIGHWAY 193	PLACERVILLE	95667	CA	4	3	1929	Residential	Tue May 20 00:00:00 EDT 2008	485000	38.7878770000000017	-120.816676000000001
324	2901 PINTAIL WAY	ELK GROVE	95757	CA	4	3	3070	Residential	Tue May 20 00:00:00 EDT 2008	495000	38.3984880000000004	-121.473423999999994
325	201 FIRESTONE DR	ROSEVILLE	95678	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	500500	38.7701530000000005	-121.300038999999998
326	1740 HIGH ST	AUBURN	95603	CA	3	3	0	Residential	Tue May 20 00:00:00 EDT 2008	504000	38.8919349999999966	-121.084339999999997
327	2733 DANA LOOP	EL DORADO HILLS	95762	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	541000	38.6284589999999994	-121.055077999999995
328	9741 SADDLEBRED CT	WILTON	95693	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	560000	38.4088410000000025	-121.198038999999994
329	7756 TIGERWOODS DR	SACRAMENTO	95829	CA	5	3	3984	Residential	Tue May 20 00:00:00 EDT 2008	572500	38.4764300000000006	-121.309242999999995
330	5709 RIVER OAK WAY	CARMICHAEL	95608	CA	4	2	2222	Residential	Tue May 20 00:00:00 EDT 2008	582000	38.6024609999999981	-121.330978999999999
331	2981 WRINGER DR	ROSEVILLE	95661	CA	4	3	3838	Residential	Tue May 20 00:00:00 EDT 2008	613401	38.7353730000000027	-121.227072000000007
332	8616 ROCKPORTE CT	ROSEVILLE	95747	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	614000	38.7421179999999978	-121.359909000000002
333	4128 HILL ST	FAIR OAKS	95628	CA	5	5	2846	Residential	Tue May 20 00:00:00 EDT 2008	680000	38.6416699999999977	-121.262099000000006
334	1409 47TH ST	SACRAMENTO	95819	CA	5	2	2484	Residential	Tue May 20 00:00:00 EDT 2008	699000	38.5632439999999974	-121.446876000000003
335	3935 EL MONTE DR	LOOMIS	95650	CA	4	4	1624	Residential	Tue May 20 00:00:00 EDT 2008	839000	38.8133369999999971	-121.133347999999998
336	5840 WALERGA RD	SACRAMENTO	95842	CA	2	1	840	Condo	Mon May 19 00:00:00 EDT 2008	40000	38.6736780000000024	-121.357471000000004
337	923 FULTON AVE	SACRAMENTO	95825	CA	1	1	484	Condo	Mon May 19 00:00:00 EDT 2008	48000	38.5822789999999998	-121.401482000000001
338	261 REDONDO AVE	SACRAMENTO	95815	CA	3	1	970	Residential	Mon May 19 00:00:00 EDT 2008	61500	38.6206850000000017	-121.460538999999997
339	4030 BROADWAY	SACRAMENTO	95817	CA	2	1	623	Residential	Mon May 19 00:00:00 EDT 2008	62050	38.5467980000000026	-121.460037999999997
340	3660 22ND AVE	SACRAMENTO	95820	CA	2	1	932	Residential	Mon May 19 00:00:00 EDT 2008	65000	38.5327180000000027	-121.467470000000006
341	3924 HIGH ST	SACRAMENTO	95838	CA	2	1	796	Residential	Mon May 19 00:00:00 EDT 2008	65000	38.6387969999999967	-121.435049000000006
342	4734 14TH AVE	SACRAMENTO	95820	CA	2	1	834	Residential	Mon May 19 00:00:00 EDT 2008	68000	38.5394470000000027	-121.450857999999997
343	4734 14TH AVE	SACRAMENTO	95820	CA	2	1	834	Residential	Mon May 19 00:00:00 EDT 2008	68000	38.5394470000000027	-121.450857999999997
344	5050 RHODE ISLAND DR Unit 4	SACRAMENTO	95841	CA	2	1	924	Condo	Mon May 19 00:00:00 EDT 2008	77000	38.6587389999999971	-121.333561000000003
345	4513 GREENHOLME DR	SACRAMENTO	95842	CA	2	1	795	Condo	Mon May 19 00:00:00 EDT 2008	82732	38.6691039999999973	-121.359008000000003
346	3845 ELM ST	SACRAMENTO	95838	CA	3	1	1250	Residential	Mon May 19 00:00:00 EDT 2008	84000	38.6373370000000023	-121.432834999999997
347	3908 17TH AVE	SACRAMENTO	95820	CA	2	1	984	Residential	Mon May 19 00:00:00 EDT 2008	84675	38.5372800000000026	-121.463531000000003
348	7109 CHANDLER DR	SACRAMENTO	95828	CA	3	1	1013	Residential	Mon May 19 00:00:00 EDT 2008	85000	38.4972369999999984	-121.424187000000003
349	7541 SKELTON WAY	SACRAMENTO	95822	CA	3	1	1012	Residential	Mon May 19 00:00:00 EDT 2008	90000	38.4842739999999992	-121.488850999999997
350	9058 MONTOYA ST	SACRAMENTO	95826	CA	2	1	795	Condo	Mon May 19 00:00:00 EDT 2008	90000	38.5591440000000034	-121.368386999999998
351	1016 CONGRESS AVE	SACRAMENTO	95838	CA	2	2	918	Residential	Mon May 19 00:00:00 EDT 2008	91000	38.6301509999999979	-121.442789000000005
352	540 MORRISON AVE	SACRAMENTO	95838	CA	3	1	1082	Residential	Mon May 19 00:00:00 EDT 2008	95000	38.6377039999999994	-121.453946000000002
353	5303 JERRETT WAY	SACRAMENTO	95842	CA	2	1	964	Residential	Mon May 19 00:00:00 EDT 2008	97500	38.6632820000000024	-121.359630999999993
354	2820 DEL PASO BLVD	SACRAMENTO	95815	CA	4	2	1404	Multi-Family	Mon May 19 00:00:00 EDT 2008	100000	38.6177180000000035	-121.440089
355	3715 TALLYHO DR Unit 78HIGH	SACRAMENTO	95826	CA	1	1	625	Condo	Mon May 19 00:00:00 EDT 2008	100000	38.5446269999999984	-121.357960000000006
356	6013 ROWAN WAY	CITRUS HEIGHTS	95621	CA	2	1	888	Residential	Mon May 19 00:00:00 EDT 2008	101000	38.6758930000000021	-121.296300000000002
357	2987 PONDEROSA LN	SACRAMENTO	95815	CA	4	2	1120	Residential	Mon May 19 00:00:00 EDT 2008	102750	38.6222429999999974	-121.457863000000003
358	3732 LANKERSHIM WAY	NORTH HIGHLANDS	95660	CA	3	1	1331	Residential	Mon May 19 00:00:00 EDT 2008	112500	38.6897200000000012	-121.378399000000002
359	2216 DUNLAP DR	SACRAMENTO	95821	CA	3	1	1014	Residential	Mon May 19 00:00:00 EDT 2008	113000	38.623738000000003	-121.413049999999998
360	3503 21ST AVE	SACRAMENTO	95820	CA	4	2	1448	Residential	Mon May 19 00:00:00 EDT 2008	114000	38.533610000000003	-121.469307999999998
361	523 EXCHANGE ST	SACRAMENTO	95838	CA	3	1	966	Residential	Mon May 19 00:00:00 EDT 2008	114000	38.6594139999999982	-121.454080000000005
362	8101 PORT ROYALE WAY	SACRAMENTO	95823	CA	2	1	779	Residential	Mon May 19 00:00:00 EDT 2008	114750	38.4639290000000003	-121.438666999999995
363	8020 WALERGA RD	ANTELOPE	95843	CA	2	2	836	Condo	Mon May 19 00:00:00 EDT 2008	115000	38.716070000000002	-121.364468000000002
364	167 VALLEY OAK DR	ROSEVILLE	95678	CA	2	2	1100	Condo	Mon May 19 00:00:00 EDT 2008	115000	38.7324290000000033	-121.288068999999993
365	7876 BURLINGTON WAY	SACRAMENTO	95832	CA	3	1	1174	Residential	Mon May 19 00:00:00 EDT 2008	116100	38.4700929999999985	-121.468346999999994
366	3726 JONKO AVE	NORTH HIGHLANDS	95660	CA	3	2	1207	Residential	Mon May 19 00:00:00 EDT 2008	119250	38.656131000000002	-121.377264999999994
367	7342 GIGI PL	SACRAMENTO	95828	CA	4	4	1995	Multi-Family	Mon May 19 00:00:00 EDT 2008	120000	38.4907040000000009	-121.410176000000007
368	2610 PHYLLIS AVE	SACRAMENTO	95820	CA	2	1	804	Residential	Mon May 19 00:00:00 EDT 2008	120000	38.5310500000000005	-121.479574
369	4200 COMMERCE WAY Unit 711	SACRAMENTO	95834	CA	2	2	958	Condo	Mon May 19 00:00:00 EDT 2008	120000	38.6475229999999996	-121.523217000000002
370	4621 COUNTRY SCENE WAY	SACRAMENTO	95823	CA	3	2	1366	Residential	Mon May 19 00:00:00 EDT 2008	120108	38.4701870000000028	-121.448149000000001
371	5380 VILLAGE WOOD DR	SACRAMENTO	95823	CA	2	2	901	Residential	Mon May 19 00:00:00 EDT 2008	121500	38.4549489999999992	-121.440578000000002
372	2621 EVERGREEN ST	SACRAMENTO	95815	CA	3	1	696	Residential	Mon May 19 00:00:00 EDT 2008	121725	38.6131030000000024	-121.444085000000001
373	201 CARLO CT	GALT	95632	CA	3	2	1080	Residential	Mon May 19 00:00:00 EDT 2008	122000	38.2422699999999978	-121.310320000000004
374	6743 21ST ST	SACRAMENTO	95822	CA	3	2	1104	Residential	Mon May 19 00:00:00 EDT 2008	123000	38.5037200000000013	-121.490656999999999
375	3128 VIA GRANDE	SACRAMENTO	95825	CA	2	1	972	Residential	Mon May 19 00:00:00 EDT 2008	125000	38.5983209999999985	-121.39161
376	2847 BELGRADE WAY	SACRAMENTO	95833	CA	4	2	1390	Residential	Mon May 19 00:00:00 EDT 2008	125573	38.6171730000000011	-121.482540999999998
377	7741 MILLDALE CIR	ELVERTA	95626	CA	4	2	1354	Residential	Mon May 19 00:00:00 EDT 2008	126714	38.705834000000003	-121.439189999999996
378	9013 CASALS ST	SACRAMENTO	95826	CA	2	1	795	Condo	Mon May 19 00:00:00 EDT 2008	126960	38.5570450000000022	-121.371669999999995
379	227 MAHAN CT Unit 1	ROSEVILLE	95678	CA	2	1	780	Condo	Mon May 19 00:00:00 EDT 2008	127000	38.749723000000003	-121.270079999999993
380	7349 FLETCHER FARM DR	SACRAMENTO	95828	CA	4	2	1587	Residential	Mon May 19 00:00:00 EDT 2008	127500	38.4906900000000007	-121.382619000000005
381	7226 LARCHMONT DR	NORTH HIGHLANDS	95660	CA	3	2	1209	Residential	Mon May 19 00:00:00 EDT 2008	130000	38.699269000000001	-121.376334
382	4114 35TH AVE	SACRAMENTO	95824	CA	2	1	1139	Residential	Mon May 19 00:00:00 EDT 2008	133105	38.5209410000000005	-121.459355000000002
383	617 M ST	RIO LINDA	95673	CA	2	2	1690	Residential	Mon May 19 00:00:00 EDT 2008	136500	38.6911040000000028	-121.451831999999996
384	7032 FAIR OAKS BLVD	CARMICHAEL	95608	CA	3	2	1245	Condo	Mon May 19 00:00:00 EDT 2008	139500	38.6285629999999998	-121.328297000000006
385	2421 SANTINA WAY	ELVERTA	95626	CA	3	2	1416	Residential	Mon May 19 00:00:00 EDT 2008	140000	38.7186499999999967	-121.407763000000003
386	2368 CRAIG AVE	SACRAMENTO	95832	CA	3	2	1300	Residential	Mon May 19 00:00:00 EDT 2008	140800	38.4780700000000024	-121.481139999999996
387	2123 AMANDA WAY	SACRAMENTO	95822	CA	3	2	1120	Residential	Mon May 19 00:00:00 EDT 2008	145000	38.4848959999999991	-121.486947999999998
388	7620 DARLA WAY	SACRAMENTO	95828	CA	4	2	1590	Residential	Mon May 19 00:00:00 EDT 2008	147000	38.4785019999999989	-121.403516999999994
389	8344 FIELDPOPPY CIR	SACRAMENTO	95828	CA	3	2	1407	Residential	Mon May 19 00:00:00 EDT 2008	149600	38.4790830000000028	-121.400701999999995
390	3624 20TH AVE	SACRAMENTO	95820	CA	5	2	1516	Residential	Mon May 19 00:00:00 EDT 2008	150000	38.5345080000000024	-121.467906999999997
391	10001 WOODCREEK OAKS BLVD Unit 1415	ROSEVILLE	95747	CA	2	2	0	Condo	Mon May 19 00:00:00 EDT 2008	150000	38.7955290000000019	-121.328818999999996
392	2848 PROVO WAY	SACRAMENTO	95822	CA	3	2	1646	Residential	Mon May 19 00:00:00 EDT 2008	150000	38.4897589999999994	-121.474754000000004
393	6045 EHRHARDT AVE	SACRAMENTO	95823	CA	3	2	1676	Residential	Mon May 19 00:00:00 EDT 2008	155000	38.4571570000000023	-121.433064999999999
394	1223 LAMBERTON CIR	SACRAMENTO	95838	CA	3	2	1370	Residential	Mon May 19 00:00:00 EDT 2008	155435	38.6466769999999968	-121.437573
395	1223 LAMBERTON CIR	SACRAMENTO	95838	CA	3	2	1370	Residential	Mon May 19 00:00:00 EDT 2008	155500	38.6466769999999968	-121.437573
396	6000 BIRCHGLADE WAY	CITRUS HEIGHTS	95621	CA	4	2	1351	Residential	Mon May 19 00:00:00 EDT 2008	158000	38.7016599999999968	-121.323249000000004
397	7204 THOMAS DR	NORTH HIGHLANDS	95660	CA	3	2	1152	Residential	Mon May 19 00:00:00 EDT 2008	158000	38.6978980000000021	-121.377686999999995
398	8363 LANGTREE WAY	SACRAMENTO	95823	CA	3	2	1452	Residential	Mon May 19 00:00:00 EDT 2008	160000	38.4535600000000031	-121.435958999999997
399	1675 VERNON ST Unit 8	ROSEVILLE	95678	CA	2	1	990	Residential	Mon May 19 00:00:00 EDT 2008	160000	38.7341359999999995	-121.299638999999999
400	6632 IBEX WOODS CT	CITRUS HEIGHTS	95621	CA	2	2	1162	Residential	Mon May 19 00:00:00 EDT 2008	164000	38.720868000000003	-121.309854999999999
401	117 EVCAR WAY	RIO LINDA	95673	CA	3	2	1182	Residential	Mon May 19 00:00:00 EDT 2008	164000	38.6876589999999965	-121.463300000000004
402	6485 LAGUNA MIRAGE LN	ELK GROVE	95758	CA	2	2	1112	Residential	Mon May 19 00:00:00 EDT 2008	165000	38.4246499999999997	-121.430137000000002
403	746 MOOSE CREEK WAY	GALT	95632	CA	3	2	1100	Residential	Mon May 19 00:00:00 EDT 2008	167000	38.2830849999999998	-121.302070999999998
404	8306 CURLEW CT	CITRUS HEIGHTS	95621	CA	4	2	1280	Residential	Mon May 19 00:00:00 EDT 2008	167293	38.7157809999999998	-121.298518999999999
405	8306 CURLEW CT	CITRUS HEIGHTS	95621	CA	4	2	1280	Residential	Mon May 19 00:00:00 EDT 2008	167293	38.7157809999999998	-121.298518999999999
406	5217 ARGO WAY	SACRAMENTO	95820	CA	3	1	1039	Residential	Mon May 19 00:00:00 EDT 2008	168000	38.5277400000000014	-121.433668999999995
407	7108 HEATHER TREE DR	SACRAMENTO	95842	CA	3	2	1159	Residential	Mon May 19 00:00:00 EDT 2008	170000	38.6956770000000034	-121.360219999999998
408	2956 DAVENPORT WAY	SACRAMENTO	95833	CA	4	2	1917	Residential	Mon May 19 00:00:00 EDT 2008	170000	38.6206869999999967	-121.482619
409	10062 LINCOLN VILLAGE DR	SACRAMENTO	95827	CA	3	2	1520	Residential	Mon May 19 00:00:00 EDT 2008	170000	38.5640000000000001	-121.320023000000006
410	332 PALIN AVE	GALT	95632	CA	3	2	1204	Residential	Mon May 19 00:00:00 EDT 2008	174000	38.2604669999999984	-121.302636000000007
411	4649 FREEWAY CIR	SACRAMENTO	95841	CA	3	2	1120	Residential	Mon May 19 00:00:00 EDT 2008	178000	38.6587340000000026	-121.357196000000002
412	8593 DERLIN WAY	SACRAMENTO	95823	CA	3	2	1436	Residential	Mon May 19 00:00:00 EDT 2008	180000	38.4475849999999966	-121.426626999999996
413	9273 PREMIER WAY	SACRAMENTO	95826	CA	3	2	1451	Residential	Mon May 19 00:00:00 EDT 2008	180000	38.5599199999999982	-121.352538999999993
414	8032 DUSENBERG CT	SACRAMENTO	95828	CA	4	2	1638	Residential	Mon May 19 00:00:00 EDT 2008	180000	38.4664989999999989	-121.381118999999998
415	7110 STELLA LN Unit 15	CARMICHAEL	95608	CA	2	2	1000	Condo	Mon May 19 00:00:00 EDT 2008	182000	38.6373960000000025	-121.300055
416	1786 PIEDMONT WAY	ROSEVILLE	95661	CA	3	1	1152	Residential	Mon May 19 00:00:00 EDT 2008	188325	38.7274799999999999	-121.256536999999994
417	1347 HIDALGO CIR	ROSEVILLE	95747	CA	3	2	1154	Residential	Mon May 19 00:00:00 EDT 2008	191500	38.747878	-121.311278999999999
418	212 CAPPUCINO WAY	SACRAMENTO	95838	CA	3	2	1353	Residential	Mon May 19 00:00:00 EDT 2008	192000	38.6578110000000024	-121.465327000000002
419	5938 WOODBRIAR WAY	CITRUS HEIGHTS	95621	CA	3	2	1329	Residential	Mon May 19 00:00:00 EDT 2008	192700	38.706152000000003	-121.325399000000004
420	3801 WILDROSE WAY	SACRAMENTO	95826	CA	3	1	1356	Residential	Mon May 19 00:00:00 EDT 2008	195000	38.5443679999999986	-121.369979000000001
421	508 SAMUEL WAY	SACRAMENTO	95838	CA	3	2	1505	Residential	Mon May 19 00:00:00 EDT 2008	197654	38.6456889999999973	-121.452765999999997
422	6128 CARL SANDBURG CIR	SACRAMENTO	95842	CA	3	1	1009	Residential	Mon May 19 00:00:00 EDT 2008	198000	38.6815410000000028	-121.355615999999998
423	1 KENNELFORD CIR	SACRAMENTO	95823	CA	3	2	1144	Residential	Mon May 19 00:00:00 EDT 2008	200345	38.4645200000000003	-121.427605999999997
424	909 SINGINGWOOD RD	SACRAMENTO	95864	CA	2	1	930	Residential	Mon May 19 00:00:00 EDT 2008	203000	38.5814710000000005	-121.388390000000001
425	6671 FOXWOOD CT	SACRAMENTO	95841	CA	4	2	1766	Residential	Mon May 19 00:00:00 EDT 2008	207000	38.6879429999999971	-121.328883000000005
426	8165 AYN RAND CT	SACRAMENTO	95828	CA	4	3	1940	Residential	Mon May 19 00:00:00 EDT 2008	208000	38.4686390000000031	-121.403265000000005
427	9474 VILLAGE TREE DR	ELK GROVE	95758	CA	4	2	1776	Residential	Mon May 19 00:00:00 EDT 2008	210000	38.4139470000000003	-121.408276000000001
428	7213 CALVIN DR	CITRUS HEIGHTS	95621	CA	3	1	1258	Residential	Mon May 19 00:00:00 EDT 2008	212000	38.6981540000000024	-121.298374999999993
429	8167 DERBY PARK CT	SACRAMENTO	95828	CA	4	2	1872	Residential	Mon May 19 00:00:00 EDT 2008	213675	38.4604920000000021	-121.373379
430	6344 LAGUNA MIRAGE LN	ELK GROVE	95758	CA	2	2	1112	Residential	Mon May 19 00:00:00 EDT 2008	213697	38.4239630000000005	-121.428875000000005
431	2945 RED HAWK WAY	SACRAMENTO	95833	CA	4	2	1856	Residential	Mon May 19 00:00:00 EDT 2008	215000	38.6196750000000009	-121.496903000000003
432	3228 I ST	SACRAMENTO	95816	CA	4	3	1939	Residential	Mon May 19 00:00:00 EDT 2008	215000	38.5738440000000011	-121.462839000000002
433	308 ATKINSON ST	ROSEVILLE	95678	CA	3	1	998	Residential	Mon May 19 00:00:00 EDT 2008	215100	38.7467940000000013	-121.299710000000005
434	624 HOVEY WAY	ROSEVILLE	95678	CA	3	2	1758	Residential	Mon May 19 00:00:00 EDT 2008	217500	38.7561490000000006	-121.306478999999996
435	110 COPPER LEAF WAY	SACRAMENTO	95838	CA	3	2	2142	Residential	Mon May 19 00:00:00 EDT 2008	218000	38.6584659999999971	-121.460661000000002
436	7535 ALMA VISTA WAY	SACRAMENTO	95831	CA	2	1	950	Residential	Mon May 19 00:00:00 EDT 2008	220000	38.4840299999999971	-121.507641000000007
437	7423 WILSALL CT	ELK GROVE	95758	CA	4	3	1739	Residential	Mon May 19 00:00:00 EDT 2008	221000	38.4170259999999999	-121.416820999999999
438	8629 VIA ALTA WAY	ELK GROVE	95624	CA	3	2	1516	Residential	Mon May 19 00:00:00 EDT 2008	222900	38.3982450000000028	-121.380615000000006
439	3318 DAVIDSON DR	ANTELOPE	95843	CA	3	1	988	Residential	Mon May 19 00:00:00 EDT 2008	223139	38.7057530000000014	-121.388917000000006
440	913 COBDEN CT	GALT	95632	CA	4	2	1555	Residential	Mon May 19 00:00:00 EDT 2008	225500	38.2820010000000011	-121.295901999999998
441	4419 79TH ST	SACRAMENTO	95820	CA	3	2	1212	Residential	Mon May 19 00:00:00 EDT 2008	228327	38.5348269999999999	-121.412544999999994
442	3012 SPOONWOOD WAY	SACRAMENTO	95833	CA	4	2	1871	Residential	Mon May 19 00:00:00 EDT 2008	230000	38.6247800000000012	-121.523473999999993
443	8728 CRYSTAL RIVER WAY	SACRAMENTO	95828	CA	3	2	1302	Residential	Mon May 19 00:00:00 EDT 2008	230000	38.4754700000000014	-121.380054999999999
444	4709 AMBER LN Unit 1	SACRAMENTO	95841	CA	2	1	756	Condo	Mon May 19 00:00:00 EDT 2008	230522	38.6577890000000011	-121.354994000000005
445	4508 OLD DAIRY DR	ANTELOPE	95843	CA	4	3	2026	Residential	Mon May 19 00:00:00 EDT 2008	231200	38.7228599999999972	-121.358939000000007
446	312 RIVER ISLE WAY	SACRAMENTO	95831	CA	3	2	1375	Residential	Mon May 19 00:00:00 EDT 2008	232000	38.4902599999999993	-121.550527000000002
447	301 OLIVADI WAY	SACRAMENTO	95834	CA	2	2	1250	Condo	Mon May 19 00:00:00 EDT 2008	232500	38.6444059999999965	-121.549048999999997
448	5636 25TH ST	SACRAMENTO	95822	CA	3	1	1058	Residential	Mon May 19 00:00:00 EDT 2008	233641	38.5238280000000017	-121.481138999999999
449	8721 SPRUCE RIDGE WAY	ANTELOPE	95843	CA	3	2	1187	Residential	Mon May 19 00:00:00 EDT 2008	234000	38.7276570000000007	-121.391028000000006
450	7461 WINDBRIDGE DR	SACRAMENTO	95831	CA	2	2	1324	Residential	Mon May 19 00:00:00 EDT 2008	234500	38.4879699999999971	-121.530229000000006
451	8101 LEMON COVE CT	SACRAMENTO	95828	CA	4	3	1936	Residential	Mon May 19 00:00:00 EDT 2008	235000	38.4629809999999992	-121.408287999999999
452	10949 SCOTSMAN WAY	RANCHO CORDOVA	95670	CA	5	4	2382	Multi-Family	Mon May 19 00:00:00 EDT 2008	236000	38.6036860000000033	-121.277844000000002
453	617 WILLOW CREEK DR	FOLSOM	95630	CA	3	2	1427	Residential	Mon May 19 00:00:00 EDT 2008	236073	38.679625999999999	-121.142608999999993
454	3301 PARK DR Unit 1914	SACRAMENTO	95835	CA	3	2	1678	Condo	Mon May 19 00:00:00 EDT 2008	238000	38.6652959999999979	-121.531993
455	709 CIMMARON CT	GALT	95632	CA	4	2	1798	Residential	Mon May 19 00:00:00 EDT 2008	238861	38.2771770000000018	-121.303747000000001
456	3305 RIO ROCA CT	ANTELOPE	95843	CA	4	3	2652	Residential	Mon May 19 00:00:00 EDT 2008	239700	38.7250790000000009	-121.387698
457	9080 BEDROCK CT	SACRAMENTO	95829	CA	4	2	1816	Residential	Mon May 19 00:00:00 EDT 2008	240000	38.4569389999999984	-121.362965000000003
458	100 TOURMALINE CIR	SACRAMENTO	95834	CA	5	3	3076	Residential	Mon May 19 00:00:00 EDT 2008	240000	38.634369999999997	-121.510778999999999
459	6411 RED BIRCH WAY	ELK GROVE	95758	CA	4	2	1844	Residential	Mon May 19 00:00:00 EDT 2008	241000	38.4346099999999993	-121.429316
460	4867 LAGUNA DR	SACRAMENTO	95823	CA	3	2	1306	Residential	Mon May 19 00:00:00 EDT 2008	245000	38.4617900000000006	-121.445370999999994
461	3662 RIVER DR	SACRAMENTO	95833	CA	4	3	2447	Residential	Mon May 19 00:00:00 EDT 2008	246000	38.604968999999997	-121.542550000000006
462	6943 WOLFGRAM WAY	SACRAMENTO	95828	CA	4	2	1176	Residential	Mon May 19 00:00:00 EDT 2008	247234	38.4892150000000015	-121.419545999999997
463	77 RINETTI WAY	RIO LINDA	95673	CA	4	2	1182	Residential	Mon May 19 00:00:00 EDT 2008	247480	38.6870210000000014	-121.463150999999996
464	1316 I ST	RIO LINDA	95673	CA	3	1	1160	Residential	Mon May 19 00:00:00 EDT 2008	249862	38.6836740000000034	-121.435203999999999
465	2130 CATHERWOOD WAY	SACRAMENTO	95835	CA	3	2	1424	Residential	Mon May 19 00:00:00 EDT 2008	251000	38.6755059999999986	-121.510987
466	8304 JUGLANS DR	ORANGEVALE	95662	CA	4	2	1574	Residential	Mon May 19 00:00:00 EDT 2008	252155	38.6918289999999985	-121.249032999999997
467	5308 MARBURY WAY	ANTELOPE	95843	CA	3	2	1830	Residential	Mon May 19 00:00:00 EDT 2008	254172	38.7102209999999971	-121.341707
468	9182 LAKEMONT DR	ELK GROVE	95624	CA	4	2	1724	Residential	Mon May 19 00:00:00 EDT 2008	258000	38.4513529999999975	-121.358776000000006
469	2231 COUNTRY VILLA CT	AUBURN	95603	CA	2	2	1255	Condo	Mon May 19 00:00:00 EDT 2008	260000	38.9316710000000015	-121.097862000000006
470	8491 CRYSTAL WALK CIR	ELK GROVE	95758	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	261000	38.4169160000000005	-121.407554000000005
471	361 MAHONIA CIR	SACRAMENTO	95835	CA	4	3	2175	Residential	Mon May 19 00:00:00 EDT 2008	261000	38.6761720000000011	-121.509760999999997
472	3427 LA CADENA WAY	SACRAMENTO	95835	CA	4	2	1904	Residential	Mon May 19 00:00:00 EDT 2008	261000	38.6811939999999979	-121.537351000000001
473	955 BIG SUR CT	EL DORADO HILLS	95762	CA	4	2	1808	Residential	Mon May 19 00:00:00 EDT 2008	262500	38.6643469999999994	-121.076528999999994
474	11826 DIONYSUS WAY	RANCHO CORDOVA	95742	CA	4	2	2711	Residential	Mon May 19 00:00:00 EDT 2008	266000	38.5510459999999995	-121.239411000000004
475	5847 DEL CAMPO LN	CARMICHAEL	95608	CA	3	1	1713	Residential	Mon May 19 00:00:00 EDT 2008	266000	38.6719950000000026	-121.324338999999995
476	5635 FOXVIEW WAY	ELK GROVE	95757	CA	3	2	1457	Residential	Mon May 19 00:00:00 EDT 2008	270000	38.3952560000000034	-121.438248999999999
477	10372 VIA CINTA CT	ELK GROVE	95757	CA	4	3	2724	Residential	Mon May 19 00:00:00 EDT 2008	274425	38.3800889999999981	-121.428185999999997
478	6286 LONETREE BLVD	ROCKLIN	95765	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	274500	38.8050360000000012	-121.293608000000006
479	7744 SOUTHBREEZE DR	SACRAMENTO	95828	CA	3	2	1468	Residential	Mon May 19 00:00:00 EDT 2008	275336	38.4769319999999979	-121.378349
480	2242 ABLE WAY	SACRAMENTO	95835	CA	4	3	2550	Residential	Mon May 19 00:00:00 EDT 2008	277980	38.6660740000000018	-121.509743
481	1042 STARBROOK DR	GALT	95632	CA	4	2	1928	Residential	Mon May 19 00:00:00 EDT 2008	280000	38.2856110000000029	-121.293063000000004
482	1219 G ST	SACRAMENTO	95814	CA	3	3	1922	Residential	Mon May 19 00:00:00 EDT 2008	284686	38.5828180000000032	-121.489096000000004
483	6220 OPUS CT	CITRUS HEIGHTS	95621	CA	3	2	1343	Residential	Mon May 19 00:00:00 EDT 2008	284893	38.7158530000000027	-121.317094999999995
484	5419 HAVENHURST CIR	ROCKLIN	95677	CA	3	2	1510	Residential	Mon May 19 00:00:00 EDT 2008	285000	38.7867460000000008	-121.209957000000003
485	220 OLD AIRPORT RD	AUBURN	95603	CA	2	2	960	Multi-Family	Mon May 19 00:00:00 EDT 2008	285000	38.9398020000000002	-121.054575
486	4622 MEYER WAY	CARMICHAEL	95608	CA	4	2	1559	Residential	Mon May 19 00:00:00 EDT 2008	285000	38.6491299999999995	-121.310666999999995
487	4885 SUMMIT VIEW DR	EL DORADO	95623	CA	3	2	1624	Residential	Mon May 19 00:00:00 EDT 2008	289000	38.6732849999999999	-120.879176000000001
488	26 JEANROSS CT	SACRAMENTO	95832	CA	5	3	2992	Residential	Mon May 19 00:00:00 EDT 2008	295000	38.4731620000000021	-121.491084999999998
489	4800 MAPLEPLAIN AVE	ELK GROVE	95758	CA	4	2	2109	Residential	Mon May 19 00:00:00 EDT 2008	296000	38.4328479999999999	-121.449236999999997
490	10629 BASIE WAY	RANCHO CORDOVA	95670	CA	4	2	1524	Residential	Mon May 19 00:00:00 EDT 2008	296056	38.5790000000000006	-121.292626999999996
491	8612 WILLOW GROVE WAY	SACRAMENTO	95828	CA	3	2	1248	Residential	Mon May 19 00:00:00 EDT 2008	297359	38.4649939999999972	-121.386961999999997
492	62 DE FER CIR	SACRAMENTO	95823	CA	4	2	1876	Residential	Mon May 19 00:00:00 EDT 2008	299940	38.4925399999999982	-121.463316000000006
493	2513 OLD KENMARE RD	LINCOLN	95648	CA	5	3	0	Residential	Mon May 19 00:00:00 EDT 2008	304000	38.8473960000000034	-121.259585999999999
494	3253 ABOTO WAY	RANCHO CORDOVA	95670	CA	4	3	1851	Residential	Mon May 19 00:00:00 EDT 2008	305000	38.5772699999999986	-121.285590999999997
495	3072 VILLAGE PLAZA DR	ROSEVILLE	95747	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	307000	38.7730940000000004	-121.365904999999998
496	251 CHANGO CIR	SACRAMENTO	95835	CA	4	2	2218	Residential	Mon May 19 00:00:00 EDT 2008	311328	38.6823699999999988	-121.539147
497	8205 WEYBURN CT	SACRAMENTO	95828	CA	3	2	1394	Residential	Mon May 19 00:00:00 EDT 2008	313138	38.47316	-121.403892999999997
498	8788 LA MARGARITA WAY	SACRAMENTO	95828	CA	3	2	1410	Residential	Mon May 19 00:00:00 EDT 2008	316630	38.4681849999999983	-121.375693999999996
499	5912 DEEPDALE WAY	ELK GROVE	95758	CA	5	3	3468	Residential	Mon May 19 00:00:00 EDT 2008	320000	38.4395650000000018	-121.436605999999998
500	4712 PISMO BEACH DR	ANTELOPE	95843	CA	5	3	2346	Residential	Mon May 19 00:00:00 EDT 2008	320000	38.7077049999999971	-121.354152999999997
501	4741 PACIFIC PARK DR	ANTELOPE	95843	CA	5	3	2347	Residential	Mon May 19 00:00:00 EDT 2008	325000	38.7092990000000015	-121.353055999999995
502	310 GROTH CIR	SACRAMENTO	95834	CA	4	2	1659	Residential	Mon May 19 00:00:00 EDT 2008	328578	38.6387640000000019	-121.531827000000007
503	6121 WILD FOX CT	ELK GROVE	95757	CA	3	3	2442	Residential	Mon May 19 00:00:00 EDT 2008	331000	38.4067580000000035	-121.431668999999999
504	12241 CANYONLANDS DR	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	331500	38.5572930000000014	-121.217611000000005
505	29 COOL FOUNTAIN CT	SACRAMENTO	95833	CA	4	2	2155	Residential	Mon May 19 00:00:00 EDT 2008	340000	38.6069060000000022	-121.541319999999999
506	907 RIO ROBLES AVE	SACRAMENTO	95838	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	344755	38.6647650000000027	-121.445006000000006
507	8909 BILLFISH WAY	SACRAMENTO	95828	CA	3	2	1810	Residential	Mon May 19 00:00:00 EDT 2008	345746	38.4754330000000024	-121.372584000000003
508	6232 GUS WAY	ELK GROVE	95757	CA	4	2	2789	Residential	Mon May 19 00:00:00 EDT 2008	351000	38.3881289999999993	-121.431169999999995
509	200 OAKWILDE ST	GALT	95632	CA	4	2	1606	Residential	Mon May 19 00:00:00 EDT 2008	353767	38.2535000000000025	-121.318119999999993
510	1033 PARK STREAM DR	GALT	95632	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	355000	38.2877849999999995	-121.289902999999995
511	200 ALLAIRE CIR	SACRAMENTO	95835	CA	4	2	2166	Residential	Mon May 19 00:00:00 EDT 2008	356035	38.6831800000000001	-121.534840000000003
512	1322 SUTTER WALK	SACRAMENTO	95816	CA	0	0	0	Condo	Mon May 19 00:00:00 EDT 2008	360000	38.5380499999999984	-121.5047
513	5479 NICKMAN WAY	SACRAMENTO	95835	CA	4	2	1871	Residential	Mon May 19 00:00:00 EDT 2008	360552	38.6729660000000024	-121.502747999999997
514	2103 BURBERRY WAY	SACRAMENTO	95835	CA	3	2	1800	Residential	Mon May 19 00:00:00 EDT 2008	362305	38.6734200000000001	-121.508542000000006
515	2450 SAN JOSE WAY	SACRAMENTO	95817	CA	3	1	1683	Residential	Mon May 19 00:00:00 EDT 2008	365000	38.5535959999999989	-121.459483000000006
516	7641 ROSEHALL DR	ROSEVILLE	95678	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	367554	38.7916170000000022	-121.286147
517	1336 LAYSAN TEAL DR	ROSEVILLE	95747	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	368500	38.7961209999999994	-121.319963000000001
518	2802 BLACK OAK DR	ROCKLIN	95765	CA	2	2	1596	Residential	Mon May 19 00:00:00 EDT 2008	370000	38.8370060000000024	-121.232023999999996
519	2113 FALL TRAIL CT	PLACERVILLE	95667	CA	4	2	0	Residential	Mon May 19 00:00:00 EDT 2008	371086	38.7331549999999964	-120.748039000000006
520	10112 LAMBEAU CT	ELK GROVE	95757	CA	3	2	1179	Residential	Mon May 19 00:00:00 EDT 2008	378000	38.3903279999999967	-121.448021999999995
521	6313 CASTRO VERDE WAY	ELK GROVE	95757	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	383000	38.3811019999999985	-121.429010000000005
522	3622 CURTIS DR	SACRAMENTO	95818	CA	3	1	1639	Residential	Mon May 19 00:00:00 EDT 2008	388000	38.5417350000000027	-121.480097999999998
523	11817 OPAL RIDGE WAY	RANCHO CORDOVA	95742	CA	5	3	3281	Residential	Mon May 19 00:00:00 EDT 2008	395100	38.5510829999999984	-121.237476000000001
524	170 LAGOMARSINO WAY	SACRAMENTO	95819	CA	3	2	1697	Residential	Mon May 19 00:00:00 EDT 2008	400000	38.5748940000000005	-121.435805999999999
525	2743 DEAKIN PL	EL DORADO HILLS	95762	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	400000	38.6928800000000024	-121.073550999999995
526	3361 ALDER CANYON WAY	ANTELOPE	95843	CA	4	3	2085	Residential	Mon May 19 00:00:00 EDT 2008	408431	38.7276489999999995	-121.385655999999997
527	2148 RANCH VIEW DR	ROCKLIN	95765	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	413000	38.8374549999999985	-121.289337000000003
528	398 LINDLEY DR	SACRAMENTO	95815	CA	4	2	1744	Multi-Family	Mon May 19 00:00:00 EDT 2008	416767	38.622359000000003	-121.457582000000002
529	3013 BRIDLEWOOD DR	EL DORADO HILLS	95762	CA	4	3	0	Residential	Mon May 19 00:00:00 EDT 2008	420000	38.6755190000000013	-121.015861999999998
530	169 BAURER CIR	FOLSOM	95630	CA	4	3	1939	Residential	Mon May 19 00:00:00 EDT 2008	423000	38.6669499999999999	-121.120728999999997
531	2809 LOON CT	CAMERON PARK	95682	CA	4	2	0	Residential	Mon May 19 00:00:00 EDT 2008	423000	38.6870720000000006	-121.004728999999998
532	1315 KONDOS AVE	SACRAMENTO	95814	CA	2	3	1788	Residential	Mon May 19 00:00:00 EDT 2008	427500	38.5719429999999974	-121.492106000000007
533	4966 CHARTER RD	ROCKLIN	95765	CA	3	2	1691	Residential	Mon May 19 00:00:00 EDT 2008	430922	38.8255300000000005	-121.254698000000005
534	9516 LAGUNA LAKE WAY	ELK GROVE	95758	CA	4	2	2002	Residential	Mon May 19 00:00:00 EDT 2008	445000	38.4112579999999966	-121.431348
535	5201 BLOSSOM RANCH DR	ELK GROVE	95757	CA	4	4	4303	Residential	Mon May 19 00:00:00 EDT 2008	450000	38.3994360000000015	-121.444040999999999
536	3027 PALMATE WAY	SACRAMENTO	95834	CA	5	3	4246	Residential	Mon May 19 00:00:00 EDT 2008	452000	38.6289549999999977	-121.529268999999999
537	500 WINCHESTER CT	ROSEVILLE	95661	CA	3	2	2274	Residential	Mon May 19 00:00:00 EDT 2008	470000	38.7398799999999994	-121.248929000000004
538	5746 GELSTON WAY	EL DORADO HILLS	95762	CA	4	3	0	Residential	Mon May 19 00:00:00 EDT 2008	471000	38.6770149999999973	-121.034082999999995
539	6935 ELM TREE LN	ORANGEVALE	95662	CA	4	4	3056	Residential	Mon May 19 00:00:00 EDT 2008	475000	38.6930410000000009	-121.232939999999999
540	9605 GOLF COURSE LN	ELK GROVE	95758	CA	3	3	2503	Residential	Mon May 19 00:00:00 EDT 2008	484500	38.4096890000000002	-121.446059000000005
541	719 BAYWOOD CT	EL DORADO HILLS	95762	CA	5	3	0	Residential	Mon May 19 00:00:00 EDT 2008	487500	38.6475980000000021	-121.077800999999994
542	5954 TANUS CIR	ROCKLIN	95677	CA	3	3	0	Residential	Mon May 19 00:00:00 EDT 2008	488750	38.777585000000002	-121.203599999999994
543	100 CHELSEA CT	FOLSOM	95630	CA	3	2	1905	Residential	Mon May 19 00:00:00 EDT 2008	500000	38.69435	-121.177259000000006
544	1500 ORANGE HILL LN	PENRYN	95663	CA	3	2	1320	Residential	Mon May 19 00:00:00 EDT 2008	506688	38.8627079999999978	-121.162092000000001
545	408 KIRKWOOD CT	LINCOLN	95648	CA	2	2	0	Residential	Mon May 19 00:00:00 EDT 2008	512000	38.8616150000000005	-121.268690000000007
546	1732 TUSCAN GROVE CIR	ROSEVILLE	95747	CA	5	3	0	Residential	Mon May 19 00:00:00 EDT 2008	520000	38.7966830000000016	-121.342555000000004
547	2049 EMPIRE MINE CIR	GOLD RIVER	95670	CA	4	2	3037	Residential	Mon May 19 00:00:00 EDT 2008	528000	38.6292990000000032	-121.249020999999999
548	9360 MAGOS RD	WILTON	95693	CA	5	2	3741	Residential	Mon May 19 00:00:00 EDT 2008	579093	38.4168090000000007	-121.240628000000001
549	104 CATLIN CT	FOLSOM	95630	CA	4	3	2660	Residential	Mon May 19 00:00:00 EDT 2008	636000	38.6844589999999968	-121.145934999999994
550	4734 GIBBONS DR	CARMICHAEL	95608	CA	4	3	3357	Residential	Mon May 19 00:00:00 EDT 2008	668365	38.6355799999999974	-121.353639000000001
551	4629 DORCHESTER LN	GRANITE BAY	95746	CA	5	3	2896	Residential	Mon May 19 00:00:00 EDT 2008	676200	38.7235450000000014	-121.216025000000002
552	2400 COUNTRYSIDE DR	PLACERVILLE	95667	CA	3	2	2025	Residential	Mon May 19 00:00:00 EDT 2008	677048	38.7374519999999976	-120.910962999999995
553	12901 FURLONG DR	WILTON	95693	CA	5	3	3788	Residential	Mon May 19 00:00:00 EDT 2008	691659	38.4135350000000031	-121.188210999999995
554	6222 CALLE MONTALVO CIR	GRANITE BAY	95746	CA	5	3	3670	Residential	Mon May 19 00:00:00 EDT 2008	760000	38.7794349999999994	-121.146675999999999
555	20 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853269999999966	-121.289411999999999
556	24 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8851319999999987	-121.289405000000002
557	28 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8849360000000033	-121.289396999999994
558	32 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847409999999982	-121.289389999999997
559	36 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845990000000015	-121.289406
560	40 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845349999999996	-121.289619000000002
561	44 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845900000000029	-121.289834999999997
562	48 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8846670000000003	-121.289895999999999
563	52 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847799999999992	-121.289911000000004
564	68 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.885235999999999	-121.289928000000003
565	72 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853500000000025	-121.289925999999994
566	76 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8854639999999989	-121.289922000000004
567	80 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8855780000000024	-121.289918999999998
568	84 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8856919999999988	-121.289914999999993
569	88 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8858060000000023	-121.289911000000004
570	92 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8859199999999987	-121.289907999999997
571	96 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.886023999999999	-121.289859000000007
572	100 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8860910000000004	-121.289743999999999
573	434 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865300000000005	-121.289406
574	3 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8846920000000011	-121.290288000000004
575	11 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.884878999999998	-121.290256999999997
576	19 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8850169999999977	-121.290261999999998
577	27 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8851730000000018	-121.290270000000007
578	35 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853280000000012	-121.290274999999994
579	43 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8854830000000007	-121.290277000000003
580	51 E ST	LINCOLN	95648	CA	4	2	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8856380000000001	-121.290278999999998
581	59 E ST	LINCOLN	95648	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8857939999999971	-121.290280999999993
582	75 E ST	LINCOLN	95648	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8861040000000031	-121.290284999999997
583	63 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8850929999999977	-121.289931999999993
584	398 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865300000000005	-121.288951999999995
585	386 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865279999999984	-121.288869000000005
586	374 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865249999999989	-121.288786999999999
587	116 CRYSTALWOOD WAY	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8862820000000013	-121.289586
588	108 CRYSTALWOOD WAY	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8862820000000013	-121.289646000000005
589	100 CRYSTALWOOD WAY	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8862820000000013	-121.289705999999995
590	55 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8848649999999978	-121.289922000000004
591	51 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847519999999989	-121.289906999999999
592	47 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8846380000000025	-121.289893000000006
593	43 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845680000000016	-121.289783999999997
594	39 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845460000000003	-121.289562000000004
595	35 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.884644999999999	-121.289396999999994
596	31 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847900000000024	-121.289392000000007
597	27 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8849850000000004	-121.289399000000003
598	23 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8851810000000029	-121.289406
599	19 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853760000000008	-121.289413999999994
600	15 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8855709999999988	-121.289421000000004
601	7 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8859619999999993	-121.289435999999995
602	7 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8859619999999993	-121.289435999999995
603	3 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8860930000000025	-121.289584000000005
604	8208 WOODYARD WAY	CITRUS HEIGHTS	95621	CA	3	2	1166	Residential	Fri May 16 00:00:00 EDT 2008	30000	38.7153220000000005	-121.314786999999995
605	113 RINETTI WAY	RIO LINDA	95673	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	30000	38.6871719999999968	-121.463932999999997
606	15 LOORZ CT	SACRAMENTO	95823	CA	2	1	838	Residential	Fri May 16 00:00:00 EDT 2008	55422	38.4716459999999998	-121.435158000000001
607	5805 DOTMAR WAY	NORTH HIGHLANDS	95660	CA	2	1	904	Residential	Fri May 16 00:00:00 EDT 2008	63000	38.6726420000000033	-121.380342999999996
608	2332 CAMBRIDGE ST	SACRAMENTO	95815	CA	2	1	1032	Residential	Fri May 16 00:00:00 EDT 2008	65000	38.6080850000000027	-121.449651000000003
609	3812 BELDEN ST	SACRAMENTO	95838	CA	2	1	904	Residential	Fri May 16 00:00:00 EDT 2008	65000	38.6368330000000029	-121.441640000000007
610	3348 40TH ST	SACRAMENTO	95817	CA	2	1	1080	Residential	Fri May 16 00:00:00 EDT 2008	65000	38.544162	-121.460651999999996
611	127 QUASAR CIR	SACRAMENTO	95822	CA	2	2	990	Residential	Fri May 16 00:00:00 EDT 2008	66500	38.4935040000000015	-121.475303999999994
612	3812 CYPRESS ST	SACRAMENTO	95838	CA	2	1	900	Residential	Fri May 16 00:00:00 EDT 2008	71000	38.6368769999999984	-121.444947999999997
613	5821 64TH ST	SACRAMENTO	95824	CA	2	1	861	Residential	Fri May 16 00:00:00 EDT 2008	75000	38.5212020000000024	-121.428145999999998
614	8248 CENTER PKWY	SACRAMENTO	95823	CA	2	1	906	Condo	Fri May 16 00:00:00 EDT 2008	77000	38.4590019999999981	-121.428793999999996
615	1171 SONOMA AVE	SACRAMENTO	95815	CA	2	1	1011	Residential	Fri May 16 00:00:00 EDT 2008	85000	38.6238000000000028	-121.439871999999994
616	4250 ARDWELL WAY	SACRAMENTO	95823	CA	3	2	1089	Residential	Fri May 16 00:00:00 EDT 2008	95625	38.466937999999999	-121.455630999999997
617	3104 CLAY ST	SACRAMENTO	95815	CA	2	1	832	Residential	Fri May 16 00:00:00 EDT 2008	96140	38.6239100000000022	-121.439207999999994
618	6063 LAND PARK DR	SACRAMENTO	95822	CA	2	1	800	Condo	Fri May 16 00:00:00 EDT 2008	104250	38.5170290000000008	-121.513808999999995
619	4738 OAKHOLLOW DR	SACRAMENTO	95842	CA	4	2	1292	Residential	Fri May 16 00:00:00 EDT 2008	105000	38.6795979999999986	-121.356035000000006
620	1401 STERLING ST	SACRAMENTO	95822	CA	2	1	810	Residential	Fri May 16 00:00:00 EDT 2008	108000	38.5203190000000006	-121.504727000000003
621	3715 DIDCOT CIR	SACRAMENTO	95838	CA	4	2	1064	Residential	Fri May 16 00:00:00 EDT 2008	109000	38.635232000000002	-121.460098000000002
622	2426 RASHAWN DR	RANCHO CORDOVA	95670	CA	2	1	911	Residential	Fri May 16 00:00:00 EDT 2008	115000	38.6108520000000013	-121.273278000000005
623	4800 WESTLAKE PKWY Unit 410	SACRAMENTO	95835	CA	1	1	846	Condo	Fri May 16 00:00:00 EDT 2008	115000	38.6588119999999975	-121.542344999999997
624	3409 VIRGO ST	SACRAMENTO	95827	CA	3	2	1320	Residential	Fri May 16 00:00:00 EDT 2008	115500	38.5634020000000035	-121.327747000000002
625	1110 PINEDALE AVE	SACRAMENTO	95838	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	115620	38.6601730000000003	-121.440216000000007
626	2361 LA LOMA DR	RANCHO CORDOVA	95670	CA	3	2	1115	Residential	Fri May 16 00:00:00 EDT 2008	116000	38.5936799999999991	-121.316053999999994
627	1455 64TH AVE	SACRAMENTO	95822	CA	3	2	1169	Residential	Fri May 16 00:00:00 EDT 2008	122000	38.4921769999999981	-121.503392000000005
628	7328 SPRINGMAN ST	SACRAMENTO	95822	CA	3	2	1164	Residential	Fri May 16 00:00:00 EDT 2008	122500	38.4919909999999987	-121.477636000000004
629	119 SAINT MARIE CIR	SACRAMENTO	95823	CA	4	2	1341	Residential	Fri May 16 00:00:00 EDT 2008	123000	38.4814539999999994	-121.446644000000006
630	12 COSTA BRASE CT	SACRAMENTO	95838	CA	3	2	1219	Residential	Fri May 16 00:00:00 EDT 2008	124000	38.6555540000000022	-121.464275000000001
631	6813 SCOTER WAY	SACRAMENTO	95842	CA	4	2	1127	Residential	Fri May 16 00:00:00 EDT 2008	124000	38.6904299999999992	-121.361035000000001
632	6548 GRAYLOCK LN	NORTH HIGHLANDS	95660	CA	3	2	1272	Residential	Fri May 16 00:00:00 EDT 2008	124413	38.6860610000000023	-121.369949000000005
633	1630 GLIDDEN AVE	SACRAMENTO	95822	CA	4	2	1253	Residential	Fri May 16 00:00:00 EDT 2008	125000	38.482717000000001	-121.499683000000005
634	7825 DALEWOODS WAY	SACRAMENTO	95828	CA	3	2	1120	Residential	Fri May 16 00:00:00 EDT 2008	130000	38.4772970000000001	-121.411512999999999
635	4073 TRESLER AVE	NORTH HIGHLANDS	95660	CA	2	2	1118	Residential	Fri May 16 00:00:00 EDT 2008	131750	38.6590160000000012	-121.370457000000002
636	4288 DYMIC WAY	SACRAMENTO	95838	CA	4	3	1890	Residential	Fri May 16 00:00:00 EDT 2008	137721	38.6465409999999991	-121.441139000000007
637	1158 SAN IGNACIO WAY	SACRAMENTO	95833	CA	3	2	1260	Residential	Fri May 16 00:00:00 EDT 2008	137760	38.6230449999999976	-121.486278999999996
638	4904 J PKWY	SACRAMENTO	95823	CA	3	2	1400	Residential	Fri May 16 00:00:00 EDT 2008	138000	38.4872969999999981	-121.442949999999996
639	2931 HOWE AVE	SACRAMENTO	95821	CA	3	1	1264	Residential	Fri May 16 00:00:00 EDT 2008	140000	38.6190119999999979	-121.415329
640	5531 JANSEN DR	SACRAMENTO	95824	CA	3	1	1060	Residential	Fri May 16 00:00:00 EDT 2008	145000	38.5220150000000032	-121.438713000000007
641	7836 ORCHARD WOODS CIR	SACRAMENTO	95828	CA	2	2	1132	Residential	Fri May 16 00:00:00 EDT 2008	145000	38.4795500000000033	-121.410866999999996
642	4055 DEERBROOK DR	SACRAMENTO	95823	CA	3	2	1466	Residential	Fri May 16 00:00:00 EDT 2008	150000	38.4721169999999972	-121.459588999999994
643	9937 BURLINE ST	SACRAMENTO	95827	CA	3	2	1092	Residential	Fri May 16 00:00:00 EDT 2008	150000	38.5596409999999992	-121.323160000000001
644	6948 MIRADOR WAY	SACRAMENTO	95828	CA	4	2	1628	Residential	Fri May 16 00:00:00 EDT 2008	151000	38.4934840000000023	-121.420349999999999
645	4909 RUGER CT	SACRAMENTO	95842	CA	3	2	960	Residential	Fri May 16 00:00:00 EDT 2008	155000	38.6874699999999976	-121.349233999999996
646	7204 KERSTEN ST	CITRUS HEIGHTS	95621	CA	3	2	1075	Residential	Fri May 16 00:00:00 EDT 2008	155800	38.6958630000000028	-121.300814000000003
647	3150 ROSEMONT DR	SACRAMENTO	95826	CA	3	2	1428	Residential	Fri May 16 00:00:00 EDT 2008	156142	38.5549269999999993	-121.35521
648	8200 STEINBECK WAY	SACRAMENTO	95828	CA	4	2	1358	Residential	Fri May 16 00:00:00 EDT 2008	158000	38.4748540000000006	-121.404725999999997
649	8198 STEVENSON AVE	SACRAMENTO	95828	CA	6	4	2475	Multi-Family	Fri May 16 00:00:00 EDT 2008	159900	38.4652710000000013	-121.404259999999994
650	6824 OLIVE TREE WAY	CITRUS HEIGHTS	95610	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	160000	38.6892390000000006	-121.267736999999997
651	3536 SUN MAIDEN WAY	ANTELOPE	95843	CA	3	2	1711	Residential	Fri May 16 00:00:00 EDT 2008	161500	38.7096799999999988	-121.382328000000001
652	4517 OLYMPIAD WAY	SACRAMENTO	95826	CA	4	2	1483	Residential	Fri May 16 00:00:00 EDT 2008	161600	38.5367510000000024	-121.359154000000004
653	925 COBDEN CT	GALT	95632	CA	3	2	1140	Residential	Fri May 16 00:00:00 EDT 2008	162000	38.2820469999999986	-121.295811999999998
654	8225 SCOTTSDALE DR	SACRAMENTO	95828	CA	4	2	1549	Residential	Fri May 16 00:00:00 EDT 2008	165000	38.4878640000000019	-121.402475999999993
655	8758 LEMAS RD	SACRAMENTO	95828	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	165000	38.4674869999999984	-121.377054999999999
656	6121 ALPINESPRING WAY	ELK GROVE	95758	CA	3	2	1240	Residential	Fri May 16 00:00:00 EDT 2008	167293	38.434075	-121.432623000000007
657	5937 YORK GLEN WAY	SACRAMENTO	95842	CA	5	2	1712	Residential	Fri May 16 00:00:00 EDT 2008	168000	38.6770029999999991	-121.354454000000004
658	6417 SUNNYFIELD WAY	SACRAMENTO	95823	CA	4	2	1580	Residential	Fri May 16 00:00:00 EDT 2008	168000	38.4491530000000026	-121.428272000000007
659	4008 GREY LIVERY WAY	ANTELOPE	95843	CA	3	2	1669	Residential	Fri May 16 00:00:00 EDT 2008	168750	38.7184600000000003	-121.370862000000002
660	8920 ROSETTA CIR	SACRAMENTO	95826	CA	3	1	1029	Residential	Fri May 16 00:00:00 EDT 2008	168750	38.5443739999999977	-121.370874000000001
661	8300 LICHEN DR	CITRUS HEIGHTS	95621	CA	3	1	1103	Residential	Fri May 16 00:00:00 EDT 2008	170000	38.7164100000000033	-121.306239000000005
662	8884 AMBERJACK WAY	SACRAMENTO	95828	CA	3	2	2161	Residential	Fri May 16 00:00:00 EDT 2008	170250	38.4793430000000001	-121.372552999999996
663	4480 VALLEY HI DR	SACRAMENTO	95823	CA	3	2	1650	Residential	Fri May 16 00:00:00 EDT 2008	173000	38.4667809999999974	-121.450954999999993
664	2250 FOREBAY RD	POLLOCK PINES	95726	CA	3	1	1320	Residential	Fri May 16 00:00:00 EDT 2008	175000	38.7749099999999984	-120.597599000000002
665	3529 FABERGE WAY	SACRAMENTO	95826	CA	3	2	1200	Residential	Fri May 16 00:00:00 EDT 2008	176095	38.5532749999999993	-121.346217999999993
666	1792 DAWNELLE WAY	SACRAMENTO	95835	CA	3	2	1170	Residential	Fri May 16 00:00:00 EDT 2008	176250	38.6827100000000002	-121.501696999999993
667	7800 TABARE CT	CITRUS HEIGHTS	95621	CA	3	2	1199	Residential	Fri May 16 00:00:00 EDT 2008	178000	38.7079900000000023	-121.302978999999993
668	8531 HERMITAGE WAY	SACRAMENTO	95823	CA	4	2	1695	Residential	Fri May 16 00:00:00 EDT 2008	179000	38.4484520000000032	-121.428535999999994
669	2421 BERRYWOOD DR	RANCHO CORDOVA	95670	CA	3	2	1157	Residential	Fri May 16 00:00:00 EDT 2008	180000	38.6086799999999997	-121.278490000000005
670	1005 MORENO WAY	SACRAMENTO	95838	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	180000	38.6462059999999994	-121.442767000000003
671	1675 VERNON ST Unit 24	ROSEVILLE	95678	CA	3	2	1174	Residential	Fri May 16 00:00:00 EDT 2008	180000	38.7341359999999995	-121.299638999999999
672	24 WINDCHIME CT	SACRAMENTO	95823	CA	3	2	1593	Residential	Fri May 16 00:00:00 EDT 2008	181000	38.4461700000000022	-121.427824000000001
673	540 HARLING CT	RIO LINDA	95673	CA	3	2	1093	Residential	Fri May 16 00:00:00 EDT 2008	182000	38.6827899999999971	-121.453508999999997
674	1207 CRESCENDO DR	ROSEVILLE	95678	CA	3	2	1770	Residential	Fri May 16 00:00:00 EDT 2008	182587	38.7244600000000005	-121.292828999999998
675	7577 EDDYLEE WAY	SACRAMENTO	95822	CA	4	2	1436	Residential	Fri May 16 00:00:00 EDT 2008	185074	38.4829099999999968	-121.491508999999994
676	8369 FOPPIANO WAY	SACRAMENTO	95829	CA	3	2	1124	Residential	Fri May 16 00:00:00 EDT 2008	185833	38.4538390000000021	-121.357918999999995
677	8817 SAWTELLE WAY	SACRAMENTO	95826	CA	4	2	1139	Residential	Fri May 16 00:00:00 EDT 2008	186785	38.5653220000000019	-121.374251000000001
678	1910 BONAVISTA WAY	SACRAMENTO	95832	CA	3	2	1638	Residential	Fri May 16 00:00:00 EDT 2008	187000	38.4760479999999987	-121.494961000000004
679	8 TIDE CT	SACRAMENTO	95833	CA	3	2	1328	Residential	Fri May 16 00:00:00 EDT 2008	188335	38.6098640000000017	-121.492304000000004
680	8952 ROCKY CREEK CT	ELK GROVE	95758	CA	3	2	1273	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.4312389999999979	-121.440010000000001
681	435 EXCHANGE ST	SACRAMENTO	95838	CA	3	1	1082	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.6594339999999974	-121.455235999999999
682	10105 MONTE VALLO CT	SACRAMENTO	95827	CA	4	2	1578	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.5739170000000016	-121.316916000000006
683	3930 ANNABELLE AVE	ROSEVILLE	95661	CA	2	1	796	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.7276090000000011	-121.226494000000002
684	4854 TANGERINE AVE	SACRAMENTO	95823	CA	3	2	1386	Residential	Fri May 16 00:00:00 EDT 2008	191250	38.4782390000000021	-121.446325999999999
685	2909 SHAWN WAY	RANCHO CORDOVA	95670	CA	3	2	1452	Residential	Fri May 16 00:00:00 EDT 2008	193000	38.5899250000000009	-121.299059
686	4290 BLACKFORD WAY	SACRAMENTO	95823	CA	3	2	1513	Residential	Fri May 16 00:00:00 EDT 2008	193500	38.4704940000000022	-121.454161999999997
687	5890 TT TRAK	FORESTHILL	95631	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	194818	39.0208080000000024	-120.821517999999998
688	7015 WOODSIDE DR	SACRAMENTO	95842	CA	4	2	1578	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.6930710000000033	-121.332364999999996
689	6019 CHESHIRE WAY	CITRUS HEIGHTS	95610	CA	4	3	1736	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.676437	-121.279165000000006
690	3330 VILLAGE CT	CAMERON PARK	95682	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.6905039999999971	-120.996245000000002
691	2561 VERNA WAY	SACRAMENTO	95821	CA	3	1	1473	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.6110550000000003	-121.369963999999996
692	3522 22ND AVE	SACRAMENTO	95820	CA	3	1	1150	Residential	Fri May 16 00:00:00 EDT 2008	198000	38.5327249999999992	-121.469077999999996
693	2880 CANDIDO DR	SACRAMENTO	95833	CA	3	2	1127	Residential	Fri May 16 00:00:00 EDT 2008	199900	38.6180189999999968	-121.510215000000002
694	6908 PIN OAK CT	FAIR OAKS	95628	CA	3	1	1144	Residential	Fri May 16 00:00:00 EDT 2008	200000	38.6642399999999995	-121.303674999999998
695	5733 ANGELINA AVE	CARMICHAEL	95608	CA	3	1	972	Residential	Fri May 16 00:00:00 EDT 2008	201000	38.6226339999999979	-121.330845999999994
696	7849 BONNY DOWNS WAY	ELK GROVE	95758	CA	4	2	2306	Residential	Fri May 16 00:00:00 EDT 2008	204918	38.4213900000000024	-121.411338999999998
697	8716 LONGSPUR WAY	ANTELOPE	95843	CA	3	2	1479	Residential	Fri May 16 00:00:00 EDT 2008	205000	38.7240830000000003	-121.358400000000003
698	6320 EL DORADO ST	EL DORADO	95623	CA	2	1	1040	Residential	Fri May 16 00:00:00 EDT 2008	205000	38.678758000000002	-120.844117999999995
699	2328 DOROTHY JUNE WAY	SACRAMENTO	95838	CA	3	2	1430	Residential	Fri May 16 00:00:00 EDT 2008	205878	38.641727000000003	-121.412702999999993
700	1986 DANVERS WAY	SACRAMENTO	95832	CA	4	2	1800	Residential	Fri May 16 00:00:00 EDT 2008	207000	38.4772299999999987	-121.492568000000006
701	7901 GAZELLE TRAIL WAY	ANTELOPE	95843	CA	4	2	1953	Residential	Fri May 16 00:00:00 EDT 2008	207744	38.7117399999999989	-121.342675
702	6080 BRIDGECROSS DR	SACRAMENTO	95835	CA	3	2	1120	Residential	Fri May 16 00:00:00 EDT 2008	209000	38.6819520000000026	-121.505009000000001
703	20 GROTH CIR	SACRAMENTO	95834	CA	3	2	1232	Residential	Fri May 16 00:00:00 EDT 2008	210000	38.6408070000000023	-121.533522000000005
704	1900 DANBROOK DR	SACRAMENTO	95835	CA	1	1	984	Condo	Fri May 16 00:00:00 EDT 2008	210944	38.6684330000000003	-121.503471000000005
705	140 VENTO CT	ROSEVILLE	95678	CA	3	2	0	Condo	Fri May 16 00:00:00 EDT 2008	212500	38.7935329999999965	-121.289685000000006
706	8442 KEUSMAN ST	ELK GROVE	95758	CA	4	2	2329	Residential	Fri May 16 00:00:00 EDT 2008	213750	38.4496510000000029	-121.414704
707	9552 SUNLIGHT LN	ELK GROVE	95758	CA	3	2	1351	Residential	Fri May 16 00:00:00 EDT 2008	215000	38.4105610000000013	-121.404326999999995
708	2733 YUMA CT	CAMERON PARK	95682	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	215000	38.6912149999999997	-120.994949000000005
709	1407 TIFFANY CIR	ROSEVILLE	95661	CA	4	1	1376	Residential	Fri May 16 00:00:00 EDT 2008	215000	38.7363920000000022	-121.266400000000004
710	636 CRESTVIEW DR	DIAMOND SPRINGS	95619	CA	3	2	1300	Residential	Fri May 16 00:00:00 EDT 2008	216033	38.6882549999999981	-120.810235000000006
711	1528 HESKET WAY	SACRAMENTO	95825	CA	4	2	1566	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.5935980000000001	-121.403637000000003
712	2327 32ND ST	SACRAMENTO	95817	CA	2	1	1115	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.5574330000000032	-121.470339999999993
713	1833 2ND AVE	SACRAMENTO	95818	CA	2	1	1032	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.5568179999999998	-121.490668999999997
714	7252 CARRIAGE DR	CITRUS HEIGHTS	95621	CA	4	2	1419	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.6980580000000032	-121.294893000000002
715	9815 PASO FINO WAY	ELK GROVE	95757	CA	3	2	1261	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.4048879999999997	-121.443997999999993
716	5532 ENGLE RD	CARMICHAEL	95608	CA	2	2	1637	Residential	Fri May 16 00:00:00 EDT 2008	220702	38.6317299999999975	-121.335285999999996
717	1139 CLINTON RD	SACRAMENTO	95825	CA	4	2	1776	Multi-Family	Fri May 16 00:00:00 EDT 2008	221250	38.585290999999998	-121.406824
718	9176 SAGE GLEN WAY	ELK GROVE	95758	CA	3	2	1338	Residential	Fri May 16 00:00:00 EDT 2008	222000	38.4239129999999989	-121.439115000000001
719	9967 HATHERTON WAY	ELK GROVE	95757	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	222500	38.3051999999999992	-121.403300000000002
720	9264 BOULDER RIVER WAY	ELK GROVE	95624	CA	5	2	2254	Residential	Fri May 16 00:00:00 EDT 2008	222750	38.4217129999999969	-121.345191
721	320 GROTH CIR	SACRAMENTO	95834	CA	3	2	1441	Residential	Fri May 16 00:00:00 EDT 2008	225000	38.6388820000000024	-121.531882999999993
722	137 GUNNISON AVE	SACRAMENTO	95838	CA	4	2	1991	Residential	Fri May 16 00:00:00 EDT 2008	225000	38.6507289999999983	-121.466482999999997
723	8209 RIVALLO WAY	SACRAMENTO	95829	CA	4	3	2126	Residential	Fri May 16 00:00:00 EDT 2008	228750	38.4595240000000018	-121.350099999999998
724	8637 PERIWINKLE CIR	ELK GROVE	95624	CA	3	2	1094	Residential	Fri May 16 00:00:00 EDT 2008	229000	38.4431840000000022	-121.364388000000005
725	3425 MEADOW WAY	ROCKLIN	95677	CA	3	2	1462	Residential	Fri May 16 00:00:00 EDT 2008	230095	38.7980280000000022	-121.235364000000004
726	107 JARVIS CIR	SACRAMENTO	95834	CA	5	3	2258	Residential	Fri May 16 00:00:00 EDT 2008	232500	38.6398909999999987	-121.537603000000004
727	2319 THORES ST	RANCHO CORDOVA	95670	CA	3	2	1074	Residential	Fri May 16 00:00:00 EDT 2008	233000	38.5967500000000001	-121.312715999999995
728	8935 MOUNTAIN HOME CT	ELK GROVE	95624	CA	4	2	2111	Residential	Fri May 16 00:00:00 EDT 2008	233500	38.3875099999999989	-121.370276000000004
729	2566 SERENATA WAY	SACRAMENTO	95835	CA	3	2	1686	Residential	Fri May 16 00:00:00 EDT 2008	239000	38.6715560000000025	-121.520916
730	4085 COUNTRY DR	ANTELOPE	95843	CA	4	3	1915	Residential	Fri May 16 00:00:00 EDT 2008	240000	38.7062090000000012	-121.369508999999994
731	9297 TROUT WAY	ELK GROVE	95624	CA	4	2	2367	Residential	Fri May 16 00:00:00 EDT 2008	240000	38.4206369999999993	-121.375798000000003
732	7 ARCHIBALD CT	SACRAMENTO	95823	CA	3	2	1962	Residential	Fri May 16 00:00:00 EDT 2008	240971	38.4433050000000023	-121.435295999999994
733	11130 EEL RIVER CT	RANCHO CORDOVA	95670	CA	2	2	1406	Residential	Fri May 16 00:00:00 EDT 2008	242000	38.6259319999999988	-121.271517000000003
734	8323 REDBANK WAY	SACRAMENTO	95829	CA	3	2	1789	Residential	Fri May 16 00:00:00 EDT 2008	243450	38.4557530000000014	-121.349272999999997
735	16 BRONCO CREEK CT	SACRAMENTO	95835	CA	4	2	1876	Residential	Fri May 16 00:00:00 EDT 2008	243500	38.6742259999999973	-121.525497000000001
736	8316 NORTHAM DR	ANTELOPE	95843	CA	3	2	1235	Residential	Fri May 16 00:00:00 EDT 2008	246544	38.7207670000000022	-121.376677999999998
737	4240 WINJE DR	ANTELOPE	95843	CA	4	2	2504	Residential	Fri May 16 00:00:00 EDT 2008	246750	38.7088400000000021	-121.359559000000004
738	3569 SODA WAY	SACRAMENTO	95834	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	247000	38.6311389999999975	-121.501879000000002
739	5118 ROBANDER ST	CARMICHAEL	95608	CA	3	2	1676	Residential	Fri May 16 00:00:00 EDT 2008	247000	38.6572669999999974	-121.310351999999995
740	5976 KYLENCH CT	CITRUS HEIGHTS	95621	CA	3	2	1367	Residential	Fri May 16 00:00:00 EDT 2008	249000	38.7089659999999967	-121.324669999999998
741	9247 DELAIR WAY	ELK GROVE	95758	CA	4	3	1899	Residential	Fri May 16 00:00:00 EDT 2008	249000	38.4222409999999996	-121.458022
742	9054 DESCENDANT DR	ELK GROVE	95758	CA	3	2	1636	Residential	Fri May 16 00:00:00 EDT 2008	250000	38.4288519999999991	-121.415627999999998
743	3450 WHITNOR CT	SACRAMENTO	95821	CA	3	2	1828	Residential	Fri May 16 00:00:00 EDT 2008	250000	38.6276980000000023	-121.369698
744	6288 LONETREE BLVD	ROCKLIN	95765	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	250000	38.8049930000000032	-121.293609000000004
745	9355 MATADOR WAY	SACRAMENTO	95826	CA	4	2	1438	Residential	Fri May 16 00:00:00 EDT 2008	252000	38.5556330000000003	-121.350690999999998
746	8671 SUMMER SUN WAY	ELK GROVE	95624	CA	3	2	1451	Residential	Fri May 16 00:00:00 EDT 2008	255000	38.4428449999999984	-121.373272
747	1890 GENEVA PL	SACRAMENTO	95825	CA	3	1	1520	Residential	Fri May 16 00:00:00 EDT 2008	255000	38.5994489999999999	-121.400305000000003
748	1813 AVENIDA MARTINA	ROSEVILLE	95747	CA	3	2	1506	Residential	Fri May 16 00:00:00 EDT 2008	255000	38.776648999999999	-121.339589000000004
749	191 BARNHART CIR	SACRAMENTO	95835	CA	4	2	2605	Residential	Fri May 16 00:00:00 EDT 2008	257200	38.6755939999999967	-121.515878000000001
750	6221 GREEN TOP WAY	ORANGEVALE	95662	CA	3	2	1196	Residential	Fri May 16 00:00:00 EDT 2008	260000	38.6794089999999997	-121.219106999999994
751	2298 PRIMROSE LN	LINCOLN	95648	CA	3	2	1621	Residential	Fri May 16 00:00:00 EDT 2008	260000	38.8991800000000012	-121.322513999999998
752	5635 LOS PUEBLOS WAY	SACRAMENTO	95835	CA	3	2	1811	Residential	Fri May 16 00:00:00 EDT 2008	263500	38.679191000000003	-121.537621999999999
753	10165 LOFTON WAY	ELK GROVE	95757	CA	3	2	1540	Residential	Fri May 16 00:00:00 EDT 2008	266510	38.3877080000000035	-121.436521999999997
754	1251 GREEN RAVINE DR	LINCOLN	95648	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	267750	38.8815600000000003	-121.301343000000003
755	6001 SHOO FLY RD	PLACERVILLE	95667	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	270000	38.8135460000000023	-120.809253999999996
756	3040 PARKHAM DR	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	271000	38.7708349999999982	-121.366996
757	2674 TAM O SHANTER DR	EL DORADO HILLS	95762	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	272700	38.695801000000003	-121.079216000000002
758	6007 MARYBELLE LN	SHINGLE SPRINGS	95682	CA	0	0	0	Unkown	Fri May 16 00:00:00 EDT 2008	275000	38.6434700000000007	-120.888182999999998
759	9949 NESTLING CIR	ELK GROVE	95757	CA	3	2	1543	Residential	Fri May 16 00:00:00 EDT 2008	275000	38.3974550000000008	-121.468390999999997
760	2915 HOLDREGE WAY	SACRAMENTO	95835	CA	5	3	2494	Residential	Fri May 16 00:00:00 EDT 2008	276000	38.663727999999999	-121.525833000000006
761	2678 BRIARTON DR	LINCOLN	95648	CA	3	2	1650	Residential	Fri May 16 00:00:00 EDT 2008	276500	38.8441159999999996	-121.274805999999998
762	294 SPARROW DR	GALT	95632	CA	4	3	2214	Residential	Fri May 16 00:00:00 EDT 2008	278000	38.258975999999997	-121.321265999999994
763	2987 DIORITE WAY	SACRAMENTO	95835	CA	5	3	2280	Residential	Fri May 16 00:00:00 EDT 2008	279000	38.6673320000000018	-121.528276000000005
764	6326 APPIAN WAY	CARMICHAEL	95608	CA	3	2	1443	Residential	Fri May 16 00:00:00 EDT 2008	280000	38.6626600000000025	-121.316857999999996
765	6905 COBALT WAY	CITRUS HEIGHTS	95621	CA	4	2	1582	Residential	Fri May 16 00:00:00 EDT 2008	280000	38.6913929999999979	-121.305215000000004
766	8986 HAFLINGER WAY	ELK GROVE	95757	CA	3	2	1857	Residential	Fri May 16 00:00:00 EDT 2008	285000	38.3979229999999987	-121.450219000000004
767	2916 BABSON DR	ELK GROVE	95758	CA	3	2	1735	Residential	Fri May 16 00:00:00 EDT 2008	288000	38.4171910000000025	-121.473896999999994
768	10133 NEBBIOLO CT	ELK GROVE	95624	CA	4	3	2096	Residential	Fri May 16 00:00:00 EDT 2008	289000	38.3910849999999968	-121.347230999999994
769	1103 COMMONS DR	SACRAMENTO	95825	CA	3	2	1720	Residential	Fri May 16 00:00:00 EDT 2008	290000	38.5678649999999976	-121.410698999999994
770	4636 TEAL BAY CT	ANTELOPE	95843	CA	4	2	2160	Residential	Fri May 16 00:00:00 EDT 2008	290000	38.7045540000000017	-121.354753000000002
771	1524 YOUNGS AVE	SACRAMENTO	95838	CA	4	2	1382	Residential	Fri May 16 00:00:00 EDT 2008	293996	38.6449270000000027	-121.430539999999993
772	865 CONRAD CT	PLACERVILLE	95667	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	294000	38.7299930000000003	-120.802458000000001
773	8463 TERRACOTTA CT	ELK GROVE	95624	CA	4	2	1721	Residential	Fri May 16 00:00:00 EDT 2008	294173	38.4505479999999977	-121.363001999999994
774	5747 KING RD	LOOMIS	95650	CA	4	2	1328	Residential	Fri May 16 00:00:00 EDT 2008	295000	38.8250960000000021	-121.198431999999997
775	8253 KEEGAN WAY	ELK GROVE	95624	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	298000	38.4462860000000006	-121.400817000000004
776	9204 TROUT WAY	ELK GROVE	95624	CA	4	2	1982	Residential	Fri May 16 00:00:00 EDT 2008	298000	38.4222210000000004	-121.375799000000001
777	1828 2ND AVE	SACRAMENTO	95818	CA	2	1	1144	Residential	Fri May 16 00:00:00 EDT 2008	299000	38.5568439999999981	-121.490769
778	1113 COMMONS DR	SACRAMENTO	95825	CA	2	2	1623	Residential	Fri May 16 00:00:00 EDT 2008	300000	38.5677949999999967	-121.410702999999998
779	2341 BIG STRIKE TRL	COOL	95614	CA	3	2	1457	Residential	Fri May 16 00:00:00 EDT 2008	300000	38.9059269999999984	-120.975168999999994
780	9452 RED SPRUCE WAY	ELK GROVE	95624	CA	6	3	2555	Residential	Fri May 16 00:00:00 EDT 2008	300000	38.4045050000000003	-121.346937999999994
781	5776 TERRACE DR	ROCKLIN	95765	CA	3	2	1577	Residential	Fri May 16 00:00:00 EDT 2008	300567	38.8005390000000006	-121.260979000000006
782	5908 MCLEAN DR	ELK GROVE	95757	CA	5	3	2592	Residential	Fri May 16 00:00:00 EDT 2008	303000	38.3891199999999984	-121.434388999999996
783	8215 PEREGRINE WAY	CITRUS HEIGHTS	95610	CA	3	2	1401	Residential	Fri May 16 00:00:00 EDT 2008	305000	38.7154930000000022	-121.262929999999997
784	1104 HILLSDALE LN	LINCOLN	95648	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	306000	38.8650170000000017	-121.32302
785	2949 PANAMA AVE	CARMICHAEL	95608	CA	3	2	1502	Residential	Fri May 16 00:00:00 EDT 2008	310000	38.6183690000000013	-121.326187000000004
786	1356 HARTLEY WAY	FOLSOM	95630	CA	3	2	1327	Residential	Fri May 16 00:00:00 EDT 2008	310000	38.6516170000000017	-121.131674000000004
787	633 HANISCH DR	ROSEVILLE	95678	CA	4	3	1800	Residential	Fri May 16 00:00:00 EDT 2008	310000	38.7634899999999973	-121.275880999999998
788	63 ANGEL ISLAND CIR	SACRAMENTO	95831	CA	4	2	2169	Residential	Fri May 16 00:00:00 EDT 2008	311518	38.4904080000000022	-121.547663999999997
789	1571 WILD OAK LN	LINCOLN	95648	CA	5	3	2457	Residential	Fri May 16 00:00:00 EDT 2008	312000	38.844144	-121.274174000000002
790	5222 COPPER SUNSET WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	313000	38.5291810000000012	-121.224755000000002
791	5601 SPINDRIFT LN	ORANGEVALE	95662	CA	4	2	2004	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.6682890000000015	-121.192316000000005
792	652 FIFTEEN MILE DR	ROSEVILLE	95678	CA	4	3	2212	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.7758719999999997	-121.298863999999995
793	7921 DOE TRAIL WAY	ANTELOPE	95843	CA	5	3	3134	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.7119270000000029	-121.343608000000003
794	4204 LUSK DR	SACRAMENTO	95864	CA	3	2	1360	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.6065690000000004	-121.368424000000005
795	5321 DELTA DR	ROCKLIN	95765	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.8154929999999965	-121.262907999999996
796	5608 ROSEDALE WAY	SACRAMENTO	95822	CA	3	2	1276	Residential	Fri May 16 00:00:00 EDT 2008	320000	38.5251149999999996	-121.518688999999995
797	3372 BERETANIA WAY	SACRAMENTO	95834	CA	4	3	2962	Residential	Fri May 16 00:00:00 EDT 2008	322000	38.6497699999999966	-121.534480000000002
798	2422 STEFANIE DR	ROCKLIN	95765	CA	4	2	1888	Residential	Fri May 16 00:00:00 EDT 2008	325000	38.82273	-121.264240000000001
799	3232 PARKHAM DR	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	325500	38.7728210000000004	-121.364821000000006
800	448 ELMWOOD CT	ROSEVILLE	95678	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	326951	38.771917000000002	-121.304439000000002
801	1214 DAWNWOOD DR	GALT	95632	CA	3	2	1548	Residential	Fri May 16 00:00:00 EDT 2008	328370	38.2901189999999971	-121.286023
802	1440 EMERALD LN	LINCOLN	95648	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	330000	38.8618639999999971	-121.267477999999997
803	3349 CORVINA DR	RANCHO CORDOVA	95670	CA	4	3	2109	Residential	Fri May 16 00:00:00 EDT 2008	330000	38.5805450000000008	-121.279015999999999
804	10254 JULIANA WAY	SACRAMENTO	95827	CA	4	2	2484	Residential	Fri May 16 00:00:00 EDT 2008	331200	38.5680300000000003	-121.309966000000003
805	149 OPUS CIR	SACRAMENTO	95834	CA	4	3	2258	Residential	Fri May 16 00:00:00 EDT 2008	332000	38.6353999999999971	-121.534989999999993
806	580 REGENCY PARK CIR	SACRAMENTO	95835	CA	3	3	2212	Residential	Fri May 16 00:00:00 EDT 2008	334000	38.6748639999999995	-121.495800000000003
807	5544 CAMAS CT	ORANGEVALE	95662	CA	3	2	1616	Residential	Fri May 16 00:00:00 EDT 2008	335000	38.667703000000003	-121.209456000000003
808	5102 ARCHCREST WAY	SACRAMENTO	95835	CA	4	2	2372	Residential	Fri May 16 00:00:00 EDT 2008	341000	38.6684100000000015	-121.494639000000006
809	5725 BALFOR RD	ROCKLIN	95765	CA	5	3	2606	Residential	Fri May 16 00:00:00 EDT 2008	346375	38.8078160000000025	-121.270008000000004
810	7697 ROSEHALL DR	ROSEVILLE	95678	CA	5	3	0	Residential	Fri May 16 00:00:00 EDT 2008	347225	38.7921800000000019	-121.28595
811	4821 HUTSON WAY	ELK GROVE	95757	CA	5	3	2877	Residential	Fri May 16 00:00:00 EDT 2008	349000	38.3862390000000033	-121.448159000000004
812	4509 WINJE DR	ANTELOPE	95843	CA	3	2	2960	Residential	Fri May 16 00:00:00 EDT 2008	350000	38.7095130000000012	-121.359357000000003
813	1965 LAURELHURST LN	LINCOLN	95648	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	350000	38.8538690000000031	-121.271742000000003
814	6709 ROSE BRIDGE DR	ROSEVILLE	95678	CA	3	2	2172	Residential	Fri May 16 00:00:00 EDT 2008	350000	38.792461000000003	-121.275711000000001
815	281 SPYGLASS HL	ROSEVILLE	95678	CA	3	2	2100	Condo	Fri May 16 00:00:00 EDT 2008	350000	38.7621529999999979	-121.283450999999999
816	7709 RIVER VILLAGE DR	SACRAMENTO	95831	CA	3	2	1795	Residential	Fri May 16 00:00:00 EDT 2008	351000	38.4832120000000018	-121.540189999999996
817	4165 BRISBANE CIR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	356200	38.6860670000000013	-121.073413000000002
818	506 BEDFORD CT	ROSEVILLE	95661	CA	4	2	2295	Residential	Fri May 16 00:00:00 EDT 2008	360000	38.733984999999997	-121.236766000000003
819	9048 PINTO CANYON WAY	ROSEVILLE	95747	CA	4	3	2577	Residential	Fri May 16 00:00:00 EDT 2008	367463	38.7924930000000003	-121.331899000000007
820	2274 IVY BRIDGE DR	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	375000	38.7785610000000034	-121.362008000000003
821	14004 WALNUT AVE	WALNUT GROVE	95690	CA	3	1	1727	Residential	Fri May 16 00:00:00 EDT 2008	380000	38.2476589999999987	-121.515129000000002
822	6905 FRANKFORT CT	ELK GROVE	95758	CA	3	2	1485	Residential	Fri May 16 00:00:00 EDT 2008	380578	38.4291389999999993	-121.423444000000003
823	3621 WINTUN DR	CARMICHAEL	95608	CA	3	2	1655	Residential	Fri May 16 00:00:00 EDT 2008	386222	38.6299289999999971	-121.323086000000004
824	201 KIRKLAND CT	LINCOLN	95648	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	389000	38.8671250000000015	-121.319085000000001
825	12075 APPLESBURY CT	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	390000	38.5356999999999985	-121.224900000000005
826	1975 SIDESADDLE WAY	ROSEVILLE	95661	CA	3	2	2049	Residential	Fri May 16 00:00:00 EDT 2008	395500	38.737872000000003	-121.249025000000003
827	5420 ALMOND FALLS WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	396000	38.5273839999999979	-121.233530999999999
828	9677 PILLITERI CT	ELK GROVE	95757	CA	5	3	2875	Residential	Fri May 16 00:00:00 EDT 2008	397000	38.4055710000000019	-121.445186000000007
829	1515 EL CAMINO VERDE DR	LINCOLN	95648	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	400000	38.9048689999999979	-121.320750000000004
830	556 PLATT CIR	EL DORADO HILLS	95762	CA	4	2	2199	Residential	Fri May 16 00:00:00 EDT 2008	400000	38.6562989999999971	-121.079783000000006
831	1792 DIAMOND WOODS CIR	ROSEVILLE	95747	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	412500	38.8085809999999967	-121.327849999999998
832	1124 PERKINS WAY	SACRAMENTO	95818	CA	2	1	1304	Residential	Fri May 16 00:00:00 EDT 2008	413500	38.5516110000000012	-121.504436999999996
833	4748 SALEM WAY	CARMICHAEL	95608	CA	3	2	2334	Residential	Fri May 16 00:00:00 EDT 2008	415000	38.6341109999999972	-121.353375999999997
834	1484 RADCLIFFE WAY	AUBURN	95603	CA	4	3	2278	Residential	Fri May 16 00:00:00 EDT 2008	420454	38.9355789999999971	-121.079018000000005
835	51 AIKEN WAY	SACRAMENTO	95819	CA	3	1	1493	Residential	Fri May 16 00:00:00 EDT 2008	425000	38.5793260000000018	-121.442520000000002
836	2818 KNOLLWOOD DR	CAMERON PARK	95682	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	425000	38.6698049999999967	-120.999007000000006
837	1536 STONEY CROSS LN	LINCOLN	95648	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	433500	38.8600070000000031	-121.310946000000001
838	509 CASTILLIAN CT	ROSEVILLE	95747	CA	5	3	0	Residential	Fri May 16 00:00:00 EDT 2008	438000	38.8047729999999973	-121.341194999999999
839	700 HUNTER PL	FOLSOM	95630	CA	5	3	2787	Residential	Fri May 16 00:00:00 EDT 2008	441000	38.6605100000000022	-121.163689000000005
840	1240 FAY CIR	SACRAMENTO	95831	CA	5	3	2824	Residential	Fri May 16 00:00:00 EDT 2008	445000	38.5063710000000015	-121.514455999999996
841	1113 SANDWICK WAY	FOLSOM	95630	CA	4	3	3261	Residential	Fri May 16 00:00:00 EDT 2008	446000	38.673881999999999	-121.105076999999994
842	3108 DELWOOD WAY	SACRAMENTO	95821	CA	4	2	2053	Residential	Fri May 16 00:00:00 EDT 2008	450000	38.6215660000000014	-121.370881999999995
843	3212 CORNICHE LN	ROSEVILLE	95661	CA	4	3	2379	Residential	Fri May 16 00:00:00 EDT 2008	455000	38.7505769999999998	-121.232767999999993
844	2159 BECKETT DR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	460000	38.6800920000000019	-121.036467000000002
845	4320 FOUR SEASONS RD	PLACERVILLE	95667	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	475000	38.6908669999999972	-120.693641
846	6401 MARSHALL RD	GARDEN VALLEY	95633	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	490000	38.8425500000000028	-120.875399999999999
847	2089 BECKETT DR	EL DORADO HILLS	95762	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	493000	38.6817780000000013	-121.035837999999998
848	6196 EDGEHILL DR	EL DORADO HILLS	95762	CA	5	4	0	Residential	Fri May 16 00:00:00 EDT 2008	508000	38.676130999999998	-121.038931000000005
849	200 HILLSFORD CT	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	511000	38.7800510000000003	-121.378718000000006
850	8217 PLUMERIA AVE	FAIR OAKS	95628	CA	3	2	3173	Residential	Fri May 16 00:00:00 EDT 2008	525000	38.6507349999999974	-121.258628000000002
851	4841 VILLAGE GREEN DR	EL DORADO HILLS	95762	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	533000	38.6640659999999983	-121.056735000000003
852	3863 LAS PASAS WAY	SACRAMENTO	95864	CA	3	1	1348	Residential	Fri May 16 00:00:00 EDT 2008	545000	38.5889359999999968	-121.373605999999995
853	820 DANA CT	AUBURN	95603	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	560000	38.8652459999999991	-121.094869000000003
854	1165 37TH ST	SACRAMENTO	95816	CA	2	1	1252	Residential	Fri May 16 00:00:00 EDT 2008	575000	38.5684380000000004	-121.457853999999998
855	203 CASCADE FALLS DR	FOLSOM	95630	CA	4	3	3229	Residential	Fri May 16 00:00:00 EDT 2008	575000	38.7039619999999971	-121.187100000000001
856	9880 IZILDA CT	SACRAMENTO	95829	CA	5	4	3863	Residential	Fri May 16 00:00:00 EDT 2008	598695	38.4532600000000002	-121.325729999999993
857	1800 AVONDALE DR	ROSEVILLE	95747	CA	5	3	0	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.7984480000000005	-121.344054
858	4620 BROMWICH CT	ROCKLIN	95677	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.772672	-121.220231999999996
859	620 KESWICK CT	GRANITE BAY	95746	CA	4	3	2356	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.7320959999999985	-121.219142000000005
860	4478 GREENBRAE RD	ROCKLIN	95677	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.7811340000000015	-121.222801000000004
861	8432 BRIGGS DR	ROSEVILLE	95747	CA	5	3	3579	Residential	Fri May 16 00:00:00 EDT 2008	610000	38.7886099999999985	-121.339494999999999
862	200 CRADLE MOUNTAIN CT	EL DORADO HILLS	95762	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	622500	38.6477999999999966	-121.030900000000003
863	2065 IMPRESSIONIST WAY	EL DORADO HILLS	95762	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	680000	38.6829609999999988	-121.033253000000002
864	2982 ABERDEEN LN	EL DORADO HILLS	95762	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	879000	38.7066919999999968	-121.058869000000001
865	9401 BARREL RACER CT	WILTON	95693	CA	4	3	4400	Residential	Fri May 16 00:00:00 EDT 2008	884790	38.4152979999999999	-121.194857999999996
866	3720 VISTA DE MADERA	LINCOLN	95648	CA	3	3	0	Residential	Fri May 16 00:00:00 EDT 2008	1551	38.8516449999999978	-121.231741999999997
867	14151 INDIO DR	SLOUGHHOUSE	95683	CA	3	4	5822	Residential	Fri May 16 00:00:00 EDT 2008	2000	38.4904470000000032	-121.129337000000007
868	7401 TOULON LN	SACRAMENTO	95828	CA	4	2	1512	Residential	Thu May 15 00:00:00 EDT 2008	56950	38.4886279999999985	-121.387759000000003
869	9127 NEWHALL DR Unit 34	SACRAMENTO	95826	CA	1	1	611	Condo	Thu May 15 00:00:00 EDT 2008	60000	38.5424190000000024	-121.359904
870	5937 BAMFORD DR	SACRAMENTO	95823	CA	2	1	876	Residential	Thu May 15 00:00:00 EDT 2008	61000	38.4711390000000009	-121.432254999999998
871	5672 HILLSDALE BLVD	SACRAMENTO	95842	CA	2	1	933	Condo	Thu May 15 00:00:00 EDT 2008	62000	38.6704670000000021	-121.359798999999995
872	3920 39TH ST	SACRAMENTO	95820	CA	2	1	864	Residential	Thu May 15 00:00:00 EDT 2008	68566	38.5392129999999966	-121.463930000000005
873	701 JESSIE AVE	SACRAMENTO	95838	CA	2	1	1011	Residential	Thu May 15 00:00:00 EDT 2008	70000	38.6439779999999971	-121.449562
874	83 ARCADE BLVD	SACRAMENTO	95815	CA	4	2	1158	Residential	Thu May 15 00:00:00 EDT 2008	80000	38.6187159999999992	-121.466327000000007
875	601 REGGINALD WAY	SACRAMENTO	95838	CA	3	2	1092	Residential	Thu May 15 00:00:00 EDT 2008	85500	38.6447199999999995	-121.452228000000005
876	550 DEL VERDE CIR	SACRAMENTO	95833	CA	2	1	956	Condo	Thu May 15 00:00:00 EDT 2008	92000	38.6271470000000008	-121.500799000000001
877	4113 DAYSTAR CT	SACRAMENTO	95824	CA	2	2	1139	Residential	Thu May 15 00:00:00 EDT 2008	93600	38.5204689999999985	-121.458606000000003
878	7374 TISDALE WAY	SACRAMENTO	95822	CA	3	1	1058	Residential	Thu May 15 00:00:00 EDT 2008	95000	38.4882380000000026	-121.472560999999999
879	3348 RIO LINDA BLVD	SACRAMENTO	95838	CA	3	2	1040	Residential	Thu May 15 00:00:00 EDT 2008	97750	38.6288419999999988	-121.446127000000004
880	3935 LIMESTONE WAY	SACRAMENTO	95823	CA	3	2	1354	Residential	Thu May 15 00:00:00 EDT 2008	104000	38.4843740000000025	-121.463156999999995
881	6208 GRATTAN WAY	NORTH HIGHLANDS	95660	CA	3	1	1051	Residential	Thu May 15 00:00:00 EDT 2008	105000	38.6792790000000011	-121.376615000000001
882	739 E WOODSIDE LN Unit E	SACRAMENTO	95825	CA	1	1	682	Condo	Thu May 15 00:00:00 EDT 2008	107666	38.5786749999999969	-121.409951000000007
883	4225 46TH AVE	SACRAMENTO	95824	CA	3	1	1161	Residential	Thu May 15 00:00:00 EDT 2008	109000	38.5118930000000006	-121.457676000000006
884	1434 BELL AVE	SACRAMENTO	95838	CA	3	1	1004	Residential	Thu May 15 00:00:00 EDT 2008	110000	38.6473980000000026	-121.432913999999997
885	5628 GEORGIA DR	NORTH HIGHLANDS	95660	CA	3	1	1229	Residential	Thu May 15 00:00:00 EDT 2008	110000	38.6695869999999999	-121.379879000000003
886	7629 BETH ST	SACRAMENTO	95832	CA	3	2	1249	Residential	Thu May 15 00:00:00 EDT 2008	112500	38.4801259999999985	-121.487869000000003
887	2277 BABETTE WAY	SACRAMENTO	95832	CA	3	2	1161	Residential	Thu May 15 00:00:00 EDT 2008	114800	38.4795930000000013	-121.484340000000003
888	6561 WEATHERFORD WAY	SACRAMENTO	95823	CA	3	1	1010	Residential	Thu May 15 00:00:00 EDT 2008	116000	38.4655509999999978	-121.426609999999997
889	3035 ESTEPA DR Unit 5C	CAMERON PARK	95682	CA	0	0	0	Condo	Thu May 15 00:00:00 EDT 2008	119000	38.6813929999999999	-120.996713
890	5136 CABOT CIR	SACRAMENTO	95820	CA	4	2	1462	Residential	Thu May 15 00:00:00 EDT 2008	121500	38.5284789999999973	-121.411805999999999
891	7730 ROBINETTE RD	SACRAMENTO	95828	CA	3	2	1269	Residential	Thu May 15 00:00:00 EDT 2008	122000	38.4770899999999969	-121.410568999999995
892	87 LACAM CIR	SACRAMENTO	95820	CA	2	2	1188	Residential	Thu May 15 00:00:00 EDT 2008	123675	38.5323589999999996	-121.411670000000001
893	1691 NOGALES ST	SACRAMENTO	95838	CA	4	2	1570	Residential	Thu May 15 00:00:00 EDT 2008	126854	38.6319250000000025	-121.427774999999997
894	3118 42ND ST	SACRAMENTO	95817	CA	3	2	1093	Residential	Thu May 15 00:00:00 EDT 2008	127059	38.546090999999997	-121.457745000000003
895	7517 50TH AVE	SACRAMENTO	95828	CA	3	1	962	Residential	Thu May 15 00:00:00 EDT 2008	128687	38.5073390000000018	-121.416267000000005
896	4071 EVALITA WAY	SACRAMENTO	95823	CA	3	2	1089	Residential	Thu May 15 00:00:00 EDT 2008	129500	38.466388000000002	-121.458860999999999
897	7928 36TH AVE	SACRAMENTO	95824	CA	3	2	1127	Residential	Thu May 15 00:00:00 EDT 2008	130000	38.5204900000000023	-121.411383000000001
898	6631 DEMARET DR	SACRAMENTO	95822	CA	4	2	1309	Residential	Thu May 15 00:00:00 EDT 2008	131750	38.5063820000000021	-121.483574000000004
899	7043 9TH AVE	RIO LINDA	95673	CA	2	1	970	Residential	Thu May 15 00:00:00 EDT 2008	132000	38.6955889999999982	-121.444132999999994
900	97 KENNELFORD CIR	SACRAMENTO	95823	CA	3	2	1144	Residential	Thu May 15 00:00:00 EDT 2008	134000	38.462375999999999	-121.426556000000005
901	2636 TRONERO WAY	RANCHO CORDOVA	95670	CA	3	1	1000	Residential	Thu May 15 00:00:00 EDT 2008	134000	38.5930490000000006	-121.303039999999996
902	1530 TOPANGA LN Unit 204	LINCOLN	95648	CA	0	0	0	Condo	Thu May 15 00:00:00 EDT 2008	138000	38.8841499999999982	-121.270276999999993
903	3604 KODIAK WAY	ANTELOPE	95843	CA	3	2	1206	Residential	Thu May 15 00:00:00 EDT 2008	142000	38.7061750000000018	-121.379776000000007
904	2149 COTTAGE WAY	SACRAMENTO	95825	CA	3	1	1285	Residential	Thu May 15 00:00:00 EDT 2008	143012	38.6035929999999965	-121.417011000000002
905	8632 PRAIRIEWOODS DR	SACRAMENTO	95828	CA	3	2	1543	Residential	Thu May 15 00:00:00 EDT 2008	145846	38.4775630000000035	-121.384382000000002
906	612 STONE BLVD	WEST SACRAMENTO	95691	CA	2	1	884	Residential	Thu May 15 00:00:00 EDT 2008	147000	38.5630840000000035	-121.535578999999998
907	4180 12TH AVE	SACRAMENTO	95817	CA	3	1	1019	Residential	Thu May 15 00:00:00 EDT 2008	148750	38.541170000000001	-121.458129
908	8025 ARROYO VISTA DR	SACRAMENTO	95823	CA	4	2	1392	Residential	Thu May 15 00:00:00 EDT 2008	150000	38.466540000000002	-121.419028999999995
909	5754 WALERGA RD Unit 4	SACRAMENTO	95842	CA	2	1	924	Condo	Thu May 15 00:00:00 EDT 2008	150454	38.6725670000000008	-121.356753999999995
910	8 LA ROCAS CT	SACRAMENTO	95823	CA	3	2	1217	Residential	Thu May 15 00:00:00 EDT 2008	151087	38.4661600000000021	-121.448283000000004
911	8636 LONGSPUR WAY	ANTELOPE	95843	CA	3	2	1670	Residential	Thu May 15 00:00:00 EDT 2008	157296	38.725873	-121.358559999999997
912	1941 EXPEDITION WAY	SACRAMENTO	95832	CA	3	2	1302	Residential	Thu May 15 00:00:00 EDT 2008	157500	38.4737750000000034	-121.493776999999994
913	4351 TURNBRIDGE DR	SACRAMENTO	95823	CA	3	2	1488	Residential	Thu May 15 00:00:00 EDT 2008	160000	38.5020340000000019	-121.456027000000006
914	6513 HOLIDAY WAY	NORTH HIGHLANDS	95660	CA	3	2	1373	Residential	Thu May 15 00:00:00 EDT 2008	160000	38.6853610000000003	-121.376937999999996
915	8321 MISTLETOE WAY	CITRUS HEIGHTS	95621	CA	4	2	1381	Residential	Thu May 15 00:00:00 EDT 2008	161250	38.7177379999999971	-121.308322000000004
916	5920 VALLEY GLEN WAY	SACRAMENTO	95823	CA	3	2	1265	Residential	Thu May 15 00:00:00 EDT 2008	164000	38.4628209999999982	-121.433134999999993
917	2601 SAN FERNANDO WAY	SACRAMENTO	95818	CA	2	1	881	Residential	Thu May 15 00:00:00 EDT 2008	165000	38.5561780000000027	-121.476256000000006
918	501 POPLAR AVE	WEST SACRAMENTO	95691	CA	0	0	0	Residential	Thu May 15 00:00:00 EDT 2008	165000	38.5845259999999968	-121.534609000000003
919	8008 SAINT HELENA CT	SACRAMENTO	95829	CA	4	2	1608	Residential	Thu May 15 00:00:00 EDT 2008	165750	38.4670119999999969	-121.359969000000007
920	6517 DONEGAL DR	CITRUS HEIGHTS	95621	CA	3	1	1344	Residential	Thu May 15 00:00:00 EDT 2008	166000	38.6815539999999984	-121.312933999999998
921	1001 RIO NORTE WAY	SACRAMENTO	95834	CA	3	2	1202	Residential	Thu May 15 00:00:00 EDT 2008	169000	38.6342920000000021	-121.485106000000002
922	604 P ST	LINCOLN	95648	CA	3	2	1104	Residential	Thu May 15 00:00:00 EDT 2008	170000	38.8931680000000028	-121.305397999999997
923	10001 WOODCREEK OAKS BLVD Unit 815	ROSEVILLE	95747	CA	2	2	0	Condo	Thu May 15 00:00:00 EDT 2008	170000	38.7955290000000019	-121.328818999999996
924	7351 GIGI PL	SACRAMENTO	95828	CA	4	2	1859	Multi-Family	Thu May 15 00:00:00 EDT 2008	170000	38.4906059999999997	-121.410173
925	7740 DIXIE LOU ST	SACRAMENTO	95832	CA	3	2	1232	Residential	Thu May 15 00:00:00 EDT 2008	170000	38.4758530000000007	-121.477039000000005
926	7342 DAVE ST	SACRAMENTO	95828	CA	3	1	1638	Residential	Thu May 15 00:00:00 EDT 2008	170725	38.4908220000000014	-121.401643000000007
927	7687 HOWERTON DR	SACRAMENTO	95831	CA	2	2	1177	Residential	Thu May 15 00:00:00 EDT 2008	171750	38.4808590000000024	-121.539744999999996
928	26 KAMSON CT	SACRAMENTO	95833	CA	3	2	1582	Residential	Thu May 15 00:00:00 EDT 2008	172000	38.622793999999999	-121.499172999999999
929	7045 PEEVEY CT	SACRAMENTO	95823	CA	2	2	904	Residential	Thu May 15 00:00:00 EDT 2008	173056	38.5022540000000006	-121.451443999999995
930	8916 GABLES MILL PL	ELK GROVE	95758	CA	3	2	1340	Residential	Thu May 15 00:00:00 EDT 2008	174000	38.4339190000000031	-121.422347000000002
931	1140 EDMONTON DR	SACRAMENTO	95833	CA	3	2	1204	Residential	Thu May 15 00:00:00 EDT 2008	174250	38.6245699999999985	-121.486913000000001
932	8879 APPLE PEAR CT	ELK GROVE	95624	CA	4	2	1477	Residential	Thu May 15 00:00:00 EDT 2008	176850	38.4457400000000007	-121.372500000000002
933	9 WIND CT	SACRAMENTO	95823	CA	4	2	1497	Residential	Thu May 15 00:00:00 EDT 2008	179500	38.4507300000000001	-121.427527999999995
934	8570 SHERATON DR	FAIR OAKS	95628	CA	3	1	960	Residential	Thu May 15 00:00:00 EDT 2008	185000	38.6672539999999998	-121.240707999999998
935	1550 TOPANGA LN Unit 207	LINCOLN	95648	CA	0	0	0	Condo	Thu May 15 00:00:00 EDT 2008	188000	38.8841699999999975	-121.270222000000004
936	1080 RIO NORTE WAY	SACRAMENTO	95834	CA	3	2	1428	Residential	Thu May 15 00:00:00 EDT 2008	188700	38.6343350000000001	-121.486097999999998
937	5501 VALLETTA WAY	SACRAMENTO	95820	CA	3	1	1039	Residential	Thu May 15 00:00:00 EDT 2008	189000	38.5301439999999999	-121.437489999999997
938	5624 MEMORY LN	FAIR OAKS	95628	CA	3	1	1529	Residential	Thu May 15 00:00:00 EDT 2008	189000	38.6674500000000023	-121.236400000000003
939	6622 WILLOWLEAF DR	CITRUS HEIGHTS	95621	CA	4	3	1892	Residential	Thu May 15 00:00:00 EDT 2008	189836	38.6997140000000002	-121.311634999999995
940	27 MEGAN CT	SACRAMENTO	95838	CA	4	2	1887	Residential	Thu May 15 00:00:00 EDT 2008	190000	38.6492580000000032	-121.465307999999993
941	6601 WOODMORE OAKS DR	ORANGEVALE	95662	CA	3	2	1294	Residential	Thu May 15 00:00:00 EDT 2008	191250	38.6870059999999967	-121.254318999999995
942	1973 DANVERS WAY	SACRAMENTO	95832	CA	3	2	1638	Residential	Thu May 15 00:00:00 EDT 2008	191675	38.477567999999998	-121.492574000000005
943	8001 ARROYO VISTA DR	SACRAMENTO	95823	CA	3	2	1677	Residential	Thu May 15 00:00:00 EDT 2008	195500	38.4673400000000001	-121.419843
944	7409 VOYAGER WAY	CITRUS HEIGHTS	95621	CA	3	1	1073	Residential	Thu May 15 00:00:00 EDT 2008	198000	38.7007169999999974	-121.313299999999998
945	815 CROSSWIND DR	SACRAMENTO	95838	CA	3	2	1231	Residential	Thu May 15 00:00:00 EDT 2008	200000	38.6513860000000022	-121.450419999999994
946	5509 LAGUNA CREST WAY	ELK GROVE	95758	CA	3	2	1175	Residential	Thu May 15 00:00:00 EDT 2008	200000	38.4244199999999978	-121.440357000000006
947	8424 MERRY HILL WAY	ELK GROVE	95624	CA	3	2	1416	Residential	Thu May 15 00:00:00 EDT 2008	200000	38.4520750000000007	-121.366461000000001
948	1525 PENNSYLVANIA AVE	WEST SACRAMENTO	95691	CA	0	0	0	Residential	Thu May 15 00:00:00 EDT 2008	200100	38.5699430000000021	-121.527539000000004
949	5954 BRIDGECROSS DR	SACRAMENTO	95835	CA	3	2	1358	Residential	Thu May 15 00:00:00 EDT 2008	201528	38.6819699999999997	-121.500024999999994
950	8789 SEQUOIA WOOD CT	ELK GROVE	95624	CA	4	2	1609	Residential	Thu May 15 00:00:00 EDT 2008	204750	38.4388179999999977	-121.374430000000004
951	6600 SILVERTHORNE CIR	SACRAMENTO	95842	CA	4	3	1968	Residential	Thu May 15 00:00:00 EDT 2008	205000	38.6860700000000008	-121.342369000000005
952	2221 2ND AVE	SACRAMENTO	95818	CA	2	2	1089	Residential	Thu May 15 00:00:00 EDT 2008	205000	38.5557810000000032	-121.485331000000002
953	3230 SMATHERS WAY	CARMICHAEL	95608	CA	3	2	1296	Residential	Thu May 15 00:00:00 EDT 2008	205900	38.6233720000000034	-121.347665000000006
954	5209 LAGUNA CREST WAY	ELK GROVE	95758	CA	2	2	1189	Residential	Thu May 15 00:00:00 EDT 2008	207000	38.4244210000000024	-121.443915000000004
955	416 LEITCH AVE	SACRAMENTO	95815	CA	2	1	795	Residential	Thu May 15 00:00:00 EDT 2008	207973	38.6126939999999976	-121.456669000000005
956	2100 BEATTY WAY	ROSEVILLE	95747	CA	3	2	1371	Residential	Thu May 15 00:00:00 EDT 2008	208250	38.737881999999999	-121.308142000000004
957	6920 GILLINGHAM WAY	NORTH HIGHLANDS	95660	CA	3	1	1310	Residential	Thu May 15 00:00:00 EDT 2008	208318	38.6942790000000016	-121.373395000000002
958	82 WILDFLOWER DR	GALT	95632	CA	3	2	1262	Residential	Thu May 15 00:00:00 EDT 2008	209347	38.2597080000000034	-121.311616000000001
959	8652 BANTON CIR	ELK GROVE	95624	CA	4	2	1740	Residential	Thu May 15 00:00:00 EDT 2008	211500	38.4440000000000026	-121.370992999999999
960	8428 MISTY PASS WAY	ANTELOPE	95843	CA	3	2	1517	Residential	Thu May 15 00:00:00 EDT 2008	212000	38.722959000000003	-121.347115000000002
961	7958 ROSEVIEW WAY	SACRAMENTO	95828	CA	3	2	1450	Residential	Thu May 15 00:00:00 EDT 2008	213000	38.4678359999999984	-121.410365999999996
962	9020 LUKEN CT	ELK GROVE	95624	CA	3	2	1416	Residential	Thu May 15 00:00:00 EDT 2008	216000	38.4513979999999975	-121.366613999999998
963	7809 VALLECITOS WAY	SACRAMENTO	95828	CA	3	1	888	Residential	Thu May 15 00:00:00 EDT 2008	216021	38.5082170000000019	-121.411207000000005
964	8445 OLD AUBURN RD	CITRUS HEIGHTS	95610	CA	3	2	1882	Residential	Thu May 15 00:00:00 EDT 2008	219000	38.7154230000000013	-121.246742999999995
965	10085 ATKINS DR	ELK GROVE	95757	CA	3	2	1302	Residential	Thu May 15 00:00:00 EDT 2008	219794	38.3908929999999984	-121.437821
966	9185 CERROLINDA CIR	ELK GROVE	95758	CA	3	2	1418	Residential	Thu May 15 00:00:00 EDT 2008	220000	38.4244970000000023	-121.426595000000006
967	9197 CORTINA CIR	ROSEVILLE	95678	CA	3	2	0	Condo	Thu May 15 00:00:00 EDT 2008	220000	38.7931519999999992	-121.290025
968	5429 HESPER WAY	CARMICHAEL	95608	CA	4	2	1319	Residential	Thu May 15 00:00:00 EDT 2008	220000	38.6651039999999995	-121.315900999999997
969	1178 WARMWOOD CT	GALT	95632	CA	4	2	1770	Residential	Thu May 15 00:00:00 EDT 2008	220000	38.2895439999999994	-121.284606999999994
970	4900 ELUDE CT	SACRAMENTO	95842	CA	4	2	1627	Residential	Thu May 15 00:00:00 EDT 2008	223000	38.6967399999999984	-121.350519000000006
971	3557 SODA WAY	SACRAMENTO	95834	CA	0	0	0	Residential	Thu May 15 00:00:00 EDT 2008	224000	38.6310259999999985	-121.501879000000002
972	3528 SAINT GEORGE DR	SACRAMENTO	95821	CA	3	1	1040	Residential	Thu May 15 00:00:00 EDT 2008	224000	38.6294680000000028	-121.376445000000004
973	7381 WASHBURN WAY	NORTH HIGHLANDS	95660	CA	3	1	960	Residential	Thu May 15 00:00:00 EDT 2008	224252	38.7035499999999999	-121.375102999999996
974	2181 WINTERHAVEN CIR	CAMERON PARK	95682	CA	3	2	0	Residential	Thu May 15 00:00:00 EDT 2008	224500	38.6975699999999989	-120.995739
975	7540 HICKORY AVE	ORANGEVALE	95662	CA	3	1	1456	Residential	Thu May 15 00:00:00 EDT 2008	225000	38.7030559999999966	-121.235220999999996
976	5024 CHAMBERLIN CIR	ELK GROVE	95757	CA	3	2	1450	Residential	Thu May 15 00:00:00 EDT 2008	228000	38.3897559999999984	-121.446246000000002
977	2400 INVERNESS DR	LINCOLN	95648	CA	3	2	1358	Residential	Thu May 15 00:00:00 EDT 2008	229027	38.8978139999999968	-121.324691000000001
978	5 BISHOPGATE CT	SACRAMENTO	95823	CA	4	2	1329	Residential	Thu May 15 00:00:00 EDT 2008	229500	38.4679360000000017	-121.445476999999997
979	5601 REXLEIGH DR	SACRAMENTO	95823	CA	4	2	1715	Residential	Thu May 15 00:00:00 EDT 2008	230000	38.4453419999999966	-121.441503999999995
980	1909 YARNELL WAY	ELK GROVE	95758	CA	3	2	1262	Residential	Thu May 15 00:00:00 EDT 2008	230000	38.4173820000000035	-121.484324999999998
981	9169 GARLINGTON CT	SACRAMENTO	95829	CA	4	3	2280	Residential	Thu May 15 00:00:00 EDT 2008	232425	38.4576789999999988	-121.359620000000007
982	6932 RUSKUT WAY	SACRAMENTO	95823	CA	3	2	1477	Residential	Thu May 15 00:00:00 EDT 2008	234000	38.4998930000000001	-121.458889999999997
983	7933 DAFFODIL WAY	CITRUS HEIGHTS	95610	CA	3	2	1216	Residential	Thu May 15 00:00:00 EDT 2008	235000	38.7088239999999999	-121.256803000000005
984	8304 RED FOX WAY	ELK GROVE	95758	CA	4	2	1685	Residential	Thu May 15 00:00:00 EDT 2008	235301	38.4170000000000016	-121.397424000000001
985	3882 YELLOWSTONE LN	EL DORADO HILLS	95762	CA	3	2	1362	Residential	Thu May 15 00:00:00 EDT 2008	235738	38.6552450000000007	-121.075914999999995
\.


--
-- Name: roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('roujygtyrqhmfikbpoitmwbwdwzkggki_id_seq', 985, true);


--
-- Data for Name: zhdfdidvufqquhhowjjjfksukvgqbibm; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY zhdfdidvufqquhhowjjjfksukvgqbibm (id, street, city, zip, state, beds, baths, sq__ft, type, sale_date, price, latitude, longitude) FROM stdin;
1	3526 HIGH ST	SACRAMENTO	95838	CA	2	1	836	Residential	Wed May 21 00:00:00 EDT 2008	59222	38.6319129999999973	-121.434878999999995
2	51 OMAHA CT	SACRAMENTO	95823	CA	3	1	1167	Residential	Wed May 21 00:00:00 EDT 2008	68212	38.4789019999999979	-121.431027999999998
3	2796 BRANCH ST	SACRAMENTO	95815	CA	2	1	796	Residential	Wed May 21 00:00:00 EDT 2008	68880	38.6183049999999994	-121.443838999999997
4	2805 JANETTE WAY	SACRAMENTO	95815	CA	2	1	852	Residential	Wed May 21 00:00:00 EDT 2008	69307	38.6168350000000018	-121.439145999999994
5	6001 MCMAHON DR	SACRAMENTO	95824	CA	2	1	797	Residential	Wed May 21 00:00:00 EDT 2008	81900	38.5194699999999983	-121.435767999999996
6	5828 PEPPERMILL CT	SACRAMENTO	95841	CA	3	1	1122	Condo	Wed May 21 00:00:00 EDT 2008	89921	38.6625950000000032	-121.327813000000006
7	6048 OGDEN NASH WAY	SACRAMENTO	95842	CA	3	2	1104	Residential	Wed May 21 00:00:00 EDT 2008	90895	38.6816590000000033	-121.351704999999995
8	2561 19TH AVE	SACRAMENTO	95820	CA	3	1	1177	Residential	Wed May 21 00:00:00 EDT 2008	91002	38.5350919999999988	-121.481367000000006
9	11150 TRINITY RIVER DR Unit 114	RANCHO CORDOVA	95670	CA	2	2	941	Condo	Wed May 21 00:00:00 EDT 2008	94905	38.6211879999999965	-121.270555000000002
10	7325 10TH ST	RIO LINDA	95673	CA	3	2	1146	Residential	Wed May 21 00:00:00 EDT 2008	98937	38.7009090000000029	-121.442978999999994
11	645 MORRISON AVE	SACRAMENTO	95838	CA	3	2	909	Residential	Wed May 21 00:00:00 EDT 2008	100309	38.6376630000000034	-121.451520000000002
12	4085 FAWN CIR	SACRAMENTO	95823	CA	3	2	1289	Residential	Wed May 21 00:00:00 EDT 2008	106250	38.4707459999999983	-121.458917999999997
13	2930 LA ROSA RD	SACRAMENTO	95815	CA	1	1	871	Residential	Wed May 21 00:00:00 EDT 2008	106852	38.618698000000002	-121.435833000000002
14	2113 KIRK WAY	SACRAMENTO	95822	CA	3	1	1020	Residential	Wed May 21 00:00:00 EDT 2008	107502	38.4822149999999965	-121.492603000000003
15	4533 LOCH HAVEN WAY	SACRAMENTO	95842	CA	2	2	1022	Residential	Wed May 21 00:00:00 EDT 2008	108750	38.6729139999999987	-121.359340000000003
16	7340 HAMDEN PL	SACRAMENTO	95842	CA	2	2	1134	Condo	Wed May 21 00:00:00 EDT 2008	110700	38.700051000000002	-121.351277999999994
17	6715 6TH ST	RIO LINDA	95673	CA	2	1	844	Residential	Wed May 21 00:00:00 EDT 2008	113263	38.6895910000000001	-121.452239000000006
18	6236 LONGFORD DR Unit 1	CITRUS HEIGHTS	95621	CA	2	1	795	Condo	Wed May 21 00:00:00 EDT 2008	116250	38.6797759999999968	-121.314088999999996
19	250 PERALTA AVE	SACRAMENTO	95833	CA	2	1	588	Residential	Wed May 21 00:00:00 EDT 2008	120000	38.6120990000000006	-121.469094999999996
20	113 LEEWILL AVE	RIO LINDA	95673	CA	3	2	1356	Residential	Wed May 21 00:00:00 EDT 2008	121630	38.6899990000000003	-121.463220000000007
21	6118 STONEHAND AVE	CITRUS HEIGHTS	95621	CA	3	2	1118	Residential	Wed May 21 00:00:00 EDT 2008	122000	38.707850999999998	-121.320706999999999
22	4882 BANDALIN WAY	SACRAMENTO	95823	CA	4	2	1329	Residential	Wed May 21 00:00:00 EDT 2008	122682	38.4681730000000002	-121.444070999999994
23	7511 OAKVALE CT	NORTH HIGHLANDS	95660	CA	4	2	1240	Residential	Wed May 21 00:00:00 EDT 2008	123000	38.7027920000000023	-121.382210000000001
24	9 PASTURE CT	SACRAMENTO	95834	CA	3	2	1601	Residential	Wed May 21 00:00:00 EDT 2008	124100	38.6286309999999986	-121.488096999999996
25	3729 BAINBRIDGE DR	NORTH HIGHLANDS	95660	CA	3	2	901	Residential	Wed May 21 00:00:00 EDT 2008	125000	38.7014989999999983	-121.376220000000004
26	3828 BLACKFOOT WAY	ANTELOPE	95843	CA	3	2	1088	Residential	Wed May 21 00:00:00 EDT 2008	126640	38.7097399999999965	-121.373769999999993
27	4108 NORTON WAY	SACRAMENTO	95820	CA	3	1	963	Residential	Wed May 21 00:00:00 EDT 2008	127281	38.5375259999999997	-121.478314999999995
28	1469 JANRICK AVE	SACRAMENTO	95832	CA	3	2	1119	Residential	Wed May 21 00:00:00 EDT 2008	129000	38.4764720000000011	-121.501711
29	9861 CULP WAY	SACRAMENTO	95827	CA	4	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	131200	38.5584229999999977	-121.327948000000006
30	7825 CREEK VALLEY CIR	SACRAMENTO	95828	CA	3	2	1248	Residential	Wed May 21 00:00:00 EDT 2008	132000	38.4721219999999988	-121.404199000000006
31	5201 LAGUNA OAKS DR Unit 140	ELK GROVE	95758	CA	2	2	1039	Condo	Wed May 21 00:00:00 EDT 2008	133000	38.4232510000000005	-121.444489000000004
32	6768 MEDORA DR	NORTH HIGHLANDS	95660	CA	3	2	1152	Residential	Wed May 21 00:00:00 EDT 2008	134555	38.691161000000001	-121.371920000000003
33	3100 EXPLORER DR	SACRAMENTO	95827	CA	3	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	136500	38.5666629999999984	-121.332644000000002
34	7944 DOMINION WAY	ELVERTA	95626	CA	3	2	1116	Residential	Wed May 21 00:00:00 EDT 2008	138750	38.7131820000000033	-121.411226999999997
35	5201 LAGUNA OAKS DR Unit 162	ELK GROVE	95758	CA	2	2	1039	Condo	Wed May 21 00:00:00 EDT 2008	141000	38.4232510000000005	-121.444489000000004
36	3920 SHINING STAR DR	SACRAMENTO	95823	CA	3	2	1418	Residential	Wed May 21 00:00:00 EDT 2008	146250	38.4874200000000002	-121.462458999999996
37	5031 CORVAIR ST	NORTH HIGHLANDS	95660	CA	3	2	1082	Residential	Wed May 21 00:00:00 EDT 2008	147308	38.6582459999999983	-121.375468999999995
38	7661 NIXOS WAY	SACRAMENTO	95823	CA	4	2	1472	Residential	Wed May 21 00:00:00 EDT 2008	148750	38.4795530000000028	-121.463317000000004
39	7044 CARTHY WAY	SACRAMENTO	95828	CA	4	2	1146	Residential	Wed May 21 00:00:00 EDT 2008	149593	38.4985700000000008	-121.420924999999997
40	2442 LARKSPUR LN	SACRAMENTO	95825	CA	1	1	760	Condo	Wed May 21 00:00:00 EDT 2008	150000	38.5851400000000027	-121.403735999999995
41	4800 WESTLAKE PKWY Unit 2109	SACRAMENTO	95835	CA	2	2	1304	Condo	Wed May 21 00:00:00 EDT 2008	152000	38.6588119999999975	-121.542344999999997
42	2178 63RD AVE	SACRAMENTO	95822	CA	3	2	1207	Residential	Wed May 21 00:00:00 EDT 2008	154000	38.4939549999999997	-121.489660000000001
43	8718 ELK WAY	ELK GROVE	95624	CA	3	2	1056	Residential	Wed May 21 00:00:00 EDT 2008	156896	38.4165300000000016	-121.379653000000005
44	5708 RIDGEPOINT DR	ANTELOPE	95843	CA	2	2	1043	Residential	Wed May 21 00:00:00 EDT 2008	161250	38.7202699999999993	-121.331554999999994
45	7315 KOALA CT	NORTH HIGHLANDS	95660	CA	4	2	1587	Residential	Wed May 21 00:00:00 EDT 2008	161500	38.6992509999999967	-121.371414000000001
46	2622 ERIN DR	SACRAMENTO	95833	CA	4	1	1120	Residential	Wed May 21 00:00:00 EDT 2008	164000	38.6137650000000008	-121.488693999999995
47	8421 SUNBLAZE WAY	SACRAMENTO	95823	CA	4	2	1580	Residential	Wed May 21 00:00:00 EDT 2008	165000	38.4505430000000032	-121.432537999999994
48	7420 ALIX PKWY	SACRAMENTO	95823	CA	4	1	1955	Residential	Wed May 21 00:00:00 EDT 2008	166357	38.4894049999999979	-121.452810999999997
49	3820 NATOMA WAY	SACRAMENTO	95838	CA	4	2	1656	Residential	Wed May 21 00:00:00 EDT 2008	166357	38.6367479999999972	-121.422158999999994
50	4431 GREEN TREE DR	SACRAMENTO	95823	CA	3	2	1477	Residential	Wed May 21 00:00:00 EDT 2008	168000	38.4999540000000025	-121.454469000000003
51	9417 SARA ST	ELK GROVE	95624	CA	3	2	1188	Residential	Wed May 21 00:00:00 EDT 2008	170000	38.4155179999999987	-121.370526999999996
52	8299 HALBRITE WAY	SACRAMENTO	95828	CA	4	2	1590	Residential	Wed May 21 00:00:00 EDT 2008	173000	38.4738139999999973	-121.400000000000006
53	7223 KALLIE KAY LN	SACRAMENTO	95823	CA	3	2	1463	Residential	Wed May 21 00:00:00 EDT 2008	174250	38.4775530000000003	-121.419462999999993
54	8156 STEINBECK WAY	SACRAMENTO	95828	CA	4	2	1714	Residential	Wed May 21 00:00:00 EDT 2008	174313	38.4748530000000031	-121.406326000000007
55	7957 VALLEY GREEN DR	SACRAMENTO	95823	CA	3	2	1185	Residential	Wed May 21 00:00:00 EDT 2008	178480	38.4651840000000007	-121.434925000000007
56	1122 WILD POPPY CT	GALT	95632	CA	3	2	1406	Residential	Wed May 21 00:00:00 EDT 2008	178760	38.2877889999999965	-121.294714999999997
57	4520 BOMARK WAY	SACRAMENTO	95842	CA	4	2	1943	Multi-Family	Wed May 21 00:00:00 EDT 2008	179580	38.6657239999999973	-121.358575999999999
58	9012 KIEFER BLVD	SACRAMENTO	95826	CA	3	2	1172	Residential	Wed May 21 00:00:00 EDT 2008	181000	38.5470109999999977	-121.366217000000006
59	5332 SANDSTONE ST	CARMICHAEL	95608	CA	3	1	1152	Residential	Wed May 21 00:00:00 EDT 2008	181872	38.6621049999999968	-121.313945000000004
60	5993 SAWYER CIR	SACRAMENTO	95823	CA	4	3	1851	Residential	Wed May 21 00:00:00 EDT 2008	182587	38.4472999999999985	-121.435218000000006
61	4844 CLYDEBANK WAY	ANTELOPE	95843	CA	3	2	1215	Residential	Wed May 21 00:00:00 EDT 2008	182716	38.7146090000000029	-121.347887
62	306 CAMELLIA WAY	GALT	95632	CA	3	2	1130	Residential	Wed May 21 00:00:00 EDT 2008	182750	38.2604430000000022	-121.297864000000004
63	9021 MADISON AVE	ORANGEVALE	95662	CA	4	2	1603	Residential	Wed May 21 00:00:00 EDT 2008	183200	38.6641860000000008	-121.217511000000002
64	404 6TH ST	GALT	95632	CA	3	1	1479	Residential	Wed May 21 00:00:00 EDT 2008	188741	38.2518079999999969	-121.302492999999998
65	8317 SUNNY CREEK WAY	SACRAMENTO	95823	CA	3	2	1420	Residential	Wed May 21 00:00:00 EDT 2008	189000	38.4590409999999991	-121.424644000000001
66	2617 BASS CT	SACRAMENTO	95826	CA	3	2	1280	Residential	Wed May 21 00:00:00 EDT 2008	192067	38.5607669999999985	-121.377471
67	7005 TIANT WAY	ELK GROVE	95758	CA	3	2	1586	Residential	Wed May 21 00:00:00 EDT 2008	194000	38.4228110000000029	-121.423285000000007
68	7895 CABER WAY	ANTELOPE	95843	CA	3	2	1362	Residential	Wed May 21 00:00:00 EDT 2008	194818	38.7112789999999976	-121.393449000000004
69	7624 BOGEY CT	SACRAMENTO	95828	CA	4	4	2162	Multi-Family	Wed May 21 00:00:00 EDT 2008	195000	38.480089999999997	-121.415102000000005
70	6930 HAMPTON COVE WAY	SACRAMENTO	95823	CA	3	2	1266	Residential	Wed May 21 00:00:00 EDT 2008	198000	38.4400400000000033	-121.421012000000005
71	8708 MESA BROOK WAY	ELK GROVE	95624	CA	4	2	1715	Residential	Wed May 21 00:00:00 EDT 2008	199500	38.4407599999999974	-121.385791999999995
72	120 GRANT LN	FOLSOM	95630	CA	3	2	1820	Residential	Wed May 21 00:00:00 EDT 2008	200000	38.6877420000000001	-121.171040000000005
73	5907 ELLERSLEE DR	CARMICHAEL	95608	CA	3	1	936	Residential	Wed May 21 00:00:00 EDT 2008	200000	38.6644679999999994	-121.326830000000001
74	17 SERASPI CT	SACRAMENTO	95834	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	206000	38.6314810000000008	-121.50188
75	170 PENHOW CIR	SACRAMENTO	95834	CA	3	2	1511	Residential	Wed May 21 00:00:00 EDT 2008	208000	38.6534389999999988	-121.535168999999996
76	8345 STAR THISTLE WAY	SACRAMENTO	95823	CA	4	2	1590	Residential	Wed May 21 00:00:00 EDT 2008	212864	38.4543490000000006	-121.439239000000001
77	9080 FRESCA WAY	ELK GROVE	95758	CA	4	2	1596	Residential	Wed May 21 00:00:00 EDT 2008	221000	38.427818000000002	-121.424025999999998
78	391 NATALINO CIR	SACRAMENTO	95835	CA	2	2	1341	Residential	Wed May 21 00:00:00 EDT 2008	221000	38.6730700000000027	-121.506372999999996
79	8373 BLACKMAN WAY	ELK GROVE	95624	CA	5	3	2136	Residential	Wed May 21 00:00:00 EDT 2008	223058	38.4354360000000028	-121.394536000000002
80	9837 CORTE DORADO CT	ELK GROVE	95624	CA	4	2	1616	Residential	Wed May 21 00:00:00 EDT 2008	227887	38.4006759999999971	-121.381010000000003
81	5037 J PKWY	SACRAMENTO	95823	CA	3	2	1478	Residential	Wed May 21 00:00:00 EDT 2008	231477	38.4913990000000013	-121.443546999999995
82	10245 LOS PALOS DR	RANCHO CORDOVA	95670	CA	3	2	1287	Residential	Wed May 21 00:00:00 EDT 2008	234697	38.5936990000000009	-121.310890000000001
83	6613 NAVION DR	CITRUS HEIGHTS	95621	CA	4	2	1277	Residential	Wed May 21 00:00:00 EDT 2008	235000	38.7028549999999996	-121.313079999999999
84	2887 AZEVEDO DR	SACRAMENTO	95833	CA	4	2	1448	Residential	Wed May 21 00:00:00 EDT 2008	236000	38.6184569999999994	-121.509439
85	9186 KINBRACE CT	SACRAMENTO	95829	CA	4	3	2235	Residential	Wed May 21 00:00:00 EDT 2008	236685	38.463355	-121.358936
86	4243 MIDDLEBURY WAY	MATHER	95655	CA	3	2	2093	Residential	Wed May 21 00:00:00 EDT 2008	237800	38.5479910000000032	-121.280483000000004
87	1028 FALLON PLACE CT	RIO LINDA	95673	CA	3	2	1193	Residential	Wed May 21 00:00:00 EDT 2008	240122	38.6938180000000003	-121.441153
88	4804 NORIKER DR	ELK GROVE	95757	CA	3	2	2163	Residential	Wed May 21 00:00:00 EDT 2008	242638	38.4009739999999979	-121.448424000000003
89	7713 HARVEST WOODS DR	SACRAMENTO	95828	CA	3	2	1269	Residential	Wed May 21 00:00:00 EDT 2008	244000	38.478197999999999	-121.412910999999994
90	2866 KARITSA AVE	SACRAMENTO	95833	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	244500	38.6266710000000018	-121.525970000000001
91	6913 RICHEVE WAY	SACRAMENTO	95828	CA	3	1	958	Residential	Wed May 21 00:00:00 EDT 2008	244960	38.5025189999999995	-121.420769000000007
92	8636 TEGEA WAY	ELK GROVE	95624	CA	5	3	2508	Residential	Wed May 21 00:00:00 EDT 2008	245918	38.4438320000000004	-121.382086999999999
93	5448 MAIDSTONE WAY	CITRUS HEIGHTS	95621	CA	3	2	1305	Residential	Wed May 21 00:00:00 EDT 2008	250000	38.6653949999999966	-121.293288000000004
94	18 OLLIE CT	ELK GROVE	95758	CA	4	2	1591	Residential	Wed May 21 00:00:00 EDT 2008	250000	38.4449090000000027	-121.412345000000002
95	4010 ALEX LN	CARMICHAEL	95608	CA	2	2	1326	Condo	Wed May 21 00:00:00 EDT 2008	250134	38.6370280000000008	-121.312962999999996
96	4901 MILLNER WAY	ELK GROVE	95757	CA	3	2	1843	Residential	Wed May 21 00:00:00 EDT 2008	254200	38.3869200000000035	-121.447349000000003
97	4818 BRITTNEY LEE CT	SACRAMENTO	95841	CA	4	2	1921	Residential	Wed May 21 00:00:00 EDT 2008	254200	38.6539169999999999	-121.342179999999999
98	5529 LAGUNA PARK DR	ELK GROVE	95758	CA	5	3	2790	Residential	Wed May 21 00:00:00 EDT 2008	258000	38.4256799999999998	-121.438062000000002
99	230 CANDELA CIR	SACRAMENTO	95835	CA	3	2	1541	Residential	Wed May 21 00:00:00 EDT 2008	260000	38.6562509999999975	-121.547572000000002
100	4900 71ST ST	SACRAMENTO	95820	CA	3	1	1018	Residential	Wed May 21 00:00:00 EDT 2008	260014	38.5315099999999973	-121.421088999999995
101	12209 CONSERVANCY WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	263500	38.5538669999999968	-121.219140999999993
102	4236 NATOMAS CENTRAL DR	SACRAMENTO	95834	CA	3	2	1672	Condo	Wed May 21 00:00:00 EDT 2008	265000	38.6488790000000009	-121.544022999999996
103	5615 LUPIN LN	POLLOCK PINES	95726	CA	3	2	1380	Residential	Wed May 21 00:00:00 EDT 2008	265000	38.7083149999999989	-120.603871999999996
104	5625 JAMES WAY	SACRAMENTO	95822	CA	3	1	975	Residential	Wed May 21 00:00:00 EDT 2008	271742	38.5239469999999997	-121.484945999999994
105	7842 LAHONTAN CT	SACRAMENTO	95829	CA	4	3	2372	Residential	Wed May 21 00:00:00 EDT 2008	273750	38.4729760000000027	-121.318633000000005
106	6850 21ST ST	SACRAMENTO	95822	CA	3	2	1446	Residential	Wed May 21 00:00:00 EDT 2008	275086	38.5021940000000029	-121.490795000000006
107	2900 BLAIR RD	POLLOCK PINES	95726	CA	2	2	1284	Residential	Wed May 21 00:00:00 EDT 2008	280908	38.7548499999999976	-120.604759999999999
108	2064 EXPEDITION WAY	SACRAMENTO	95832	CA	4	3	3009	Residential	Wed May 21 00:00:00 EDT 2008	280987	38.4740990000000025	-121.490711000000005
109	2912 NORCADE CIR	SACRAMENTO	95826	CA	8	4	3612	Multi-Family	Wed May 21 00:00:00 EDT 2008	282400	38.5595050000000015	-121.364839000000003
110	9507 SEA CLIFF WAY	ELK GROVE	95758	CA	4	2	2056	Residential	Wed May 21 00:00:00 EDT 2008	285000	38.4109920000000002	-121.479043000000004
111	8882 AUTUMN GOLD CT	ELK GROVE	95624	CA	4	2	1993	Residential	Wed May 21 00:00:00 EDT 2008	287417	38.4438999999999993	-121.372550000000004
112	5322 WHITE LOTUS WAY	ELK GROVE	95757	CA	3	2	1857	Residential	Wed May 21 00:00:00 EDT 2008	291000	38.3915379999999971	-121.442595999999995
113	1838 CASTRO WAY	SACRAMENTO	95818	CA	2	1	1126	Residential	Wed May 21 00:00:00 EDT 2008	292024	38.5560979999999986	-121.490786999999997
114	10158 CRAWFORD WAY	SACRAMENTO	95827	CA	4	4	2213	Multi-Family	Wed May 21 00:00:00 EDT 2008	297000	38.5703000000000031	-121.315735000000004
115	7731 MASTERS ST	ELK GROVE	95758	CA	5	3	2494	Residential	Wed May 21 00:00:00 EDT 2008	297000	38.4420310000000001	-121.410872999999995
116	4925 PERCHERON DR	ELK GROVE	95757	CA	3	2	1843	Residential	Wed May 21 00:00:00 EDT 2008	298000	38.4015399999999971	-121.447648999999998
117	2010 PROMONTORY POINT LN	GOLD RIVER	95670	CA	2	2	1520	Residential	Wed May 21 00:00:00 EDT 2008	299000	38.6286899999999989	-121.261668999999998
118	4727 SAVOIE WAY	SACRAMENTO	95835	CA	5	3	2800	Residential	Wed May 21 00:00:00 EDT 2008	304037	38.6581819999999965	-121.549520999999999
119	8664 MAGNOLIA HILL WAY	ELK GROVE	95624	CA	4	2	2309	Residential	Wed May 21 00:00:00 EDT 2008	311000	38.4423519999999996	-121.389674999999997
120	9570 HARVEST ROSE WAY	SACRAMENTO	95827	CA	5	3	2367	Residential	Wed May 21 00:00:00 EDT 2008	315537	38.5559930000000008	-121.340351999999996
121	4359 CREGAN CT	RANCHO CORDOVA	95742	CA	5	4	3516	Residential	Wed May 21 00:00:00 EDT 2008	320000	38.5451279999999983	-121.224922000000007
122	5337 DUSTY ROSE WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	320000	38.5285749999999965	-121.2286
123	8929 SUTTERS GOLD DR	SACRAMENTO	95826	CA	4	3	1914	Residential	Wed May 21 00:00:00 EDT 2008	328360	38.550848000000002	-121.370223999999993
124	8025 PEERLESS AVE	ORANGEVALE	95662	CA	2	1	1690	Residential	Wed May 21 00:00:00 EDT 2008	334150	38.7114699999999985	-121.216213999999994
125	4620 WELERA WAY	ELK GROVE	95757	CA	3	3	2725	Residential	Wed May 21 00:00:00 EDT 2008	335750	38.3986090000000004	-121.450147999999999
126	9723 TERRAPIN CT	ELK GROVE	95757	CA	4	3	2354	Residential	Wed May 21 00:00:00 EDT 2008	335750	38.403492	-121.430223999999995
127	2115 SMOKESTACK WAY	SACRAMENTO	95833	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	339500	38.6024159999999981	-121.542964999999995
128	100 REBECCA WAY	FOLSOM	95630	CA	3	2	2185	Residential	Wed May 21 00:00:00 EDT 2008	344250	38.6847899999999996	-121.149198999999996
129	9488 OAK VILLAGE WAY	ELK GROVE	95758	CA	4	2	1801	Residential	Wed May 21 00:00:00 EDT 2008	346210	38.413330000000002	-121.404999000000004
130	8495 DARTFORD DR	SACRAMENTO	95823	CA	3	3	1961	Residential	Wed May 21 00:00:00 EDT 2008	347029	38.4485069999999993	-121.421346
131	6708 PONTA DO SOL WAY	ELK GROVE	95757	CA	4	2	3134	Residential	Wed May 21 00:00:00 EDT 2008	347650	38.3806349999999981	-121.425538000000003
132	4143 SEA MEADOW WAY	SACRAMENTO	95823	CA	4	3	1915	Residential	Wed May 21 00:00:00 EDT 2008	351300	38.4653399999999976	-121.457519000000005
133	3020 RICHARDSON CIR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Wed May 21 00:00:00 EDT 2008	352000	38.6912990000000008	-121.081751999999994
134	8082 LINDA ISLE LN	SACRAMENTO	95831	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	370000	38.4772000000000034	-121.521500000000003
135	15300 MURIETA SOUTH PKWY	RANCHO MURIETA	95683	CA	4	3	2734	Residential	Wed May 21 00:00:00 EDT 2008	370500	38.4874000000000009	-121.075129000000004
136	11215 SHARRMONT CT	WILTON	95693	CA	3	2	2110	Residential	Wed May 21 00:00:00 EDT 2008	372000	38.3506199999999993	-121.228348999999994
137	7105 DANBERG WAY	ELK GROVE	95757	CA	5	3	3164	Residential	Wed May 21 00:00:00 EDT 2008	375000	38.4018999999999977	-121.420388000000003
138	5579 JERRY LITELL WAY	SACRAMENTO	95835	CA	5	3	3599	Residential	Wed May 21 00:00:00 EDT 2008	381300	38.6771260000000012	-121.500518999999997
139	1050 FOXHALL WAY	SACRAMENTO	95831	CA	4	2	2054	Residential	Wed May 21 00:00:00 EDT 2008	381942	38.5098190000000002	-121.519660999999999
140	7837 ABBINGTON WAY	ANTELOPE	95843	CA	4	2	1830	Residential	Wed May 21 00:00:00 EDT 2008	387731	38.7098730000000018	-121.339472000000001
141	1300 F ST	SACRAMENTO	95814	CA	3	3	1627	Residential	Wed May 21 00:00:00 EDT 2008	391000	38.5835500000000025	-121.487289000000004
142	6801 RAWLEY WAY	ELK GROVE	95757	CA	4	3	3440	Residential	Wed May 21 00:00:00 EDT 2008	394470	38.4083510000000032	-121.423924999999997
143	1693 SHELTER COVE DR	GREENWOOD	95635	CA	3	2	2846	Residential	Wed May 21 00:00:00 EDT 2008	395000	38.9453570000000013	-120.908822000000001
144	9361 WADDELL LN	ELK GROVE	95624	CA	4	3	2359	Residential	Wed May 21 00:00:00 EDT 2008	400186	38.4508289999999988	-121.349928000000006
145	10 SEA FOAM CT	SACRAMENTO	95831	CA	3	3	2052	Residential	Wed May 21 00:00:00 EDT 2008	415000	38.4878849999999986	-121.545946999999998
146	6945 RIO TEJO WAY	ELK GROVE	95757	CA	5	3	3433	Residential	Wed May 21 00:00:00 EDT 2008	425000	38.3856380000000001	-121.422616000000005
147	4186 TULIP PARK WAY	RANCHO CORDOVA	95742	CA	5	3	3615	Residential	Wed May 21 00:00:00 EDT 2008	430000	38.5506170000000026	-121.235259999999997
148	9278 DAIRY CT	ELK GROVE	95624	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	445000	38.420338000000001	-121.363757000000007
149	207 ORANGE BLOSSOM CIR Unit C	FOLSOM	95630	CA	5	3	2687	Residential	Wed May 21 00:00:00 EDT 2008	460000	38.6462730000000008	-121.175321999999994
150	6507 RIO DE ONAR WAY	ELK GROVE	95757	CA	4	3	2724	Residential	Wed May 21 00:00:00 EDT 2008	461000	38.3825300000000027	-121.428006999999994
151	7004 RAWLEY WAY	ELK GROVE	95757	CA	4	3	3440	Residential	Wed May 21 00:00:00 EDT 2008	489332	38.4064210000000017	-121.422081000000006
152	6503 RIO DE ONAR WAY	ELK GROVE	95757	CA	5	4	3508	Residential	Wed May 21 00:00:00 EDT 2008	510000	38.3825300000000027	-121.428038000000001
153	2217 APPALOOSA CT	FOLSOM	95630	CA	4	2	2462	Residential	Wed May 21 00:00:00 EDT 2008	539000	38.6551669999999987	-121.090177999999995
154	868 HILDEBRAND CIR	FOLSOM	95630	CA	0	0	0	Residential	Wed May 21 00:00:00 EDT 2008	585000	38.6709469999999982	-121.097727000000006
155	6030 PALERMO WAY	EL DORADO HILLS	95762	CA	4	3	0	Residential	Wed May 21 00:00:00 EDT 2008	600000	38.6727610000000013	-121.050377999999995
156	4070 REDONDO DR	EL DORADO HILLS	95762	CA	4	3	0	Residential	Wed May 21 00:00:00 EDT 2008	606238	38.6668069999999986	-121.064830000000001
157	4004 CRESTA WAY	SACRAMENTO	95864	CA	3	3	2325	Residential	Wed May 21 00:00:00 EDT 2008	660000	38.5916179999999969	-121.370626000000001
158	315 JUMEL CT	EL DORADO HILLS	95762	CA	6	5	0	Residential	Wed May 21 00:00:00 EDT 2008	830000	38.6699309999999983	-121.059579999999997
159	6272 LONGFORD DR Unit 1	CITRUS HEIGHTS	95621	CA	2	1	795	Condo	Tue May 20 00:00:00 EDT 2008	69000	38.6809229999999999	-121.313945000000004
160	3432 Y ST	SACRAMENTO	95817	CA	4	2	1099	Residential	Tue May 20 00:00:00 EDT 2008	70000	38.5549669999999978	-121.468046000000001
161	9512 EMERALD PARK DR Unit 3	ELK GROVE	95624	CA	2	1	840	Condo	Tue May 20 00:00:00 EDT 2008	71000	38.4057299999999984	-121.369832000000002
162	3132 CLAY ST	SACRAMENTO	95815	CA	2	1	800	Residential	Tue May 20 00:00:00 EDT 2008	78000	38.624678000000003	-121.439203000000006
163	5221 38TH AVE	SACRAMENTO	95824	CA	2	1	746	Residential	Tue May 20 00:00:00 EDT 2008	78400	38.5180440000000033	-121.443555000000003
164	6112 HERMOSA ST	SACRAMENTO	95822	CA	3	1	1067	Residential	Tue May 20 00:00:00 EDT 2008	80000	38.5151249999999976	-121.480416000000005
165	483 ARCADE BLVD	SACRAMENTO	95815	CA	4	2	1316	Residential	Tue May 20 00:00:00 EDT 2008	89000	38.6235709999999983	-121.454884000000007
166	671 SONOMA AVE	SACRAMENTO	95815	CA	3	1	1337	Residential	Tue May 20 00:00:00 EDT 2008	90000	38.6229530000000025	-121.450142
167	5980 79TH ST	SACRAMENTO	95824	CA	2	1	868	Residential	Tue May 20 00:00:00 EDT 2008	90000	38.5183729999999969	-121.411778999999996
168	7607 ELDER CREEK RD	SACRAMENTO	95824	CA	3	1	924	Residential	Tue May 20 00:00:00 EDT 2008	92000	38.5105500000000021	-121.414767999999995
169	5028 14TH AVE	SACRAMENTO	95820	CA	2	1	610	Residential	Tue May 20 00:00:00 EDT 2008	93675	38.5394199999999998	-121.446894
170	14788 NATCHEZ CT	RANCHO MURIETA	95683	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	97750	38.4922869999999975	-121.100031999999999
171	1069 ACACIA AVE	SACRAMENTO	95815	CA	2	1	1220	Residential	Tue May 20 00:00:00 EDT 2008	98000	38.6219979999999978	-121.442238000000003
172	5201 LAGUNA OAKS DR Unit 199	ELK GROVE	95758	CA	1	1	722	Condo	Tue May 20 00:00:00 EDT 2008	98000	38.4232510000000005	-121.444489000000004
173	3847 LAS PASAS WAY	SACRAMENTO	95864	CA	3	1	1643	Residential	Tue May 20 00:00:00 EDT 2008	99000	38.5886720000000025	-121.373915999999994
174	5201 LAGUNA OAKS DR Unit 172	ELK GROVE	95758	CA	1	1	722	Condo	Tue May 20 00:00:00 EDT 2008	100000	38.4232510000000005	-121.444489000000004
175	1121 CREEKSIDE WAY	GALT	95632	CA	3	1	1080	Residential	Tue May 20 00:00:00 EDT 2008	106716	38.2415140000000022	-121.312199000000007
176	5307 CABRILLO WAY	SACRAMENTO	95820	CA	3	1	1039	Residential	Tue May 20 00:00:00 EDT 2008	111000	38.5271199999999965	-121.435348000000005
177	3725 DON JULIO BLVD	NORTH HIGHLANDS	95660	CA	3	1	1051	Residential	Tue May 20 00:00:00 EDT 2008	111000	38.6789500000000004	-121.379406000000003
178	4803 MCCLOUD DR	SACRAMENTO	95842	CA	2	2	967	Residential	Tue May 20 00:00:00 EDT 2008	114800	38.6822790000000012	-121.352817000000002
179	10542 SILVERWOOD WAY	RANCHO CORDOVA	95670	CA	3	1	1098	Residential	Tue May 20 00:00:00 EDT 2008	120108	38.5871560000000002	-121.295777999999999
180	6318 39TH AVE	SACRAMENTO	95824	CA	3	1	1050	Residential	Tue May 20 00:00:00 EDT 2008	123225	38.5189420000000027	-121.430158000000006
181	211 MCDANIEL CIR	SACRAMENTO	95838	CA	3	2	1110	Residential	Tue May 20 00:00:00 EDT 2008	123750	38.6365649999999974	-121.460382999999993
182	3800 LYNHURST WAY	NORTH HIGHLANDS	95660	CA	3	1	888	Residential	Tue May 20 00:00:00 EDT 2008	125000	38.6504449999999977	-121.374860999999996
183	6139 HERMOSA ST	SACRAMENTO	95822	CA	3	2	1120	Residential	Tue May 20 00:00:00 EDT 2008	125000	38.5146650000000008	-121.480411000000004
184	2505 RHINE WAY	ELVERTA	95626	CA	3	2	1080	Residential	Tue May 20 00:00:00 EDT 2008	126000	38.7179760000000002	-121.407684000000003
185	3692 PAYNE WAY	NORTH HIGHLANDS	95660	CA	3	1	957	Residential	Tue May 20 00:00:00 EDT 2008	129000	38.6665399999999977	-121.378298000000001
186	604 MORRISON AVE	SACRAMENTO	95838	CA	2	1	952	Residential	Tue May 20 00:00:00 EDT 2008	134000	38.6376780000000011	-121.452476000000004
187	648 SANTA ANA AVE	SACRAMENTO	95838	CA	3	2	1211	Residential	Tue May 20 00:00:00 EDT 2008	135000	38.6584780000000023	-121.450408999999993
188	14 ASHLEY OAKS CT	SACRAMENTO	95815	CA	3	2	1264	Residential	Tue May 20 00:00:00 EDT 2008	135500	38.6177899999999994	-121.436764999999994
189	3174 NORTHVIEW DR	SACRAMENTO	95833	CA	3	1	1080	Residential	Tue May 20 00:00:00 EDT 2008	140000	38.6238170000000025	-121.477827000000005
190	840 TRANQUIL LN	GALT	95632	CA	3	2	1266	Residential	Tue May 20 00:00:00 EDT 2008	140000	38.2706170000000014	-121.299205000000001
191	5333 PRIMROSE DR Unit 19A	FAIR OAKS	95628	CA	2	2	994	Condo	Tue May 20 00:00:00 EDT 2008	142500	38.6627849999999995	-121.276272000000006
192	1035 MILLET WAY	SACRAMENTO	95834	CA	3	2	1202	Residential	Tue May 20 00:00:00 EDT 2008	143500	38.6310560000000009	-121.485079999999996
193	5201 LAGUNA OAKS DR Unit 126	ELK GROVE	95758	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	145000	38.4232510000000005	-121.444489000000004
194	3328 22ND AVE	SACRAMENTO	95820	CA	2	1	722	Residential	Tue May 20 00:00:00 EDT 2008	145000	38.5327270000000013	-121.470782999999997
195	8001 HARTWICK WAY	SACRAMENTO	95828	CA	4	2	1448	Residential	Tue May 20 00:00:00 EDT 2008	145000	38.4886229999999969	-121.410582000000005
196	7812 HARTWICK WAY	SACRAMENTO	95828	CA	3	2	1188	Residential	Tue May 20 00:00:00 EDT 2008	145000	38.4886109999999988	-121.412807999999998
197	4207 PAINTER WAY	NORTH HIGHLANDS	95660	CA	4	2	1183	Residential	Tue May 20 00:00:00 EDT 2008	146000	38.6929149999999993	-121.367497
198	7458 WINKLEY WAY	SACRAMENTO	95822	CA	3	1	1320	Residential	Tue May 20 00:00:00 EDT 2008	148500	38.4874440000000035	-121.491365999999999
199	8354 SUNRISE WOODS WAY	SACRAMENTO	95828	CA	3	2	1117	Residential	Tue May 20 00:00:00 EDT 2008	149000	38.4732879999999966	-121.396299999999997
200	8116 COTTONMILL CIR	SACRAMENTO	95828	CA	3	2	1364	Residential	Tue May 20 00:00:00 EDT 2008	150000	38.4828759999999974	-121.405912000000001
201	4660 CEDARWOOD WAY	SACRAMENTO	95823	CA	4	2	1310	Residential	Tue May 20 00:00:00 EDT 2008	150000	38.4848339999999993	-121.449315999999996
202	9254 HARROGATE WAY	ELK GROVE	95758	CA	2	2	1006	Residential	Tue May 20 00:00:00 EDT 2008	152000	38.4201380000000015	-121.412178999999995
203	6716 TAREYTON WAY	CITRUS HEIGHTS	95621	CA	3	2	1104	Residential	Tue May 20 00:00:00 EDT 2008	156000	38.6937240000000031	-121.307169000000002
204	2028 ROBERT WAY	SACRAMENTO	95825	CA	2	1	810	Residential	Tue May 20 00:00:00 EDT 2008	156000	38.6099820000000022	-121.419263000000001
205	9346 AIZENBERG CIR	ELK GROVE	95624	CA	2	2	1123	Residential	Tue May 20 00:00:00 EDT 2008	156000	38.4187500000000028	-121.370018999999999
206	4524 LOCH HAVEN WAY	SACRAMENTO	95842	CA	2	1	904	Residential	Tue May 20 00:00:00 EDT 2008	157788	38.6727300000000014	-121.359645
207	7140 BLUE SPRINGS WAY	CITRUS HEIGHTS	95621	CA	3	2	1156	Residential	Tue May 20 00:00:00 EDT 2008	161653	38.7206529999999987	-121.302240999999995
208	4631 11TH AVE	SACRAMENTO	95820	CA	2	1	1321	Residential	Tue May 20 00:00:00 EDT 2008	161829	38.5419649999999976	-121.452132000000006
209	3228 BAGGAN CT	ANTELOPE	95843	CA	3	2	1392	Residential	Tue May 20 00:00:00 EDT 2008	165000	38.7153459999999967	-121.388163000000006
210	8515 DARTFORD DR	SACRAMENTO	95823	CA	3	2	1439	Residential	Tue May 20 00:00:00 EDT 2008	168000	38.448287999999998	-121.420719000000005
211	4500 TIPPWOOD WAY	SACRAMENTO	95842	CA	3	2	1159	Residential	Tue May 20 00:00:00 EDT 2008	169000	38.6995099999999965	-121.359988999999999
212	2460 EL ROCCO WAY	RANCHO CORDOVA	95670	CA	3	2	1671	Residential	Tue May 20 00:00:00 EDT 2008	175000	38.5914769999999976	-121.315340000000006
213	8244 SUNBIRD WAY	SACRAMENTO	95823	CA	3	2	1740	Residential	Tue May 20 00:00:00 EDT 2008	176250	38.457653999999998	-121.431381000000002
214	5841 VALLEY VALE WAY	SACRAMENTO	95823	CA	3	2	1265	Residential	Tue May 20 00:00:00 EDT 2008	179000	38.4612830000000017	-121.434321999999995
215	7863 CRESTLEIGH CT	ANTELOPE	95843	CA	2	2	1007	Residential	Tue May 20 00:00:00 EDT 2008	180000	38.7108890000000017	-121.358875999999995
216	7129 SPRINGMONT DR	ELK GROVE	95758	CA	3	2	1716	Residential	Tue May 20 00:00:00 EDT 2008	180400	38.4176489999999973	-121.420293999999998
217	8284 RED FOX WAY	ELK GROVE	95758	CA	4	2	1685	Residential	Tue May 20 00:00:00 EDT 2008	182000	38.4171819999999968	-121.397231000000005
218	2219 EL CANTO CIR	RANCHO CORDOVA	95670	CA	4	2	1829	Residential	Tue May 20 00:00:00 EDT 2008	184500	38.5923829999999981	-121.318669
219	8907 GEMWOOD WAY	ELK GROVE	95758	CA	3	2	1555	Residential	Tue May 20 00:00:00 EDT 2008	185000	38.4354709999999997	-121.441173000000006
220	5925 MALEVILLE AVE	CARMICHAEL	95608	CA	4	2	1120	Residential	Tue May 20 00:00:00 EDT 2008	189000	38.666564000000001	-121.325716999999997
221	7031 CANEVALLEY CIR	CITRUS HEIGHTS	95621	CA	3	2	1137	Residential	Tue May 20 00:00:00 EDT 2008	194000	38.7186930000000018	-121.303618999999998
222	3949 WILDROSE WAY	SACRAMENTO	95826	CA	3	1	1174	Residential	Tue May 20 00:00:00 EDT 2008	195000	38.5436970000000017	-121.366682999999995
223	4437 MITCHUM CT	ANTELOPE	95843	CA	3	2	1393	Residential	Tue May 20 00:00:00 EDT 2008	200000	38.7044070000000033	-121.361130000000003
224	2778 KAWEAH CT	CAMERON PARK	95682	CA	3	1	0	Residential	Tue May 20 00:00:00 EDT 2008	201000	38.6940519999999992	-120.995588999999995
225	1636 ALLENWOOD CIR	LINCOLN	95648	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	202500	38.8791920000000033	-121.309477000000001
226	8151 QUAIL RIDGE CT	SACRAMENTO	95828	CA	3	2	1289	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.4612959999999973	-121.390857999999994
227	4899 WIND CREEK DR	SACRAMENTO	95838	CA	4	2	1799	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.6558869999999999	-121.446118999999996
228	2370 BIG CANYON CREEK RD	PLACERVILLE	95667	CA	3	2	0	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.7445799999999991	-120.794253999999995
229	6049 HAMBURG WAY	SACRAMENTO	95823	CA	4	3	1953	Residential	Tue May 20 00:00:00 EDT 2008	205000	38.4432529999999986	-121.431991999999994
230	4232 71ST ST	SACRAMENTO	95820	CA	2	1	723	Residential	Tue May 20 00:00:00 EDT 2008	207000	38.5367409999999992	-121.421149999999997
231	3361 BOW MAR CT	CAMERON PARK	95682	CA	2	2	0	Residential	Tue May 20 00:00:00 EDT 2008	210000	38.6943699999999993	-120.996601999999996
232	1889 COLD SPRINGS RD	PLACERVILLE	95667	CA	2	1	948	Residential	Tue May 20 00:00:00 EDT 2008	211500	38.739773999999997	-120.860242999999997
233	5805 HIMALAYA WAY	CITRUS HEIGHTS	95621	CA	4	2	1578	Residential	Tue May 20 00:00:00 EDT 2008	215000	38.6964889999999997	-121.328554999999994
234	7944 SYLVAN OAK WAY	CITRUS HEIGHTS	95610	CA	3	2	1317	Residential	Tue May 20 00:00:00 EDT 2008	215000	38.7103880000000018	-121.261095999999995
235	3139 SPOONWOOD WAY Unit 1	SACRAMENTO	95833	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	215500	38.6265819999999991	-121.521510000000006
236	6217 LEOLA WAY	SACRAMENTO	95824	CA	3	1	1360	Residential	Tue May 20 00:00:00 EDT 2008	222381	38.513066000000002	-121.451909000000001
237	2340 HURLEY WAY	SACRAMENTO	95825	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	225000	38.5888160000000013	-121.408548999999994
238	3035 BRUNNET LN	SACRAMENTO	95833	CA	3	2	1522	Residential	Tue May 20 00:00:00 EDT 2008	225000	38.6247619999999969	-121.522774999999996
239	3025 EL PRADO WAY	SACRAMENTO	95825	CA	4	2	1751	Residential	Tue May 20 00:00:00 EDT 2008	225000	38.6066029999999998	-121.394147000000004
240	9387 GRANITE FALLS CT	ELK GROVE	95624	CA	3	2	1465	Residential	Tue May 20 00:00:00 EDT 2008	225000	38.4192139999999966	-121.348533000000003
241	9257 CALDERA WAY	SACRAMENTO	95826	CA	4	2	1605	Residential	Tue May 20 00:00:00 EDT 2008	228000	38.5582100000000025	-121.355022000000005
242	441 ARLINGDALE CIR	RIO LINDA	95673	CA	4	2	1475	Residential	Tue May 20 00:00:00 EDT 2008	229665	38.7028930000000031	-121.454948999999999
243	2284 LOS ROBLES RD	MEADOW VISTA	95722	CA	3	1	1216	Residential	Tue May 20 00:00:00 EDT 2008	230000	39.0081589999999991	-121.036230000000003
244	8164 CHENIN BLANC LN	FAIR OAKS	95628	CA	2	2	1315	Residential	Tue May 20 00:00:00 EDT 2008	230000	38.6656440000000003	-121.259968999999998
245	4620 CHAMBERLIN CIR	ELK GROVE	95757	CA	3	2	1567	Residential	Tue May 20 00:00:00 EDT 2008	230000	38.3905570000000012	-121.449804999999998
246	5340 BIRK WAY	SACRAMENTO	95835	CA	3	2	1776	Residential	Tue May 20 00:00:00 EDT 2008	234000	38.6724949999999978	-121.515251000000006
247	51 ANJOU CIR	SACRAMENTO	95835	CA	3	2	2187	Residential	Tue May 20 00:00:00 EDT 2008	235000	38.6616580000000027	-121.540633
248	2125 22ND AVE	SACRAMENTO	95822	CA	3	1	1291	Residential	Tue May 20 00:00:00 EDT 2008	236250	38.5345960000000005	-121.493121000000002
249	611 BLOSSOM ROCK LN	FOLSOM	95630	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	240000	38.6456999999999979	-121.119699999999995
250	8830 ADUR RD	ELK GROVE	95624	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	242000	38.437420000000003	-121.372876000000005
251	7344 BUTTERBALL WAY	SACRAMENTO	95842	CA	3	2	1503	Residential	Tue May 20 00:00:00 EDT 2008	245000	38.6994889999999998	-121.361828000000003
252	8219 GWINHURST CIR	SACRAMENTO	95828	CA	4	3	2491	Residential	Tue May 20 00:00:00 EDT 2008	245000	38.4597109999999986	-121.384282999999996
253	3240 S ST	SACRAMENTO	95816	CA	2	1	1269	Residential	Tue May 20 00:00:00 EDT 2008	245000	38.5622960000000035	-121.467489
254	221 PICASSO CIR	SACRAMENTO	95835	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.6766580000000033	-121.528127999999995
255	5706 GREENACRES WAY	ORANGEVALE	95662	CA	3	2	1176	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.6698820000000012	-121.213532999999998
256	6900 LONICERA DR	ORANGEVALE	95662	CA	4	2	1456	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.6921990000000022	-121.250974999999997
257	419 DAWNRIDGE RD	ROSEVILLE	95678	CA	3	2	1498	Residential	Tue May 20 00:00:00 EDT 2008	250000	38.7252829999999975	-121.297953000000007
258	5312 MARBURY WAY	ANTELOPE	95843	CA	3	2	1574	Residential	Tue May 20 00:00:00 EDT 2008	255000	38.7102209999999971	-121.341650999999999
259	6344 BONHAM CIR	CITRUS HEIGHTS	95610	CA	5	4	2085	Multi-Family	Tue May 20 00:00:00 EDT 2008	256054	38.6823580000000007	-121.272875999999997
260	8207 YORKTON WAY	SACRAMENTO	95829	CA	3	2	2170	Residential	Tue May 20 00:00:00 EDT 2008	257729	38.4596700000000027	-121.360461000000001
261	7922 MANSELL WAY	ELK GROVE	95758	CA	4	2	1595	Residential	Tue May 20 00:00:00 EDT 2008	260000	38.4096339999999969	-121.410786999999999
262	5712 MELBURY CIR	ANTELOPE	95843	CA	3	2	1567	Residential	Tue May 20 00:00:00 EDT 2008	261000	38.7058490000000006	-121.334700999999995
263	632 NEWBRIDGE LN	LINCOLN	95648	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	261800	38.8790839999999989	-121.298586
264	1570 GLIDDEN AVE	SACRAMENTO	95822	CA	4	2	1253	Residential	Tue May 20 00:00:00 EDT 2008	264469	38.4827039999999982	-121.500433000000001
265	8108 FILIFERA WAY	ANTELOPE	95843	CA	4	3	1768	Residential	Tue May 20 00:00:00 EDT 2008	265000	38.7170419999999993	-121.354680000000002
266	230 BANKSIDE WAY	SACRAMENTO	95835	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6769370000000023	-121.529244000000006
267	5342 CALABRIA WAY	SACRAMENTO	95835	CA	4	3	2030	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6718070000000012	-121.498273999999995
268	47 NAPONEE CT	SACRAMENTO	95835	CA	3	2	1531	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6657039999999981	-121.529095999999996
269	4236 ADRIATIC SEA WAY	SACRAMENTO	95834	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	270000	38.6479610000000022	-121.543161999999995
270	8864 REMBRANT CT	ELK GROVE	95624	CA	4	3	1653	Residential	Tue May 20 00:00:00 EDT 2008	275000	38.4352879999999999	-121.375703000000001
271	9455 SEA CLIFF WAY	ELK GROVE	95758	CA	4	2	2056	Residential	Tue May 20 00:00:00 EDT 2008	275000	38.4115219999999979	-121.481406000000007
272	9720 LITTLE HARBOR WAY	ELK GROVE	95624	CA	4	3	2494	Residential	Tue May 20 00:00:00 EDT 2008	280000	38.4049339999999972	-121.352405000000005
273	8806 PHOENIX AVE	FAIR OAKS	95628	CA	3	2	1450	Residential	Tue May 20 00:00:00 EDT 2008	286013	38.6603220000000007	-121.230101000000005
274	3578 LOGGERHEAD WAY	SACRAMENTO	95834	CA	4	2	2169	Residential	Tue May 20 00:00:00 EDT 2008	292000	38.633028000000003	-121.526754999999994
275	1416 LOCKHART WAY	ROSEVILLE	95747	CA	3	2	1440	Residential	Tue May 20 00:00:00 EDT 2008	292000	38.7523989999999969	-121.330327999999994
276	5413 BUENA VENTURA WAY	FAIR OAKS	95628	CA	3	2	1527	Residential	Tue May 20 00:00:00 EDT 2008	293993	38.6645520000000005	-121.255937000000003
277	37 WHITE BIRCH CT	ROSEVILLE	95678	CA	3	2	1401	Residential	Tue May 20 00:00:00 EDT 2008	294000	38.776327000000002	-121.284514000000001
278	405 MARLIN SPIKE WAY	SACRAMENTO	95838	CA	3	2	1411	Residential	Tue May 20 00:00:00 EDT 2008	296769	38.657829999999997	-121.456841999999995
279	1102 CHESLEY LN	LINCOLN	95648	CA	4	4	0	Residential	Tue May 20 00:00:00 EDT 2008	297500	38.8648639999999972	-121.313987999999995
280	11281 STANFORD COURT LN Unit 604	GOLD RIVER	95670	CA	0	0	0	Condo	Tue May 20 00:00:00 EDT 2008	300000	38.6252890000000022	-121.260285999999994
281	7320 6TH ST	RIO LINDA	95673	CA	3	1	1284	Residential	Tue May 20 00:00:00 EDT 2008	300000	38.7005529999999993	-121.452223000000004
282	993 MANTON CT	GALT	95632	CA	4	3	2307	Residential	Tue May 20 00:00:00 EDT 2008	300000	38.2729420000000005	-121.289147999999997
283	4487 PANORAMA DR	PLACERVILLE	95667	CA	3	2	1329	Residential	Tue May 20 00:00:00 EDT 2008	300000	38.6945589999999982	-120.848157
284	5651 OVERLEAF WAY	SACRAMENTO	95835	CA	4	2	1910	Residential	Tue May 20 00:00:00 EDT 2008	300500	38.6774539999999973	-121.494791000000006
285	2015 PROMONTORY POINT LN	GOLD RIVER	95670	CA	3	2	1981	Residential	Tue May 20 00:00:00 EDT 2008	305000	38.6287319999999994	-121.261149000000003
286	3224 PARKHAM DR	ROSEVILLE	95747	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	306500	38.7727709999999988	-121.364877000000007
287	15 VANESSA PL	SACRAMENTO	95835	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	312500	38.6686920000000001	-121.545490000000001
288	1312 RENISON LN	LINCOLN	95648	CA	5	3	0	Residential	Tue May 20 00:00:00 EDT 2008	315000	38.8664089999999973	-121.308485000000005
289	8 RIVER RAFT CT	SACRAMENTO	95823	CA	4	2	2205	Residential	Tue May 20 00:00:00 EDT 2008	319789	38.4473529999999997	-121.434968999999995
290	2251 LAMPLIGHT LN	LINCOLN	95648	CA	2	2	1449	Residential	Tue May 20 00:00:00 EDT 2008	330000	38.8499240000000015	-121.275728999999998
291	106 FARHAM DR	FOLSOM	95630	CA	3	2	1258	Residential	Tue May 20 00:00:00 EDT 2008	330000	38.6678339999999992	-121.168577999999997
292	5405 NECTAR CIR	ELK GROVE	95757	CA	3	2	2575	Residential	Tue May 20 00:00:00 EDT 2008	331000	38.3870140000000006	-121.440967000000001
293	5411 10TH AVE	SACRAMENTO	95820	CA	2	1	539	Residential	Tue May 20 00:00:00 EDT 2008	334000	38.5427269999999993	-121.442448999999996
294	3512 RAINSONG CIR	RANCHO CORDOVA	95670	CA	4	3	2208	Residential	Tue May 20 00:00:00 EDT 2008	336000	38.5734879999999976	-121.282809
295	1106 55TH ST	SACRAMENTO	95819	CA	3	1	1108	Residential	Tue May 20 00:00:00 EDT 2008	339000	38.5638050000000021	-121.436395000000005
296	411 ILLSLEY WAY	FOLSOM	95630	CA	4	2	1595	Residential	Tue May 20 00:00:00 EDT 2008	339000	38.6520020000000031	-121.129503999999997
297	796 BUTTERCUP CIR	GALT	95632	CA	4	2	2159	Residential	Tue May 20 00:00:00 EDT 2008	345000	38.2795810000000003	-121.300827999999996
298	1230 SANDRA CIR	PLACERVILLE	95667	CA	4	3	2295	Residential	Tue May 20 00:00:00 EDT 2008	350000	38.7381409999999988	-120.784144999999995
299	318 ANACAPA DR	ROSEVILLE	95678	CA	3	2	1838	Residential	Tue May 20 00:00:00 EDT 2008	356000	38.7820940000000007	-121.297133000000002
300	3975 SHINING STAR DR	SACRAMENTO	95823	CA	4	2	1900	Residential	Tue May 20 00:00:00 EDT 2008	361745	38.4874089999999995	-121.461412999999993
301	1620 BASLER ST	SACRAMENTO	95811	CA	4	2	1718	Residential	Tue May 20 00:00:00 EDT 2008	361948	38.5918220000000005	-121.478644000000003
302	9688 NATURE TRAIL WAY	ELK GROVE	95757	CA	5	3	3389	Residential	Tue May 20 00:00:00 EDT 2008	370000	38.4052239999999969	-121.479275000000001
303	5924 TANUS CIR	ROCKLIN	95677	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	380000	38.778691000000002	-121.204291999999995
304	9629 CEDAR OAK WAY	ELK GROVE	95757	CA	5	4	3260	Residential	Tue May 20 00:00:00 EDT 2008	385000	38.4055269999999993	-121.431746000000004
305	3429 FERNBROOK CT	CAMERON PARK	95682	CA	3	2	2016	Residential	Tue May 20 00:00:00 EDT 2008	399000	38.6642250000000018	-121.007172999999995
306	2121 HANNAH WAY	ROCKLIN	95765	CA	4	2	2607	Residential	Tue May 20 00:00:00 EDT 2008	402000	38.8057489999999987	-121.280930999999995
307	10104 ANNIE ST	ELK GROVE	95757	CA	4	3	2724	Residential	Tue May 20 00:00:00 EDT 2008	406026	38.390464999999999	-121.443478999999996
308	1092 MAUGHAM CT	GALT	95632	CA	5	4	3746	Residential	Tue May 20 00:00:00 EDT 2008	420000	38.2716459999999969	-121.286848000000006
309	5404 ALMOND FALLS WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	425000	38.5275019999999984	-121.233491999999998
310	6306 CONEJO	RANCHO MURIETA	95683	CA	4	2	3192	Residential	Tue May 20 00:00:00 EDT 2008	425000	38.5126020000000011	-121.087232999999998
311	14 CASA VATONI PL	SACRAMENTO	95834	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	433500	38.6502210000000019	-121.551704000000001
312	1456 EAGLESFIELD LN	LINCOLN	95648	CA	4	3	0	Residential	Tue May 20 00:00:00 EDT 2008	436746	38.8576350000000019	-121.311374999999998
313	4100 BOTHWELL CIR	EL DORADO HILLS	95762	CA	5	3	0	Residential	Tue May 20 00:00:00 EDT 2008	438700	38.6791359999999997	-121.034329
314	427 21ST ST	SACRAMENTO	95811	CA	2	1	1247	Residential	Tue May 20 00:00:00 EDT 2008	445000	38.5826040000000035	-121.475759999999994
315	1044 GALSTON DR	FOLSOM	95630	CA	4	2	2581	Residential	Tue May 20 00:00:00 EDT 2008	450000	38.6763059999999967	-121.099540000000005
316	4440 SYCAMORE AVE	SACRAMENTO	95841	CA	3	1	2068	Residential	Tue May 20 00:00:00 EDT 2008	460000	38.6463740000000016	-121.353657999999996
317	1032 SOUZA DR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Tue May 20 00:00:00 EDT 2008	460000	38.6682389999999998	-121.064436999999998
318	9760 LAZULITE CT	ELK GROVE	95624	CA	4	3	3992	Residential	Tue May 20 00:00:00 EDT 2008	460000	38.403609000000003	-121.335541000000006
319	241 LANFRANCO CIR	SACRAMENTO	95835	CA	4	4	3397	Residential	Tue May 20 00:00:00 EDT 2008	465000	38.665695999999997	-121.549436999999998
320	5559 NORTHBOROUGH DR	SACRAMENTO	95835	CA	5	3	3881	Residential	Tue May 20 00:00:00 EDT 2008	471750	38.677225	-121.519687000000005
321	2125 BIG SKY DR	ROCKLIN	95765	CA	5	3	0	Residential	Tue May 20 00:00:00 EDT 2008	480000	38.8016369999999995	-121.278797999999995
322	2109 HAMLET PL	CARMICHAEL	95608	CA	2	2	1598	Residential	Tue May 20 00:00:00 EDT 2008	484000	38.6027539999999973	-121.329325999999995
323	9970 STATE HIGHWAY 193	PLACERVILLE	95667	CA	4	3	1929	Residential	Tue May 20 00:00:00 EDT 2008	485000	38.7878770000000017	-120.816676000000001
324	2901 PINTAIL WAY	ELK GROVE	95757	CA	4	3	3070	Residential	Tue May 20 00:00:00 EDT 2008	495000	38.3984880000000004	-121.473423999999994
325	201 FIRESTONE DR	ROSEVILLE	95678	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	500500	38.7701530000000005	-121.300038999999998
326	1740 HIGH ST	AUBURN	95603	CA	3	3	0	Residential	Tue May 20 00:00:00 EDT 2008	504000	38.8919349999999966	-121.084339999999997
327	2733 DANA LOOP	EL DORADO HILLS	95762	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	541000	38.6284589999999994	-121.055077999999995
328	9741 SADDLEBRED CT	WILTON	95693	CA	0	0	0	Residential	Tue May 20 00:00:00 EDT 2008	560000	38.4088410000000025	-121.198038999999994
329	7756 TIGERWOODS DR	SACRAMENTO	95829	CA	5	3	3984	Residential	Tue May 20 00:00:00 EDT 2008	572500	38.4764300000000006	-121.309242999999995
330	5709 RIVER OAK WAY	CARMICHAEL	95608	CA	4	2	2222	Residential	Tue May 20 00:00:00 EDT 2008	582000	38.6024609999999981	-121.330978999999999
331	2981 WRINGER DR	ROSEVILLE	95661	CA	4	3	3838	Residential	Tue May 20 00:00:00 EDT 2008	613401	38.7353730000000027	-121.227072000000007
332	8616 ROCKPORTE CT	ROSEVILLE	95747	CA	4	2	0	Residential	Tue May 20 00:00:00 EDT 2008	614000	38.7421179999999978	-121.359909000000002
333	4128 HILL ST	FAIR OAKS	95628	CA	5	5	2846	Residential	Tue May 20 00:00:00 EDT 2008	680000	38.6416699999999977	-121.262099000000006
334	1409 47TH ST	SACRAMENTO	95819	CA	5	2	2484	Residential	Tue May 20 00:00:00 EDT 2008	699000	38.5632439999999974	-121.446876000000003
335	3935 EL MONTE DR	LOOMIS	95650	CA	4	4	1624	Residential	Tue May 20 00:00:00 EDT 2008	839000	38.8133369999999971	-121.133347999999998
336	5840 WALERGA RD	SACRAMENTO	95842	CA	2	1	840	Condo	Mon May 19 00:00:00 EDT 2008	40000	38.6736780000000024	-121.357471000000004
337	923 FULTON AVE	SACRAMENTO	95825	CA	1	1	484	Condo	Mon May 19 00:00:00 EDT 2008	48000	38.5822789999999998	-121.401482000000001
338	261 REDONDO AVE	SACRAMENTO	95815	CA	3	1	970	Residential	Mon May 19 00:00:00 EDT 2008	61500	38.6206850000000017	-121.460538999999997
339	4030 BROADWAY	SACRAMENTO	95817	CA	2	1	623	Residential	Mon May 19 00:00:00 EDT 2008	62050	38.5467980000000026	-121.460037999999997
340	3660 22ND AVE	SACRAMENTO	95820	CA	2	1	932	Residential	Mon May 19 00:00:00 EDT 2008	65000	38.5327180000000027	-121.467470000000006
341	3924 HIGH ST	SACRAMENTO	95838	CA	2	1	796	Residential	Mon May 19 00:00:00 EDT 2008	65000	38.6387969999999967	-121.435049000000006
342	4734 14TH AVE	SACRAMENTO	95820	CA	2	1	834	Residential	Mon May 19 00:00:00 EDT 2008	68000	38.5394470000000027	-121.450857999999997
343	4734 14TH AVE	SACRAMENTO	95820	CA	2	1	834	Residential	Mon May 19 00:00:00 EDT 2008	68000	38.5394470000000027	-121.450857999999997
344	5050 RHODE ISLAND DR Unit 4	SACRAMENTO	95841	CA	2	1	924	Condo	Mon May 19 00:00:00 EDT 2008	77000	38.6587389999999971	-121.333561000000003
345	4513 GREENHOLME DR	SACRAMENTO	95842	CA	2	1	795	Condo	Mon May 19 00:00:00 EDT 2008	82732	38.6691039999999973	-121.359008000000003
346	3845 ELM ST	SACRAMENTO	95838	CA	3	1	1250	Residential	Mon May 19 00:00:00 EDT 2008	84000	38.6373370000000023	-121.432834999999997
347	3908 17TH AVE	SACRAMENTO	95820	CA	2	1	984	Residential	Mon May 19 00:00:00 EDT 2008	84675	38.5372800000000026	-121.463531000000003
348	7109 CHANDLER DR	SACRAMENTO	95828	CA	3	1	1013	Residential	Mon May 19 00:00:00 EDT 2008	85000	38.4972369999999984	-121.424187000000003
349	7541 SKELTON WAY	SACRAMENTO	95822	CA	3	1	1012	Residential	Mon May 19 00:00:00 EDT 2008	90000	38.4842739999999992	-121.488850999999997
350	9058 MONTOYA ST	SACRAMENTO	95826	CA	2	1	795	Condo	Mon May 19 00:00:00 EDT 2008	90000	38.5591440000000034	-121.368386999999998
351	1016 CONGRESS AVE	SACRAMENTO	95838	CA	2	2	918	Residential	Mon May 19 00:00:00 EDT 2008	91000	38.6301509999999979	-121.442789000000005
352	540 MORRISON AVE	SACRAMENTO	95838	CA	3	1	1082	Residential	Mon May 19 00:00:00 EDT 2008	95000	38.6377039999999994	-121.453946000000002
353	5303 JERRETT WAY	SACRAMENTO	95842	CA	2	1	964	Residential	Mon May 19 00:00:00 EDT 2008	97500	38.6632820000000024	-121.359630999999993
354	2820 DEL PASO BLVD	SACRAMENTO	95815	CA	4	2	1404	Multi-Family	Mon May 19 00:00:00 EDT 2008	100000	38.6177180000000035	-121.440089
355	3715 TALLYHO DR Unit 78HIGH	SACRAMENTO	95826	CA	1	1	625	Condo	Mon May 19 00:00:00 EDT 2008	100000	38.5446269999999984	-121.357960000000006
356	6013 ROWAN WAY	CITRUS HEIGHTS	95621	CA	2	1	888	Residential	Mon May 19 00:00:00 EDT 2008	101000	38.6758930000000021	-121.296300000000002
357	2987 PONDEROSA LN	SACRAMENTO	95815	CA	4	2	1120	Residential	Mon May 19 00:00:00 EDT 2008	102750	38.6222429999999974	-121.457863000000003
358	3732 LANKERSHIM WAY	NORTH HIGHLANDS	95660	CA	3	1	1331	Residential	Mon May 19 00:00:00 EDT 2008	112500	38.6897200000000012	-121.378399000000002
359	2216 DUNLAP DR	SACRAMENTO	95821	CA	3	1	1014	Residential	Mon May 19 00:00:00 EDT 2008	113000	38.623738000000003	-121.413049999999998
360	3503 21ST AVE	SACRAMENTO	95820	CA	4	2	1448	Residential	Mon May 19 00:00:00 EDT 2008	114000	38.533610000000003	-121.469307999999998
361	523 EXCHANGE ST	SACRAMENTO	95838	CA	3	1	966	Residential	Mon May 19 00:00:00 EDT 2008	114000	38.6594139999999982	-121.454080000000005
362	8101 PORT ROYALE WAY	SACRAMENTO	95823	CA	2	1	779	Residential	Mon May 19 00:00:00 EDT 2008	114750	38.4639290000000003	-121.438666999999995
363	8020 WALERGA RD	ANTELOPE	95843	CA	2	2	836	Condo	Mon May 19 00:00:00 EDT 2008	115000	38.716070000000002	-121.364468000000002
364	167 VALLEY OAK DR	ROSEVILLE	95678	CA	2	2	1100	Condo	Mon May 19 00:00:00 EDT 2008	115000	38.7324290000000033	-121.288068999999993
365	7876 BURLINGTON WAY	SACRAMENTO	95832	CA	3	1	1174	Residential	Mon May 19 00:00:00 EDT 2008	116100	38.4700929999999985	-121.468346999999994
366	3726 JONKO AVE	NORTH HIGHLANDS	95660	CA	3	2	1207	Residential	Mon May 19 00:00:00 EDT 2008	119250	38.656131000000002	-121.377264999999994
367	7342 GIGI PL	SACRAMENTO	95828	CA	4	4	1995	Multi-Family	Mon May 19 00:00:00 EDT 2008	120000	38.4907040000000009	-121.410176000000007
368	2610 PHYLLIS AVE	SACRAMENTO	95820	CA	2	1	804	Residential	Mon May 19 00:00:00 EDT 2008	120000	38.5310500000000005	-121.479574
369	4200 COMMERCE WAY Unit 711	SACRAMENTO	95834	CA	2	2	958	Condo	Mon May 19 00:00:00 EDT 2008	120000	38.6475229999999996	-121.523217000000002
370	4621 COUNTRY SCENE WAY	SACRAMENTO	95823	CA	3	2	1366	Residential	Mon May 19 00:00:00 EDT 2008	120108	38.4701870000000028	-121.448149000000001
371	5380 VILLAGE WOOD DR	SACRAMENTO	95823	CA	2	2	901	Residential	Mon May 19 00:00:00 EDT 2008	121500	38.4549489999999992	-121.440578000000002
372	2621 EVERGREEN ST	SACRAMENTO	95815	CA	3	1	696	Residential	Mon May 19 00:00:00 EDT 2008	121725	38.6131030000000024	-121.444085000000001
373	201 CARLO CT	GALT	95632	CA	3	2	1080	Residential	Mon May 19 00:00:00 EDT 2008	122000	38.2422699999999978	-121.310320000000004
374	6743 21ST ST	SACRAMENTO	95822	CA	3	2	1104	Residential	Mon May 19 00:00:00 EDT 2008	123000	38.5037200000000013	-121.490656999999999
375	3128 VIA GRANDE	SACRAMENTO	95825	CA	2	1	972	Residential	Mon May 19 00:00:00 EDT 2008	125000	38.5983209999999985	-121.39161
376	2847 BELGRADE WAY	SACRAMENTO	95833	CA	4	2	1390	Residential	Mon May 19 00:00:00 EDT 2008	125573	38.6171730000000011	-121.482540999999998
377	7741 MILLDALE CIR	ELVERTA	95626	CA	4	2	1354	Residential	Mon May 19 00:00:00 EDT 2008	126714	38.705834000000003	-121.439189999999996
378	9013 CASALS ST	SACRAMENTO	95826	CA	2	1	795	Condo	Mon May 19 00:00:00 EDT 2008	126960	38.5570450000000022	-121.371669999999995
379	227 MAHAN CT Unit 1	ROSEVILLE	95678	CA	2	1	780	Condo	Mon May 19 00:00:00 EDT 2008	127000	38.749723000000003	-121.270079999999993
380	7349 FLETCHER FARM DR	SACRAMENTO	95828	CA	4	2	1587	Residential	Mon May 19 00:00:00 EDT 2008	127500	38.4906900000000007	-121.382619000000005
381	7226 LARCHMONT DR	NORTH HIGHLANDS	95660	CA	3	2	1209	Residential	Mon May 19 00:00:00 EDT 2008	130000	38.699269000000001	-121.376334
382	4114 35TH AVE	SACRAMENTO	95824	CA	2	1	1139	Residential	Mon May 19 00:00:00 EDT 2008	133105	38.5209410000000005	-121.459355000000002
383	617 M ST	RIO LINDA	95673	CA	2	2	1690	Residential	Mon May 19 00:00:00 EDT 2008	136500	38.6911040000000028	-121.451831999999996
384	7032 FAIR OAKS BLVD	CARMICHAEL	95608	CA	3	2	1245	Condo	Mon May 19 00:00:00 EDT 2008	139500	38.6285629999999998	-121.328297000000006
385	2421 SANTINA WAY	ELVERTA	95626	CA	3	2	1416	Residential	Mon May 19 00:00:00 EDT 2008	140000	38.7186499999999967	-121.407763000000003
386	2368 CRAIG AVE	SACRAMENTO	95832	CA	3	2	1300	Residential	Mon May 19 00:00:00 EDT 2008	140800	38.4780700000000024	-121.481139999999996
387	2123 AMANDA WAY	SACRAMENTO	95822	CA	3	2	1120	Residential	Mon May 19 00:00:00 EDT 2008	145000	38.4848959999999991	-121.486947999999998
388	7620 DARLA WAY	SACRAMENTO	95828	CA	4	2	1590	Residential	Mon May 19 00:00:00 EDT 2008	147000	38.4785019999999989	-121.403516999999994
389	8344 FIELDPOPPY CIR	SACRAMENTO	95828	CA	3	2	1407	Residential	Mon May 19 00:00:00 EDT 2008	149600	38.4790830000000028	-121.400701999999995
390	3624 20TH AVE	SACRAMENTO	95820	CA	5	2	1516	Residential	Mon May 19 00:00:00 EDT 2008	150000	38.5345080000000024	-121.467906999999997
391	10001 WOODCREEK OAKS BLVD Unit 1415	ROSEVILLE	95747	CA	2	2	0	Condo	Mon May 19 00:00:00 EDT 2008	150000	38.7955290000000019	-121.328818999999996
392	2848 PROVO WAY	SACRAMENTO	95822	CA	3	2	1646	Residential	Mon May 19 00:00:00 EDT 2008	150000	38.4897589999999994	-121.474754000000004
393	6045 EHRHARDT AVE	SACRAMENTO	95823	CA	3	2	1676	Residential	Mon May 19 00:00:00 EDT 2008	155000	38.4571570000000023	-121.433064999999999
394	1223 LAMBERTON CIR	SACRAMENTO	95838	CA	3	2	1370	Residential	Mon May 19 00:00:00 EDT 2008	155435	38.6466769999999968	-121.437573
395	1223 LAMBERTON CIR	SACRAMENTO	95838	CA	3	2	1370	Residential	Mon May 19 00:00:00 EDT 2008	155500	38.6466769999999968	-121.437573
396	6000 BIRCHGLADE WAY	CITRUS HEIGHTS	95621	CA	4	2	1351	Residential	Mon May 19 00:00:00 EDT 2008	158000	38.7016599999999968	-121.323249000000004
397	7204 THOMAS DR	NORTH HIGHLANDS	95660	CA	3	2	1152	Residential	Mon May 19 00:00:00 EDT 2008	158000	38.6978980000000021	-121.377686999999995
398	8363 LANGTREE WAY	SACRAMENTO	95823	CA	3	2	1452	Residential	Mon May 19 00:00:00 EDT 2008	160000	38.4535600000000031	-121.435958999999997
399	1675 VERNON ST Unit 8	ROSEVILLE	95678	CA	2	1	990	Residential	Mon May 19 00:00:00 EDT 2008	160000	38.7341359999999995	-121.299638999999999
400	6632 IBEX WOODS CT	CITRUS HEIGHTS	95621	CA	2	2	1162	Residential	Mon May 19 00:00:00 EDT 2008	164000	38.720868000000003	-121.309854999999999
401	117 EVCAR WAY	RIO LINDA	95673	CA	3	2	1182	Residential	Mon May 19 00:00:00 EDT 2008	164000	38.6876589999999965	-121.463300000000004
402	6485 LAGUNA MIRAGE LN	ELK GROVE	95758	CA	2	2	1112	Residential	Mon May 19 00:00:00 EDT 2008	165000	38.4246499999999997	-121.430137000000002
403	746 MOOSE CREEK WAY	GALT	95632	CA	3	2	1100	Residential	Mon May 19 00:00:00 EDT 2008	167000	38.2830849999999998	-121.302070999999998
404	8306 CURLEW CT	CITRUS HEIGHTS	95621	CA	4	2	1280	Residential	Mon May 19 00:00:00 EDT 2008	167293	38.7157809999999998	-121.298518999999999
405	8306 CURLEW CT	CITRUS HEIGHTS	95621	CA	4	2	1280	Residential	Mon May 19 00:00:00 EDT 2008	167293	38.7157809999999998	-121.298518999999999
406	5217 ARGO WAY	SACRAMENTO	95820	CA	3	1	1039	Residential	Mon May 19 00:00:00 EDT 2008	168000	38.5277400000000014	-121.433668999999995
407	7108 HEATHER TREE DR	SACRAMENTO	95842	CA	3	2	1159	Residential	Mon May 19 00:00:00 EDT 2008	170000	38.6956770000000034	-121.360219999999998
408	2956 DAVENPORT WAY	SACRAMENTO	95833	CA	4	2	1917	Residential	Mon May 19 00:00:00 EDT 2008	170000	38.6206869999999967	-121.482619
409	10062 LINCOLN VILLAGE DR	SACRAMENTO	95827	CA	3	2	1520	Residential	Mon May 19 00:00:00 EDT 2008	170000	38.5640000000000001	-121.320023000000006
410	332 PALIN AVE	GALT	95632	CA	3	2	1204	Residential	Mon May 19 00:00:00 EDT 2008	174000	38.2604669999999984	-121.302636000000007
411	4649 FREEWAY CIR	SACRAMENTO	95841	CA	3	2	1120	Residential	Mon May 19 00:00:00 EDT 2008	178000	38.6587340000000026	-121.357196000000002
412	8593 DERLIN WAY	SACRAMENTO	95823	CA	3	2	1436	Residential	Mon May 19 00:00:00 EDT 2008	180000	38.4475849999999966	-121.426626999999996
413	9273 PREMIER WAY	SACRAMENTO	95826	CA	3	2	1451	Residential	Mon May 19 00:00:00 EDT 2008	180000	38.5599199999999982	-121.352538999999993
414	8032 DUSENBERG CT	SACRAMENTO	95828	CA	4	2	1638	Residential	Mon May 19 00:00:00 EDT 2008	180000	38.4664989999999989	-121.381118999999998
415	7110 STELLA LN Unit 15	CARMICHAEL	95608	CA	2	2	1000	Condo	Mon May 19 00:00:00 EDT 2008	182000	38.6373960000000025	-121.300055
416	1786 PIEDMONT WAY	ROSEVILLE	95661	CA	3	1	1152	Residential	Mon May 19 00:00:00 EDT 2008	188325	38.7274799999999999	-121.256536999999994
417	1347 HIDALGO CIR	ROSEVILLE	95747	CA	3	2	1154	Residential	Mon May 19 00:00:00 EDT 2008	191500	38.747878	-121.311278999999999
418	212 CAPPUCINO WAY	SACRAMENTO	95838	CA	3	2	1353	Residential	Mon May 19 00:00:00 EDT 2008	192000	38.6578110000000024	-121.465327000000002
419	5938 WOODBRIAR WAY	CITRUS HEIGHTS	95621	CA	3	2	1329	Residential	Mon May 19 00:00:00 EDT 2008	192700	38.706152000000003	-121.325399000000004
420	3801 WILDROSE WAY	SACRAMENTO	95826	CA	3	1	1356	Residential	Mon May 19 00:00:00 EDT 2008	195000	38.5443679999999986	-121.369979000000001
421	508 SAMUEL WAY	SACRAMENTO	95838	CA	3	2	1505	Residential	Mon May 19 00:00:00 EDT 2008	197654	38.6456889999999973	-121.452765999999997
422	6128 CARL SANDBURG CIR	SACRAMENTO	95842	CA	3	1	1009	Residential	Mon May 19 00:00:00 EDT 2008	198000	38.6815410000000028	-121.355615999999998
423	1 KENNELFORD CIR	SACRAMENTO	95823	CA	3	2	1144	Residential	Mon May 19 00:00:00 EDT 2008	200345	38.4645200000000003	-121.427605999999997
424	909 SINGINGWOOD RD	SACRAMENTO	95864	CA	2	1	930	Residential	Mon May 19 00:00:00 EDT 2008	203000	38.5814710000000005	-121.388390000000001
425	6671 FOXWOOD CT	SACRAMENTO	95841	CA	4	2	1766	Residential	Mon May 19 00:00:00 EDT 2008	207000	38.6879429999999971	-121.328883000000005
426	8165 AYN RAND CT	SACRAMENTO	95828	CA	4	3	1940	Residential	Mon May 19 00:00:00 EDT 2008	208000	38.4686390000000031	-121.403265000000005
427	9474 VILLAGE TREE DR	ELK GROVE	95758	CA	4	2	1776	Residential	Mon May 19 00:00:00 EDT 2008	210000	38.4139470000000003	-121.408276000000001
428	7213 CALVIN DR	CITRUS HEIGHTS	95621	CA	3	1	1258	Residential	Mon May 19 00:00:00 EDT 2008	212000	38.6981540000000024	-121.298374999999993
429	8167 DERBY PARK CT	SACRAMENTO	95828	CA	4	2	1872	Residential	Mon May 19 00:00:00 EDT 2008	213675	38.4604920000000021	-121.373379
430	6344 LAGUNA MIRAGE LN	ELK GROVE	95758	CA	2	2	1112	Residential	Mon May 19 00:00:00 EDT 2008	213697	38.4239630000000005	-121.428875000000005
431	2945 RED HAWK WAY	SACRAMENTO	95833	CA	4	2	1856	Residential	Mon May 19 00:00:00 EDT 2008	215000	38.6196750000000009	-121.496903000000003
432	3228 I ST	SACRAMENTO	95816	CA	4	3	1939	Residential	Mon May 19 00:00:00 EDT 2008	215000	38.5738440000000011	-121.462839000000002
433	308 ATKINSON ST	ROSEVILLE	95678	CA	3	1	998	Residential	Mon May 19 00:00:00 EDT 2008	215100	38.7467940000000013	-121.299710000000005
434	624 HOVEY WAY	ROSEVILLE	95678	CA	3	2	1758	Residential	Mon May 19 00:00:00 EDT 2008	217500	38.7561490000000006	-121.306478999999996
435	110 COPPER LEAF WAY	SACRAMENTO	95838	CA	3	2	2142	Residential	Mon May 19 00:00:00 EDT 2008	218000	38.6584659999999971	-121.460661000000002
436	7535 ALMA VISTA WAY	SACRAMENTO	95831	CA	2	1	950	Residential	Mon May 19 00:00:00 EDT 2008	220000	38.4840299999999971	-121.507641000000007
437	7423 WILSALL CT	ELK GROVE	95758	CA	4	3	1739	Residential	Mon May 19 00:00:00 EDT 2008	221000	38.4170259999999999	-121.416820999999999
438	8629 VIA ALTA WAY	ELK GROVE	95624	CA	3	2	1516	Residential	Mon May 19 00:00:00 EDT 2008	222900	38.3982450000000028	-121.380615000000006
439	3318 DAVIDSON DR	ANTELOPE	95843	CA	3	1	988	Residential	Mon May 19 00:00:00 EDT 2008	223139	38.7057530000000014	-121.388917000000006
440	913 COBDEN CT	GALT	95632	CA	4	2	1555	Residential	Mon May 19 00:00:00 EDT 2008	225500	38.2820010000000011	-121.295901999999998
441	4419 79TH ST	SACRAMENTO	95820	CA	3	2	1212	Residential	Mon May 19 00:00:00 EDT 2008	228327	38.5348269999999999	-121.412544999999994
442	3012 SPOONWOOD WAY	SACRAMENTO	95833	CA	4	2	1871	Residential	Mon May 19 00:00:00 EDT 2008	230000	38.6247800000000012	-121.523473999999993
443	8728 CRYSTAL RIVER WAY	SACRAMENTO	95828	CA	3	2	1302	Residential	Mon May 19 00:00:00 EDT 2008	230000	38.4754700000000014	-121.380054999999999
444	4709 AMBER LN Unit 1	SACRAMENTO	95841	CA	2	1	756	Condo	Mon May 19 00:00:00 EDT 2008	230522	38.6577890000000011	-121.354994000000005
445	4508 OLD DAIRY DR	ANTELOPE	95843	CA	4	3	2026	Residential	Mon May 19 00:00:00 EDT 2008	231200	38.7228599999999972	-121.358939000000007
446	312 RIVER ISLE WAY	SACRAMENTO	95831	CA	3	2	1375	Residential	Mon May 19 00:00:00 EDT 2008	232000	38.4902599999999993	-121.550527000000002
447	301 OLIVADI WAY	SACRAMENTO	95834	CA	2	2	1250	Condo	Mon May 19 00:00:00 EDT 2008	232500	38.6444059999999965	-121.549048999999997
448	5636 25TH ST	SACRAMENTO	95822	CA	3	1	1058	Residential	Mon May 19 00:00:00 EDT 2008	233641	38.5238280000000017	-121.481138999999999
449	8721 SPRUCE RIDGE WAY	ANTELOPE	95843	CA	3	2	1187	Residential	Mon May 19 00:00:00 EDT 2008	234000	38.7276570000000007	-121.391028000000006
450	7461 WINDBRIDGE DR	SACRAMENTO	95831	CA	2	2	1324	Residential	Mon May 19 00:00:00 EDT 2008	234500	38.4879699999999971	-121.530229000000006
451	8101 LEMON COVE CT	SACRAMENTO	95828	CA	4	3	1936	Residential	Mon May 19 00:00:00 EDT 2008	235000	38.4629809999999992	-121.408287999999999
452	10949 SCOTSMAN WAY	RANCHO CORDOVA	95670	CA	5	4	2382	Multi-Family	Mon May 19 00:00:00 EDT 2008	236000	38.6036860000000033	-121.277844000000002
453	617 WILLOW CREEK DR	FOLSOM	95630	CA	3	2	1427	Residential	Mon May 19 00:00:00 EDT 2008	236073	38.679625999999999	-121.142608999999993
454	3301 PARK DR Unit 1914	SACRAMENTO	95835	CA	3	2	1678	Condo	Mon May 19 00:00:00 EDT 2008	238000	38.6652959999999979	-121.531993
455	709 CIMMARON CT	GALT	95632	CA	4	2	1798	Residential	Mon May 19 00:00:00 EDT 2008	238861	38.2771770000000018	-121.303747000000001
456	3305 RIO ROCA CT	ANTELOPE	95843	CA	4	3	2652	Residential	Mon May 19 00:00:00 EDT 2008	239700	38.7250790000000009	-121.387698
457	9080 BEDROCK CT	SACRAMENTO	95829	CA	4	2	1816	Residential	Mon May 19 00:00:00 EDT 2008	240000	38.4569389999999984	-121.362965000000003
458	100 TOURMALINE CIR	SACRAMENTO	95834	CA	5	3	3076	Residential	Mon May 19 00:00:00 EDT 2008	240000	38.634369999999997	-121.510778999999999
459	6411 RED BIRCH WAY	ELK GROVE	95758	CA	4	2	1844	Residential	Mon May 19 00:00:00 EDT 2008	241000	38.4346099999999993	-121.429316
460	4867 LAGUNA DR	SACRAMENTO	95823	CA	3	2	1306	Residential	Mon May 19 00:00:00 EDT 2008	245000	38.4617900000000006	-121.445370999999994
461	3662 RIVER DR	SACRAMENTO	95833	CA	4	3	2447	Residential	Mon May 19 00:00:00 EDT 2008	246000	38.604968999999997	-121.542550000000006
462	6943 WOLFGRAM WAY	SACRAMENTO	95828	CA	4	2	1176	Residential	Mon May 19 00:00:00 EDT 2008	247234	38.4892150000000015	-121.419545999999997
463	77 RINETTI WAY	RIO LINDA	95673	CA	4	2	1182	Residential	Mon May 19 00:00:00 EDT 2008	247480	38.6870210000000014	-121.463150999999996
464	1316 I ST	RIO LINDA	95673	CA	3	1	1160	Residential	Mon May 19 00:00:00 EDT 2008	249862	38.6836740000000034	-121.435203999999999
465	2130 CATHERWOOD WAY	SACRAMENTO	95835	CA	3	2	1424	Residential	Mon May 19 00:00:00 EDT 2008	251000	38.6755059999999986	-121.510987
466	8304 JUGLANS DR	ORANGEVALE	95662	CA	4	2	1574	Residential	Mon May 19 00:00:00 EDT 2008	252155	38.6918289999999985	-121.249032999999997
467	5308 MARBURY WAY	ANTELOPE	95843	CA	3	2	1830	Residential	Mon May 19 00:00:00 EDT 2008	254172	38.7102209999999971	-121.341707
468	9182 LAKEMONT DR	ELK GROVE	95624	CA	4	2	1724	Residential	Mon May 19 00:00:00 EDT 2008	258000	38.4513529999999975	-121.358776000000006
469	2231 COUNTRY VILLA CT	AUBURN	95603	CA	2	2	1255	Condo	Mon May 19 00:00:00 EDT 2008	260000	38.9316710000000015	-121.097862000000006
470	8491 CRYSTAL WALK CIR	ELK GROVE	95758	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	261000	38.4169160000000005	-121.407554000000005
471	361 MAHONIA CIR	SACRAMENTO	95835	CA	4	3	2175	Residential	Mon May 19 00:00:00 EDT 2008	261000	38.6761720000000011	-121.509760999999997
472	3427 LA CADENA WAY	SACRAMENTO	95835	CA	4	2	1904	Residential	Mon May 19 00:00:00 EDT 2008	261000	38.6811939999999979	-121.537351000000001
473	955 BIG SUR CT	EL DORADO HILLS	95762	CA	4	2	1808	Residential	Mon May 19 00:00:00 EDT 2008	262500	38.6643469999999994	-121.076528999999994
474	11826 DIONYSUS WAY	RANCHO CORDOVA	95742	CA	4	2	2711	Residential	Mon May 19 00:00:00 EDT 2008	266000	38.5510459999999995	-121.239411000000004
475	5847 DEL CAMPO LN	CARMICHAEL	95608	CA	3	1	1713	Residential	Mon May 19 00:00:00 EDT 2008	266000	38.6719950000000026	-121.324338999999995
476	5635 FOXVIEW WAY	ELK GROVE	95757	CA	3	2	1457	Residential	Mon May 19 00:00:00 EDT 2008	270000	38.3952560000000034	-121.438248999999999
477	10372 VIA CINTA CT	ELK GROVE	95757	CA	4	3	2724	Residential	Mon May 19 00:00:00 EDT 2008	274425	38.3800889999999981	-121.428185999999997
478	6286 LONETREE BLVD	ROCKLIN	95765	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	274500	38.8050360000000012	-121.293608000000006
479	7744 SOUTHBREEZE DR	SACRAMENTO	95828	CA	3	2	1468	Residential	Mon May 19 00:00:00 EDT 2008	275336	38.4769319999999979	-121.378349
480	2242 ABLE WAY	SACRAMENTO	95835	CA	4	3	2550	Residential	Mon May 19 00:00:00 EDT 2008	277980	38.6660740000000018	-121.509743
481	1042 STARBROOK DR	GALT	95632	CA	4	2	1928	Residential	Mon May 19 00:00:00 EDT 2008	280000	38.2856110000000029	-121.293063000000004
482	1219 G ST	SACRAMENTO	95814	CA	3	3	1922	Residential	Mon May 19 00:00:00 EDT 2008	284686	38.5828180000000032	-121.489096000000004
483	6220 OPUS CT	CITRUS HEIGHTS	95621	CA	3	2	1343	Residential	Mon May 19 00:00:00 EDT 2008	284893	38.7158530000000027	-121.317094999999995
484	5419 HAVENHURST CIR	ROCKLIN	95677	CA	3	2	1510	Residential	Mon May 19 00:00:00 EDT 2008	285000	38.7867460000000008	-121.209957000000003
485	220 OLD AIRPORT RD	AUBURN	95603	CA	2	2	960	Multi-Family	Mon May 19 00:00:00 EDT 2008	285000	38.9398020000000002	-121.054575
486	4622 MEYER WAY	CARMICHAEL	95608	CA	4	2	1559	Residential	Mon May 19 00:00:00 EDT 2008	285000	38.6491299999999995	-121.310666999999995
487	4885 SUMMIT VIEW DR	EL DORADO	95623	CA	3	2	1624	Residential	Mon May 19 00:00:00 EDT 2008	289000	38.6732849999999999	-120.879176000000001
488	26 JEANROSS CT	SACRAMENTO	95832	CA	5	3	2992	Residential	Mon May 19 00:00:00 EDT 2008	295000	38.4731620000000021	-121.491084999999998
489	4800 MAPLEPLAIN AVE	ELK GROVE	95758	CA	4	2	2109	Residential	Mon May 19 00:00:00 EDT 2008	296000	38.4328479999999999	-121.449236999999997
490	10629 BASIE WAY	RANCHO CORDOVA	95670	CA	4	2	1524	Residential	Mon May 19 00:00:00 EDT 2008	296056	38.5790000000000006	-121.292626999999996
491	8612 WILLOW GROVE WAY	SACRAMENTO	95828	CA	3	2	1248	Residential	Mon May 19 00:00:00 EDT 2008	297359	38.4649939999999972	-121.386961999999997
492	62 DE FER CIR	SACRAMENTO	95823	CA	4	2	1876	Residential	Mon May 19 00:00:00 EDT 2008	299940	38.4925399999999982	-121.463316000000006
493	2513 OLD KENMARE RD	LINCOLN	95648	CA	5	3	0	Residential	Mon May 19 00:00:00 EDT 2008	304000	38.8473960000000034	-121.259585999999999
494	3253 ABOTO WAY	RANCHO CORDOVA	95670	CA	4	3	1851	Residential	Mon May 19 00:00:00 EDT 2008	305000	38.5772699999999986	-121.285590999999997
495	3072 VILLAGE PLAZA DR	ROSEVILLE	95747	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	307000	38.7730940000000004	-121.365904999999998
496	251 CHANGO CIR	SACRAMENTO	95835	CA	4	2	2218	Residential	Mon May 19 00:00:00 EDT 2008	311328	38.6823699999999988	-121.539147
497	8205 WEYBURN CT	SACRAMENTO	95828	CA	3	2	1394	Residential	Mon May 19 00:00:00 EDT 2008	313138	38.47316	-121.403892999999997
498	8788 LA MARGARITA WAY	SACRAMENTO	95828	CA	3	2	1410	Residential	Mon May 19 00:00:00 EDT 2008	316630	38.4681849999999983	-121.375693999999996
499	5912 DEEPDALE WAY	ELK GROVE	95758	CA	5	3	3468	Residential	Mon May 19 00:00:00 EDT 2008	320000	38.4395650000000018	-121.436605999999998
500	4712 PISMO BEACH DR	ANTELOPE	95843	CA	5	3	2346	Residential	Mon May 19 00:00:00 EDT 2008	320000	38.7077049999999971	-121.354152999999997
501	4741 PACIFIC PARK DR	ANTELOPE	95843	CA	5	3	2347	Residential	Mon May 19 00:00:00 EDT 2008	325000	38.7092990000000015	-121.353055999999995
502	310 GROTH CIR	SACRAMENTO	95834	CA	4	2	1659	Residential	Mon May 19 00:00:00 EDT 2008	328578	38.6387640000000019	-121.531827000000007
503	6121 WILD FOX CT	ELK GROVE	95757	CA	3	3	2442	Residential	Mon May 19 00:00:00 EDT 2008	331000	38.4067580000000035	-121.431668999999999
504	12241 CANYONLANDS DR	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	331500	38.5572930000000014	-121.217611000000005
505	29 COOL FOUNTAIN CT	SACRAMENTO	95833	CA	4	2	2155	Residential	Mon May 19 00:00:00 EDT 2008	340000	38.6069060000000022	-121.541319999999999
506	907 RIO ROBLES AVE	SACRAMENTO	95838	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	344755	38.6647650000000027	-121.445006000000006
507	8909 BILLFISH WAY	SACRAMENTO	95828	CA	3	2	1810	Residential	Mon May 19 00:00:00 EDT 2008	345746	38.4754330000000024	-121.372584000000003
508	6232 GUS WAY	ELK GROVE	95757	CA	4	2	2789	Residential	Mon May 19 00:00:00 EDT 2008	351000	38.3881289999999993	-121.431169999999995
509	200 OAKWILDE ST	GALT	95632	CA	4	2	1606	Residential	Mon May 19 00:00:00 EDT 2008	353767	38.2535000000000025	-121.318119999999993
510	1033 PARK STREAM DR	GALT	95632	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	355000	38.2877849999999995	-121.289902999999995
511	200 ALLAIRE CIR	SACRAMENTO	95835	CA	4	2	2166	Residential	Mon May 19 00:00:00 EDT 2008	356035	38.6831800000000001	-121.534840000000003
512	1322 SUTTER WALK	SACRAMENTO	95816	CA	0	0	0	Condo	Mon May 19 00:00:00 EDT 2008	360000	38.5380499999999984	-121.5047
513	5479 NICKMAN WAY	SACRAMENTO	95835	CA	4	2	1871	Residential	Mon May 19 00:00:00 EDT 2008	360552	38.6729660000000024	-121.502747999999997
514	2103 BURBERRY WAY	SACRAMENTO	95835	CA	3	2	1800	Residential	Mon May 19 00:00:00 EDT 2008	362305	38.6734200000000001	-121.508542000000006
515	2450 SAN JOSE WAY	SACRAMENTO	95817	CA	3	1	1683	Residential	Mon May 19 00:00:00 EDT 2008	365000	38.5535959999999989	-121.459483000000006
516	7641 ROSEHALL DR	ROSEVILLE	95678	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	367554	38.7916170000000022	-121.286147
517	1336 LAYSAN TEAL DR	ROSEVILLE	95747	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	368500	38.7961209999999994	-121.319963000000001
518	2802 BLACK OAK DR	ROCKLIN	95765	CA	2	2	1596	Residential	Mon May 19 00:00:00 EDT 2008	370000	38.8370060000000024	-121.232023999999996
519	2113 FALL TRAIL CT	PLACERVILLE	95667	CA	4	2	0	Residential	Mon May 19 00:00:00 EDT 2008	371086	38.7331549999999964	-120.748039000000006
520	10112 LAMBEAU CT	ELK GROVE	95757	CA	3	2	1179	Residential	Mon May 19 00:00:00 EDT 2008	378000	38.3903279999999967	-121.448021999999995
521	6313 CASTRO VERDE WAY	ELK GROVE	95757	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	383000	38.3811019999999985	-121.429010000000005
522	3622 CURTIS DR	SACRAMENTO	95818	CA	3	1	1639	Residential	Mon May 19 00:00:00 EDT 2008	388000	38.5417350000000027	-121.480097999999998
523	11817 OPAL RIDGE WAY	RANCHO CORDOVA	95742	CA	5	3	3281	Residential	Mon May 19 00:00:00 EDT 2008	395100	38.5510829999999984	-121.237476000000001
524	170 LAGOMARSINO WAY	SACRAMENTO	95819	CA	3	2	1697	Residential	Mon May 19 00:00:00 EDT 2008	400000	38.5748940000000005	-121.435805999999999
525	2743 DEAKIN PL	EL DORADO HILLS	95762	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	400000	38.6928800000000024	-121.073550999999995
526	3361 ALDER CANYON WAY	ANTELOPE	95843	CA	4	3	2085	Residential	Mon May 19 00:00:00 EDT 2008	408431	38.7276489999999995	-121.385655999999997
527	2148 RANCH VIEW DR	ROCKLIN	95765	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	413000	38.8374549999999985	-121.289337000000003
528	398 LINDLEY DR	SACRAMENTO	95815	CA	4	2	1744	Multi-Family	Mon May 19 00:00:00 EDT 2008	416767	38.622359000000003	-121.457582000000002
529	3013 BRIDLEWOOD DR	EL DORADO HILLS	95762	CA	4	3	0	Residential	Mon May 19 00:00:00 EDT 2008	420000	38.6755190000000013	-121.015861999999998
530	169 BAURER CIR	FOLSOM	95630	CA	4	3	1939	Residential	Mon May 19 00:00:00 EDT 2008	423000	38.6669499999999999	-121.120728999999997
531	2809 LOON CT	CAMERON PARK	95682	CA	4	2	0	Residential	Mon May 19 00:00:00 EDT 2008	423000	38.6870720000000006	-121.004728999999998
532	1315 KONDOS AVE	SACRAMENTO	95814	CA	2	3	1788	Residential	Mon May 19 00:00:00 EDT 2008	427500	38.5719429999999974	-121.492106000000007
533	4966 CHARTER RD	ROCKLIN	95765	CA	3	2	1691	Residential	Mon May 19 00:00:00 EDT 2008	430922	38.8255300000000005	-121.254698000000005
534	9516 LAGUNA LAKE WAY	ELK GROVE	95758	CA	4	2	2002	Residential	Mon May 19 00:00:00 EDT 2008	445000	38.4112579999999966	-121.431348
535	5201 BLOSSOM RANCH DR	ELK GROVE	95757	CA	4	4	4303	Residential	Mon May 19 00:00:00 EDT 2008	450000	38.3994360000000015	-121.444040999999999
536	3027 PALMATE WAY	SACRAMENTO	95834	CA	5	3	4246	Residential	Mon May 19 00:00:00 EDT 2008	452000	38.6289549999999977	-121.529268999999999
537	500 WINCHESTER CT	ROSEVILLE	95661	CA	3	2	2274	Residential	Mon May 19 00:00:00 EDT 2008	470000	38.7398799999999994	-121.248929000000004
538	5746 GELSTON WAY	EL DORADO HILLS	95762	CA	4	3	0	Residential	Mon May 19 00:00:00 EDT 2008	471000	38.6770149999999973	-121.034082999999995
539	6935 ELM TREE LN	ORANGEVALE	95662	CA	4	4	3056	Residential	Mon May 19 00:00:00 EDT 2008	475000	38.6930410000000009	-121.232939999999999
540	9605 GOLF COURSE LN	ELK GROVE	95758	CA	3	3	2503	Residential	Mon May 19 00:00:00 EDT 2008	484500	38.4096890000000002	-121.446059000000005
541	719 BAYWOOD CT	EL DORADO HILLS	95762	CA	5	3	0	Residential	Mon May 19 00:00:00 EDT 2008	487500	38.6475980000000021	-121.077800999999994
542	5954 TANUS CIR	ROCKLIN	95677	CA	3	3	0	Residential	Mon May 19 00:00:00 EDT 2008	488750	38.777585000000002	-121.203599999999994
543	100 CHELSEA CT	FOLSOM	95630	CA	3	2	1905	Residential	Mon May 19 00:00:00 EDT 2008	500000	38.69435	-121.177259000000006
544	1500 ORANGE HILL LN	PENRYN	95663	CA	3	2	1320	Residential	Mon May 19 00:00:00 EDT 2008	506688	38.8627079999999978	-121.162092000000001
545	408 KIRKWOOD CT	LINCOLN	95648	CA	2	2	0	Residential	Mon May 19 00:00:00 EDT 2008	512000	38.8616150000000005	-121.268690000000007
546	1732 TUSCAN GROVE CIR	ROSEVILLE	95747	CA	5	3	0	Residential	Mon May 19 00:00:00 EDT 2008	520000	38.7966830000000016	-121.342555000000004
547	2049 EMPIRE MINE CIR	GOLD RIVER	95670	CA	4	2	3037	Residential	Mon May 19 00:00:00 EDT 2008	528000	38.6292990000000032	-121.249020999999999
548	9360 MAGOS RD	WILTON	95693	CA	5	2	3741	Residential	Mon May 19 00:00:00 EDT 2008	579093	38.4168090000000007	-121.240628000000001
549	104 CATLIN CT	FOLSOM	95630	CA	4	3	2660	Residential	Mon May 19 00:00:00 EDT 2008	636000	38.6844589999999968	-121.145934999999994
550	4734 GIBBONS DR	CARMICHAEL	95608	CA	4	3	3357	Residential	Mon May 19 00:00:00 EDT 2008	668365	38.6355799999999974	-121.353639000000001
551	4629 DORCHESTER LN	GRANITE BAY	95746	CA	5	3	2896	Residential	Mon May 19 00:00:00 EDT 2008	676200	38.7235450000000014	-121.216025000000002
552	2400 COUNTRYSIDE DR	PLACERVILLE	95667	CA	3	2	2025	Residential	Mon May 19 00:00:00 EDT 2008	677048	38.7374519999999976	-120.910962999999995
553	12901 FURLONG DR	WILTON	95693	CA	5	3	3788	Residential	Mon May 19 00:00:00 EDT 2008	691659	38.4135350000000031	-121.188210999999995
554	6222 CALLE MONTALVO CIR	GRANITE BAY	95746	CA	5	3	3670	Residential	Mon May 19 00:00:00 EDT 2008	760000	38.7794349999999994	-121.146675999999999
555	20 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853269999999966	-121.289411999999999
556	24 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8851319999999987	-121.289405000000002
557	28 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8849360000000033	-121.289396999999994
558	32 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847409999999982	-121.289389999999997
559	36 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845990000000015	-121.289406
560	40 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845349999999996	-121.289619000000002
561	44 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845900000000029	-121.289834999999997
562	48 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8846670000000003	-121.289895999999999
563	52 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847799999999992	-121.289911000000004
564	68 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.885235999999999	-121.289928000000003
565	72 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853500000000025	-121.289925999999994
566	76 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8854639999999989	-121.289922000000004
567	80 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8855780000000024	-121.289918999999998
568	84 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8856919999999988	-121.289914999999993
569	88 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8858060000000023	-121.289911000000004
570	92 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8859199999999987	-121.289907999999997
571	96 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.886023999999999	-121.289859000000007
572	100 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8860910000000004	-121.289743999999999
573	434 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865300000000005	-121.289406
574	3 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8846920000000011	-121.290288000000004
575	11 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.884878999999998	-121.290256999999997
576	19 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8850169999999977	-121.290261999999998
577	27 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8851730000000018	-121.290270000000007
578	35 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853280000000012	-121.290274999999994
579	43 E ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8854830000000007	-121.290277000000003
580	51 E ST	LINCOLN	95648	CA	4	2	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8856380000000001	-121.290278999999998
581	59 E ST	LINCOLN	95648	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8857939999999971	-121.290280999999993
582	75 E ST	LINCOLN	95648	CA	3	2	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8861040000000031	-121.290284999999997
583	63 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8850929999999977	-121.289931999999993
584	398 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865300000000005	-121.288951999999995
585	386 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865279999999984	-121.288869000000005
586	374 1ST ST	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8865249999999989	-121.288786999999999
587	116 CRYSTALWOOD WAY	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8862820000000013	-121.289586
588	108 CRYSTALWOOD WAY	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8862820000000013	-121.289646000000005
589	100 CRYSTALWOOD WAY	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8862820000000013	-121.289705999999995
590	55 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8848649999999978	-121.289922000000004
591	51 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847519999999989	-121.289906999999999
592	47 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8846380000000025	-121.289893000000006
593	43 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845680000000016	-121.289783999999997
594	39 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8845460000000003	-121.289562000000004
595	35 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.884644999999999	-121.289396999999994
596	31 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8847900000000024	-121.289392000000007
597	27 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8849850000000004	-121.289399000000003
598	23 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8851810000000029	-121.289406
599	19 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8853760000000008	-121.289413999999994
600	15 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8855709999999988	-121.289421000000004
601	7 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8859619999999993	-121.289435999999995
602	7 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8859619999999993	-121.289435999999995
603	3 CRYSTALWOOD CIR	LINCOLN	95648	CA	0	0	0	Residential	Mon May 19 00:00:00 EDT 2008	4897	38.8860930000000025	-121.289584000000005
604	8208 WOODYARD WAY	CITRUS HEIGHTS	95621	CA	3	2	1166	Residential	Fri May 16 00:00:00 EDT 2008	30000	38.7153220000000005	-121.314786999999995
605	113 RINETTI WAY	RIO LINDA	95673	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	30000	38.6871719999999968	-121.463932999999997
606	15 LOORZ CT	SACRAMENTO	95823	CA	2	1	838	Residential	Fri May 16 00:00:00 EDT 2008	55422	38.4716459999999998	-121.435158000000001
607	5805 DOTMAR WAY	NORTH HIGHLANDS	95660	CA	2	1	904	Residential	Fri May 16 00:00:00 EDT 2008	63000	38.6726420000000033	-121.380342999999996
608	2332 CAMBRIDGE ST	SACRAMENTO	95815	CA	2	1	1032	Residential	Fri May 16 00:00:00 EDT 2008	65000	38.6080850000000027	-121.449651000000003
609	3812 BELDEN ST	SACRAMENTO	95838	CA	2	1	904	Residential	Fri May 16 00:00:00 EDT 2008	65000	38.6368330000000029	-121.441640000000007
610	3348 40TH ST	SACRAMENTO	95817	CA	2	1	1080	Residential	Fri May 16 00:00:00 EDT 2008	65000	38.544162	-121.460651999999996
611	127 QUASAR CIR	SACRAMENTO	95822	CA	2	2	990	Residential	Fri May 16 00:00:00 EDT 2008	66500	38.4935040000000015	-121.475303999999994
612	3812 CYPRESS ST	SACRAMENTO	95838	CA	2	1	900	Residential	Fri May 16 00:00:00 EDT 2008	71000	38.6368769999999984	-121.444947999999997
613	5821 64TH ST	SACRAMENTO	95824	CA	2	1	861	Residential	Fri May 16 00:00:00 EDT 2008	75000	38.5212020000000024	-121.428145999999998
614	8248 CENTER PKWY	SACRAMENTO	95823	CA	2	1	906	Condo	Fri May 16 00:00:00 EDT 2008	77000	38.4590019999999981	-121.428793999999996
615	1171 SONOMA AVE	SACRAMENTO	95815	CA	2	1	1011	Residential	Fri May 16 00:00:00 EDT 2008	85000	38.6238000000000028	-121.439871999999994
616	4250 ARDWELL WAY	SACRAMENTO	95823	CA	3	2	1089	Residential	Fri May 16 00:00:00 EDT 2008	95625	38.466937999999999	-121.455630999999997
617	3104 CLAY ST	SACRAMENTO	95815	CA	2	1	832	Residential	Fri May 16 00:00:00 EDT 2008	96140	38.6239100000000022	-121.439207999999994
618	6063 LAND PARK DR	SACRAMENTO	95822	CA	2	1	800	Condo	Fri May 16 00:00:00 EDT 2008	104250	38.5170290000000008	-121.513808999999995
619	4738 OAKHOLLOW DR	SACRAMENTO	95842	CA	4	2	1292	Residential	Fri May 16 00:00:00 EDT 2008	105000	38.6795979999999986	-121.356035000000006
620	1401 STERLING ST	SACRAMENTO	95822	CA	2	1	810	Residential	Fri May 16 00:00:00 EDT 2008	108000	38.5203190000000006	-121.504727000000003
621	3715 DIDCOT CIR	SACRAMENTO	95838	CA	4	2	1064	Residential	Fri May 16 00:00:00 EDT 2008	109000	38.635232000000002	-121.460098000000002
622	2426 RASHAWN DR	RANCHO CORDOVA	95670	CA	2	1	911	Residential	Fri May 16 00:00:00 EDT 2008	115000	38.6108520000000013	-121.273278000000005
623	4800 WESTLAKE PKWY Unit 410	SACRAMENTO	95835	CA	1	1	846	Condo	Fri May 16 00:00:00 EDT 2008	115000	38.6588119999999975	-121.542344999999997
624	3409 VIRGO ST	SACRAMENTO	95827	CA	3	2	1320	Residential	Fri May 16 00:00:00 EDT 2008	115500	38.5634020000000035	-121.327747000000002
625	1110 PINEDALE AVE	SACRAMENTO	95838	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	115620	38.6601730000000003	-121.440216000000007
626	2361 LA LOMA DR	RANCHO CORDOVA	95670	CA	3	2	1115	Residential	Fri May 16 00:00:00 EDT 2008	116000	38.5936799999999991	-121.316053999999994
627	1455 64TH AVE	SACRAMENTO	95822	CA	3	2	1169	Residential	Fri May 16 00:00:00 EDT 2008	122000	38.4921769999999981	-121.503392000000005
628	7328 SPRINGMAN ST	SACRAMENTO	95822	CA	3	2	1164	Residential	Fri May 16 00:00:00 EDT 2008	122500	38.4919909999999987	-121.477636000000004
629	119 SAINT MARIE CIR	SACRAMENTO	95823	CA	4	2	1341	Residential	Fri May 16 00:00:00 EDT 2008	123000	38.4814539999999994	-121.446644000000006
630	12 COSTA BRASE CT	SACRAMENTO	95838	CA	3	2	1219	Residential	Fri May 16 00:00:00 EDT 2008	124000	38.6555540000000022	-121.464275000000001
631	6813 SCOTER WAY	SACRAMENTO	95842	CA	4	2	1127	Residential	Fri May 16 00:00:00 EDT 2008	124000	38.6904299999999992	-121.361035000000001
632	6548 GRAYLOCK LN	NORTH HIGHLANDS	95660	CA	3	2	1272	Residential	Fri May 16 00:00:00 EDT 2008	124413	38.6860610000000023	-121.369949000000005
633	1630 GLIDDEN AVE	SACRAMENTO	95822	CA	4	2	1253	Residential	Fri May 16 00:00:00 EDT 2008	125000	38.482717000000001	-121.499683000000005
634	7825 DALEWOODS WAY	SACRAMENTO	95828	CA	3	2	1120	Residential	Fri May 16 00:00:00 EDT 2008	130000	38.4772970000000001	-121.411512999999999
635	4073 TRESLER AVE	NORTH HIGHLANDS	95660	CA	2	2	1118	Residential	Fri May 16 00:00:00 EDT 2008	131750	38.6590160000000012	-121.370457000000002
636	4288 DYMIC WAY	SACRAMENTO	95838	CA	4	3	1890	Residential	Fri May 16 00:00:00 EDT 2008	137721	38.6465409999999991	-121.441139000000007
637	1158 SAN IGNACIO WAY	SACRAMENTO	95833	CA	3	2	1260	Residential	Fri May 16 00:00:00 EDT 2008	137760	38.6230449999999976	-121.486278999999996
638	4904 J PKWY	SACRAMENTO	95823	CA	3	2	1400	Residential	Fri May 16 00:00:00 EDT 2008	138000	38.4872969999999981	-121.442949999999996
639	2931 HOWE AVE	SACRAMENTO	95821	CA	3	1	1264	Residential	Fri May 16 00:00:00 EDT 2008	140000	38.6190119999999979	-121.415329
640	5531 JANSEN DR	SACRAMENTO	95824	CA	3	1	1060	Residential	Fri May 16 00:00:00 EDT 2008	145000	38.5220150000000032	-121.438713000000007
641	7836 ORCHARD WOODS CIR	SACRAMENTO	95828	CA	2	2	1132	Residential	Fri May 16 00:00:00 EDT 2008	145000	38.4795500000000033	-121.410866999999996
642	4055 DEERBROOK DR	SACRAMENTO	95823	CA	3	2	1466	Residential	Fri May 16 00:00:00 EDT 2008	150000	38.4721169999999972	-121.459588999999994
643	9937 BURLINE ST	SACRAMENTO	95827	CA	3	2	1092	Residential	Fri May 16 00:00:00 EDT 2008	150000	38.5596409999999992	-121.323160000000001
644	6948 MIRADOR WAY	SACRAMENTO	95828	CA	4	2	1628	Residential	Fri May 16 00:00:00 EDT 2008	151000	38.4934840000000023	-121.420349999999999
645	4909 RUGER CT	SACRAMENTO	95842	CA	3	2	960	Residential	Fri May 16 00:00:00 EDT 2008	155000	38.6874699999999976	-121.349233999999996
646	7204 KERSTEN ST	CITRUS HEIGHTS	95621	CA	3	2	1075	Residential	Fri May 16 00:00:00 EDT 2008	155800	38.6958630000000028	-121.300814000000003
647	3150 ROSEMONT DR	SACRAMENTO	95826	CA	3	2	1428	Residential	Fri May 16 00:00:00 EDT 2008	156142	38.5549269999999993	-121.35521
648	8200 STEINBECK WAY	SACRAMENTO	95828	CA	4	2	1358	Residential	Fri May 16 00:00:00 EDT 2008	158000	38.4748540000000006	-121.404725999999997
649	8198 STEVENSON AVE	SACRAMENTO	95828	CA	6	4	2475	Multi-Family	Fri May 16 00:00:00 EDT 2008	159900	38.4652710000000013	-121.404259999999994
650	6824 OLIVE TREE WAY	CITRUS HEIGHTS	95610	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	160000	38.6892390000000006	-121.267736999999997
651	3536 SUN MAIDEN WAY	ANTELOPE	95843	CA	3	2	1711	Residential	Fri May 16 00:00:00 EDT 2008	161500	38.7096799999999988	-121.382328000000001
652	4517 OLYMPIAD WAY	SACRAMENTO	95826	CA	4	2	1483	Residential	Fri May 16 00:00:00 EDT 2008	161600	38.5367510000000024	-121.359154000000004
653	925 COBDEN CT	GALT	95632	CA	3	2	1140	Residential	Fri May 16 00:00:00 EDT 2008	162000	38.2820469999999986	-121.295811999999998
654	8225 SCOTTSDALE DR	SACRAMENTO	95828	CA	4	2	1549	Residential	Fri May 16 00:00:00 EDT 2008	165000	38.4878640000000019	-121.402475999999993
655	8758 LEMAS RD	SACRAMENTO	95828	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	165000	38.4674869999999984	-121.377054999999999
656	6121 ALPINESPRING WAY	ELK GROVE	95758	CA	3	2	1240	Residential	Fri May 16 00:00:00 EDT 2008	167293	38.434075	-121.432623000000007
657	5937 YORK GLEN WAY	SACRAMENTO	95842	CA	5	2	1712	Residential	Fri May 16 00:00:00 EDT 2008	168000	38.6770029999999991	-121.354454000000004
658	6417 SUNNYFIELD WAY	SACRAMENTO	95823	CA	4	2	1580	Residential	Fri May 16 00:00:00 EDT 2008	168000	38.4491530000000026	-121.428272000000007
659	4008 GREY LIVERY WAY	ANTELOPE	95843	CA	3	2	1669	Residential	Fri May 16 00:00:00 EDT 2008	168750	38.7184600000000003	-121.370862000000002
660	8920 ROSETTA CIR	SACRAMENTO	95826	CA	3	1	1029	Residential	Fri May 16 00:00:00 EDT 2008	168750	38.5443739999999977	-121.370874000000001
661	8300 LICHEN DR	CITRUS HEIGHTS	95621	CA	3	1	1103	Residential	Fri May 16 00:00:00 EDT 2008	170000	38.7164100000000033	-121.306239000000005
662	8884 AMBERJACK WAY	SACRAMENTO	95828	CA	3	2	2161	Residential	Fri May 16 00:00:00 EDT 2008	170250	38.4793430000000001	-121.372552999999996
663	4480 VALLEY HI DR	SACRAMENTO	95823	CA	3	2	1650	Residential	Fri May 16 00:00:00 EDT 2008	173000	38.4667809999999974	-121.450954999999993
664	2250 FOREBAY RD	POLLOCK PINES	95726	CA	3	1	1320	Residential	Fri May 16 00:00:00 EDT 2008	175000	38.7749099999999984	-120.597599000000002
665	3529 FABERGE WAY	SACRAMENTO	95826	CA	3	2	1200	Residential	Fri May 16 00:00:00 EDT 2008	176095	38.5532749999999993	-121.346217999999993
666	1792 DAWNELLE WAY	SACRAMENTO	95835	CA	3	2	1170	Residential	Fri May 16 00:00:00 EDT 2008	176250	38.6827100000000002	-121.501696999999993
667	7800 TABARE CT	CITRUS HEIGHTS	95621	CA	3	2	1199	Residential	Fri May 16 00:00:00 EDT 2008	178000	38.7079900000000023	-121.302978999999993
668	8531 HERMITAGE WAY	SACRAMENTO	95823	CA	4	2	1695	Residential	Fri May 16 00:00:00 EDT 2008	179000	38.4484520000000032	-121.428535999999994
669	2421 BERRYWOOD DR	RANCHO CORDOVA	95670	CA	3	2	1157	Residential	Fri May 16 00:00:00 EDT 2008	180000	38.6086799999999997	-121.278490000000005
670	1005 MORENO WAY	SACRAMENTO	95838	CA	3	2	1410	Residential	Fri May 16 00:00:00 EDT 2008	180000	38.6462059999999994	-121.442767000000003
671	1675 VERNON ST Unit 24	ROSEVILLE	95678	CA	3	2	1174	Residential	Fri May 16 00:00:00 EDT 2008	180000	38.7341359999999995	-121.299638999999999
672	24 WINDCHIME CT	SACRAMENTO	95823	CA	3	2	1593	Residential	Fri May 16 00:00:00 EDT 2008	181000	38.4461700000000022	-121.427824000000001
673	540 HARLING CT	RIO LINDA	95673	CA	3	2	1093	Residential	Fri May 16 00:00:00 EDT 2008	182000	38.6827899999999971	-121.453508999999997
674	1207 CRESCENDO DR	ROSEVILLE	95678	CA	3	2	1770	Residential	Fri May 16 00:00:00 EDT 2008	182587	38.7244600000000005	-121.292828999999998
675	7577 EDDYLEE WAY	SACRAMENTO	95822	CA	4	2	1436	Residential	Fri May 16 00:00:00 EDT 2008	185074	38.4829099999999968	-121.491508999999994
676	8369 FOPPIANO WAY	SACRAMENTO	95829	CA	3	2	1124	Residential	Fri May 16 00:00:00 EDT 2008	185833	38.4538390000000021	-121.357918999999995
677	8817 SAWTELLE WAY	SACRAMENTO	95826	CA	4	2	1139	Residential	Fri May 16 00:00:00 EDT 2008	186785	38.5653220000000019	-121.374251000000001
678	1910 BONAVISTA WAY	SACRAMENTO	95832	CA	3	2	1638	Residential	Fri May 16 00:00:00 EDT 2008	187000	38.4760479999999987	-121.494961000000004
679	8 TIDE CT	SACRAMENTO	95833	CA	3	2	1328	Residential	Fri May 16 00:00:00 EDT 2008	188335	38.6098640000000017	-121.492304000000004
680	8952 ROCKY CREEK CT	ELK GROVE	95758	CA	3	2	1273	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.4312389999999979	-121.440010000000001
681	435 EXCHANGE ST	SACRAMENTO	95838	CA	3	1	1082	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.6594339999999974	-121.455235999999999
682	10105 MONTE VALLO CT	SACRAMENTO	95827	CA	4	2	1578	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.5739170000000016	-121.316916000000006
683	3930 ANNABELLE AVE	ROSEVILLE	95661	CA	2	1	796	Residential	Fri May 16 00:00:00 EDT 2008	190000	38.7276090000000011	-121.226494000000002
684	4854 TANGERINE AVE	SACRAMENTO	95823	CA	3	2	1386	Residential	Fri May 16 00:00:00 EDT 2008	191250	38.4782390000000021	-121.446325999999999
685	2909 SHAWN WAY	RANCHO CORDOVA	95670	CA	3	2	1452	Residential	Fri May 16 00:00:00 EDT 2008	193000	38.5899250000000009	-121.299059
686	4290 BLACKFORD WAY	SACRAMENTO	95823	CA	3	2	1513	Residential	Fri May 16 00:00:00 EDT 2008	193500	38.4704940000000022	-121.454161999999997
687	5890 TT TRAK	FORESTHILL	95631	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	194818	39.0208080000000024	-120.821517999999998
688	7015 WOODSIDE DR	SACRAMENTO	95842	CA	4	2	1578	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.6930710000000033	-121.332364999999996
689	6019 CHESHIRE WAY	CITRUS HEIGHTS	95610	CA	4	3	1736	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.676437	-121.279165000000006
690	3330 VILLAGE CT	CAMERON PARK	95682	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.6905039999999971	-120.996245000000002
691	2561 VERNA WAY	SACRAMENTO	95821	CA	3	1	1473	Residential	Fri May 16 00:00:00 EDT 2008	195000	38.6110550000000003	-121.369963999999996
692	3522 22ND AVE	SACRAMENTO	95820	CA	3	1	1150	Residential	Fri May 16 00:00:00 EDT 2008	198000	38.5327249999999992	-121.469077999999996
693	2880 CANDIDO DR	SACRAMENTO	95833	CA	3	2	1127	Residential	Fri May 16 00:00:00 EDT 2008	199900	38.6180189999999968	-121.510215000000002
694	6908 PIN OAK CT	FAIR OAKS	95628	CA	3	1	1144	Residential	Fri May 16 00:00:00 EDT 2008	200000	38.6642399999999995	-121.303674999999998
695	5733 ANGELINA AVE	CARMICHAEL	95608	CA	3	1	972	Residential	Fri May 16 00:00:00 EDT 2008	201000	38.6226339999999979	-121.330845999999994
696	7849 BONNY DOWNS WAY	ELK GROVE	95758	CA	4	2	2306	Residential	Fri May 16 00:00:00 EDT 2008	204918	38.4213900000000024	-121.411338999999998
697	8716 LONGSPUR WAY	ANTELOPE	95843	CA	3	2	1479	Residential	Fri May 16 00:00:00 EDT 2008	205000	38.7240830000000003	-121.358400000000003
698	6320 EL DORADO ST	EL DORADO	95623	CA	2	1	1040	Residential	Fri May 16 00:00:00 EDT 2008	205000	38.678758000000002	-120.844117999999995
699	2328 DOROTHY JUNE WAY	SACRAMENTO	95838	CA	3	2	1430	Residential	Fri May 16 00:00:00 EDT 2008	205878	38.641727000000003	-121.412702999999993
700	1986 DANVERS WAY	SACRAMENTO	95832	CA	4	2	1800	Residential	Fri May 16 00:00:00 EDT 2008	207000	38.4772299999999987	-121.492568000000006
701	7901 GAZELLE TRAIL WAY	ANTELOPE	95843	CA	4	2	1953	Residential	Fri May 16 00:00:00 EDT 2008	207744	38.7117399999999989	-121.342675
702	6080 BRIDGECROSS DR	SACRAMENTO	95835	CA	3	2	1120	Residential	Fri May 16 00:00:00 EDT 2008	209000	38.6819520000000026	-121.505009000000001
703	20 GROTH CIR	SACRAMENTO	95834	CA	3	2	1232	Residential	Fri May 16 00:00:00 EDT 2008	210000	38.6408070000000023	-121.533522000000005
704	1900 DANBROOK DR	SACRAMENTO	95835	CA	1	1	984	Condo	Fri May 16 00:00:00 EDT 2008	210944	38.6684330000000003	-121.503471000000005
705	140 VENTO CT	ROSEVILLE	95678	CA	3	2	0	Condo	Fri May 16 00:00:00 EDT 2008	212500	38.7935329999999965	-121.289685000000006
706	8442 KEUSMAN ST	ELK GROVE	95758	CA	4	2	2329	Residential	Fri May 16 00:00:00 EDT 2008	213750	38.4496510000000029	-121.414704
707	9552 SUNLIGHT LN	ELK GROVE	95758	CA	3	2	1351	Residential	Fri May 16 00:00:00 EDT 2008	215000	38.4105610000000013	-121.404326999999995
708	2733 YUMA CT	CAMERON PARK	95682	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	215000	38.6912149999999997	-120.994949000000005
709	1407 TIFFANY CIR	ROSEVILLE	95661	CA	4	1	1376	Residential	Fri May 16 00:00:00 EDT 2008	215000	38.7363920000000022	-121.266400000000004
710	636 CRESTVIEW DR	DIAMOND SPRINGS	95619	CA	3	2	1300	Residential	Fri May 16 00:00:00 EDT 2008	216033	38.6882549999999981	-120.810235000000006
711	1528 HESKET WAY	SACRAMENTO	95825	CA	4	2	1566	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.5935980000000001	-121.403637000000003
712	2327 32ND ST	SACRAMENTO	95817	CA	2	1	1115	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.5574330000000032	-121.470339999999993
713	1833 2ND AVE	SACRAMENTO	95818	CA	2	1	1032	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.5568179999999998	-121.490668999999997
714	7252 CARRIAGE DR	CITRUS HEIGHTS	95621	CA	4	2	1419	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.6980580000000032	-121.294893000000002
715	9815 PASO FINO WAY	ELK GROVE	95757	CA	3	2	1261	Residential	Fri May 16 00:00:00 EDT 2008	220000	38.4048879999999997	-121.443997999999993
716	5532 ENGLE RD	CARMICHAEL	95608	CA	2	2	1637	Residential	Fri May 16 00:00:00 EDT 2008	220702	38.6317299999999975	-121.335285999999996
717	1139 CLINTON RD	SACRAMENTO	95825	CA	4	2	1776	Multi-Family	Fri May 16 00:00:00 EDT 2008	221250	38.585290999999998	-121.406824
718	9176 SAGE GLEN WAY	ELK GROVE	95758	CA	3	2	1338	Residential	Fri May 16 00:00:00 EDT 2008	222000	38.4239129999999989	-121.439115000000001
719	9967 HATHERTON WAY	ELK GROVE	95757	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	222500	38.3051999999999992	-121.403300000000002
720	9264 BOULDER RIVER WAY	ELK GROVE	95624	CA	5	2	2254	Residential	Fri May 16 00:00:00 EDT 2008	222750	38.4217129999999969	-121.345191
721	320 GROTH CIR	SACRAMENTO	95834	CA	3	2	1441	Residential	Fri May 16 00:00:00 EDT 2008	225000	38.6388820000000024	-121.531882999999993
722	137 GUNNISON AVE	SACRAMENTO	95838	CA	4	2	1991	Residential	Fri May 16 00:00:00 EDT 2008	225000	38.6507289999999983	-121.466482999999997
723	8209 RIVALLO WAY	SACRAMENTO	95829	CA	4	3	2126	Residential	Fri May 16 00:00:00 EDT 2008	228750	38.4595240000000018	-121.350099999999998
724	8637 PERIWINKLE CIR	ELK GROVE	95624	CA	3	2	1094	Residential	Fri May 16 00:00:00 EDT 2008	229000	38.4431840000000022	-121.364388000000005
725	3425 MEADOW WAY	ROCKLIN	95677	CA	3	2	1462	Residential	Fri May 16 00:00:00 EDT 2008	230095	38.7980280000000022	-121.235364000000004
726	107 JARVIS CIR	SACRAMENTO	95834	CA	5	3	2258	Residential	Fri May 16 00:00:00 EDT 2008	232500	38.6398909999999987	-121.537603000000004
727	2319 THORES ST	RANCHO CORDOVA	95670	CA	3	2	1074	Residential	Fri May 16 00:00:00 EDT 2008	233000	38.5967500000000001	-121.312715999999995
728	8935 MOUNTAIN HOME CT	ELK GROVE	95624	CA	4	2	2111	Residential	Fri May 16 00:00:00 EDT 2008	233500	38.3875099999999989	-121.370276000000004
729	2566 SERENATA WAY	SACRAMENTO	95835	CA	3	2	1686	Residential	Fri May 16 00:00:00 EDT 2008	239000	38.6715560000000025	-121.520916
730	4085 COUNTRY DR	ANTELOPE	95843	CA	4	3	1915	Residential	Fri May 16 00:00:00 EDT 2008	240000	38.7062090000000012	-121.369508999999994
731	9297 TROUT WAY	ELK GROVE	95624	CA	4	2	2367	Residential	Fri May 16 00:00:00 EDT 2008	240000	38.4206369999999993	-121.375798000000003
732	7 ARCHIBALD CT	SACRAMENTO	95823	CA	3	2	1962	Residential	Fri May 16 00:00:00 EDT 2008	240971	38.4433050000000023	-121.435295999999994
733	11130 EEL RIVER CT	RANCHO CORDOVA	95670	CA	2	2	1406	Residential	Fri May 16 00:00:00 EDT 2008	242000	38.6259319999999988	-121.271517000000003
734	8323 REDBANK WAY	SACRAMENTO	95829	CA	3	2	1789	Residential	Fri May 16 00:00:00 EDT 2008	243450	38.4557530000000014	-121.349272999999997
735	16 BRONCO CREEK CT	SACRAMENTO	95835	CA	4	2	1876	Residential	Fri May 16 00:00:00 EDT 2008	243500	38.6742259999999973	-121.525497000000001
736	8316 NORTHAM DR	ANTELOPE	95843	CA	3	2	1235	Residential	Fri May 16 00:00:00 EDT 2008	246544	38.7207670000000022	-121.376677999999998
737	4240 WINJE DR	ANTELOPE	95843	CA	4	2	2504	Residential	Fri May 16 00:00:00 EDT 2008	246750	38.7088400000000021	-121.359559000000004
738	3569 SODA WAY	SACRAMENTO	95834	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	247000	38.6311389999999975	-121.501879000000002
739	5118 ROBANDER ST	CARMICHAEL	95608	CA	3	2	1676	Residential	Fri May 16 00:00:00 EDT 2008	247000	38.6572669999999974	-121.310351999999995
740	5976 KYLENCH CT	CITRUS HEIGHTS	95621	CA	3	2	1367	Residential	Fri May 16 00:00:00 EDT 2008	249000	38.7089659999999967	-121.324669999999998
741	9247 DELAIR WAY	ELK GROVE	95758	CA	4	3	1899	Residential	Fri May 16 00:00:00 EDT 2008	249000	38.4222409999999996	-121.458022
742	9054 DESCENDANT DR	ELK GROVE	95758	CA	3	2	1636	Residential	Fri May 16 00:00:00 EDT 2008	250000	38.4288519999999991	-121.415627999999998
743	3450 WHITNOR CT	SACRAMENTO	95821	CA	3	2	1828	Residential	Fri May 16 00:00:00 EDT 2008	250000	38.6276980000000023	-121.369698
744	6288 LONETREE BLVD	ROCKLIN	95765	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	250000	38.8049930000000032	-121.293609000000004
745	9355 MATADOR WAY	SACRAMENTO	95826	CA	4	2	1438	Residential	Fri May 16 00:00:00 EDT 2008	252000	38.5556330000000003	-121.350690999999998
746	8671 SUMMER SUN WAY	ELK GROVE	95624	CA	3	2	1451	Residential	Fri May 16 00:00:00 EDT 2008	255000	38.4428449999999984	-121.373272
747	1890 GENEVA PL	SACRAMENTO	95825	CA	3	1	1520	Residential	Fri May 16 00:00:00 EDT 2008	255000	38.5994489999999999	-121.400305000000003
748	1813 AVENIDA MARTINA	ROSEVILLE	95747	CA	3	2	1506	Residential	Fri May 16 00:00:00 EDT 2008	255000	38.776648999999999	-121.339589000000004
749	191 BARNHART CIR	SACRAMENTO	95835	CA	4	2	2605	Residential	Fri May 16 00:00:00 EDT 2008	257200	38.6755939999999967	-121.515878000000001
750	6221 GREEN TOP WAY	ORANGEVALE	95662	CA	3	2	1196	Residential	Fri May 16 00:00:00 EDT 2008	260000	38.6794089999999997	-121.219106999999994
751	2298 PRIMROSE LN	LINCOLN	95648	CA	3	2	1621	Residential	Fri May 16 00:00:00 EDT 2008	260000	38.8991800000000012	-121.322513999999998
752	5635 LOS PUEBLOS WAY	SACRAMENTO	95835	CA	3	2	1811	Residential	Fri May 16 00:00:00 EDT 2008	263500	38.679191000000003	-121.537621999999999
753	10165 LOFTON WAY	ELK GROVE	95757	CA	3	2	1540	Residential	Fri May 16 00:00:00 EDT 2008	266510	38.3877080000000035	-121.436521999999997
754	1251 GREEN RAVINE DR	LINCOLN	95648	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	267750	38.8815600000000003	-121.301343000000003
755	6001 SHOO FLY RD	PLACERVILLE	95667	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	270000	38.8135460000000023	-120.809253999999996
756	3040 PARKHAM DR	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	271000	38.7708349999999982	-121.366996
757	2674 TAM O SHANTER DR	EL DORADO HILLS	95762	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	272700	38.695801000000003	-121.079216000000002
758	6007 MARYBELLE LN	SHINGLE SPRINGS	95682	CA	0	0	0	Unkown	Fri May 16 00:00:00 EDT 2008	275000	38.6434700000000007	-120.888182999999998
759	9949 NESTLING CIR	ELK GROVE	95757	CA	3	2	1543	Residential	Fri May 16 00:00:00 EDT 2008	275000	38.3974550000000008	-121.468390999999997
760	2915 HOLDREGE WAY	SACRAMENTO	95835	CA	5	3	2494	Residential	Fri May 16 00:00:00 EDT 2008	276000	38.663727999999999	-121.525833000000006
761	2678 BRIARTON DR	LINCOLN	95648	CA	3	2	1650	Residential	Fri May 16 00:00:00 EDT 2008	276500	38.8441159999999996	-121.274805999999998
762	294 SPARROW DR	GALT	95632	CA	4	3	2214	Residential	Fri May 16 00:00:00 EDT 2008	278000	38.258975999999997	-121.321265999999994
763	2987 DIORITE WAY	SACRAMENTO	95835	CA	5	3	2280	Residential	Fri May 16 00:00:00 EDT 2008	279000	38.6673320000000018	-121.528276000000005
764	6326 APPIAN WAY	CARMICHAEL	95608	CA	3	2	1443	Residential	Fri May 16 00:00:00 EDT 2008	280000	38.6626600000000025	-121.316857999999996
765	6905 COBALT WAY	CITRUS HEIGHTS	95621	CA	4	2	1582	Residential	Fri May 16 00:00:00 EDT 2008	280000	38.6913929999999979	-121.305215000000004
766	8986 HAFLINGER WAY	ELK GROVE	95757	CA	3	2	1857	Residential	Fri May 16 00:00:00 EDT 2008	285000	38.3979229999999987	-121.450219000000004
767	2916 BABSON DR	ELK GROVE	95758	CA	3	2	1735	Residential	Fri May 16 00:00:00 EDT 2008	288000	38.4171910000000025	-121.473896999999994
768	10133 NEBBIOLO CT	ELK GROVE	95624	CA	4	3	2096	Residential	Fri May 16 00:00:00 EDT 2008	289000	38.3910849999999968	-121.347230999999994
769	1103 COMMONS DR	SACRAMENTO	95825	CA	3	2	1720	Residential	Fri May 16 00:00:00 EDT 2008	290000	38.5678649999999976	-121.410698999999994
770	4636 TEAL BAY CT	ANTELOPE	95843	CA	4	2	2160	Residential	Fri May 16 00:00:00 EDT 2008	290000	38.7045540000000017	-121.354753000000002
771	1524 YOUNGS AVE	SACRAMENTO	95838	CA	4	2	1382	Residential	Fri May 16 00:00:00 EDT 2008	293996	38.6449270000000027	-121.430539999999993
772	865 CONRAD CT	PLACERVILLE	95667	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	294000	38.7299930000000003	-120.802458000000001
773	8463 TERRACOTTA CT	ELK GROVE	95624	CA	4	2	1721	Residential	Fri May 16 00:00:00 EDT 2008	294173	38.4505479999999977	-121.363001999999994
774	5747 KING RD	LOOMIS	95650	CA	4	2	1328	Residential	Fri May 16 00:00:00 EDT 2008	295000	38.8250960000000021	-121.198431999999997
775	8253 KEEGAN WAY	ELK GROVE	95624	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	298000	38.4462860000000006	-121.400817000000004
776	9204 TROUT WAY	ELK GROVE	95624	CA	4	2	1982	Residential	Fri May 16 00:00:00 EDT 2008	298000	38.4222210000000004	-121.375799000000001
777	1828 2ND AVE	SACRAMENTO	95818	CA	2	1	1144	Residential	Fri May 16 00:00:00 EDT 2008	299000	38.5568439999999981	-121.490769
778	1113 COMMONS DR	SACRAMENTO	95825	CA	2	2	1623	Residential	Fri May 16 00:00:00 EDT 2008	300000	38.5677949999999967	-121.410702999999998
779	2341 BIG STRIKE TRL	COOL	95614	CA	3	2	1457	Residential	Fri May 16 00:00:00 EDT 2008	300000	38.9059269999999984	-120.975168999999994
780	9452 RED SPRUCE WAY	ELK GROVE	95624	CA	6	3	2555	Residential	Fri May 16 00:00:00 EDT 2008	300000	38.4045050000000003	-121.346937999999994
781	5776 TERRACE DR	ROCKLIN	95765	CA	3	2	1577	Residential	Fri May 16 00:00:00 EDT 2008	300567	38.8005390000000006	-121.260979000000006
782	5908 MCLEAN DR	ELK GROVE	95757	CA	5	3	2592	Residential	Fri May 16 00:00:00 EDT 2008	303000	38.3891199999999984	-121.434388999999996
783	8215 PEREGRINE WAY	CITRUS HEIGHTS	95610	CA	3	2	1401	Residential	Fri May 16 00:00:00 EDT 2008	305000	38.7154930000000022	-121.262929999999997
784	1104 HILLSDALE LN	LINCOLN	95648	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	306000	38.8650170000000017	-121.32302
785	2949 PANAMA AVE	CARMICHAEL	95608	CA	3	2	1502	Residential	Fri May 16 00:00:00 EDT 2008	310000	38.6183690000000013	-121.326187000000004
786	1356 HARTLEY WAY	FOLSOM	95630	CA	3	2	1327	Residential	Fri May 16 00:00:00 EDT 2008	310000	38.6516170000000017	-121.131674000000004
787	633 HANISCH DR	ROSEVILLE	95678	CA	4	3	1800	Residential	Fri May 16 00:00:00 EDT 2008	310000	38.7634899999999973	-121.275880999999998
788	63 ANGEL ISLAND CIR	SACRAMENTO	95831	CA	4	2	2169	Residential	Fri May 16 00:00:00 EDT 2008	311518	38.4904080000000022	-121.547663999999997
789	1571 WILD OAK LN	LINCOLN	95648	CA	5	3	2457	Residential	Fri May 16 00:00:00 EDT 2008	312000	38.844144	-121.274174000000002
790	5222 COPPER SUNSET WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	313000	38.5291810000000012	-121.224755000000002
791	5601 SPINDRIFT LN	ORANGEVALE	95662	CA	4	2	2004	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.6682890000000015	-121.192316000000005
792	652 FIFTEEN MILE DR	ROSEVILLE	95678	CA	4	3	2212	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.7758719999999997	-121.298863999999995
793	7921 DOE TRAIL WAY	ANTELOPE	95843	CA	5	3	3134	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.7119270000000029	-121.343608000000003
794	4204 LUSK DR	SACRAMENTO	95864	CA	3	2	1360	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.6065690000000004	-121.368424000000005
795	5321 DELTA DR	ROCKLIN	95765	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	315000	38.8154929999999965	-121.262907999999996
796	5608 ROSEDALE WAY	SACRAMENTO	95822	CA	3	2	1276	Residential	Fri May 16 00:00:00 EDT 2008	320000	38.5251149999999996	-121.518688999999995
797	3372 BERETANIA WAY	SACRAMENTO	95834	CA	4	3	2962	Residential	Fri May 16 00:00:00 EDT 2008	322000	38.6497699999999966	-121.534480000000002
798	2422 STEFANIE DR	ROCKLIN	95765	CA	4	2	1888	Residential	Fri May 16 00:00:00 EDT 2008	325000	38.82273	-121.264240000000001
799	3232 PARKHAM DR	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	325500	38.7728210000000004	-121.364821000000006
800	448 ELMWOOD CT	ROSEVILLE	95678	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	326951	38.771917000000002	-121.304439000000002
801	1214 DAWNWOOD DR	GALT	95632	CA	3	2	1548	Residential	Fri May 16 00:00:00 EDT 2008	328370	38.2901189999999971	-121.286023
802	1440 EMERALD LN	LINCOLN	95648	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	330000	38.8618639999999971	-121.267477999999997
803	3349 CORVINA DR	RANCHO CORDOVA	95670	CA	4	3	2109	Residential	Fri May 16 00:00:00 EDT 2008	330000	38.5805450000000008	-121.279015999999999
804	10254 JULIANA WAY	SACRAMENTO	95827	CA	4	2	2484	Residential	Fri May 16 00:00:00 EDT 2008	331200	38.5680300000000003	-121.309966000000003
805	149 OPUS CIR	SACRAMENTO	95834	CA	4	3	2258	Residential	Fri May 16 00:00:00 EDT 2008	332000	38.6353999999999971	-121.534989999999993
806	580 REGENCY PARK CIR	SACRAMENTO	95835	CA	3	3	2212	Residential	Fri May 16 00:00:00 EDT 2008	334000	38.6748639999999995	-121.495800000000003
807	5544 CAMAS CT	ORANGEVALE	95662	CA	3	2	1616	Residential	Fri May 16 00:00:00 EDT 2008	335000	38.667703000000003	-121.209456000000003
808	5102 ARCHCREST WAY	SACRAMENTO	95835	CA	4	2	2372	Residential	Fri May 16 00:00:00 EDT 2008	341000	38.6684100000000015	-121.494639000000006
809	5725 BALFOR RD	ROCKLIN	95765	CA	5	3	2606	Residential	Fri May 16 00:00:00 EDT 2008	346375	38.8078160000000025	-121.270008000000004
810	7697 ROSEHALL DR	ROSEVILLE	95678	CA	5	3	0	Residential	Fri May 16 00:00:00 EDT 2008	347225	38.7921800000000019	-121.28595
811	4821 HUTSON WAY	ELK GROVE	95757	CA	5	3	2877	Residential	Fri May 16 00:00:00 EDT 2008	349000	38.3862390000000033	-121.448159000000004
812	4509 WINJE DR	ANTELOPE	95843	CA	3	2	2960	Residential	Fri May 16 00:00:00 EDT 2008	350000	38.7095130000000012	-121.359357000000003
813	1965 LAURELHURST LN	LINCOLN	95648	CA	2	2	0	Residential	Fri May 16 00:00:00 EDT 2008	350000	38.8538690000000031	-121.271742000000003
814	6709 ROSE BRIDGE DR	ROSEVILLE	95678	CA	3	2	2172	Residential	Fri May 16 00:00:00 EDT 2008	350000	38.792461000000003	-121.275711000000001
815	281 SPYGLASS HL	ROSEVILLE	95678	CA	3	2	2100	Condo	Fri May 16 00:00:00 EDT 2008	350000	38.7621529999999979	-121.283450999999999
816	7709 RIVER VILLAGE DR	SACRAMENTO	95831	CA	3	2	1795	Residential	Fri May 16 00:00:00 EDT 2008	351000	38.4832120000000018	-121.540189999999996
817	4165 BRISBANE CIR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	356200	38.6860670000000013	-121.073413000000002
818	506 BEDFORD CT	ROSEVILLE	95661	CA	4	2	2295	Residential	Fri May 16 00:00:00 EDT 2008	360000	38.733984999999997	-121.236766000000003
819	9048 PINTO CANYON WAY	ROSEVILLE	95747	CA	4	3	2577	Residential	Fri May 16 00:00:00 EDT 2008	367463	38.7924930000000003	-121.331899000000007
820	2274 IVY BRIDGE DR	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	375000	38.7785610000000034	-121.362008000000003
821	14004 WALNUT AVE	WALNUT GROVE	95690	CA	3	1	1727	Residential	Fri May 16 00:00:00 EDT 2008	380000	38.2476589999999987	-121.515129000000002
822	6905 FRANKFORT CT	ELK GROVE	95758	CA	3	2	1485	Residential	Fri May 16 00:00:00 EDT 2008	380578	38.4291389999999993	-121.423444000000003
823	3621 WINTUN DR	CARMICHAEL	95608	CA	3	2	1655	Residential	Fri May 16 00:00:00 EDT 2008	386222	38.6299289999999971	-121.323086000000004
824	201 KIRKLAND CT	LINCOLN	95648	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	389000	38.8671250000000015	-121.319085000000001
825	12075 APPLESBURY CT	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	390000	38.5356999999999985	-121.224900000000005
826	1975 SIDESADDLE WAY	ROSEVILLE	95661	CA	3	2	2049	Residential	Fri May 16 00:00:00 EDT 2008	395500	38.737872000000003	-121.249025000000003
827	5420 ALMOND FALLS WAY	RANCHO CORDOVA	95742	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	396000	38.5273839999999979	-121.233530999999999
828	9677 PILLITERI CT	ELK GROVE	95757	CA	5	3	2875	Residential	Fri May 16 00:00:00 EDT 2008	397000	38.4055710000000019	-121.445186000000007
829	1515 EL CAMINO VERDE DR	LINCOLN	95648	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	400000	38.9048689999999979	-121.320750000000004
830	556 PLATT CIR	EL DORADO HILLS	95762	CA	4	2	2199	Residential	Fri May 16 00:00:00 EDT 2008	400000	38.6562989999999971	-121.079783000000006
831	1792 DIAMOND WOODS CIR	ROSEVILLE	95747	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	412500	38.8085809999999967	-121.327849999999998
832	1124 PERKINS WAY	SACRAMENTO	95818	CA	2	1	1304	Residential	Fri May 16 00:00:00 EDT 2008	413500	38.5516110000000012	-121.504436999999996
833	4748 SALEM WAY	CARMICHAEL	95608	CA	3	2	2334	Residential	Fri May 16 00:00:00 EDT 2008	415000	38.6341109999999972	-121.353375999999997
834	1484 RADCLIFFE WAY	AUBURN	95603	CA	4	3	2278	Residential	Fri May 16 00:00:00 EDT 2008	420454	38.9355789999999971	-121.079018000000005
835	51 AIKEN WAY	SACRAMENTO	95819	CA	3	1	1493	Residential	Fri May 16 00:00:00 EDT 2008	425000	38.5793260000000018	-121.442520000000002
836	2818 KNOLLWOOD DR	CAMERON PARK	95682	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	425000	38.6698049999999967	-120.999007000000006
837	1536 STONEY CROSS LN	LINCOLN	95648	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	433500	38.8600070000000031	-121.310946000000001
838	509 CASTILLIAN CT	ROSEVILLE	95747	CA	5	3	0	Residential	Fri May 16 00:00:00 EDT 2008	438000	38.8047729999999973	-121.341194999999999
839	700 HUNTER PL	FOLSOM	95630	CA	5	3	2787	Residential	Fri May 16 00:00:00 EDT 2008	441000	38.6605100000000022	-121.163689000000005
840	1240 FAY CIR	SACRAMENTO	95831	CA	5	3	2824	Residential	Fri May 16 00:00:00 EDT 2008	445000	38.5063710000000015	-121.514455999999996
841	1113 SANDWICK WAY	FOLSOM	95630	CA	4	3	3261	Residential	Fri May 16 00:00:00 EDT 2008	446000	38.673881999999999	-121.105076999999994
842	3108 DELWOOD WAY	SACRAMENTO	95821	CA	4	2	2053	Residential	Fri May 16 00:00:00 EDT 2008	450000	38.6215660000000014	-121.370881999999995
843	3212 CORNICHE LN	ROSEVILLE	95661	CA	4	3	2379	Residential	Fri May 16 00:00:00 EDT 2008	455000	38.7505769999999998	-121.232767999999993
844	2159 BECKETT DR	EL DORADO HILLS	95762	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	460000	38.6800920000000019	-121.036467000000002
845	4320 FOUR SEASONS RD	PLACERVILLE	95667	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	475000	38.6908669999999972	-120.693641
846	6401 MARSHALL RD	GARDEN VALLEY	95633	CA	3	2	0	Residential	Fri May 16 00:00:00 EDT 2008	490000	38.8425500000000028	-120.875399999999999
847	2089 BECKETT DR	EL DORADO HILLS	95762	CA	4	2	0	Residential	Fri May 16 00:00:00 EDT 2008	493000	38.6817780000000013	-121.035837999999998
848	6196 EDGEHILL DR	EL DORADO HILLS	95762	CA	5	4	0	Residential	Fri May 16 00:00:00 EDT 2008	508000	38.676130999999998	-121.038931000000005
849	200 HILLSFORD CT	ROSEVILLE	95747	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	511000	38.7800510000000003	-121.378718000000006
850	8217 PLUMERIA AVE	FAIR OAKS	95628	CA	3	2	3173	Residential	Fri May 16 00:00:00 EDT 2008	525000	38.6507349999999974	-121.258628000000002
851	4841 VILLAGE GREEN DR	EL DORADO HILLS	95762	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	533000	38.6640659999999983	-121.056735000000003
852	3863 LAS PASAS WAY	SACRAMENTO	95864	CA	3	1	1348	Residential	Fri May 16 00:00:00 EDT 2008	545000	38.5889359999999968	-121.373605999999995
853	820 DANA CT	AUBURN	95603	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	560000	38.8652459999999991	-121.094869000000003
854	1165 37TH ST	SACRAMENTO	95816	CA	2	1	1252	Residential	Fri May 16 00:00:00 EDT 2008	575000	38.5684380000000004	-121.457853999999998
855	203 CASCADE FALLS DR	FOLSOM	95630	CA	4	3	3229	Residential	Fri May 16 00:00:00 EDT 2008	575000	38.7039619999999971	-121.187100000000001
856	9880 IZILDA CT	SACRAMENTO	95829	CA	5	4	3863	Residential	Fri May 16 00:00:00 EDT 2008	598695	38.4532600000000002	-121.325729999999993
857	1800 AVONDALE DR	ROSEVILLE	95747	CA	5	3	0	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.7984480000000005	-121.344054
858	4620 BROMWICH CT	ROCKLIN	95677	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.772672	-121.220231999999996
859	620 KESWICK CT	GRANITE BAY	95746	CA	4	3	2356	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.7320959999999985	-121.219142000000005
860	4478 GREENBRAE RD	ROCKLIN	95677	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	600000	38.7811340000000015	-121.222801000000004
861	8432 BRIGGS DR	ROSEVILLE	95747	CA	5	3	3579	Residential	Fri May 16 00:00:00 EDT 2008	610000	38.7886099999999985	-121.339494999999999
862	200 CRADLE MOUNTAIN CT	EL DORADO HILLS	95762	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	622500	38.6477999999999966	-121.030900000000003
863	2065 IMPRESSIONIST WAY	EL DORADO HILLS	95762	CA	0	0	0	Residential	Fri May 16 00:00:00 EDT 2008	680000	38.6829609999999988	-121.033253000000002
864	2982 ABERDEEN LN	EL DORADO HILLS	95762	CA	4	3	0	Residential	Fri May 16 00:00:00 EDT 2008	879000	38.7066919999999968	-121.058869000000001
865	9401 BARREL RACER CT	WILTON	95693	CA	4	3	4400	Residential	Fri May 16 00:00:00 EDT 2008	884790	38.4152979999999999	-121.194857999999996
866	3720 VISTA DE MADERA	LINCOLN	95648	CA	3	3	0	Residential	Fri May 16 00:00:00 EDT 2008	1551	38.8516449999999978	-121.231741999999997
867	14151 INDIO DR	SLOUGHHOUSE	95683	CA	3	4	5822	Residential	Fri May 16 00:00:00 EDT 2008	2000	38.4904470000000032	-121.129337000000007
868	7401 TOULON LN	SACRAMENTO	95828	CA	4	2	1512	Residential	Thu May 15 00:00:00 EDT 2008	56950	38.4886279999999985	-121.387759000000003
869	9127 NEWHALL DR Unit 34	SACRAMENTO	95826	CA	1	1	611	Condo	Thu May 15 00:00:00 EDT 2008	60000	38.5424190000000024	-121.359904
870	5937 BAMFORD DR	SACRAMENTO	95823	CA	2	1	876	Residential	Thu May 15 00:00:00 EDT 2008	61000	38.4711390000000009	-121.432254999999998
871	5672 HILLSDALE BLVD	SACRAMENTO	95842	CA	2	1	933	Condo	Thu May 15 00:00:00 EDT 2008	62000	38.6704670000000021	-121.359798999999995
872	3920 39TH ST	SACRAMENTO	95820	CA	2	1	864	Residential	Thu May 15 00:00:00 EDT 2008	68566	38.5392129999999966	-121.463930000000005
873	701 JESSIE AVE	SACRAMENTO	95838	CA	2	1	1011	Residential	Thu May 15 00:00:00 EDT 2008	70000	38.6439779999999971	-121.449562
874	83 ARCADE BLVD	SACRAMENTO	95815	CA	4	2	1158	Residential	Thu May 15 00:00:00 EDT 2008	80000	38.6187159999999992	-121.466327000000007
875	601 REGGINALD WAY	SACRAMENTO	95838	CA	3	2	1092	Residential	Thu May 15 00:00:00 EDT 2008	85500	38.6447199999999995	-121.452228000000005
876	550 DEL VERDE CIR	SACRAMENTO	95833	CA	2	1	956	Condo	Thu May 15 00:00:00 EDT 2008	92000	38.6271470000000008	-121.500799000000001
877	4113 DAYSTAR CT	SACRAMENTO	95824	CA	2	2	1139	Residential	Thu May 15 00:00:00 EDT 2008	93600	38.5204689999999985	-121.458606000000003
878	7374 TISDALE WAY	SACRAMENTO	95822	CA	3	1	1058	Residential	Thu May 15 00:00:00 EDT 2008	95000	38.4882380000000026	-121.472560999999999
879	3348 RIO LINDA BLVD	SACRAMENTO	95838	CA	3	2	1040	Residential	Thu May 15 00:00:00 EDT 2008	97750	38.6288419999999988	-121.446127000000004
880	3935 LIMESTONE WAY	SACRAMENTO	95823	CA	3	2	1354	Residential	Thu May 15 00:00:00 EDT 2008	104000	38.4843740000000025	-121.463156999999995
881	6208 GRATTAN WAY	NORTH HIGHLANDS	95660	CA	3	1	1051	Residential	Thu May 15 00:00:00 EDT 2008	105000	38.6792790000000011	-121.376615000000001
882	739 E WOODSIDE LN Unit E	SACRAMENTO	95825	CA	1	1	682	Condo	Thu May 15 00:00:00 EDT 2008	107666	38.5786749999999969	-121.409951000000007
883	4225 46TH AVE	SACRAMENTO	95824	CA	3	1	1161	Residential	Thu May 15 00:00:00 EDT 2008	109000	38.5118930000000006	-121.457676000000006
884	1434 BELL AVE	SACRAMENTO	95838	CA	3	1	1004	Residential	Thu May 15 00:00:00 EDT 2008	110000	38.6473980000000026	-121.432913999999997
885	5628 GEORGIA DR	NORTH HIGHLANDS	95660	CA	3	1	1229	Residential	Thu May 15 00:00:00 EDT 2008	110000	38.6695869999999999	-121.379879000000003
886	7629 BETH ST	SACRAMENTO	95832	CA	3	2	1249	Residential	Thu May 15 00:00:00 EDT 2008	112500	38.4801259999999985	-121.487869000000003
887	2277 BABETTE WAY	SACRAMENTO	95832	CA	3	2	1161	Residential	Thu May 15 00:00:00 EDT 2008	114800	38.4795930000000013	-121.484340000000003
888	6561 WEATHERFORD WAY	SACRAMENTO	95823	CA	3	1	1010	Residential	Thu May 15 00:00:00 EDT 2008	116000	38.4655509999999978	-121.426609999999997
889	3035 ESTEPA DR Unit 5C	CAMERON PARK	95682	CA	0	0	0	Condo	Thu May 15 00:00:00 EDT 2008	119000	38.6813929999999999	-120.996713
890	5136 CABOT CIR	SACRAMENTO	95820	CA	4	2	1462	Residential	Thu May 15 00:00:00 EDT 2008	121500	38.5284789999999973	-121.411805999999999
891	7730 ROBINETTE RD	SACRAMENTO	95828	CA	3	2	1269	Residential	Thu May 15 00:00:00 EDT 2008	122000	38.4770899999999969	-121.410568999999995
892	87 LACAM CIR	SACRAMENTO	95820	CA	2	2	1188	Residential	Thu May 15 00:00:00 EDT 2008	123675	38.5323589999999996	-121.411670000000001
893	1691 NOGALES ST	SACRAMENTO	95838	CA	4	2	1570	Residential	Thu May 15 00:00:00 EDT 2008	126854	38.6319250000000025	-121.427774999999997
894	3118 42ND ST	SACRAMENTO	95817	CA	3	2	1093	Residential	Thu May 15 00:00:00 EDT 2008	127059	38.546090999999997	-121.457745000000003
895	7517 50TH AVE	SACRAMENTO	95828	CA	3	1	962	Residential	Thu May 15 00:00:00 EDT 2008	128687	38.5073390000000018	-121.416267000000005
896	4071 EVALITA WAY	SACRAMENTO	95823	CA	3	2	1089	Residential	Thu May 15 00:00:00 EDT 2008	129500	38.466388000000002	-121.458860999999999
897	7928 36TH AVE	SACRAMENTO	95824	CA	3	2	1127	Residential	Thu May 15 00:00:00 EDT 2008	130000	38.5204900000000023	-121.411383000000001
898	6631 DEMARET DR	SACRAMENTO	95822	CA	4	2	1309	Residential	Thu May 15 00:00:00 EDT 2008	131750	38.5063820000000021	-121.483574000000004
899	7043 9TH AVE	RIO LINDA	95673	CA	2	1	970	Residential	Thu May 15 00:00:00 EDT 2008	132000	38.6955889999999982	-121.444132999999994
900	97 KENNELFORD CIR	SACRAMENTO	95823	CA	3	2	1144	Residential	Thu May 15 00:00:00 EDT 2008	134000	38.462375999999999	-121.426556000000005
901	2636 TRONERO WAY	RANCHO CORDOVA	95670	CA	3	1	1000	Residential	Thu May 15 00:00:00 EDT 2008	134000	38.5930490000000006	-121.303039999999996
902	1530 TOPANGA LN Unit 204	LINCOLN	95648	CA	0	0	0	Condo	Thu May 15 00:00:00 EDT 2008	138000	38.8841499999999982	-121.270276999999993
903	3604 KODIAK WAY	ANTELOPE	95843	CA	3	2	1206	Residential	Thu May 15 00:00:00 EDT 2008	142000	38.7061750000000018	-121.379776000000007
904	2149 COTTAGE WAY	SACRAMENTO	95825	CA	3	1	1285	Residential	Thu May 15 00:00:00 EDT 2008	143012	38.6035929999999965	-121.417011000000002
905	8632 PRAIRIEWOODS DR	SACRAMENTO	95828	CA	3	2	1543	Residential	Thu May 15 00:00:00 EDT 2008	145846	38.4775630000000035	-121.384382000000002
906	612 STONE BLVD	WEST SACRAMENTO	95691	CA	2	1	884	Residential	Thu May 15 00:00:00 EDT 2008	147000	38.5630840000000035	-121.535578999999998
907	4180 12TH AVE	SACRAMENTO	95817	CA	3	1	1019	Residential	Thu May 15 00:00:00 EDT 2008	148750	38.541170000000001	-121.458129
908	8025 ARROYO VISTA DR	SACRAMENTO	95823	CA	4	2	1392	Residential	Thu May 15 00:00:00 EDT 2008	150000	38.466540000000002	-121.419028999999995
909	5754 WALERGA RD Unit 4	SACRAMENTO	95842	CA	2	1	924	Condo	Thu May 15 00:00:00 EDT 2008	150454	38.6725670000000008	-121.356753999999995
910	8 LA ROCAS CT	SACRAMENTO	95823	CA	3	2	1217	Residential	Thu May 15 00:00:00 EDT 2008	151087	38.4661600000000021	-121.448283000000004
911	8636 LONGSPUR WAY	ANTELOPE	95843	CA	3	2	1670	Residential	Thu May 15 00:00:00 EDT 2008	157296	38.725873	-121.358559999999997
912	1941 EXPEDITION WAY	SACRAMENTO	95832	CA	3	2	1302	Residential	Thu May 15 00:00:00 EDT 2008	157500	38.4737750000000034	-121.493776999999994
913	4351 TURNBRIDGE DR	SACRAMENTO	95823	CA	3	2	1488	Residential	Thu May 15 00:00:00 EDT 2008	160000	38.5020340000000019	-121.456027000000006
914	6513 HOLIDAY WAY	NORTH HIGHLANDS	95660	CA	3	2	1373	Residential	Thu May 15 00:00:00 EDT 2008	160000	38.6853610000000003	-121.376937999999996
915	8321 MISTLETOE WAY	CITRUS HEIGHTS	95621	CA	4	2	1381	Residential	Thu May 15 00:00:00 EDT 2008	161250	38.7177379999999971	-121.308322000000004
916	5920 VALLEY GLEN WAY	SACRAMENTO	95823	CA	3	2	1265	Residential	Thu May 15 00:00:00 EDT 2008	164000	38.4628209999999982	-121.433134999999993
917	2601 SAN FERNANDO WAY	SACRAMENTO	95818	CA	2	1	881	Residential	Thu May 15 00:00:00 EDT 2008	165000	38.5561780000000027	-121.476256000000006
918	501 POPLAR AVE	WEST SACRAMENTO	95691	CA	0	0	0	Residential	Thu May 15 00:00:00 EDT 2008	165000	38.5845259999999968	-121.534609000000003
919	8008 SAINT HELENA CT	SACRAMENTO	95829	CA	4	2	1608	Residential	Thu May 15 00:00:00 EDT 2008	165750	38.4670119999999969	-121.359969000000007
920	6517 DONEGAL DR	CITRUS HEIGHTS	95621	CA	3	1	1344	Residential	Thu May 15 00:00:00 EDT 2008	166000	38.6815539999999984	-121.312933999999998
921	1001 RIO NORTE WAY	SACRAMENTO	95834	CA	3	2	1202	Residential	Thu May 15 00:00:00 EDT 2008	169000	38.6342920000000021	-121.485106000000002
922	604 P ST	LINCOLN	95648	CA	3	2	1104	Residential	Thu May 15 00:00:00 EDT 2008	170000	38.8931680000000028	-121.305397999999997
923	10001 WOODCREEK OAKS BLVD Unit 815	ROSEVILLE	95747	CA	2	2	0	Condo	Thu May 15 00:00:00 EDT 2008	170000	38.7955290000000019	-121.328818999999996
924	7351 GIGI PL	SACRAMENTO	95828	CA	4	2	1859	Multi-Family	Thu May 15 00:00:00 EDT 2008	170000	38.4906059999999997	-121.410173
925	7740 DIXIE LOU ST	SACRAMENTO	95832	CA	3	2	1232	Residential	Thu May 15 00:00:00 EDT 2008	170000	38.4758530000000007	-121.477039000000005
926	7342 DAVE ST	SACRAMENTO	95828	CA	3	1	1638	Residential	Thu May 15 00:00:00 EDT 2008	170725	38.4908220000000014	-121.401643000000007
927	7687 HOWERTON DR	SACRAMENTO	95831	CA	2	2	1177	Residential	Thu May 15 00:00:00 EDT 2008	171750	38.4808590000000024	-121.539744999999996
928	26 KAMSON CT	SACRAMENTO	95833	CA	3	2	1582	Residential	Thu May 15 00:00:00 EDT 2008	172000	38.622793999999999	-121.499172999999999
929	7045 PEEVEY CT	SACRAMENTO	95823	CA	2	2	904	Residential	Thu May 15 00:00:00 EDT 2008	173056	38.5022540000000006	-121.451443999999995
930	8916 GABLES MILL PL	ELK GROVE	95758	CA	3	2	1340	Residential	Thu May 15 00:00:00 EDT 2008	174000	38.4339190000000031	-121.422347000000002
931	1140 EDMONTON DR	SACRAMENTO	95833	CA	3	2	1204	Residential	Thu May 15 00:00:00 EDT 2008	174250	38.6245699999999985	-121.486913000000001
932	8879 APPLE PEAR CT	ELK GROVE	95624	CA	4	2	1477	Residential	Thu May 15 00:00:00 EDT 2008	176850	38.4457400000000007	-121.372500000000002
933	9 WIND CT	SACRAMENTO	95823	CA	4	2	1497	Residential	Thu May 15 00:00:00 EDT 2008	179500	38.4507300000000001	-121.427527999999995
934	8570 SHERATON DR	FAIR OAKS	95628	CA	3	1	960	Residential	Thu May 15 00:00:00 EDT 2008	185000	38.6672539999999998	-121.240707999999998
935	1550 TOPANGA LN Unit 207	LINCOLN	95648	CA	0	0	0	Condo	Thu May 15 00:00:00 EDT 2008	188000	38.8841699999999975	-121.270222000000004
936	1080 RIO NORTE WAY	SACRAMENTO	95834	CA	3	2	1428	Residential	Thu May 15 00:00:00 EDT 2008	188700	38.6343350000000001	-121.486097999999998
937	5501 VALLETTA WAY	SACRAMENTO	95820	CA	3	1	1039	Residential	Thu May 15 00:00:00 EDT 2008	189000	38.5301439999999999	-121.437489999999997
938	5624 MEMORY LN	FAIR OAKS	95628	CA	3	1	1529	Residential	Thu May 15 00:00:00 EDT 2008	189000	38.6674500000000023	-121.236400000000003
939	6622 WILLOWLEAF DR	CITRUS HEIGHTS	95621	CA	4	3	1892	Residential	Thu May 15 00:00:00 EDT 2008	189836	38.6997140000000002	-121.311634999999995
940	27 MEGAN CT	SACRAMENTO	95838	CA	4	2	1887	Residential	Thu May 15 00:00:00 EDT 2008	190000	38.6492580000000032	-121.465307999999993
941	6601 WOODMORE OAKS DR	ORANGEVALE	95662	CA	3	2	1294	Residential	Thu May 15 00:00:00 EDT 2008	191250	38.6870059999999967	-121.254318999999995
942	1973 DANVERS WAY	SACRAMENTO	95832	CA	3	2	1638	Residential	Thu May 15 00:00:00 EDT 2008	191675	38.477567999999998	-121.492574000000005
943	8001 ARROYO VISTA DR	SACRAMENTO	95823	CA	3	2	1677	Residential	Thu May 15 00:00:00 EDT 2008	195500	38.4673400000000001	-121.419843
944	7409 VOYAGER WAY	CITRUS HEIGHTS	95621	CA	3	1	1073	Residential	Thu May 15 00:00:00 EDT 2008	198000	38.7007169999999974	-121.313299999999998
945	815 CROSSWIND DR	SACRAMENTO	95838	CA	3	2	1231	Residential	Thu May 15 00:00:00 EDT 2008	200000	38.6513860000000022	-121.450419999999994
946	5509 LAGUNA CREST WAY	ELK GROVE	95758	CA	3	2	1175	Residential	Thu May 15 00:00:00 EDT 2008	200000	38.4244199999999978	-121.440357000000006
947	8424 MERRY HILL WAY	ELK GROVE	95624	CA	3	2	1416	Residential	Thu May 15 00:00:00 EDT 2008	200000	38.4520750000000007	-121.366461000000001
948	1525 PENNSYLVANIA AVE	WEST SACRAMENTO	95691	CA	0	0	0	Residential	Thu May 15 00:00:00 EDT 2008	200100	38.5699430000000021	-121.527539000000004
949	5954 BRIDGECROSS DR	SACRAMENTO	95835	CA	3	2	1358	Residential	Thu May 15 00:00:00 EDT 2008	201528	38.6819699999999997	-121.500024999999994
950	8789 SEQUOIA WOOD CT	ELK GROVE	95624	CA	4	2	1609	Residential	Thu May 15 00:00:00 EDT 2008	204750	38.4388179999999977	-121.374430000000004
951	6600 SILVERTHORNE CIR	SACRAMENTO	95842	CA	4	3	1968	Residential	Thu May 15 00:00:00 EDT 2008	205000	38.6860700000000008	-121.342369000000005
952	2221 2ND AVE	SACRAMENTO	95818	CA	2	2	1089	Residential	Thu May 15 00:00:00 EDT 2008	205000	38.5557810000000032	-121.485331000000002
953	3230 SMATHERS WAY	CARMICHAEL	95608	CA	3	2	1296	Residential	Thu May 15 00:00:00 EDT 2008	205900	38.6233720000000034	-121.347665000000006
954	5209 LAGUNA CREST WAY	ELK GROVE	95758	CA	2	2	1189	Residential	Thu May 15 00:00:00 EDT 2008	207000	38.4244210000000024	-121.443915000000004
955	416 LEITCH AVE	SACRAMENTO	95815	CA	2	1	795	Residential	Thu May 15 00:00:00 EDT 2008	207973	38.6126939999999976	-121.456669000000005
956	2100 BEATTY WAY	ROSEVILLE	95747	CA	3	2	1371	Residential	Thu May 15 00:00:00 EDT 2008	208250	38.737881999999999	-121.308142000000004
957	6920 GILLINGHAM WAY	NORTH HIGHLANDS	95660	CA	3	1	1310	Residential	Thu May 15 00:00:00 EDT 2008	208318	38.6942790000000016	-121.373395000000002
958	82 WILDFLOWER DR	GALT	95632	CA	3	2	1262	Residential	Thu May 15 00:00:00 EDT 2008	209347	38.2597080000000034	-121.311616000000001
959	8652 BANTON CIR	ELK GROVE	95624	CA	4	2	1740	Residential	Thu May 15 00:00:00 EDT 2008	211500	38.4440000000000026	-121.370992999999999
960	8428 MISTY PASS WAY	ANTELOPE	95843	CA	3	2	1517	Residential	Thu May 15 00:00:00 EDT 2008	212000	38.722959000000003	-121.347115000000002
961	7958 ROSEVIEW WAY	SACRAMENTO	95828	CA	3	2	1450	Residential	Thu May 15 00:00:00 EDT 2008	213000	38.4678359999999984	-121.410365999999996
962	9020 LUKEN CT	ELK GROVE	95624	CA	3	2	1416	Residential	Thu May 15 00:00:00 EDT 2008	216000	38.4513979999999975	-121.366613999999998
963	7809 VALLECITOS WAY	SACRAMENTO	95828	CA	3	1	888	Residential	Thu May 15 00:00:00 EDT 2008	216021	38.5082170000000019	-121.411207000000005
964	8445 OLD AUBURN RD	CITRUS HEIGHTS	95610	CA	3	2	1882	Residential	Thu May 15 00:00:00 EDT 2008	219000	38.7154230000000013	-121.246742999999995
965	10085 ATKINS DR	ELK GROVE	95757	CA	3	2	1302	Residential	Thu May 15 00:00:00 EDT 2008	219794	38.3908929999999984	-121.437821
966	9185 CERROLINDA CIR	ELK GROVE	95758	CA	3	2	1418	Residential	Thu May 15 00:00:00 EDT 2008	220000	38.4244970000000023	-121.426595000000006
967	9197 CORTINA CIR	ROSEVILLE	95678	CA	3	2	0	Condo	Thu May 15 00:00:00 EDT 2008	220000	38.7931519999999992	-121.290025
968	5429 HESPER WAY	CARMICHAEL	95608	CA	4	2	1319	Residential	Thu May 15 00:00:00 EDT 2008	220000	38.6651039999999995	-121.315900999999997
969	1178 WARMWOOD CT	GALT	95632	CA	4	2	1770	Residential	Thu May 15 00:00:00 EDT 2008	220000	38.2895439999999994	-121.284606999999994
970	4900 ELUDE CT	SACRAMENTO	95842	CA	4	2	1627	Residential	Thu May 15 00:00:00 EDT 2008	223000	38.6967399999999984	-121.350519000000006
971	3557 SODA WAY	SACRAMENTO	95834	CA	0	0	0	Residential	Thu May 15 00:00:00 EDT 2008	224000	38.6310259999999985	-121.501879000000002
972	3528 SAINT GEORGE DR	SACRAMENTO	95821	CA	3	1	1040	Residential	Thu May 15 00:00:00 EDT 2008	224000	38.6294680000000028	-121.376445000000004
973	7381 WASHBURN WAY	NORTH HIGHLANDS	95660	CA	3	1	960	Residential	Thu May 15 00:00:00 EDT 2008	224252	38.7035499999999999	-121.375102999999996
974	2181 WINTERHAVEN CIR	CAMERON PARK	95682	CA	3	2	0	Residential	Thu May 15 00:00:00 EDT 2008	224500	38.6975699999999989	-120.995739
975	7540 HICKORY AVE	ORANGEVALE	95662	CA	3	1	1456	Residential	Thu May 15 00:00:00 EDT 2008	225000	38.7030559999999966	-121.235220999999996
976	5024 CHAMBERLIN CIR	ELK GROVE	95757	CA	3	2	1450	Residential	Thu May 15 00:00:00 EDT 2008	228000	38.3897559999999984	-121.446246000000002
977	2400 INVERNESS DR	LINCOLN	95648	CA	3	2	1358	Residential	Thu May 15 00:00:00 EDT 2008	229027	38.8978139999999968	-121.324691000000001
978	5 BISHOPGATE CT	SACRAMENTO	95823	CA	4	2	1329	Residential	Thu May 15 00:00:00 EDT 2008	229500	38.4679360000000017	-121.445476999999997
979	5601 REXLEIGH DR	SACRAMENTO	95823	CA	4	2	1715	Residential	Thu May 15 00:00:00 EDT 2008	230000	38.4453419999999966	-121.441503999999995
980	1909 YARNELL WAY	ELK GROVE	95758	CA	3	2	1262	Residential	Thu May 15 00:00:00 EDT 2008	230000	38.4173820000000035	-121.484324999999998
981	9169 GARLINGTON CT	SACRAMENTO	95829	CA	4	3	2280	Residential	Thu May 15 00:00:00 EDT 2008	232425	38.4576789999999988	-121.359620000000007
982	6932 RUSKUT WAY	SACRAMENTO	95823	CA	3	2	1477	Residential	Thu May 15 00:00:00 EDT 2008	234000	38.4998930000000001	-121.458889999999997
983	7933 DAFFODIL WAY	CITRUS HEIGHTS	95610	CA	3	2	1216	Residential	Thu May 15 00:00:00 EDT 2008	235000	38.7088239999999999	-121.256803000000005
984	8304 RED FOX WAY	ELK GROVE	95758	CA	4	2	1685	Residential	Thu May 15 00:00:00 EDT 2008	235301	38.4170000000000016	-121.397424000000001
985	3882 YELLOWSTONE LN	EL DORADO HILLS	95762	CA	3	2	1362	Residential	Thu May 15 00:00:00 EDT 2008	235738	38.6552450000000007	-121.075914999999995
\.


--
-- Name: zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('zhdfdidvufqquhhowjjjfksukvgqbibm_id_seq', 985, true);


--
-- Name: column_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY column_meta
    ADD CONSTRAINT column_order_pkey PRIMARY KEY (id);


--
-- Name: fpvuhdtsqnbbrixsowqwwzmuftamkqlv_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY fpvuhdtsqnbbrixsowqwwzmuftamkqlv
    ADD CONSTRAINT fpvuhdtsqnbbrixsowqwwzmuftamkqlv_pkey PRIMARY KEY (id);


--
-- Name: nfpzglsypjyuhqausvglcsqzgdimaehl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY nfpzglsypjyuhqausvglcsqzgdimaehl
    ADD CONSTRAINT nfpzglsypjyuhqausvglcsqzgdimaehl_pkey PRIMARY KEY (id);


--
-- Name: oxvfmwsjsmespxihxfqzxpjzynyajche_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY oxvfmwsjsmespxihxfqzxpjzynyajche
    ADD CONSTRAINT oxvfmwsjsmespxihxfqzxpjzynyajche_pkey PRIMARY KEY (id);


--
-- Name: roujygtyrqhmfikbpoitmwbwdwzkggki_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roujygtyrqhmfikbpoitmwbwdwzkggki
    ADD CONSTRAINT roujygtyrqhmfikbpoitmwbwdwzkggki_pkey PRIMARY KEY (id);


--
-- Name: zhdfdidvufqquhhowjjjfksukvgqbibm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY zhdfdidvufqquhhowjjjfksukvgqbibm
    ADD CONSTRAINT zhdfdidvufqquhhowjjjfksukvgqbibm_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

