--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.11
-- Dumped by pg_dump version 9.2.2
-- Started on 2014-05-17 11:56:54

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

DROP DATABASE "BIM-test";
--
-- TOC entry 2061 (class 1262 OID 125465)
-- Name: BIM-test; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "BIM-test" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE "BIM-test" OWNER TO "postgres";

\connect "BIM-test"

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "public";


ALTER SCHEMA "public" OWNER TO "postgres";

--
-- TOC entry 2062 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 187 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2064 (class 0 OID 0)
-- Dependencies: 187
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


SET search_path = "public", pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 176 (class 1259 OID 127492)
-- Name: Cantieri; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Cantieri" (
    "Sezione" character varying(255) NOT NULL,
    "Numero" integer NOT NULL,
    "DataInizio" "date",
    "DataFine" "date",
    "Note" "text"
);


ALTER TABLE "public"."Cantieri" OWNER TO "postgres";

--
-- TOC entry 2065 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE "Cantieri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Cantieri" IS 'Tabella contenente l''elenco dei cantieri';


--
-- TOC entry 2066 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Cantieri"."Sezione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Sezione" IS 'Sezione del cantiere';


--
-- TOC entry 2067 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Cantieri"."Numero"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Numero" IS 'Numero progressivo del cantiere (0 iniziale)';


--
-- TOC entry 2068 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Cantieri"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataInizio" IS 'Data apertura del cantiere';


--
-- TOC entry 2069 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Cantieri"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataFine" IS 'Data chiusura del cantiere';


--
-- TOC entry 2070 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Cantieri"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Note" IS 'Campo note sul cantiere';


--
-- TOC entry 181 (class 1259 OID 127640)
-- Name: Interventi; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi" (
    "Codice" integer NOT NULL,
    "DataIntervento" timestamp with time zone DEFAULT "now"() NOT NULL,
    "Inizialized" boolean DEFAULT true NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Interventi" OWNER TO "postgres";

--
-- TOC entry 2071 (class 0 OID 0)
-- Dependencies: 181
-- Name: TABLE "Interventi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi" IS 'Tabella contenente gli interventi eseguiti';


--
-- TOC entry 2072 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Interventi"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."Codice" IS 'Codice associato all''intervento';


--
-- TOC entry 2073 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Interventi"."DataIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."DataIntervento" IS 'Data (e ora) in cui viene aperto l''intervento';


--
-- TOC entry 2074 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Interventi"."Inizialized"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."Inizialized" IS 'Indica se l''intervento è stato inserito completamente o se deve ancora rimanere in sospeso per aggiunte';


--
-- TOC entry 2075 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Interventi"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2076 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Interventi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 180 (class 1259 OID 127638)
-- Name: Interventi_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Interventi_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Interventi_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2077 (class 0 OID 0)
-- Dependencies: 180
-- Name: Interventi_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Interventi_Codice_seq" OWNED BY "Interventi"."Codice";


--
-- TOC entry 186 (class 1259 OID 127717)
-- Name: Interventi_InformazioniArcheologiche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniArcheologiche" (
    "CodiceIntervento" bigint NOT NULL
);


ALTER TABLE "public"."Interventi_InformazioniArcheologiche" OWNER TO "postgres";

--
-- TOC entry 2078 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE "Interventi_InformazioniArcheologiche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniArcheologiche" IS 'Tabella contenente le Informazioni Archeologiche sugli interventi';


--
-- TOC entry 2079 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Interventi_InformazioniArcheologiche"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniArcheologiche"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 185 (class 1259 OID 127707)
-- Name: Interventi_InformazioniArchitettoniche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniArchitettoniche" (
    "CodiceIntervento" bigint NOT NULL
);


ALTER TABLE "public"."Interventi_InformazioniArchitettoniche" OWNER TO "postgres";

--
-- TOC entry 2080 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE "Interventi_InformazioniArchitettoniche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniArchitettoniche" IS 'Tabella contenente le Informazioni Architettoniche sugli interventi';


--
-- TOC entry 2081 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Interventi_InformazioniArchitettoniche"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniArchitettoniche"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 184 (class 1259 OID 127682)
-- Name: Interventi_InformazioniDuomo; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniDuomo" (
    "CodiceIntervento" bigint NOT NULL,
    "Livello" character varying(255)
);


ALTER TABLE "public"."Interventi_InformazioniDuomo" OWNER TO "postgres";

--
-- TOC entry 2082 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE "Interventi_InformazioniDuomo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniDuomo" IS 'Tabella contenente le Informazioni aggiuntive per il Duomo sugli interventi';


--
-- TOC entry 2083 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Interventi_InformazioniDuomo"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniDuomo"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 2084 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Interventi_InformazioniDuomo"."Livello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniDuomo"."Livello" IS 'Correttivo manuale per il livello in caso di disparità';


--
-- TOC entry 183 (class 1259 OID 127669)
-- Name: Interventi_InformazioniPrincipali; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniPrincipali" (
    "CodiceIntervento" bigint NOT NULL,
    "DataInizio" "date",
    "DataFine" "date",
    "Descrizione" "text",
    "Note" "text"
);


ALTER TABLE "public"."Interventi_InformazioniPrincipali" OWNER TO "postgres";

--
-- TOC entry 2085 (class 0 OID 0)
-- Dependencies: 183
-- Name: TABLE "Interventi_InformazioniPrincipali"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniPrincipali" IS 'Tabella contenente le Informazioni Generiche sugli interventi';


--
-- TOC entry 2086 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Interventi_InformazioniPrincipali"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 2087 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Interventi_InformazioniPrincipali"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."DataInizio" IS 'Data di inizio reale dei lavori';


--
-- TOC entry 2088 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Interventi_InformazioniPrincipali"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."DataFine" IS 'Data di fine reale dei lavori';


--
-- TOC entry 2089 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Interventi_InformazioniPrincipali"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."Descrizione" IS 'Descrizione dell''intervento';


--
-- TOC entry 2090 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Interventi_InformazioniPrincipali"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."Note" IS 'Note sull''intervento';


--
-- TOC entry 177 (class 1259 OID 127501)
-- Name: MaterialeAggiuntivo; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "MaterialeAggiuntivo" (
    "Filename" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "TipoRiferimento" character varying(255),
    "ValoreRiferimento" character varying(255),
    "Qualità" integer DEFAULT 0 NOT NULL,
    "DataScatto" "date",
    "Descrizione" "text",
    "Permessi_lvl1" integer DEFAULT 7 NOT NULL,
    "Permessi_lvl2" integer DEFAULT 4 NOT NULL,
    "Permessi_lvl3" integer DEFAULT 0 NOT NULL,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "file" "bytea" NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255),
    "refSezione" character varying(255),
    "refZona" character varying(255),
    "refSettore" character varying(255),
    "refTipo" character varying(255)
);


ALTER TABLE "public"."MaterialeAggiuntivo" OWNER TO "postgres";

--
-- TOC entry 2091 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE "MaterialeAggiuntivo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeAggiuntivo" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2092 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2093 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2094 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2095 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2096 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2097 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2098 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2099 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2100 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2101 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2102 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2103 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2104 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2105 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2106 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "MaterialeAggiuntivo"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 179 (class 1259 OID 127620)
-- Name: MaterialeModelli; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "MaterialeModelli" (
    "CodiceModello" bigint NOT NULL,
    "URL" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "Descrizione" "text",
    "DataScatto" "date" NOT NULL,
    "Permessi_lvl1" integer DEFAULT 7,
    "Permessi_lvl2" integer DEFAULT 4,
    "Permessi_lvl3" integer DEFAULT 0,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "file" "bytea" NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."MaterialeModelli" OWNER TO "postgres";

--
-- TOC entry 2107 (class 0 OID 0)
-- Dependencies: 179
-- Name: TABLE "MaterialeModelli"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeModelli" IS 'Tabella contenente tutto il materiale (file) associato ai pezzi';


--
-- TOC entry 2108 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."CodiceModello" IS 'Codice del Modello a cui il materiale è associato';


--
-- TOC entry 2109 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."URL" IS 'URL del materiale';


--
-- TOC entry 2110 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2111 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2112 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2113 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2114 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2115 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2116 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2117 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2118 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2119 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2120 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "MaterialeModelli"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 178 (class 1259 OID 127586)
-- Name: MaterialePezzi; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "MaterialePezzi" (
    "CodicePezzo" bigint NOT NULL,
    "URL" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "Descrizione" "text",
    "DataScatto" "date" NOT NULL,
    "Permessi_lvl1" integer DEFAULT 7,
    "Permessi_lvl2" integer DEFAULT 4,
    "Permessi_lvl3" integer DEFAULT 0,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "file" "bytea" NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."MaterialePezzi" OWNER TO "postgres";

--
-- TOC entry 2121 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE "MaterialePezzi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialePezzi" IS 'Tabella contenente tutto il materiale (file) associato ai pezzi';


--
-- TOC entry 2122 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."CodicePezzo" IS 'Codice del pezzo a cui il materiale è associato';


--
-- TOC entry 2123 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."URL" IS 'URL del materiale';


--
-- TOC entry 2124 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2125 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2126 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2127 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2128 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2129 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2130 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2131 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2132 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2133 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2134 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "MaterialePezzi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 164 (class 1259 OID 125537)
-- Name: Modelli3D; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D" (
    "Codice" bigint NOT NULL,
    "Superficie" double precision,
    "Volume" double precision,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D" OWNER TO "postgres";

--
-- TOC entry 2135 (class 0 OID 0)
-- Dependencies: 164
-- Name: TABLE "Modelli3D"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D" IS 'Tabella di riferimento per i Modelli 3D';


--
-- TOC entry 2136 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Codice" IS 'Codice del Modello 3D (diverso dal codice del pezzo!!!) - PRIMARY KEY';


--
-- TOC entry 2137 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."Superficie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Superficie" IS 'Superficie del pezzo (calcolata dal modello 3D)';


--
-- TOC entry 2138 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."Volume"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Volume" IS 'Volume del pezzo (calcolato dal modello 3D)';


--
-- TOC entry 2139 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2140 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 167 (class 1259 OID 125614)
-- Name: Modelli3D_3dm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_3dm" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_3dm" OWNER TO "postgres";

--
-- TOC entry 2141 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE "Modelli3D_3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm" IS 'Tabella contenente i file 3dm dei Modelli 3D';


--
-- TOC entry 2142 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2143 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2144 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."file" IS 'File 3dm codificato in bytea';


--
-- TOC entry 2145 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2146 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 168 (class 1259 OID 125641)
-- Name: Modelli3D_Backup3dm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_Backup3dm" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_Backup3dm" OWNER TO "postgres";

--
-- TOC entry 2147 (class 0 OID 0)
-- Dependencies: 168
-- Name: TABLE "Modelli3D_Backup3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_Backup3dm" IS 'Tabella contenente il backup dei  file 3dm dei Modelli 3D';


--
-- TOC entry 163 (class 1259 OID 125535)
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Modelli3D_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Modelli3D_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2148 (class 0 OID 0)
-- Dependencies: 163
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Modelli3D_Codice_seq" OWNED BY "Modelli3D"."Codice";


--
-- TOC entry 165 (class 1259 OID 125548)
-- Name: Modelli3D_LoD; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_LoD" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "xc" double precision NOT NULL,
    "yc" double precision NOT NULL,
    "zc" double precision NOT NULL,
    "Radius" double precision NOT NULL,
    "3dm" boolean DEFAULT false NOT NULL,
    "JSON" boolean DEFAULT false NOT NULL,
    "JSON_NumeroParti" integer
);


ALTER TABLE "public"."Modelli3D_LoD" OWNER TO "postgres";

--
-- TOC entry 2149 (class 0 OID 0)
-- Dependencies: 165
-- Name: TABLE "Modelli3D_LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_LoD" IS 'Tabella di riferimento per i livelli di dettaglio dei Modelli 3D';


--
-- TOC entry 2150 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."CodiceModello" IS 'Riferimento al codice del Modello 3D';


--
-- TOC entry 2151 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."LoD" IS 'Level of Detail del modello 3D';


--
-- TOC entry 2152 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."xc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."xc" IS 'Coordinata x del centro';


--
-- TOC entry 2153 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."yc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."yc" IS 'Coordinata y del centro';


--
-- TOC entry 2154 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."zc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."zc" IS 'Coordinata z del centro';


--
-- TOC entry 2155 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."Radius"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Radius" IS 'Raggio del bounding box sferico';


--
-- TOC entry 2156 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm" IS 'Indica se è stato inserito nel database il file 3dm corrispondente';


--
-- TOC entry 2157 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON" IS 'Indica se è stato inserito nel database il file JSON corrispondente';


--
-- TOC entry 2158 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."JSON_NumeroParti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_NumeroParti" IS 'Qualora sia presente il file JSON, specifica in quanti parti viene suddiviso';


--
-- TOC entry 166 (class 1259 OID 125603)
-- Name: Modelli3D_PezziJSON; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_PezziJSON" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "Parte" integer NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_PezziJSON" OWNER TO "postgres";

--
-- TOC entry 2159 (class 0 OID 0)
-- Dependencies: 166
-- Name: TABLE "Modelli3D_PezziJSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_PezziJSON" IS 'Tabella contenente i file JSON dei Modelli 3D';


--
-- TOC entry 2160 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2161 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2162 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."Parte" IS 'Parte del file JSON';


--
-- TOC entry 2163 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."file" IS 'File JSON codificato in bytea';


--
-- TOC entry 2164 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2165 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 162 (class 1259 OID 125468)
-- Name: Pezzi; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi" (
    "Codice" bigint NOT NULL,
    "Sezione" character varying(255) NOT NULL,
    "Zona" character varying(255) NOT NULL,
    "Settore" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "Nome" character varying(255) NOT NULL,
    "Versione" integer DEFAULT 0 NOT NULL,
    "CodiceModello" bigint,
    "Originale" bigint DEFAULT 0 NOT NULL,
    "DataCreazione" timestamp with time zone DEFAULT "now"() NOT NULL,
    "DataEliminazione" timestamp with time zone,
    "Live" integer DEFAULT 4 NOT NULL,
    "CantiereCreazione" integer DEFAULT 0 NOT NULL,
    "CantiereEliminazione" integer,
    "Lock" character varying(255),
    "Updating" boolean DEFAULT false NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Pezzi" OWNER TO "postgres";

--
-- TOC entry 2166 (class 0 OID 0)
-- Dependencies: 162
-- Name: TABLE "Pezzi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi" IS 'Tabella contenente i pezzi (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2167 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Codice" IS 'Codice identificativo pezzo - PRIMARY KEY';


--
-- TOC entry 2168 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Sezione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Sezione" IS 'Sezione in cui è contenuto il pezzo';


--
-- TOC entry 2169 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Zona"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Zona" IS 'Zona in cui è contenuto il pezzo';


--
-- TOC entry 2170 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Settore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Settore" IS 'Settore in cui è contenuto il pezzo';


--
-- TOC entry 2171 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Tipo" IS 'Tipo del pezzo';


--
-- TOC entry 2172 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Nome"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Nome" IS 'Nome utilizzato per disambiguare due pezzi appartenenti alla stessa Sezione + Zona + Settore + Tipo';


--
-- TOC entry 2173 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Versione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Versione" IS 'Versione del pezzo, per disambiguare più pezzi che condividono lo stesso modello in tempi storici differenti (DEFAULT 0)';


--
-- TOC entry 2174 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CodiceModello" IS 'Codice del modello 3D del pezzo';


--
-- TOC entry 2175 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Originale" IS 'Se 0 è il pezzo originale, altrimenti è un pezzo modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2176 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."DataCreazione" IS 'Data (e ora) di creazione del pezzo';


--
-- TOC entry 2177 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."DataEliminazione" IS 'Data (e ora) di eliminazione del pezzo';


--
-- TOC entry 2178 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Live"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Live" IS 'll pezzo è attivo nel modello 3d corrente?

0 -> non attivo
1 -> live on-line
2 -> live on-line, ma morto (nuovo non pronto)
3 -> modello da creare di un pezzo che deve diventare on-line
4 -> inserito ex-novo da Rhino, da gestire e attivare
6 -> modello figlio creato, ma non on-line perché in attesa di modello di altri figli
8 -> non attivo e clonato

// 5 -> live on-line e clonato <- unused
// 7 -> live on-line e clonato, ma morto (nuovo non pronto) <- unused
// 9 -> da 6, attesa dipendenze <- unused';


--
-- TOC entry 2179 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CantiereCreazione" IS 'Cantiere nel quale è stato creato il pezzo';


--
-- TOC entry 2180 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato il pezzo';


--
-- TOC entry 2181 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Lock" IS 'Lock del file dell''utente specificato (i pezzi con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2182 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Updating" IS 'Pezzo in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2183 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2184 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 161 (class 1259 OID 125466)
-- Name: Pezzi_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pezzi_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Pezzi_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2185 (class 0 OID 0)
-- Dependencies: 161
-- Name: Pezzi_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_Codice_seq" OWNED BY "Pezzi"."Codice";


--
-- TOC entry 172 (class 1259 OID 127393)
-- Name: Pezzi_InformazioniArcheologiche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_InformazioniArcheologiche" (
    "CodicePezzo" bigint NOT NULL
);


ALTER TABLE "public"."Pezzi_InformazioniArcheologiche" OWNER TO "postgres";

--
-- TOC entry 2186 (class 0 OID 0)
-- Dependencies: 172
-- Name: TABLE "Pezzi_InformazioniArcheologiche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_InformazioniArcheologiche" IS 'Tabella contenente le Informazioni Archeologiche sui pezzi';


--
-- TOC entry 2187 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Pezzi_InformazioniArcheologiche"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniArcheologiche"."CodicePezzo" IS 'Codice del pezzo';


--
-- TOC entry 171 (class 1259 OID 125676)
-- Name: Pezzi_InformazioniArchitettoniche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_InformazioniArchitettoniche" (
    "CodicePezzo" bigint NOT NULL
);


ALTER TABLE "public"."Pezzi_InformazioniArchitettoniche" OWNER TO "postgres";

--
-- TOC entry 2188 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE "Pezzi_InformazioniArchitettoniche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_InformazioniArchitettoniche" IS 'Tabella contenente le Informazioni Architettoniche sui pezzi';


--
-- TOC entry 2189 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN "Pezzi_InformazioniArchitettoniche"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniArchitettoniche"."CodicePezzo" IS 'Codice del pezzo';


--
-- TOC entry 170 (class 1259 OID 125666)
-- Name: Pezzi_InformazioniDuomo; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_InformazioniDuomo" (
    "CodicePezzo" bigint NOT NULL,
    "DataMontaggio" "date",
    "DataSmontaggio" "date",
    "Sigla" character varying(255),
    "l" character varying(255),
    "p" character varying(255),
    "h" character varying(255),
    "DimaEntrata" "date",
    "DimaUscita" "date"
);


ALTER TABLE "public"."Pezzi_InformazioniDuomo" OWNER TO "postgres";

--
-- TOC entry 2190 (class 0 OID 0)
-- Dependencies: 170
-- Name: TABLE "Pezzi_InformazioniDuomo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_InformazioniDuomo" IS 'Tabella contenente le Informazioni aggiuntive per il Duomo sui pezzi';


--
-- TOC entry 2191 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."CodicePezzo" IS 'Codice del pezzo';


--
-- TOC entry 2192 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."DataMontaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."DataMontaggio" IS 'Data di montaggio del pezzo';


--
-- TOC entry 2193 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."DataSmontaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."DataSmontaggio" IS 'Data di smontaggio del pezzo';


--
-- TOC entry 2194 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."Sigla"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."Sigla" IS 'Sigla del pezzo';


--
-- TOC entry 2195 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."l"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."l" IS 'Campi tabella geometra';


--
-- TOC entry 2196 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."p"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."p" IS 'Campi tabella geometra';


--
-- TOC entry 2197 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."h"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."h" IS 'Campi tabella geometra';


--
-- TOC entry 2198 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."DimaEntrata"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."DimaEntrata" IS 'Campi tabella geometra';


--
-- TOC entry 2199 (class 0 OID 0)
-- Dependencies: 170
-- Name: COLUMN "Pezzi_InformazioniDuomo"."DimaUscita"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniDuomo"."DimaUscita" IS 'Campi tabella geometra';


--
-- TOC entry 169 (class 1259 OID 125656)
-- Name: Pezzi_InformazioniPrincipali; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_InformazioniPrincipali" (
    "CodicePezzo" bigint NOT NULL,
    "Descrizione" "text",
    "Note" "text",
    "NoteStoriche" "text"
);


ALTER TABLE "public"."Pezzi_InformazioniPrincipali" OWNER TO "postgres";

--
-- TOC entry 2200 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE "Pezzi_InformazioniPrincipali"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_InformazioniPrincipali" IS 'Tabella contenente le Informazioni Generiche sui pezzi';


--
-- TOC entry 2201 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Pezzi_InformazioniPrincipali"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniPrincipali"."CodicePezzo" IS 'Codice del pezzo';


--
-- TOC entry 2202 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Pezzi_InformazioniPrincipali"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniPrincipali"."Descrizione" IS 'Campo descrizione';


--
-- TOC entry 2203 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Pezzi_InformazioniPrincipali"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniPrincipali"."Note" IS 'Campo note';


--
-- TOC entry 2204 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Pezzi_InformazioniPrincipali"."NoteStoriche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_InformazioniPrincipali"."NoteStoriche" IS 'Campo per le note storiche';


--
-- TOC entry 182 (class 1259 OID 127649)
-- Name: Relazioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Relazioni" (
    "Padre" bigint NOT NULL,
    "Figlio" bigint NOT NULL,
    "Intervento" integer NOT NULL
);


ALTER TABLE "public"."Relazioni" OWNER TO "postgres";

--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE "Relazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Relazioni" IS 'Tabella contenente le relazioni padre <-> figlio (molti a molti) dei pezzi e li associa agli interventi

NB: creare prima voce corrispondente nei pezzi padre e figlio e nella tabella interventi';


--
-- TOC entry 2206 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Relazioni"."Padre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Relazioni"."Padre" IS 'Codice del padre';


--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Relazioni"."Figlio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Relazioni"."Figlio" IS 'Codice del figlio';


--
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Relazioni"."Intervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Relazioni"."Intervento" IS 'Codice intervento';


--
-- TOC entry 173 (class 1259 OID 127429)
-- Name: Utenti; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Utenti" (
    "User" character varying(255) NOT NULL,
    "Password" character varying NOT NULL,
    "FullName" character varying(255) NOT NULL,
    "Gruppi" character varying NOT NULL
);


ALTER TABLE "public"."Utenti" OWNER TO "postgres";

--
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE "Utenti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Utenti" IS 'Tabella accessi e permessi';


--
-- TOC entry 2210 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Utenti"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."User" IS 'Nome utente';


--
-- TOC entry 2211 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Utenti"."Password"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Password" IS 'Password dell''account';


--
-- TOC entry 2212 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Utenti"."FullName"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."FullName" IS 'Nome e cognome reale';


--
-- TOC entry 2213 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Utenti"."Gruppi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Gruppi" IS 'gruppi, separati da virgole e senza spazi';


--
-- TOC entry 175 (class 1259 OID 127439)
-- Name: VersionManager; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "VersionManager" (
    "Id" integer NOT NULL,
    "Version" character varying(10) NOT NULL,
    "ReleaseDate" "date" DEFAULT "now"(),
    "Testing" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."VersionManager" OWNER TO "postgres";

--
-- TOC entry 2214 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE "VersionManager"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "VersionManager" IS 'Tabella per il controllo della versione installata del software';


--
-- TOC entry 174 (class 1259 OID 127437)
-- Name: VersionManager_Id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "VersionManager_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."VersionManager_Id_seq" OWNER TO "postgres";

--
-- TOC entry 2215 (class 0 OID 0)
-- Dependencies: 174
-- Name: VersionManager_Id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "VersionManager_Id_seq" OWNED BY "VersionManager"."Id";


--
-- TOC entry 1989 (class 2604 OID 127643)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Interventi_Codice_seq"'::"regclass");


--
-- TOC entry 1962 (class 2604 OID 125540)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Modelli3D_Codice_seq"'::"regclass");


--
-- TOC entry 1954 (class 2604 OID 125471)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Pezzi_Codice_seq"'::"regclass");


--
-- TOC entry 1971 (class 2604 OID 127442)
-- Name: Id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "VersionManager" ALTER COLUMN "Id" SET DEFAULT "nextval"('"VersionManager_Id_seq"'::"regclass");


--
-- TOC entry 2028 (class 2606 OID 127648)
-- Name: Interventi-Key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi"
    ADD CONSTRAINT "Interventi-Key" PRIMARY KEY ("Codice");


--
-- TOC entry 2038 (class 2606 OID 127721)
-- Name: Interventi_InformazioniArcheologiche-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniArcheologiche"
    ADD CONSTRAINT "Interventi_InformazioniArcheologiche-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2036 (class 2606 OID 127711)
-- Name: Interventi_InformazioniArchitettoniche-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniArchitettoniche"
    ADD CONSTRAINT "Interventi_InformazioniArchitettoniche-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2034 (class 2606 OID 127686)
-- Name: Interventi_InformazioniDuomo-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniDuomo"
    ADD CONSTRAINT "Interventi_InformazioniDuomo-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2032 (class 2606 OID 127676)
-- Name: Interventi_InformazioniPrincipali-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniPrincipali"
    ADD CONSTRAINT "Interventi_InformazioniPrincipali-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2022 (class 2606 OID 127513)
-- Name: KeyMaterialeAggiuntivo; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialeAggiuntivo"
    ADD CONSTRAINT "KeyMaterialeAggiuntivo" PRIMARY KEY ("Filename");


--
-- TOC entry 2026 (class 2606 OID 127632)
-- Name: MaterialeModelli_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialeModelli"
    ADD CONSTRAINT "MaterialeModelli_pkey" PRIMARY KEY ("CodiceModello", "URL", "Qualità");


--
-- TOC entry 2024 (class 2606 OID 127598)
-- Name: Materiale_pezzi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialePezzi"
    ADD CONSTRAINT "Materiale_pezzi_pkey" PRIMARY KEY ("CodicePezzo", "URL", "Qualità");


--
-- TOC entry 1998 (class 2606 OID 125542)
-- Name: Modelli3D-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D"
    ADD CONSTRAINT "Modelli3D-primary-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2004 (class 2606 OID 125619)
-- Name: Modelli3D_3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2006 (class 2606 OID 125650)
-- Name: Modelli3D_Backup3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_Backup3dm"
    ADD CONSTRAINT "Modelli3D_Backup3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "LastUpdate");


--
-- TOC entry 2000 (class 2606 OID 125552)
-- Name: Modelli3D_LoD-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2002 (class 2606 OID 125607)
-- Name: Modelli3d_PezziJSON-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_PezziJSON"
    ADD CONSTRAINT "Modelli3d_PezziJSON-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 1994 (class 2606 OID 125477)
-- Name: Pezzi-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-key" PRIMARY KEY ("Codice");


--
-- TOC entry 1996 (class 2606 OID 125479)
-- Name: Pezzi-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-unicità" UNIQUE ("Sezione", "Zona", "Settore", "Tipo", "Nome", "Versione");


--
-- TOC entry 2014 (class 2606 OID 127397)
-- Name: Pezzi_InformazioniArcheologiche-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_InformazioniArcheologiche"
    ADD CONSTRAINT "Pezzi_InformazioniArcheologiche-primary-key" PRIMARY KEY ("CodicePezzo");


--
-- TOC entry 2012 (class 2606 OID 125680)
-- Name: Pezzi_InformazioniArchitettoniche-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_InformazioniArchitettoniche"
    ADD CONSTRAINT "Pezzi_InformazioniArchitettoniche-primary-key" PRIMARY KEY ("CodicePezzo");


--
-- TOC entry 2010 (class 2606 OID 125670)
-- Name: Pezzi_InformazioniDuomo-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_InformazioniDuomo"
    ADD CONSTRAINT "Pezzi_InformazioniDuomo-primary-key" PRIMARY KEY ("CodicePezzo");


--
-- TOC entry 2008 (class 2606 OID 125660)
-- Name: Pezzi_InformazioniPrincipali-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_InformazioniPrincipali"
    ADD CONSTRAINT "Pezzi_InformazioniPrincipali-primary-key" PRIMARY KEY ("CodicePezzo");


--
-- TOC entry 2030 (class 2606 OID 127653)
-- Name: Primary_Key_Relazioni; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Primary_Key_Relazioni" PRIMARY KEY ("Padre", "Figlio");


--
-- TOC entry 2016 (class 2606 OID 127436)
-- Name: Utenti-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Utenti"
    ADD CONSTRAINT "Utenti-key" PRIMARY KEY ("User");


--
-- TOC entry 2020 (class 2606 OID 127499)
-- Name: prim_key_cantieri; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Cantieri"
    ADD CONSTRAINT "prim_key_cantieri" PRIMARY KEY ("Sezione", "Numero");


--
-- TOC entry 2018 (class 2606 OID 127446)
-- Name: version_primkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "VersionManager"
    ADD CONSTRAINT "version_primkey" PRIMARY KEY ("Version");


--
-- TOC entry 2056 (class 2606 OID 127722)
-- Name: Interventi_InformazioniArcheologiche-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniArcheologiche"
    ADD CONSTRAINT "Interventi_InformazioniArcheologiche-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2055 (class 2606 OID 127712)
-- Name: Interventi_InformazioniArchitettoniche-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniArchitettoniche"
    ADD CONSTRAINT "Interventi_InformazioniArchitettoniche-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2054 (class 2606 OID 127697)
-- Name: Interventi_InformazioniDuomo-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniDuomo"
    ADD CONSTRAINT "Interventi_InformazioniDuomo-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2053 (class 2606 OID 127692)
-- Name: Interventi_InformazioniPrincipali-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniPrincipali"
    ADD CONSTRAINT "Interventi_InformazioniPrincipali-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2042 (class 2606 OID 127477)
-- Name: Modelli3D_3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2043 (class 2606 OID 127482)
-- Name: Modelli3D_Backup3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Backup3dm"
    ADD CONSTRAINT "Modelli3D_Backup3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2040 (class 2606 OID 127702)
-- Name: Modelli3D_LoD-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2041 (class 2606 OID 127487)
-- Name: Modelli3D_PezziJSON-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_PezziJSON"
    ADD CONSTRAINT "Modelli3D_PezziJSON-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2039 (class 2606 OID 127447)
-- Name: Pezzi-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 2047 (class 2606 OID 127457)
-- Name: Pezzi_InformazioniArcheologiche-key-Pezzi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_InformazioniArcheologiche"
    ADD CONSTRAINT "Pezzi_InformazioniArcheologiche-key-Pezzi" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2046 (class 2606 OID 127452)
-- Name: Pezzi_InformazioniArchitettoniche-key-Pezzi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_InformazioniArchitettoniche"
    ADD CONSTRAINT "Pezzi_InformazioniArchitettoniche-key-Pezzi" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2045 (class 2606 OID 127462)
-- Name: Pezzi_InformazioniDuomo-key-Pezzi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_InformazioniDuomo"
    ADD CONSTRAINT "Pezzi_InformazioniDuomo-key-Pezzi" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2044 (class 2606 OID 127467)
-- Name: Pezzi_InformazioniPrincipali-key-Pezzi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_InformazioniPrincipali"
    ADD CONSTRAINT "Pezzi_InformazioniPrincipali-key-Pezzi" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2049 (class 2606 OID 127633)
-- Name: Verifica_Codice_Modello; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeModelli"
    ADD CONSTRAINT "Verifica_Codice_Modello" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2048 (class 2606 OID 127604)
-- Name: Verifica_Codice_pezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialePezzi"
    ADD CONSTRAINT "Verifica_Codice_pezzo" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2050 (class 2606 OID 127654)
-- Name: Verifica_figlio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Verifica_figlio" FOREIGN KEY ("Figlio") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2051 (class 2606 OID 127659)
-- Name: Verifica_intervento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Verifica_intervento" FOREIGN KEY ("Intervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2052 (class 2606 OID 127664)
-- Name: Verifica_padre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Verifica_padre" FOREIGN KEY ("Padre") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2063 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA "public" FROM PUBLIC;
REVOKE ALL ON SCHEMA "public" FROM "postgres";
GRANT ALL ON SCHEMA "public" TO "postgres";
GRANT ALL ON SCHEMA "public" TO PUBLIC;


-- Completed on 2014-05-17 11:56:55

--
-- PostgreSQL database dump complete
--

