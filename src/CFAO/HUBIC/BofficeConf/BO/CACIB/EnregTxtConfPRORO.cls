Class CFAO.HUBIC.BofficeConf.BO.CACIB.EnregTxtConfPRORO Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method EnregEtRapprochePJ(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{

	// OK POUR cette classe Passage par fonction
	
	// Instanciation de la Response ***********************************************************************************
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = ""
	// ****************************************************************************************************************	
	
	
	
	// Mise en variable de la date du jour ****************************************************************************
	Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ"
	Set AnnéeSaisie = $extract(DateTraitement,1,4)
	Set MoisSaisie =  $extract(DateTraitement,5,6)
	Set jourSaisie =  $extract(DateTraitement,7,8)
	Set Htime=$PIECE($HOROLOG,",",2)
	Set ltime = $ZTIME(Htime,1)
	set DateTraitTIMESTAMP = AnnéeSaisie_"-"_MoisSaisie_"-"_jourSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"
	// ****************************************************************************************************************	
	
	// Instanciation des variable
	Set i = 0
	Set ErrorBo = "OK"
	Set ErrorBoDescription = ""
	
	Set NomBanquesCB = "CA"
	Set TypeConfirmation= "PRORO"
	Set NomDuFichierConfirmation = ""
	Set Contrat = "", RefOperation = ""
	Set DateNegoce = "", DateValeur = ""
	Set CoursChange= 0, Sens = ""
	Set NousAchetons= "", NousAchetonsMontant = "", NousAchetonsDevise = ""
	Set NousVendons = "", NousVendonsMontant =  "", NousVendonsDevise = ""
	Set Devise = "", MontantDevise = ""
	
	Set IDForex = ""
    Set IdEAI = ""
    Set NbRapproche = "Aucun"
        
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	While 'pRequest.AtEnd {
		Set i = i + 1
		Set LaLigne = pRequest.ReadLine()
		
		//Nom du fichier traité -------------------------------------
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		}
		//Contrat et Réference de l'opération -----------------------
		if $Find(LaLigne ,"otre référence") > 0 {
			Set RefOperation = $replace($piece(LaLigne,":",2)," ","")
			Set Contrat= $replace($piece(LaLigne,":",2)," ","")
		}
		//DATE DE NÉGOCIATION ou TRADE DATE -------------------------
		if $Find(LaLigne ,"Date d'opération") > 0 {
			Set DateNegoce = $piece(LaLigne,":",2)
		}
		//Date de Valeur ou MATURITE --------------------------------
		if $Find(LaLigne ,"Date d'échéance") > 0 {
			Set DateValeur = $piece(LaLigne,":",2)
		}
		//Cours de Change -------------------------------------------
		if $Find(LaLigne ,"Cours à terme") > 0 {
			Set CoursChange = $replace($piece(LaLigne,":",2)," ","")
			Set CoursChange = (CoursChange * 1)
			if $Extract(CoursChange,1,1)="."{
				Set CoursChange = "0"_CoursChange
			}
		}
		//NOUS ACHETONS + Sens --------------------------------------
		if $Find(LaLigne ,"Nous achetons") > 0 {
			Set NousAchetons = $replace($piece(LaLigne,":",2)," ","")
			if NousAchetons '= "" {
				Set NousAchetonsMontant = $extract(NousAchetons,4,*)
				Set NousAchetonsDevise = $extract(NousAchetons,1,3)
			}
		}
		//NOUS VENDONS ----------------------------------------------
		if $Find(LaLigne ,"Nous vendons") > 0 {
			Set NousVendons = $replace($piece(LaLigne,":",2)," ","")
			if NousVendons '= "" {
				Set NousVendonsMontant =  $extract(NousVendons,4,*)
				Set NousVendonsDevise = $extract(NousVendons,1,3)
				/*If NousVendonsDevise '= "EUR"{
					SET Sens = "A"
					SET MontantDevise = NousVendonsMontant
					SET Devise = NousVendonsDevise
				}else{
					SET Sens = "V"
					SET MontantDevise = NousAchetonsMontant
					SET Devise = NousAchetonsDevise
				}*/
			}
		}
		
		//Mise en forme du montant de la devise en entier
		/*if $Find(MontantDevise,"."){
			Set MontantDevise = $piece(MontantDevise,".",1)
		}
		Set MontantDevise = $Replace(MontantDevise,",","")
		Set MontantDevise = $Replace(MontantDevise," ","")*/
	} // Fin de While ('request.AtEnd = 0)
	// ****************************************************************************************************************
	
	
	// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
	$$$LOGINFO(NomBanquesCB _ "-" _ TypeConfirmation _ "-" _ NousAchetonsDevise _ "-" _ NousVendonsDevise)
	Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "A" SET MontantDevise = NousVendonsMontant, Devise = NousVendonsDevise
	If Sens = "V" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDevise,"."){
		Set MontantDevise = $piece(MontantDevise,".",1)
	}
	Set MontantDevise = $Replace(MontantDevise,",","")
	Set MontantDevise = $Replace(MontantDevise," ","")
	$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)
	// **********************************************************************************************************************************************************
	
	
	
	//DEBUT Mise en forme des dates pour la clause where de la requete de rapprochement *******************************
	//TRADEDATE du JrnForex:2014-03-03 <==> Date de negoce de la confirmation 03-MAR-2014
	if (DateNegoce '= ""){
		Set DateNegoce = ..FormatDateConf(DateNegoce)
	}
	
	//MATURITYDATE du JrnForex :2014-02-03 <==> Date de Valeur 03-FEV-2014
	if (DateValeur '= ""){
		Set DateValeur = ..FormatDateConf(DateValeur)
	}
	// ****************************************************************************************************************
    
    
    
    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent ************************
    If (DateValeur="") || (Devise="") || (MontantDevise="") || (CoursChange=0) {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "CACIBLEVEE - Valeur de rapprochement manquante!@@!"
    }
	// ****************************************************************************************************************
	
	
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
    If ErrorBo = "OK" {
        Set IDForex = ""
    	Set IdEAI = ""
        Set NbRapproche = "Aucun"
    	&sql(Select count(*),IDForex,ID into :NbRapproche, :IDForex, :IdEAIJrnForex 
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where MATURITYDATE = :DateValeur 
	    and   CPTYSHORTNAME = 'CA' 
	    and   CURRENCY1SHORTNAME = :Devise
	    and   AMOUNT1 = :MontantDevise
	    and   CLIENTRATE = :CoursChange
	    and   SensVouA = :Sens
	    and   rapprocherOUINON = 'NON')
    }
	// ****************************************************************************************************************


	// Enregistrement de la Conf avec Raprochement OUI ou NON *********************************************************
	If ErrorBo = "OK"{
		// insert des données dans la tables des confirmations bancaires
		Set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).SaveConfBanque(
											NomDuFichierConfirmation ,Contrat,DateNegoce,DateValeur,
											CoursChange,NousAchetonsMontant,NousVendonsMontant,
											NousAchetonsDevise,NousVendonsDevise,Sens,Devise,
											MontantDevise,NomBanquesCB,TypeConfirmation,
											DateTraitement,DateTraitTIMESTAMP,IDForex,IdEAIJrnForex,NbRapproche,ErrorBo)
		
		//$$$LOGINFO("EnregConfBanqueComptant : "_EnregConfBanqueComptant)
		If $Piece(EnregConfBanqueComptant,"!##!",1) '= "OK" {
			Set ErrorBo = $Piece(EnregConfBanqueComptant,"!##!",1)
	    	Set ErrorBoDescription = $Piece(EnregConfBanqueComptant,"!##!",2)	    	
		}else{
			Set IdEAIconfbanque = $Piece(EnregConfBanqueComptant,"!##!",3)
		}
		
		If NbRapproche = 1 {
			Set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).SaveRapproLigneJRN(DateTraitTIMESTAMP, IdEAIJrnForex, NbRapproche,NomDuFichierConfirmation,Contrat)
		}
	}
	// ****************************************************************************************************************
	
	
	
	// Envoi du mail a la banque **************************************************************************************		
	If NbRapproche = 1 {
		Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(NomBanquesCB,NomDuFichierConfirmation,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanque,IdEAIJrnForex,Contrat)
		If SendEmailGeneric '= "OK"{
			 Set ErrorBo = "WAR"
			 Set ErrorBoDescription = SendEmailGeneric
		}
	}	
	// ****************************************************************************************************************
	
	 
	
	
	// ***************************************************************************************************************
	If ErrorBo = "OK" {
		$$$LOGINFO("Fichier OK : "_NomDuFichierConfirmation_" Avec "_NbRapproche_" rapprochement")
		set pResponse.StringValue = "0!##!"_NomBanquesCB_"!##!Aucune"
	}else{
		If ErrorBo = "WAR" {
			$$$LOGINFO("Fichier WAR :"_NomDuFichierConfirmation)
			set pResponse.StringValue = "1!##!"_NomBanquesCB_"!##!"_ErrorBoDescription
		}
		If ErrorBo = "ERR" {
			$$$LOGINFO("Fichier ERR :"_NomDuFichierConfirmation)
			set pResponse.StringValue = "2!##!"_NomBanquesCB_"!##!"_ErrorBoDescription
		}
	}
	// ****************************************************************************************************************
	
 	Quit $$$OK
}

/// Transfo des date dans le format attendu
ClassMethod FormatDateConf(DateConf As %String) As %Status
{
 
    Set JourDate = $piece(DateConf," ",2)
	Set MoisDate = $piece(DateConf," ",3)
	Set AnneeDate = $piece(DateConf," ",4)
	If MoisDate = "janvier" Set MoisDate = "01"
	If MoisDate = "février" Set MoisDate = "02"
	If MoisDate = "mars" Set MoisDate = "03"
	If MoisDate = "avril" Set MoisDate = "04"
	If MoisDate = "mai" Set MoisDate = "05"
	If MoisDate = "juin" Set MoisDate = "06"
	If MoisDate = "juillet" Set MoisDate = "07"
	If MoisDate = "août" Set MoisDate = "08"
	If MoisDate = "aout" Set MoisDate = "08"
	If MoisDate = "septembre" Set MoisDate = "09"
	If MoisDate = "octobre" Set MoisDate = "10"
	If MoisDate = "novembre" Set MoisDate = "11"
	If MoisDate = "décembre" Set MoisDate = "12"	
    Set DateBoConf =  AnneeDate_"-"_MoisDate_"-"_JourDate
    Set DateBoConf = $Replace(DateBoConf," ","")
    
    Quit DateBoConf
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="%Stream.FileCharacter"> 
		<Method>EnregEtRapprochePJ</Method>
	</MapItem>
</MapItems>
}

/*
	$$$LOGINFO("Contrat CB :"_Contrat)
	$$$LOGINFO("RefOperation : "_RefOperation)		
	$$$LOGINFO("USIUTI CB :"_USIUTI)     
	$$$LOGINFO("DateNegoce CB :"_DateNegoce)	
	$$$LOGINFO("DateValeur CB :"_DateValeur)
	$$$LOGINFO("CoursChange CB :"_CoursChange)
	$$$LOGINFO("NousAchetonsMontant CB :"_NousAchetonsMontant)
	$$$LOGINFO("NousAchetonsDevise CB :"_NousAchetonsDevise) 
	$$$LOGINFO("NousVendonsMontant CB :"_NousVendonsMontant) 
	$$$LOGINFO("NousVendonsDevise CB :"_NousVendonsDevise) 
	$$$LOGINFO("Devise CB :"_Devise)
	$$$LOGINFO("MontantDeviseEntier CB :"_MontantDevise)
	$$$LOGINFO("Sens CB :"_Sens)
	
	Set JourDateNegoce = $piece(DateNegoce," ",2)
		Set MoisDateNegoce = $piece(DateNegoce," ",3)
		Set AnneeDateNegoce = $piece(DateNegoce," ",4)
		//Jan Feb MAR APR MAY JUN JUL AUG SEP OCT NOV DEC
		If MoisDateNegoce = "janvier" Set MoisDateNegoce = "01"
		If MoisDateNegoce = "février" Set MoisDateNegoce = "02"
		If MoisDateNegoce = "mars" Set MoisDateNegoce = "03"
		If MoisDateNegoce = "avril" Set MoisDateNegoce = "04"
		If MoisDateNegoce = "mai" Set MoisDateNegoce = "05"
		If MoisDateNegoce = "juin" Set MoisDateNegoce = "06"
		If MoisDateNegoce = "juillet" Set MoisDateNegoce = "07"
		If MoisDateNegoce = "août" Set MoisDateNegoce = "08"
		If MoisDateNegoce = "aout" Set MoisDateNegoce = "08"
		If MoisDateNegoce = "septembre" Set MoisDateNegoce = "09"
		If MoisDateNegoce = "octobre" Set MoisDateNegoce = "10"
		If MoisDateNegoce = "novembre" Set MoisDateNegoce = "11"
		If MoisDateNegoce = "décembre" Set MoisDateNegoce = "12"	
	    Set DateNegoce =  AnneeDateNegoce_"-"_MoisDateNegoce_"-"_JourDateNegoce	   //Format 2014-03-03
	    Set DateNegoce = $Replace(DateNegoce," ","") 
	    
	    //================================================================================================================================
	//Identique pour tous les BO d'integration des confirmation de banques ===========================================================
	//DEBUT insert les données dans la tables des confirmations bancaires ***********************************************
	Set LaConfirmationBanques =  ##class(CFAO.HUBIC.EMIRtools.Table.ConfirmationBanques).%New()
	Set LaConfirmationBanques.FilenameCB = "CA"_$Replace(RefOperation,"/","-")_".txt"
	Set LaConfirmationBanques.ContratCB = Contrat
	Set LaConfirmationBanques.USIUTICB = USIUTI
	Set LaConfirmationBanques.DateNegoceCB = DateNegoce
	Set LaConfirmationBanques.DateValeurCB = DateValeur
	Set LaConfirmationBanques.CoursDeChangeCB = CoursChange
	Set LaConfirmationBanques.AcheterMontantCB = NousAchetonsMontant
	Set LaConfirmationBanques.VenduMontantCB = NousVendonsMontant
	Set LaConfirmationBanques.AcheterDeviseCB = NousAchetonsDevise
	Set LaConfirmationBanques.VenduDeviseCB = NousVendonsDevise
	Set LaConfirmationBanques.SensCB = Sens
	Set LaConfirmationBanques.DeviseCB = Devise
	Set LaConfirmationBanques.MontantDeviseCB = MontantDevise		
	Set LaConfirmationBanques.NomBanquesCB = "CA" // Entité du journal forex
	Set LaConfirmationBanques.TypeConfirmationCB = TypeConfirmation	
	Set LaConfirmationBanques.DateTraitementCB = DateTraitement // format "YYYYMMJJ" 
	Set LaConfirmationBanques.DateTraitementTimeStampCB = DateTraitTIMESTAMP
	Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	Set LaConfirmationBanques.StatutEnvoiForexCB = "NON"
		
	//$$$LOGINFO("ErrorBo 1 :"_ErrorBo)	
	If ErrorBo = "OK"{
		If NbRapproche = 1 {
			//Information contenu dans la ligne de Jouranl Foraex a rajouter sur la ligne des banques
			Set LaConfirmationBanques.IDforexCB = IDForex
			Set LaConfirmationBanques.IdEAIJrnForexCB = IdEAIJrnForex
			Set LaConfirmationBanques.StatutRapprocherCB = "OUI"
			//Enregistrement du statut des erreurs et de leurs descriptions
			Set LaConfirmationBanques.StatutErrorCB = "0"
			Set LaConfirmationBanques.DescErrorCB = "0"
			
			
		//DEBUT MAJ des données dans la tables des lignes de Journaux Forex ***********************************************
		If IdEAIJrnForex '= "" {
			Set LaLigneJrnForex =  ##class(CFAO.HUBIC.EMIRtools.Table.JrnForexEMIR).%OpenId(IdEAIJrnForex)
			Set LaLigneJrnForex.rapprocherOUINON = "OUI"
			Set LaLigneJrnForex.UTIbanques = USIUTI
			Set LaLigneJrnForex.TypeRapprochement = "AUTO"
			Set LaLigneJrnForex.DateRapprochement = DateTraitTIMESTAMP
			Set MajLigneJrnForexStatut =  LaLigneJrnForex.%Save()
			If ('MajLigneJrnForexStatut){
				Set ErrorBo = "WAR"
	    		Set ErrorBoDescription = ErrorBoDescription_"CACIBLEVEE - Erreur de mise a jour du statut rapporchement JrnForex pour ID Forex : "_IDForex_"!@@!"
			}
		}			
		//FIN MAJ des données dans la tables des lignes de Journaux Forex ***********************************************

		//$$$LOGINFO("ErrorBo 2 :"_ErrorBo)	
		}
		If NbRapproche = 0 {
			Set LaConfirmationBanques.StatutErrorCB = "0"
			Set LaConfirmationBanques.DescErrorCB = "0"
			Set LaConfirmationBanques.StatutRapprocherCB = "NON"
		}
		If NbRapproche > 1 {
			Set LaConfirmationBanques.StatutErrorCB = "2"
			Set LaConfirmationBanques.DescErrorCB = "plusieurs demandes trouvées"
			Set ErrorBo = "ERR"
		}
	}
	If ErrorBo = "ERR"{
		Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	} 	
	//$$$LOGINFO("ErrorBo 3a :"_ErrorBo)
	Set EnregConfBanquesStatut = LaConfirmationBanques.%Save()
	
	If ('EnregConfBanquesStatut){
		Set ErrorBo = "ERR"
	    Set ErrorBoDescription = ErrorBoDescription_"CACIBLEVEE - Erreur de sauvegarde de la confirmation pour le contrat: "_Contrat_"!@@!"
	}
	//FIN insert les données dans la tables des confirmations bancaires ***********************************************
	*/
}
