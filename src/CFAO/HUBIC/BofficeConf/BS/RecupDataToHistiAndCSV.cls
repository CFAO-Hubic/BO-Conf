Class CFAO.HUBIC.BofficeConf.BS.RecupDataToHistiAndCSV Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.SQL.InboundAdapter";

Property Adapter As EnsLib.SQL.InboundAdapter;

Property TargetConfigNames As %String;

Property lastTRADETYPESHORTNAME As %String;

Property lastvarCPTYSHORTNAME As %String;

Property NomduFichierCSV As %String;

Property TotalDeviseGlobal As %String;

Property TotalEURGlobal As %String;

Property NbError As %String;

Property MessError As %String;

Parameter SETTINGS = "TargetConfigNames";

Method OnProcessInput(pInput As EnsLib.SQL.Snapshot, Output pOutput As %RegisteredObject) As %Status
{
	
	$$$LOGINFO("***** DEBUT  *****")
	//Select distinct(TRADEDATE) as UneTradeDate From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords  where  StatutHistoForex = 'NON' and TRADEDATE is not null
	//Select distinct(TRADEDATE) as UneTradeDate From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords  where TRADEDATE = '2017-01-09'
	Set tSC = $$$OK
	
	//&sql(delete from CFAO_HUBIC_Alertes.HistoAlertOnErreur where DateErrString like '2011%')
	/*
	&sql(Select count(*) into nbf from CFAO_HUBIC_Alertes.HistoAlertOnErreur where AlertTime  like '2016%')
	$$$LOGINFO("***** nb 2016% "_nbf)
	&sql(Select count(*) into nbg from CFAO_HUBIC_Alertes.HistoAlertOnErreur where AlertTime  like '2017%')
	$$$LOGINFO("***** nb 2017% "_nbg)*/
	
	
	// Mise en variable de la date du jour **********************************************************************
	Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ" 
	Set AnnéeSaisie = $extract(DateTraitement,1,4)
	Set MoisSaisie =  $extract(DateTraitement,5,6)
	Set jourSaisie =  $extract(DateTraitement,7,8)
	Set Htime=$PIECE($HOROLOG,",",2)
	Set ltime = $ZTIME(Htime,1) 
	set DateTraitTIMESTAMP = AnnéeSaisie_"-"_MoisSaisie_"-"_jourSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"
	// **********************************************************************************************************

	Set EnvoiForex = "NON"

	Set ..NbError = 0
	Set DescrptionError = ""
	Set ErrorMail = ""
	Set ..MessError = ""
	Set VarIdInError = ""
	
	Set ..TotalDeviseGlobal = 0
	Set ..TotalEURGlobal = 0
	Set TotalGlobal = 0
	Set MEPcpt = 0
	Set SWAPcpt = 0
	Set PROROcpt = 0
	Set LeveeVentecpt = 0
	Set LeveeAchatcpt = 0

	Set varTRADEDATETraiter = ""
	Set varNbTradeDateSatutAll = 0
	Set varTRADEDATE = ""
	Set ..lastTRADETYPESHORTNAME = ""
	Set ..lastvarCPTYSHORTNAME = ""
	
	Set varTRADEDATETraiter = pInput.UneTradeDate
	//$$$LOGINFO(":varTRADEDATETraiter : "_varTRADEDATETraiter)

		
	// On compte le nombre de trade date total pour la tradedate 
	&sql(Select count(distinct(IDForex)) INTO :varNbTradeDateSatutAll From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords where TRADEDATE = :varTRADEDATETraiter and StatutHistoForex = 'NON'  )
	//$$$LOGINFO("varNbTradeDateSatutAll : "_varNbTradeDateSatutAll)
	 
	 
	// On compte le nombre de tradedate au statut OUI total pour la tradedate
	&sql(Select count(*) INTO :varNbTradeDateSatutOUI From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords where TRADEDATE = :varTRADEDATETraiter and rapprocherOUINON = 'OUI' and StatutHistoForex = 'NON' )
	//$$$LOGINFO("varNbTradeDateSatutOUI : "_varNbTradeDateSatutOUI)
	//$$$LOGINFO("TRADEDATE "_ varTRADEDATETraiter _ " : " _ varNbTradeDateSatutOUI _ " Rapprochées sur " _ varNbTradeDateSatutAll)
	 
	 		
			
	If (varNbTradeDateSatutAll = varNbTradeDateSatutOUI) && (varNbTradeDateSatutAll '= 0){
		//$$$LOGINFO("On Passe par envoi forex batch")
		 	
	 	//Si nous avons autant de tradedate que de tradedate a oui (pour une meme tradedate 
	 	//alors nous pouvons envoyer cette tradedate a Forex Finance
	 	
	 	// Instaciation d'un new classe de Batch ------------------------------------------------------------
		Set contextJrnForex = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.BenvCSV).%New() 
		Set ..NomduFichierCSV = "RE_"_varTRADEDATETraiter_"_"_$Replace($ZTIME(Htime,1),":","")_".csv"
		Set contextJrnForex.%Source = ..NomduFichierCSV
		$$$LOGINFO("NomduFichierCSV : "_..NomduFichierCSV)
		Set CreationBatch =  contextJrnForex.%Save()
		Set varIdbatch = contextJrnForex.%Id()				
		$$$LOGINFO("varIdbatch : "_varIdbatch)		
				
		If (CreationBatch){
			//$$$LOGINFO("Creation batch OK forex batch")		 
			//On recherche les lignes prete a l'envoi
	 		
  			// Enregistrement des MEP pour le reporting -------------------------------------------------------------------------------------------------------------------
  			&sql(DECLARE CMEP CURSOR FOR
			     Select ID, IDForex, TRADEDATE,CPTYSHORTNAME, CURRENCY1SHORTNAME, AMOUNT1,CLIENTRATE, SPOTRATE , TRADETYPESHORTNAME, MATURITYDATE,AMOUNT2  
			       INTO :varID, :varIDForex, :varTRADEDATE, :varCPTYSHORTNAME, :varCURRENCY1SHORTNAME, :varAMOUNT1, :varCLIENTRATE, :varSPOTRATE , :varTRADETYPESHORTNAME, :varMATURITYDATE, :varAMOUNT2   
			       From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			     where TRADEDATE = :varTRADEDATETraiter and TRADETYPESHORTNAME IN ('EAAT','EVAT')
			     Order by CURRENCY1SHORTNAME,TRADETYPESHORTNAME,CPTYSHORTNAME)
			&sql(OPEN CMEP)
			&sql(FETCH CMEP)

	 		While (SQLCODE = 0) {		 		
				Set EnvoiForex = "OUI"
				$$$LOGINFO("SQL varIDForex : " _ varIDForex)
				Set MEPcpt = MEPcpt + 1 
				
				Set RepEnregLigneMEP = ..EnregLigneMEP(varID,varIDForex,varTRADEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
				varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,varTRADETYPESHORTNAME,varMATURITYDATE,MEPcpt,varIdbatch)				
								
				&sql(FETCH CMEP)
				
			} //fin du While 	 						
			&sql(CLOSE CMEP)					
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------
			If MEPcpt > 0 Set RepEnregLigneMEP = ..EnregLigneMEP(varID,varIDForex,varTRADEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"FIN",varMATURITYDATE,999,varIdbatch)	
				
			// Enregistrement des SWAP pour le reporting -------------------------------------------------------------------------------------------------------------------
  			&sql(DECLARE CSAWP CURSOR FOR
			     Select ID, IDForex, TRADEDATE,CPTYSHORTNAME, CURRENCY1SHORTNAME, AMOUNT1,CLIENTRATE, SPOTRATE , TRADETYPESHORTNAME, MATURITYDATE,AMOUNT2  
			       INTO :varID, :varIDForex, :varTRADEDATE, :varCPTYSHORTNAME, :varCURRENCY1SHORTNAME, :varAMOUNT1, :varCLIENTRATE, :varSPOTRATE , :varTRADETYPESHORTNAME, :varMATURITYDATE, :varAMOUNT2   
			       From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			     where TRADEDATE = :varTRADEDATETraiter and TRADETYPESHORTNAME IN ('SWAAA','SWAAF','SWAV','SWAVF')
			     Order by CURRENCY1SHORTNAME,TRADETYPESHORTNAME,CPTYSHORTNAME)
			&sql(OPEN CSAWP)
			&sql(FETCH CSAWP)

	 		While (SQLCODE = 0) {		 		
				Set EnvoiForex = "OUI"
				
				Set SWAPcpt = SWAPcpt + 1 
				
				Set RepEnregLigneMEP = ..EnregLigneMEP(varID,varIDForex,varTRADEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
				varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,varTRADETYPESHORTNAME,varMATURITYDATE,SWAPcpt,varIdbatch)				
								
				&sql(FETCH CSAWP)
				
			} //fin du While 	 						
			&sql(CLOSE CSAWP)	
			If SWAPcpt > 0 Set RepEnregLigneMEP = ..EnregLigneMEP(varID,varIDForex,varTRADEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"FIN",varMATURITYDATE,999,varIdbatch)					
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		
			// Enregistrement des PRORO pour le reporting -------------------------------------------------------------------------------------------------------------------
  			&sql(DECLARE CPRORO CURSOR FOR
			     Select ID, IDForex, TRADEDATE,CPTYSHORTNAME, CURRENCY1SHORTNAME, AMOUNT1,CLIENTRATE, SPOTRATE , TRADETYPESHORTNAME, MATURITYDATE,AMOUNT2  
			       INTO :varID, :varIDForex, :varTRADEDATE, :varCPTYSHORTNAME, :varCURRENCY1SHORTNAME, :varAMOUNT1, :varCLIENTRATE, :varSPOTRATE , :varTRADETYPESHORTNAME, :varMATURITYDATE, :varAMOUNT2   
			       From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			     where TRADEDATE = :varTRADEDATETraiter and TRADETYPESHORTNAME IN ('ERAT','ERVT')
			     Order by CURRENCY1SHORTNAME,TRADETYPESHORTNAME,CPTYSHORTNAME)
			&sql(OPEN CPRORO)
			&sql(FETCH CPRORO)

	 		While (SQLCODE = 0) {		 		
				Set EnvoiForex = "OUI"
				
				Set PROROcpt = PROROcpt + 1 
				
				Set RepEnregLigneMEP = ..EnregLigneMEP(varID,varIDForex,varTRADEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
				varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,varTRADETYPESHORTNAME,varMATURITYDATE,PROROcpt,varIdbatch)				
								
				&sql(FETCH CPRORO)
				
			} //fin du While 	 						
			&sql(CLOSE CPRORO)
			If PROROcpt > 0 Set RepEnregLigneMEP = ..EnregLigneMEP(varID,varIDForex,varTRADEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"FIN",varMATURITYDATE,999,varIdbatch)					
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		
			
			// Enregistrement des LEVEE Vente pour le reporting -----------------------------------------------------------------------------------------------------------------
  			Set FinLigne = "NON"
  			&sql(DECLARE CLVente CURSOR FOR
			     Select ID, IDForex, TRADEDATE,CPTYSHORTNAME, CURRENCY1SHORTNAME, AMOUNT1,CLIENTRATE, SPOTRATE , TRADETYPESHORTNAME, MATURITYDATE ,AMOUNT2,VALUEDATE 
			       INTO :varID, :varIDForex, :varTRADEDATE, :varCPTYSHORTNAME, :varCURRENCY1SHORTNAME, :varAMOUNT1, :varCLIENTRATE, :varSPOTRATE , :varTRADETYPESHORTNAME, :varMATURITYDATE, :varAMOUNT2, :varVALUEDATE 
			       From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			     where TRADEDATE = :varTRADEDATETraiter and TRADETYPESHORTNAME IN ('ELVT','EVSP','ELVTA','EVSPA')
			     Order by CURRENCY1SHORTNAME,TRADETYPESHORTNAME,CPTYSHORTNAME)
			&sql(OPEN CLVente)
			&sql(FETCH CLVente)

	 		While (SQLCODE = 0) {		 		
				Set EnvoiForex = "OUI"
				
				Set LeveeVentecpt = LeveeVentecpt + 1 
				
				Set RepEnregLigneMEP = ..EnregLigneLEVEE(varID,varIDForex,varTRADEDATE,varVALUEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
				varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"VENTES",varMATURITYDATE,LeveeVentecpt,varIdbatch,FinLigne)				
								
				&sql(FETCH CLVente)
				
			} //fin du While 	 						
			&sql(CLOSE CLVente)						
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------
			If LeveeVentecpt > 0{
				Set FinLigne = "OUI"
				Set varCPTYSHORTNAME = "FIN"
				Set RepEnregLigneMEP = ..EnregLigneLEVEE(varID,varIDForex,varTRADEDATE,varVALUEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
					varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"VENTES",varMATURITYDATE,999,varIdbatch,FinLigne)
			}
			
			// Enregistrement des LEVEE Achat pour le reporting -----------------------------------------------------------------------------------------------------------------
  			Set FinLigne = "NON"
  			&sql(DECLARE CLAchat CURSOR FOR
			     Select ID, IDForex, TRADEDATE,CPTYSHORTNAME, CURRENCY1SHORTNAME, AMOUNT1,CLIENTRATE, SPOTRATE , TRADETYPESHORTNAME, MATURITYDATE ,AMOUNT2,VALUEDATE 
			       INTO :varID, :varIDForex, :varTRADEDATE, :varCPTYSHORTNAME, :varCURRENCY1SHORTNAME, :varAMOUNT1, :varCLIENTRATE, :varSPOTRATE , :varTRADETYPESHORTNAME, :varMATURITYDATE, :varAMOUNT2, :varVALUEDATE 
			       From CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			     where TRADEDATE = :varTRADEDATETraiter and TRADETYPESHORTNAME IN ('ELAT','EASP','ELATA','EASPA')
			     Order by CURRENCY1SHORTNAME,TRADETYPESHORTNAME,CPTYSHORTNAME)
			&sql(OPEN CLAchat)
			&sql(FETCH CLAchat)

	 		While (SQLCODE = 0) {		 		
				Set EnvoiForex = "OUI"
				
				Set LeveeAchatcpt = LeveeAchatcpt + 1 
				
				Set RepEnregLigneMEP = ..EnregLigneLEVEE(varID,varIDForex,varTRADEDATE,varVALUEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
				varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"ACHAT",varMATURITYDATE,LeveeAchatcpt,varIdbatch,FinLigne)				
								
				&sql(FETCH CLAchat)
				
			} //fin du While 	 						
			&sql(CLOSE CLAchat)	
			If LeveeVentecpt > 0{
				Set FinLigne = "OUI"
				Set varCPTYSHORTNAME = "FIN"
				Set RepEnregLigneMEP = ..EnregLigneLEVEE(varID,varIDForex,varTRADEDATE,varVALUEDATE,varCPTYSHORTNAME,varCURRENCY1SHORTNAME,
					varAMOUNT1,varAMOUNT2,varCLIENTRATE,varSPOTRATE,"ACHAT",varMATURITYDATE,999,varIdbatch,FinLigne)
			}					
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		}else{
			Set ..NbError = 1	
			Set ..MessError = "Erreur de creation du fichier de reporting"				
		} // Fin de creationBatch						
	} // Fin varNbTradeDateSatutAll = varNbTradeDateSatutOUI
	 	 		
	 
	$$$LOGINFO("***** FIN  ***** ERR = "_..NbError)		 		 
    
    
    
    if ..NbError = 0{
	    If EnvoiForex = "OUI" {	
	    	$$$LOGINFO("CreationLigne avec MAJ statut : ")
			//Mise a jour du statut d'envoi du journal Forex
			&sql(update CFAO_HUBIC_BofficeConf_Table.JrnForexRecords set StatutHistoForex = 'OUI', DateHistoF = :DateTraitTIMESTAMP  where rapprocherOUINON = 'OUI' and TRADEDATE = :varTRADEDATETraiter )
							
			//Mise a jour de la confirmation correspondante
			&sql(update CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques set StatutEnvoiHistoCB = 'OUI' where StatutRapprocherCB = 'OUI' and DateNegoceCB = :varTRADEDATETraiter)
	    
			Set tSC = ..SendRequestAsync(..TargetConfigNames,contextJrnForex)
    	}
		Quit tSC
    }else{
	 	// Mise en variable de la date du jour
		Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ" 
		Set AnnéeSaisie = $extract(DateTraitement,1,4)
		Set MoisSaisie =  $extract(DateTraitement,5,6)
		Set jourSaisie =  $extract(DateTraitement,7,8)
	
		Set Htime=$PIECE($HOROLOG,",",2)
		Set ltime = $ZTIME(Htime,1) 
		set DateTraitTIMESTAMP =jourSaisie_"/"_MoisSaisie_"/"_ AnnéeSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"
		
		Set ErrorMail = "Bonjour, "_$c(13,10)_$c(13,10)
		Set ErrorMail = ErrorMail_"Nous sommes le "_DateTraitTIMESTAMP_$c(13,10)_$c(13,10)
		Set ErrorMail = ErrorMail_"Une erreur a été détectée lors de la récupération des données raprochées pour la TradeDate : "_varTRADEDATETraiter_$c(13,10)_$c(13,10)
		Set ErrorMail = ErrorMail_"Details : "_..MessError_$c(13,10)_$c(13,10)
		Set ErrorMail = ErrorMail_"Bien Cordialement,"_$c(13,10)_"l'équipe EAI"
		
		Quit $$$ERROR($$$EnsErrGeneral,$c(13,10)_$c(13,10)_ErrorMail)	   
    }
    
    Quit $$$OK
}

/// 
/// 
/// 
/// 
/// 
/// -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP 
/// -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP -------- MEP 
/// Génération des lignes MEP destinnées au fichier CSV
Method EnregLigneMEP(varID, varIDForex, varTRADEDATE, varCPTYSHORTNAME, varCURRENCY1SHORTNAME, varAMOUNT1, varAMOUNT2, varCLIENTRATE, varSPOTRATE, varTRADETYPESHORTNAME, varMATURITYDATE, i, varIdbatch) As %Stream.FileCharacter
{
	//Mise au format des date AAAA-MM-JJ devient JJ-MM-AAAA --------------------------------------------------------------------
	//Pour datetraitementUTC
	Set varTRADEDATE = $Piece(varTRADEDATE,"-",3)_"/"_$Piece(varTRADEDATE,"-",2)_"/"_$Piece(varTRADEDATE,"-",1)
	//Pour dateecheance
	Set varMATURITYDATE = $Piece(varMATURITYDATE,"-",3)_"/"_$Piece(varMATURITYDATE,"-",2)_"/"_$Piece(varMATURITYDATE,"-",1)				
	$$$LOGINFO("i : " _ i)	
	$$$LOGINFO("..lastTRADETYPESHORTNAME : " _ ..lastTRADETYPESHORTNAME)
	$$$LOGINFO("varTRADETYPESHORTNAME : " _ varTRADETYPESHORTNAME)						
	If ((..lastTRADETYPESHORTNAME = varTRADETYPESHORTNAME) || (i=1)) {
		$$$LOGINFO("varIDForex : " _ varIDForex)
		//Information commune a tous les enregistrement ----------------------------------------------------------------------------
		Set NewRecordLigne = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record).%New()
		Set NewRecordLigne.refinterne  = varIDForex
		Set NewRecordLigne.%Source = ..NomduFichierCSV
		Set NewRecordLigne.Devises = varCURRENCY1SHORTNAME
		Set NewRecordLigne.TypeOpe = varTRADETYPESHORTNAME
		Set NewRecordLigne.cpty = varCPTYSHORTNAME
		Set NewRecordLigne.DeviseMontant = varAMOUNT1
		Set NewRecordLigne.Spot = varSPOTRATE
		Set NewRecordLigne.CoursTerme = varCLIENTRATE
		Set NewRecordLigne.Echeance = varMATURITYDATE
		Set NewRecordLigne.EURmontant = varAMOUNT2
	    Set NewRecordLigne.TotalDevise = varAMOUNT1	
	    Set NewRecordLigne.TypeTableau = "MEP"						
		//On enregistre la ligne FF
		Set CreationLigne = NewRecordLigne.%Save()
		Set varIdrecord = NewRecordLigne.%Id()    			
		// on met a jour le champs %parentbatch qui fait le liens entre la ligne de Batch et les lignes de records
		&sql(update CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record set %ParentBatch = :varIdbatch where ID = :varIdrecord)
		
		Set ..TotalDeviseGlobal = ..TotalDeviseGlobal + varAMOUNT1
	}Else{
		
		Set NewRecordLigne = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record).%New()
		Set NewRecordLigne.%Source = ..NomduFichierCSV
		Set NewRecordLigne.Devises = varCURRENCY1SHORTNAME
		Set NewRecordLigne.TypeOpe = "Total " _ ..lastTRADETYPESHORTNAME
		Set NewRecordLigne.TotalDevise = ..TotalDeviseGlobal
		Set NewRecordLigne.TypeTableau = "MEP"
		Set ..TotalDeviseGlobal = 0
		//On enregistre la ligne FF
		Set CreationLigne = NewRecordLigne.%Save()
		Set varIdrecord = NewRecordLigne.%Id()    			
		// on met a jour le champs %parentbatch qui fait le liens entre la ligne de Batch et les lignes de records
		&sql(update CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record set %ParentBatch = :varIdbatch where ID = :varIdrecord)
		
		If varTRADETYPESHORTNAME '= "FIN" {
			Set NewRecordLigne = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record).%New()
			Set NewRecordLigne.refinterne  = varIDForex
			Set NewRecordLigne.%Source = ..NomduFichierCSV
			Set NewRecordLigne.Devises = varCURRENCY1SHORTNAME
			Set NewRecordLigne.TypeOpe = varTRADETYPESHORTNAME
			Set NewRecordLigne.cpty = varCPTYSHORTNAME
			Set NewRecordLigne.DeviseMontant = varAMOUNT1
			Set NewRecordLigne.Spot = varSPOTRATE
			Set NewRecordLigne.CoursTerme = varCLIENTRATE
			Set NewRecordLigne.Echeance = varMATURITYDATE
			Set NewRecordLigne.EURmontant = varAMOUNT2
	    	Set NewRecordLigne.TotalDevise = varAMOUNT1
	    	Set NewRecordLigne.TypeTableau = "MEP"						
			//On enregistre la ligne FF
			Set CreationLigne = NewRecordLigne.%Save()
			Set varIdrecord = NewRecordLigne.%Id()    			
			// on met a jour le champs %parentbatch qui fait le liens entre la ligne de Batch et les lignes de records
			&sql(update CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record set %ParentBatch = :varIdbatch where ID = :varIdrecord)
			Set ..TotalDeviseGlobal = ..TotalDeviseGlobal + varAMOUNT1
		}
		
		
	}	       
	
	If ('CreationLigne){ 
		Set ..NbError = 1
		Set ..MessError = "Erreur d'enregistrement de la ligne Forex : "_varIDForex
	}
				
	// Mise en variable de la valeur TRADETYPESHORTNAME
	Set ..lastTRADETYPESHORTNAME = varTRADETYPESHORTNAME
	
	
	Quit $$$OK
}

/// 
/// 
/// 
/// 
/// 
/// 
/// -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO 
/// -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO -------- PRORO 
/// Génération des lignes LEVEE destinnées au fichier CSV
Method EnregLigneLEVEE(varID, varIDForex, varTRADEDATE, varVALUEDATE, varCPTYSHORTNAME, varCURRENCY1SHORTNAME, varAMOUNT1, varAMOUNT2, varCLIENTRATE, varSPOTRATE, varTRADETYPESHORTNAME, varMATURITYDATE, i, varIdbatch, FinLigne) As %Stream.FileCharacter
{
	//Mise au format des date AAAA-MM-JJ devient JJ-MM-AAAA --------------------------------------------------------------------
	//Pour datetraitementUTC
	Set varTRADEDATE = $Piece(varTRADEDATE,"-",3)_"/"_$Piece(varTRADEDATE,"-",2)_"/"_$Piece(varTRADEDATE,"-",1)
	//Pour dateecheance
	Set varVALUEDATE = $Piece(varVALUEDATE,"-",3)_"/"_$Piece(varVALUEDATE,"-",2)_"/"_$Piece(varVALUEDATE,"-",1)				
								
	$$$LOGINFO("i : " _ i)	
	$$$LOGINFO("..lastvarCPTYSHORTNAME : " _ ..lastvarCPTYSHORTNAME)
	$$$LOGINFO("varCPTYSHORTNAME : " _ varCPTYSHORTNAME)	
	//Information commune a tous les enregistrement ----------------------------------------------------------------------------
	
	If ((..lastvarCPTYSHORTNAME = varCPTYSHORTNAME) || (i=1)) {
		Set NewRecordLigne = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record).%New()
		Set NewRecordLigne.%Source = ..NomduFichierCSV
		Set NewRecordLigne.refinterne  = varIDForex
	    Set NewRecordLigne.Devises = varCURRENCY1SHORTNAME
	    Set NewRecordLigne.TypeOpe = varTRADETYPESHORTNAME
		Set NewRecordLigne.cpty = varCPTYSHORTNAME
		Set NewRecordLigne.DeviseMontant = varAMOUNT1
		Set NewRecordLigne.Spot = varSPOTRATE
		Set NewRecordLigne.CoursTerme = varCLIENTRATE
		Set NewRecordLigne.EURmontant = varAMOUNT2
		Set NewRecordLigne.Echeance = varVALUEDATE 		
		Set NewRecordLigne.TotalDevise = varAMOUNT1
		Set NewRecordLigne.TotalEUR = varAMOUNT2
		Set NewRecordLigne.TypeTableau = "LEVEE"
		//On enregistre la ligne FF
		Set CreationLigne = NewRecordLigne.%Save()
		Set varIdrecord = NewRecordLigne.%Id()
		// on met a jour le champs %parentbatch qui fait le liens entre la ligne de Batch et les lignes de records
		&sql(update CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record set %ParentBatch = :varIdbatch where ID = :varIdrecord)
				
		Set ..TotalDeviseGlobal = ..TotalDeviseGlobal + varAMOUNT1
		Set ..TotalEURGlobal = ..TotalEURGlobal + varAMOUNT2
		
	}else{		
			Set NewRecordLigne = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record).%New()
			Set NewRecordLigne.%Source = ..NomduFichierCSV
			Set NewRecordLigne.Devises = varCURRENCY1SHORTNAME
	    	Set NewRecordLigne.TypeOpe = varTRADETYPESHORTNAME
	    	Set NewRecordLigne.cpty = "Total " _ varTRADETYPESHORTNAME _ " " _ ..lastvarCPTYSHORTNAME
			Set NewRecordLigne.TotalDevise = ..TotalDeviseGlobal
			Set NewRecordLigne.TotalEUR = ..TotalEURGlobal
			Set NewRecordLigne.TypeTableau = "LEVEE"
			//On enregistre la ligne FF
			Set CreationLigne = NewRecordLigne.%Save()
			Set varIdrecord = NewRecordLigne.%Id()
			// on met a jour le champs %parentbatch qui fait le liens entre la ligne de Batch et les lignes de records
			&sql(update CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record set %ParentBatch = :varIdbatch where ID = :varIdrecord)
			Set ..TotalDeviseGlobal = 0
			Set ..TotalEURGlobal = 0
		If FinLigne '= "OUI" {
			Set NewRecordLigne = ##class(CFAO.HUBIC.BofficeConf.recordMap.EnvoiCSV.Record).%New()
			Set NewRecordLigne.%Source = ..NomduFichierCSV
			Set NewRecordLigne.refinterne  = varIDForex
		    Set NewRecordLigne.Devises = varCURRENCY1SHORTNAME
		    Set NewRecordLigne.TypeOpe = varTRADETYPESHORTNAME
			Set NewRecordLigne.cpty = varCPTYSHORTNAME
			Set NewRecordLigne.DeviseMontant = varAMOUNT1
			Set NewRecordLigne.Spot = varSPOTRATE
			Set NewRecordLigne.CoursTerme = varCLIENTRATE
			Set NewRecordLigne.EURmontant = varAMOUNT2
			Set NewRecordLigne.Echeance = varVALUEDATE 		
			Set NewRecordLigne.TotalDevise = varAMOUNT1
			Set NewRecordLigne.TotalEUR = varAMOUNT2
			Set NewRecordLigne.TypeTableau = "LEVEE"		
			
			//On enregistre la ligne FF
			Set CreationLigneDeb = NewRecordLigne.%Save()
			Set varIdrecordDeb = NewRecordLigne.%Id()
			// on met a jour le champs %parentbatch qui fait le liens entre la ligne de Batch et les lignes de records
			&sql(update CFAO_HUBIC_BofficeConf_recordMap_EnvoiCSV.Record set %ParentBatch = :varIdbatch where ID = :varIdrecordDeb)
			
			Set ..TotalDeviseGlobal = ..TotalDeviseGlobal + varAMOUNT1
			Set ..TotalEURGlobal = ..TotalEURGlobal + varAMOUNT2
		}
	}
			
	
	If ('CreationLigne){ 
		Set ..NbError = 1
		Set ..MessError = "Erreur d'enregistrement de la ligne Forex : "_varIDForex
	}
				
	// Mise en variable de la valeur TRADETYPESHORTNAME
	Set ..lastvarCPTYSHORTNAME = varCPTYSHORTNAME
	
	
	Quit $$$OK
}

/// 
/// 
/// 
/// 
/// 
/// cette methode fait le lien entre le BS et sa Cible target
ClassMethod OnGetConnections(pArray As %String, item As Ens.Config.Item) As %Status
{
	Set (tValue,tIndex)="" For { Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""  Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigNames" Set tValue=tSetting.Value  Quit
	}
	For i=1:1:$L(tValue,",") { Set tOne=$ZStrip($P(tValue,",",i),"<>W")  Continue:""=tOne  Set pArray(tOne)="" }
}

}
