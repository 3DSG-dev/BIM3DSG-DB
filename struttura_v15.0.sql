--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 9.6.10

-- Started on 2019-01-28 14:13:01 CET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2790 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- TOC entry 1 (class 3079 OID 12393)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "plpgsql" WITH SCHEMA "pg_catalog";


--
-- TOC entry 2791 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


--
-- TOC entry 260 (class 1255 OID 21842)
-- Name: addimportnome("text", "text", "text", "text", "text", boolean, boolean, "text", boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."addimportnome"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "name" "text", "match" boolean, "rw" boolean, "username" "text", "removed" boolean) RETURNS "text"
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
-- TOC entry 261 (class 1255 OID 21844)
-- Name: addinterventosubversion("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."addinterventosubversion"("codicepadriversion" "text", "utente" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
    codicePadriSubVersion bigint[];
    codicePadriVersionInt bigint;
    codicePadriVersionAux text[];
    codiceFiglioSubVersion bigint;
    codiceIntervento bigint;
    cantiereAttuale int;

    selSubVersion RECORD;

    auxInt int;
    auxData date;
  BEGIN
    IF (codicePadriVersion IS NOT NULL AND codicePadriVersion != '')   
    THEN
	codicePadriVersionAux :=  regexp_split_to_array(codicePadriVersion,',');
        FOR i IN array_lower(codicePadriVersionAux, 1) .. array_upper(codicePadriVersionAux, 1)
        LOOP
	    IF (codicePadriVersionAux[i] IS NOT NULL AND codicePadriVersionAux[i] != '')
	    THEN
		codicePadriVersionInt := CAST (codicePadriVersionAux[i] as bigint);
		codicePadriSubVersion[i] := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codicePadriVersionInt AND "SubVersion" = (SELECT MAX("SubVersion") FROM "OggettiSubVersion" WHERE "CodiceVersione" = codicePadriVersionInt));
	    ELSE
		RAISE EXCEPTION 'Codicipadri can''t be null or blank!';
	    END IF;
        END LOOP;

             
	IF ((codicePadriSubVersion IS NULL) OR (array_length(codicePadriSubVersion,1) = 0))
	THEN
	RAISE EXCEPTION 'Occorre inserire almeno un padre per creare un nuovo intervento!';	
	END IF;

	FOR i IN array_lower(codicePadriSubVersion, 1) .. array_upper(codicePadriSubVersion, 1)
	LOOP
		IF (codicePadriSubVersion[i] IS NULL)
		THEN
			RAISE EXCEPTION 'Padre non corretto!';	
		END IF;
		auxInt := (SELECT COUNT(*) FROM "InterventiSubVersion_Relazioni" WHERE "Padre" = codicePadriSubVersion[i]);
		IF (auxInt > 0)
		THEN
		    RAISE EXCEPTION 'Impossibile aggiungere l''intervento: la subversion selezionata (ID=%) ha già un intervento (ID=%) a suo carico\n\n Se occorre inserire un nuovo intervento in quell''area occorre inserirlo sui pezzi generati da quell''intervento',codicePadriVersion[i], auxInt; 
		END IF;    
		auxInt := (SELECT COUNT(*) FROM "OggettiSubVersion" WHERE "Codice" = codicePadriSubVersion[i] AND "Lock" = utente);
		IF (auxInt != 1)
		THEN
		    RAISE EXCEPTION 'Impossibile aggiungere l''intervento: il pezzo selezionato (ID=%) non è stato importato in scrittura',codicePadriSubVersion[i]; 
		END IF;
	END LOOP;

	auxData = now();
	        
	INSERT INTO "InterventiSubVersion" ("Data", "CreatedBy") VALUES (auxData, utente) RETURNING "Codice" INTO codiceIntervento;

	FOR i IN array_lower(codicePadriSubVersion, 1) .. array_upper(codicePadriSubVersion, 1)
	LOOP
		SELECT * INTO selSubVersion FROM "OggettiSubVersion" WHERE "Codice" = codicePadriSubVersion[i];

		cantiereAttuale := (SELECT MAX("Numero") FROM "Cantieri" WHERE "Layer0" = (SELECT "Layer0" FROM "Oggetti" WHERE "Codice" = selSubVersion."CodiceOggetto"));

		INSERT INTO "OggettiSubVersion"("CodiceOggetto", "CodiceVersione", "SubVersion", "Originale", "DataCreazione", "CantiereCreazione", "Lock", "LastUpdate", "LastUpdateBy") VALUES (selSubVersion."CodiceOggetto", selSubVersion."CodiceVersione", selSubVersion."SubVersion" + 1, selSubVersion."Codice", auxData, cantiereAttuale, utente, auxData, utente) RETURNING "Codice" INTO codiceFiglioSubVersion;

		UPDATE "OggettiSubVersion" SET "DataEliminazione" = auxData, "CantiereEliminazione" = cantiereAttuale, "LastUpdate" = auxData, "LastUpdateBy" = utente WHERE "Codice" = codicePadriSubVersion[i];

		INSERT INTO "InterventiSubVersion_Relazioni"("Intervento", "Padre", "Figlio") VALUES (codiceIntervento, codicePadriSubVersion[i], codiceFiglioSubVersion);
	END LOOP;
   ELSE
	RAISE EXCEPTION 'Codicipadri can''t be null or blank!';
    END IF;

    RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."addinterventosubversion"("codicepadriversion" "text", "utente" "text") OWNER TO "postgres";

--
-- TOC entry 274 (class 1255 OID 21845)
-- Name: checkallmodelled(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."checkallmodelled"("codiceoggetto" bigint) RETURNS "text"
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
-- TOC entry 275 (class 1255 OID 21846)
-- Name: deleteimportlist("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."deleteimportlist"("username" "text") RETURNS "text"
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
-- TOC entry 276 (class 1255 OID 21847)
-- Name: deleteimportobject(bigint, bigint, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."deleteimportobject"("codiceoggetto" bigint, "codiceversione" bigint, "username" "text") RETURNS "text"
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
-- TOC entry 277 (class 1255 OID 21848)
-- Name: deleteobject(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."deleteobject"("codiceoggetto" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE

  BEGIN
	DELETE FROM "Modelli3D" WHERE "Codice" IN (SELECT "CodiceModello" FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceoggetto);

	CREATE TEMP TABLE versioni AS (SELECT "Codice" FROM "OggettiVersion" WHERE "CodiceOggetto" = codiceoggetto);

	CREATE TEMP TABLE schedeversion AS (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" IN (SELECT * FROM versioni) AND "CodiceScheda" NOT IN (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" NOT IN (SELECT * FROM versioni)));
	DELETE FROM "OggettiVersion_Schede" WHERE "CodiceScheda" IN (SELECT * FROM schedeversion);
	DELETE FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceScheda" IN (SELECT * FROM schedeversion);

	CREATE TEMP TABLE subversion AS (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceOggetto" = codiceoggetto);

	CREATE TEMP TABLE schedesubversion AS (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" IN (SELECT * FROM subversion) AND "CodiceScheda" NOT IN (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" NOT IN (SELECT * FROM subversion)));
	DELETE FROM "OggettiSubVersion_Schede" WHERE "CodiceScheda" IN (SELECT * FROM schedesubversion);
	DELETE FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceScheda" IN (SELECT * FROM schedesubversion);

	CREATE TEMP TABLE schedeoggetto AS (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = 2 AND "CodiceScheda" NOT IN (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" != 2));
	DELETE FROM "Oggetti_Schede" WHERE "CodiceScheda" IN (SELECT * FROM schedeoggetto);
	DELETE FROM "Oggetti_RelazioniSchede" WHERE "CodiceScheda" IN (SELECT * FROM schedeoggetto);
	
	DELETE FROM "Oggetti" WHERE "Codice" = codiceoggetto;
  
    RETURN 'success';
END;
$$;


ALTER FUNCTION "public"."deleteobject"("codiceoggetto" bigint) OWNER TO "postgres";

--
-- TOC entry 278 (class 1255 OID 21849)
-- Name: deleteoggettiinfo(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."deleteoggettiinfo"("codicescheda" bigint, "codicecampo" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "Oggetti_Schede" WHERE "CodiceScheda" = codiceScheda AND "CodiceCampo" = codiceCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deleteoggettiinfo"("codicescheda" bigint, "codicecampo" integer) OWNER TO "postgres";

--
-- TOC entry 279 (class 1255 OID 21850)
-- Name: deleteoggettisubversioninfo(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."deleteoggettisubversioninfo"("codicescheda" bigint, "codicecampo" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "OggettiSubVersion_Schede" WHERE "CodiceScheda" = codiceScheda AND "CodiceCampo" = codiceCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deleteoggettisubversioninfo"("codicescheda" bigint, "codicecampo" integer) OWNER TO "postgres";

--
-- TOC entry 280 (class 1255 OID 21851)
-- Name: deleteoggettiversioninfo(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."deleteoggettiversioninfo"("codicescheda" bigint, "codicecampo" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
  BEGIN
	DELETE FROM "OggettiVersion_Schede" WHERE "CodiceScheda" = codiceScheda AND "CodiceCampo" = codiceCampo;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."deleteoggettiversioninfo"("codicescheda" bigint, "codicecampo" integer) OWNER TO "postgres";

--
-- TOC entry 281 (class 1255 OID 21852)
-- Name: preinitializemodifiedobject("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializemodifiedobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
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
-- TOC entry 282 (class 1255 OID 21853)
-- Name: preinitializemodifiedobject("text", "text", "text", "text", "text", integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializemodifiedobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") RETURNS "text"
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
-- TOC entry 283 (class 1255 OID 21854)
-- Name: preinitializemodifiedobjectonlyrhino("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializemodifiedobjectonlyrhino"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
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
-- TOC entry 284 (class 1255 OID 21855)
-- Name: preinitializemodifiedobjectonlyweb("text", "text", "text", "text", "text", integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializemodifiedobjectonlyweb"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "username" "text") RETURNS "text"
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
-- TOC entry 285 (class 1255 OID 21856)
-- Name: preinitializemodifiedobjectonlyweb("text", "text", "text", "text", "text", integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializemodifiedobjectonlyweb"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") RETURNS "text"
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
-- TOC entry 286 (class 1255 OID 21857)
-- Name: preinitializenewhotspot("text", "text", "text", "text", "text", integer, double precision, double precision, double precision, double precision, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializenewhotspot"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "category" integer, "username" "text") RETURNS "text"
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
	INSERT INTO "Oggetti"("Layer0", "Layer1", "Layer2", "Layer3", "Name", "Categoria", "DataCreazione", "DataEliminazione", "CantiereCreazione", "CantiereEliminazione", 
			"Lock", "LastUpdate", "LastUpdateBy")
		VALUES (layer0, layer1, layer2, layer3, nome, category, now(), null, 0, null,
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

	INSERT INTO "Modelli3D_HotSpotColor"("CodiceModello")
		VALUES (codiceModello);

	INSERT INTO "Import" ("User", "CodiceOggetto", "CodiceVersione", "CodiceModello", "Colore", "readonly") VALUES (username, codiceOggetto, codiceVersione, codiceModello, 301, false);

    	RETURN 'success';
  END;
$$;


ALTER FUNCTION "public"."preinitializenewhotspot"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "category" integer, "username" "text") OWNER TO "postgres";

--
-- TOC entry 287 (class 1255 OID 21858)
-- Name: preinitializenewhotspot("text", "text", "text", "text", "text", integer, double precision, double precision, double precision, double precision, real, real, real, real, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializenewhotspot"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "colorr" real, "colorg" real, "colorb" real, "colora" real, "username" "text") RETURNS "text"
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
-- TOC entry 288 (class 1255 OID 21859)
-- Name: preinitializenewobject("text", "text", "text", "text", "text", integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."preinitializenewobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "tipomodello" integer, "username" "text") RETURNS "text"
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
-- TOC entry 289 (class 1255 OID 21860)
-- Name: setoggettiinfocombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "ComboValue") VALUES (' || codiceScheda || ', ''' || codiceCampo || ''', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = ' || valore || ' WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codicecampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 290 (class 1255 OID 21861)
-- Name: setoggettiinfomulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "MultiComboValue") VALUES (' || codiceScheda || ', ''' || codiceCampo || ''', ''' || valore  || ''')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = ''' || valore || ''' WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codicecampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 291 (class 1255 OID 21862)
-- Name: setoggettiinfoschedacombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedacombovalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfocombovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedacombovalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 292 (class 1255 OID 21863)
-- Name: setoggettiinfoschedamulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedamulticombovalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfomulticombovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedamulticombovalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 293 (class 1255 OID 21864)
-- Name: setoggettiinfoschedavalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 294 (class 1255 OID 21865)
-- Name: setoggettiinfoschedavalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" real) OWNER TO "postgres";

--
-- TOC entry 295 (class 1255 OID 21866)
-- Name: setoggettiinfoschedavalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" integer) OWNER TO "postgres";

--
-- TOC entry 296 (class 1255 OID 21867)
-- Name: setoggettiinfoschedavalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 297 (class 1255 OID 21868)
-- Name: setoggettiinfoschedavalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "Oggetti_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "Oggetti_RelazioniSchede" WHERE "CodiceOggetto" = codiceoggetto AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "Oggetti_RelazioniSchede"("CodiceOggetto", "CodiceTitolo") VALUES (codiceoggetto, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 298 (class 1255 OID 21869)
-- Name: setoggettiinfovalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "BoolValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 299 (class 1255 OID 21870)
-- Name: setoggettiinfovalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "RealValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) OWNER TO "postgres";

--
-- TOC entry 300 (class 1255 OID 21871)
-- Name: setoggettiinfovalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "IntValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) OWNER TO "postgres";

--
-- TOC entry 301 (class 1255 OID 21872)
-- Name: setoggettiinfovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "TextValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 302 (class 1255 OID 21873)
-- Name: setoggettiinfovalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "Oggetti_Schede" ("CodiceScheda", "CodiceCampo", "TimestampValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "Oggetti_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''', "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 303 (class 1255 OID 21874)
-- Name: setoggettisubversioninfocombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "ComboValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = ' || valore || ' WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;

$$;


ALTER FUNCTION "public"."setoggettisubversioninfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 304 (class 1255 OID 21875)
-- Name: setoggettisubversioninfomulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "MultiComboValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = ''' || valore || ''' WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;

$$;


ALTER FUNCTION "public"."setoggettisubversioninfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 305 (class 1255 OID 21876)
-- Name: setoggettisubversioninfoschedacombovalue(bigint, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedacombovalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfocombovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedacombovalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 306 (class 1255 OID 21877)
-- Name: setoggettisubversioninfoschedamulticombovalue(bigint, integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedamulticombovalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfomulticombovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedamulticombovalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 307 (class 1255 OID 21878)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 308 (class 1255 OID 21879)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" real) OWNER TO "postgres";

--
-- TOC entry 309 (class 1255 OID 21880)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" integer) OWNER TO "postgres";

--
-- TOC entry 310 (class 1255 OID 21881)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 311 (class 1255 OID 21882)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codicesubversion bigint;
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codicesubversion := (SELECT "Codice" FROM "OggettiSubVersion" WHERE "CodiceVersione" = codiceversione AND "SubVersion" = subversion);
	
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiSubVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiSubVersion_RelazioniSchede" WHERE "CodiceSubVersion" = codiceSubVersion AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiSubVersion_RelazioniSchede"("CodiceSubVersion", "CodiceTitolo") VALUES (codiceSubVersion, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiSubVersioninfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 312 (class 1255 OID 21883)
-- Name: setoggettisubversioninfovalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "BoolValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 313 (class 1255 OID 21884)
-- Name: setoggettisubversioninfovalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "RealValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) OWNER TO "postgres";

--
-- TOC entry 314 (class 1255 OID 21885)
-- Name: setoggettisubversioninfovalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "IntValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) OWNER TO "postgres";

--
-- TOC entry 315 (class 1255 OID 21886)
-- Name: setoggettisubversioninfovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL AND valore != '' AND trim(from valore) != '') THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "TextValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 316 (class 1255 OID 21887)
-- Name: setoggettisubversioninfovalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiSubVersion_Schede" ("CodiceScheda", "CodiceCampo", "TimestampValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiSubVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''', "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiSubVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 317 (class 1255 OID 21888)
-- Name: setoggettiversioniinfocombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "ComboValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = ' || valore || ' WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;

$$;


ALTER FUNCTION "public"."setoggettiversioniinfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 318 (class 1255 OID 21889)
-- Name: setoggettiversioniinfomulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "MultiComboValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = ''' || valore || ''' WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;

$$;


ALTER FUNCTION "public"."setoggettiversioniinfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 319 (class 1255 OID 21890)
-- Name: setoggettiversioniinfoschedacombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedacombovalue"("codiceversione" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfocombovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedacombovalue"("codiceversione" bigint, "codicecampo" integer, "valore" bigint) OWNER TO "postgres";

--
-- TOC entry 320 (class 1255 OID 21891)
-- Name: setoggettiversioniinfoschedamulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedamulticombovalue"("codiceversione" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfomulticombovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedamulticombovalue"("codiceversione" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 321 (class 1255 OID 21892)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 322 (class 1255 OID 21893)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" real) OWNER TO "postgres";

--
-- TOC entry 323 (class 1255 OID 21894)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" integer) OWNER TO "postgres";

--
-- TOC entry 324 (class 1255 OID 21895)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 325 (class 1255 OID 21896)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	codiceScheda bigint;
	codiceTitolo integer;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	codiceTitolo := (SELECT "CodiceTitolo" FROM "OggettiVersion_ListaInformazioni" WHERE "Codice" = codicecampo);
	IF (codiceTitolo is NULL) THEN
		RAISE EXCEPTION 'Can''t find (%) information group', codicecampo;
	END IF;

	codiceScheda := (SELECT "CodiceScheda" FROM "OggettiVersion_RelazioniSchede" WHERE "CodiceVersione" = codiceversione AND "CodiceTitolo" = codiceTitolo);

	IF (codiceScheda is NULL) THEN
		INSERT INTO "OggettiVersion_RelazioniSchede"("CodiceVersione", "CodiceTitolo") VALUES (codiceversione, codiceTitolo) RETURNING "CodiceScheda" INTO codiceScheda;
	END IF;

	select setoggettiversioniinfovalue(codiceScheda, codicecampo, valore) INTO tmpRecord;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 326 (class 1255 OID 21897)
-- Name: setoggettiversioniinfovalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "BoolValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = ' || valore || ', "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) OWNER TO "postgres";

--
-- TOC entry 327 (class 1255 OID 21898)
-- Name: setoggettiversioniinfovalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "RealValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = ' || valore || ', "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) OWNER TO "postgres";

--
-- TOC entry 328 (class 1255 OID 21899)
-- Name: setoggettiversioniinfovalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "IntValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ' || valore  || ')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = ' || valore || ', "RealValue" = null, "TextValue" = null, "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) OWNER TO "postgres";

--
-- TOC entry 329 (class 1255 OID 21900)
-- Name: setoggettiversioniinfovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL AND valore != '' AND trim(from valore) != '') THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "TextValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = ''' || valore || ''', "TimestampValue" = null, "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") OWNER TO "postgres";

--
-- TOC entry 330 (class 1255 OID 21901)
-- Name: setoggettiversioniinfovalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
  DECLARE
	sql_insert text;
	sql_update text;

	tmpRecord RECORD;
		
	auxint int;
  BEGIN
	IF (valore IS NOT NULL) THEN
		sql_insert := 'INSERT INTO "OggettiVersion_Schede" ("CodiceScheda", "CodiceCampo", "TimestampValue") VALUES (' || codiceScheda || ', ' || codiceCampo || ', ''' || valore  || ''')';
		sql_update := 'UPDATE "OggettiVersion_Schede" SET "BoolValue" = null, "IntValue" = null, "RealValue" = null, "TextValue" = null, "TimestampValue" = ''' || valore || ''', "ComboValue" = null, "MultiComboValue" = null WHERE "CodiceScheda" = ' || codiceScheda || ' AND "CodiceCampo" = ' || codiceCampo;

		select upsert(sql_insert, sql_update) INTO tmpRecord;
	ELSE
		select deleteOggettiVersionInfo(codiceScheda, codiceCampo) INTO tmpRecord;
	END IF;

	RETURN 'success';
 END;
$$;


ALTER FUNCTION "public"."setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) OWNER TO "postgres";

--
-- TOC entry 331 (class 1255 OID 21902)
-- Name: updateobject("text", "text", "text", "text", "text", integer, integer, double precision, double precision, double precision, double precision, double precision, double precision, integer, boolean, boolean, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."updateobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "username" "text") RETURNS "text"
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
-- TOC entry 332 (class 1255 OID 21903)
-- Name: updateobject("text", "text", "text", "text", "text", integer, integer, double precision, double precision, double precision, double precision, double precision, double precision, integer, boolean, boolean, boolean, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."updateobject"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "volume" double precision, "superficie" double precision, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "parti" integer, "texture_3dm" boolean, "json_texture" boolean, "exportjson" boolean, "username" "text") RETURNS "text"
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
-- TOC entry 333 (class 1255 OID 21904)
-- Name: upload3dmfile("text", "text", "text", "text", "text", integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."upload3dmfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "file3dm" "bytea", "username" "text") RETURNS "text"
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
-- TOC entry 334 (class 1255 OID 21905)
-- Name: uploadjsonfile("text", "text", "text", "text", "text", integer, integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."uploadjsonfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "filejson" "bytea", "username" "text") RETURNS "text"
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
-- TOC entry 335 (class 1255 OID 21906)
-- Name: uploadobjfile("text", "text", "text", "text", "text", integer, integer, integer, "bytea", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."uploadobjfile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "lod" integer, "parte" integer, "fileobj" "bytea", "username" "text") RETURNS "text"
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
-- TOC entry 336 (class 1255 OID 21907)
-- Name: uploadtexturefile("text", "text", "text", "text", "text", integer, integer, integer, "text", "bytea", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."uploadtexturefile"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "textureindex" integer, "qualità" integer, "filename" "text", "filetexture" "bytea", "mimetype" "text", "username" "text") RETURNS "text"
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
-- TOC entry 337 (class 1255 OID 21908)
-- Name: upsert("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."upsert"("sql_insert" "text", "sql_update" "text") RETURNS "void"
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
-- TOC entry 185 (class 1259 OID 21909)
-- Name: Cantieri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Cantieri" (
    "Layer0" character varying(255) NOT NULL,
    "Numero" integer NOT NULL,
    "DataInizio" "date",
    "DataFine" "date",
    "Note" "text"
);


ALTER TABLE "public"."Cantieri" OWNER TO "postgres";

--
-- TOC entry 2792 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE "Cantieri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Cantieri" IS 'Tabella contenente l''elenco dei cantieri';


--
-- TOC entry 2793 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Cantieri"."Layer0"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Cantieri"."Layer0" IS 'Layer0 del cantiere';


--
-- TOC entry 2794 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Cantieri"."Numero"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Cantieri"."Numero" IS 'Numero progressivo del cantiere (0 iniziale)';


--
-- TOC entry 2795 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Cantieri"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Cantieri"."DataInizio" IS 'Data apertura del cantiere';


--
-- TOC entry 2796 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Cantieri"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Cantieri"."DataFine" IS 'Data chiusura del cantiere';


--
-- TOC entry 2797 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN "Cantieri"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Cantieri"."Note" IS 'Campo note sul cantiere';


--
-- TOC entry 186 (class 1259 OID 21915)
-- Name: Categorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Categorie" (
    "Codice" integer NOT NULL,
    "Nome" character varying(255) NOT NULL,
    "ColorR" real DEFAULT 1 NOT NULL,
    "ColorG" real DEFAULT 0 NOT NULL,
    "ColorB" real DEFAULT 0 NOT NULL,
    "ColorA" real DEFAULT 0.6 NOT NULL,
    "CodiceGruppo" integer NOT NULL
);


ALTER TABLE "public"."Categorie" OWNER TO "postgres";

--
-- TOC entry 2798 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE "Categorie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Categorie" IS 'Lista delle categorie';


--
-- TOC entry 2799 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Categorie"."Nome"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Categorie"."Nome" IS 'Titolo delle categorie';


--
-- TOC entry 2800 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Categorie"."ColorR"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Categorie"."ColorR" IS 'Colore red';


--
-- TOC entry 2801 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Categorie"."ColorG"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Categorie"."ColorG" IS 'Colore green';


--
-- TOC entry 2802 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Categorie"."ColorB"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Categorie"."ColorB" IS 'Colore blue';


--
-- TOC entry 2803 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Categorie"."ColorA"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Categorie"."ColorA" IS 'Canale Alpha del colore';


--
-- TOC entry 2804 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "Categorie"."CodiceGruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Categorie"."CodiceGruppo" IS 'Codice del gruppo della categoria';


--
-- TOC entry 187 (class 1259 OID 21922)
-- Name: Categorie_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Categorie_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Categorie_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2805 (class 0 OID 0)
-- Dependencies: 187
-- Name: Categorie_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Categorie_Codice_seq" OWNED BY "public"."Categorie"."Codice";


--
-- TOC entry 188 (class 1259 OID 21924)
-- Name: FileExtra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."FileExtra" (
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


ALTER TABLE "public"."FileExtra" OWNER TO "postgres";

--
-- TOC entry 2806 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE "FileExtra"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."FileExtra" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2807 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2808 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2809 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2810 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2811 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2812 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2813 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2814 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2815 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2816 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2817 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2818 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2819 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2820 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2821 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "FileExtra"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."FileExtra"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 189 (class 1259 OID 21935)
-- Name: GruppiCategorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."GruppiCategorie" (
    "Codice" integer NOT NULL,
    "Nome" character varying(255) NOT NULL
);


ALTER TABLE "public"."GruppiCategorie" OWNER TO "postgres";

--
-- TOC entry 2822 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE "GruppiCategorie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."GruppiCategorie" IS 'Gruppi delle categorie';


--
-- TOC entry 2823 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "GruppiCategorie"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."GruppiCategorie"."Codice" IS 'Codice del gruppo';


--
-- TOC entry 2824 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN "GruppiCategorie"."Nome"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."GruppiCategorie"."Nome" IS 'Nome';


--
-- TOC entry 190 (class 1259 OID 21938)
-- Name: GruppiCategorie_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."GruppiCategorie_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."GruppiCategorie_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 190
-- Name: GruppiCategorie_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."GruppiCategorie_Codice_seq" OWNED BY "public"."GruppiCategorie"."Codice";


--
-- TOC entry 191 (class 1259 OID 21940)
-- Name: Import; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Import" (
    "User" character varying(255) NOT NULL,
    "CodiceOggetto" bigint NOT NULL,
    "CodiceVersione" bigint NOT NULL,
    "CodiceModello" bigint,
    "Colore" integer,
    "readonly" boolean,
    "NewAdded" boolean DEFAULT true
);


ALTER TABLE "public"."Import" OWNER TO "postgres";

--
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE "Import"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Import" IS 'Tabella contenente le liste di importazione degli utenti';


--
-- TOC entry 2827 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."User" IS 'Nome dell''utente';


--
-- TOC entry 2828 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."CodiceOggetto" IS 'Codice dell''oggetto da importare';


--
-- TOC entry 2829 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."CodiceVersione" IS 'Codice dell''oggetto+versione da importare';


--
-- TOC entry 2830 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."CodiceModello" IS 'Codice del modello da importare';


--
-- TOC entry 2831 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."Colore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."Colore" IS 'Codice del colore da associare all''oggetto da importare';


--
-- TOC entry 2832 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."readonly"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."readonly" IS 'Identifica se importato in sola lettura (o modifica)';


--
-- TOC entry 2833 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN "Import"."NewAdded"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Import"."NewAdded" IS 'Indica se è stato aggiunto alla lista di importazione e mai importato';


--
-- TOC entry 192 (class 1259 OID 21944)
-- Name: InterventiSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion" (
    "Codice" bigint NOT NULL,
    "Data" timestamp with time zone NOT NULL,
    "CreatedBy" character varying(255)
);


ALTER TABLE "public"."InterventiSubVersion" OWNER TO "postgres";

--
-- TOC entry 2834 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "InterventiSubVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion"."Codice" IS 'Codice dell''intervento';


--
-- TOC entry 2835 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "InterventiSubVersion"."Data"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion"."Data" IS 'Data dell''intervento';


--
-- TOC entry 2836 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN "InterventiSubVersion"."CreatedBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion"."CreatedBy" IS 'Utente che ha creato l''intervento';


--
-- TOC entry 193 (class 1259 OID 21947)
-- Name: InterventiSubVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "public"."InterventiSubVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2837 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "InterventiSubVersion_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 194 (class 1259 OID 21950)
-- Name: InterventiSubVersion_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."InterventiSubVersion_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."InterventiSubVersion_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2838 (class 0 OID 0)
-- Dependencies: 194
-- Name: InterventiSubVersion_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."InterventiSubVersion_Codice_seq" OWNED BY "public"."InterventiSubVersion"."Codice";


--
-- TOC entry 195 (class 1259 OID 21952)
-- Name: InterventiSubVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "public"."InterventiSubVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2839 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE "InterventiSubVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."InterventiSubVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2840 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "InterventiSubVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2841 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "InterventiSubVersion_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 2842 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "InterventiSubVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 196 (class 1259 OID 21955)
-- Name: InterventiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."InterventiSubVersion_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."InterventiSubVersion_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2843 (class 0 OID 0)
-- Dependencies: 196
-- Name: InterventiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."InterventiSubVersion_InfoComboBox_Codice_seq" OWNED BY "public"."InterventiSubVersion_InfoComboBox"."Codice";


--
-- TOC entry 197 (class 1259 OID 21957)
-- Name: InterventiSubVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_ListaInformazioni" (
    "Codice" integer NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL,
    "IsMultiCombo" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer DEFAULT 0 NOT NULL,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "public"."InterventiSubVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2844 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE "InterventiSubVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."InterventiSubVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli InterventiSubVersion e dei relativi campi';


--
-- TOC entry 2845 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 2846 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2847 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2848 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2849 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 2850 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2851 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2852 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2853 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2854 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2855 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 2857 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2858 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2859 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 198 (class 1259 OID 21972)
-- Name: InterventiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."InterventiSubVersion_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."InterventiSubVersion_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2860 (class 0 OID 0)
-- Dependencies: 198
-- Name: InterventiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."InterventiSubVersion_ListaInformazioni_Codice_seq" OWNED BY "public"."InterventiSubVersion_ListaInformazioni"."Codice";


--
-- TOC entry 199 (class 1259 OID 21974)
-- Name: InterventiSubVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "public"."InterventiSubVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2861 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE "InterventiSubVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."InterventiSubVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2862 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "InterventiSubVersion_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 2863 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "InterventiSubVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 2864 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "InterventiSubVersion_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 200 (class 1259 OID 21977)
-- Name: InterventiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."InterventiSubVersion_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."InterventiSubVersion_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2865 (class 0 OID 0)
-- Dependencies: 200
-- Name: InterventiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."InterventiSubVersion_ListaSchede_Codice_seq" OWNED BY "public"."InterventiSubVersion_ListaSchede"."Codice";


--
-- TOC entry 201 (class 1259 OID 21979)
-- Name: InterventiSubVersion_Relazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_Relazioni" (
    "Intervento" bigint NOT NULL,
    "Padre" bigint NOT NULL,
    "Figlio" bigint
);


ALTER TABLE "public"."InterventiSubVersion_Relazioni" OWNER TO "postgres";

--
-- TOC entry 2866 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE "InterventiSubVersion_Relazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."InterventiSubVersion_Relazioni" IS 'Tabella delle relazioni degli interventi sulle SubVersion';


--
-- TOC entry 2867 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "InterventiSubVersion_Relazioni"."Intervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Relazioni"."Intervento" IS 'Codice dell''intervento';


--
-- TOC entry 2868 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "InterventiSubVersion_Relazioni"."Padre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Relazioni"."Padre" IS 'Codice della SubVersion padre';


--
-- TOC entry 2869 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "InterventiSubVersion_Relazioni"."Figlio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Relazioni"."Figlio" IS 'Codice della SubVersion figlio';


--
-- TOC entry 202 (class 1259 OID 21982)
-- Name: InterventiSubVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_RelazioniSchede" (
    "CodiceSubVersion" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "public"."InterventiSubVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2870 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE "InterventiSubVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."InterventiSubVersion_RelazioniSchede" IS 'Relazioni tra gli InterventiSubVersion e le schede informative';


--
-- TOC entry 2871 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_RelazioniSchede"."CodiceSubVersion" IS 'Codice dell''oggetto';


--
-- TOC entry 2872 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2873 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 203 (class 1259 OID 21985)
-- Name: InterventiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."InterventiSubVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."InterventiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2874 (class 0 OID 0)
-- Dependencies: 203
-- Name: InterventiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."InterventiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "public"."InterventiSubVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 204 (class 1259 OID 21987)
-- Name: InterventiSubVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."InterventiSubVersion_Schede" (
    "CodiceScheda" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint,
    "MultiComboValue" character varying(255)
);


ALTER TABLE "public"."InterventiSubVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 2875 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE "InterventiSubVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."InterventiSubVersion_Schede" IS 'Informazioni testuali sugli InterventiSubVersion';


--
-- TOC entry 2876 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 2877 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 2878 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2879 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2880 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2881 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 2882 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 2883 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 2884 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN "InterventiSubVersion_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."InterventiSubVersion_Schede"."MultiComboValue" IS 'Valore del multi combobox';


--
-- TOC entry 205 (class 1259 OID 21993)
-- Name: Modelli3D; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D" (
    "Codice" bigint NOT NULL,
    "Type" integer DEFAULT 0 NOT NULL,
    "Superficie" double precision,
    "Volume" double precision,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D" OWNER TO "postgres";

--
-- TOC entry 2885 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "Modelli3D"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D" IS 'Tabella di riferimento per i Modelli 3D';


--
-- TOC entry 2886 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Modelli3D"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D"."Codice" IS 'Codice del Modello 3D (diverso dal codice dell''oggetto!!!) - PRIMARY KEY';


--
-- TOC entry 2887 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Modelli3D"."Type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D"."Type" IS '0 -> Mesh
1 -> Point Cloud
2 -> HotSpot';


--
-- TOC entry 2888 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Modelli3D"."Superficie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D"."Superficie" IS 'Superficie dell''oggetto (calcolata dal modello 3D)';


--
-- TOC entry 2889 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Modelli3D"."Volume"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D"."Volume" IS 'Volume dell''oggetto (calcolato dal modello 3D)';


--
-- TOC entry 2890 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Modelli3D"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2891 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "Modelli3D"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 206 (class 1259 OID 21998)
-- Name: Modelli3D_LoD; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_LoD" (
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


ALTER TABLE "public"."Modelli3D_LoD" OWNER TO "postgres";

--
-- TOC entry 2892 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE "Modelli3D_LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_LoD" IS 'Tabella di riferimento per i livelli di dettaglio dei Modelli 3D';


--
-- TOC entry 2893 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."CodiceModello" IS 'Riferimento al codice del Modello 3D';


--
-- TOC entry 2894 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."LoD" IS 'Level of Detail del modello 3D';


--
-- TOC entry 2895 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."xc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."xc" IS 'Coordinata x del centro';


--
-- TOC entry 2896 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."yc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."yc" IS 'Coordinata y del centro';


--
-- TOC entry 2897 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."zc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."zc" IS 'Coordinata z del centro';


--
-- TOC entry 2898 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."Radius"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."Radius" IS 'Raggio del bounding box sferico';


--
-- TOC entry 2899 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."Texture" IS 'Specifica se è stata inserita una texture';


--
-- TOC entry 2900 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."3dm" IS 'Indica se è stato inserito nel database il file 3dm corrispondente';


--
-- TOC entry 2901 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."3dm_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."3dm_Texture" IS 'Specifica se il modello 3dm contiene le informazioni per la texture';


--
-- TOC entry 2902 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."3dm_Backup"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."3dm_Backup" IS 'Indica se è presente nel database un backup per il file 3dm corrispondente';


--
-- TOC entry 2903 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."JSON" IS 'Indica se è stato inserito nel database il file JSON corrispondente';


--
-- TOC entry 2904 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."JSON_NumeroParti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."JSON_NumeroParti" IS 'Qualora sia presente il file JSON, specifica in quanti parti viene suddiviso';


--
-- TOC entry 2905 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."JSON_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."JSON_Texture" IS 'Specifica se il modello JSON contiene le informazioni per la texture';


--
-- TOC entry 2906 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."OBJ"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."OBJ" IS 'Indica se è stato inserito nel database il file OBJ corrispondente';


--
-- TOC entry 2907 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN "Modelli3D_LoD"."HotSpot"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_LoD"."HotSpot" IS 'Indica se è stato inserito nel database le informazioni per l''HotSpot';


--
-- TOC entry 207 (class 1259 OID 22009)
-- Name: Oggetti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti" (
    "Codice" bigint NOT NULL,
    "Layer0" character varying(255) NOT NULL,
    "Layer1" character varying(255) NOT NULL,
    "Layer2" character varying(255) NOT NULL,
    "Layer3" character varying(255) NOT NULL,
    "Name" character varying(255) NOT NULL,
    "Categoria" integer,
    "DataCreazione" timestamp with time zone DEFAULT "now"() NOT NULL,
    "DataEliminazione" timestamp with time zone,
    "CantiereCreazione" integer DEFAULT 0 NOT NULL,
    "CantiereEliminazione" integer,
    "Lock" character varying(255),
    "Updating" boolean DEFAULT false NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Oggetti" OWNER TO "postgres";

--
-- TOC entry 2908 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE "Oggetti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Oggetti" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2909 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Codice" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2910 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Layer0"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Layer0" IS 'Layer0 in cui è contenuto l''oggetto';


--
-- TOC entry 2911 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Layer1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Layer1" IS 'Layer1 in cui è contenuto l''oggetto';


--
-- TOC entry 2912 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Layer2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Layer2" IS 'Layer2 in cui è contenuto l''oggetto';


--
-- TOC entry 2913 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Layer3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Layer3" IS 'Layer3 in cui è contenuto l''oggetto';


--
-- TOC entry 2914 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Name" IS 'Nome utilizzato per disambiguare due oggetti appartenenti allo stesso Layer0 + Layer1 + Layer2 + Layer3';


--
-- TOC entry 2915 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Categoria"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Categoria" IS 'Codice della categoria dell''oggetto';


--
-- TOC entry 2916 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto';


--
-- TOC entry 2917 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto';


--
-- TOC entry 2918 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto';


--
-- TOC entry 2919 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto';


--
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2921 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2922 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2923 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "Oggetti"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 208 (class 1259 OID 22019)
-- Name: OggettiVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion" (
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


ALTER TABLE "public"."OggettiVersion" OWNER TO "postgres";

--
-- TOC entry 2924 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE "OggettiVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiVersion" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2925 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."Codice" IS 'Codice identificativo dell''oggetto+versione - PRIMARY KEY';


--
-- TOC entry 2926 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."CodiceOggetto" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2927 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."Versione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."Versione" IS 'Versione dell''oggetto, per identificare variazioni del modello dell''oggetto in seguito ad interventi o cambiamenti (DEFAULT 0)';


--
-- TOC entry 2928 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."CodiceModello" IS 'Codice del modello 3D dell''oggetto+versione';


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."Originale" IS 'Se 0 è l''oggetto+versione originale, altrimenti è un oggetto modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2930 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."Live"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."Live" IS 'L''oggetto è attivo nel modello 3d corrente?

0 -> non attivo
1 -> live on-line
2 -> live on-line, ma morto (nuovo non pronto)
3 -> modello da creare di un oggetto che deve diventare on-line
4 -> inserito ex-novo da Rhino, da gestire e attivare
6 -> modello figlio creato, ma non on-line perché in attesa di modello di altri figli';


--
-- TOC entry 2931 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto+versione';


--
-- TOC entry 2932 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto+versione';


--
-- TOC entry 2933 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione';


--
-- TOC entry 2934 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione';


--
-- TOC entry 2935 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2936 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2937 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2938 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 209 (class 1259 OID 22032)
-- Name: ListaOggettiLoD; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."ListaOggettiLoD" AS
 SELECT "OggettiVersion"."Codice",
    "Oggetti"."Layer0",
    "Oggetti"."Layer1",
    "Oggetti"."Layer2",
    "Oggetti"."Layer3",
    "Oggetti"."Name",
    "Oggetti"."Categoria",
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
   FROM ((("public"."Oggetti"
     JOIN "public"."OggettiVersion" ON (("Oggetti"."Codice" = "OggettiVersion"."CodiceOggetto")))
     JOIN "public"."Modelli3D" ON (("OggettiVersion"."CodiceModello" = "Modelli3D"."Codice")))
     JOIN "public"."Modelli3D_LoD" ON (("OggettiVersion"."CodiceModello" = "Modelli3D_LoD"."CodiceModello")))
  WHERE ((("OggettiVersion"."Live" = 1) OR ("OggettiVersion"."Live" = 2)) AND ("OggettiVersion"."Updating" = false))
  ORDER BY "OggettiVersion"."Codice", "Modelli3D_LoD"."LoD";


ALTER TABLE "public"."ListaOggettiLoD" OWNER TO "postgres";

--
-- TOC entry 210 (class 1259 OID 22037)
-- Name: Log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Log" (
    "NumeroLog" bigint NOT NULL,
    "DateTime" timestamp without time zone NOT NULL,
    "Messaggio" "text" NOT NULL,
    "User" character varying(255)
);


ALTER TABLE "public"."Log" OWNER TO "postgres";

--
-- TOC entry 2939 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE "Log"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Log" IS 'Log degli errori';


--
-- TOC entry 2940 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "Log"."DateTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Log"."DateTime" IS 'Data e ora dell''evento';


--
-- TOC entry 2941 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "Log"."Messaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Log"."Messaggio" IS 'Messaggio di log';


--
-- TOC entry 2942 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN "Log"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Log"."User" IS 'Utente che ha effettuato l''operazione';


--
-- TOC entry 211 (class 1259 OID 22043)
-- Name: Log_NumeroLog_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Log_NumeroLog_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Log_NumeroLog_seq" OWNER TO "postgres";

--
-- TOC entry 2943 (class 0 OID 0)
-- Dependencies: 211
-- Name: Log_NumeroLog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Log_NumeroLog_seq" OWNED BY "public"."Log"."NumeroLog";


--
-- TOC entry 212 (class 1259 OID 22045)
-- Name: MaterialeInterventiSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."MaterialeInterventiSubVersion" (
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


ALTER TABLE "public"."MaterialeInterventiSubVersion" OWNER TO "postgres";

--
-- TOC entry 2944 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE "MaterialeInterventiSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."MaterialeInterventiSubVersion" IS 'Tabella contenente tutto il materiale (file) associato alle SubVersion';


--
-- TOC entry 2945 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."CodiceSubVersion" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2946 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."URL" IS 'URL del materiale';


--
-- TOC entry 2947 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2948 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2949 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2950 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2951 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2952 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2953 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2954 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2955 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2956 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2957 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN "MaterialeInterventiSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeInterventiSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 213 (class 1259 OID 22056)
-- Name: MaterialeOggetti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."MaterialeOggetti" (
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


ALTER TABLE "public"."MaterialeOggetti" OWNER TO "postgres";

--
-- TOC entry 2958 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE "MaterialeOggetti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."MaterialeOggetti" IS 'Tabella contenente tutto il materiale (file) associato agli oggetti';


--
-- TOC entry 2959 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."CodiceOggetto" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2960 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."URL" IS 'URL del materiale';


--
-- TOC entry 2961 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2962 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2963 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2964 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2965 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2966 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2967 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2968 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2969 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2970 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2971 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "MaterialeOggetti"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeOggetti"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 214 (class 1259 OID 22067)
-- Name: MaterialeSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."MaterialeSubVersion" (
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


ALTER TABLE "public"."MaterialeSubVersion" OWNER TO "postgres";

--
-- TOC entry 2972 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE "MaterialeSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."MaterialeSubVersion" IS 'Tabella contenente tutto il materiale (file) associato alle SubVersion';


--
-- TOC entry 2973 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."CodiceSubVersion" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2974 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."URL" IS 'URL del materiale';


--
-- TOC entry 2975 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2976 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2977 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2978 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2979 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2980 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2985 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN "MaterialeSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 215 (class 1259 OID 22078)
-- Name: MaterialeVersioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."MaterialeVersioni" (
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


ALTER TABLE "public"."MaterialeVersioni" OWNER TO "postgres";

--
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE "MaterialeVersioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."MaterialeVersioni" IS 'Tabella contenente tutto il materiale (file) associato alle versioni';


--
-- TOC entry 2987 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."CodiceVersione" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."URL" IS 'URL del materiale';


--
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "MaterialeVersioni"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."MaterialeVersioni"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 216 (class 1259 OID 22089)
-- Name: MaxCantieri; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."MaxCantieri" AS
 SELECT "Cantieri"."Layer0",
    "max"("Cantieri"."Numero") AS "num"
   FROM "public"."Cantieri"
  GROUP BY "Cantieri"."Layer0";


ALTER TABLE "public"."MaxCantieri" OWNER TO "postgres";

--
-- TOC entry 217 (class 1259 OID 22093)
-- Name: Modelli3D_3dm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_3dm" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_3dm" OWNER TO "postgres";

--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE "Modelli3D_3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_3dm" IS 'Tabella contenente i file 3dm dei Modelli 3D';


--
-- TOC entry 3001 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "Modelli3D_3dm"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_3dm"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 3002 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "Modelli3D_3dm"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_3dm"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 3003 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "Modelli3D_3dm"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_3dm"."file" IS 'File 3dm codificato in bytea';


--
-- TOC entry 3004 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "Modelli3D_3dm"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_3dm"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 3005 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "Modelli3D_3dm"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_3dm"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 218 (class 1259 OID 22101)
-- Name: Modelli3D_3dm_Backup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_3dm_Backup" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer DEFAULT 0 NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_3dm_Backup" OWNER TO "postgres";

--
-- TOC entry 3006 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE "Modelli3D_3dm_Backup"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_3dm_Backup" IS 'Tabella contenente il backup dei  file 3dm dei Modelli 3D';


--
-- TOC entry 219 (class 1259 OID 22109)
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Modelli3D_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Modelli3D_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3007 (class 0 OID 0)
-- Dependencies: 219
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Modelli3D_Codice_seq" OWNED BY "public"."Modelli3D"."Codice";


--
-- TOC entry 220 (class 1259 OID 22111)
-- Name: Modelli3D_HotSpotColor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_HotSpotColor" (
    "CodiceModello" bigint NOT NULL,
    "ColorR" real DEFAULT 1 NOT NULL,
    "ColorG" real DEFAULT 0 NOT NULL,
    "ColorB" real DEFAULT 0 NOT NULL,
    "ColorA" real DEFAULT 0.6 NOT NULL
);


ALTER TABLE "public"."Modelli3D_HotSpotColor" OWNER TO "postgres";

--
-- TOC entry 3008 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE "Modelli3D_HotSpotColor"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_HotSpotColor" IS 'Contiene i dati colore per gli hotspot';


--
-- TOC entry 3009 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Modelli3D_HotSpotColor"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_HotSpotColor"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 3010 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorR"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_HotSpotColor"."ColorR" IS 'Colore red';


--
-- TOC entry 3011 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorG"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_HotSpotColor"."ColorG" IS 'Colore green';


--
-- TOC entry 3012 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorB"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_HotSpotColor"."ColorB" IS 'Colore blue';


--
-- TOC entry 3013 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorA"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_HotSpotColor"."ColorA" IS 'Canale Alpha del colore';


--
-- TOC entry 221 (class 1259 OID 22118)
-- Name: Modelli3D_JSON; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_JSON" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "Parte" integer NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_JSON" OWNER TO "postgres";

--
-- TOC entry 3014 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE "Modelli3D_JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_JSON" IS 'Tabella contenente i file JSON dei Modelli 3D';


--
-- TOC entry 3015 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN "Modelli3D_JSON"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_JSON"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 3016 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN "Modelli3D_JSON"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_JSON"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 3017 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN "Modelli3D_JSON"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_JSON"."Parte" IS 'Parte del file JSON';


--
-- TOC entry 3018 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN "Modelli3D_JSON"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_JSON"."file" IS 'File JSON codificato in bytea';


--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN "Modelli3D_JSON"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_JSON"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN "Modelli3D_JSON"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_JSON"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 222 (class 1259 OID 22125)
-- Name: Modelli3D_OBJ; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_OBJ" (
    "CodiceModello" bigint NOT NULL,
    "LoD" integer NOT NULL,
    "Parte" integer NOT NULL,
    "file" "bytea" NOT NULL,
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255)
);


ALTER TABLE "public"."Modelli3D_OBJ" OWNER TO "postgres";

--
-- TOC entry 3021 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE "Modelli3D_OBJ"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_OBJ" IS 'Tabella contenente i file OBJ dei Modelli 3D';


--
-- TOC entry 3022 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Modelli3D_OBJ"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_OBJ"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Modelli3D_OBJ"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_OBJ"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Modelli3D_OBJ"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_OBJ"."Parte" IS 'Parte del file OBJ';


--
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Modelli3D_OBJ"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_OBJ"."file" IS 'File OBJ codificato in bytea';


--
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Modelli3D_OBJ"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_OBJ"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 3027 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Modelli3D_OBJ"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_OBJ"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 223 (class 1259 OID 22132)
-- Name: Modelli3D_Texture; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Modelli3D_Texture" (
    "CodiceModello" bigint NOT NULL,
    "TextureNumber" integer DEFAULT 0 NOT NULL,
    "Qualità" integer DEFAULT 0 NOT NULL,
    "Filename" character varying(255) NOT NULL,
    "file" "bytea" NOT NULL,
    "MimeType" character varying(255),
    "LastUpdate" timestamp with time zone DEFAULT "now"() NOT NULL,
    "LastUpdateBy" character varying(255) NOT NULL
);


ALTER TABLE "public"."Modelli3D_Texture" OWNER TO "postgres";

--
-- TOC entry 3028 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE "Modelli3D_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Modelli3D_Texture" IS 'Tabella contenente le texture dei modelli';


--
-- TOC entry 3029 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 3030 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."TextureNumber"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."TextureNumber" IS 'Numero dell''indice della texture (se è una texture sola è 0)';


--
-- TOC entry 3031 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."Qualità" IS '0 -> originale
1 -> 2048
2 -> 1024
3 -> 512
4 -> 256
5 -> 128
6 -> 64
7 -> 32';


--
-- TOC entry 3032 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."Filename" IS 'Nome del file';


--
-- TOC entry 3033 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."file" IS 'File salvato il bytea';


--
-- TOC entry 3034 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."MimeType"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."MimeType" IS 'MimeType del file';


--
-- TOC entry 3035 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."LastUpdate" IS 'Data dell''ultima modifica';


--
-- TOC entry 3036 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN "Modelli3D_Texture"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Modelli3D_Texture"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 224 (class 1259 OID 22141)
-- Name: OggettiSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion" (
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


ALTER TABLE "public"."OggettiSubVersion" OWNER TO "postgres";

--
-- TOC entry 3037 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE "OggettiSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiSubVersion" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 3038 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."Codice" IS 'Codice identificativo dell''oggetto+versione - PRIMARY KEY';


--
-- TOC entry 3039 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."CodiceOggetto" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 3040 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."CodiceVersione" IS 'Codice identificativo dell''oggetto+versione ';


--
-- TOC entry 3041 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."SubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."SubVersion" IS 'SubVersion dell''oggetto, per identificare variazioni in seguito ad interventi che non modificano il modello (DEFAULT 0)';


--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."Originale" IS 'Se 0 è l''oggetto+versione originale, altrimenti è un oggetto modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 3043 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto+versione+subversion';


--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto+versione+subversion';


--
-- TOC entry 3045 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione+subversion';


--
-- TOC entry 3046 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione+subversion';


--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "OggettiSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 225 (class 1259 OID 22154)
-- Name: OggettiSubVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "public"."OggettiSubVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN "OggettiSubVersion_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 226 (class 1259 OID 22157)
-- Name: OggettiSubVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "public"."OggettiSubVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE "OggettiSubVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiSubVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 227 (class 1259 OID 22160)
-- Name: OggettiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiSubVersion_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiSubVersion_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 227
-- Name: OggettiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiSubVersion_InfoComboBox_Codice_seq" OWNED BY "public"."OggettiSubVersion_InfoComboBox"."Codice";


--
-- TOC entry 228 (class 1259 OID 22162)
-- Name: OggettiSubVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion_ListaInformazioni" (
    "Codice" integer NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL,
    "IsMultiCombo" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer DEFAULT 0 NOT NULL,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "public"."OggettiSubVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE "OggettiSubVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiSubVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli OggettiSubVersion e dei relativi campi';


--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 229 (class 1259 OID 22177)
-- Name: OggettiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiSubVersion_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiSubVersion_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 229
-- Name: OggettiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiSubVersion_ListaInformazioni_Codice_seq" OWNED BY "public"."OggettiSubVersion_ListaInformazioni"."Codice";


--
-- TOC entry 230 (class 1259 OID 22179)
-- Name: OggettiSubVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "public"."OggettiSubVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE "OggettiSubVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiSubVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 231 (class 1259 OID 22182)
-- Name: OggettiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiSubVersion_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiSubVersion_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 231
-- Name: OggettiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiSubVersion_ListaSchede_Codice_seq" OWNED BY "public"."OggettiSubVersion_ListaSchede"."Codice";


--
-- TOC entry 232 (class 1259 OID 22184)
-- Name: OggettiSubVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion_RelazioniSchede" (
    "CodiceSubVersion" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "public"."OggettiSubVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE "OggettiSubVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiSubVersion_RelazioniSchede" IS 'Relazioni tra gli OggettiSubVersion e le schede informative';


--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_RelazioniSchede"."CodiceSubVersion" IS 'Codice dell''oggetto';


--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 233 (class 1259 OID 22187)
-- Name: OggettiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiSubVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 233
-- Name: OggettiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "public"."OggettiSubVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 234 (class 1259 OID 22189)
-- Name: OggettiSubVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiSubVersion_Schede" (
    "CodiceScheda" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint,
    "MultiComboValue" character varying(255)
);


ALTER TABLE "public"."OggettiSubVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE "OggettiSubVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiSubVersion_Schede" IS 'Informazioni testuali sugli OggettiSubVersion';


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN "OggettiSubVersion_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiSubVersion_Schede"."MultiComboValue" IS 'Valore del multi combobox';


--
-- TOC entry 235 (class 1259 OID 22195)
-- Name: OggettiVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "public"."OggettiVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN "OggettiVersion_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 236 (class 1259 OID 22198)
-- Name: OggettiVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "public"."OggettiVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE "OggettiVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN "OggettiVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN "OggettiVersion_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN "OggettiVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 237 (class 1259 OID 22201)
-- Name: OggettiVersion_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiVersion_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiVersion_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 237
-- Name: OggettiVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiVersion_InfoComboBox_Codice_seq" OWNED BY "public"."OggettiVersion_InfoComboBox"."Codice";


--
-- TOC entry 238 (class 1259 OID 22203)
-- Name: OggettiVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion_ListaInformazioni" (
    "Codice" integer NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL,
    "IsMultiCombo" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer DEFAULT 0 NOT NULL,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "public"."OggettiVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE "OggettiVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli OggettiVersion e dei relativi campi';


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 3104 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 3105 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 239 (class 1259 OID 22218)
-- Name: OggettiVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiVersion_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiVersion_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 239
-- Name: OggettiVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiVersion_ListaInformazioni_Codice_seq" OWNED BY "public"."OggettiVersion_ListaInformazioni"."Codice";


--
-- TOC entry 240 (class 1259 OID 22220)
-- Name: OggettiVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "public"."OggettiVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE "OggettiVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN "OggettiVersion_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN "OggettiVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN "OggettiVersion_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 241 (class 1259 OID 22223)
-- Name: OggettiVersion_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiVersion_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiVersion_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 241
-- Name: OggettiVersion_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiVersion_ListaSchede_Codice_seq" OWNED BY "public"."OggettiVersion_ListaSchede"."Codice";


--
-- TOC entry 242 (class 1259 OID 22225)
-- Name: OggettiVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion_RelazioniSchede" (
    "CodiceVersione" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "public"."OggettiVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE "OggettiVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiVersion_RelazioniSchede" IS 'Relazioni tra gli OggettiVersion e le schede informative';


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_RelazioniSchede"."CodiceVersione" IS 'Codice dell''oggetto';


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 243 (class 1259 OID 22228)
-- Name: OggettiVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."OggettiVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."OggettiVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 243
-- Name: OggettiVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."OggettiVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "public"."OggettiVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 244 (class 1259 OID 22230)
-- Name: OggettiVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."OggettiVersion_Schede" (
    "CodiceScheda" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint,
    "MultiComboValue" character varying(255)
);


ALTER TABLE "public"."OggettiVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE "OggettiVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."OggettiVersion_Schede" IS 'Informazioni testuali sugli OggettiVersion';


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN "OggettiVersion_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."OggettiVersion_Schede"."MultiComboValue" IS 'Valore del multi combobox';


--
-- TOC entry 245 (class 1259 OID 22236)
-- Name: Oggetti_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "public"."Oggetti_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN "Oggetti_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 246 (class 1259 OID 22239)
-- Name: Oggetti_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 246
-- Name: Oggetti_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_Codice_seq" OWNED BY "public"."Oggetti"."Codice";


--
-- TOC entry 247 (class 1259 OID 22241)
-- Name: Oggetti_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "public"."Oggetti_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE "Oggetti_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Oggetti_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN "Oggetti_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN "Oggetti_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN "Oggetti_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 248 (class 1259 OID 22244)
-- Name: Oggetti_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3143 (class 0 OID 0)
-- Dependencies: 248
-- Name: Oggetti_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_InfoComboBox_Codice_seq" OWNED BY "public"."Oggetti_InfoComboBox"."Codice";


--
-- TOC entry 249 (class 1259 OID 22246)
-- Name: Oggetti_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti_ListaInformazioni" (
    "Codice" integer NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "Campo" character varying(255) NOT NULL,
    "IsTitle" boolean DEFAULT false NOT NULL,
    "IsLink" boolean DEFAULT false NOT NULL,
    "IsBool" boolean DEFAULT false NOT NULL,
    "IsInt" boolean DEFAULT false NOT NULL,
    "IsReal" boolean DEFAULT false NOT NULL,
    "IsText" boolean DEFAULT false NOT NULL,
    "IsTimestamp" boolean DEFAULT false NOT NULL,
    "IsCombo" boolean DEFAULT false NOT NULL,
    "IsMultiCombo" boolean DEFAULT false NOT NULL,
    "IsSeparator" boolean DEFAULT false NOT NULL,
    "Posizione" integer DEFAULT 0 NOT NULL,
    "Height" integer DEFAULT 22 NOT NULL
);


ALTER TABLE "public"."Oggetti_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE "Oggetti_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Oggetti_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli oggetti e dei relativi campi';


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 3146 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3147 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 3148 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 3149 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 3151 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 3152 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 3153 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 3154 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 3155 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 3156 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 3157 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 3158 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 3159 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "Oggetti_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 250 (class 1259 OID 22261)
-- Name: Oggetti_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3160 (class 0 OID 0)
-- Dependencies: 250
-- Name: Oggetti_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_ListaInformazioni_Codice_seq" OWNED BY "public"."Oggetti_ListaInformazioni"."Codice";


--
-- TOC entry 251 (class 1259 OID 22263)
-- Name: Oggetti_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "public"."Oggetti_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 3161 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE "Oggetti_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Oggetti_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 3162 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN "Oggetti_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 3163 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN "Oggetti_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 3164 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN "Oggetti_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 252 (class 1259 OID 22266)
-- Name: Oggetti_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3165 (class 0 OID 0)
-- Dependencies: 252
-- Name: Oggetti_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_ListaSchede_Codice_seq" OWNED BY "public"."Oggetti_ListaSchede"."Codice";


--
-- TOC entry 253 (class 1259 OID 22268)
-- Name: Oggetti_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti_RelazioniSchede" (
    "CodiceOggetto" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "public"."Oggetti_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 3166 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE "Oggetti_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Oggetti_RelazioniSchede" IS 'Relazioni tra gli oggetti e le schede informative';


--
-- TOC entry 3167 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_RelazioniSchede"."CodiceOggetto" IS 'Codice dell''oggetto';


--
-- TOC entry 3168 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3169 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 254 (class 1259 OID 22271)
-- Name: Oggetti_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 3170 (class 0 OID 0)
-- Dependencies: 254
-- Name: Oggetti_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_RelazioniSchede_CodiceScheda_seq" OWNED BY "public"."Oggetti_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 255 (class 1259 OID 22273)
-- Name: Oggetti_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Oggetti_Schede" (
    "CodiceScheda" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "BoolValue" boolean,
    "IntValue" integer,
    "RealValue" real,
    "TextValue" "text",
    "TimestampValue" timestamp with time zone,
    "ComboValue" bigint,
    "MultiComboValue" character varying(255)
);


ALTER TABLE "public"."Oggetti_Schede" OWNER TO "postgres";

--
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE "Oggetti_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Oggetti_Schede" IS 'Informazioni testuali sugli oggetti';


--
-- TOC entry 3172 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 3173 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 3177 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 3178 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 3179 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 3180 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN "Oggetti_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Oggetti_Schede"."MultiComboValue" IS 'Valore di un comobox multiplo';


--
-- TOC entry 256 (class 1259 OID 22279)
-- Name: Oggetti_SubVersion_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_SubVersion_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_SubVersion_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3181 (class 0 OID 0)
-- Dependencies: 256
-- Name: Oggetti_SubVersion_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_SubVersion_Codice_seq" OWNED BY "public"."OggettiSubVersion"."Codice";


--
-- TOC entry 257 (class 1259 OID 22281)
-- Name: Oggetti_Versioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."Oggetti_Versioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."Oggetti_Versioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3182 (class 0 OID 0)
-- Dependencies: 257
-- Name: Oggetti_Versioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."Oggetti_Versioni_Codice_seq" OWNED BY "public"."OggettiVersion"."Codice";


--
-- TOC entry 258 (class 1259 OID 22283)
-- Name: Settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Settings" (
    "Key" character varying(255) NOT NULL,
    "Value" character varying(255) NOT NULL
);


ALTER TABLE "public"."Settings" OWNER TO "postgres";

--
-- TOC entry 3183 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE "Settings"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Settings" IS 'Tabella che contiene i vari settings del db';


--
-- TOC entry 3184 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN "Settings"."Key"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Settings"."Key" IS 'Chiave del setting';


--
-- TOC entry 3185 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN "Settings"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Settings"."Value" IS 'Valore del setting';


--
-- TOC entry 259 (class 1259 OID 22289)
-- Name: Utenti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."Utenti" (
    "User" character varying(255) NOT NULL,
    "Password" character varying NOT NULL,
    "FullName" character varying(255) NOT NULL,
    "Gruppi" character varying NOT NULL
);


ALTER TABLE "public"."Utenti" OWNER TO "postgres";

--
-- TOC entry 3186 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE "Utenti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "public"."Utenti" IS 'Tabella accessi e permessi';


--
-- TOC entry 3187 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN "Utenti"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Utenti"."User" IS 'Nome utente';


--
-- TOC entry 3188 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN "Utenti"."Password"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Utenti"."Password" IS 'Password dell''account';


--
-- TOC entry 3189 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN "Utenti"."FullName"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Utenti"."FullName" IS 'Nome e cognome reale';


--
-- TOC entry 3190 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN "Utenti"."Gruppi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "public"."Utenti"."Gruppi" IS 'gruppi, separati da virgole e senza spazi';


--
-- TOC entry 2342 (class 2604 OID 22295)
-- Name: Categorie Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Categorie" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Categorie_Codice_seq"'::"regclass");


--
-- TOC entry 2348 (class 2604 OID 22296)
-- Name: GruppiCategorie Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."GruppiCategorie" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."GruppiCategorie_Codice_seq"'::"regclass");


--
-- TOC entry 2350 (class 2604 OID 22297)
-- Name: InterventiSubVersion Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."InterventiSubVersion_Codice_seq"'::"regclass");


--
-- TOC entry 2351 (class 2604 OID 22298)
-- Name: InterventiSubVersion_InfoComboBox Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."InterventiSubVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2364 (class 2604 OID 22299)
-- Name: InterventiSubVersion_ListaInformazioni Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."InterventiSubVersion_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2365 (class 2604 OID 22300)
-- Name: InterventiSubVersion_ListaSchede Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."InterventiSubVersion_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2366 (class 2604 OID 22301)
-- Name: InterventiSubVersion_RelazioniSchede CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"public"."InterventiSubVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2391 (class 2604 OID 22302)
-- Name: Log NumeroLog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Log" ALTER COLUMN "NumeroLog" SET DEFAULT "nextval"('"public"."Log_NumeroLog_seq"'::"regclass");


--
-- TOC entry 2369 (class 2604 OID 22303)
-- Name: Modelli3D Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Modelli3D_Codice_seq"'::"regclass");


--
-- TOC entry 2382 (class 2604 OID 22304)
-- Name: Oggetti Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Oggetti_Codice_seq"'::"regclass");


--
-- TOC entry 2432 (class 2604 OID 22305)
-- Name: OggettiSubVersion Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Oggetti_SubVersion_Codice_seq"'::"regclass");


--
-- TOC entry 2433 (class 2604 OID 22306)
-- Name: OggettiSubVersion_InfoComboBox Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."OggettiSubVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2446 (class 2604 OID 22307)
-- Name: OggettiSubVersion_ListaInformazioni Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."OggettiSubVersion_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2447 (class 2604 OID 22308)
-- Name: OggettiSubVersion_ListaSchede Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."OggettiSubVersion_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2448 (class 2604 OID 22309)
-- Name: OggettiSubVersion_RelazioniSchede CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"public"."OggettiSubVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2390 (class 2604 OID 22310)
-- Name: OggettiVersion Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Oggetti_Versioni_Codice_seq"'::"regclass");


--
-- TOC entry 2449 (class 2604 OID 22311)
-- Name: OggettiVersion_InfoComboBox Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."OggettiVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2462 (class 2604 OID 22312)
-- Name: OggettiVersion_ListaInformazioni Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."OggettiVersion_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2463 (class 2604 OID 22313)
-- Name: OggettiVersion_ListaSchede Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."OggettiVersion_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2464 (class 2604 OID 22314)
-- Name: OggettiVersion_RelazioniSchede CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"public"."OggettiVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2465 (class 2604 OID 22315)
-- Name: Oggetti_InfoComboBox Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Oggetti_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2478 (class 2604 OID 22316)
-- Name: Oggetti_ListaInformazioni Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Oggetti_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2479 (class 2604 OID 22317)
-- Name: Oggetti_ListaSchede Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"public"."Oggetti_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2480 (class 2604 OID 22318)
-- Name: Oggetti_RelazioniSchede CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"public"."Oggetti_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2482 (class 2606 OID 22862)
-- Name: Cantieri Cantieri_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Cantieri"
    ADD CONSTRAINT "Cantieri_primaryKey" PRIMARY KEY ("Layer0", "Numero");


--
-- TOC entry 2484 (class 2606 OID 22864)
-- Name: Categorie Categorie_UniqueName; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Categorie"
    ADD CONSTRAINT "Categorie_UniqueName" UNIQUE ("Nome");


--
-- TOC entry 2486 (class 2606 OID 22866)
-- Name: Categorie Categorie_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Categorie"
    ADD CONSTRAINT "Categorie_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2488 (class 2606 OID 22868)
-- Name: FileExtra FileExtra_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."FileExtra"
    ADD CONSTRAINT "FileExtra_primaryKey" PRIMARY KEY ("Filename");


--
-- TOC entry 2490 (class 2606 OID 22870)
-- Name: GruppiCategorie GruppiCategorie-NomeUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."GruppiCategorie"
    ADD CONSTRAINT "GruppiCategorie-NomeUnique" UNIQUE ("Nome");


--
-- TOC entry 2492 (class 2606 OID 22872)
-- Name: GruppiCategorie GruppiCategorie-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."GruppiCategorie"
    ADD CONSTRAINT "GruppiCategorie-primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2494 (class 2606 OID 22874)
-- Name: Import Import_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Import"
    ADD CONSTRAINT "Import_primaryKey" PRIMARY KEY ("User", "CodiceVersione");


--
-- TOC entry 2498 (class 2606 OID 22876)
-- Name: InterventiSubVersion_CategorieSchede InterventiSubVersion_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_CategorieSchede"
    ADD CONSTRAINT "InterventiSubVersion_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2500 (class 2606 OID 22878)
-- Name: InterventiSubVersion_InfoComboBox InterventiSubVersion_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_InfoComboBox"
    ADD CONSTRAINT "InterventiSubVersion_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2502 (class 2606 OID 22880)
-- Name: InterventiSubVersion_ListaInformazioni InterventiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "InterventiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2504 (class 2606 OID 22882)
-- Name: InterventiSubVersion_ListaInformazioni InterventiSubVersion_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "InterventiSubVersion_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2506 (class 2606 OID 22884)
-- Name: InterventiSubVersion_ListaSchede InterventiSubVersion_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaSchede"
    ADD CONSTRAINT "InterventiSubVersion_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2508 (class 2606 OID 22886)
-- Name: InterventiSubVersion_ListaSchede InterventiSubVersion_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaSchede"
    ADD CONSTRAINT "InterventiSubVersion_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2510 (class 2606 OID 22888)
-- Name: InterventiSubVersion_Relazioni InterventiSubVersion_Relazioni-UniqueFiglio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-UniqueFiglio" UNIQUE ("Figlio");


--
-- TOC entry 2512 (class 2606 OID 22890)
-- Name: InterventiSubVersion_Relazioni InterventiSubVersion_Relazioni-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-primaryKey" PRIMARY KEY ("Intervento", "Padre");


--
-- TOC entry 2516 (class 2606 OID 22892)
-- Name: InterventiSubVersion_RelazioniSchede InterventiSubVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "InterventiSubVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceSubVersion", "CodiceTitolo");


--
-- TOC entry 2514 (class 2606 OID 22894)
-- Name: InterventiSubVersion_Relazioni InterventiSubVersion_Relazioni_UniquePadre; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni_UniquePadre" UNIQUE ("Padre");


--
-- TOC entry 2518 (class 2606 OID 22896)
-- Name: InterventiSubVersion_Schede InterventiSubVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Schede"
    ADD CONSTRAINT "InterventiSubVersion_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2496 (class 2606 OID 22898)
-- Name: InterventiSubVersion InterventiSubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion"
    ADD CONSTRAINT "InterventiSubVersion_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2532 (class 2606 OID 22900)
-- Name: Log Log_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Log"
    ADD CONSTRAINT "Log_primaryKey" PRIMARY KEY ("NumeroLog");


--
-- TOC entry 2534 (class 2606 OID 22902)
-- Name: MaterialeInterventiSubVersion MaterialeInterventiSubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeInterventiSubVersion"
    ADD CONSTRAINT "MaterialeInterventiSubVersion_primaryKey" PRIMARY KEY ("CodiceSubVersion", "URL", "Qualità");


--
-- TOC entry 2536 (class 2606 OID 22904)
-- Name: MaterialeOggetti MaterialeOggetti_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeOggetti"
    ADD CONSTRAINT "MaterialeOggetti_primaryKey" PRIMARY KEY ("CodiceOggetto", "URL", "Qualità");


--
-- TOC entry 2538 (class 2606 OID 22906)
-- Name: MaterialeSubVersion MaterialeSubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeSubVersion"
    ADD CONSTRAINT "MaterialeSubVersion_primaryKey" PRIMARY KEY ("CodiceSubVersion", "URL", "Qualità");


--
-- TOC entry 2540 (class 2606 OID 22908)
-- Name: MaterialeVersioni MaterialeVersioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeVersioni"
    ADD CONSTRAINT "MaterialeVersioni_primaryKey" PRIMARY KEY ("CodiceVersione", "URL", "Qualità");


--
-- TOC entry 2544 (class 2606 OID 22910)
-- Name: Modelli3D_3dm_Backup Modelli3D_3dm_Backup_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_3dm_Backup"
    ADD CONSTRAINT "Modelli3D_3dm_Backup_primaryKey" PRIMARY KEY ("CodiceModello", "LoD", "LastUpdate");


--
-- TOC entry 2542 (class 2606 OID 22912)
-- Name: Modelli3D_3dm Modelli3D_3dm_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm_primaryKey" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2546 (class 2606 OID 22914)
-- Name: Modelli3D_HotSpotColor Modelli3D_HotSpotColor_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_HotSpotColor"
    ADD CONSTRAINT "Modelli3D_HotSpotColor_primaryKey" PRIMARY KEY ("CodiceModello");


--
-- TOC entry 2522 (class 2606 OID 22916)
-- Name: Modelli3D_LoD Modelli3D_LoD_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD_primaryKey" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2552 (class 2606 OID 22918)
-- Name: Modelli3D_Texture Modelli3D_Textture_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Textture_primaryKey" PRIMARY KEY ("CodiceModello", "TextureNumber", "Qualità");


--
-- TOC entry 2520 (class 2606 OID 22920)
-- Name: Modelli3D Modelli3D_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D"
    ADD CONSTRAINT "Modelli3D_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2548 (class 2606 OID 22922)
-- Name: Modelli3D_JSON Modelli3d_OggettiJSON_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3d_OggettiJSON_primaryKey" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2550 (class 2606 OID 22924)
-- Name: Modelli3D_OBJ Modelli3d_OggettiOBJ-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_OBJ"
    ADD CONSTRAINT "Modelli3d_OggettiOBJ-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2524 (class 2606 OID 22926)
-- Name: Oggetti Oggetti-UniqueLayersName; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti"
    ADD CONSTRAINT "Oggetti-UniqueLayersName" UNIQUE ("Layer0", "Layer1", "Layer2", "Layer3", "Name");


--
-- TOC entry 2558 (class 2606 OID 22928)
-- Name: OggettiSubVersion_CategorieSchede OggettiSubVersion_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2560 (class 2606 OID 22930)
-- Name: OggettiSubVersion_InfoComboBox OggettiSubVersion_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiSubVersion_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2562 (class 2606 OID 22932)
-- Name: OggettiSubVersion_ListaInformazioni OggettiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2564 (class 2606 OID 22934)
-- Name: OggettiSubVersion_ListaInformazioni OggettiSubVersion_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2566 (class 2606 OID 22936)
-- Name: OggettiSubVersion_ListaSchede OggettiSubVersion_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaSchede"
    ADD CONSTRAINT "OggettiSubVersion_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2568 (class 2606 OID 22938)
-- Name: OggettiSubVersion_ListaSchede OggettiSubVersion_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaSchede"
    ADD CONSTRAINT "OggettiSubVersion_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2570 (class 2606 OID 22940)
-- Name: OggettiSubVersion_RelazioniSchede OggettiSubVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceSubVersion", "CodiceTitolo");


--
-- TOC entry 2572 (class 2606 OID 22942)
-- Name: OggettiSubVersion_Schede OggettiSubVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2574 (class 2606 OID 22944)
-- Name: OggettiVersion_CategorieSchede OggettiVersion_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2576 (class 2606 OID 22946)
-- Name: OggettiVersion_InfoComboBox OggettiVersion_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiVersion_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2578 (class 2606 OID 22948)
-- Name: OggettiVersion_ListaInformazioni OggettiVersion_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2580 (class 2606 OID 22950)
-- Name: OggettiVersion_ListaInformazioni OggettiVersion_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2582 (class 2606 OID 22952)
-- Name: OggettiVersion_ListaSchede OggettiVersion_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaSchede"
    ADD CONSTRAINT "OggettiVersion_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2584 (class 2606 OID 22954)
-- Name: OggettiVersion_ListaSchede OggettiVersion_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaSchede"
    ADD CONSTRAINT "OggettiVersion_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2586 (class 2606 OID 22956)
-- Name: OggettiVersion_RelazioniSchede OggettiVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceVersione", "CodiceTitolo");


--
-- TOC entry 2588 (class 2606 OID 22958)
-- Name: OggettiVersion_Schede OggettiVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2590 (class 2606 OID 22960)
-- Name: Oggetti_CategorieSchede Oggetti_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2592 (class 2606 OID 22962)
-- Name: Oggetti_InfoComboBox Oggetti_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_InfoComboBox"
    ADD CONSTRAINT "Oggetti_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2594 (class 2606 OID 22964)
-- Name: Oggetti_ListaInformazioni Oggetti_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2596 (class 2606 OID 22966)
-- Name: Oggetti_ListaInformazioni Oggetti_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2598 (class 2606 OID 22968)
-- Name: Oggetti_ListaSchede Oggetti_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaSchede"
    ADD CONSTRAINT "Oggetti_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2600 (class 2606 OID 22970)
-- Name: Oggetti_ListaSchede Oggetti_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaSchede"
    ADD CONSTRAINT "Oggetti_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2602 (class 2606 OID 22972)
-- Name: Oggetti_RelazioniSchede Oggetti_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceOggetto", "CodiceTitolo");


--
-- TOC entry 2604 (class 2606 OID 22974)
-- Name: Oggetti_Schede Oggetti_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2554 (class 2606 OID 22976)
-- Name: OggettiSubVersion Oggetti_SubVersion-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-unicità" UNIQUE ("CodiceOggetto", "CodiceVersione", "SubVersion");


--
-- TOC entry 2556 (class 2606 OID 22978)
-- Name: OggettiSubVersion Oggetti_SubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2528 (class 2606 OID 22980)
-- Name: OggettiVersion Oggetti_Versioni-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-unicità" UNIQUE ("CodiceOggetto", "Versione");


--
-- TOC entry 2530 (class 2606 OID 22982)
-- Name: OggettiVersion Oggetti_Versioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2526 (class 2606 OID 22984)
-- Name: Oggetti Oggetti_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti"
    ADD CONSTRAINT "Oggetti_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2606 (class 2606 OID 22986)
-- Name: Settings Settings-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Settings"
    ADD CONSTRAINT "Settings-primaryKey" PRIMARY KEY ("Key");


--
-- TOC entry 2608 (class 2606 OID 22988)
-- Name: Utenti Utenti_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Utenti"
    ADD CONSTRAINT "Utenti_primaryKey" PRIMARY KEY ("User");


--
-- TOC entry 2609 (class 2606 OID 22989)
-- Name: Categorie CategorieCodiceGruppo-refGruppiCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Categorie"
    ADD CONSTRAINT "CategorieCodiceGruppo-refGruppiCategorie" FOREIGN KEY ("CodiceGruppo") REFERENCES "public"."GruppiCategorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2610 (class 2606 OID 22994)
-- Name: Import Import_CodiceModelloRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Import"
    ADD CONSTRAINT "Import_CodiceModelloRef" FOREIGN KEY ("CodiceModello") REFERENCES "public"."Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2611 (class 2606 OID 22999)
-- Name: Import Import_CodiceOggettoRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Import"
    ADD CONSTRAINT "Import_CodiceOggettoRef" FOREIGN KEY ("CodiceOggetto") REFERENCES "public"."Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2612 (class 2606 OID 23004)
-- Name: Import Import_CodiceOggettoVersioneRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Import"
    ADD CONSTRAINT "Import_CodiceOggettoVersioneRef" FOREIGN KEY ("CodiceVersione") REFERENCES "public"."OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2613 (class 2606 OID 23009)
-- Name: Import Import_UserRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Import"
    ADD CONSTRAINT "Import_UserRef" FOREIGN KEY ("User") REFERENCES "public"."Utenti"("User") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2614 (class 2606 OID 23014)
-- Name: InterventiSubVersion_CategorieSchede InterventiSubVersion_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_CategorieSchede"
    ADD CONSTRAINT "InterventiSubVersion_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "public"."Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2615 (class 2606 OID 23019)
-- Name: InterventiSubVersion_CategorieSchede InterventiSubVersion_CategorieSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_CategorieSchede"
    ADD CONSTRAINT "InterventiSubVersion_CategorieSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "public"."InterventiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2616 (class 2606 OID 23024)
-- Name: InterventiSubVersion_InfoComboBox InterventiSubVersion_InfoComboBox-refSubVersion_ListaInformazio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_InfoComboBox"
    ADD CONSTRAINT "InterventiSubVersion_InfoComboBox-refSubVersion_ListaInformazio" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."InterventiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2617 (class 2606 OID 23029)
-- Name: InterventiSubVersion_ListaInformazioni InterventiSubVersion_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "InterventiSubVersion_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."InterventiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2618 (class 2606 OID 23034)
-- Name: InterventiSubVersion_Relazioni InterventiSubVersion_Relazioni-Figlio_RefOggettiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-Figlio_RefOggettiSubVersion" FOREIGN KEY ("Figlio") REFERENCES "public"."OggettiSubVersion"("Codice");


--
-- TOC entry 2619 (class 2606 OID 23039)
-- Name: InterventiSubVersion_Relazioni InterventiSubVersion_Relazioni-Intervento_RefInterventiiSubVers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-Intervento_RefInterventiiSubVers" FOREIGN KEY ("Intervento") REFERENCES "public"."InterventiSubVersion"("Codice");


--
-- TOC entry 2620 (class 2606 OID 23044)
-- Name: InterventiSubVersion_Relazioni InterventiSubVersion_Relazioni-Padre_RefOggettiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-Padre_RefOggettiSubVersion" FOREIGN KEY ("Padre") REFERENCES "public"."OggettiSubVersion"("Codice");


--
-- TOC entry 2621 (class 2606 OID 23049)
-- Name: InterventiSubVersion_RelazioniSchede InterventiSubVersion_RelazioniSchede_refInterventiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "InterventiSubVersion_RelazioniSchede_refInterventiSubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "public"."InterventiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2622 (class 2606 OID 23054)
-- Name: InterventiSubVersion_RelazioniSchede InterventiSubVersion_RelazioniSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "InterventiSubVersion_RelazioniSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."InterventiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2623 (class 2606 OID 23059)
-- Name: InterventiSubVersion_Schede InterventiSubVersion_Schede_refSubVersion_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Schede"
    ADD CONSTRAINT "InterventiSubVersion_Schede_refSubVersion_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "public"."InterventiSubVersion_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2624 (class 2606 OID 23064)
-- Name: InterventiSubVersion_Schede InterventiSubVersion_Schede_refSubVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."InterventiSubVersion_Schede"
    ADD CONSTRAINT "InterventiSubVersion_Schede_refSubVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."InterventiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2629 (class 2606 OID 23069)
-- Name: MaterialeInterventiSubVersion MaterialeInterventiSubVersion_Verifica_Codice_SubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeInterventiSubVersion"
    ADD CONSTRAINT "MaterialeInterventiSubVersion_Verifica_Codice_SubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "public"."InterventiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2631 (class 2606 OID 23074)
-- Name: MaterialeSubVersion MaterialeSubVersion_Verifica_Codice_SubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeSubVersion"
    ADD CONSTRAINT "MaterialeSubVersion_Verifica_Codice_SubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "public"."OggettiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2632 (class 2606 OID 23079)
-- Name: MaterialeVersioni MaterialeVersioni_Verifica_Codice_Versione; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeVersioni"
    ADD CONSTRAINT "MaterialeVersioni_Verifica_Codice_Versione" FOREIGN KEY ("CodiceVersione") REFERENCES "public"."OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2633 (class 2606 OID 23084)
-- Name: Modelli3D_3dm Modelli3D_3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "public"."Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2634 (class 2606 OID 23089)
-- Name: Modelli3D_3dm_Backup Modelli3D_3dm_Backup-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_3dm_Backup"
    ADD CONSTRAINT "Modelli3D_3dm_Backup-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "public"."Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2635 (class 2606 OID 23094)
-- Name: Modelli3D_HotSpotColor Modelli3D_HotSpotColor-refModelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_HotSpotColor"
    ADD CONSTRAINT "Modelli3D_HotSpotColor-refModelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "public"."Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2625 (class 2606 OID 23099)
-- Name: Modelli3D_LoD Modelli3D_LoD-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "public"."Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2636 (class 2606 OID 23104)
-- Name: Modelli3D_JSON Modelli3D_OggettiJSON-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3D_OggettiJSON-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "public"."Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2637 (class 2606 OID 23109)
-- Name: Modelli3D_OBJ Modelli3D_OggettiOBJ-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_OBJ"
    ADD CONSTRAINT "Modelli3D_OggettiOBJ-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "public"."Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2638 (class 2606 OID 23114)
-- Name: Modelli3D_Texture Modelli3D_Texture-refCodiceModello; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Texture-refCodiceModello" FOREIGN KEY ("CodiceModello") REFERENCES "public"."Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2641 (class 2606 OID 23119)
-- Name: OggettiSubVersion_CategorieSchede OggettiSubVersion_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "public"."Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2642 (class 2606 OID 23124)
-- Name: OggettiSubVersion_CategorieSchede OggettiSubVersion_CategorieSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "public"."OggettiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2643 (class 2606 OID 23129)
-- Name: OggettiSubVersion_InfoComboBox OggettiSubVersion_InfoComboBox-refSubVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiSubVersion_InfoComboBox-refSubVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."OggettiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2644 (class 2606 OID 23134)
-- Name: OggettiSubVersion_ListaInformazioni OggettiSubVersion_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."OggettiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2645 (class 2606 OID 23139)
-- Name: OggettiSubVersion_RelazioniSchede OggettiSubVersion_RelazioniSchede_refOggettiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_refOggettiSubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "public"."OggettiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2646 (class 2606 OID 23144)
-- Name: OggettiSubVersion_RelazioniSchede OggettiSubVersion_RelazioniSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."OggettiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2647 (class 2606 OID 23149)
-- Name: OggettiSubVersion_Schede OggettiSubVersion_Schede_refSubVersion_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_refSubVersion_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "public"."OggettiSubVersion_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2648 (class 2606 OID 23154)
-- Name: OggettiSubVersion_Schede OggettiSubVersion_Schede_refSubVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_refSubVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."OggettiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2649 (class 2606 OID 23159)
-- Name: OggettiVersion_CategorieSchede OggettiVersion_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "public"."Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2650 (class 2606 OID 23164)
-- Name: OggettiVersion_CategorieSchede OggettiVersion_CategorieSchede_refOggettiVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_refOggettiVersion_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "public"."OggettiVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2651 (class 2606 OID 23169)
-- Name: OggettiVersion_InfoComboBox OggettiVersion_InfoComboBox-refOggettiVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiVersion_InfoComboBox-refOggettiVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."OggettiVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2652 (class 2606 OID 23174)
-- Name: OggettiVersion_ListaInformazioni OggettiVersion_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."OggettiVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2653 (class 2606 OID 23179)
-- Name: OggettiVersion_RelazioniSchede OggettiVersion_RelazioniSchede_refOggettiVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_refOggettiVersion" FOREIGN KEY ("CodiceVersione") REFERENCES "public"."OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2654 (class 2606 OID 23184)
-- Name: OggettiVersion_RelazioniSchede OggettiVersion_RelazioniSchede_refOggettiVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_refOggettiVersion_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."OggettiVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2655 (class 2606 OID 23189)
-- Name: OggettiVersion_Schede OggettiVersion_Schede_refOggettiVersion_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_refOggettiVersion_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "public"."OggettiVersion_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2656 (class 2606 OID 23194)
-- Name: OggettiVersion_Schede OggettiVersion_Schede_refOggettiVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_refOggettiVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."OggettiVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2657 (class 2606 OID 23199)
-- Name: Oggetti_CategorieSchede Oggetti_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "public"."Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2658 (class 2606 OID 23204)
-- Name: Oggetti_CategorieSchede Oggetti_CategorieSchede_refOggetti_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_refOggetti_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "public"."Oggetti_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2659 (class 2606 OID 23209)
-- Name: Oggetti_InfoComboBox Oggetti_InfoComboBox-refOggetti_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_InfoComboBox"
    ADD CONSTRAINT "Oggetti_InfoComboBox-refOggetti_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."Oggetti_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2660 (class 2606 OID 23214)
-- Name: Oggetti_ListaInformazioni Oggetti_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."Oggetti_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2661 (class 2606 OID 23219)
-- Name: Oggetti_RelazioniSchede Oggetti_RelazioniSchede_refOggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_refOggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "public"."Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2662 (class 2606 OID 23224)
-- Name: Oggetti_RelazioniSchede Oggetti_RelazioniSchede_refOggetti_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_refOggetti_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "public"."Oggetti_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2663 (class 2606 OID 23229)
-- Name: Oggetti_Schede Oggetti_Schede_refOggetti_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_refOggetti_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "public"."Oggetti_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2664 (class 2606 OID 23234)
-- Name: Oggetti_Schede Oggetti_Schede_refOggetti_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_refOggetti_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "public"."Oggetti_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2639 (class 2606 OID 23239)
-- Name: OggettiSubVersion Oggetti_SubVersion-keu-Oggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-keu-Oggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "public"."Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2640 (class 2606 OID 23244)
-- Name: OggettiSubVersion Oggetti_SubVersion-key-Oggetti_Versioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-key-Oggetti_Versioni" FOREIGN KEY ("CodiceVersione") REFERENCES "public"."OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2627 (class 2606 OID 23249)
-- Name: OggettiVersion Oggetti_Versioni-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "public"."Modelli3D"("Codice") ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 2628 (class 2606 OID 23254)
-- Name: OggettiVersion Oggetti_Versioni-key-Oggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key-Oggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "public"."Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2626 (class 2606 OID 23259)
-- Name: Oggetti Oggetti_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."Oggetti"
    ADD CONSTRAINT "Oggetti_refCategorie" FOREIGN KEY ("Categoria") REFERENCES "public"."Categorie"("Codice") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2630 (class 2606 OID 23264)
-- Name: MaterialeOggetti Verifica_Codice_oggetto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."MaterialeOggetti"
    ADD CONSTRAINT "Verifica_Codice_oggetto" FOREIGN KEY ("CodiceOggetto") REFERENCES "public"."Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2019-01-28 14:13:01 CET

--
-- PostgreSQL database dump complete
--

