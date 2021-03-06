--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.18
-- Dumped by pg_dump version 9.5.5

-- Started on 2018-09-04 13:19:55

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2672 (class 0 OID 0)
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
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION "plpgsql"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "plpgsql" IS 'PL/pgSQL procedural language';


SET search_path = "public", pg_catalog;

--
-- TOC entry 262 (class 1255 OID 714493)
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
-- TOC entry 317 (class 1255 OID 759644)
-- Name: addinterventosubversion("text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "addinterventosubversion"("codicepadriversion" "text", "utente" "text") RETURNS "text"
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
-- TOC entry 264 (class 1255 OID 714495)
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
-- TOC entry 265 (class 1255 OID 714496)
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
-- TOC entry 266 (class 1255 OID 714497)
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
-- TOC entry 292 (class 1255 OID 755708)
-- Name: deleteobject(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteobject"("codiceoggetto" bigint) RETURNS "text"
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
-- TOC entry 281 (class 1255 OID 716831)
-- Name: deleteoggettiinfo(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteoggettiinfo"("codicescheda" bigint, "codicecampo" integer) RETURNS "text"
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
-- TOC entry 263 (class 1255 OID 772170)
-- Name: deleteoggettisubversioninfo(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteoggettisubversioninfo"("codicescheda" bigint, "codicecampo" integer) RETURNS "text"
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
-- TOC entry 282 (class 1255 OID 716832)
-- Name: deleteoggettiversioninfo(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "deleteoggettiversioninfo"("codicescheda" bigint, "codicecampo" integer) RETURNS "text"
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
-- TOC entry 267 (class 1255 OID 714500)
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
-- TOC entry 268 (class 1255 OID 714501)
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
-- TOC entry 269 (class 1255 OID 714502)
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
-- TOC entry 270 (class 1255 OID 714503)
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
-- TOC entry 271 (class 1255 OID 714504)
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
-- TOC entry 303 (class 1255 OID 727736)
-- Name: preinitializenewhotspot("text", "text", "text", "text", "text", integer, double precision, double precision, double precision, double precision, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "preinitializenewhotspot"("layer0" "text", "layer1" "text", "layer2" "text", "layer3" "text", "nome" "text", "versione" integer, "xcentro" double precision, "ycentro" double precision, "zcentro" double precision, "raggio" double precision, "category" integer, "username" "text") RETURNS "text"
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
-- TOC entry 272 (class 1255 OID 714505)
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
-- TOC entry 273 (class 1255 OID 714506)
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
-- TOC entry 300 (class 1255 OID 727007)
-- Name: setoggettiinfocombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
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
-- TOC entry 308 (class 1255 OID 744753)
-- Name: setoggettiinfomulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 299 (class 1255 OID 727006)
-- Name: setoggettiinfoschedacombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedacombovalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
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
-- TOC entry 309 (class 1255 OID 744755)
-- Name: setoggettiinfoschedamulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedamulticombovalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 288 (class 1255 OID 726986)
-- Name: setoggettiinfoschedavalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
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
-- TOC entry 291 (class 1255 OID 726984)
-- Name: setoggettiinfoschedavalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
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
-- TOC entry 289 (class 1255 OID 726987)
-- Name: setoggettiinfoschedavalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
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
-- TOC entry 290 (class 1255 OID 726982)
-- Name: setoggettiinfoschedavalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 287 (class 1255 OID 726985)
-- Name: setoggettiinfoschedavalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfoschedavalue"("codiceoggetto" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
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
-- TOC entry 283 (class 1255 OID 726988)
-- Name: setoggettiinfovalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
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
-- TOC entry 284 (class 1255 OID 726989)
-- Name: setoggettiinfovalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
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
-- TOC entry 286 (class 1255 OID 726990)
-- Name: setoggettiinfovalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
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
-- TOC entry 285 (class 1255 OID 726983)
-- Name: setoggettiinfovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 293 (class 1255 OID 726991)
-- Name: setoggettiinfovalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
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
-- TOC entry 315 (class 1255 OID 772153)
-- Name: setoggettisubversioninfocombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
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
-- TOC entry 316 (class 1255 OID 772155)
-- Name: setoggettisubversioninfomulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 325 (class 1255 OID 772176)
-- Name: setoggettisubversioninfoschedacombovalue(bigint, integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedacombovalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" bigint) RETURNS "text"
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
-- TOC entry 326 (class 1255 OID 772177)
-- Name: setoggettisubversioninfoschedamulticombovalue(bigint, integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedamulticombovalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 323 (class 1255 OID 772174)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" boolean) RETURNS "text"
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
-- TOC entry 321 (class 1255 OID 772171)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" real) RETURNS "text"
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
-- TOC entry 322 (class 1255 OID 772173)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" integer) RETURNS "text"
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
-- TOC entry 324 (class 1255 OID 772175)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 320 (class 1255 OID 772172)
-- Name: setoggettisubversioninfoschedavalue(bigint, integer, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfoschedavalue"("codiceversione" bigint, "subversion" integer, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
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
-- TOC entry 319 (class 1255 OID 772169)
-- Name: setoggettisubversioninfovalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
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
-- TOC entry 318 (class 1255 OID 772167)
-- Name: setoggettisubversioninfovalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
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
-- TOC entry 314 (class 1255 OID 772165)
-- Name: setoggettisubversioninfovalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
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
-- TOC entry 327 (class 1255 OID 772178)
-- Name: setoggettisubversioninfovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 313 (class 1255 OID 772166)
-- Name: setoggettisubversioninfovalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettisubversioninfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
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
-- TOC entry 305 (class 1255 OID 727013)
-- Name: setoggettiversioniinfocombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfocombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
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
-- TOC entry 311 (class 1255 OID 744756)
-- Name: setoggettiversioniinfomulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfomulticombovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 301 (class 1255 OID 727005)
-- Name: setoggettiversioniinfoschedacombovalue(bigint, integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedacombovalue"("codiceversione" bigint, "codicecampo" integer, "valore" bigint) RETURNS "text"
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
-- TOC entry 312 (class 1255 OID 744757)
-- Name: setoggettiversioniinfoschedamulticombovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedamulticombovalue"("codiceversione" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 298 (class 1255 OID 726999)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
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
-- TOC entry 294 (class 1255 OID 727001)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
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
-- TOC entry 296 (class 1255 OID 727003)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
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
-- TOC entry 297 (class 1255 OID 727002)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 295 (class 1255 OID 727000)
-- Name: setoggettiversioniinfoschedavalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfoschedavalue"("codiceversione" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
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
-- TOC entry 310 (class 1255 OID 727011)
-- Name: setoggettiversioniinfovalue(bigint, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" boolean) RETURNS "text"
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
-- TOC entry 307 (class 1255 OID 727008)
-- Name: setoggettiversioniinfovalue(bigint, integer, real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" real) RETURNS "text"
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
-- TOC entry 304 (class 1255 OID 727009)
-- Name: setoggettiversioniinfovalue(bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" integer) RETURNS "text"
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
-- TOC entry 306 (class 1255 OID 727012)
-- Name: setoggettiversioniinfovalue(bigint, integer, "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" "text") RETURNS "text"
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
-- TOC entry 302 (class 1255 OID 727010)
-- Name: setoggettiversioniinfovalue(bigint, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "setoggettiversioniinfovalue"("codicescheda" bigint, "codicecampo" integer, "valore" timestamp with time zone) RETURNS "text"
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
-- TOC entry 274 (class 1255 OID 714531)
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
-- TOC entry 275 (class 1255 OID 714532)
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
-- TOC entry 276 (class 1255 OID 714533)
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
-- TOC entry 277 (class 1255 OID 714534)
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
-- TOC entry 278 (class 1255 OID 714535)
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
-- TOC entry 279 (class 1255 OID 714536)
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
-- TOC entry 280 (class 1255 OID 714537)
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
-- TOC entry 175 (class 1259 OID 714538)
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
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 175
-- Name: TABLE "Cantieri"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Cantieri" IS 'Tabella contenente l''elenco dei cantieri';


--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Cantieri"."Layer0"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Layer0" IS 'Layer0 del cantiere';


--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Cantieri"."Numero"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Numero" IS 'Numero progressivo del cantiere (0 iniziale)';


--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Cantieri"."DataInizio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataInizio" IS 'Data apertura del cantiere';


--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Cantieri"."DataFine"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."DataFine" IS 'Data chiusura del cantiere';


--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 175
-- Name: COLUMN "Cantieri"."Note"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Cantieri"."Note" IS 'Campo note sul cantiere';


--
-- TOC entry 176 (class 1259 OID 714544)
-- Name: Categorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Categorie" (
    "Codice" integer NOT NULL,
    "Nome" character varying(255) NOT NULL,
    "ColorR" real DEFAULT 1 NOT NULL,
    "ColorG" real DEFAULT 0 NOT NULL,
    "ColorB" real DEFAULT 0 NOT NULL,
    "ColorA" real DEFAULT 0.6 NOT NULL,
    "CodiceGruppo" integer NOT NULL
);


ALTER TABLE "Categorie" OWNER TO "postgres";

--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE "Categorie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Categorie" IS 'Lista delle categorie';


--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Categorie"."Nome"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."Nome" IS 'Titolo delle categorie';


--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Categorie"."ColorR"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."ColorR" IS 'Colore red';


--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Categorie"."ColorG"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."ColorG" IS 'Colore green';


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Categorie"."ColorB"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."ColorB" IS 'Colore blue';


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Categorie"."ColorA"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."ColorA" IS 'Canale Alpha del colore';


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN "Categorie"."CodiceGruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Categorie"."CodiceGruppo" IS 'Codice del gruppo della categoria';


--
-- TOC entry 177 (class 1259 OID 714547)
-- Name: Categorie_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Categorie_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Categorie_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 177
-- Name: Categorie_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Categorie_Codice_seq" OWNED BY "Categorie"."Codice";


--
-- TOC entry 178 (class 1259 OID 714549)
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
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE "FileExtra"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "FileExtra" IS 'Tabella contenente tutto il materiale (file) aggiuntivo';


--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Filename" IS 'Percorso relativo del file';


--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Tipo" IS 'Tipo del file';


--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."TipoRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."TipoRiferimento" IS 'Associazione alla "colonna" a cui il riferimento è associato';


--
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."ValoreRiferimento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."ValoreRiferimento" IS 'Riferimento';


--
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Qualità" IS '0 -> originale

2 -> ridimensionamento leggero (1600)

7 -> thumbs (192)';


--
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."file" IS 'File (memorizzato come bytea)';


--
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."DataScatto" IS 'Data dello scatto';


--
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Descrizione" IS 'Descrizione dle materiale';


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)';


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)';


--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Permessi_lvl3" IS 'Permessi livello 3 - pubblico (museo)';


--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Proprietario" IS 'Proprietario del file';


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."Gruppo" IS 'Gruppo di proprietà del file';


--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."LastModified"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastModified" IS 'Data dell''ultima modifica del file';


--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN "FileExtra"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "FileExtra"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 233 (class 1259 OID 721350)
-- Name: GruppiCategorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "GruppiCategorie" (
    "Codice" integer NOT NULL,
    "Nome" character varying(255) NOT NULL
);


ALTER TABLE "GruppiCategorie" OWNER TO "postgres";

--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE "GruppiCategorie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "GruppiCategorie" IS 'Gruppi delle categorie';


--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN "GruppiCategorie"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "GruppiCategorie"."Codice" IS 'Codice del gruppo';


--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN "GruppiCategorie"."Nome"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "GruppiCategorie"."Nome" IS 'Nome';


--
-- TOC entry 232 (class 1259 OID 721348)
-- Name: GruppiCategorie_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "GruppiCategorie_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "GruppiCategorie_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 232
-- Name: GruppiCategorie_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "GruppiCategorie_Codice_seq" OWNED BY "GruppiCategorie"."Codice";


--
-- TOC entry 179 (class 1259 OID 714560)
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
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 179
-- Name: TABLE "Import"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Import" IS 'Tabella contenente le liste di importazione degli utenti';


--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."User" IS 'Nome dell''utente';


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceOggetto" IS 'Codice dell''oggetto da importare';


--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceVersione" IS 'Codice dell''oggetto+versione da importare';


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."CodiceModello" IS 'Codice del modello da importare';


--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."Colore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."Colore" IS 'Codice del colore da associare all''oggetto da importare';


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."readonly"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."readonly" IS 'Identifica se importato in sola lettura (o modifica)';


--
-- TOC entry 2716 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN "Import"."NewAdded"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Import"."NewAdded" IS 'Indica se è stato aggiunto alla lista di importazione e mai importato';


--
-- TOC entry 237 (class 1259 OID 756442)
-- Name: InterventiSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion" (
    "Codice" bigint NOT NULL,
    "Data" timestamp with time zone NOT NULL,
    "CreatedBy" character varying(255)
);


ALTER TABLE "InterventiSubVersion" OWNER TO "postgres";

--
-- TOC entry 2717 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN "InterventiSubVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion"."Codice" IS 'Codice dell''intervento';


--
-- TOC entry 2718 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN "InterventiSubVersion"."Data"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion"."Data" IS 'Data dell''intervento';


--
-- TOC entry 2719 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN "InterventiSubVersion"."CreatedBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion"."CreatedBy" IS 'Utente che ha creato l''intervento';


--
-- TOC entry 241 (class 1259 OID 756492)
-- Name: InterventiSubVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "InterventiSubVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2720 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN "InterventiSubVersion_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 236 (class 1259 OID 756440)
-- Name: InterventiSubVersion_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "InterventiSubVersion_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InterventiSubVersion_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 236
-- Name: InterventiSubVersion_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "InterventiSubVersion_Codice_seq" OWNED BY "InterventiSubVersion"."Codice";


--
-- TOC entry 245 (class 1259 OID 756536)
-- Name: InterventiSubVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "InterventiSubVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE "InterventiSubVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "InterventiSubVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN "InterventiSubVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN "InterventiSubVersion_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN "InterventiSubVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 244 (class 1259 OID 756534)
-- Name: InterventiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "InterventiSubVersion_InfoComboBox_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InterventiSubVersion_InfoComboBox_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 244
-- Name: InterventiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "InterventiSubVersion_InfoComboBox_Codice_seq" OWNED BY "InterventiSubVersion_InfoComboBox"."Codice";


--
-- TOC entry 243 (class 1259 OID 756509)
-- Name: InterventiSubVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_ListaInformazioni" (
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


ALTER TABLE "InterventiSubVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE "InterventiSubVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "InterventiSubVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli InterventiSubVersion e dei relativi campi';


--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 2729 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2730 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2731 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2732 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 2733 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2734 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2735 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2736 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2737 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2738 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 2739 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 2740 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2741 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2742 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN "InterventiSubVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 242 (class 1259 OID 756507)
-- Name: InterventiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "InterventiSubVersion_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InterventiSubVersion_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2743 (class 0 OID 0)
-- Dependencies: 242
-- Name: InterventiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "InterventiSubVersion_ListaInformazioni_Codice_seq" OWNED BY "InterventiSubVersion_ListaInformazioni"."Codice";


--
-- TOC entry 240 (class 1259 OID 756484)
-- Name: InterventiSubVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "InterventiSubVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2744 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE "InterventiSubVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "InterventiSubVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2745 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN "InterventiSubVersion_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 2746 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN "InterventiSubVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 2747 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN "InterventiSubVersion_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 239 (class 1259 OID 756482)
-- Name: InterventiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "InterventiSubVersion_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InterventiSubVersion_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2748 (class 0 OID 0)
-- Dependencies: 239
-- Name: InterventiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "InterventiSubVersion_ListaSchede_Codice_seq" OWNED BY "InterventiSubVersion_ListaSchede"."Codice";


--
-- TOC entry 238 (class 1259 OID 756448)
-- Name: InterventiSubVersion_Relazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_Relazioni" (
    "Intervento" bigint NOT NULL,
    "Padre" bigint NOT NULL,
    "Figlio" bigint
);


ALTER TABLE "InterventiSubVersion_Relazioni" OWNER TO "postgres";

--
-- TOC entry 2749 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE "InterventiSubVersion_Relazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "InterventiSubVersion_Relazioni" IS 'Tabella delle relazioni degli interventi sulle SubVersion';


--
-- TOC entry 2750 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "InterventiSubVersion_Relazioni"."Intervento"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Relazioni"."Intervento" IS 'Codice dell''intervento';


--
-- TOC entry 2751 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "InterventiSubVersion_Relazioni"."Padre"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Relazioni"."Padre" IS 'Codice della SubVersion padre';


--
-- TOC entry 2752 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN "InterventiSubVersion_Relazioni"."Figlio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Relazioni"."Figlio" IS 'Codice della SubVersion figlio';


--
-- TOC entry 248 (class 1259 OID 756567)
-- Name: InterventiSubVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_RelazioniSchede" (
    "CodiceSubVersion" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "InterventiSubVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2753 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE "InterventiSubVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "InterventiSubVersion_RelazioniSchede" IS 'Relazioni tra gli InterventiSubVersion e le schede informative';


--
-- TOC entry 2754 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceSubVersion" IS 'Codice dell''oggetto';


--
-- TOC entry 2755 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2756 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 247 (class 1259 OID 756565)
-- Name: InterventiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "InterventiSubVersion_RelazioniSchede_CodiceScheda_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "InterventiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNER TO "postgres";

--
-- TOC entry 2757 (class 0 OID 0)
-- Dependencies: 247
-- Name: InterventiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "InterventiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "InterventiSubVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 246 (class 1259 OID 756547)
-- Name: InterventiSubVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "InterventiSubVersion_Schede" (
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


ALTER TABLE "InterventiSubVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 2758 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE "InterventiSubVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "InterventiSubVersion_Schede" IS 'Informazioni testuali sugli InterventiSubVersion';


--
-- TOC entry 2759 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 2760 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 2761 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2762 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2763 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2764 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 2765 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 2766 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 2767 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN "InterventiSubVersion_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "InterventiSubVersion_Schede"."MultiComboValue" IS 'Valore del multi combobox';


--
-- TOC entry 180 (class 1259 OID 714564)
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
-- TOC entry 2768 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE "Modelli3D"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D" IS 'Tabella di riferimento per i Modelli 3D';


--
-- TOC entry 2769 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Modelli3D"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Codice" IS 'Codice del Modello 3D (diverso dal codice dell''oggetto!!!) - PRIMARY KEY';


--
-- TOC entry 2770 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Modelli3D"."Type"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Type" IS '0 -> Mesh
1 -> Point Cloud
2 -> HotSpot';


--
-- TOC entry 2771 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Modelli3D"."Superficie"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Superficie" IS 'Superficie dell''oggetto (calcolata dal modello 3D)';


--
-- TOC entry 2772 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Modelli3D"."Volume"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."Volume" IS 'Volume dell''oggetto (calcolato dal modello 3D)';


--
-- TOC entry 2773 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Modelli3D"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2774 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN "Modelli3D"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 181 (class 1259 OID 714569)
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
-- TOC entry 2775 (class 0 OID 0)
-- Dependencies: 181
-- Name: TABLE "Modelli3D_LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_LoD" IS 'Tabella di riferimento per i livelli di dettaglio dei Modelli 3D';


--
-- TOC entry 2776 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."CodiceModello" IS 'Riferimento al codice del Modello 3D';


--
-- TOC entry 2777 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."LoD" IS 'Level of Detail del modello 3D';


--
-- TOC entry 2778 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."xc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."xc" IS 'Coordinata x del centro';


--
-- TOC entry 2779 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."yc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."yc" IS 'Coordinata y del centro';


--
-- TOC entry 2780 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."zc"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."zc" IS 'Coordinata z del centro';


--
-- TOC entry 2781 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."Radius"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Radius" IS 'Raggio del bounding box sferico';


--
-- TOC entry 2782 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."Texture" IS 'Specifica se è stata inserita una texture';


--
-- TOC entry 2783 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm" IS 'Indica se è stato inserito nel database il file 3dm corrispondente';


--
-- TOC entry 2784 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."3dm_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm_Texture" IS 'Specifica se il modello 3dm contiene le informazioni per la texture';


--
-- TOC entry 2785 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."3dm_Backup"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."3dm_Backup" IS 'Indica se è presente nel database un backup per il file 3dm corrispondente';


--
-- TOC entry 2786 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON" IS 'Indica se è stato inserito nel database il file JSON corrispondente';


--
-- TOC entry 2787 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."JSON_NumeroParti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_NumeroParti" IS 'Qualora sia presente il file JSON, specifica in quanti parti viene suddiviso';


--
-- TOC entry 2788 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."JSON_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."JSON_Texture" IS 'Specifica se il modello JSON contiene le informazioni per la texture';


--
-- TOC entry 2789 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."OBJ"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."OBJ" IS 'Indica se è stato inserito nel database il file OBJ corrispondente';


--
-- TOC entry 2790 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN "Modelli3D_LoD"."HotSpot"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_LoD"."HotSpot" IS 'Indica se è stato inserito nel database le informazioni per l''HotSpot';


--
-- TOC entry 182 (class 1259 OID 714580)
-- Name: Oggetti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti" (
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


ALTER TABLE "Oggetti" OWNER TO "postgres";

--
-- TOC entry 2791 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE "Oggetti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2792 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Codice" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2793 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Layer0"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer0" IS 'Layer0 in cui è contenuto l''oggetto';


--
-- TOC entry 2794 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Layer1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer1" IS 'Layer1 in cui è contenuto l''oggetto';


--
-- TOC entry 2795 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Layer2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer2" IS 'Layer2 in cui è contenuto l''oggetto';


--
-- TOC entry 2796 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Layer3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Layer3" IS 'Layer3 in cui è contenuto l''oggetto';


--
-- TOC entry 2797 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Name"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Name" IS 'Nome utilizzato per disambiguare due oggetti appartenenti allo stesso Layer0 + Layer1 + Layer2 + Layer3';


--
-- TOC entry 2798 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Categoria"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Categoria" IS 'Codice della categoria dell''oggetto';


--
-- TOC entry 2799 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto';


--
-- TOC entry 2800 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto';


--
-- TOC entry 2801 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto';


--
-- TOC entry 2802 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto';


--
-- TOC entry 2803 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2804 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2805 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2806 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN "Oggetti"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 183 (class 1259 OID 714590)
-- Name: OggettiVersion; Type: TABLE; Schema: public; Owner: postgres
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
-- TOC entry 2807 (class 0 OID 0)
-- Dependencies: 183
-- Name: TABLE "OggettiVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2808 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Codice" IS 'Codice identificativo dell''oggetto+versione - PRIMARY KEY';


--
-- TOC entry 2809 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CodiceOggetto" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2810 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."Versione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Versione" IS 'Versione dell''oggetto, per identificare variazioni del modello dell''oggetto in seguito ad interventi o cambiamenti (DEFAULT 0)';


--
-- TOC entry 2811 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CodiceModello" IS 'Codice del modello 3D dell''oggetto+versione';


--
-- TOC entry 2812 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Originale" IS 'Se 0 è l''oggetto+versione originale, altrimenti è un oggetto modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2813 (class 0 OID 0)
-- Dependencies: 183
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
-- TOC entry 2814 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto+versione';


--
-- TOC entry 2815 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto+versione';


--
-- TOC entry 2816 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione';


--
-- TOC entry 2817 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione';


--
-- TOC entry 2818 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2819 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2820 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2821 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN "OggettiVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 234 (class 1259 OID 727726)
-- Name: ListaOggettiLoD; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "ListaOggettiLoD" AS
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
   FROM ((("Oggetti"
     JOIN "OggettiVersion" ON (("Oggetti"."Codice" = "OggettiVersion"."CodiceOggetto")))
     JOIN "Modelli3D" ON (("OggettiVersion"."CodiceModello" = "Modelli3D"."Codice")))
     JOIN "Modelli3D_LoD" ON (("OggettiVersion"."CodiceModello" = "Modelli3D_LoD"."CodiceModello")))
  WHERE ((("OggettiVersion"."Live" = 1) OR ("OggettiVersion"."Live" = 2)) AND ("OggettiVersion"."Updating" = false))
  ORDER BY "OggettiVersion"."Codice", "Modelli3D_LoD"."LoD";


ALTER TABLE "ListaOggettiLoD" OWNER TO "postgres";

--
-- TOC entry 184 (class 1259 OID 714608)
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
-- TOC entry 2822 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE "Log"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Log" IS 'Log degli errori';


--
-- TOC entry 2823 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Log"."DateTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."DateTime" IS 'Data e ora dell''evento';


--
-- TOC entry 2824 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Log"."Messaggio"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."Messaggio" IS 'Messaggio di log';


--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN "Log"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Log"."User" IS 'Utente che ha effettuato l''operazione';


--
-- TOC entry 185 (class 1259 OID 714614)
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
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 185
-- Name: Log_NumeroLog_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Log_NumeroLog_seq" OWNED BY "Log"."NumeroLog";


--
-- TOC entry 249 (class 1259 OID 756583)
-- Name: MaterialeInterventiSubVersion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "MaterialeInterventiSubVersion" (
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


ALTER TABLE "MaterialeInterventiSubVersion" OWNER TO "postgres";

--
-- TOC entry 2827 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE "MaterialeInterventiSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeInterventiSubVersion" IS 'Tabella contenente tutto il materiale (file) associato alle SubVersion';


--
-- TOC entry 2828 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."CodiceSubVersion" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2829 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."URL" IS 'URL del materiale';


--
-- TOC entry 2830 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2831 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2832 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2833 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2834 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2835 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2836 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2837 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2838 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2839 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2840 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN "MaterialeInterventiSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeInterventiSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 186 (class 1259 OID 714616)
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
-- TOC entry 2841 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE "MaterialeOggetti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeOggetti" IS 'Tabella contenente tutto il materiale (file) associato agli oggetti';


--
-- TOC entry 2842 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."CodiceOggetto" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2843 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."URL" IS 'URL del materiale';


--
-- TOC entry 2844 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2845 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2846 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2847 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2848 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2849 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2850 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2851 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2852 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2853 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2854 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN "MaterialeOggetti"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeOggetti"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 187 (class 1259 OID 714627)
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
-- TOC entry 2855 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE "MaterialeSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeSubVersion" IS 'Tabella contenente tutto il materiale (file) associato alle SubVersion';


--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."CodiceSubVersion" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2857 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."URL" IS 'URL del materiale';


--
-- TOC entry 2858 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2859 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2860 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2861 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2862 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2863 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2864 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2865 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2866 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2867 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2868 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN "MaterialeSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 188 (class 1259 OID 714638)
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
-- TOC entry 2869 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE "MaterialeVersioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "MaterialeVersioni" IS 'Tabella contenente tutto il materiale (file) associato alle versioni';


--
-- TOC entry 2870 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."CodiceVersione" IS 'Codice dell''oggetto a cui il materiale è associato';


--
-- TOC entry 2871 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."URL"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."URL" IS 'URL del materiale';


--
-- TOC entry 2872 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Tipo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Tipo" IS 'Tipo del file (es: immagine)';


--
-- TOC entry 2873 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Qualità" IS '0 -> originale
2 -> ridimensionamento leggero (1600)
7 -> thumbs (192)';


--
-- TOC entry 2874 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."file" IS 'File (i file materiali sono memorizzati nel db come bytea)';


--
-- TOC entry 2875 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Descrizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Descrizione" IS 'Descrizione';


--
-- TOC entry 2876 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."DataScatto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."DataScatto" IS 'Data dello scatto (se non disponibile dell''inserimento)';


--
-- TOC entry 2877 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl1"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Permessi_lvl1" IS 'Permesso livello 1 (proprietario)

Default: lettura&scrittura';


--
-- TOC entry 2878 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl2"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Permessi_lvl2" IS 'Permesso livello 2 (altri uffici)

Default: lettura';


--
-- TOC entry 2879 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Permessi_lvl3"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Permessi_lvl3" IS 'Permesso livello 3 (museo)

Default: nessuno';


--
-- TOC entry 2880 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Proprietario"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Proprietario" IS 'Informazioni proprietario del file';


--
-- TOC entry 2881 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."Gruppo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."Gruppo" IS 'gruppo di proprietà del file';


--
-- TOC entry 2882 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN "MaterialeVersioni"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "MaterialeVersioni"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 189 (class 1259 OID 714649)
-- Name: MaxCantieri; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "MaxCantieri" AS
 SELECT "Cantieri"."Layer0",
    "max"("Cantieri"."Numero") AS "num"
   FROM "Cantieri"
  GROUP BY "Cantieri"."Layer0";


ALTER TABLE "MaxCantieri" OWNER TO "postgres";

--
-- TOC entry 190 (class 1259 OID 714653)
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
-- TOC entry 2883 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE "Modelli3D_3dm"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm" IS 'Tabella contenente i file 3dm dei Modelli 3D';


--
-- TOC entry 2884 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "Modelli3D_3dm"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2885 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "Modelli3D_3dm"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2886 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "Modelli3D_3dm"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."file" IS 'File 3dm codificato in bytea';


--
-- TOC entry 2887 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "Modelli3D_3dm"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2888 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN "Modelli3D_3dm"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_3dm"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 191 (class 1259 OID 714661)
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
-- TOC entry 2889 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE "Modelli3D_3dm_Backup"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_3dm_Backup" IS 'Tabella contenente il backup dei  file 3dm dei Modelli 3D';


--
-- TOC entry 192 (class 1259 OID 714669)
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
-- TOC entry 2890 (class 0 OID 0)
-- Dependencies: 192
-- Name: Modelli3D_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Modelli3D_Codice_seq" OWNED BY "Modelli3D"."Codice";


--
-- TOC entry 193 (class 1259 OID 714671)
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
-- TOC entry 2891 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE "Modelli3D_HotSpotColor"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_HotSpotColor" IS 'Contiene i dati colore per gli hotspot';


--
-- TOC entry 2892 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "Modelli3D_HotSpotColor"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2893 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorR"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorR" IS 'Colore red';


--
-- TOC entry 2894 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorG"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorG" IS 'Colore green';


--
-- TOC entry 2895 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorB"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorB" IS 'Colore blue';


--
-- TOC entry 2896 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN "Modelli3D_HotSpotColor"."ColorA"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_HotSpotColor"."ColorA" IS 'Canale Alpha del colore';


--
-- TOC entry 194 (class 1259 OID 714678)
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
-- TOC entry 2897 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE "Modelli3D_JSON"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_JSON" IS 'Tabella contenente i file JSON dei Modelli 3D';


--
-- TOC entry 2898 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "Modelli3D_JSON"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2899 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "Modelli3D_JSON"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2900 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "Modelli3D_JSON"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."Parte" IS 'Parte del file JSON';


--
-- TOC entry 2901 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "Modelli3D_JSON"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."file" IS 'File JSON codificato in bytea';


--
-- TOC entry 2902 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "Modelli3D_JSON"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2903 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN "Modelli3D_JSON"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_JSON"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 195 (class 1259 OID 714685)
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
-- TOC entry 2904 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE "Modelli3D_OBJ"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_OBJ" IS 'Tabella contenente i file OBJ dei Modelli 3D';


--
-- TOC entry 2905 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "Modelli3D_OBJ"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."CodiceModello" IS 'Codice del Modello 3D';


--
-- TOC entry 2906 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "Modelli3D_OBJ"."LoD"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."LoD" IS 'Livello di dettaglio';


--
-- TOC entry 2907 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "Modelli3D_OBJ"."Parte"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."Parte" IS 'Parte del file OBJ';


--
-- TOC entry 2908 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "Modelli3D_OBJ"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."file" IS 'File OBJ codificato in bytea';


--
-- TOC entry 2909 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "Modelli3D_OBJ"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2910 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN "Modelli3D_OBJ"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_OBJ"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 196 (class 1259 OID 714692)
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
-- TOC entry 2911 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE "Modelli3D_Texture"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Modelli3D_Texture" IS 'Tabella contenente le texture dei modelli';


--
-- TOC entry 2912 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."CodiceModello"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."CodiceModello" IS 'Codice del Modello';


--
-- TOC entry 2913 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."TextureNumber"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."TextureNumber" IS 'Numero dell''indice della texture (se è una texture sola è 0)';


--
-- TOC entry 2914 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."Qualità"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."Qualità" IS '0 -> originale
1 -> 2048
2 -> 1024
3 -> 512
4 -> 256
5 -> 128
6 -> 64
7 -> 32';


--
-- TOC entry 2915 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."Filename"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."Filename" IS 'Nome del file';


--
-- TOC entry 2916 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."file"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."file" IS 'File salvato il bytea';


--
-- TOC entry 2917 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."MimeType"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."MimeType" IS 'MimeType del file';


--
-- TOC entry 2918 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."LastUpdate" IS 'Data dell''ultima modifica';


--
-- TOC entry 2919 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "Modelli3D_Texture"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Modelli3D_Texture"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 197 (class 1259 OID 714701)
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
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE "OggettiSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion" IS 'Tabella contenente gli oggetti (gli oggetti astratti, non i Modelli3D)';


--
-- TOC entry 2921 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Codice" IS 'Codice identificativo dell''oggetto+versione - PRIMARY KEY';


--
-- TOC entry 2922 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CodiceOggetto" IS 'Codice identificativo dell''oggetto - PRIMARY KEY';


--
-- TOC entry 2923 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CodiceVersione" IS 'Codice identificativo dell''oggetto+versione ';


--
-- TOC entry 2924 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."SubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."SubVersion" IS 'SubVersion dell''oggetto, per identificare variazioni in seguito ad interventi che non modificano il modello (DEFAULT 0)';


--
-- TOC entry 2925 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."Originale"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Originale" IS 'Se 0 è l''oggetto+versione originale, altrimenti è un oggetto modificato ed il campo contiene il Codice del padre da cui deriva';


--
-- TOC entry 2926 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."DataCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."DataCreazione" IS 'Data (e ora) di creazione dell''oggetto+versione+subversion';


--
-- TOC entry 2927 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."DataEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."DataEliminazione" IS 'Data (e ora) di eliminazione dell''oggetto+versione+subversion';


--
-- TOC entry 2928 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."CantiereCreazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CantiereCreazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione+subversion';


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."CantiereEliminazione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."CantiereEliminazione" IS 'Cantiere nel quale è stato creato l''oggetto+versione+subversion';


--
-- TOC entry 2930 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."Lock"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Lock" IS 'Lock del file dell''utente specificato (gli oggetti con il lock si possono aprire solo in sola lettura)';


--
-- TOC entry 2931 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."Updating"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."Updating" IS 'Oggetto in fase di aggiornamento (3dm, JSON, DB)';


--
-- TOC entry 2932 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."LastUpdate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."LastUpdate" IS 'Data e ora dell''ultimo aggiornamento';


--
-- TOC entry 2933 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "OggettiSubVersion"."LastUpdateBy"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion"."LastUpdateBy" IS 'Utente che ha effettuato l''ultimo aggiornamento';


--
-- TOC entry 198 (class 1259 OID 714714)
-- Name: OggettiSubVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "OggettiSubVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2934 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN "OggettiSubVersion_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 199 (class 1259 OID 714717)
-- Name: OggettiSubVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "OggettiSubVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2935 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE "OggettiSubVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2936 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2937 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 2938 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN "OggettiSubVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 200 (class 1259 OID 714720)
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
-- TOC entry 2939 (class 0 OID 0)
-- Dependencies: 200
-- Name: OggettiSubVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiSubVersion_InfoComboBox_Codice_seq" OWNED BY "OggettiSubVersion_InfoComboBox"."Codice";


--
-- TOC entry 201 (class 1259 OID 714722)
-- Name: OggettiSubVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_ListaInformazioni" (
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


ALTER TABLE "OggettiSubVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2940 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE "OggettiSubVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli OggettiSubVersion e dei relativi campi';


--
-- TOC entry 2941 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 2942 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2943 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2944 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2945 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 2946 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2947 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2948 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2949 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2950 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2951 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 2952 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 2953 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2954 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2955 (class 0 OID 0)
-- Dependencies: 201
-- Name: COLUMN "OggettiSubVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 202 (class 1259 OID 714737)
-- Name: OggettiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiSubVersion_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiSubVersion_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2956 (class 0 OID 0)
-- Dependencies: 202
-- Name: OggettiSubVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiSubVersion_ListaInformazioni_Codice_seq" OWNED BY "OggettiSubVersion_ListaInformazioni"."Codice";


--
-- TOC entry 203 (class 1259 OID 714739)
-- Name: OggettiSubVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "OggettiSubVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 2957 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE "OggettiSubVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 2958 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 2959 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 2960 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN "OggettiSubVersion_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 204 (class 1259 OID 714742)
-- Name: OggettiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiSubVersion_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiSubVersion_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2961 (class 0 OID 0)
-- Dependencies: 204
-- Name: OggettiSubVersion_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiSubVersion_ListaSchede_Codice_seq" OWNED BY "OggettiSubVersion_ListaSchede"."Codice";


--
-- TOC entry 205 (class 1259 OID 714744)
-- Name: OggettiSubVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_RelazioniSchede" (
    "CodiceSubVersion" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "OggettiSubVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 2962 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE "OggettiSubVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_RelazioniSchede" IS 'Relazioni tra gli OggettiSubVersion e le schede informative';


--
-- TOC entry 2963 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceSubVersion"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceSubVersion" IS 'Codice dell''oggetto';


--
-- TOC entry 2964 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2965 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 206 (class 1259 OID 714747)
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
-- TOC entry 2966 (class 0 OID 0)
-- Dependencies: 206
-- Name: OggettiSubVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiSubVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "OggettiSubVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 207 (class 1259 OID 714749)
-- Name: OggettiSubVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiSubVersion_Schede" (
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


ALTER TABLE "OggettiSubVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 2967 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE "OggettiSubVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiSubVersion_Schede" IS 'Informazioni testuali sugli OggettiSubVersion';


--
-- TOC entry 2968 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 2969 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 2970 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 2971 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 2972 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 2973 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 2974 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 2975 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 2976 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN "OggettiSubVersion_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiSubVersion_Schede"."MultiComboValue" IS 'Valore del multi combobox';


--
-- TOC entry 208 (class 1259 OID 714755)
-- Name: OggettiVersion_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "OggettiVersion_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 2977 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN "OggettiVersion_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 209 (class 1259 OID 714758)
-- Name: OggettiVersion_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "OggettiVersion_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 2978 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE "OggettiVersion_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 2979 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "OggettiVersion_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 2980 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "OggettiVersion_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 209
-- Name: COLUMN "OggettiVersion_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 210 (class 1259 OID 714761)
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
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 210
-- Name: OggettiVersion_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiVersion_InfoComboBox_Codice_seq" OWNED BY "OggettiVersion_InfoComboBox"."Codice";


--
-- TOC entry 211 (class 1259 OID 714763)
-- Name: OggettiVersion_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_ListaInformazioni" (
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


ALTER TABLE "OggettiVersion_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE "OggettiVersion_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli OggettiVersion e dei relativi campi';


--
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 2985 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 2987 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN "OggettiVersion_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 212 (class 1259 OID 714778)
-- Name: OggettiVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiVersion_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiVersion_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 212
-- Name: OggettiVersion_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiVersion_ListaInformazioni_Codice_seq" OWNED BY "OggettiVersion_ListaInformazioni"."Codice";


--
-- TOC entry 213 (class 1259 OID 714780)
-- Name: OggettiVersion_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "OggettiVersion_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE "OggettiVersion_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 3001 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "OggettiVersion_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 3002 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "OggettiVersion_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 3003 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN "OggettiVersion_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 214 (class 1259 OID 714783)
-- Name: OggettiVersion_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "OggettiVersion_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "OggettiVersion_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3004 (class 0 OID 0)
-- Dependencies: 214
-- Name: OggettiVersion_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiVersion_ListaSchede_Codice_seq" OWNED BY "OggettiVersion_ListaSchede"."Codice";


--
-- TOC entry 215 (class 1259 OID 714785)
-- Name: OggettiVersion_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_RelazioniSchede" (
    "CodiceVersione" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "OggettiVersion_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 3005 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE "OggettiVersion_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_RelazioniSchede" IS 'Relazioni tra gli OggettiVersion e le schede informative';


--
-- TOC entry 3006 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceVersione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_RelazioniSchede"."CodiceVersione" IS 'Codice dell''oggetto';


--
-- TOC entry 3007 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3008 (class 0 OID 0)
-- Dependencies: 215
-- Name: COLUMN "OggettiVersion_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 216 (class 1259 OID 714788)
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
-- TOC entry 3009 (class 0 OID 0)
-- Dependencies: 216
-- Name: OggettiVersion_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "OggettiVersion_RelazioniSchede_CodiceScheda_seq" OWNED BY "OggettiVersion_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 217 (class 1259 OID 714790)
-- Name: OggettiVersion_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OggettiVersion_Schede" (
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


ALTER TABLE "OggettiVersion_Schede" OWNER TO "postgres";

--
-- TOC entry 3010 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE "OggettiVersion_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "OggettiVersion_Schede" IS 'Informazioni testuali sugli OggettiVersion';


--
-- TOC entry 3011 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 3012 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 3013 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 3014 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 3015 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 3016 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 3017 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 3018 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN "OggettiVersion_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "OggettiVersion_Schede"."MultiComboValue" IS 'Valore del multi combobox';


--
-- TOC entry 218 (class 1259 OID 714796)
-- Name: Oggetti_CategorieSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_CategorieSchede" (
    "CodiceCategoria" integer NOT NULL,
    "CodiceScheda" integer NOT NULL
);


ALTER TABLE "Oggetti_CategorieSchede" OWNER TO "postgres";

--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN "Oggetti_CategorieSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_CategorieSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 219 (class 1259 OID 714799)
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
-- TOC entry 3021 (class 0 OID 0)
-- Dependencies: 219
-- Name: Oggetti_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_Codice_seq" OWNED BY "Oggetti"."Codice";


--
-- TOC entry 220 (class 1259 OID 714801)
-- Name: Oggetti_InfoComboBox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_InfoComboBox" (
    "Codice" bigint NOT NULL,
    "CodiceCampo" integer NOT NULL,
    "Value" character varying(255)
);


ALTER TABLE "Oggetti_InfoComboBox" OWNER TO "postgres";

--
-- TOC entry 3022 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE "Oggetti_InfoComboBox"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_InfoComboBox" IS 'Tabella che contiene i valori dei campi ComboBox';


--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Oggetti_InfoComboBox"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."Codice" IS 'Codice del campo';


--
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Oggetti_InfoComboBox"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."CodiceCampo" IS 'Codice del campo a cui si riferisce il ComboBox';


--
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN "Oggetti_InfoComboBox"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_InfoComboBox"."Value" IS 'Valore del campo';


--
-- TOC entry 221 (class 1259 OID 714804)
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
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 221
-- Name: Oggetti_InfoComboBox_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_InfoComboBox_Codice_seq" OWNED BY "Oggetti_InfoComboBox"."Codice";


--
-- TOC entry 222 (class 1259 OID 714806)
-- Name: Oggetti_ListaInformazioni; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_ListaInformazioni" (
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


ALTER TABLE "Oggetti_ListaInformazioni" OWNER TO "postgres";

--
-- TOC entry 3027 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE "Oggetti_ListaInformazioni"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_ListaInformazioni" IS 'Elenco delle schedee dei campi di informazioni sugli oggetti e dei relativi campi';


--
-- TOC entry 3028 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Codice" IS 'Codice del campo informazioni';


--
-- TOC entry 3029 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3030 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."Campo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Campo" IS 'Nome del campo';


--
-- TOC entry 3031 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsTitle"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsTitle" IS 'Specifica se il campo è un titolo';


--
-- TOC entry 3032 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsLink"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsLink" IS 'Specifica se il campo è un link';


--
-- TOC entry 3033 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsBool"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsBool" IS 'Specifica se il campo è booleano';


--
-- TOC entry 3034 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsInt"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsInt" IS 'Specifica se il campo è integer';


--
-- TOC entry 3035 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsReal"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsReal" IS 'Specifica se il campo è real';


--
-- TOC entry 3036 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsText"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsText" IS 'Specifica se il campo è text';


--
-- TOC entry 3037 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsTimestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsTimestamp" IS 'Specifica se il campo è timestamp';


--
-- TOC entry 3038 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsCombo" IS 'Specifica se il campo è un combobox';


--
-- TOC entry 3039 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsMultiCombo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsMultiCombo" IS 'Specifica se il campo è un combobox a scelta multipla';


--
-- TOC entry 3040 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."IsSeparator"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."IsSeparator" IS 'Specifica se il campo è un separator';


--
-- TOC entry 3041 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Posizione" IS 'Posizione del campo nella scheda';


--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN "Oggetti_ListaInformazioni"."Height"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaInformazioni"."Height" IS 'Specifica l''altezza del campo';


--
-- TOC entry 223 (class 1259 OID 714821)
-- Name: Oggetti_ListaInformazioni_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_ListaInformazioni_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_ListaInformazioni_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3043 (class 0 OID 0)
-- Dependencies: 223
-- Name: Oggetti_ListaInformazioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_ListaInformazioni_Codice_seq" OWNED BY "Oggetti_ListaInformazioni"."Codice";


--
-- TOC entry 224 (class 1259 OID 714823)
-- Name: Oggetti_ListaSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_ListaSchede" (
    "Codice" integer NOT NULL,
    "Titolo" character varying(255) NOT NULL,
    "Posizione" integer
);


ALTER TABLE "Oggetti_ListaSchede" OWNER TO "postgres";

--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE "Oggetti_ListaSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_ListaSchede" IS 'Lista delle schede';


--
-- TOC entry 3045 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "Oggetti_ListaSchede"."Codice"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaSchede"."Codice" IS 'Codice riferito al titolo della scheda';


--
-- TOC entry 3046 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "Oggetti_ListaSchede"."Titolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaSchede"."Titolo" IS 'Titolo delle schede';


--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN "Oggetti_ListaSchede"."Posizione"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_ListaSchede"."Posizione" IS 'Posizione della scheda';


--
-- TOC entry 225 (class 1259 OID 714826)
-- Name: Oggetti_ListaSchede_Codice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Oggetti_ListaSchede_Codice_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Oggetti_ListaSchede_Codice_seq" OWNER TO "postgres";

--
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 225
-- Name: Oggetti_ListaSchede_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_ListaSchede_Codice_seq" OWNED BY "Oggetti_ListaSchede"."Codice";


--
-- TOC entry 226 (class 1259 OID 714828)
-- Name: Oggetti_RelazioniSchede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_RelazioniSchede" (
    "CodiceOggetto" bigint NOT NULL,
    "CodiceTitolo" integer NOT NULL,
    "CodiceScheda" bigint NOT NULL
);


ALTER TABLE "Oggetti_RelazioniSchede" OWNER TO "postgres";

--
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE "Oggetti_RelazioniSchede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_RelazioniSchede" IS 'Relazioni tra gli oggetti e le schede informative';


--
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceOggetto"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_RelazioniSchede"."CodiceOggetto" IS 'Codice dell''oggetto';


--
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceTitolo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_RelazioniSchede"."CodiceTitolo" IS 'Codice del titolo della scheda';


--
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN "Oggetti_RelazioniSchede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_RelazioniSchede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 227 (class 1259 OID 714831)
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
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 227
-- Name: Oggetti_RelazioniSchede_CodiceScheda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_RelazioniSchede_CodiceScheda_seq" OWNED BY "Oggetti_RelazioniSchede"."CodiceScheda";


--
-- TOC entry 228 (class 1259 OID 714833)
-- Name: Oggetti_Schede; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Oggetti_Schede" (
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


ALTER TABLE "Oggetti_Schede" OWNER TO "postgres";

--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE "Oggetti_Schede"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Oggetti_Schede" IS 'Informazioni testuali sugli oggetti';


--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."CodiceScheda"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."CodiceScheda" IS 'Codice della scheda';


--
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."CodiceCampo"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."CodiceCampo" IS 'Codice del campo';


--
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."BoolValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."BoolValue" IS 'Valore booleano';


--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."IntValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."IntValue" IS 'Valore intero';


--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."RealValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."RealValue" IS 'Valore reale';


--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."TextValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."TextValue" IS 'Valore testo o multicombo (indici del combobox separati da virgola)';


--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."TimestampValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."TimestampValue" IS 'Valore timestamp';


--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."ComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."ComboValue" IS 'Indice del ComboBox per accedere al valore';


--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN "Oggetti_Schede"."MultiComboValue"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Oggetti_Schede"."MultiComboValue" IS 'Valore di un comobox multiplo';


--
-- TOC entry 229 (class 1259 OID 714839)
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
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 229
-- Name: Oggetti_SubVersion_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_SubVersion_Codice_seq" OWNED BY "OggettiSubVersion"."Codice";


--
-- TOC entry 230 (class 1259 OID 714841)
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
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 230
-- Name: Oggetti_Versioni_Codice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Oggetti_Versioni_Codice_seq" OWNED BY "OggettiVersion"."Codice";


--
-- TOC entry 235 (class 1259 OID 756431)
-- Name: Settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Settings" (
    "Key" character varying(255) NOT NULL,
    "Value" character varying(255) NOT NULL
);


ALTER TABLE "Settings" OWNER TO "postgres";

--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE "Settings"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Settings" IS 'Tabella che contiene i vari settings del db';


--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN "Settings"."Key"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Settings"."Key" IS 'Chiave del setting';


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN "Settings"."Value"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Settings"."Value" IS 'Valore del setting';


--
-- TOC entry 231 (class 1259 OID 714843)
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
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE "Utenti"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "Utenti" IS 'Tabella accessi e permessi';


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN "Utenti"."User"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."User" IS 'Nome utente';


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN "Utenti"."Password"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Password" IS 'Password dell''account';


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN "Utenti"."FullName"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."FullName" IS 'Nome e cognome reale';


--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN "Utenti"."Gruppi"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN "Utenti"."Gruppi" IS 'gruppi, separati da virgole e senza spazi';


--
-- TOC entry 2229 (class 2604 OID 714849)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Categorie" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Categorie_Codice_seq"'::"regclass");


--
-- TOC entry 2349 (class 2604 OID 721353)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "GruppiCategorie" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"GruppiCategorie_Codice_seq"'::"regclass");


--
-- TOC entry 2350 (class 2604 OID 756445)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"InterventiSubVersion_Codice_seq"'::"regclass");


--
-- TOC entry 2365 (class 2604 OID 756539)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"InterventiSubVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2352 (class 2604 OID 756512)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"InterventiSubVersion_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2351 (class 2604 OID 756487)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"InterventiSubVersion_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2366 (class 2604 OID 756570)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"InterventiSubVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2264 (class 2604 OID 714850)
-- Name: NumeroLog; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Log" ALTER COLUMN "NumeroLog" SET DEFAULT "nextval"('"Log_NumeroLog_seq"'::"regclass");


--
-- TOC entry 2242 (class 2604 OID 714851)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Modelli3D_Codice_seq"'::"regclass");


--
-- TOC entry 2255 (class 2604 OID 714852)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_Codice_seq"'::"regclass");


--
-- TOC entry 2300 (class 2604 OID 714853)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_SubVersion_Codice_seq"'::"regclass");


--
-- TOC entry 2301 (class 2604 OID 714854)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiSubVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2314 (class 2604 OID 714855)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiSubVersion_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2315 (class 2604 OID 714856)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiSubVersion_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2316 (class 2604 OID 714857)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"OggettiSubVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2263 (class 2604 OID 714858)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_Versioni_Codice_seq"'::"regclass");


--
-- TOC entry 2317 (class 2604 OID 714859)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiVersion_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2330 (class 2604 OID 714860)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiVersion_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2331 (class 2604 OID 714861)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"OggettiVersion_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2332 (class 2604 OID 714862)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"OggettiVersion_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2333 (class 2604 OID 714863)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_InfoComboBox" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_InfoComboBox_Codice_seq"'::"regclass");


--
-- TOC entry 2346 (class 2604 OID 714864)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaInformazioni" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_ListaInformazioni_Codice_seq"'::"regclass");


--
-- TOC entry 2347 (class 2604 OID 714865)
-- Name: Codice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaSchede" ALTER COLUMN "Codice" SET DEFAULT "nextval"('"Oggetti_ListaSchede_Codice_seq"'::"regclass");


--
-- TOC entry 2348 (class 2604 OID 714866)
-- Name: CodiceScheda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede" ALTER COLUMN "CodiceScheda" SET DEFAULT "nextval"('"Oggetti_RelazioniSchede_CodiceScheda_seq"'::"regclass");


--
-- TOC entry 2373 (class 2606 OID 714868)
-- Name: Cantieri_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Cantieri"
    ADD CONSTRAINT "Cantieri_primaryKey" PRIMARY KEY ("Layer0", "Numero");


--
-- TOC entry 2375 (class 2606 OID 714870)
-- Name: Categorie_UniqueName; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Categorie"
    ADD CONSTRAINT "Categorie_UniqueName" UNIQUE ("Nome");


--
-- TOC entry 2377 (class 2606 OID 714872)
-- Name: Categorie_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Categorie"
    ADD CONSTRAINT "Categorie_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2379 (class 2606 OID 714874)
-- Name: FileExtra_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "FileExtra"
    ADD CONSTRAINT "FileExtra_primaryKey" PRIMARY KEY ("Filename");


--
-- TOC entry 2469 (class 2606 OID 721359)
-- Name: GruppiCategorie-NomeUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "GruppiCategorie"
    ADD CONSTRAINT "GruppiCategorie-NomeUnique" UNIQUE ("Nome");


--
-- TOC entry 2471 (class 2606 OID 721357)
-- Name: GruppiCategorie-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "GruppiCategorie"
    ADD CONSTRAINT "GruppiCategorie-primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2381 (class 2606 OID 714876)
-- Name: Import_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_primaryKey" PRIMARY KEY ("User", "CodiceVersione");


--
-- TOC entry 2487 (class 2606 OID 756496)
-- Name: InterventiSubVersion_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_CategorieSchede"
    ADD CONSTRAINT "InterventiSubVersion_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2493 (class 2606 OID 756541)
-- Name: InterventiSubVersion_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_InfoComboBox"
    ADD CONSTRAINT "InterventiSubVersion_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2489 (class 2606 OID 756528)
-- Name: InterventiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "InterventiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2491 (class 2606 OID 756526)
-- Name: InterventiSubVersion_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "InterventiSubVersion_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2483 (class 2606 OID 756491)
-- Name: InterventiSubVersion_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaSchede"
    ADD CONSTRAINT "InterventiSubVersion_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2485 (class 2606 OID 756489)
-- Name: InterventiSubVersion_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaSchede"
    ADD CONSTRAINT "InterventiSubVersion_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2477 (class 2606 OID 756456)
-- Name: InterventiSubVersion_Relazioni-UniqueFiglio; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-UniqueFiglio" UNIQUE ("Figlio");


--
-- TOC entry 2479 (class 2606 OID 756452)
-- Name: InterventiSubVersion_Relazioni-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-primaryKey" PRIMARY KEY ("Intervento", "Padre");


--
-- TOC entry 2497 (class 2606 OID 756572)
-- Name: InterventiSubVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "InterventiSubVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceSubVersion", "CodiceTitolo");


--
-- TOC entry 2481 (class 2606 OID 756454)
-- Name: InterventiSubVersion_Relazioni_UniquePadre; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni_UniquePadre" UNIQUE ("Padre");


--
-- TOC entry 2495 (class 2606 OID 756554)
-- Name: InterventiSubVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Schede"
    ADD CONSTRAINT "InterventiSubVersion_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2475 (class 2606 OID 756447)
-- Name: InterventiSubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion"
    ADD CONSTRAINT "InterventiSubVersion_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2395 (class 2606 OID 714878)
-- Name: Log_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "Log_primaryKey" PRIMARY KEY ("NumeroLog");


--
-- TOC entry 2499 (class 2606 OID 756595)
-- Name: MaterialeInterventiSubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeInterventiSubVersion"
    ADD CONSTRAINT "MaterialeInterventiSubVersion_primaryKey" PRIMARY KEY ("CodiceSubVersion", "URL", "Qualità");


--
-- TOC entry 2397 (class 2606 OID 714880)
-- Name: MaterialeOggetti_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeOggetti"
    ADD CONSTRAINT "MaterialeOggetti_primaryKey" PRIMARY KEY ("CodiceOggetto", "URL", "Qualità");


--
-- TOC entry 2399 (class 2606 OID 714882)
-- Name: MaterialeSubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeSubVersion"
    ADD CONSTRAINT "MaterialeSubVersion_primaryKey" PRIMARY KEY ("CodiceSubVersion", "URL", "Qualità");


--
-- TOC entry 2401 (class 2606 OID 714884)
-- Name: MaterialeVersioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeVersioni"
    ADD CONSTRAINT "MaterialeVersioni_primaryKey" PRIMARY KEY ("CodiceVersione", "URL", "Qualità");


--
-- TOC entry 2405 (class 2606 OID 714886)
-- Name: Modelli3D_3dm_Backup_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm_Backup"
    ADD CONSTRAINT "Modelli3D_3dm_Backup_primaryKey" PRIMARY KEY ("CodiceModello", "LoD", "LastUpdate");


--
-- TOC entry 2403 (class 2606 OID 714888)
-- Name: Modelli3D_3dm_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm_primaryKey" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2407 (class 2606 OID 714890)
-- Name: Modelli3D_HotSpotColor_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_HotSpotColor"
    ADD CONSTRAINT "Modelli3D_HotSpotColor_primaryKey" PRIMARY KEY ("CodiceModello");


--
-- TOC entry 2385 (class 2606 OID 714892)
-- Name: Modelli3D_LoD_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD_primaryKey" PRIMARY KEY ("CodiceModello", "LoD");


--
-- TOC entry 2413 (class 2606 OID 714894)
-- Name: Modelli3D_Textture_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Textture_primaryKey" PRIMARY KEY ("CodiceModello", "TextureNumber", "Qualità");


--
-- TOC entry 2383 (class 2606 OID 714896)
-- Name: Modelli3D_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D"
    ADD CONSTRAINT "Modelli3D_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2409 (class 2606 OID 714898)
-- Name: Modelli3d_OggettiJSON_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3d_OggettiJSON_primaryKey" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2411 (class 2606 OID 714900)
-- Name: Modelli3d_OggettiOBJ-primary-key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_OBJ"
    ADD CONSTRAINT "Modelli3d_OggettiOBJ-primary-key" PRIMARY KEY ("CodiceModello", "LoD", "Parte");


--
-- TOC entry 2387 (class 2606 OID 714902)
-- Name: Oggetti-UniqueLayersName; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti"
    ADD CONSTRAINT "Oggetti-UniqueLayersName" UNIQUE ("Layer0", "Layer1", "Layer2", "Layer3", "Name");


--
-- TOC entry 2419 (class 2606 OID 714904)
-- Name: OggettiSubVersion_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2421 (class 2606 OID 714906)
-- Name: OggettiSubVersion_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiSubVersion_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2423 (class 2606 OID 714908)
-- Name: OggettiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2425 (class 2606 OID 714910)
-- Name: OggettiSubVersion_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2427 (class 2606 OID 714912)
-- Name: OggettiSubVersion_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaSchede"
    ADD CONSTRAINT "OggettiSubVersion_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2429 (class 2606 OID 714914)
-- Name: OggettiSubVersion_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaSchede"
    ADD CONSTRAINT "OggettiSubVersion_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2431 (class 2606 OID 714916)
-- Name: OggettiSubVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceSubVersion", "CodiceTitolo");


--
-- TOC entry 2433 (class 2606 OID 714918)
-- Name: OggettiSubVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2435 (class 2606 OID 714920)
-- Name: OggettiVersion_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2437 (class 2606 OID 714922)
-- Name: OggettiVersion_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiVersion_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2439 (class 2606 OID 714924)
-- Name: OggettiVersion_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2441 (class 2606 OID 714926)
-- Name: OggettiVersion_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2443 (class 2606 OID 714928)
-- Name: OggettiVersion_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaSchede"
    ADD CONSTRAINT "OggettiVersion_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2445 (class 2606 OID 714930)
-- Name: OggettiVersion_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaSchede"
    ADD CONSTRAINT "OggettiVersion_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2447 (class 2606 OID 714932)
-- Name: OggettiVersion_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceVersione", "CodiceTitolo");


--
-- TOC entry 2449 (class 2606 OID 714934)
-- Name: OggettiVersion_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2451 (class 2606 OID 714936)
-- Name: Oggetti_CategorieSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_primaryKey" PRIMARY KEY ("CodiceCategoria", "CodiceScheda");


--
-- TOC entry 2453 (class 2606 OID 714938)
-- Name: Oggetti_InfoComboBox_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_InfoComboBox"
    ADD CONSTRAINT "Oggetti_InfoComboBox_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2455 (class 2606 OID 714940)
-- Name: Oggetti_ListaInformazioni_UniqueCodiceTitoloCampo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_UniqueCodiceTitoloCampo" UNIQUE ("CodiceTitolo", "Campo");


--
-- TOC entry 2457 (class 2606 OID 714942)
-- Name: Oggetti_ListaInformazioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2459 (class 2606 OID 714944)
-- Name: Oggetti_ListaSchede_TitoloUnique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaSchede"
    ADD CONSTRAINT "Oggetti_ListaSchede_TitoloUnique" UNIQUE ("Titolo");


--
-- TOC entry 2461 (class 2606 OID 714946)
-- Name: Oggetti_ListaSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaSchede"
    ADD CONSTRAINT "Oggetti_ListaSchede_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2463 (class 2606 OID 714948)
-- Name: Oggetti_RelazioniSchede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_primaryKey" PRIMARY KEY ("CodiceOggetto", "CodiceTitolo");


--
-- TOC entry 2465 (class 2606 OID 714950)
-- Name: Oggetti_Schede_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_primaryKey" PRIMARY KEY ("CodiceScheda", "CodiceCampo");


--
-- TOC entry 2415 (class 2606 OID 714952)
-- Name: Oggetti_SubVersion-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-unicità" UNIQUE ("CodiceOggetto", "CodiceVersione", "SubVersion");


--
-- TOC entry 2417 (class 2606 OID 714954)
-- Name: Oggetti_SubVersion_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2391 (class 2606 OID 714956)
-- Name: Oggetti_Versioni-unicità; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-unicità" UNIQUE ("CodiceOggetto", "Versione");


--
-- TOC entry 2393 (class 2606 OID 714958)
-- Name: Oggetti_Versioni_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2389 (class 2606 OID 714960)
-- Name: Oggetti_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti"
    ADD CONSTRAINT "Oggetti_primaryKey" PRIMARY KEY ("Codice");


--
-- TOC entry 2473 (class 2606 OID 756439)
-- Name: Settings-primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Settings"
    ADD CONSTRAINT "Settings-primaryKey" PRIMARY KEY ("Key");


--
-- TOC entry 2467 (class 2606 OID 714962)
-- Name: Utenti_primaryKey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Utenti"
    ADD CONSTRAINT "Utenti_primaryKey" PRIMARY KEY ("User");


--
-- TOC entry 2500 (class 2606 OID 721365)
-- Name: CategorieCodiceGruppo-refGruppiCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Categorie"
    ADD CONSTRAINT "CategorieCodiceGruppo-refGruppiCategorie" FOREIGN KEY ("CodiceGruppo") REFERENCES "GruppiCategorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2501 (class 2606 OID 714963)
-- Name: Import_CodiceModelloRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceModelloRef" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2502 (class 2606 OID 714968)
-- Name: Import_CodiceOggettoRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceOggettoRef" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2503 (class 2606 OID 714973)
-- Name: Import_CodiceOggettoVersioneRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_CodiceOggettoVersioneRef" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2504 (class 2606 OID 714978)
-- Name: Import_UserRef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Import"
    ADD CONSTRAINT "Import_UserRef" FOREIGN KEY ("User") REFERENCES "Utenti"("User") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2547 (class 2606 OID 756497)
-- Name: InterventiSubVersion_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_CategorieSchede"
    ADD CONSTRAINT "InterventiSubVersion_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2548 (class 2606 OID 756502)
-- Name: InterventiSubVersion_CategorieSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_CategorieSchede"
    ADD CONSTRAINT "InterventiSubVersion_CategorieSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "InterventiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2550 (class 2606 OID 756542)
-- Name: InterventiSubVersion_InfoComboBox-refSubVersion_ListaInformazio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_InfoComboBox"
    ADD CONSTRAINT "InterventiSubVersion_InfoComboBox-refSubVersion_ListaInformazio" FOREIGN KEY ("CodiceCampo") REFERENCES "InterventiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2549 (class 2606 OID 756529)
-- Name: InterventiSubVersion_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "InterventiSubVersion_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "InterventiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2545 (class 2606 OID 756462)
-- Name: InterventiSubVersion_Relazioni-Figlio_RefOggettiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-Figlio_RefOggettiSubVersion" FOREIGN KEY ("Figlio") REFERENCES "OggettiSubVersion"("Codice");


--
-- TOC entry 2546 (class 2606 OID 756467)
-- Name: InterventiSubVersion_Relazioni-Intervento_RefInterventiiSubVers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-Intervento_RefInterventiiSubVers" FOREIGN KEY ("Intervento") REFERENCES "InterventiSubVersion"("Codice");


--
-- TOC entry 2544 (class 2606 OID 756457)
-- Name: InterventiSubVersion_Relazioni-Padre_RefOggettiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Relazioni"
    ADD CONSTRAINT "InterventiSubVersion_Relazioni-Padre_RefOggettiSubVersion" FOREIGN KEY ("Padre") REFERENCES "OggettiSubVersion"("Codice");


--
-- TOC entry 2553 (class 2606 OID 756573)
-- Name: InterventiSubVersion_RelazioniSchede_refInterventiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "InterventiSubVersion_RelazioniSchede_refInterventiSubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "InterventiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2554 (class 2606 OID 756578)
-- Name: InterventiSubVersion_RelazioniSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "InterventiSubVersion_RelazioniSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "InterventiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2551 (class 2606 OID 756555)
-- Name: InterventiSubVersion_Schede_refSubVersion_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Schede"
    ADD CONSTRAINT "InterventiSubVersion_Schede_refSubVersion_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "InterventiSubVersion_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2552 (class 2606 OID 756560)
-- Name: InterventiSubVersion_Schede_refSubVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "InterventiSubVersion_Schede"
    ADD CONSTRAINT "InterventiSubVersion_Schede_refSubVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "InterventiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2555 (class 2606 OID 756596)
-- Name: MaterialeInterventiSubVersion_Verifica_Codice_SubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeInterventiSubVersion"
    ADD CONSTRAINT "MaterialeInterventiSubVersion_Verifica_Codice_SubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "InterventiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2510 (class 2606 OID 714983)
-- Name: MaterialeSubVersion_Verifica_Codice_SubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeSubVersion"
    ADD CONSTRAINT "MaterialeSubVersion_Verifica_Codice_SubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "OggettiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2511 (class 2606 OID 714988)
-- Name: MaterialeVersioni_Verifica_Codice_Versione; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeVersioni"
    ADD CONSTRAINT "MaterialeVersioni_Verifica_Codice_Versione" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2512 (class 2606 OID 714993)
-- Name: Modelli3D_3dm-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm"
    ADD CONSTRAINT "Modelli3D_3dm-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2513 (class 2606 OID 714998)
-- Name: Modelli3D_3dm_Backup-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_3dm_Backup"
    ADD CONSTRAINT "Modelli3D_3dm_Backup-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2514 (class 2606 OID 715003)
-- Name: Modelli3D_HotSpotColor-refModelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_HotSpotColor"
    ADD CONSTRAINT "Modelli3D_HotSpotColor-refModelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2505 (class 2606 OID 715008)
-- Name: Modelli3D_LoD-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_LoD"
    ADD CONSTRAINT "Modelli3D_LoD-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2515 (class 2606 OID 715013)
-- Name: Modelli3D_OggettiJSON-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_JSON"
    ADD CONSTRAINT "Modelli3D_OggettiJSON-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2516 (class 2606 OID 715018)
-- Name: Modelli3D_OggettiOBJ-key-Modelli3D_LoD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_OBJ"
    ADD CONSTRAINT "Modelli3D_OggettiOBJ-key-Modelli3D_LoD" FOREIGN KEY ("CodiceModello", "LoD") REFERENCES "Modelli3D_LoD"("CodiceModello", "LoD") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2517 (class 2606 OID 715023)
-- Name: Modelli3D_Texture-refCodiceModello; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Modelli3D_Texture"
    ADD CONSTRAINT "Modelli3D_Texture-refCodiceModello" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2520 (class 2606 OID 715028)
-- Name: OggettiSubVersion_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2521 (class 2606 OID 715033)
-- Name: OggettiSubVersion_CategorieSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiSubVersion_CategorieSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "OggettiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2522 (class 2606 OID 715038)
-- Name: OggettiSubVersion_InfoComboBox-refSubVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiSubVersion_InfoComboBox-refSubVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "OggettiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2523 (class 2606 OID 715043)
-- Name: OggettiSubVersion_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiSubVersion_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "OggettiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2524 (class 2606 OID 715048)
-- Name: OggettiSubVersion_RelazioniSchede_refOggettiSubVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_refOggettiSubVersion" FOREIGN KEY ("CodiceSubVersion") REFERENCES "OggettiSubVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2525 (class 2606 OID 715053)
-- Name: OggettiSubVersion_RelazioniSchede_refSubVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiSubVersion_RelazioniSchede_refSubVersion_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "OggettiSubVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2526 (class 2606 OID 715058)
-- Name: OggettiSubVersion_Schede_refSubVersion_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_refSubVersion_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "OggettiSubVersion_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2527 (class 2606 OID 715063)
-- Name: OggettiSubVersion_Schede_refSubVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion_Schede"
    ADD CONSTRAINT "OggettiSubVersion_Schede_refSubVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "OggettiSubVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2528 (class 2606 OID 715068)
-- Name: OggettiVersion_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2529 (class 2606 OID 715073)
-- Name: OggettiVersion_CategorieSchede_refOggettiVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_CategorieSchede"
    ADD CONSTRAINT "OggettiVersion_CategorieSchede_refOggettiVersion_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "OggettiVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2530 (class 2606 OID 715078)
-- Name: OggettiVersion_InfoComboBox-refOggettiVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_InfoComboBox"
    ADD CONSTRAINT "OggettiVersion_InfoComboBox-refOggettiVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "OggettiVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2531 (class 2606 OID 715083)
-- Name: OggettiVersion_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_ListaInformazioni"
    ADD CONSTRAINT "OggettiVersion_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "OggettiVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2532 (class 2606 OID 715088)
-- Name: OggettiVersion_RelazioniSchede_refOggettiVersion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_refOggettiVersion" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2533 (class 2606 OID 715093)
-- Name: OggettiVersion_RelazioniSchede_refOggettiVersion_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_RelazioniSchede"
    ADD CONSTRAINT "OggettiVersion_RelazioniSchede_refOggettiVersion_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "OggettiVersion_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2534 (class 2606 OID 715098)
-- Name: OggettiVersion_Schede_refOggettiVersion_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_refOggettiVersion_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "OggettiVersion_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2535 (class 2606 OID 715103)
-- Name: OggettiVersion_Schede_refOggettiVersion_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion_Schede"
    ADD CONSTRAINT "OggettiVersion_Schede_refOggettiVersion_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "OggettiVersion_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2536 (class 2606 OID 715108)
-- Name: Oggetti_CategorieSchede_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_refCategorie" FOREIGN KEY ("CodiceCategoria") REFERENCES "Categorie"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2537 (class 2606 OID 715113)
-- Name: Oggetti_CategorieSchede_refOggetti_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_CategorieSchede"
    ADD CONSTRAINT "Oggetti_CategorieSchede_refOggetti_ListaSchede" FOREIGN KEY ("CodiceScheda") REFERENCES "Oggetti_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2538 (class 2606 OID 715118)
-- Name: Oggetti_InfoComboBox-refOggetti_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_InfoComboBox"
    ADD CONSTRAINT "Oggetti_InfoComboBox-refOggetti_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "Oggetti_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2539 (class 2606 OID 715123)
-- Name: Oggetti_ListaInformazioni_refCodiceTitolo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_ListaInformazioni"
    ADD CONSTRAINT "Oggetti_ListaInformazioni_refCodiceTitolo" FOREIGN KEY ("CodiceTitolo") REFERENCES "Oggetti_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2540 (class 2606 OID 715128)
-- Name: Oggetti_RelazioniSchede_refOggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_refOggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2541 (class 2606 OID 715133)
-- Name: Oggetti_RelazioniSchede_refOggetti_ListaSchede; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_RelazioniSchede"
    ADD CONSTRAINT "Oggetti_RelazioniSchede_refOggetti_ListaSchede" FOREIGN KEY ("CodiceTitolo") REFERENCES "Oggetti_ListaSchede"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2542 (class 2606 OID 715138)
-- Name: Oggetti_Schede_refOggetti_InfoComboBox; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_refOggetti_InfoComboBox" FOREIGN KEY ("ComboValue") REFERENCES "Oggetti_InfoComboBox"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2543 (class 2606 OID 715143)
-- Name: Oggetti_Schede_refOggetti_ListaInformazioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti_Schede"
    ADD CONSTRAINT "Oggetti_Schede_refOggetti_ListaInformazioni" FOREIGN KEY ("CodiceCampo") REFERENCES "Oggetti_ListaInformazioni"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2518 (class 2606 OID 715148)
-- Name: Oggetti_SubVersion-keu-Oggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-keu-Oggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2519 (class 2606 OID 715153)
-- Name: Oggetti_SubVersion-key-Oggetti_Versioni; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiSubVersion"
    ADD CONSTRAINT "Oggetti_SubVersion-key-Oggetti_Versioni" FOREIGN KEY ("CodiceVersione") REFERENCES "OggettiVersion"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2507 (class 2606 OID 715158)
-- Name: Oggetti_Versioni-key-Modelli3D; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key-Modelli3D" FOREIGN KEY ("CodiceModello") REFERENCES "Modelli3D"("Codice") ON UPDATE SET NULL ON DELETE SET NULL;


--
-- TOC entry 2508 (class 2606 OID 715163)
-- Name: Oggetti_Versioni-key-Oggetti; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OggettiVersion"
    ADD CONSTRAINT "Oggetti_Versioni-key-Oggetti" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2506 (class 2606 OID 715168)
-- Name: Oggetti_refCategorie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Oggetti"
    ADD CONSTRAINT "Oggetti_refCategorie" FOREIGN KEY ("Categoria") REFERENCES "Categorie"("Codice") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2509 (class 2606 OID 715173)
-- Name: Verifica_Codice_oggetto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MaterialeOggetti"
    ADD CONSTRAINT "Verifica_Codice_oggetto" FOREIGN KEY ("CodiceOggetto") REFERENCES "Oggetti"("Codice") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA "public" FROM PUBLIC;
REVOKE ALL ON SCHEMA "public" FROM "postgres";
GRANT ALL ON SCHEMA "public" TO "postgres";
GRANT ALL ON SCHEMA "public" TO PUBLIC;


-- Completed on 2018-09-04 13:20:17

--
-- PostgreSQL database dump complete
--

