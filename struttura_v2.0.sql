--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.11
-- Dumped by pg_dump version 9.2.2
-- Started on 2014-11-28 14:57:03

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

DROP DATABASE "BIM3DSG_BIM-test";
--
-- TOC entry 2123 (class 1262 OID 125465)
-- Name: BIM3DSG_BIM-test; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "BIM3DSG_BIM-test" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE "BIM3DSG_BIM-test" OWNER TO "postgres";

\connect "BIM3DSG_BIM-test"

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
-- TOC entry 2124 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 193 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2126 (class 0 OID 0)
-- Dependencies: 193
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


SET search_path = "public", pg_catalog;

--
-- TOC entry 217 (class 1255 OID 152349)
-- Name: addimportnome("text", "text", "text", "text", "text", boolean, boolean, "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "addimportnome"("area" "text", "zona" "text", "sector" "text", "tipo" "text", "name" "text", "match" boolean, "rw" boolean, "username" "text", "removed" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	--maxCantiere "Cantieri"%ROWTYPE;
	selPezzi1 RECORD;

	colore int;
	cmod int;
	rwmod boolean;
	
	text_output text;
    
  BEGIN
	text_output:='';
  
	IF (area IS NULL OR area = '')
	THEN
	    area := '%';
	ELSE
	    IF (match = false)
	    THEN
		area := '%' || UPPER(area) || '%';
	    ELSE
		area := UPPER(area);
	    END IF;
	END IF;
	IF (zona IS NULL OR zona = '')
	THEN
	    zona := '%';
	ELSE
	    IF (match = false)
	    THEN
		zona := '%' || UPPER(zona) || '%';
	    ELSE
		zona := UPPER(zona);
	    END IF;
	END IF;
	IF (sector IS NULL OR sector = '')
	THEN
	    sector := '%';
	ELSE
	    IF (match = false)
	    THEN
		sector := '%' || UPPER(sector) || '%';
	    ELSE
		sector := UPPER(sector);
	    END IF;
	END IF;
	IF (tipo IS NULL OR tipo = '')
	THEN
	    tipo := '%';
	ELSE
	    IF (match = false)
	    THEN
		tipo := '%' || UPPER(tipo) || '%';
	    ELSE
		tipo := UPPER(tipo);
	    END IF;
	END IF;
	IF (name IS NULL OR name = '')
	THEN
	    name := '%';
	ELSE
	    IF (match = false)
	    THEN
		name := '%' || UPPER(name) || '%';
	    ELSE
		name := UPPER(name);
	    END IF;
	END IF;


	 --maxCantiere := (SELECT "area", MAX("Numero") AS num FROM "Cantieri" GROUP BY "area");
	--text_output := '';
	--FOR maxCantiere IN (SELECT "area", MAX("Numero") AS num FROM "Cantieri" GROUP BY "area") LOOP
	--	text_output := text_output || maxCantiere."area" || '__' || maxCantiere."Numero" || ' - ';
	--END LOOP;

	FOR selPezzi1 IN (SELECT "Codice", "Area", "Zone", "Sector", "Type", "Name", "Versione", "Originale", "CodiceModello", "CantiereCreazione", "CantiereEliminazione", "Live", "Lock" FROM "Pezzi" WHERE UPPER("Area") LIKE area AND UPPER("Zone") LIKE zona AND UPPER("Sector") LIKE sector AND UPPER("Type") LIKE tipo AND UPPER("Name") LIKE name ORDER BY "Versione") LOOP
		CASE selPezzi1."Live"
			WHEN 0 THEN
				IF (removed = true)
				THEN
					colore := 2;
				ELSE
					colore := -1;
				END IF;
			WHEN 8 THEN colore := -1;
				IF (removed = true)
				THEN
					colore := 2;
				ELSE
					colore := -1;
				END IF;
			WHEN 1 THEN colore := 1;
			WHEN 5 THEN colore := 1;
			WHEN 2 THEN colore := 2;
			WHEN 7 THEN colore := 2;
			WHEN 3 THEN colore := 3;
			WHEN 4 THEN colore := 4;
			WHEN 6 THEN colore := 6;
			WHEN 99 THEN colore := -1;
			ELSE colore := -1;
		END CASE;
		IF (colore != -1)
		THEN
			cmod := (SELECT num FROM "MaxCantieri" WHERE "Area" = selPezzi1."Area")  - selPezzi1."CantiereCreazione";
			IF (cmod > 3 OR (selPezzi1."CantiereCreazione" = 0 AND selPezzi1."Live" != 2 AND selPezzi1."Live" != 7))
			THEN
				cmod := 3;
			END IF;
			colore := colore + (cmod * 100);

			IF (selPezzi1."Originale" != 0)
			THEN
			    colore := colore + 50;
			END IF;

			IF ((rw = true) AND (selPezzi1."Lock" IS NOT NULL) AND (selPezzi1."Lock" != '') AND (selPezzi1."Lock" != username))
			THEN
				IF (text_output NOT LIKE ('%' || selPezzi1."Lock" || '%'))
				THEN
					text_output := text_output || selPezzi1."Lock" || ', ';
				END IF;
				rwmod := true;
				colore := colore + 20;
			ELSE
				IF (rw = true)
				THEN
					rwmod = false;
				ELSE
					rwmod = true;
					colore = colore + 20;
				END IF;
			END IF;

			BEGIN

				INSERT INTO "Import" ("User", "CodicePezzo", "CodiceModello", "Colore", "readonly") VALUES (username, selPezzi1."Codice", selPezzi1."CodiceModello", colore, rwmod);

				IF (rwmod = false)
				THEN
					UPDATE "Pezzi" SET "Lock" = username WHERE "Area" = selPezzi1."Area" AND "Zone" = selPezzi1."Zone" AND "Sector" = selPezzi1."Sector" AND "Type" = selPezzi1."Type" AND "Name" = selPezzi1."Name";
				END IF;
			EXCEPTION WHEN unique_violation THEN
			END;
                END IF;
	END LOOP;

	IF (text_output != '')
	THEN
		text_output = 'ATTENZIONE!!! Impossibile importare in modalità modifica (rw) alcuni file perché sono in corso di modifica da parte di ' ||  text_output || 'pertanto verranno settati per essere importati in sola lettura!';
	END IF;
	
	RETURN text_output;
--    RETURN 'success';
END;
$$;


ALTER FUNCTION "public"."addimportnome"("area" "text", "zona" "text", "sector" "text", "tipo" "text", "name" "text", "match" boolean, "rw" boolean, "username" "text", "removed" boolean) OWNER TO "postgres";

--
-- TOC entry 215 (class 1255 OID 144551)
-- Name: checkallmodelled(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "checkallmodelled"("codicepezzo" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo2 bigint;
	codiceModello bigint;

	selPezzi1 RECORD;
	selPezzi2 RECORD;

	auxint int;
  BEGIN
	-- find codice modello, live status
	SELECT "Live", "Versione", "CodiceModello" INTO selPezzi1 FROM "Pezzi" WHERE "Codice" = codicepezzo ORDER BY "Versione" DESC LIMIT 1;
	
	-- check live status and all modelled
	CASE selPezzi1."Live"
		WHEN 0, 1, 2, 4 THEN
			RAISE EXCEPTION 'Can''t check if all object is modelled for (id=%) because it isn''t wait for other object to be modelled!: DB can be in a inconsistent status! Can''t modified object (id=%): operation aborted!',codicePezzo,codicePezzo;
		WHEN 3 THEN
			RAISE EXCEPTION 'Can''t check if all object is modelled for (id=%) because it isn''t modelled!: DB can be in a inconsistent status! Can''t modified object (id=%): operation aborted!',codicePezzo,codicePezzo;
		WHEN 6 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	

	--todo




	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."checkallmodelled"("codicepezzo" bigint) OWNER TO "postgres";

--
-- TOC entry 205 (class 1255 OID 163909)
-- Name: deletepezziinfo(bigint, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deletepezziinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "Pezzi_Schede" WHERE "Codice" = codiceScheda AND "TitoloScheda" = titoloScheda AND "NomeCampo" = nomeCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deletepezziinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") OWNER TO "postgres";

--
-- TOC entry 213 (class 1255 OID 141138)
-- Name: preinitializemodifiedobject("text", "text", "text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceModello bigint;

	selPezzi1 RECORD;
	selModelliLoD1 RECORD;

	modified boolean;
	added boolean;
	
	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,area,zona,settore,tipo,nome;
	END IF;

	-- lock check
	auxint := (SELECT count(*) FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - name=%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',area,zona,settore,tipo,nome;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Versione", "CodiceModello" INTO selPezzi1 FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome ORDER BY "Versione" DESC LIMIT 1;
	
	CASE selPezzi1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
			added := true;
		WHEN 6 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
			added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "Pezzi" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome;
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "Pezzi" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome;
	END IF;

	-- update model
	UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selPezzi1."CodiceModello";

	-- remove old JSON
	DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "3dm" = false AND "Backup3dm" = false;
	DELETE FROM "Modelli3D_PezziJSON" WHERE "CodiceModello" = selPezzi1."CodiceModello";

	-- backup old 3dm
	FOR selModelliLoD1 IN (SELECT "LoD" FROM "Modelli3D_LoD" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "3dm" = true) LOOP
		--DELETE FROM "Modelli3D_Backup3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = selModelliLoD1."LastUpdate";
		INSERT INTO "Modelli3D_Backup3dm" (SELECT * FROM "Modelli3D_3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		-- DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";
		auxint := (SELECT COUNT(*) FROM "Modelli3D_Backup3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		IF (auxInt > 4) THEN
			DELETE FROM "Modelli3D_Backup3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = (SELECT "LastUpdate" FROM "Modelli3D_Backup3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" ORDER BY "LastUpdate" LIMIT 1);
		END IF;
	END LOOP;

	-- remove old 3dm
	DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";

	-- update Modelli3d LoD status
	UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "Backup3dm" = true, "3dm" = false, "JSON" = false WHERE "CodiceModello" = selPezzi1."CodiceModello" AND ("3dm" = true OR "Backup3dm" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "username" "text") OWNER TO "postgres";

--
-- TOC entry 214 (class 1255 OID 141127)
-- Name: preinitializenewobject("text", "text", "text", "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializenewobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceModello bigint;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - name=%): operation aborted!',username,area,zona,settore,tipo,nome;
	END IF;

	-- add a void model
	INSERT INTO "Modelli3D" ("LastUpdate", "LastUpdateBy") VALUES (now(), username) RETURNING "Codice" INTO codiceModello;

	-- add a new object
	INSERT INTO "Pezzi" ("Area", "Zone", "Sector", "Type", "Name", "Versione", "CodiceModello", "Originale", "DataCreazione", "DataEliminazione", 
		    "Live", "CantiereCreazione", "CantiereEliminazione", "Lock", "Updating", "LastUpdate", "LastUpdateBy")
	    VALUES (area, zona, settore, tipo, nome, 0, codiceModello, 0, now(), null,
		    1, 0, null, username, true, now(), username) RETURNING "Codice" INTO codicePezzo;

	-- add void object infos
	INSERT INTO "Pezzi_InformazioniArcheologiche" ("CodicePezzo") VALUES (codicePezzo);
	INSERT INTO "Pezzi_InformazioniArchitettoniche" ("CodicePezzo") VALUES (codicePezzo);
	INSERT INTO "Pezzi_InformazioniDuomo" ("CodicePezzo") VALUES (codicePezzo);
	INSERT INTO "Pezzi_InformazioniPrincipali" ("CodicePezzo") VALUES (codicePezzo);

	-- add cantiere if not exist
	auxint := (SELECT count(*) FROM "Cantieri" WHERE "Area" = area);
	IF (auxInt = 0) THEN
		INSERT INTO "Cantieri" ("Area", "Numero", "DataInizio") VALUES (area, 0, now());
	END IF;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."preinitializenewobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "username" "text") OWNER TO "postgres";

--
-- TOC entry 207 (class 1255 OID 163911)
-- Name: setpezziinfovalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Pezzi_Schede" ("Codice", "TitoloScheda", "NomeCampo", "BoolValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Pezzi_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 206 (class 1255 OID 163912)
-- Name: setpezziinfovalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL AND valore != '' AND trim(from valore) != '') THEN
		sql_insert := 'INSERT INTO "Pezzi_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TextValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "Pezzi_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 208 (class 1255 OID 163913)
-- Name: setpezziinfovalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Pezzi_Schede" ("Codice", "TitoloScheda", "NomeCampo", "IntValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Pezzi_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 209 (class 1255 OID 163914)
-- Name: setpezziinfovalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Pezzi_Schede" ("Codice", "TitoloScheda", "NomeCampo", "RealValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Pezzi_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 210 (class 1255 OID 163915)
-- Name: setpezziinfovalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Pezzi_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TimestampValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "Pezzi_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''' WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 218 (class 1255 OID 144552)
-- Name: updateobject("text", "text", "text", "text", "text", integer, double precision, double precision, double precision, double precision, double precision, double precision, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "updateobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceModello bigint;

	selPezzi1 RECORD;

	tmpRecord RECORD;

	sql_insert text;
	sql_update text;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - name=%): operation aborted!',username,area,zona,settore,tipo,nome;
	END IF;

	-- find codice modello, live status
	SELECT "Codice", "Live", "Versione", "CodiceModello" INTO selPezzi1 FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome ORDER BY "Versione" DESC LIMIT 1;
	
	-- check live status and all modelled
	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN
			RAISE EXCEPTION 'Can''t insert a model for a non preinizialized object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
		WHEN 6 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
			--check all modelled
			codicePezzo := selPezzi1."CodicePezzo";
			select checkallmodelled(codicePezzo) INTO tmpRecord;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	codiceModello := selPezzi1."CodiceModello";

	-- update volume, area
	UPDATE "Modelli3D" SET "Superficie"=superficie, "Volume"=volume, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = codiceModello AND "Superficie" IS NULL AND "Volume" IS NULL;

	-- insert or update LoD information
	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "Backup3dm") VALUES (' || codiceModello || ', ' || lod || ', ' || xcentro || ', ' || ycentro || ', ' || zcentro || ', ' || raggio || ', false, false, ' || parti || ', false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET xc = ' || xcentro || ', yc = ' || ycentro || ', zc = ' || zcentro || ', "Radius" = ' || raggio || ', "JSON_NumeroParti" = ' || parti || ' WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."updateobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 211 (class 1255 OID 143107)
-- Name: upload3dmfile("text", "text", "text", "text", "text", integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "upload3dmfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "lod" integer, "file3dm" "bytea", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceModello bigint;

	selPezzi1 RECORD;
	selModelliLoD1 RECORD;

	tmpRecord RECORD;

	modified boolean;
	added boolean;
	
	sql_insert text;
	sql_update text;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,area,zona,settore,tipo,nome;
	END IF;

	-- find codice modello
	SELECT "Live", "Versione", "CodiceModello" INTO selPezzi1 FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome ORDER BY "Versione" DESC LIMIT 1;

	codiceModello := selPezzi1."CodiceModello";

	--codiceModello := (SELECT "CodiceModello" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome ORDER BY "Versione" DESC LIMIT 1);

	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
		WHEN 6 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	-- update Modelli3d LoD status
	SELECT "CodiceModello", "3dm" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
	IF (selModelliLoD1."3dm" = true) THEN
		RAISE EXCEPTION 'There is already a 3dm file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
	END IF;

	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "Backup3dm") VALUES (' || codiceModello || ', '|| lod || ', 0, 0, 0, 0, true, false, null, false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET "3dm" = true WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

-- old one
--	SELECT "CodiceModello", "3dm" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
--	IF (selModelliLoD1 != null) THEN
--		IF (selModelliLoD1."3dm" == false) THEN
--			UPDATE "Modelli3D_LoD" SET "3dm" = true WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
--		ELSE
--			RAISE EXCEPTION 'There is already a 3dm file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
--		END IF;
--	ELSE
--		INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "Backup3dm")
--				    VALUES (codiceModello, lod, 0, 0, 0, 0, true, false, null, false);
--	END IF;

	INSERT INTO "Modelli3D_3dm"("CodiceModello", "LoD", file, "LastUpdate", "LastUpdateBy")
			    VALUES (codiceModello, lod, file3dm, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."upload3dmfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "lod" integer, "file3dm" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 212 (class 1255 OID 144564)
-- Name: uploadjsonfile("text", "text", "text", "text", "text", integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "uploadjsonfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceModello bigint;

	selPezzi1 RECORD;
	selModelliLoD1 RECORD;

	tmpRecord RECORD;

	modified boolean;
	added boolean;
	
	sql_insert text;
	sql_update text;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,area,zona,settore,tipo,nome;
	END IF;

	-- find codice modello
	SELECT "Live", "Versione", "CodiceModello" INTO selPezzi1 FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome ORDER BY "Versione" DESC LIMIT 1;

	codiceModello := selPezzi1."CodiceModello";

	--codiceModello := (SELECT "CodiceModello" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome ORDER BY "Versione" DESC LIMIT 1);

	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
		WHEN 6 THEN
			IF (selPezzi1."Versione" != 0) THEN
				RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
			END IF;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	-- update Modelli3d LoD status
	SELECT "CodiceModello", "JSON", "JSON_NumeroParti" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
--	IF (selModelliLoD1."JSON" = true) THEN
--		RAISE EXCEPTION 'There is already a JSON file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
--	END IF;

	IF (selModelliLoD1."CodiceModello" != codiceModello OR selModelliLoD1."JSON_NumeroParti" = 0) THEN
		RAISE EXCEPTION 'The value of JSON part''s number isn''t inserted for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
	END IF;

	UPDATE "Modelli3D_LoD" SET "JSON" = true WHERE "CodiceModello" = codiceModello AND "LoD" = lod;

	-- insert JSON files
	INSERT INTO "Modelli3D_PezziJSON"("CodiceModello", "LoD", "Parte", file, "LastUpdate", "LastUpdateBy")
				  VALUES (codiceModello, lod, parte, filejson, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."uploadjsonfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 216 (class 1255 OID 143517)
-- Name: upsert("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "upsert"("sql_insert" "text", "sql_update" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	auxint int;
 BEGIN
    -- first try to insert and after to update. Note : insert has pk and update not...
    LOOP
        -- first try to update
        EXECUTE sql_update;
        GET DIAGNOSTICS auxint = ROW_COUNT;

        -- check if the row is found
        --IF FOUND THEN
        IF (auxint>0) THEN
            RETURN;
        END IF;
        -- not found so insert the row
        BEGIN
            EXECUTE sql_insert;
            RETURN;
            EXCEPTION WHEN unique_violation THEN
                -- do nothing and loop
        END;
    END LOOP;
 END;
 $$;


ALTER FUNCTION "public"."upsert"("sql_insert" "text", "sql_update" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 172 (class 1259 OID 127492)
-- Name: Cantieri; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Cantieri" (
    "Area" character varying(255) NOT NULL,
    "Numero" integer NOT NULL,
    "DataInizio" "date",
    "DataFine" "date",
    "Note" "text"
);


ALTER TABLE "public"."Cantieri" OWNER TO "postgres";

--
-- TOC entry 2127 (class 0 OID 0)
-- Dependencies: 172
-- Name: TABLE "Cantieri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Cantieri" IS 'Tabella contenente l''elenco dei cantieri';


--
-- TOC entry 2128 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."Area"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Area" IS 'Area del cantiere';


--
-- TOC entry 2129 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."Numero"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Numero" IS 'Numero progressivo del cantiere (0 iniziale)';


--
-- TOC entry 2130 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataInizio" IS 'Data apertura del cantiere';


--
-- TOC entry 2131 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataFine" IS 'Data chiusura del cantiere';


--
-- TOC entry 2132 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Note" IS 'Campo note sul cantiere';


--
-- TOC entry 187 (class 1259 OID 157553)
-- Name: FileExtra; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "FileExtra" (
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


ALTER TABLE "public"."FileExtra" OWNER TO "postgres";

--
-- TOC entry 2133 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE "FileExtra"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "FileExtra" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2134 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2135 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2136 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2137 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2138 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2139 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2140 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2141 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2142 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2143 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2144 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2145 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2146 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2147 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2148 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "FileExtra"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 185 (class 1259 OID 152324)
-- Name: Import; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Import" (
    "User" character varying(255) NOT NULL,
    "CodicePezzo" bigint NOT NULL,
    "CodiceModello" bigint,
    "Colore" integer,
    "readonly" boolean,
    "NewAdded" boolean DEFAULT true
);


ALTER TABLE "public"."Import" OWNER TO "postgres";

--
-- TOC entry 2149 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE "Import"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Import" IS 'Tabella contenente le liste di importazione degli utenti';


--
-- TOC entry 2150 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Import"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."User" IS 'Nome dell''utente';


--
-- TOC entry 2151 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Import"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodicePezzo" IS 'Codice del pezzo da importare';


--
-- TOC entry 2152 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Import"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceModello" IS 'Codice del modello da importare';


--
-- TOC entry 2153 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Import"."Colore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."Colore" IS 'Codice del colore da associare all''oggetto da importare';


--
-- TOC entry 2154 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Import"."readonly"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."readonly" IS 'Identifica se importato in sola lettura (o modifica)';


--
-- TOC entry 2155 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Import"."NewAdded"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."NewAdded" IS 'Indica se è stato aggiunto alla lista di importazione e mai importato';


--
-- TOC entry 177 (class 1259 OID 127640)
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
-- TOC entry 2156 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE "Interventi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi" IS 'Tabella contenente gli interventi eseguiti';


--
-- TOC entry 2157 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Interventi"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."Codice" IS 'Codice associato all''intervento';


--
-- TOC entry 2158 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Interventi"."DataIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."DataIntervento" IS 'Data (e ora) in cui viene aperto l''intervento';


--
-- TOC entry 2159 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Interventi"."Inizialized"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."Inizialized" IS 'Indica se l''intervento è stato inserito completamente o se deve ancora rimanere in sospeso per aggiunte';


--
-- TOC entry 2160 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Interventi"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2161 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Interventi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 176 (class 1259 OID 127638)
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
-- TOC entry 2162 (class 0 OID 0)
-- Dependencies: 176
-- Name: Interventi_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Interventi_Codice_seq" OWNED BY "Interventi"."Codice";


--
-- TOC entry 182 (class 1259 OID 127717)
-- Name: Interventi_InformazioniArcheologiche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniArcheologiche" (
    "CodiceIntervento" bigint NOT NULL
);


ALTER TABLE "public"."Interventi_InformazioniArcheologiche" OWNER TO "postgres";

--
-- TOC entry 2163 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE "Interventi_InformazioniArcheologiche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniArcheologiche" IS 'Tabella contenente le Informazioni Archeologiche sugli interventi';


--
-- TOC entry 2164 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Interventi_InformazioniArcheologiche"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniArcheologiche"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 181 (class 1259 OID 127707)
-- Name: Interventi_InformazioniArchitettoniche; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniArchitettoniche" (
    "CodiceIntervento" bigint NOT NULL
);


ALTER TABLE "public"."Interventi_InformazioniArchitettoniche" OWNER TO "postgres";

--
-- TOC entry 2165 (class 0 OID 0)
-- Dependencies: 181
-- Name: TABLE "Interventi_InformazioniArchitettoniche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniArchitettoniche" IS 'Tabella contenente le Informazioni Architettoniche sugli interventi';


--
-- TOC entry 2166 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Interventi_InformazioniArchitettoniche"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniArchitettoniche"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 180 (class 1259 OID 127682)
-- Name: Interventi_InformazioniDuomo; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Interventi_InformazioniDuomo" (
    "CodiceIntervento" bigint NOT NULL,
    "Livello" character varying(255)
);


ALTER TABLE "public"."Interventi_InformazioniDuomo" OWNER TO "postgres";

--
-- TOC entry 2167 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE "Interventi_InformazioniDuomo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniDuomo" IS 'Tabella contenente le Informazioni aggiuntive per il Duomo sugli interventi';


--
-- TOC entry 2168 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Interventi_InformazioniDuomo"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniDuomo"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 2169 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Interventi_InformazioniDuomo"."Livello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniDuomo"."Livello" IS 'Correttivo manuale per il livello in caso di disparità';


--
-- TOC entry 179 (class 1259 OID 127669)
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
-- TOC entry 2170 (class 0 OID 0)
-- Dependencies: 179
-- Name: TABLE "Interventi_InformazioniPrincipali"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Interventi_InformazioniPrincipali" IS 'Tabella contenente le Informazioni Generiche sugli interventi';


--
-- TOC entry 2171 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Interventi_InformazioniPrincipali"."CodiceIntervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."CodiceIntervento" IS 'Riferimento al codice intervento';


--
-- TOC entry 2172 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Interventi_InformazioniPrincipali"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."DataInizio" IS 'Data di inizio reale dei lavori';


--
-- TOC entry 2173 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Interventi_InformazioniPrincipali"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."DataFine" IS 'Data di fine reale dei lavori';


--
-- TOC entry 2174 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Interventi_InformazioniPrincipali"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."Descrizione" IS 'Descrizione dell''intervento';


--
-- TOC entry 2175 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Interventi_InformazioniPrincipali"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Interventi_InformazioniPrincipali"."Note" IS 'Note sull''intervento';


--
-- TOC entry 183 (class 1259 OID 138575)
-- Name: Log_NumeroErrore_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Log_NumeroErrore_seq"
    START WITH 5004
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Log_NumeroErrore_seq" OWNER TO "postgres";

--
-- TOC entry 184 (class 1259 OID 138577)
-- Name: Log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Log" (
    "NumeroLog" bigint DEFAULT "nextval"('"Log_NumeroErrore_seq"'::"regclass") NOT NULL,
    "DateTime" timestamp without time zone NOT NULL,
    "Messaggio" "text" NOT NULL,
    "User" character varying(255)
);


ALTER TABLE "public"."Log" OWNER TO "postgres";

--
-- TOC entry 2176 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE "Log"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Log" IS 'Log degli errori';


--
-- TOC entry 2177 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Log"."DateTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."DateTime" IS 'Data e ora dell''evento';


--
-- TOC entry 2178 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Log"."Messaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."Messaggio" IS 'Messaggio di log';


--
-- TOC entry 2179 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Log"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."User" IS 'Utente che ha effettuato l''operazione';


--
-- TOC entry 173 (class 1259 OID 127501)
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
-- TOC entry 2180 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE "MaterialeAggiuntivo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeAggiuntivo" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2181 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2182 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2183 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2184 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2185 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2186 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2187 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2188 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2189 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2190 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2191 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2192 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2193 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2194 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2195 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "MaterialeAggiuntivo"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeAggiuntivo"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 175 (class 1259 OID 127620)
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
-- TOC entry 2196 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE "MaterialeModelli"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeModelli" IS 'Tabella contenente tutto il materiale (file) associato ai pezzi';


--
-- TOC entry 2197 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."CodiceModello" IS 'Codice del Modello a cui il materiale è associato';


--
-- TOC entry 2198 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."URL" IS 'URL del materiale';


--
-- TOC entry 2199 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2200 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2201 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2202 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2203 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2204 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2206 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "MaterialeModelli"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeModelli"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 174 (class 1259 OID 127586)
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
-- TOC entry 2210 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE "MaterialePezzi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialePezzi" IS 'Tabella contenente tutto il materiale (file) associato ai pezzi';


--
-- TOC entry 2211 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."CodicePezzo" IS 'Codice del pezzo a cui il materiale è associato';


--
-- TOC entry 2212 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."URL" IS 'URL del materiale';


--
-- TOC entry 2213 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2214 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2215 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2216 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2217 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2218 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2219 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2220 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2221 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2222 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2223 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "MaterialePezzi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 186 (class 1259 OID 152350)
-- Name: MaxCantieri; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "MaxCantieri" AS
    SELECT "Cantieri"."Area", "max"("Cantieri"."Numero") AS "num" FROM "Cantieri" GROUP BY "Cantieri"."Area";


ALTER TABLE "public"."MaxCantieri" OWNER TO "postgres";

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
-- TOC entry 2224 (class 0 OID 0)
-- Dependencies: 164
-- Name: TABLE "Modelli3D"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D" IS 'Tabella di riferimento per i Modelli 3D';


--
-- TOC entry 2225 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Codice" IS 'Codice del Modello 3D (diverso dal codice del pezzo!!!) - PRIMARY KEY';


--
-- TOC entry 2226 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."Superficie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Superficie" IS 'Superficie del pezzo (calcolata dal modello 3D)';


--
-- TOC entry 2227 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."Volume"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Volume" IS 'Volume del pezzo (calcolato dal modello 3D)';


--
-- TOC entry 2228 (class 0 OID 0)
-- Dependencies: 164
-- Name: COLUMN "Modelli3D"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2229 (class 0 OID 0)
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
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE "Modelli3D_3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm" IS 'Tabella contenente i file 3dm dei Modelli 3D';


--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2232 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2233 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."file" IS 'File 3dm codificato in bytea';


--
-- TOC entry 2234 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN "Modelli3D_3dm"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2235 (class 0 OID 0)
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
-- TOC entry 2236 (class 0 OID 0)
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
-- TOC entry 2237 (class 0 OID 0)
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
    "JSON_NumeroParti" integer,
    "Backup3dm" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."Modelli3D_LoD" OWNER TO "postgres";

--
-- TOC entry 2238 (class 0 OID 0)
-- Dependencies: 165
-- Name: TABLE "Modelli3D_LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_LoD" IS 'Tabella di riferimento per i livelli di dettaglio dei Modelli 3D';


--
-- TOC entry 2239 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."CodiceModello" IS 'Riferimento al codice del Modello 3D';


--
-- TOC entry 2240 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."LoD" IS 'Level of Detail del modello 3D';


--
-- TOC entry 2241 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."xc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."xc" IS 'Coordinata x del centro';


--
-- TOC entry 2242 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."yc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."yc" IS 'Coordinata y del centro';


--
-- TOC entry 2243 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."zc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."zc" IS 'Coordinata z del centro';


--
-- TOC entry 2244 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."Radius"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Radius" IS 'Raggio del bounding box sferico';


--
-- TOC entry 2245 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm" IS 'Indica se è stato inserito nel database il file 3dm corrispondente';


--
-- TOC entry 2246 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON" IS 'Indica se è stato inserito nel database il file JSON corrispondente';


--
-- TOC entry 2247 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."JSON_NumeroParti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_NumeroParti" IS 'Qualora sia presente il file JSON, specifica in quanti parti viene suddiviso';


--
-- TOC entry 2248 (class 0 OID 0)
-- Dependencies: 165
-- Name: COLUMN "Modelli3D_LoD"."Backup3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Backup3dm" IS 'Indica se è presente nel database un backup per il file 3dm corrispondente';


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
-- TOC entry 2249 (class 0 OID 0)
-- Dependencies: 166
-- Name: TABLE "Modelli3D_PezziJSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_PezziJSON" IS 'Tabella contenente i file JSON dei Modelli 3D';


--
-- TOC entry 2250 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2251 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2252 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."Parte" IS 'Parte del file JSON';


--
-- TOC entry 2253 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."file" IS 'File JSON codificato in bytea';


--
-- TOC entry 2254 (class 0 OID 0)
-- Dependencies: 166
-- Name: COLUMN "Modelli3D_PezziJSON"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_PezziJSON"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2255 (class 0 OID 0)
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
    "Area" character varying(255) NOT NULL,
    "Zone" character varying(255) NOT NULL,
    "Sector" character varying(255) NOT NULL,
    "Type" character varying(255) NOT NULL,
    "Name" character varying(255) NOT NULL,
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
-- TOC entry 2256 (class 0 OID 0)
-- Dependencies: 162
-- Name: TABLE "Pezzi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi" IS 'Tabella contenente i pezzi (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2257 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Codice" IS 'Codice identificativo pezzo - PRIMARY KEY';


--
-- TOC entry 2258 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Area"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Area" IS 'Area in cui è contenuto il pezzo';


--
-- TOC entry 2259 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Zone"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Zone" IS 'Zona in cui è contenuto il pezzo';


--
-- TOC entry 2260 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Sector"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Sector" IS 'Settore in cui è contenuto il pezzo';


--
-- TOC entry 2261 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Type" IS 'Tipo del pezzo';


--
-- TOC entry 2262 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Name" IS 'Nome utilizzato per disambiguare due pezzi appartenenti alla stessa Sezione + Zona + Settore + Tipo';


--
-- TOC entry 2263 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Versione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Versione" IS 'Versione del pezzo, per disambiguare più pezzi che condividono lo stesso modello in tempi storici differenti (DEFAULT 0)';


--
-- TOC entry 2264 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CodiceModello" IS 'Codice del modello 3D del pezzo';


--
-- TOC entry 2265 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Originale" IS 'Se 0 è il pezzo originale, altrimenti è un pezzo modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2266 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."DataCreazione" IS 'Data (e ora) di creazione del pezzo';


--
-- TOC entry 2267 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."DataEliminazione" IS 'Data (e ora) di eliminazione del pezzo';


--
-- TOC entry 2268 (class 0 OID 0)
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
-- TOC entry 2269 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CantiereCreazione" IS 'Cantiere nel quale è stato creato il pezzo';


--
-- TOC entry 2270 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato il pezzo';


--
-- TOC entry 2271 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Lock" IS 'Lock del file dell''utente specificato (i pezzi con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2272 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Updating" IS 'Pezzo in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2273 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN "Pezzi"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2274 (class 0 OID 0)
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
-- TOC entry 2275 (class 0 OID 0)
-- Dependencies: 161
-- Name: Pezzi_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_Codice_seq" OWNED BY "Pezzi"."Codice";


--
-- TOC entry 191 (class 1259 OID 161665)
-- Name: Pezzi_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_ListaInformazioni" (
    "Titolo" character varying(255) NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer
);


ALTER TABLE "public"."Pezzi_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2276 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE "Pezzi_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sui pezzi e dei relativi campi';


--
-- TOC entry 2277 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2278 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2279 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2280 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2281 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2282 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2283 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2284 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2285 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Pezzi_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 190 (class 1259 OID 161110)
-- Name: Pezzi_ListaSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "public"."Pezzi_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2286 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE "Pezzi_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2287 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "Pezzi_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 189 (class 1259 OID 161103)
-- Name: Pezzi_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_RelazioniSchede" (
    "CodicePezzo" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "public"."Pezzi_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2288 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Pezzi_RelazioniSchede"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_RelazioniSchede"."CodicePezzo" IS 'Codice del pezzo';


--
-- TOC entry 2289 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Pezzi_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 188 (class 1259 OID 161101)
-- Name: Pezzi_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pezzi_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Pezzi_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2290 (class 0 OID 0)
-- Dependencies: 188
-- Name: Pezzi_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_RelazioniSchede_CodiceScheda_seq" OWNED BY "Pezzi_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 192 (class 1259 OID 161684)
-- Name: Pezzi_Schede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_Schede" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone
);


ALTER TABLE "public"."Pezzi_Schede" OWNER TO "postgres";

--
-- TOC entry 2291 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE "Pezzi_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_Schede" IS 'Informazioni testuali sui pezzi';


--
-- TOC entry 2292 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2293 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2294 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2295 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2296 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2297 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2298 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2299 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "Pezzi_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 178 (class 1259 OID 127649)
-- Name: Relazioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Relazioni" (
    "Padre" bigint NOT NULL,
    "Figlio" bigint NOT NULL,
    "Intervento" integer NOT NULL
);


ALTER TABLE "public"."Relazioni" OWNER TO "postgres";

--
-- TOC entry 2300 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE "Relazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Relazioni" IS 'Tabella contenente le relazioni padre <-> figlio (molti a molti) dei pezzi e li associa agli interventi

NB: creare prima voce corrispondente nei pezzi padre e figlio e nella tabella interventi';


--
-- TOC entry 2301 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "Relazioni"."Padre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Relazioni"."Padre" IS 'Codice del padre';


--
-- TOC entry 2302 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "Relazioni"."Figlio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Relazioni"."Figlio" IS 'Codice del figlio';


--
-- TOC entry 2303 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "Relazioni"."Intervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Relazioni"."Intervento" IS 'Codice intervento';


--
-- TOC entry 169 (class 1259 OID 127429)
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
-- TOC entry 2304 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE "Utenti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Utenti" IS 'Tabella accessi e permessi';


--
-- TOC entry 2305 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Utenti"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."User" IS 'Nome utente';


--
-- TOC entry 2306 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Utenti"."Password"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Password" IS 'Password dell''account';


--
-- TOC entry 2307 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Utenti"."FullName"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."FullName" IS 'Nome e cognome reale';


--
-- TOC entry 2308 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN "Utenti"."Gruppi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Gruppi" IS 'gruppi, separati da virgole e senza spazi';


--
-- TOC entry 171 (class 1259 OID 127439)
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
-- TOC entry 2309 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE "VersionManager"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "VersionManager" IS 'Tabella per il controllo della versione installata del software';


--
-- TOC entry 170 (class 1259 OID 127437)
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
-- TOC entry 2310 (class 0 OID 0)
-- Dependencies: 170
-- Name: VersionManager_Id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "VersionManager_Id_seq" OWNED BY "VersionManager"."Id";


--
-- TOC entry 2027 (class 2604 OID 127643)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Interventi_Codice_seq"'::"regclass");


--
-- TOC entry 1999 (class 2604 OID 125540)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Modelli3D_Codice_seq"'::"regclass");


--
-- TOC entry 1991 (class 2604 OID 125471)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Pezzi_Codice_seq"'::"regclass");


--
-- TOC entry 2038 (class 2604 OID 161106)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"Pezzi_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2009 (class 2604 OID 127442)
-- Name: Id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "VersionManager" ALTER COLUMN "Id" SET DEFAULT "nextval"('"VersionManager_Id_seq"'::"regclass");


--
-- TOC entry 2086 (class 2606 OID 152328)
-- Name: Import_PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_PrimaryKey" PRIMARY KEY ("User", "CodicePezzo");


--
-- TOC entry 2072 (class 2606 OID 127648)
-- Name: Interventi-Key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi"
    ADD CONSTRAINT "Interventi-Key" PRIMARY KEY ("Codice");


--
-- TOC entry 2082 (class 2606 OID 127721)
-- Name: Interventi_InformazioniArcheologiche-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniArcheologiche"
    ADD CONSTRAINT "Interventi_InformazioniArcheologiche-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2080 (class 2606 OID 127711)
-- Name: Interventi_InformazioniArchitettoniche-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniArchitettoniche"
    ADD CONSTRAINT "Interventi_InformazioniArchitettoniche-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2078 (class 2606 OID 127686)
-- Name: Interventi_InformazioniDuomo-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniDuomo"
    ADD CONSTRAINT "Interventi_InformazioniDuomo-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2076 (class 2606 OID 127676)
-- Name: Interventi_InformazioniPrincipali-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Interventi_InformazioniPrincipali"
    ADD CONSTRAINT "Interventi_InformazioniPrincipali-key" PRIMARY KEY ("CodiceIntervento");


--
-- TOC entry 2088 (class 2606 OID 157565)
-- Name: KeyFileExtra; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "FileExtra"
    ADD CONSTRAINT "KeyFileExtra" PRIMARY KEY ("Filename");


--
-- TOC entry 2066 (class 2606 OID 127513)
-- Name: KeyMaterialeAggiuntivo; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialeAggiuntivo"
    ADD CONSTRAINT "KeyMaterialeAggiuntivo" PRIMARY KEY ("Filename");


--
-- TOC entry 2094 (class 2606 OID 161678)
-- Name: ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_ListaInformazioni"
    ADD CONSTRAINT "ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2070 (class 2606 OID 127632)
-- Name: MaterialeModelli_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialeModelli"
    ADD CONSTRAINT "MaterialeModelli_pkey" PRIMARY KEY ("CodiceModello", "URL", "Qualità");


--
-- TOC entry 2068 (class 2606 OID 127598)
-- Name: Materiale_pezzi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialePezzi"
    ADD CONSTRAINT "Materiale_pezzi_pkey" PRIMARY KEY ("CodicePezzo", "URL", "Qualità");


--
-- TOC entry 2050 (class 2606 OID 125542)
-- Name: Modelli3D-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D"
    ADD CONSTRAINT "Modelli3D-primary-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2056 (class 2606 OID 125619)
-- Name: Modelli3D_3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2058 (class 2606 OID 125650)
-- Name: Modelli3D_Backup3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_Backup3dm"
    ADD CONSTRAINT "Modelli3D_Backup3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "LastUpdate");


--
-- TOC entry 2052 (class 2606 OID 125552)
-- Name: Modelli3D_LoD-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2054 (class 2606 OID 125607)
-- Name: Modelli3d_PezziJSON-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_PezziJSON"
    ADD CONSTRAINT "Modelli3d_PezziJSON-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2046 (class 2606 OID 125477)
-- Name: Pezzi-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2048 (class 2606 OID 125479)
-- Name: Pezzi-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-unicità" UNIQUE ("Area", "Zone", "Sector", "Type", "Name", "Versione");


--
-- TOC entry 2092 (class 2606 OID 161114)
-- Name: Pezzi_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_ListaSchede"
    ADD CONSTRAINT "Pezzi_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2090 (class 2606 OID 161108)
-- Name: Pezzi_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede"
    ADD CONSTRAINT "Pezzi_RelazioniSchede_primaryKey" PRIMARY KEY ("CodicePezzo", "TitoloScheda");


--
-- TOC entry 2096 (class 2606 OID 161691)
-- Name: Pezzi_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_Schede"
    ADD CONSTRAINT "Pezzi_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2074 (class 2606 OID 127653)
-- Name: Primary_Key_Relazioni; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Primary_Key_Relazioni" PRIMARY KEY ("Padre", "Figlio");


--
-- TOC entry 2060 (class 2606 OID 127436)
-- Name: Utenti-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Utenti"
    ADD CONSTRAINT "Utenti-key" PRIMARY KEY ("User");


--
-- TOC entry 2084 (class 2606 OID 138585)
-- Name: chiave_errori_ins; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "chiave_errori_ins" PRIMARY KEY ("NumeroLog");


--
-- TOC entry 2064 (class 2606 OID 127499)
-- Name: prim_key_cantieri; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Cantieri"
    ADD CONSTRAINT "prim_key_cantieri" PRIMARY KEY ("Area", "Numero");


--
-- TOC entry 2062 (class 2606 OID 127446)
-- Name: version_primkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "VersionManager"
    ADD CONSTRAINT "version_primkey" PRIMARY KEY ("Version");


--
-- TOC entry 2111 (class 2606 OID 157823)
-- Name: Import_CodiceModelloRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceModelloRef" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2112 (class 2606 OID 157828)
-- Name: Import_CodicePezzoRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodicePezzoRef" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2113 (class 2606 OID 157833)
-- Name: Import_UserRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_UserRef" FOREIGN KEY ("User") REFERENCES "Utenti"("User") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2110 (class 2606 OID 127722)
-- Name: Interventi_InformazioniArcheologiche-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniArcheologiche"
    ADD CONSTRAINT "Interventi_InformazioniArcheologiche-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2109 (class 2606 OID 127712)
-- Name: Interventi_InformazioniArchitettoniche-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniArchitettoniche"
    ADD CONSTRAINT "Interventi_InformazioniArchitettoniche-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2108 (class 2606 OID 127697)
-- Name: Interventi_InformazioniDuomo-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniDuomo"
    ADD CONSTRAINT "Interventi_InformazioniDuomo-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2107 (class 2606 OID 127692)
-- Name: Interventi_InformazioniPrincipali-Interventi-codice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Interventi_InformazioniPrincipali"
    ADD CONSTRAINT "Interventi_InformazioniPrincipali-Interventi-codice" FOREIGN KEY ("CodiceIntervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2100 (class 2606 OID 127477)
-- Name: Modelli3D_3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2101 (class 2606 OID 127482)
-- Name: Modelli3D_Backup3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Backup3dm"
    ADD CONSTRAINT "Modelli3D_Backup3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2098 (class 2606 OID 141149)
-- Name: Modelli3D_LoD-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2099 (class 2606 OID 127487)
-- Name: Modelli3D_PezziJSON-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_PezziJSON"
    ADD CONSTRAINT "Modelli3D_PezziJSON-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2097 (class 2606 OID 141122)
-- Name: Pezzi-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 2116 (class 2606 OID 161679)
-- Name: Pezzi_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_ListaInformazioni"
    ADD CONSTRAINT "Pezzi_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "Pezzi_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2114 (class 2606 OID 161130)
-- Name: Pezzi_RelazioniSchede_refCodicePezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede"
    ADD CONSTRAINT "Pezzi_RelazioniSchede_refCodicePezzo" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2115 (class 2606 OID 161135)
-- Name: Pezzi_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede"
    ADD CONSTRAINT "Pezzi_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "Pezzi_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2117 (class 2606 OID 163648)
-- Name: Pezzi_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_Schede"
    ADD CONSTRAINT "Pezzi_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "Pezzi_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2118 (class 2606 OID 163653)
-- Name: Pezzi_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_Schede"
    ADD CONSTRAINT "Pezzi_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "Pezzi_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2103 (class 2606 OID 127633)
-- Name: Verifica_Codice_Modello; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeModelli"
    ADD CONSTRAINT "Verifica_Codice_Modello" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2102 (class 2606 OID 127604)
-- Name: Verifica_Codice_pezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialePezzi"
    ADD CONSTRAINT "Verifica_Codice_pezzo" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2104 (class 2606 OID 127654)
-- Name: Verifica_figlio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Verifica_figlio" FOREIGN KEY ("Figlio") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2105 (class 2606 OID 127659)
-- Name: Verifica_intervento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Verifica_intervento" FOREIGN KEY ("Intervento") REFERENCES "Interventi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2106 (class 2606 OID 127664)
-- Name: Verifica_padre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Relazioni"
    ADD CONSTRAINT "Verifica_padre" FOREIGN KEY ("Padre") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2125 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA "public" FROM PUBLIC;
REVOKE ALL ON SCHEMA "public" FROM "postgres";
GRANT ALL ON SCHEMA "public" TO "postgres";
GRANT ALL ON SCHEMA "public" TO PUBLIC;


-- Completed on 2014-11-28 14:57:05

--
-- PostgreSQL database dump complete
--

