--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.4
-- Dumped by pg_dump version 9.5.5

-- Started on 2017-09-05 11:22:54

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
--SET row_security = off;

--
-- TOC entry 2488 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 1 (class 3079 OID 11870)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2490 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


SET search_path = "public", pg_catalog;

--
-- TOC entry 241 (class 1255 OID 430830)
-- Name: addimportnome("text", "text", "text", "text", "text", boolean, boolean, "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "addimportnome"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "name" "text", "match" boolean, "rw" boolean, "username" "text", "removed" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	--maxCantiere "Cantieri"%ROWTYPE;
	selOggetti1 RECORD;

	colore int;
	cmod int;
	rwmod boolean;

	nullLayer1 text;
	nullLayer2 text;
	nullLayer3 text;
	nullName text;
	
	text_output text;
    
  BEGIN
	text_output:='';
  
	IF (layer0 IS NULL OR layer0 = '')
	THEN
	    layer0 := '%';
	ELSE
	    IF (match = false)
	    THEN
		layer0 := '%' || UPPER(layer0) || '%';
	    ELSE
		layer0 := UPPER(layer0);
	    END IF;
	END IF;
	IF (layer1 IS NULL OR layer1 = '')
	THEN
	    layer1 := '%';
	ELSE
	    IF (match = false)
	    THEN
		layer1 := '%' || UPPER(layer1) || '%';
	    ELSE
		layer1 := UPPER(layer1);
	    END IF;
	END IF;
	IF (layer2 IS NULL OR layer2 = '')
	THEN
	    layer2 := '%';
	ELSE
	    IF (match = false)
	    THEN
		layer2 := '%' || UPPER(layer2) || '%';
	    ELSE
		layer2 := UPPER(layer2);
	    END IF;
	END IF;
	IF (layer3 IS NULL OR layer3 = '')
	THEN
	    layer3 := '%';
	ELSE
	    IF (match = false)
	    THEN
		layer3 := '%' || UPPER(layer3) || '%';
	    ELSE
		layer3 := UPPER(layer3);
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


	 --maxCantiere := (SELECT "layer0", MAX("Numero") AS num FROM "Cantieri" GROUP BY "layer0");
	--text_output := '';
	--FOR maxCantiere IN (SELECT "layer0", MAX("Numero") AS num FROM "Cantieri" GROUP BY "layer0") LOOP
	--	text_output := text_output || maxCantiere."layer0" || '__' || maxCantiere."Numero" || ' - ';
	--END LOOP;

	IF (layer1= '-')
	THEN
		nullLayer1 = '';
	ELSE
		nullLayer1 = '-';
	END IF;
	IF (layer2= '-')
	THEN
		nullLayer2 = '';
	ELSE
		nullLayer2 = '-';
	END IF;
	IF (layer3= '-')
	THEN
		nullLayer3 = '';
	ELSE
		nullLayer3 = '-';
	END IF;
	IF (name = '-')
	THEN
		nullName = '';
	ELSE
		nullName = '-';
	END IF;

	FOR selOggetti1 IN (SELECT "OggettiVersion"."Codice" AS "CodiceVersione", "CodiceOggetto", "Layer0", "Layer1", "Layer2", "Layer3", "Name", "Versione", "Originale", "CodiceModello", "OggettiVersion"."CantiereCreazione", "OggettiVersion"."CantiereEliminazione", "Live", "Oggetti"."Lock" AS "OggettiLock",  "OggettiVersion"."Lock" AS "OggettiVersioneLock" FROM "Oggetti" JOIN "OggettiVersion" ON "Oggetti"."Codice" = "OggettiVersion"."CodiceOggetto" WHERE UPPER("Layer0") LIKE layer0 AND UPPER("Layer1") LIKE layer1 AND "Layer1" != nullLayer1 AND UPPER("Layer2") LIKE layer2 AND "Layer2" != nullLayer2 AND UPPER("Layer3") LIKE layer3 AND "Layer3" != nullLayer3 AND UPPER("Name") LIKE name AND "Name" != nullName) LOOP
		CASE selOggetti1."Live"
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
			cmod := (SELECT num FROM "MaxCantieri" WHERE "Layer0" = selOggetti1."Layer0")  - selOggetti1."CantiereCreazione";
			IF (cmod > 3 OR (selOggetti1."CantiereCreazione" = 0 AND selOggetti1."Live" != 2 AND selOggetti1."Live" != 7))
			THEN
				cmod := 3;
			END IF;
			colore := colore + (cmod * 100);

			IF (selOggetti1."Originale" != 0)
			THEN
			    colore := colore + 50;
			END IF;

			IF ((rw = true) AND (selOggetti1."OggettiLock" IS NOT NULL) AND (selOggetti1."OggettiLock" != '') AND (selOggetti1."OggettiLock" != username))
			THEN
				IF (text_output NOT LIKE ('%' || selOggetti1."OggettiLock" || '%'))
				THEN
					text_output := text_output || selOggetti1."OggettiLock" || ', ';
				END IF;
				rwmod := true;
				colore := colore + 20;
			ELSE IF ((rw = true) AND (selOggetti1."OggettiVersioneLock" IS NOT NULL) AND (selOggetti1."OggettiVersioneLock" != '') AND (selOggetti1."OggettiVersioneLock" != username))
				THEN
					IF (text_output NOT LIKE ('%' || selOggetti1."OggettiVersioneLock" || '%'))
					THEN
						text_output := text_output || selOggetti1."OggettiVersioneLock" || ', ';
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
				INSERT INTO "Import" ("User", "CodiceOggetto", "CodiceVersione", "CodiceModello", "Colore", "readonly") VALUES (username, selOggetti1."CodiceOggetto", selOggetti1."CodiceVersione", selOggetti1."CodiceModello", colore, rwmod);

				IF (rwmod = false)
				THEN
					UPDATE "Oggetti" SET "Lock" = username WHERE "Codice" = selOggetti1."CodiceOggetto";
					UPDATE "OggettiVersion" SET "Lock" = username WHERE "Codice" = selOggetti1."CodiceVersione";
					UPDATE "OggettiSubVersion" SET "Lock" = username WHERE "CodiceOggetto" = selOggetti1."CodiceOggetto" AND "CodiceVersione" = selOggetti1."CodiceVersione";
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


ALTER FUNCTION "public"."addimportnome"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "name" "text", "match" boolean, "rw" boolean, "username" "text", "removed" boolean) OWNER TO "postgres";

--
-- TOC entry 236 (class 1255 OID 430831)
-- Name: checkallmodelled(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "checkallmodelled"("codiceoggetto" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto2 bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
	selOggetti2 RECORD;

	auxint int;
  BEGIN
	-- find codice modello, live status
	--SELECT "Live", "Versione", "CodiceModello" INTO selOggetti1 FROM "Oggetti" WHERE "Codice" = codiceoggetto ORDER BY "Versione" DESC LIMIT 1;
	
	-- check live status and all modelled
	--CASE selOggetti1."Live"
	--	WHEN 0, 1, 2, 4 THEN
	--		RAISE EXCEPTION 'Can''t check if all object is modelled for (id=%) because it isn''t wait for other object to be modelled!: DB can be in a inconsistent status! Can''t modified object (id=%): operation aborted!',codiceOggetto,codiceOggetto;
	--	WHEN 3 THEN
	--		RAISE EXCEPTION 'Can''t check if all object is modelled for (id=%) because it isn''t modelled!: DB can be in a inconsistent status! Can''t modified object (id=%): operation aborted!',codiceOggetto,codiceOggetto;
	--	WHEN 6 THEN
	--		IF (selOggetti1."Versione" != 0) THEN
	--			RAISE EXCEPTION 'Can''t add a new different model for two version of the same object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',layer0,layer1,layer2,layer3,nome;
	--		END IF;
	--	ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	--END CASE;

	

	--todo




	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."checkallmodelled"("codiceoggetto" bigint) OWNER TO "postgres";

--
-- TOC entry 237 (class 1255 OID 430832)
-- Name: deleteimportlist("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteimportlist"("username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "Import" WHERE "User" = username;

	UPDATE "Oggetti" SET "Lock" = null WHERE "Lock" = username;
	UPDATE "OggettiVersion" SET "Lock" = null WHERE "Lock" = username;
	UPDATE "OggettiSubVersion" SET "Lock" = null WHERE "Lock" = username;
    RETURN 'success';
END;
$$;


ALTER FUNCTION "public"."deleteimportlist"("username" "text") OWNER TO "postgres";

--
-- TOC entry 238 (class 1255 OID 430833)
-- Name: deleteimportobject(bigint, bigint, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteimportobject"("codiceoggetto" bigint, "codiceversione" bigint, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	locked int;
  BEGIN
	DELETE FROM "Import" WHERE "CodiceVersione" = codiceVersione AND "User" = username;

	UPDATE "OggettiVersion" SET "Lock" = null WHERE "Codice" = codiceVersione AND "Lock" = username;
	UPDATE "OggettiSubVersion" SET "Lock" = null WHERE "CodiceVersione" = codiceVersione AND "Lock" = username;

	locked := (SELECT COUNT(*) FROM "Oggetti" JOIN "OggettiVersion" ON "Oggetti"."Codice" = "OggettiVersion"."CodiceOggetto" WHERE "CodiceOggetto" = codiceOggetto AND "OggettiVersion"."Lock" = username);
	IF (locked = 0)
	THEN
		UPDATE "Oggetti" SET "Lock" = null WHERE "Lock" = username;
	END IF;

    RETURN 'success';
END;
$$;


ALTER FUNCTION "public"."deleteimportobject"("codiceoggetto" bigint, "codiceversione" bigint, "username" "text") OWNER TO "postgres";

--
-- TOC entry 239 (class 1255 OID 430834)
-- Name: deleteoggettiinfo(bigint, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteoggettiinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "Oggetti_Schede" WHERE "Codice" = codiceScheda AND "TitoloScheda" = titoloScheda AND "NomeCampo" = nomeCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deleteoggettiinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") OWNER TO "postgres";

--
-- TOC entry 240 (class 1255 OID 430835)
-- Name: deleteoggettiversioniinfo(bigint, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteoggettiversioniinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "OggettiVersion_Schede" WHERE "Codice" = codiceScheda AND "TitoloScheda" = titoloScheda AND "NomeCampo" = nomeCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deleteoggettiversioniinfo"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text") OWNER TO "postgres";

--
-- TOC entry 269 (class 1255 OID 430836)
-- Name: preinitializemodifiedobject("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
	selModelliLoD1 RECORD;

	modified boolean;
	added boolean;
	
	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;


	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	-- lock check
	auxint := (SELECT count(*) FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - %__v%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',layer0,layer1,layer2,layer3,nome,versione;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Codice", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	CASE selOggetti1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN added := true;
		WHEN 6 THEN added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - %__v%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome,versione;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- update model
	UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."CodiceModello";

	-- remove old JSON
	DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = false AND "3dm_Backup" = false;
	DELETE FROM "Modelli3D_JSON" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- backup old 3dm
	FOR selModelliLoD1 IN (SELECT "LoD" FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = true) LOOP
		--DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = selModelliLoD1."LastUpdate";
		INSERT INTO "Modelli3D_3dm_Backup" (SELECT * FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		-- DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";
		auxint := (SELECT COUNT(*) FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		IF (auxInt > 4) THEN
			DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = (SELECT "LastUpdate" FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" ORDER BY "LastUpdate" LIMIT 1);
		END IF;
	END LOOP;

	-- remove old 3dm
	DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- remove textures
	DELETE FROM "Modelli3D_Texture" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- update Modelli3d LoD status
	UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "3dm_Backup" = true, "3dm" = false, "JSON" = false, "3dm_Texture" = false, "JSON_Texture" = false, "Texture" = false WHERE "CodiceModello" = selOggetti1."CodiceModello" AND ("3dm" = true OR "3dm_Backup" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 279 (class 1255 OID 592362)
-- Name: preinitializemodifiedobject("text", "text", "text", "text", "text", integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
	selModelliLoD1 RECORD;

	modified boolean;
	added boolean;
	
	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;


	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	-- lock check
	auxint := (SELECT count(*) FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - %__v%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',layer0,layer1,layer2,layer3,nome,versione;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Codice", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	CASE selOggetti1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN added := true;
		WHEN 6 THEN added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - %__v%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome,versione;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- update model
	UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "Type" = tipoModello, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."CodiceModello";

	-- remove old JSON
	DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = false AND "3dm_Backup" = false;
	DELETE FROM "Modelli3D_JSON" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- backup old 3dm
	FOR selModelliLoD1 IN (SELECT "LoD" FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = true) LOOP
		--DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = selModelliLoD1."LastUpdate";
		INSERT INTO "Modelli3D_3dm_Backup" (SELECT * FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		-- DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";
		auxint := (SELECT COUNT(*) FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		IF (auxInt > 4) THEN
			DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = (SELECT "LastUpdate" FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" ORDER BY "LastUpdate" LIMIT 1);
		END IF;
	END LOOP;

	-- remove old 3dm
	DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- remove textures
	DELETE FROM "Modelli3D_Texture" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- update Modelli3d LoD status
	UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "3dm_Backup" = true, "3dm" = false, "JSON" = false, "3dm_Texture" = false, "JSON_Texture" = false, "Texture" = false WHERE "CodiceModello" = selOggetti1."CodiceModello" AND ("3dm" = true OR "3dm_Backup" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 268 (class 1255 OID 479542)
-- Name: preinitializemodifiedobjectonlyrhino("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobjectonlyrhino"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
	selModelliLoD1 RECORD;

	modified boolean;
	added boolean;
	
	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;


	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	-- lock check
	auxint := (SELECT count(*) FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - %__v%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',layer0,layer1,layer2,layer3,nome,versione;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Codice", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	CASE selOggetti1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN added := true;
		WHEN 6 THEN added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - %__v%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome,versione;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- update model
	--UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."CodiceModello";
	UPDATE "Modelli3D" SET "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."CodiceModello";

	-- remove old JSON
	--DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = false AND "3dm_Backup" = false;
	--DELETE FROM "Modelli3D_JSON" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- backup old 3dm
	FOR selModelliLoD1 IN (SELECT "LoD" FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = true) LOOP
		--DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = selModelliLoD1."LastUpdate";
		INSERT INTO "Modelli3D_3dm_Backup" (SELECT * FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		-- DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";
		auxint := (SELECT COUNT(*) FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
		IF (auxInt > 4) THEN
			DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = (SELECT "LastUpdate" FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" ORDER BY "LastUpdate" LIMIT 1);
		END IF;
	END LOOP;

	-- remove old 3dm
	DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- remove textures
	--DELETE FROM "Modelli3D_Texture" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- update Modelli3d LoD status
	--UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "3dm_Backup" = true, "3dm" = false, "JSON" = false, "3dm_Texture" = false, "JSON_Texture" = false, "Texture" = false WHERE "CodiceModello" = selOggetti1."CodiceModello" AND ("3dm" = true OR "3dm_Backup" = true);
	UPDATE "Modelli3D_LoD" SET "3dm_Backup" = true, "3dm" = false, "3dm_Texture" = false WHERE "CodiceModello" = selOggetti1."CodiceModello" AND ("3dm" = true OR "3dm_Backup" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobjectonlyrhino"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 266 (class 1255 OID 484654)
-- Name: preinitializemodifiedobjectonlyweb("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobjectonlyweb"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
	selModelliLoD1 RECORD;

	modified boolean;
	added boolean;
	
	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;


	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	-- lock check
	auxint := (SELECT count(*) FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - %__v%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',layer0,layer1,layer2,layer3,nome,versione;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Codice", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	CASE selOggetti1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN added := true;
		WHEN 6 THEN added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - %__v%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome,versione;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- update model
	UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."CodiceModello";

	-- remove old JSON
	DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = false AND "3dm_Backup" = false;
	DELETE FROM "Modelli3D_JSON" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- backup old 3dm
	--FOR selModelliLoD1 IN (SELECT "LoD" FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = true) LOOP
	--	--DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = selModelliLoD1."LastUpdate";
	--	INSERT INTO "Modelli3D_3dm_Backup" (SELECT * FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
	--	-- DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";
	--	auxint := (SELECT COUNT(*) FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
	--	IF (auxInt > 4) THEN
	--		DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = (SELECT "LastUpdate" FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" ORDER BY "LastUpdate" LIMIT 1);
	--	END IF;
	--END LOOP;

	-- remove old 3dm
	--DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";

	-- remove textures
	DELETE FROM "Modelli3D_Texture" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- update Modelli3d LoD status
	UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "JSON" = false, "3dm_Texture" = false, "JSON_Texture" = false, "Texture" = false WHERE "CodiceModello" = selOggetti1."CodiceModello" AND ("3dm" = true OR "3dm_Backup" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobjectonlyweb"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 278 (class 1255 OID 592363)
-- Name: preinitializemodifiedobjectonlyweb("text", "text", "text", "text", "text", integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializemodifiedobjectonlyweb"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
	selModelliLoD1 RECORD;

	modified boolean;
	added boolean;
	
	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;


	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	-- lock check
	auxint := (SELECT count(*) FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione AND "Lock" != username);
	IF (auxInt != 0) THEN
		RAISE EXCEPTION 'The object(layer=%_%_%_% - %__v%) isn''t locked by current user (or at least a version of the object isn''t locked! Can''t modified object: operation aborted!',layer0,layer1,layer2,layer3,nome,versione;
	END IF;
	
	-- check live status
	modified := false;
	added := false;

	SELECT "Live", "Codice", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	CASE selOggetti1."Live"
		WHEN 0 THEN modified := true;
		WHEN 1 THEN modified := true;
		WHEN 2 THEN modified := true;
		WHEN 4 THEN modified := true;
		WHEN 3 THEN added := true;
		WHEN 6 THEN added := true;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - %__v%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome,versione;
	END CASE;


	-- only for modified
	IF (modified = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- only for added
	IF (added = true) THEN
		--update object
		UPDATE "OggettiVersion" SET "Live" = 6, "Updating"=true, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."Codice";
	END IF;

	-- update model
	UPDATE "Modelli3D" SET "Superficie"=null, "Volume"=null, "Type" = tipoModello, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = selOggetti1."CodiceModello";

	-- remove old JSON
	DELETE FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = false AND "3dm_Backup" = false;
	DELETE FROM "Modelli3D_JSON" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- backup old 3dm
	--FOR selModelliLoD1 IN (SELECT "LoD" FROM "Modelli3D_LoD" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "3dm" = true) LOOP
	--	--DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = selModelliLoD1."LastUpdate";
	--	INSERT INTO "Modelli3D_3dm_Backup" (SELECT * FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
	--	-- DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";
	--	auxint := (SELECT COUNT(*) FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD");
	--	IF (auxInt > 4) THEN
	--		DELETE FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" AND "LastUpdate" = (SELECT "LastUpdate" FROM "Modelli3D_3dm_Backup" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD" ORDER BY "LastUpdate" LIMIT 1);
	--	END IF;
	--END LOOP;

	-- remove old 3dm
	--DELETE FROM "Modelli3D_3dm" WHERE "CodiceModello" = selOggetti1."CodiceModello" AND "LoD" = selModelliLoD1."LoD";

	-- remove textures
	DELETE FROM "Modelli3D_Texture" WHERE "CodiceModello" = selOggetti1."CodiceModello";

	-- update Modelli3d LoD status
	UPDATE "Modelli3D_LoD" SET xc = 0, yc = 0, zc = 0, "Radius" = 0, "JSON" = false, "3dm_Texture" = false, "JSON_Texture" = false, "Texture" = false WHERE "CodiceModello" = selOggetti1."CodiceModello" AND ("3dm" = true OR "3dm_Backup" = true);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."preinitializemodifiedobjectonlyweb"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 277 (class 1255 OID 593032)
-- Name: preinitializenewhotspot("text", "text", "text", "text", "text", integer, double precision, double precision, double precision, double precision, real, real, real, real, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializenewhotspot"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "colorr" real, "colorg" real, "colorb" real, "colora" real, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceVersione bigint;
	codiceModello bigint;

	auxint int;
	tmpRecord RECORD;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - %__v%): operation aborted!',username,layer0,layer1,layer2,layer3,nome, versione;
	END IF;

	-- add a void model
	INSERT INTO "Modelli3D" ("Type", "LastUpdate", "LastUpdateBy") VALUES (2, now(), username) RETURNING "Codice" INTO codiceModello;

	-- add a new object
	INSERT INTO "Oggetti"("Layer0", "Layer1", "Layer2", "Layer3", "Name", "DataCreazione", "DataEliminazione", "CantiereCreazione", "CantiereEliminazione", 
			"Lock", "LastUpdate", "LastUpdateBy")
		VALUES (layer0, layer1, layer2, layer3, nome, now(), null, 0, null,
			username, now(), username) RETURNING "Codice" INTO codiceOggetto;

	INSERT INTO "OggettiVersion"("CodiceOggetto", "Versione", "CodiceModello", "Originale", "DataCreazione", "DataEliminazione", "Live",
			"CantiereCreazione", "CantiereEliminazione", "Lock", "Updating", "LastUpdate", "LastUpdateBy")
	    VALUES (codiceOggetto, versione, codiceModello, 0, now(), null, 1,
		    0, null, username, false, now(), username) RETURNING "Codice" INTO codiceVersione;


	INSERT INTO "OggettiSubVersion"("CodiceOggetto", "CodiceVersione", "SubVersion", "Originale", "DataCreazione", "DataEliminazione",
			"CantiereCreazione", "CantiereEliminazione", "Lock", "LastUpdate", "LastUpdateBy")
	    VALUES (codiceOggetto, codiceVersione, 0, 0, now(), null, 
		    0, null, username, now(), username);

	
	-- add cantiere if not exist
	auxint := (SELECT count(*) FROM "Cantieri" WHERE "Layer0" = layer0);
	IF (auxInt = 0) THEN
		INSERT INTO "Cantieri" ("Layer0", "Numero", "DataInizio") VALUES (layer0, 0, now());
	END IF;

	INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "3dm_Backup", "3dm_Texture",
			"JSON_Texture", "Texture", "OBJ", "HotSpot")
		VALUES (codiceModello, 0, xcentro, ycentro, zcentro, raggio, false, false, null, false, false, false, false, false, true);

	INSERT INTO "Modelli3D_HotSpotColor"("CodiceModello", "ColorR", "ColorG", "ColorB", "ColorA")
		VALUES (codiceModello, colorr, colorg, colorb, colora);

	INSERT INTO "Import" ("User", "CodiceOggetto", "CodiceVersione", "CodiceModello", "Colore", "readonly") VALUES (username, codiceOggetto, codiceVersione, codiceModello, 301, false);

    	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."preinitializenewhotspot"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "colorr" real, "colorg" real, "colorb" real, "colora" real, "username" "text") OWNER TO "postgres";

--
-- TOC entry 276 (class 1255 OID 592361)
-- Name: preinitializenewobject("text", "text", "text", "text", "text", integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializenewobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceVersione bigint;
	codiceModello bigint;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - %__v%): operation aborted!',username,layer0,layer1,layer2,layer3,nome, versione;
	END IF;

	-- add a void model
	INSERT INTO "Modelli3D" ("Type", "LastUpdate", "LastUpdateBy") VALUES (tipoModello, now(), username) RETURNING "Codice" INTO codiceModello;

	-- add a new object
	INSERT INTO "Oggetti"("Layer0", "Layer1", "Layer2", "Layer3", "Name", "DataCreazione", "DataEliminazione", "CantiereCreazione", "CantiereEliminazione", 
			"Lock", "LastUpdate", "LastUpdateBy")
		VALUES (layer0, layer1, layer2, layer3, nome, now(), null, 0, null,
			username, now(), username) RETURNING "Codice" INTO codiceOggetto;

	INSERT INTO "OggettiVersion"("CodiceOggetto", "Versione", "CodiceModello", "Originale", "DataCreazione", "DataEliminazione", "Live",
			"CantiereCreazione", "CantiereEliminazione", "Lock", "Updating", "LastUpdate", "LastUpdateBy")
	    VALUES (codiceOggetto, versione, codiceModello, 0, now(), null, 1,
		    0, null, username, true, now(), username) RETURNING "Codice" INTO codiceVersione;


	INSERT INTO "OggettiSubVersion"("CodiceOggetto", "CodiceVersione", "SubVersion", "Originale", "DataCreazione", "DataEliminazione",
			"CantiereCreazione", "CantiereEliminazione", "Lock", "LastUpdate", "LastUpdateBy")
	    VALUES (codiceOggetto, codiceVersione, 0, 0, now(), null, 
		    0, null, username, now(), username);

	
	-- add cantiere if not exist
	auxint := (SELECT count(*) FROM "Cantieri" WHERE "Layer0" = layer0);
	IF (auxInt = 0) THEN
		INSERT INTO "Cantieri" ("Layer0", "Numero", "DataInizio") VALUES (layer0, 0, now());
	END IF;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."preinitializenewobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 272 (class 1255 OID 586432)
-- Name: setoggettiinfocombovalue(bigint, "text", "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfocombovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("Codice", "TitoloScheda", "NomeCampo", "ComboValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = ' || valore || ' WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfocombovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 265 (class 1255 OID 586431)
-- Name: setoggettiinfoschedacombovalue(bigint, "text", "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedacombovalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "TitoloScheda") VALUES (codiceoggetto, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfocombovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedacombovalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 245 (class 1255 OID 430841)
-- Name: setoggettiinfoschedavalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "TitoloScheda") VALUES (codiceoggetto, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 244 (class 1255 OID 430840)
-- Name: setoggettiinfoschedavalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "TitoloScheda") VALUES (codiceoggetto, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 242 (class 1255 OID 430838)
-- Name: setoggettiinfoschedavalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "TitoloScheda") VALUES (codiceoggetto, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 243 (class 1255 OID 430839)
-- Name: setoggettiinfoschedavalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "TitoloScheda") VALUES (codiceoggetto, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 246 (class 1255 OID 430842)
-- Name: setoggettiinfoschedavalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "TitoloScheda") VALUES (codiceoggetto, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 247 (class 1255 OID 430843)
-- Name: setoggettiinfovalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("Codice", "TitoloScheda", "NomeCampo", "BoolValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 270 (class 1255 OID 430846)
-- Name: setoggettiinfovalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("Codice", "TitoloScheda", "NomeCampo", "RealValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 254 (class 1255 OID 430845)
-- Name: setoggettiinfovalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("Codice", "TitoloScheda", "NomeCampo", "IntValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 271 (class 1255 OID 430844)
-- Name: setoggettiinfovalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL AND valore != '' AND trim(from valore) != '') THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TextValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 253 (class 1255 OID 430847)
-- Name: setoggettiinfovalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TimestampValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''', "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 273 (class 1255 OID 586433)
-- Name: setoggettiversioniinfocombovalue(bigint, "text", "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfocombovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("Codice", "TitoloScheda", "NomeCampo", "ComboValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = ' || valore || ' WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfocombovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 274 (class 1255 OID 586434)
-- Name: setoggettiversioniinfoschedacombovalue(bigint, "text", "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedacombovalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfocombovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedacombovalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 249 (class 1255 OID 430849)
-- Name: setoggettiversioniinfoschedavalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 252 (class 1255 OID 430852)
-- Name: setoggettiversioniinfoschedavalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 248 (class 1255 OID 430848)
-- Name: setoggettiversioniinfoschedavalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 250 (class 1255 OID 430850)
-- Name: setoggettiversioniinfoschedavalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 251 (class 1255 OID 430851)
-- Name: setoggettiversioniinfoschedavalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "TitoloScheda" = titoloscheda);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "TitoloScheda") VALUES (codiceversione, titoloscheda) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, titoloscheda, nomecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 257 (class 1255 OID 430854)
-- Name: setoggettiversioniinfovalue(bigint, "text", "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("Codice", "TitoloScheda", "NomeCampo", "BoolValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 256 (class 1255 OID 430857)
-- Name: setoggettiversioniinfovalue(bigint, "text", "text", real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("Codice", "TitoloScheda", "NomeCampo", "RealValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" real) OWNER TO "postgres";

--
-- TOC entry 263 (class 1255 OID 430856)
-- Name: setoggettiversioniinfovalue(bigint, "text", "text", integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("Codice", "TitoloScheda", "NomeCampo", "IntValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" integer) OWNER TO "postgres";

--
-- TOC entry 258 (class 1255 OID 430855)
-- Name: setoggettiversioniinfovalue(bigint, "text", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL AND valore != '' AND trim(from valore) != '') THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TextValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null, "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" "text") OWNER TO "postgres";

--
-- TOC entry 264 (class 1255 OID 430853)
-- Name: setoggettiversioniinfovalue(bigint, "text", "text", timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("Codice", "TitoloScheda", "NomeCampo", "TimestampValue") VALUES (' || codiceScheda || ', ''' || titoloScheda || ''', ''' || nomeCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''', "ComboValue" = null WHERE "Codice" = ' || codiceScheda || ' AND "TitoloScheda" = ''' || titoloScheda || ''' AND "NomeCampo" = ''' || nomeCampo || '''';

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, titoloScheda, nomeCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "titoloscheda" "text", "nomecampo" "text", "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 255 (class 1255 OID 430858)
-- Name: updateobject("text", "text", "text", "text", "text", integer, integer, double precision, double precision, double precision, double precision, double precision, double precision, integer, boolean, boolean, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "updateobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceVersione bigint;
	codiceModello bigint;

	selOggetti1 RECORD;

	tmpRecord RECORD;

	sql_insert text;
	sql_update text;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - %__v%): operation aborted!',username,layer0,layer1,layer2,layer3,nome, versione;
	END IF;

	-- find codice oggetto
	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	
	-- find codice modello, live status
	SELECT "Codice", "Versione", "CodiceModello", "Live" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	-- check live status and all modelled
	CASE selOggetti1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN
			RAISE EXCEPTION 'Can''t insert a model for a non preinizialized object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',layer0,layer1,layer2,layer3,nome;
		WHEN 6 THEN
			--check all modelled
			codiceVersione := selOggetti1."Codice";
			select checkallmodelled(codiceVersione) INTO tmpRecord;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	END CASE;

	codiceModello := selOggetti1."CodiceModello";

	-- update volume, layer0
	UPDATE "Modelli3D" SET "Superficie"=superficie, "Volume"=volume, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = codiceModello AND "Superficie" IS NULL AND "Volume" IS NULL;

	-- insert or update LoD information
	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "3dm_Backup", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', ' || lod || ', ' || xcentro || ', ' || ycentro || ', ' || zcentro || ', ' || raggio || ', false, false, ' || parti || ', false, ' || texture_3dm || ',' || json_texture || ', false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET xc = ' || xcentro || ', yc = ' || ycentro || ', zc = ' || zcentro || ', "Radius" = ' || raggio || ', "JSON_NumeroParti" = ' || parti || ', "3dm_Texture" = ' || texture_3dm || ', "JSON_Texture" = ' || json_texture || ' WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."updateobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "username" "text") OWNER TO "postgres";

--
-- TOC entry 267 (class 1255 OID 484272)
-- Name: updateobject("text", "text", "text", "text", "text", integer, integer, double precision, double precision, double precision, double precision, double precision, double precision, integer, boolean, boolean, boolean, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "updateobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "exportjson" boolean, "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceVersione bigint;
	codiceModello bigint;

	selOggetti1 RECORD;

	tmpRecord RECORD;

	sql_insert text;
	sql_update text;

	json boolean;

	auxint int;
  BEGIN
	-- username check
	auxint := (SELECT count(*) FROM "Utenti" WHERE "User" = username);
	IF (auxInt != 1) THEN
		RAISE EXCEPTION 'Username % is invalid! Can''t add a new object (layer=%_%_%_% - %__v%): operation aborted!',username,layer0,layer1,layer2,layer3,nome, versione;
	END IF;

	-- find codice oggetto
	codiceOggetto := (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome);
	
	-- find codice modello, live status
	SELECT "Codice", "Versione", "CodiceModello", "Live" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceOggetto AND "Versione" = versione;
	
	-- check live status and all modelled
	CASE selOggetti1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN
			RAISE EXCEPTION 'Can''t insert a model for a non preinizialized object: DB can be in a inconsistent status! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',layer0,layer1,layer2,layer3,nome;
		WHEN 6 THEN
			--check all modelled
			codiceVersione := selOggetti1."Codice";
			SELECT checkallmodelled(codiceVersione) INTO tmpRecord;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	END CASE;

	codiceModello := selOggetti1."CodiceModello";

	-- insert or update LoD information
	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "3dm_Backup", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', ' || lod || ', ' || xcentro || ', ' || ycentro || ', ' || zcentro || ', ' || raggio || ', false, false, ' || parti || ', false, ' || texture_3dm || ',' || json_texture || ', false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET xc = ' || xcentro || ', yc = ' || ycentro || ', zc = ' || zcentro || ', "Radius" = ' || raggio || ', "JSON_NumeroParti" = ' || parti || ', "3dm_Texture" = ' || texture_3dm || ', "JSON_Texture" = ' || json_texture || ' WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;

	json := (SELECT "JSON" FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod);

	IF (exportJSON = true OR json = false OR json IS NULL) THEN
		-- update volume, layer0
		UPDATE "Modelli3D" SET "Superficie"=superficie, "Volume"=volume, "LastUpdate"=now(), "LastUpdateBy"=username WHERE "Codice" = codiceModello AND "Superficie" IS NULL AND "Volume" IS NULL;
	ELSE
		sql_update := 'UPDATE "Modelli3D_LoD" SET "3dm_Texture" = ' || texture_3dm || ' WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	END IF;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."updateobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "exportjson" boolean, "username" "text") OWNER TO "postgres";

--
-- TOC entry 259 (class 1255 OID 430859)
-- Name: upload3dmfile("text", "text", "text", "text", "text", integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "upload3dmfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "file3dm" "bytea", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
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
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;

	-- find codice modello
	SELECT "Live", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selOggetti1."CodiceModello";

	CASE selOggetti1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	END CASE;

	-- update Modelli3d LoD status
	SELECT "CodiceModello", "3dm" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
	IF (selModelliLoD1."3dm" = true) THEN
		RAISE EXCEPTION 'There is already a 3dm file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,layer0,layer1,layer2,layer3,nome;
	END IF;

	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "3dm_Backup", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', '|| lod || ', 0, 0, 0, 0, true, false, null, false, false, false, false)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET "3dm" = true WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || lod;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;

	-- inserti 3dm file
	INSERT INTO "Modelli3D_3dm"("CodiceModello", "LoD", file, "LastUpdate", "LastUpdateBy")
			    VALUES (codiceModello, lod, file3dm, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."upload3dmfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "file3dm" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 260 (class 1255 OID 430860)
-- Name: uploadjsonfile("text", "text", "text", "text", "text", integer, integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "uploadjsonfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
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
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;

	-- find codice modello
	SELECT "Live", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selOggetti1."CodiceModello";

	CASE selOggetti1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	END CASE;

	-- update Modelli3d LoD status
	SELECT "CodiceModello", "JSON", "JSON_NumeroParti" INTO selModelliLoD1 FROM "Modelli3D_LoD" WHERE "CodiceModello" = codiceModello AND "LoD" = lod;
--	IF (selModelliLoD1."JSON" = true) THEN
--		RAISE EXCEPTION 'There is already a JSON file for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,layer0,layer1,layer2,layer3,nome;
--	END IF;

	IF (selModelliLoD1."CodiceModello" != codiceModello OR selModelliLoD1."JSON_NumeroParti" = 0 OR selModelliLoD1."JSON_NumeroParti" IS NULL) THEN
		RAISE EXCEPTION 'The value of JSON part''s number isn''t inserted for LoD% for this model! Can''t insert a new model for this object (layer=%_%_%_% - name=%): operation aborted!',lod,layer0,layer1,layer2,layer3,nome;
	END IF;

	UPDATE "Modelli3D_LoD" SET "JSON" = true WHERE "CodiceModello" = codiceModello AND "LoD" = lod;

	-- insert JSON files
	INSERT INTO "Modelli3D_JSON"("CodiceModello", "LoD", "Parte", file, "LastUpdate", "LastUpdateBy")
				  VALUES (codiceModello, lod, parte, filejson, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."uploadjsonfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 275 (class 1255 OID 586786)
-- Name: uploadobjfile("text", "text", "text", "text", "text", integer, integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "uploadobjfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "fileobj" "bytea", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
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
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;

	-- find codice modello
	SELECT "Live", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selOggetti1."CodiceModello";

	CASE selOggetti1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	END CASE;

	UPDATE "Modelli3D_LoD" SET "OBJ" = true WHERE "CodiceModello" = codiceModello AND "LoD" = lod;

	-- insert OBJ files
	INSERT INTO "Modelli3D_OBJ"("CodiceModello", "LoD", "Parte", file, "LastUpdate", "LastUpdateBy")
				  VALUES (codiceModello, lod, parte, fileOBJ, now(), username);
 
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."uploadobjfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "fileobj" "bytea", "username" "text") OWNER TO "postgres";

--
-- TOC entry 261 (class 1255 OID 430861)
-- Name: uploadtexturefile("text", "text", "text", "text", "text", integer, integer, integer, "text", "bytea", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "uploadtexturefile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "textureindex" integer, "qualità" integer, "filename" "text", "filetexture" "bytea", "mimetype" "text", "username" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceOggetto bigint;
	codiceModello bigint;

	selOggetti1 RECORD;
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
		RAISE EXCEPTION 'Username % is invalid! Can''t modified object (layer=%_%_%_% - name=%): operation aborted!',username,layer0,layer1,layer2,layer3,nome;
	END IF;

	-- find codice modello
	SELECT "Live", "CodiceModello" INTO selOggetti1 FROM "OggettiVersion" WHERE "CodiceOggetto" = (SELECT "Codice" FROM "Oggetti" WHERE "Layer0" = layer0 AND "Layer1" = layer1 AND "Layer2" = layer2 AND "Layer3" = layer3 AND "Name" = nome) AND "Versione" = versione;

	codiceModello := selOggetti1."CodiceModello";

	CASE selOggetti1."Live"
		WHEN 0 THEN auxInt = 0;
		WHEN 1 THEN auxInt = 0;
		WHEN 2 THEN auxInt = 0;
		WHEN 4 THEN auxInt = 0;
		WHEN 3 THEN auxInt = 0;
		WHEN 6 THEN auxInt = 0;
		ELSE RAISE EXCEPTION 'Live status (%) of object (layer=%_%_%_% - name=%) is invalid! Can''t modified object: operation aborted!',selOggetti1."Live",layer0,layer1,layer2,layer3,nome;
	END CASE;

	INSERT INTO "Modelli3D_Texture"("CodiceModello", "TextureNumber", "Qualità", "Filename", file, "MimeType", "LastUpdate", "LastUpdateBy")
				VALUES (codiceModello, textureIndex, qualità, filename, fileTexture, mimetype, now(), username);
 
	-- insert or update LoD information
	sql_insert := 'INSERT INTO "Modelli3D_LoD"("CodiceModello", "LoD", xc, yc, zc, "Radius", "3dm", "JSON", "JSON_NumeroParti", "3dm_Backup", "3dm_Texture", "JSON_Texture", "Texture") VALUES (' || codiceModello || ', ' || qualità || ', 0, 0, 0, 0, false, false, null, false, false, false, true)';
	sql_update := 'UPDATE "Modelli3D_LoD" SET "Texture" = true WHERE "CodiceModello" = ' || codiceModello || ' AND "LoD" = ' || qualità;
	
	select upsert(sql_insert, sql_update) INTO tmpRecord;
	
	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."uploadtexturefile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "textureindex" integer, "qualità" integer, "filename" "text", "filetexture" "bytea", "mimetype" "text", "username" "text") OWNER TO "postgres";

--
-- TOC entry 262 (class 1255 OID 430862)
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
-- TOC entry 173 (class 1259 OID 430863)
-- Name: Cantieri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Cantieri" (
    "Layer0" character varying(255) NOT NULL,
    "Numero" integer NOT NULL,
    "DataInizio" "date",
    "DataFine" "date",
    "Note" "text"
);


ALTER TABLE "Cantieri" OWNER TO "postgres";

--
-- TOC entry 2491 (class 0 OID 0)
-- Dependencies: 173
-- Name: TABLE "Cantieri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Cantieri" IS 'Tabella contenente l''elenco dei cantieri';


--
-- TOC entry 2492 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Cantieri"."Layer0"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Layer0" IS 'Layer0 del cantiere';


--
-- TOC entry 2493 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Cantieri"."Numero"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Numero" IS 'Numero progressivo del cantiere (0 iniziale)';


--
-- TOC entry 2494 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Cantieri"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataInizio" IS 'Data apertura del cantiere';


--
-- TOC entry 2495 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Cantieri"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataFine" IS 'Data chiusura del cantiere';


--
-- TOC entry 2496 (class 0 OID 0)
-- Dependencies: 173
-- Name: COLUMN "Cantieri"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Note" IS 'Campo note sul cantiere';


--
-- TOC entry 220 (class 1259 OID 704671)
-- Name: Categorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Categorie" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "Categorie" OWNER TO "postgres";

--
-- TOC entry 2497 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE "Categorie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Categorie" IS 'Lista delle categorie';


--
-- TOC entry 2498 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Categorie"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."Titolo" IS 'Titolo delle categorie';


--
-- TOC entry 174 (class 1259 OID 430869)
-- Name: FileExtra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "FileExtra" (
    "Filename" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "TipoRiferimento" character varying(255),
    "ValoreRiferimento" character varying(255),
    "refLayer0" character varying(255),
    "refLayer1" character varying(255),
    "refLayer2" character varying(255),
    "refLayer3" character varying(255),
    "Qualità" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "DataScatto" "date",
    "Descrizione" "text",
    "Permessi_lvl1" integer DEFAULT 7 NOT NULL,
    "Permessi_lvl2" integer DEFAULT 4 NOT NULL,
    "Permessi_lvl3" integer DEFAULT 0 NOT NULL,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "FileExtra" OWNER TO "postgres";

--
-- TOC entry 2499 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE "FileExtra"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "FileExtra" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2500 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2501 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2502 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2503 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2504 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2505 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2506 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2507 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2508 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2509 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2510 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2511 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2512 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2513 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN "FileExtra"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 175 (class 1259 OID 430880)
-- Name: Import; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Import" (
    "User" character varying(255) NOT NULL,
    "CodiceOggetto" bigint NOT NULL,
    "CodiceVersione" bigint NOT NULL,
    "CodiceModello" bigint,
    "Colore" integer,
    "readonly" boolean,
    "NewAdded" boolean DEFAULT true
);


ALTER TABLE "Import" OWNER TO "postgres";

--
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE "Import"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Import" IS 'Tabella contenente le liste di importazione degli utenti';


--
-- TOC entry 2516 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."User" IS 'Nome dell''utente';


--
-- TOC entry 2517 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceOggetto" IS 'Codice dell''oggetto da importare';


--
-- TOC entry 2518 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceVersione" IS 'Codice dell''oggetto+versione da importare';


--
-- TOC entry 2519 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceModello" IS 'Codice del modello da importare';


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."Colore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."Colore" IS 'Codice del colore da associare all''oggetto da importare';


--
-- TOC entry 2521 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."readonly"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."readonly" IS 'Identifica se importato in sola lettura (o modifica)';


--
-- TOC entry 2522 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Import"."NewAdded"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."NewAdded" IS 'Indica se è stato aggiunto alla lista di importazione e mai importato';


--
-- TOC entry 184 (class 1259 OID 430944)
-- Name: Modelli3D; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Modelli3D" (
    "Codice" bigint NOT NULL,
    "Type" integer DEFAULT 0 NOT NULL,
    "Superficie" double precision,
    "Volume" double precision,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D" OWNER TO "postgres";

--
-- TOC entry 2523 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE "Modelli3D"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D" IS 'Tabella di riferimento per i Modelli 3D';


--
-- TOC entry 2524 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Codice" IS 'Codice del Modello 3D (diverso dal codice dell''oggetto!!!) - PRIMARY KEY';


--
-- TOC entry 2525 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D"."Superficie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Superficie" IS 'Superficie dell''oggetto (calcolata dal modello 3D)';


--
-- TOC entry 2526 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D"."Volume"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Volume" IS 'Volume dell''oggetto (calcolato dal modello 3D)';


--
-- TOC entry 2527 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2528 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 2529 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Modelli3D"."Type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Type" IS '0 -> Mesh
1 -> Point Cloud
2 -> HotSpot';


--
-- TOC entry 176 (class 1259 OID 430884)
-- Name: Modelli3D_LoD; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Modelli3D_LoD" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "xc" double precision NOT NULL,
    "yc" double precision NOT NULL,
    "zc" double precision NOT NULL,
    "Radius" double precision NOT NULL,
    "Texture" boolean DEFAULT false NOT NULL,
    "3dm" boolean DEFAULT false NOT NULL,
    "3dm_Texture" boolean DEFAULT false NOT NULL,
    "3dm_Backup" boolean DEFAULT false NOT NULL,
    "JSON" boolean DEFAULT false NOT NULL,
    "JSON_NumeroParti" integer,
    "JSON_Texture" boolean DEFAULT false NOT NULL,
    "OBJ" boolean DEFAULT false NOT NULL,
    "HotSpot" boolean DEFAULT false NOT NULL
);


ALTER TABLE "Modelli3D_LoD" OWNER TO "postgres";

--
-- TOC entry 2530 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE "Modelli3D_LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_LoD" IS 'Tabella di riferimento per i livelli di dettaglio dei Modelli 3D';


--
-- TOC entry 2531 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."CodiceModello" IS 'Riferimento al codice del Modello 3D';


--
-- TOC entry 2532 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."LoD" IS 'Level of Detail del modello 3D';


--
-- TOC entry 2533 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."xc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."xc" IS 'Coordinata x del centro';


--
-- TOC entry 2534 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."yc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."yc" IS 'Coordinata y del centro';


--
-- TOC entry 2535 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."zc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."zc" IS 'Coordinata z del centro';


--
-- TOC entry 2536 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."Radius"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Radius" IS 'Raggio del bounding box sferico';


--
-- TOC entry 2537 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm" IS 'Indica se è stato inserito nel database il file 3dm corrispondente';


--
-- TOC entry 2538 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."3dm_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm_Texture" IS 'Specifica se il modello 3dm contiene le informazioni per la texture';


--
-- TOC entry 2539 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON" IS 'Indica se è stato inserito nel database il file JSON corrispondente';


--
-- TOC entry 2540 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."JSON_NumeroParti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_NumeroParti" IS 'Qualora sia presente il file JSON, specifica in quanti parti viene suddiviso';


--
-- TOC entry 2541 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."JSON_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_Texture" IS 'Specifica se il modello JSON contiene le informazioni per la texture';


--
-- TOC entry 2542 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Texture" IS 'Specifica se è stata inserita una texture';


--
-- TOC entry 2543 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."3dm_Backup"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm_Backup" IS 'Indica se è presente nel database un backup per il file 3dm corrispondente';


--
-- TOC entry 2544 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."OBJ"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."OBJ" IS 'Indica se è stato inserito nel database il file OBJ corrispondente';


--
-- TOC entry 2545 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Modelli3D_LoD"."HotSpot"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."HotSpot" IS 'Indica se è stato inserito nel database le informazioni per l''HotSpot';


--
-- TOC entry 177 (class 1259 OID 430893)
-- Name: Oggetti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti" (
    "Codice" bigint NOT NULL,
    "Layer0" character varying(255) NOT NULL,
    "Layer1" character varying(255) NOT NULL,
    "Layer2" character varying(255) NOT NULL,
    "Layer3" character varying(255) NOT NULL,
    "Name" character varying(255) NOT NULL,
    "DataCreazione" timestamp with time zone DEFAULT "now"() NOT NULL,
    "DataEliminazione" timestamp with time zone,
    "CantiereCreazione" integer DEFAULT 0 NOT NULL,
    "CantiereEliminazione" integer,
    "Category" character varying(255),
    "Lock" character varying(255),
    "Updating" boolean DEFAULT false NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Oggetti" OWNER TO "postgres";

--
-- TOC entry 2546 (class 0 OID 0)
-- Dependencies: 177
-- Name: TABLE "Oggetti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2547 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Codice" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2548 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Layer0"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer0" IS 'Layer0 in cui è contenuto l''oggetto';


--
-- TOC entry 2549 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Layer1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer1" IS 'Layer1 in cui è contenuto l''oggetto';


--
-- TOC entry 2550 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Layer2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer2" IS 'Layer2 in cui è contenuto l''oggetto';


--
-- TOC entry 2551 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Layer3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer3" IS 'Layer3 in cui è contenuto l''oggetto';


--
-- TOC entry 2552 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Name" IS 'Nome utilizzato per disambiguare due oggetti appartenenti allo stesso Layer0 + Layer1 + Layer2 + Layer3';


--
-- TOC entry 2553 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto';


--
-- TOC entry 2554 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto';


--
-- TOC entry 2555 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto';


--
-- TOC entry 2556 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto';


--
-- TOC entry 2557 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2558 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2559 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2560 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 2561 (class 0 OID 0)
-- Dependencies: 177
-- Name: COLUMN "Oggetti"."Category"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Category" IS 'Categoria dell''oggetto';


--
-- TOC entry 178 (class 1259 OID 430903)
-- Name: OggettiVersioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion" (
    "Codice" bigint NOT NULL,
    "CodiceOggetto" bigint NOT NULL,
    "Versione" integer DEFAULT 0 NOT NULL,
    "CodiceModello" bigint,
    "Originale" bigint DEFAULT 0 NOT NULL,
    "Live" integer DEFAULT 4 NOT NULL,
    "DataCreazione" timestamp with time zone DEFAULT "now"() NOT NULL,
    "DataEliminazione" timestamp with time zone,
    "CantiereCreazione" integer DEFAULT 0 NOT NULL,
    "CantiereEliminazione" integer,
    "Lock" character varying(255),
    "Updating" boolean DEFAULT false NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "OggettiVersion" OWNER TO "postgres";

--
-- TOC entry 2562 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE "OggettiVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2563 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Codice" IS 'Codice identificativo dell''oggetto+versione - PRIMARY KEY';


--
-- TOC entry 2564 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CodiceOggetto" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2565 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."Versione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Versione" IS 'Versione dell''oggetto, per identificare variazioni del modello dell''oggetto in seguito ad interventi o cambiamenti (DEFAULT 0)';


--
-- TOC entry 2566 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CodiceModello" IS 'Codice del modello 3D dell''oggetto+versione';


--
-- TOC entry 2567 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Originale" IS 'Se 0 è l''oggetto+versione originale, altrimenti è un oggetto modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2568 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto+versione';


--
-- TOC entry 2569 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto+versione';


--
-- TOC entry 2570 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."Live"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Live" IS 'L''oggetto è attivo nel modello 3d corrente?

0 -> non attivo
1 -> live on-line
2 -> live on-line, ma morto (nuovo non pronto)
3 -> modello da creare di un oggetto che deve diventare on-line
4 -> inserito ex-novo da Rhino, da gestire e attivare
6 -> modello figlio creato, ma non on-line perché in attesa di modello di altri figli';


--
-- TOC entry 2571 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione';


--
-- TOC entry 2572 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione';


--
-- TOC entry 2573 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2574 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2575 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2576 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "OggettiVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 179 (class 1259 OID 430916)
-- Name: ListaOggettiLoD; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "ListaOggettiLoD" AS
 SELECT "OggettiVersion"."Codice",
    "Oggetti"."Layer0",
    "Oggetti"."Layer1",
    "Oggetti"."Layer2",
    "Oggetti"."Layer3",
    "Oggetti"."Name",
    "OggettiVersion"."CodiceModello",
    "OggettiVersion"."Originale",
    "OggettiVersion"."Live",
    "OggettiVersion"."DataCreazione",
    "OggettiVersion"."DataEliminazione",
    "Modelli3D_LoD"."LoD",
    "Modelli3D_LoD"."JSON",
    "Modelli3D_LoD"."JSON_NumeroParti",
    "Modelli3D_LoD"."xc",
    "Modelli3D_LoD"."yc",
    "Modelli3D_LoD"."zc",
    "Modelli3D_LoD"."Radius",
    "Modelli3D_LoD"."3dm_Texture" AS "Texture3dm",
    "Modelli3D_LoD"."JSON_Texture" AS "TextureJSON",
    "Modelli3D"."Type" AS "ModelType"
   FROM ((("Oggetti"
     JOIN "OggettiVersion" ON (("Oggetti"."Codice" = "OggettiVersion"."CodiceOggetto")))
     JOIN "Modelli3D" ON (("OggettiVersion"."CodiceModello" = "Modelli3D"."Codice")))
     JOIN "Modelli3D_LoD" ON (("OggettiVersion"."CodiceModello" = "Modelli3D_LoD"."CodiceModello")))
  WHERE ((("OggettiVersion"."Live" = 1) OR ("OggettiVersion"."Live" = 2)) AND ("OggettiVersion"."Updating" = false))
  ORDER BY "OggettiVersion"."Codice", "Modelli3D_LoD"."LoD";


ALTER TABLE "ListaOggettiLoD" OWNER TO "postgres";

--
-- TOC entry 180 (class 1259 OID 430921)
-- Name: Log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Log" (
    "NumeroLog" bigint NOT NULL,
    "DateTime" timestamp without time zone NOT NULL,
    "Messaggio" "text" NOT NULL,
    "User" character varying(255)
);


ALTER TABLE "Log" OWNER TO "postgres";

--
-- TOC entry 2577 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE "Log"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Log" IS 'Log degli errori';


--
-- TOC entry 2578 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Log"."DateTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."DateTime" IS 'Data e ora dell''evento';


--
-- TOC entry 2579 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Log"."Messaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."Messaggio" IS 'Messaggio di log';


--
-- TOC entry 2580 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Log"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."User" IS 'Utente che ha effettuato l''operazione';


--
-- TOC entry 181 (class 1259 OID 430927)
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
-- TOC entry 2581 (class 0 OID 0)
-- Dependencies: 181
-- Name: Log_NumeroLog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Log_NumeroLog_seq" OWNED BY "Log"."NumeroLog";


--
-- TOC entry 182 (class 1259 OID 430929)
-- Name: MaterialeOggetti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "MaterialeOggetti" (
    "CodiceOggetto" bigint NOT NULL,
    "URL" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "Descrizione" "text",
    "DataScatto" "date" NOT NULL,
    "Permessi_lvl1" integer DEFAULT 7,
    "Permessi_lvl2" integer DEFAULT 4,
    "Permessi_lvl3" integer DEFAULT 0,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "MaterialeOggetti" OWNER TO "postgres";

--
-- TOC entry 2582 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE "MaterialeOggetti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeOggetti" IS 'Tabella contenente tutto il materiale (file) associato agli oggetti';


--
-- TOC entry 2583 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."CodiceOggetto" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2584 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."URL" IS 'URL del materiale';


--
-- TOC entry 2585 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2586 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2587 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2588 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2589 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2590 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2591 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2592 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2593 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2594 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2595 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "MaterialeOggetti"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 217 (class 1259 OID 586483)
-- Name: MaterialeSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "MaterialeSubVersion" (
    "CodiceSubVersion" bigint NOT NULL,
    "URL" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "Descrizione" "text",
    "DataScatto" "date" NOT NULL,
    "Permessi_lvl1" integer DEFAULT 7,
    "Permessi_lvl2" integer DEFAULT 4,
    "Permessi_lvl3" integer DEFAULT 0,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "MaterialeSubVersion" OWNER TO "postgres";

--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE "MaterialeSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeSubVersion" IS 'Tabella contenente tutto il materiale (file) associato alle SubVersion';


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."CodiceSubVersion" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2598 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."URL" IS 'URL del materiale';


--
-- TOC entry 2599 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2600 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2601 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2602 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2603 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2604 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2605 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2606 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2607 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2608 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2609 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "MaterialeSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 210 (class 1259 OID 443950)
-- Name: MaterialeVersioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "MaterialeVersioni" (
    "CodiceVersione" bigint NOT NULL,
    "URL" character varying(255) NOT NULL,
    "Tipo" character varying(255) NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "Descrizione" "text",
    "DataScatto" "date" NOT NULL,
    "Permessi_lvl1" integer DEFAULT 7,
    "Permessi_lvl2" integer DEFAULT 4,
    "Permessi_lvl3" integer DEFAULT 0,
    "Proprietario" character varying(255) NOT NULL,
    "Gruppo" character varying(255) NOT NULL,
    "LastModified" timestamp without time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "MaterialeVersioni" OWNER TO "postgres";

--
-- TOC entry 2610 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE "MaterialeVersioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeVersioni" IS 'Tabella contenente tutto il materiale (file) associato alle versioni';


--
-- TOC entry 2611 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."CodiceVersione" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2612 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."URL" IS 'URL del materiale';


--
-- TOC entry 2613 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2614 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2615 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2616 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2617 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2618 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2619 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2620 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2621 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2622 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2623 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "MaterialeVersioni"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 183 (class 1259 OID 430940)
-- Name: MaxCantieri; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "MaxCantieri" AS
 SELECT "Cantieri"."Layer0",
    "max"("Cantieri"."Numero") AS "num"
   FROM "Cantieri"
  GROUP BY "Cantieri"."Layer0";


ALTER TABLE "MaxCantieri" OWNER TO "postgres";

--
-- TOC entry 185 (class 1259 OID 430948)
-- Name: Modelli3D_3dm; Type: TABLE; Schema: public; Owner: postgres
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
-- TOC entry 2624 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE "Modelli3D_3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm" IS 'Tabella contenente i file 3dm dei Modelli 3D';


--
-- TOC entry 2625 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Modelli3D_3dm"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2626 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Modelli3D_3dm"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2627 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Modelli3D_3dm"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."file" IS 'File 3dm codificato in bytea';


--
-- TOC entry 2628 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Modelli3D_3dm"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2629 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Modelli3D_3dm"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 186 (class 1259 OID 430956)
-- Name: Modelli3D_3dm_Backup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Modelli3D_3dm_Backup" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D_3dm_Backup" OWNER TO "postgres";

--
-- TOC entry 2630 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE "Modelli3D_3dm_Backup"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm_Backup" IS 'Tabella contenente il backup dei  file 3dm dei Modelli 3D';


--
-- TOC entry 187 (class 1259 OID 430964)
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
-- TOC entry 2631 (class 0 OID 0)
-- Dependencies: 187
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Modelli3D_Codice_seq" OWNED BY "Modelli3D"."Codice";


--
-- TOC entry 219 (class 1259 OID 592999)
-- Name: Modelli3D_HotSpotColor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Modelli3D_HotSpotColor" (
    "CodiceModello" bigint NOT NULL,
    "ColorR" real DEFAULT 1 NOT NULL,
    "ColorG" real DEFAULT 0 NOT NULL,
    "ColorB" real DEFAULT 0 NOT NULL,
    "ColorA" real DEFAULT 0.6 NOT NULL
);


ALTER TABLE "Modelli3D_HotSpotColor" OWNER TO "postgres";

--
-- TOC entry 2632 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE "Modelli3D_HotSpotColor"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_HotSpotColor" IS 'Contiene i dati colore per gli hotspot';


--
-- TOC entry 2633 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN "Modelli3D_HotSpotColor"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2634 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorR"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorR" IS 'Colore red';


--
-- TOC entry 2635 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorG"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorG" IS 'Colore green';


--
-- TOC entry 2636 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorB"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorB" IS 'Colore blue';


--
-- TOC entry 2637 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorA"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorA" IS 'Canale Alpha del colore';


--
-- TOC entry 188 (class 1259 OID 430966)
-- Name: Modelli3D_JSON; Type: TABLE; Schema: public; Owner: postgres
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
-- TOC entry 2638 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE "Modelli3D_JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_JSON" IS 'Tabella contenente i file JSON dei Modelli 3D';


--
-- TOC entry 2639 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_JSON"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2640 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_JSON"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2641 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_JSON"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."Parte" IS 'Parte del file JSON';


--
-- TOC entry 2642 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_JSON"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."file" IS 'File JSON codificato in bytea';


--
-- TOC entry 2643 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_JSON"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2644 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "Modelli3D_JSON"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 218 (class 1259 OID 586772)
-- Name: Modelli3D_OBJ; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Modelli3D_OBJ" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "Parte" integer NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "Modelli3D_OBJ" OWNER TO "postgres";

--
-- TOC entry 2645 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE "Modelli3D_OBJ"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_OBJ" IS 'Tabella contenente i file OBJ dei Modelli 3D';


--
-- TOC entry 2646 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Modelli3D_OBJ"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2647 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Modelli3D_OBJ"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2648 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Modelli3D_OBJ"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."Parte" IS 'Parte del file OBJ';


--
-- TOC entry 2649 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Modelli3D_OBJ"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."file" IS 'File OBJ codificato in bytea';


--
-- TOC entry 2650 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Modelli3D_OBJ"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2651 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Modelli3D_OBJ"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 189 (class 1259 OID 430973)
-- Name: Modelli3D_Texture; Type: TABLE; Schema: public; Owner: postgres
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
-- TOC entry 2652 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE "Modelli3D_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_Texture" IS 'Tabella contenente le texture dei modelli';


--
-- TOC entry 2653 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2654 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."TextureNumber"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."TextureNumber" IS 'Numero dell''indice della texture (se è una texture sola è 0)';


--
-- TOC entry 2655 (class 0 OID 0)
-- Dependencies: 189
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
-- TOC entry 2656 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."Filename" IS 'Nome del file';


--
-- TOC entry 2657 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."file" IS 'File salvato il bytea';


--
-- TOC entry 2658 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."MimeType"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."MimeType" IS 'MimeType del file';


--
-- TOC entry 2659 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."LastUpdate" IS 'Data dell''ultima modifica';


--
-- TOC entry 2660 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "Modelli3D_Texture"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 190 (class 1259 OID 430982)
-- Name: OggettiSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion" (
    "Codice" bigint NOT NULL,
    "CodiceOggetto" bigint NOT NULL,
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


ALTER TABLE "OggettiSubVersion" OWNER TO "postgres";

--
-- TOC entry 2661 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE "OggettiSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2662 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Codice" IS 'Codice identificativo dell''oggetto+versione - PRIMARY KEY';


--
-- TOC entry 2663 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CodiceOggetto" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2664 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CodiceVersione" IS 'Codice identificativo dell''oggetto+versione ';


--
-- TOC entry 2665 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."SubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."SubVersion" IS 'SubVersion dell''oggetto, per identificare variazioni in seguito ad interventi che non modificano il modello (DEFAULT 0)';


--
-- TOC entry 2666 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Originale" IS 'Se 0 è l''oggetto+versione originale, altrimenti è un oggetto modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2667 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto+versione+subversion';


--
-- TOC entry 2668 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto+versione+subversion';


--
-- TOC entry 2669 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione+subversion';


--
-- TOC entry 2670 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione+subversion';


--
-- TOC entry 2671 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2672 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "OggettiSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 223 (class 1259 OID 704713)
-- Name: OggettiSubVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_CategorieSchede" (
    "Categoria" character varying(255) NOT NULL,
    "Scheda" character varying(255) NOT NULL
);


ALTER TABLE "OggettiSubVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE "OggettiSubVersion_CategorieSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_CategorieSchede" IS 'Associazione delle categorie con le schede';


--
-- TOC entry 216 (class 1259 OID 586437)
-- Name: OggettiSubVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "OggettiSubVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE "OggettiSubVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."TitoloScheda" IS 'Titolo della Scheda';


--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 215 (class 1259 OID 586435)
-- Name: OggettiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiSubVersion_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiSubVersion_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 215
-- Name: OggettiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiSubVersion_InfoComboBox_Codice_seq" OWNED BY "OggettiSubVersion_InfoComboBox"."Codice";


--
-- TOC entry 191 (class 1259 OID 430995)
-- Name: OggettiSubVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_ListaInformazioni" (
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
    "Height" integer DEFAULT 22 NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL
);


ALTER TABLE "OggettiSubVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE "OggettiSubVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli oggetti e dei relativi campi';


--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 192 (class 1259 OID 431010)
-- Name: OggettiSubVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "OggettiSubVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE "OggettiSubVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 193 (class 1259 OID 431013)
-- Name: OggettiSubVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_RelazioniSchede" (
    "CodiceSubVersion" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "OggettiSubVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE "OggettiSubVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_RelazioniSchede" IS 'Relazioni tra gli oggetti e le schede informative';


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceSubVersion" IS 'Codice dell''oggetto';


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 194 (class 1259 OID 431016)
-- Name: OggettiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiSubVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 194
-- Name: OggettiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "OggettiSubVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 195 (class 1259 OID 431018)
-- Name: OggettiSubVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_Schede" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint
);


ALTER TABLE "OggettiSubVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE "OggettiSubVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_Schede" IS 'Informazioni testuali sugli oggetti';


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "OggettiSubVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 222 (class 1259 OID 704695)
-- Name: OggettiVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_CategorieSchede" (
    "Categoria" character varying(255) NOT NULL,
    "Scheda" character varying(255) NOT NULL
);


ALTER TABLE "OggettiVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE "OggettiVersion_CategorieSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_CategorieSchede" IS 'Associazione delle categorie con le schede';


--
-- TOC entry 214 (class 1259 OID 586404)
-- Name: OggettiVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "OggettiVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE "OggettiVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "OggettiVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "OggettiVersion_InfoComboBox"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."TitoloScheda" IS 'Titolo della Scheda';


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "OggettiVersion_InfoComboBox"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2716 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "OggettiVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 213 (class 1259 OID 586402)
-- Name: OggettiVersion_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiVersion_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiVersion_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2717 (class 0 OID 0)
-- Dependencies: 213
-- Name: OggettiVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiVersion_InfoComboBox_Codice_seq" OWNED BY "OggettiVersion_InfoComboBox"."Codice";


--
-- TOC entry 196 (class 1259 OID 431024)
-- Name: OggettiVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_ListaInformazioni" (
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
    "Height" integer DEFAULT 22 NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL
);


ALTER TABLE "OggettiVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2718 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE "OggettiVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli oggetti e dei relativi campi';


--
-- TOC entry 2719 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2720 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2729 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 2730 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 197 (class 1259 OID 431039)
-- Name: OggettiVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "OggettiVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2731 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE "OggettiVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2732 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 198 (class 1259 OID 431042)
-- Name: OggettiVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_RelazioniSchede" (
    "CodiceVersione" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "OggettiVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2733 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE "OggettiVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_RelazioniSchede" IS 'Relazioni tra gli oggetti e le schede informative';


--
-- TOC entry 2734 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_RelazioniSchede"."CodiceVersione" IS 'Codice dell''oggetto';


--
-- TOC entry 2735 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 199 (class 1259 OID 431045)
-- Name: OggettiVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2736 (class 0 OID 0)
-- Dependencies: 199
-- Name: OggettiVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "OggettiVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 200 (class 1259 OID 431047)
-- Name: OggettiVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_Schede" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint
);


ALTER TABLE "OggettiVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 2737 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE "OggettiVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_Schede" IS 'Informazioni testuali sugli oggetti';


--
-- TOC entry 2738 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2739 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2740 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2741 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2742 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2743 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2744 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2745 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 2746 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN "OggettiVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 221 (class 1259 OID 704676)
-- Name: Oggetti_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_CategorieSchede" (
    "Categoria" character varying(255) NOT NULL,
    "Scheda" character varying(255) NOT NULL
);


ALTER TABLE "Oggetti_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2747 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE "Oggetti_CategorieSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_CategorieSchede" IS 'Associazione delle categorie con le schede';


--
-- TOC entry 201 (class 1259 OID 431053)
-- Name: Oggetti_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2748 (class 0 OID 0)
-- Dependencies: 201
-- Name: Oggetti_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_Codice_seq" OWNED BY "Oggetti"."Codice";


--
-- TOC entry 212 (class 1259 OID 586379)
-- Name: Oggetti_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "Oggetti_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2749 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE "Oggetti_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2750 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "Oggetti_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2751 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "Oggetti_InfoComboBox"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."TitoloScheda" IS 'Titolo della Scheda';


--
-- TOC entry 2752 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "Oggetti_InfoComboBox"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2753 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "Oggetti_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 211 (class 1259 OID 586377)
-- Name: Oggetti_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2754 (class 0 OID 0)
-- Dependencies: 211
-- Name: Oggetti_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_InfoComboBox_Codice_seq" OWNED BY "Oggetti_InfoComboBox"."Codice";


--
-- TOC entry 202 (class 1259 OID 431055)
-- Name: Oggetti_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_ListaInformazioni" (
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
    "Height" integer DEFAULT 22 NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL
);


ALTER TABLE "Oggetti_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2755 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "Oggetti_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_ListaInformazioni" IS 'Elenco delle schede e dei campi di informazioni sugli oggetti e dei relativi campi';


--
-- TOC entry 2756 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Titolo" IS 'Titolo della scheda';


--
-- TOC entry 2757 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2758 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2759 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2760 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2761 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2762 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2763 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2764 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2765 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2766 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 2767 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un ComboBox';


--
-- TOC entry 203 (class 1259 OID 431070)
-- Name: Oggetti_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_ListaSchede" (
    "Titolo" character varying(255) NOT NULL
);


ALTER TABLE "Oggetti_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2768 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE "Oggetti_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2769 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN "Oggetti_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 204 (class 1259 OID 431073)
-- Name: Oggetti_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_RelazioniSchede" (
    "CodiceOggetto" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "Oggetti_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2770 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "Oggetti_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_RelazioniSchede" IS 'Relazioni tra gli oggetti e le schede informative';


--
-- TOC entry 2771 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_RelazioniSchede"."CodiceOggetto" IS 'Codice dell''oggetto';


--
-- TOC entry 2772 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "Oggetti_RelazioniSchede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_RelazioniSchede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 205 (class 1259 OID 431076)
-- Name: Oggetti_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2773 (class 0 OID 0)
-- Dependencies: 205
-- Name: Oggetti_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_RelazioniSchede_CodiceScheda_seq" OWNED BY "Oggetti_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 206 (class 1259 OID 431078)
-- Name: Oggetti_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_Schede" (
    "Codice" bigint NOT NULL,
    "TitoloScheda" character varying(255) NOT NULL,
    "NomeCampo" character varying(255) NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint
);


ALTER TABLE "Oggetti_Schede" OWNER TO "postgres";

--
-- TOC entry 2774 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "Oggetti_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_Schede" IS 'Informazioni testuali sugli oggetti';


--
-- TOC entry 2775 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."Codice" IS 'Codice della scheda';


--
-- TOC entry 2776 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."TitoloScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."TitoloScheda" IS 'Titolo della scheda';


--
-- TOC entry 2777 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."NomeCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."NomeCampo" IS 'Nome del campo';


--
-- TOC entry 2778 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2779 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2780 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2781 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."TextValue" IS 'Valore testo';


--
-- TOC entry 2782 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 2783 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Oggetti_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 207 (class 1259 OID 431084)
-- Name: Oggetti_SubVersion_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_SubVersion_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_SubVersion_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2784 (class 0 OID 0)
-- Dependencies: 207
-- Name: Oggetti_SubVersion_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_SubVersion_Codice_seq" OWNED BY "OggettiSubVersion"."Codice";


--
-- TOC entry 208 (class 1259 OID 431086)
-- Name: Oggetti_Versioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_Versioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_Versioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2785 (class 0 OID 0)
-- Dependencies: 208
-- Name: Oggetti_Versioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_Versioni_Codice_seq" OWNED BY "OggettiVersion"."Codice";


--
-- TOC entry 209 (class 1259 OID 431088)
-- Name: Utenti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Utenti" (
    "User" character varying(255) NOT NULL,
    "Password" character varying NOT NULL,
    "FullName" character varying(255) NOT NULL,
    "Gruppi" character varying NOT NULL
);


ALTER TABLE "Utenti" OWNER TO "postgres";

--
-- TOC entry 2786 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "Utenti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Utenti" IS 'Tabella accessi e permessi';


--
-- TOC entry 2787 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "Utenti"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."User" IS 'Nome utente';


--
-- TOC entry 2788 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "Utenti"."Password"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Password" IS 'Password dell''account';


--
-- TOC entry 2789 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "Utenti"."FullName"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."FullName" IS 'Nome e cognome reale';


--
-- TOC entry 2790 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "Utenti"."Gruppi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Gruppi" IS 'gruppi, separati da virgole e senza spazi';


--
-- TOC entry 2168 (class 2604 OID 431094)
-- Name: NumeroLog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Log" ALTER COLUMN "NumeroLog" SET DEFAULT "nextval"('"Log_NumeroLog_seq"'::"regclass");


--
-- TOC entry 2175 (class 2604 OID 431095)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Modelli3D_Codice_seq"'::"regclass");


--
-- TOC entry 2159 (class 2604 OID 431096)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_Codice_seq"'::"regclass");


--
-- TOC entry 2192 (class 2604 OID 431097)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_SubVersion_Codice_seq"'::"regclass");


--
-- TOC entry 2233 (class 2604 OID 586440)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiSubVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2203 (class 2604 OID 431098)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"OggettiSubVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2167 (class 2604 OID 431099)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_Versioni_Codice_seq"'::"regclass");


--
-- TOC entry 2232 (class 2604 OID 586407)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2214 (class 2604 OID 431100)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"OggettiVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2231 (class 2604 OID 586382)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2225 (class 2604 OID 431101)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"Oggetti_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2319 (class 2606 OID 704675)
-- Name: Categorie_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Categorie"
    ADD CONSTRAINT "Categorie_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2249 (class 2606 OID 431268)
-- Name: Import_PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_PrimaryKey" PRIMARY KEY ("User", "CodiceVersione");


--
-- TOC entry 2247 (class 2606 OID 431270)
-- Name: KeyFileExtra; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "FileExtra"
    ADD CONSTRAINT "KeyFileExtra" PRIMARY KEY ("Filename");


--
-- TOC entry 2295 (class 2606 OID 431272)
-- Name: ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaInformazioni"
    ADD CONSTRAINT "ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2261 (class 2606 OID 431274)
-- Name: Log-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "Log-key" PRIMARY KEY ("NumeroLog");


--
-- TOC entry 2313 (class 2606 OID 586495)
-- Name: MaterialeSubVersion_SubVersion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeSubVersion"
    ADD CONSTRAINT "MaterialeSubVersion_SubVersion_pkey" PRIMARY KEY ("CodiceSubVersion", "URL", "Qualità");


--
-- TOC entry 2305 (class 2606 OID 443962)
-- Name: MaterialeVersioni_Versioni_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeVersioni"
    ADD CONSTRAINT "MaterialeVersioni_Versioni_pkey" PRIMARY KEY ("CodiceVersione", "URL", "Qualità");


--
-- TOC entry 2263 (class 2606 OID 431276)
-- Name: Materiale_oggetti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeOggetti"
    ADD CONSTRAINT "Materiale_oggetti_pkey" PRIMARY KEY ("CodiceOggetto", "URL", "Qualità");


--
-- TOC entry 2265 (class 2606 OID 431278)
-- Name: Modelli3D-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D"
    ADD CONSTRAINT "Modelli3D-primary-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2267 (class 2606 OID 431280)
-- Name: Modelli3D_3dm-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2269 (class 2606 OID 431282)
-- Name: Modelli3D_3dm_Backup-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm_Backup"
    ADD CONSTRAINT "Modelli3D_3dm_Backup-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "LastUpdate");


--
-- TOC entry 2317 (class 2606 OID 593003)
-- Name: Modelli3D_HotSpotColor-PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_HotSpotColor"
    ADD CONSTRAINT "Modelli3D_HotSpotColor-PrimaryKey" PRIMARY KEY ("CodiceModello");


--
-- TOC entry 2251 (class 2606 OID 431284)
-- Name: Modelli3D_LoD-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-primary-key" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2273 (class 2606 OID 431286)
-- Name: Modelli3D_Textture-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Textture-primaryKey" PRIMARY KEY ("CodiceModello", "TextureNumber", "Qualità");


--
-- TOC entry 2271 (class 2606 OID 431288)
-- Name: Modelli3d_OggettiJSON-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3d_OggettiJSON-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2315 (class 2606 OID 586780)
-- Name: Modelli3d_OggettiOBJ-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_OBJ"
    ADD CONSTRAINT "Modelli3d_OggettiOBJ-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2253 (class 2606 OID 431290)
-- Name: Oggetti-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti"
    ADD CONSTRAINT "Oggetti-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2255 (class 2606 OID 431292)
-- Name: Oggetti-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti"
    ADD CONSTRAINT "Oggetti-unicità" UNIQUE ("Layer0", "Layer1", "Layer2", "Layer3", "Name");


--
-- TOC entry 2325 (class 2606 OID 704720)
-- Name: OggettiSubVersion_CategorieSchede_primary; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_primary" PRIMARY KEY ("Categoria", "Scheda");


--
-- TOC entry 2311 (class 2606 OID 586445)
-- Name: OggettiSubVersion_InfoComboBox-PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiSubVersion_InfoComboBox-PrimaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2279 (class 2606 OID 431294)
-- Name: OggettiSubVersion_ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2281 (class 2606 OID 431296)
-- Name: OggettiSubVersion_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaSchede"
    ADD CONSTRAINT "OggettiSubVersion_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2283 (class 2606 OID 431298)
-- Name: OggettiSubVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceSubVersion", "TitoloScheda");


--
-- TOC entry 2285 (class 2606 OID 431300)
-- Name: OggettiSubVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2323 (class 2606 OID 704702)
-- Name: OggettiVersion_CategorieSchede_primary; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_primary" PRIMARY KEY ("Categoria", "Scheda");


--
-- TOC entry 2309 (class 2606 OID 586412)
-- Name: OggettiVersion_InfoComboBox-PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiVersion_InfoComboBox-PrimaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2287 (class 2606 OID 431302)
-- Name: OggettiVersion_ListaSchede-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaSchede-primaryKey" PRIMARY KEY ("Titolo", "Campo");


--
-- TOC entry 2289 (class 2606 OID 431304)
-- Name: OggettiVersion_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaSchede"
    ADD CONSTRAINT "OggettiVersion_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2291 (class 2606 OID 431306)
-- Name: OggettiVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceVersione", "TitoloScheda");


--
-- TOC entry 2293 (class 2606 OID 431308)
-- Name: OggettiVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2321 (class 2606 OID 704683)
-- Name: Oggetti_CategorieSchede_primary; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_primary" PRIMARY KEY ("Categoria", "Scheda");


--
-- TOC entry 2307 (class 2606 OID 586387)
-- Name: Oggetti_InfoComboBox-PrimaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_InfoComboBox"
    ADD CONSTRAINT "Oggetti_InfoComboBox-PrimaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2297 (class 2606 OID 431310)
-- Name: Oggetti_ListaSchede_primKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaSchede"
    ADD CONSTRAINT "Oggetti_ListaSchede_primKey" PRIMARY KEY ("Titolo");


--
-- TOC entry 2299 (class 2606 OID 431312)
-- Name: Oggetti_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceOggetto", "TitoloScheda");


--
-- TOC entry 2301 (class 2606 OID 431314)
-- Name: Oggetti_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_primaryKey" PRIMARY KEY ("Codice", "TitoloScheda", "NomeCampo");


--
-- TOC entry 2275 (class 2606 OID 431316)
-- Name: Oggetti_SubVersion-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2277 (class 2606 OID 431318)
-- Name: Oggetti_SubVersion-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-unicità" UNIQUE ("CodiceOggetto", "CodiceVersione", "SubVersion");


--
-- TOC entry 2257 (class 2606 OID 431320)
-- Name: Oggetti_Versioni-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key" PRIMARY KEY ("Codice");


--
-- TOC entry 2259 (class 2606 OID 431322)
-- Name: Oggetti_Versioni-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-unicità" UNIQUE ("CodiceOggetto", "Versione");


--
-- TOC entry 2303 (class 2606 OID 431324)
-- Name: Utenti-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Utenti"
    ADD CONSTRAINT "Utenti-key" PRIMARY KEY ("User");


--
-- TOC entry 2245 (class 2606 OID 431326)
-- Name: prim_key_cantieri; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Cantieri"
    ADD CONSTRAINT "prim_key_cantieri" PRIMARY KEY ("Layer0", "Numero");


--
-- TOC entry 2326 (class 2606 OID 431327)
-- Name: Import_CodiceModelloRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceModelloRef" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2327 (class 2606 OID 431332)
-- Name: Import_CodiceOggettoRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceOggettoRef" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2328 (class 2606 OID 431337)
-- Name: Import_CodiceOggettoVersioneRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceOggettoVersioneRef" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2329 (class 2606 OID 431342)
-- Name: Import_UserRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_UserRef" FOREIGN KEY ("User") REFERENCES "Utenti"("User") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2363 (class 2606 OID 586496)
-- Name: MaterialeSubVersion_Verifica_Codice_SubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeSubVersion"
    ADD CONSTRAINT "MaterialeSubVersion_Verifica_Codice_SubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "OggettiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2359 (class 2606 OID 443963)
-- Name: MaterialeVersioni_Verifica_Codice_Versione; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeVersioni"
    ADD CONSTRAINT "MaterialeVersioni_Verifica_Codice_Versione" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2335 (class 2606 OID 431347)
-- Name: Modelli3D_3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2336 (class 2606 OID 431352)
-- Name: Modelli3D_3dm_Backup-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm_Backup"
    ADD CONSTRAINT "Modelli3D_3dm_Backup-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2365 (class 2606 OID 593004)
-- Name: Modelli3D_HotSpotColor-refModelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_HotSpotColor"
    ADD CONSTRAINT "Modelli3D_HotSpotColor-refModelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2330 (class 2606 OID 431357)
-- Name: Modelli3D_LoD-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2337 (class 2606 OID 431362)
-- Name: Modelli3D_OggettiJSON-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3D_OggettiJSON-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2364 (class 2606 OID 586781)
-- Name: Modelli3D_OggettiOBJ-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_OBJ"
    ADD CONSTRAINT "Modelli3D_OggettiOBJ-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2338 (class 2606 OID 431367)
-- Name: Modelli3D_Texture-refCodiceModello; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Texture-refCodiceModello" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2370 (class 2606 OID 704721)
-- Name: OggettiSubVersion_CategorieSchede_CategorieRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_CategorieRef" FOREIGN KEY ("Categoria") REFERENCES "Categorie"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2371 (class 2606 OID 704726)
-- Name: OggettiSubVersion_CategorieSchede_SchedeRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_SchedeRef" FOREIGN KEY ("Scheda") REFERENCES "OggettiSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2362 (class 2606 OID 586446)
-- Name: OggettiSubVersion_InfoComboBox-ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiSubVersion_InfoComboBox-ListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "OggettiSubVersion_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2341 (class 2606 OID 431372)
-- Name: OggettiSubVersion_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "OggettiSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2342 (class 2606 OID 431377)
-- Name: OggettiSubVersion_RelazioniSchede_refCodiceOggetto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_refCodiceOggetto" FOREIGN KEY ("CodiceSubVersion") REFERENCES "OggettiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2343 (class 2606 OID 431382)
-- Name: OggettiSubVersion_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "OggettiSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2346 (class 2606 OID 586460)
-- Name: OggettiSubVersion_Schede-InfoCombo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede-InfoCombo" FOREIGN KEY ("ComboValue") REFERENCES "OggettiSubVersion_InfoComboBox"("Codice");


--
-- TOC entry 2344 (class 2606 OID 431387)
-- Name: OggettiSubVersion_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "OggettiSubVersion_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2345 (class 2606 OID 431392)
-- Name: OggettiSubVersion_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "OggettiSubVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2368 (class 2606 OID 704703)
-- Name: OggettiVersion_CategorieSchede_CategorieRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_CategorieRef" FOREIGN KEY ("Categoria") REFERENCES "Categorie"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2369 (class 2606 OID 704708)
-- Name: OggettiVersion_CategorieSchede_SchedeRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_SchedeRef" FOREIGN KEY ("Scheda") REFERENCES "OggettiVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2361 (class 2606 OID 586413)
-- Name: OggettiVersion_InfoComboBox-ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiVersion_InfoComboBox-ListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "OggettiVersion_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2347 (class 2606 OID 431397)
-- Name: OggettiVersion_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "OggettiVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2348 (class 2606 OID 431402)
-- Name: OggettiVersion_RelazioniSchede_refCodiceOggetto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_refCodiceOggetto" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2349 (class 2606 OID 431407)
-- Name: OggettiVersion_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "OggettiVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2352 (class 2606 OID 586426)
-- Name: OggettiVersion_Schede-InfoCombo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede-InfoCombo" FOREIGN KEY ("ComboValue") REFERENCES "OggettiVersion_InfoComboBox"("Codice");


--
-- TOC entry 2350 (class 2606 OID 431412)
-- Name: OggettiVersion_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "OggettiVersion_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2351 (class 2606 OID 431417)
-- Name: OggettiVersion_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "OggettiVersion_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2331 (class 2606 OID 704731)
-- Name: Oggetti_CategorieRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti"
    ADD CONSTRAINT "Oggetti_CategorieRef" FOREIGN KEY ("Category") REFERENCES "Categorie"("Titolo") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2366 (class 2606 OID 704684)
-- Name: Oggetti_CategorieSchede_CategorieRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_CategorieRef" FOREIGN KEY ("Categoria") REFERENCES "Categorie"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2367 (class 2606 OID 704689)
-- Name: Oggetti_CategorieSchede_SchedeRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_SchedeRef" FOREIGN KEY ("Scheda") REFERENCES "Oggetti_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2360 (class 2606 OID 586388)
-- Name: Oggetti_InfoComboBox-ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_InfoComboBox"
    ADD CONSTRAINT "Oggetti_InfoComboBox-ListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "Oggetti_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2353 (class 2606 OID 431422)
-- Name: Oggetti_ListaInformazioni_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_refTitolo" FOREIGN KEY ("Titolo") REFERENCES "Oggetti_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2354 (class 2606 OID 431427)
-- Name: Oggetti_RelazioniSchede_refCodiceOggetto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_refCodiceOggetto" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2355 (class 2606 OID 431432)
-- Name: Oggetti_RelazioniSchede_refTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_refTitolo" FOREIGN KEY ("TitoloScheda") REFERENCES "Oggetti_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2358 (class 2606 OID 586393)
-- Name: Oggetti_Schede-InfoCombo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede-InfoCombo" FOREIGN KEY ("ComboValue") REFERENCES "Oggetti_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2356 (class 2606 OID 431437)
-- Name: Oggetti_Schede_refListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_refListaInformazioni" FOREIGN KEY ("TitoloScheda", "NomeCampo") REFERENCES "Oggetti_ListaInformazioni"("Titolo", "Campo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2357 (class 2606 OID 431442)
-- Name: Oggetti_Schede_refTitoli; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_refTitoli" FOREIGN KEY ("TitoloScheda") REFERENCES "Oggetti_ListaSchede"("Titolo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2339 (class 2606 OID 431447)
-- Name: Oggetti_SubVersion-keu-Oggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-keu-Oggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2340 (class 2606 OID 431452)
-- Name: Oggetti_SubVersion-key-Oggetti_Versioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-key-Oggetti_Versioni" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2332 (class 2606 OID 431457)
-- Name: Oggetti_Versioni-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 2333 (class 2606 OID 431462)
-- Name: Oggetti_Versioni-key-Oggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key-Oggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2334 (class 2606 OID 431467)
-- Name: Verifica_Codice_oggetto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeOggetti"
    ADD CONSTRAINT "Verifica_Codice_oggetto" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2489 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA "public" FROM PUBLIC;
REVOKE ALL ON SCHEMA "public" FROM "postgres";
GRANT ALL ON SCHEMA "public" TO "postgres";
GRANT ALL ON SCHEMA "public" TO PUBLIC;


-- Completed on 2017-09-05 11:23:12

--
-- PostgreSQL database dump complete
--

