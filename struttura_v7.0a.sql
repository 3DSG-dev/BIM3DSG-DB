--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.4
-- Dumped by pg_dump version 9.4.0
-- Started on 2015-09-24 00:30:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2355 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 209 (class 3079 OID 11870)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2357 (class 0 OID 0)
-- Dependencies: 209
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


SET search_path = "public", pg_catalog;

--
-- TOC entry 222 (class 1255 OID 430830)
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

	FOR selPezzi1 IN (SELECT "PezziVersioni"."Codice" AS "CodiceVersione", "CodicePezzo", "Area", "Zone", "Sector", "Type", "Name", "Versione", "Originale", "CodiceModello", "PezziVersioni"."CantiereCreazione", "PezziVersioni"."CantiereEliminazione", "Live", "Pezzi"."Lock" AS "PezziLock",  "PezziVersioni"."Lock" AS "PezziVersioneLock" FROM "Pezzi" JOIN "PezziVersioni" ON "Pezzi"."Codice" = "PezziVersioni"."CodicePezzo" WHERE UPPER("Area") LIKE area AND UPPER("Zone") LIKE zona AND UPPER("Sector") LIKE sector AND UPPER("Type") LIKE tipo AND UPPER("Name") LIKE name) LOOP
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

			IF ((rw = true) AND (selPezzi1."PezziLock" IS NOT NULL) AND (selPezzi1."PezziLock" != '') AND (selPezzi1."PezziLock" != username))
			THEN
				IF (text_output NOT LIKE ('%' || selPezzi1."PezziLock" || '%'))
				THEN
					text_output := text_output || selPezzi1."PezziLock" || ', ';
				END IF;
				rwmod := true;
				colore := colore + 20;
			ELSE IF ((rw = true) AND (selPezzi1."PezziVersioneLock" IS NOT NULL) AND (selPezzi1."PezziVersioneLock" != '') AND (selPezzi1."PezziVersioneLock" != username))
				THEN
					IF (text_output NOT LIKE ('%' || selPezzi1."PezziVersioneLock" || '%'))
					THEN
						text_output := text_output || selPezzi1."PezziVersioneLock" || ', ';
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
			END IF;

			BEGIN
				INSERT INTO "Import" ("User", "CodicePezzo", "CodiceVersione", "CodiceModello", "Colore", "readonly") VALUES (username, selPezzi1."CodicePezzo", selPezzi1."CodiceVersione", selPezzi1."CodiceModello", colore, rwmod);

				IF (rwmod = false)
				THEN
					UPDATE "Pezzi" SET "Lock" = username WHERE "Codice" = selPezzi1."CodicePezzo";
					UPDATE "PezziVersioni" SET "Lock" = username WHERE "Codice" = selPezzi1."CodiceVersione";
					UPDATE "PezziSubVersion" SET "Lock" = username WHERE "CodicePezzo" = selPezzi1."CodicePezzo" AND "CodiceVersione" = selPezzi1."CodiceVersione";
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
-- TOC entry 223 (class 1255 OID 430831)
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
	--SELECT "Live", "Versione", "CodiceModello" INTO selPezzi1 FROM "Pezzi" WHERE "Codice" = codicepezzo ORDER BY "Versione" DESC LIMIT 1;
	
	-- check live status and all modelled
	--CASE selPezzi1."Live"
	--	WHEN 0, 1, 2, 4 THEN
	--		RAISE EXCEPTION 'Can''t check if all object is modelled for (id=%) because it isn''t wait for other object to be modelled!: DB can be in a inconsistent status! Can''t modified object (id=%): operation aborted!',codicePezzo,codicePezzo;
	--	WHEN 3 THEN
	--		RAISE EXCEPTION 'Can''t check if all object is modelled for (id=%) because it isn''t modelled!: DB can be in a inconsistent status! Can''t modified object (id=%): operation aborted!',codicePezzo,codicePezzo;
	--	WHEN 6 THEN
	--		IF (selPezzi1."Versione" != 0) THEN
	--			RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
	--		END IF;
	--	ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	--END CASE;

	

	--todo




	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."checkallmodelled"("codicepezzo" bigint) OWNER TO "postgres";

--
-- TOC entry 224 (class 1255 OID 430832)
-- Name: deleteimportlist("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteimportlist"("username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "Import" WHERE "User" = username;

	UPDATE "Pezzi" SET "Lock" = null WHERE "Lock" = username;
	UPDATE "PezziVersioni" SET "Lock" = null WHERE "Lock" = username;
	UPDATE "PezziSubVersion" SET "Lock" = null WHERE "Lock" = username;
    RETURN 'success';
END;
$$;


ALTER FUNCTION "public"."deleteimportlist"("username" "text") OWNER TO "postgres";

--
-- TOC entry 225 (class 1255 OID 430833)
-- Name: deleteimportobject(bigint, bigint, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteimportobject"("codicepezzo" bigint, "codiceversione" bigint, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	locked int;
  BEGIN
	DELETE FROM "Import" WHERE "CodiceVersione" = codiceVersione AND "User" = username;

	UPDATE "PezziVersioni" SET "Lock" = null WHERE "Codice" = codiceVersione AND "Lock" = username;
	UPDATE "PezziSubVersion" SET "Lock" = null WHERE "CodiceVersione" = codiceVersione AND "Lock" = username;

	locked := (SELECT COUNT(*) FROM "Pezzi" JOIN "PezziVersioni" ON "Pezzi"."Codice" = "PezziVersioni"."CodicePezzo" WHERE "CodicePezzo" = codicePezzo AND "PezziVersioni"."Lock" = username);
	IF (locked = 0)
	THEN
		UPDATE "Pezzi" SET "Lock" = null WHERE "Lock" = username;
	END IF;

    RETURN 'success';
END;
$$;


ALTER FUNCTION "public"."deleteimportobject"("codicepezzo" bigint, "codiceversione" bigint, "username" "text") OWNER TO "postgres";

--
-- TOC entry 226 (class 1255 OID 430834)
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
-- TOC entry 227 (class 1255 OID 430835)
-- Name: deletepezziversioniinfo(bigint, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deletepezziversioniinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "PezziVersioni_Schede" WHERE "Codice" = codiceScheda AND "TitoloScheda" = titoloScheda AND "NomeCampo" = nomeCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deletepezziversioniinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") OWNER TO "postgres";

--
-- TOC entry 228 (class 1255 OID 430836)
-- Name: preinitializemodifiedobject("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
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


	codicePezzo := (SELECT "Codice" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome);
	-- lock check
	auxint := (SELECT count(*) FROM "PezziVersioni" WHERE "CodicePezzo" = codicePezzo AND "Versione" = versione AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - %__v%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',area,zona,settore,tipo,nome,versione;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Codice", "CodiceModello" INTO selPezzi1 FROM "PezziVersioni" WHERE "CodicePezzo" = codicePezzo AND "Versione" = versione;
	
	CASE selPezzi1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN added := true;
		WHEN 6 THEN added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - %__v%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome,versione;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "PezziVersioni" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selPezzi1."Codice";
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "PezziVersioni" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selPezzi1."Codice";
	END IF;

	-- update model
	UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selPezzi1."CodiceModello";

	-- remove old JSON
	DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selPezzi1."CodiceModello" AND "3dm" = false AND "Backup3dm" = false;
	DELETE FROM "Modelli3D_JSON" WHERE "CodiceModello" = selPezzi1."CodiceModello";

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

	-- remove textures
	DELETE FROM "Modelli3D_Texture" WHERE "CodiceModello" = selPezzi1."CodiceModello";

	-- update Modelli3d LoD status
	UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "Backup3dm" = true, "3dm" = false, "JSON" = false, "3dm_Texture" = false, "JSON_Texture" = false, "Texture" = false WHERE "CodiceModello" = selPezzi1."CodiceModello" AND ("3dm" = true OR "Backup3dm" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 229 (class 1255 OID 430837)
-- Name: preinitializenewobject("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializenewobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceVersione bigint;
	codiceModello bigint;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - %__v%): operation aborted!',username,area,zona,settore,tipo,nome, versione;
	END IF;

	-- add a void model
	INSERT INTO "Modelli3D" ("LastUpdate", "LastUpdateBy") VALUES (now(), username) RETURNING "Codice" INTO codiceModello;

	-- add a new object
	INSERT INTO "Pezzi"("Area", "Zone", "Sector", "Type", "Name", "DataCreazione", "DataEliminazione", "CantiereCreazione", "CantiereEliminazione", 
			"Lock", "LastUpdate", "LastUpdateBy")
		VALUES (area, zona, settore, tipo, nome, now(), null, 0, null,
			username, now(), username) RETURNING "Codice" INTO codicePezzo;

	INSERT INTO "PezziVersioni"("CodicePezzo", "Versione", "CodiceModello", "Originale", "DataCreazione", "DataEliminazione", "Live",
			"CantiereCreazione", "CantiereEliminazione", "Lock", "Updating", "LastUpdate", "LastUpdateBy")
	    VALUES (codicePezzo, versione, codiceModello, 0, now(), null, 1,
		    0, null, username, true, now(), username) RETURNING "Codice" INTO codiceVersione;


	INSERT INTO "PezziSubVersion"("CodicePezzo", "CodiceVersione", "SubVersion", "Originale", "DataCreazione", "DataEliminazione",
			"CantiereCreazione", "CantiereEliminazione", "Lock", "LastUpdate", "LastUpdateBy")
	    VALUES (codicePezzo, codiceVersione, 0, 0, now(), null, 
		    0, null, username, now(), username);

	
	-- add cantiere if not exist
	auxint := (SELECT count(*) FROM "Cantieri" WHERE "Area" = area);
	IF (auxInt = 0) THEN
		INSERT INTO "Cantieri" ("Area", "Numero", "DataInizio") VALUES (area, 0, now());
	END IF;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."preinitializenewobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 231 (class 1255 OID 430839)
-- Name: setpezziinfoschedavalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Pezzi_RelazioniSchede" WHERE "CodicePezzo" = codicepezzo AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Pezzi_RelazioniSchede"("CodicePezzo", "TitoloScheda") VALUES (codicepezzo, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 233 (class 1255 OID 430841)
-- Name: setpezziinfoschedavalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Pezzi_RelazioniSchede" WHERE "CodicePezzo" = codicepezzo AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Pezzi_RelazioniSchede"("CodicePezzo", "TitoloScheda") VALUES (codicepezzo, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 230 (class 1255 OID 430838)
-- Name: setpezziinfoschedavalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Pezzi_RelazioniSchede" WHERE "CodicePezzo" = codicepezzo AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Pezzi_RelazioniSchede"("CodicePezzo", "TitoloScheda") VALUES (codicepezzo, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 232 (class 1255 OID 430840)
-- Name: setpezziinfoschedavalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Pezzi_RelazioniSchede" WHERE "CodicePezzo" = codicepezzo AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Pezzi_RelazioniSchede"("CodicePezzo", "TitoloScheda") VALUES (codicepezzo, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 234 (class 1255 OID 430842)
-- Name: setpezziinfoschedavalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Pezzi_RelazioniSchede" WHERE "CodicePezzo" = codicepezzo AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Pezzi_RelazioniSchede"("CodicePezzo", "TitoloScheda") VALUES (codicepezzo, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziinfoschedavalue"("codicepezzo" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 236 (class 1255 OID 430844)
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
-- TOC entry 235 (class 1255 OID 430843)
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
-- TOC entry 237 (class 1255 OID 430845)
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
-- TOC entry 238 (class 1255 OID 430846)
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
-- TOC entry 239 (class 1255 OID 430847)
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
-- TOC entry 242 (class 1255 OID 430850)
-- Name: setpezziversioniinfoschedavalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "PezziVersioni_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "PezziVersioni_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 241 (class 1255 OID 430849)
-- Name: setpezziversioniinfoschedavalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "PezziVersioni_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "PezziVersioni_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 240 (class 1255 OID 430848)
-- Name: setpezziversioniinfoschedavalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "PezziVersioni_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "PezziVersioni_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 244 (class 1255 OID 430852)
-- Name: setpezziversioniinfoschedavalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "PezziVersioni_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "PezziVersioni_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 243 (class 1255 OID 430851)
-- Name: setpezziversioniinfoschedavalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "PezziVersioni_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "PezziVersioni_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setpezziversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 247 (class 1255 OID 430855)
-- Name: setpezziversioniinfovalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL AND valore != '' AND trim(from valore) != '') THEN
		sql_insert := 'INSERT INTO "PezziVersioni_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TextValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "PezziVersioni_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziVersioniInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 246 (class 1255 OID 430854)
-- Name: setpezziversioniinfovalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "PezziVersioni_Schede" ("Codice", "TitoloScheda", "NomeCampo", "BoolValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "PezziVersioni_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziVersioniInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 248 (class 1255 OID 430856)
-- Name: setpezziversioniinfovalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "PezziVersioni_Schede" ("Codice", "TitoloScheda", "NomeCampo", "IntValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "PezziVersioni_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziVersioniInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 249 (class 1255 OID 430857)
-- Name: setpezziversioniinfovalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "PezziVersioni_Schede" ("Codice", "TitoloScheda", "NomeCampo", "RealValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "PezziVersioni_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziVersioniInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 245 (class 1255 OID 430853)
-- Name: setpezziversioniinfovalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "PezziVersioni_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TimestampValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "PezziVersioni_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''' WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deletePezziVersioniInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setpezziversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 250 (class 1255 OID 430858)
-- Name: updateobject("text", "text", "text", "text", "text", integer, integer, double precision, double precision, double precision, double precision, double precision, double precision, integer, boolean, boolean, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "updateobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicePezzo bigint;
	codiceVersione bigint;
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
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - %__v%): operation aborted!',username,area,zona,settore,tipo,nome, versione;
	END IF;

	-- find codice pezzo
	codicePezzo := (SELECT "Codice" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome);
	
	-- find codice modello, live status
	SELECT "Codice", "Versione", "CodiceModello", "Live" INTO selPezzi1 FROM "PezziVersioni" WHERE "CodicePezzo" = codicePezzo AND "Versione" = versione;
	
	-- check live status and all modelled
	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN
			RAISE EXCEPTION 'Can''t insert a model for a non preinizialized object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',area,zona,settore,tipo,nome;
		WHEN 6 THEN
			--check all modelled
			codiceVersione := selPezzi1."Codice";
			select checkallmodelled(codiceVersione) INTO tmpRecord;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	codiceModello := selPezzi1."CodiceModello";

	-- update volume, area
	UPDATE "Modelli3D" SET "Superficie"=superficie, "Volume"=volume, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = codiceModello AND "Superficie" IS NULL AND "Volume" IS NULL;

	-- insert or update LoD information
	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "Backup3dm", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', ' || lod || ', ' || xcentro || ', ' || ycentro || ', ' || zcentro || ', ' || raggio || ', false, false, ' || parti || ', false, ' || texture_3dm || ',' || json_texture || ', false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET xc = ' || xcentro || ', yc = ' || ycentro || ', zc = ' || zcentro || ', "Radius" = ' || raggio || ', "JSON_NumeroParti" = ' || parti || ', "3dm_Texture" = ' || texture_3dm || ', "JSON_Texture" = ' || json_texture || ' WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."updateobject"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "username" "text") OWNER TO "postgres";

--
-- TOC entry 251 (class 1255 OID 430859)
-- Name: upload3dmfile("text", "text", "text", "text", "text", integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "upload3dmfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "lod" integer, "file3dm" "bytea", "username" "text") RETURNS "text"
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
	SELECT "Live", "CodiceModello" INTO selPezzi1 FROM "PezziVersioni" WHERE "CodicePezzo" = (SELECT "Codice" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selPezzi1."CodiceModello";

	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	-- update Modelli3d LoD status
	SELECT "CodiceModello", "3dm" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
	IF (selModelliLoD1."3dm" = true) THEN
		RAISE EXCEPTION 'There is already a 3dm file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
	END IF;

	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "Backup3dm", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', '|| lod || ', 0, 0, 0, 0, true, false, null, false, false, false, false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET "3dm" = true WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

	-- inserti 3dm file
	INSERT INTO "Modelli3D_3dm"("CodiceModello", "LoD", file, "LastUpdate", "LastUpdateBy")
			    VALUES (codiceModello, lod, file3dm, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."upload3dmfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "lod" integer, "file3dm" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 252 (class 1255 OID 430860)
-- Name: uploadjsonfile("text", "text", "text", "text", "text", integer, integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "uploadjsonfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") RETURNS "text"
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
	SELECT "Live", "CodiceModello" INTO selPezzi1 FROM "PezziVersioni" WHERE "CodicePezzo" = (SELECT "Codice" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selPezzi1."CodiceModello";

	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	-- update Modelli3d LoD status
	SELECT "CodiceModello", "JSON", "JSON_NumeroParti" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
--	IF (selModelliLoD1."JSON" = true) THEN
--		RAISE EXCEPTION 'There is already a JSON file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
--	END IF;

	IF (selModelliLoD1."CodiceModello" != codiceModello OR selModelliLoD1."JSON_NumeroParti" = 0 OR selModelliLoD1."JSON_NumeroParti" IS NULL) THEN
		RAISE EXCEPTION 'The value of JSON part''s number isn''t inserted for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,area,zona,settore,tipo,nome;
	END IF;

	UPDATE "Modelli3D_LoD" SET "JSON" = true WHERE "CodiceModello" = codiceModello AND "LoD" = lod;

	-- insert JSON files
	INSERT INTO "Modelli3D_JSON"("CodiceModello", "LoD", "Parte", file, "LastUpdate", "LastUpdateBy")
				  VALUES (codiceModello, lod, parte, filejson, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."uploadjsonfile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 253 (class 1255 OID 430861)
-- Name: uploadtexturefile("text", "text", "text", "text", "text", integer, integer, integer, "text", "bytea", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "uploadtexturefile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "textureindex" integer, "qualità" integer, "filename" "text", "filetexture" "bytea", "mimetype" "text", "username" "text") RETURNS "text"
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
	SELECT "Live", "CodiceModello" INTO selPezzi1 FROM "PezziVersioni" WHERE "CodicePezzo" = (SELECT "Codice" FROM "Pezzi" WHERE "Area" = area AND "Zone" = zona AND "Sector" = settore AND "Type" = tipo AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selPezzi1."CodiceModello";

	CASE selPezzi1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selPezzi1."Live",area,zona,settore,tipo,nome;
	END CASE;

	INSERT INTO "Modelli3D_Texture"("CodiceModello", "TextureNumber", "Qualità", "Filename", file, "MimeType", "LastUpdate", "LastUpdateBy")
				VALUES (codiceModello, textureIndex, qualità, filename, fileTexture, mimetype, now(), username);
 
	-- insert or update LoD information
	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "Backup3dm", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', ' || qualità || ', 0, 0, 0, 0, false, false, null, false, false, false, true)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET "Texture" = true WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || qualità;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;
	
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."uploadtexturefile"("area" "text", "zona" "text", "settore" "text", "tipo" "text", "nome" "text", "versione" integer, "textureindex" integer, "qualità" integer, "filename" "text", "filetexture" "bytea", "mimetype" "text", "username" "text") OWNER TO "postgres";

--
-- TOC entry 254 (class 1255 OID 430862)
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
-- TOC entry 172 (class 1259 OID 430863)
-- Name: Cantieri; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Cantieri" (
    "Area" character varying(255) NOT NULL,
    "Numero" integer NOT NULL,
    "DataInizio" "date",
    "DataFine" "date",
    "Note" "text"
);


ALTER TABLE "Cantieri" OWNER TO "postgres";

--
-- TOC entry 2358 (class 0 OID 0)
-- Dependencies: 172
-- Name: TABLE "Cantieri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Cantieri" IS 'Tabella contenente l''elenco dei cantieri';


--
-- TOC entry 2359 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."Area"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Area" IS 'Area del cantiere';


--
-- TOC entry 2360 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."Numero"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Numero" IS 'Numero progressivo del cantiere (0 iniziale)';


--
-- TOC entry 2361 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataInizio" IS 'Data apertura del cantiere';


--
-- TOC entry 2362 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataFine" IS 'Data chiusura del cantiere';


--
-- TOC entry 2363 (class 0 OID 0)
-- Dependencies: 172
-- Name: COLUMN "Cantieri"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Note" IS 'Campo note sul cantiere';


--
-- TOC entry 173 (class 1259 OID 430869)
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


ALTER TABLE "FileExtra" OWNER TO "postgres";

--
-- TOC entry 2364 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE "FileExtra"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "FileExtra" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2365 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2366 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2367 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2368 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2369 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2370 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2371 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2372 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2373 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2374 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2375 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2376 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2377 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2378 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2379 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "FileExtra"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 174 (class 1259 OID 430880)
-- Name: Import; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Import" (
    "User" character varying(255) NOT NULL,
    "CodicePezzo" bigint NOT NULL,
    "CodiceVersione" bigint NOT NULL,
    "CodiceModello" bigint,
    "Colore" integer,
    "readonly" boolean,
    "NewAdded" boolean DEFAULT true
);


ALTER TABLE "Import" OWNER TO "postgres";

--
-- TOC entry 2380 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE "Import"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Import" IS 'Tabella contenente le liste di importazione degli utenti';


--
-- TOC entry 2381 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."User" IS 'Nome dell''utente';


--
-- TOC entry 2382 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodicePezzo" IS 'Codice del pezzo da importare';


--
-- TOC entry 2383 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceVersione" IS 'Codice del pezzo+versione da importare';


--
-- TOC entry 2384 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceModello" IS 'Codice del modello da importare';


--
-- TOC entry 2385 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."Colore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."Colore" IS 'Codice del colore da associare all''oggetto da importare';


--
-- TOC entry 2386 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."readonly"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."readonly" IS 'Identifica se importato in sola lettura (o modifica)';


--
-- TOC entry 2387 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "Import"."NewAdded"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."NewAdded" IS 'Indica se è stato aggiunto alla lista di importazione e mai importato';


--
-- TOC entry 175 (class 1259 OID 430884)
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
    "3dm_Texture" boolean DEFAULT false NOT NULL,
    "JSON" boolean DEFAULT false NOT NULL,
    "JSON_NumeroParti" integer,
    "JSON_Texture" boolean DEFAULT false NOT NULL,
    "Texture" boolean DEFAULT false NOT NULL,
    "Backup3dm" boolean DEFAULT false NOT NULL
);


ALTER TABLE "Modelli3D_LoD" OWNER TO "postgres";

--
-- TOC entry 2388 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE "Modelli3D_LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_LoD" IS 'Tabella di riferimento per i livelli di dettaglio dei Modelli 3D';


--
-- TOC entry 2389 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."CodiceModello" IS 'Riferimento al codice del Modello 3D';


--
-- TOC entry 2390 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."LoD" IS 'Level of Detail del modello 3D';


--
-- TOC entry 2391 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."xc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."xc" IS 'Coordinata x del centro';


--
-- TOC entry 2392 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."yc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."yc" IS 'Coordinata y del centro';


--
-- TOC entry 2393 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."zc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."zc" IS 'Coordinata z del centro';


--
-- TOC entry 2394 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."Radius"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Radius" IS 'Raggio del bounding box sferico';


--
-- TOC entry 2395 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm" IS 'Indica se è stato inserito nel database il file 3dm corrispondente';


--
-- TOC entry 2396 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."3dm_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm_Texture" IS 'Specifica se il modello 3dm contiene le informazioni per la texture';


--
-- TOC entry 2397 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON" IS 'Indica se è stato inserito nel database il file JSON corrispondente';


--
-- TOC entry 2398 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."JSON_NumeroParti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_NumeroParti" IS 'Qualora sia presente il file JSON, specifica in quanti parti viene suddiviso';


--
-- TOC entry 2399 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."JSON_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_Texture" IS 'Specifica se il modello JSON contiene le informazioni per la texture';


--
-- TOC entry 2400 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Texture" IS 'Specifica se è stata inserita una texture';


--
-- TOC entry 2401 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Modelli3D_LoD"."Backup3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Backup3dm" IS 'Indica se è presente nel database un backup per il file 3dm corrispondente';


--
-- TOC entry 176 (class 1259 OID 430893)
-- Name: Pezzi; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi" (
    "Codice" bigint NOT NULL,
    "Area" character varying(255) NOT NULL,
    "Zone" character varying(255) NOT NULL,
    "Sector" character varying(255) NOT NULL,
    "Type" character varying(255) NOT NULL,
    "Name" character varying(255) NOT NULL,
    "DataCreazione" timestamp with time zone DEFAULT "now"() NOT NULL,
    "DataEliminazione" timestamp with time zone,
    "CantiereCreazione" integer DEFAULT 0 NOT NULL,
    "CantiereEliminazione" integer,
    "Lock" character varying(255),
    "Updating" boolean DEFAULT false NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Pezzi" OWNER TO "postgres";

--
-- TOC entry 2402 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE "Pezzi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi" IS 'Tabella contenente i pezzi (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2403 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Codice" IS 'Codice identificativo pezzo - PRIMARY KEY';


--
-- TOC entry 2404 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Area"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Area" IS 'Area in cui è contenuto il pezzo';


--
-- TOC entry 2405 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Zone"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Zone" IS 'Zona in cui è contenuto il pezzo';


--
-- TOC entry 2406 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Sector"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Sector" IS 'Settore in cui è contenuto il pezzo';


--
-- TOC entry 2407 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Type" IS 'Tipo del pezzo';


--
-- TOC entry 2408 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Name" IS 'Nome utilizzato per disambiguare due pezzi appartenenti alla stessa Sezione + Zona + Settore + Tipo';


--
-- TOC entry 2409 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."DataCreazione" IS 'Data (e ora) di creazione del pezzo';


--
-- TOC entry 2410 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."DataEliminazione" IS 'Data (e ora) di eliminazione del pezzo';


--
-- TOC entry 2411 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CantiereCreazione" IS 'Cantiere nel quale è stato creato il pezzo';


--
-- TOC entry 2412 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato il pezzo';


--
-- TOC entry 2413 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Lock" IS 'Lock del file dell''utente specificato (i pezzi con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2414 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."Updating" IS 'Pezzo in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2415 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2416 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Pezzi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 177 (class 1259 OID 430903)
-- Name: PezziVersioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziVersioni" (
    "Codice" bigint NOT NULL,
    "CodicePezzo" bigint NOT NULL,
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


ALTER TABLE "PezziVersioni" OWNER TO "postgres";

--
-- TOC entry 2417 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE "PezziVersioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziVersioni" IS 'Tabella contenente i pezzi (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2418 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."Codice" IS 'Codice identificativo pezzo+versione - PRIMARY KEY';


--
-- TOC entry 2419 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."CodicePezzo" IS 'Codice identificativo pezzo - PRIMARY KEY';


--
-- TOC entry 2420 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."Versione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."Versione" IS 'Versione del pezzo, per identificare variazioni del modello del pezzo in seguito ad interventi o cambiamenti (DEFAULT 0)';


--
-- TOC entry 2421 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."CodiceModello" IS 'Codice del modello 3D del pezzo+versione';


--
-- TOC entry 2422 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."Originale" IS 'Se 0 è il pezzo+versione originale, altrimenti è un pezzo modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2423 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."DataCreazione" IS 'Data (e ora) di creazione del pezzo+versione';


--
-- TOC entry 2424 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."DataEliminazione" IS 'Data (e ora) di eliminazione del pezzo+versione';


--
-- TOC entry 2425 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."Live"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."Live" IS 'll pezzo è attivo nel modello 3d corrente?

0 -> non attivo
1 -> live on-line
2 -> live on-line, ma morto (nuovo non pronto)
3 -> modello da creare di un pezzo che deve diventare on-line
4 -> inserito ex-novo da Rhino, da gestire e attivare
6 -> modello figlio creato, ma non on-line perché in attesa di modello di altri figli';


--
-- TOC entry 2426 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."CantiereCreazione" IS 'Cantiere nel quale è stato creato il pezzo+versione';


--
-- TOC entry 2427 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato il pezzo+versione';


--
-- TOC entry 2428 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."Lock" IS 'Lock del file dell''utente specificato (i pezzi con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2429 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."Updating" IS 'Pezzo in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2430 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2431 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "PezziVersioni"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 178 (class 1259 OID 430916)
-- Name: ListaPezziLoD; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "ListaPezziLoD" AS
 SELECT "PezziVersioni"."Codice",
    "Pezzi"."Area",
    "Pezzi"."Zone",
    "Pezzi"."Sector",
    "Pezzi"."Type",
    "Pezzi"."Name",
    "PezziVersioni"."CodiceModello",
    "PezziVersioni"."Originale",
    "PezziVersioni"."Live",
    "PezziVersioni"."DataCreazione",
    "PezziVersioni"."DataEliminazione",
    "Modelli3D_LoD"."LoD",
    "Modelli3D_LoD"."JSON",
    "Modelli3D_LoD"."JSON_NumeroParti",
    "Modelli3D_LoD"."xc",
    "Modelli3D_LoD"."yc",
    "Modelli3D_LoD"."zc",
    "Modelli3D_LoD"."Radius",
    "Modelli3D_LoD"."3dm_Texture" AS "Texture3dm",
    "Modelli3D_LoD"."JSON_Texture" AS "TextureJSON"
   FROM (("Pezzi"
     JOIN "PezziVersioni" ON (("Pezzi"."Codice" = "PezziVersioni"."CodicePezzo")))
     JOIN "Modelli3D_LoD" ON (("PezziVersioni"."CodiceModello" = "Modelli3D_LoD"."CodiceModello")))
  WHERE ((("PezziVersioni"."Live" = 1) OR ("PezziVersioni"."Live" = 2)) AND ("PezziVersioni"."Updating" = false))
  ORDER BY "PezziVersioni"."Codice", "Modelli3D_LoD"."LoD";


ALTER TABLE "ListaPezziLoD" OWNER TO "postgres";

--
-- TOC entry 179 (class 1259 OID 430921)
-- Name: Log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Log" (
    "NumeroLog" bigint NOT NULL,
    "DateTime" timestamp without time zone NOT NULL,
    "Messaggio" "text" NOT NULL,
    "User" character varying(255)
);


ALTER TABLE "Log" OWNER TO "postgres";

--
-- TOC entry 2432 (class 0 OID 0)
-- Dependencies: 179
-- Name: TABLE "Log"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Log" IS 'Log degli errori';


--
-- TOC entry 2433 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Log"."DateTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."DateTime" IS 'Data e ora dell''evento';


--
-- TOC entry 2434 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Log"."Messaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."Messaggio" IS 'Messaggio di log';


--
-- TOC entry 2435 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Log"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."User" IS 'Utente che ha effettuato l''operazione';


--
-- TOC entry 180 (class 1259 OID 430927)
-- Name: Log_NumeroLog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Log_NumeroLog_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Log_NumeroLog_seq" OWNER TO "postgres";

--
-- TOC entry 2436 (class 0 OID 0)
-- Dependencies: 180
-- Name: Log_NumeroLog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Log_NumeroLog_seq" OWNED BY "Log"."NumeroLog";


--
-- TOC entry 181 (class 1259 OID 430929)
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


ALTER TABLE "MaterialePezzi" OWNER TO "postgres";

--
-- TOC entry 2437 (class 0 OID 0)
-- Dependencies: 181
-- Name: TABLE "MaterialePezzi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialePezzi" IS 'Tabella contenente tutto il materiale (file) associato ai pezzi';


--
-- TOC entry 2438 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."CodicePezzo" IS 'Codice del pezzo a cui il materiale è associato';


--
-- TOC entry 2439 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."URL" IS 'URL del materiale';


--
-- TOC entry 2440 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2441 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2442 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2443 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2444 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2445 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2446 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2447 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2448 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2449 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2450 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "MaterialePezzi"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialePezzi"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 182 (class 1259 OID 430940)
-- Name: MaxCantieri; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "MaxCantieri" AS
 SELECT "Cantieri"."Area",
    "max"("Cantieri"."Numero") AS "num"
   FROM "Cantieri"
  GROUP BY "Cantieri"."Area";


ALTER TABLE "MaxCantieri" OWNER TO "postgres";

--
-- TOC entry 183 (class 1259 OID 430944)
-- Name: Modelli3D; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D" (
    "Codice" bigint NOT NULL,
    "Superficie" double precision,
    "Volume" double precision,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D" OWNER TO "postgres";

--
-- TOC entry 2451 (class 0 OID 0)
-- Dependencies: 183
-- Name: TABLE "Modelli3D"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D" IS 'Tabella di riferimento per i Modelli 3D';


--
-- TOC entry 2452 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Modelli3D"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Codice" IS 'Codice del Modello 3D (diverso dal codice del pezzo!!!) - PRIMARY KEY';


--
-- TOC entry 2453 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Modelli3D"."Superficie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Superficie" IS 'Superficie del pezzo (calcolata dal modello 3D)';


--
-- TOC entry 2454 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Modelli3D"."Volume"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Volume" IS 'Volume del pezzo (calcolato dal modello 3D)';


--
-- TOC entry 2455 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Modelli3D"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2456 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "Modelli3D"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 184 (class 1259 OID 430948)
-- Name: Modelli3D_3dm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_3dm" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D_3dm" OWNER TO "postgres";

--
-- TOC entry 2457 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE "Modelli3D_3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm" IS 'Tabella contenente i file 3dm dei Modelli 3D';


--
-- TOC entry 2458 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D_3dm"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2459 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D_3dm"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2460 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D_3dm"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."file" IS 'File 3dm codificato in bytea';


--
-- TOC entry 2461 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D_3dm"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2462 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D_3dm"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 185 (class 1259 OID 430956)
-- Name: Modelli3D_Backup3dm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_Backup3dm" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D_Backup3dm" OWNER TO "postgres";

--
-- TOC entry 2463 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE "Modelli3D_Backup3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_Backup3dm" IS 'Tabella contenente il backup dei  file 3dm dei Modelli 3D';


--
-- TOC entry 186 (class 1259 OID 430964)
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Modelli3D_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Modelli3D_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2464 (class 0 OID 0)
-- Dependencies: 186
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Modelli3D_Codice_seq" OWNED BY "Modelli3D"."Codice";


--
-- TOC entry 187 (class 1259 OID 430966)
-- Name: Modelli3D_JSON; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_JSON" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "Parte" integer NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D_JSON" OWNER TO "postgres";

--
-- TOC entry 2465 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE "Modelli3D_JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_JSON" IS 'Tabella contenente i file JSON dei Modelli 3D';


--
-- TOC entry 2466 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "Modelli3D_JSON"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2467 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "Modelli3D_JSON"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2468 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "Modelli3D_JSON"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."Parte" IS 'Parte del file JSON';


--
-- TOC entry 2469 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "Modelli3D_JSON"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."file" IS 'File JSON codificato in bytea';


--
-- TOC entry 2470 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "Modelli3D_JSON"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2471 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "Modelli3D_JSON"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 188 (class 1259 OID 430973)
-- Name: Modelli3D_Texture; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Modelli3D_Texture" (
    "CodiceModello" bigint NOT NULL,
    "TextureNumber" integer DEFAULT 0 NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "Filename" character varying(255) NOT NULL,
    "file" "bytea" NOT NULL,
    "MimeType" character varying(255),
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255) NOT NULL
);


ALTER TABLE "Modelli3D_Texture" OWNER TO "postgres";

--
-- TOC entry 2472 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE "Modelli3D_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_Texture" IS 'Tabella contenente le texture dei modelli';


--
-- TOC entry 2473 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2474 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."TextureNumber"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."TextureNumber" IS 'Numero dell''indice della texture (se è una texture sola è 0)';


--
-- TOC entry 2475 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."Qualità" IS '0 -> originale
1 -> 8192
2 -> 4096
3 -> 2048
4 -> 1024
5 -> 512
6 -> 256
7 -> 128';


--
-- TOC entry 2476 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."Filename" IS 'Nome del file';


--
-- TOC entry 2477 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."file" IS 'File salvato il bytea';


--
-- TOC entry 2478 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."MimeType"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."MimeType" IS 'MimeType del file';


--
-- TOC entry 2479 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."LastUpdate" IS 'Data dell''ultima modifica';


--
-- TOC entry 2480 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_Texture"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 189 (class 1259 OID 430982)
-- Name: PezziSubVersion; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziSubVersion" (
    "Codice" bigint NOT NULL,
    "CodicePezzo" bigint NOT NULL,
    "CodiceVersione" integer DEFAULT 0 NOT NULL,
    "SubVersion" integer DEFAULT 0 NOT NULL,
    "Originale" bigint DEFAULT 0 NOT NULL,
    "DataCreazione" timestamp with time zone DEFAULT "now"() NOT NULL,
    "DataEliminazione" timestamp with time zone,
    "CantiereCreazione" integer DEFAULT 0 NOT NULL,
    "CantiereEliminazione" integer,
    "Lock" character varying(255),
    "Updating" boolean DEFAULT false NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "PezziSubVersion" OWNER TO "postgres";

--
-- TOC entry 2481 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE "PezziSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziSubVersion" IS 'Tabella contenente i pezzi (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2482 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."Codice" IS 'Codice identificativo pezzo+versione - PRIMARY KEY';


--
-- TOC entry 2483 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."CodicePezzo" IS 'Codice identificativo pezzo - PRIMARY KEY';


--
-- TOC entry 2484 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."CodiceVersione" IS 'Codice identificativo pezzo+versione ';


--
-- TOC entry 2485 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."SubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."SubVersion" IS 'SubVersion del pezzo, per identificare variazioni in seguito ad interventi che non modificano il modello (DEFAULT 0)';


--
-- TOC entry 2486 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."Originale" IS 'Se 0 è il pezzo+versione originale, altrimenti è un pezzo modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2487 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."DataCreazione" IS 'Data (e ora) di creazione del pezzo+versione+subversion';


--
-- TOC entry 2488 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione del pezzo+versione+subversion';


--
-- TOC entry 2489 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato il pezzo+versione+subversion';


--
-- TOC entry 2490 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato il pezzo+versione+subversion';


--
-- TOC entry 2491 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."Lock" IS 'Lock del file dell''utente specificato (i pezzi con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2492 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."Updating" IS 'Pezzo in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2493 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2494 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "PezziSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 190 (class 1259 OID 430995)
-- Name: PezziSubVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziSubVersion_ListaInformazioni" (
    "Titolo" character varying(255) NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "PezziSubVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2495 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE "PezziSubVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziSubVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sui pezzi e dei relativi campi';


--
-- TOC entry 2496 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2497 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2498 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2499 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2500 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2501 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2502 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2503 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2504 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2505 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2506 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "PezziSubVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 191 (class 1259 OID 431010)
-- Name: PezziSubVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziSubVersion_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "PezziSubVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2507 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE "PezziSubVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziSubVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2508 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "PezziSubVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 192 (class 1259 OID 431013)
-- Name: PezziSubVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziSubVersion_RelazioniSchede" (
    "CodiceSubVersion" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "PezziSubVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2509 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE "PezziSubVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziSubVersion_RelazioniSchede" IS 'Relazioni tra i pezzi e le schede informative';


--
-- TOC entry 2510 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "PezziSubVersion_RelazioniSchede"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_RelazioniSchede"."CodiceSubVersion" IS 'Codice del pezzo';


--
-- TOC entry 2511 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "PezziSubVersion_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 193 (class 1259 OID 431016)
-- Name: PezziSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "PezziSubVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "PezziSubVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2512 (class 0 OID 0)
-- Dependencies: 193
-- Name: PezziSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "PezziSubVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "PezziSubVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 194 (class 1259 OID 431018)
-- Name: PezziSubVersion_Schede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziSubVersion_Schede" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone
);


ALTER TABLE "PezziSubVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 2513 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE "PezziSubVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziSubVersion_Schede" IS 'Informazioni testuali sui pezzi';


--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2516 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2517 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2518 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2519 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2521 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "PezziSubVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziSubVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 195 (class 1259 OID 431024)
-- Name: PezziVersioni_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziVersioni_ListaInformazioni" (
    "Titolo" character varying(255) NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "PezziVersioni_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2522 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE "PezziVersioni_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziVersioni_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sui pezzi e dei relativi campi';


--
-- TOC entry 2523 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2524 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2525 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2526 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2527 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2528 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2529 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2530 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2531 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2532 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2533 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "PezziVersioni_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 196 (class 1259 OID 431039)
-- Name: PezziVersioni_ListaSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziVersioni_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "PezziVersioni_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2534 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE "PezziVersioni_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziVersioni_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2535 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "PezziVersioni_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 197 (class 1259 OID 431042)
-- Name: PezziVersioni_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziVersioni_RelazioniSchede" (
    "CodiceVersione" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "PezziVersioni_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2536 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE "PezziVersioni_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziVersioni_RelazioniSchede" IS 'Relazioni tra i pezzi e le schede informative';


--
-- TOC entry 2537 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "PezziVersioni_RelazioniSchede"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_RelazioniSchede"."CodiceVersione" IS 'Codice del pezzo';


--
-- TOC entry 2538 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "PezziVersioni_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 198 (class 1259 OID 431045)
-- Name: PezziVersioni_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "PezziVersioni_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "PezziVersioni_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2539 (class 0 OID 0)
-- Dependencies: 198
-- Name: PezziVersioni_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "PezziVersioni_RelazioniSchede_CodiceScheda_seq" OWNED BY "PezziVersioni_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 199 (class 1259 OID 431047)
-- Name: PezziVersioni_Schede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "PezziVersioni_Schede" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone
);


ALTER TABLE "PezziVersioni_Schede" OWNER TO "postgres";

--
-- TOC entry 2540 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE "PezziVersioni_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "PezziVersioni_Schede" IS 'Informazioni testuali sui pezzi';


--
-- TOC entry 2541 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2542 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2543 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2544 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2545 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2546 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2547 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2548 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "PezziVersioni_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "PezziVersioni_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 200 (class 1259 OID 431053)
-- Name: Pezzi_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pezzi_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Pezzi_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2549 (class 0 OID 0)
-- Dependencies: 200
-- Name: Pezzi_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_Codice_seq" OWNED BY "Pezzi"."Codice";


--
-- TOC entry 201 (class 1259 OID 431055)
-- Name: Pezzi_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_ListaInformazioni" (
    "Titolo" character varying(255) NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "Pezzi_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2550 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE "Pezzi_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sui pezzi e dei relativi campi';


--
-- TOC entry 2551 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2552 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2553 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2554 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2555 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2556 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2557 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2558 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2559 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2560 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2561 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "Pezzi_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 202 (class 1259 OID 431070)
-- Name: Pezzi_ListaSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "Pezzi_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2562 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "Pezzi_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2563 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Pezzi_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 203 (class 1259 OID 431073)
-- Name: Pezzi_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Pezzi_RelazioniSchede" (
    "CodicePezzo" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "Pezzi_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2564 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE "Pezzi_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_RelazioniSchede" IS 'Relazioni tra i pezzi e le schede informative';


--
-- TOC entry 2565 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN "Pezzi_RelazioniSchede"."CodicePezzo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_RelazioniSchede"."CodicePezzo" IS 'Codice del pezzo';


--
-- TOC entry 2566 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN "Pezzi_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 204 (class 1259 OID 431076)
-- Name: Pezzi_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pezzi_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Pezzi_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2567 (class 0 OID 0)
-- Dependencies: 204
-- Name: Pezzi_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_RelazioniSchede_CodiceScheda_seq" OWNED BY "Pezzi_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 205 (class 1259 OID 431078)
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


ALTER TABLE "Pezzi_Schede" OWNER TO "postgres";

--
-- TOC entry 2568 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "Pezzi_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Pezzi_Schede" IS 'Informazioni testuali sui pezzi';


--
-- TOC entry 2569 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2570 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2571 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2572 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2573 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2574 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2575 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2576 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Pezzi_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Pezzi_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 206 (class 1259 OID 431084)
-- Name: Pezzi_SubVersion_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pezzi_SubVersion_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Pezzi_SubVersion_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2577 (class 0 OID 0)
-- Dependencies: 206
-- Name: Pezzi_SubVersion_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_SubVersion_Codice_seq" OWNED BY "PezziSubVersion"."Codice";


--
-- TOC entry 207 (class 1259 OID 431086)
-- Name: Pezzi_Versioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Pezzi_Versioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Pezzi_Versioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2578 (class 0 OID 0)
-- Dependencies: 207
-- Name: Pezzi_Versioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Pezzi_Versioni_Codice_seq" OWNED BY "PezziVersioni"."Codice";


--
-- TOC entry 208 (class 1259 OID 431088)
-- Name: Utenti; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Utenti" (
    "User" character varying(255) NOT NULL,
    "Password" character varying NOT NULL,
    "FullName" character varying(255) NOT NULL,
    "Gruppi" character varying NOT NULL
);


ALTER TABLE "Utenti" OWNER TO "postgres";

--
-- TOC entry 2579 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE "Utenti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Utenti" IS 'Tabella accessi e permessi';


--
-- TOC entry 2580 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "Utenti"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."User" IS 'Nome utente';


--
-- TOC entry 2581 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "Utenti"."Password"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Password" IS 'Password dell''account';


--
-- TOC entry 2582 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "Utenti"."FullName"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."FullName" IS 'Nome e cognome reale';


--
-- TOC entry 2583 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "Utenti"."Gruppi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Gruppi" IS 'gruppi, separati da virgole e senza spazi';


--
-- TOC entry 2096 (class 2604 OID 431094)
-- Name: NumeroLog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Log" ALTER COLUMN "NumeroLog" SET DEFAULT "nextval"('"Log_NumeroLog_seq"'::"regclass");


--
-- TOC entry 2103 (class 2604 OID 431095)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Modelli3D_Codice_seq"'::"regclass");


--
-- TOC entry 2087 (class 2604 OID 431096)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Pezzi_Codice_seq"'::"regclass");


--
-- TOC entry 2119 (class 2604 OID 431097)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Pezzi_SubVersion_Codice_seq"'::"regclass");


--
-- TOC entry 2129 (class 2604 OID 431098)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"PezziSubVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2095 (class 2604 OID 431099)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Pezzi_Versioni_Codice_seq"'::"regclass");


--
-- TOC entry 2139 (class 2604 OID 431100)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"PezziVersioni_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2149 (class 2604 OID 431101)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"Pezzi_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2155 (class 2606 OID 431268)
-- Name: Import_PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_PrimaryKey" PRIMARY KEY ("User", "CodiceVersione");


--
-- TOC entry 2153 (class 2606 OID 431270)
-- Name: KeyFileExtra; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "FileExtra"
    ADD CONSTRAINT "KeyFileExtra" PRIMARY KEY ("Filename");


--
-- TOC entry 2201 (class 2606 OID 431272)
-- Name: ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_ListaInformazioni"
    ADD CONSTRAINT "ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2167 (class 2606 OID 431274)
-- Name: Log-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "Log-key" PRIMARY KEY ("NumeroLog");


--
-- TOC entry 2169 (class 2606 OID 431276)
-- Name: Materiale_pezzi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "MaterialePezzi"
    ADD CONSTRAINT "Materiale_pezzi_pkey" PRIMARY KEY ("CodicePezzo", "URL", "Qualità");


--
-- TOC entry 2171 (class 2606 OID 431278)
-- Name: Modelli3D-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D"
    ADD CONSTRAINT "Modelli3D-primary-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2173 (class 2606 OID 431280)
-- Name: Modelli3D_3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2175 (class 2606 OID 431282)
-- Name: Modelli3D_Backup3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_Backup3dm"
    ADD CONSTRAINT "Modelli3D_Backup3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "LastUpdate");


--
-- TOC entry 2157 (class 2606 OID 431284)
-- Name: Modelli3D_LoD-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2179 (class 2606 OID 431286)
-- Name: Modelli3D_Textture-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Textture-primaryKey" PRIMARY KEY ("CodiceModello", "TextureNumber", "Qualità");


--
-- TOC entry 2177 (class 2606 OID 431288)
-- Name: Modelli3d_PezziJSON-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3d_PezziJSON-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2159 (class 2606 OID 431290)
-- Name: Pezzi-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2161 (class 2606 OID 431292)
-- Name: Pezzi-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi"
    ADD CONSTRAINT "Pezzi-unicità" UNIQUE ("Area", "Zone", "Sector", "Type", "Name");


--
-- TOC entry 2185 (class 2606 OID 431294)
-- Name: PezziSubVersion_ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziSubVersion_ListaInformazioni"
    ADD CONSTRAINT "PezziSubVersion_ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2187 (class 2606 OID 431296)
-- Name: PezziSubVersion_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziSubVersion_ListaSchede"
    ADD CONSTRAINT "PezziSubVersion_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2189 (class 2606 OID 431298)
-- Name: PezziSubVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziSubVersion_RelazioniSchede"
    ADD CONSTRAINT "PezziSubVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceSubVersion", "TitoloScheda");


--
-- TOC entry 2191 (class 2606 OID 431300)
-- Name: PezziSubVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziSubVersion_Schede"
    ADD CONSTRAINT "PezziSubVersion_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2193 (class 2606 OID 431302)
-- Name: PezziVersioni_ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziVersioni_ListaInformazioni"
    ADD CONSTRAINT "PezziVersioni_ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2195 (class 2606 OID 431304)
-- Name: PezziVersioni_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziVersioni_ListaSchede"
    ADD CONSTRAINT "PezziVersioni_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2197 (class 2606 OID 431306)
-- Name: PezziVersioni_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziVersioni_RelazioniSchede"
    ADD CONSTRAINT "PezziVersioni_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceVersione", "TitoloScheda");


--
-- TOC entry 2199 (class 2606 OID 431308)
-- Name: PezziVersioni_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziVersioni_Schede"
    ADD CONSTRAINT "PezziVersioni_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2203 (class 2606 OID 431310)
-- Name: Pezzi_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_ListaSchede"
    ADD CONSTRAINT "Pezzi_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2205 (class 2606 OID 431312)
-- Name: Pezzi_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede"
    ADD CONSTRAINT "Pezzi_RelazioniSchede_primaryKey" PRIMARY KEY ("CodicePezzo", "TitoloScheda");


--
-- TOC entry 2207 (class 2606 OID 431314)
-- Name: Pezzi_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Pezzi_Schede"
    ADD CONSTRAINT "Pezzi_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2181 (class 2606 OID 431316)
-- Name: Pezzi_SubVersion-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziSubVersion"
    ADD CONSTRAINT "Pezzi_SubVersion-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2183 (class 2606 OID 431318)
-- Name: Pezzi_SubVersion-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziSubVersion"
    ADD CONSTRAINT "Pezzi_SubVersion-unicità" UNIQUE ("CodicePezzo", "CodiceVersione", "SubVersion");


--
-- TOC entry 2163 (class 2606 OID 431320)
-- Name: Pezzi_Versioni-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziVersioni"
    ADD CONSTRAINT "Pezzi_Versioni-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2165 (class 2606 OID 431322)
-- Name: Pezzi_Versioni-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "PezziVersioni"
    ADD CONSTRAINT "Pezzi_Versioni-unicità" UNIQUE ("CodicePezzo", "Versione");


--
-- TOC entry 2209 (class 2606 OID 431324)
-- Name: Utenti-key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Utenti"
    ADD CONSTRAINT "Utenti-key" PRIMARY KEY ("User");


--
-- TOC entry 2151 (class 2606 OID 431326)
-- Name: prim_key_cantieri; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Cantieri"
    ADD CONSTRAINT "prim_key_cantieri" PRIMARY KEY ("Area", "Numero");


--
-- TOC entry 2210 (class 2606 OID 431327)
-- Name: Import_CodiceModelloRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceModelloRef" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2211 (class 2606 OID 431332)
-- Name: Import_CodicePezzoRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodicePezzoRef" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2212 (class 2606 OID 431337)
-- Name: Import_CodicePezzoVersioneRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodicePezzoVersioneRef" FOREIGN KEY ("CodiceVersione") REFERENCES "PezziVersioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2213 (class 2606 OID 431342)
-- Name: Import_UserRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_UserRef" FOREIGN KEY ("User") REFERENCES "Utenti"("User") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2218 (class 2606 OID 431347)
-- Name: Modelli3D_3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2219 (class 2606 OID 431352)
-- Name: Modelli3D_Backup3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Backup3dm"
    ADD CONSTRAINT "Modelli3D_Backup3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2214 (class 2606 OID 431357)
-- Name: Modelli3D_LoD-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2220 (class 2606 OID 431362)
-- Name: Modelli3D_PezziJSON-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3D_PezziJSON-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2221 (class 2606 OID 431367)
-- Name: Modelli3D_Texture-refCodiceModello; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Texture-refCodiceModello" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2224 (class 2606 OID 431372)
-- Name: PezziSubVersion_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion_ListaInformazioni"
    ADD CONSTRAINT "PezziSubVersion_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "PezziSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2225 (class 2606 OID 431377)
-- Name: PezziSubVersion_RelazioniSchede_refCodicePezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion_RelazioniSchede"
    ADD CONSTRAINT "PezziSubVersion_RelazioniSchede_refCodicePezzo" FOREIGN KEY ("CodiceSubVersion") REFERENCES "PezziSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2226 (class 2606 OID 431382)
-- Name: PezziSubVersion_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion_RelazioniSchede"
    ADD CONSTRAINT "PezziSubVersion_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "PezziSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2227 (class 2606 OID 431387)
-- Name: PezziSubVersion_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion_Schede"
    ADD CONSTRAINT "PezziSubVersion_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "PezziSubVersion_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2228 (class 2606 OID 431392)
-- Name: PezziSubVersion_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion_Schede"
    ADD CONSTRAINT "PezziSubVersion_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "PezziSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2229 (class 2606 OID 431397)
-- Name: PezziVersioni_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni_ListaInformazioni"
    ADD CONSTRAINT "PezziVersioni_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "PezziVersioni_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2230 (class 2606 OID 431402)
-- Name: PezziVersioni_RelazioniSchede_refCodicePezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni_RelazioniSchede"
    ADD CONSTRAINT "PezziVersioni_RelazioniSchede_refCodicePezzo" FOREIGN KEY ("CodiceVersione") REFERENCES "PezziVersioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2231 (class 2606 OID 431407)
-- Name: PezziVersioni_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni_RelazioniSchede"
    ADD CONSTRAINT "PezziVersioni_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "PezziVersioni_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2232 (class 2606 OID 431412)
-- Name: PezziVersioni_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni_Schede"
    ADD CONSTRAINT "PezziVersioni_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "PezziVersioni_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2233 (class 2606 OID 431417)
-- Name: PezziVersioni_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni_Schede"
    ADD CONSTRAINT "PezziVersioni_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "PezziVersioni_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2234 (class 2606 OID 431422)
-- Name: Pezzi_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_ListaInformazioni"
    ADD CONSTRAINT "Pezzi_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "Pezzi_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2235 (class 2606 OID 431427)
-- Name: Pezzi_RelazioniSchede_refCodicePezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede"
    ADD CONSTRAINT "Pezzi_RelazioniSchede_refCodicePezzo" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2236 (class 2606 OID 431432)
-- Name: Pezzi_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_RelazioniSchede"
    ADD CONSTRAINT "Pezzi_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "Pezzi_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2237 (class 2606 OID 431437)
-- Name: Pezzi_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_Schede"
    ADD CONSTRAINT "Pezzi_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "Pezzi_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2238 (class 2606 OID 431442)
-- Name: Pezzi_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Pezzi_Schede"
    ADD CONSTRAINT "Pezzi_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "Pezzi_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2222 (class 2606 OID 431447)
-- Name: Pezzi_SubVersion-keu-Pezzi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion"
    ADD CONSTRAINT "Pezzi_SubVersion-keu-Pezzi" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2223 (class 2606 OID 431452)
-- Name: Pezzi_SubVersion-key-Pezzi_Versioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziSubVersion"
    ADD CONSTRAINT "Pezzi_SubVersion-key-Pezzi_Versioni" FOREIGN KEY ("CodiceVersione") REFERENCES "PezziVersioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2215 (class 2606 OID 431457)
-- Name: Pezzi_Versioni-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni"
    ADD CONSTRAINT "Pezzi_Versioni-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 2216 (class 2606 OID 431462)
-- Name: Pezzi_Versioni-key-Pezzi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "PezziVersioni"
    ADD CONSTRAINT "Pezzi_Versioni-key-Pezzi" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2217 (class 2606 OID 431467)
-- Name: Verifica_Codice_pezzo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialePezzi"
    ADD CONSTRAINT "Verifica_Codice_pezzo" FOREIGN KEY ("CodicePezzo") REFERENCES "Pezzi"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2356 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA "public" FROM PUBLIC;
REVOKE ALL ON SCHEMA "public" FROM "postgres";
GRANT ALL ON SCHEMA "public" TO "postgres";
GRANT ALL ON SCHEMA "public" TO PUBLIC;


-- Completed on 2015-09-24 00:30:39

--
-- PostgreSQL database dump complete
--

