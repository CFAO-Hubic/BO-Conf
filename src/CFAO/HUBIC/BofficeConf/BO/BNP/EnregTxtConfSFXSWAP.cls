Class CFAO.HUBIC.BofficeConf.BO.BNP.EnregTxtConfSFXSWAP Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

Property Prefix As %String [ InitialExpression = "BNP" ];

Property FiltreReference As %String [ InitialExpression = "Notre référence" ];

Property FiltreDateValeur As %String [ InitialExpression = "Date de valeur" ];

Property FiltreTradeDate As %String [ InitialExpression = "Date d'opération" ];

Property FiltreUTI As %String [ InitialExpression = "UTI/USI" ];

Property FiltreCours As %String [ InitialExpression = "Cours à terme" ];

Property FiltreVente As %String [ InitialExpression = "Nous vendons" ];

Property FiltreAchat As %String [ InitialExpression = "Nous achetons" ];

/// /Method EnregEtRapprochePJ(pRequest As %Library.FileCharacterStream, Output pResponse As %Library.Persistent) As %Status
/// This is the default message handler.  All request types not declared in the message map are delivered here
Method EnregEtRapprochePJ(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	
	// Instanciation de la Response *****************************************************************************
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = ""
	Set i = 0
	Set ErrorBo = "OK"
	Set ErrorBoDescription = ""
	Set TypeConfirmation= "LEVEE/PRORO"
	Set USIUTI = ""
	
	$$$LOGINFO("DEBUT ************************ DEBUT")
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()		
		
		//Nom du fichier traité
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		}  	
		
		//	Contrat et Réference de l'opération ------------------------------------------------------------
		if $Find(LaLigne ,..FiltreReference) > 0 {
			Set RefOperation = $replace($piece(LaLigne,":",2)," ","")
			Set Contrat= $replace($piece(LaLigne,":",2)," ","")		   		
		}
			
		//	USI/UTI -----------------------------------------------------------------------------
		/*if $Find(LaLigne,..FiltreUTI) > 0 {
			Set USIUTI = ..GetUTI(LaLigne)		 
		}*/		   
		
		//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 --------------------------------
		if $Find(LaLigne ,..FiltreTradeDate) > 0 {
			Set DateNegoce = ..GetDateOperation(LaLigne)	   		
		}
		
		//Date de Valeur ou MATURITE ----------------------------------------------------------
		if $Find(LaLigne ,..FiltreDateValeur) > 0 {
			Set DateValeur = ..GetDateValeurMaturite(LaLigne)	   		
		}
		
		//Cours de Change ---------------------------------------------------------------------	
		if $Find(LaLigne ,..FiltreCours) > 0 {
			Set CoursChange = ..GetCoursChange(LaLigne)			   		
		}
		
		//NOUS ACHETONS + Sens ----------------------------------------------------------------
		if $Find(LaLigne ,..FiltreAchat) > 0 {
			Set NousAchetonsMontant = ..GetMontantAchat(LaLigne)
			Set NousAchetonsDevise = ..GetDeviseAchat(LaLigne)		
		}
		//NOUS VENDONS ------------------------------------------------------------------------	
		if $Find(LaLigne ,..FiltreVente) > 0 {
			SET Sens = ..GetSens(LaLigne)
			SET MontantDevise = ..GetMontantVente(LaLigne)
			SET Devise = ..GetDeviseVente(LaLigne)
						
		}
		
	} // Fin de While ('request.AtEnd = 0)

     
    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent
    If (DateValeur="") || (Devise="") || (MontantDevise="") || (CoursChange=0) {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "BNP - Valeur de rapprochement manquante!@@!"
    }
    
    //On verifie que UTI est bien present
    /*If (USIUTI="") {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = ErrorBoDescription_"BNP - La valeur UTI est non conforme!@@!"
    }*/
    
	  
	// $$$LOGINFO("ErrorBo Av Requete: "_ErrorBo) 
    
    If ErrorBo = "OK" {     
           
        //Requete pour les MEP de SG
    	&sql(Select count(*),IDForex,ID into :NbRapproche, :IDForex, :IdEAIJrnForex 
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where MATURITYDATE = :DateValeur    
	    and   CPTYSHORTNAME = 'BNP' 
	    and   CURRENCY1SHORTNAME = :Devise
	    and   AMOUNT1 = :MontantDevise
	    and   CLIENTRATE = :CoursChange
	    and   SensVouA = :Sens
	    and   rapprocherOUINON = 'NON')	    
	    
     	
     	//$$$LOGINFO("IDForex :"_IDForex)
	    //$$$LOGINFO("IdEAIJrnForex :"_IdEAIJrnForex)	    
    }  
    
    
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
	
	  
	 
	//================================================================================================================================
	//Identique pour tous les BO d'integration des confirmation de banques ===========================================================
	//DEBUT insert les données dans la tables des confirmations bancaires ***********************************************
	Set LaConfirmationBanques =  ##class(CFAO.HUBIC.EMIRtools.Table.ConfirmationBanques).%New()
	Set LaConfirmationBanques.FilenameCB = "BNP"_$Replace(RefOperation,"/","-")_".txt" 
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
	Set LaConfirmationBanques.NomBanquesCB = "BNP" // Entité du journal forex
	Set LaConfirmationBanques.TypeConfirmationCB = TypeConfirmation	
	Set LaConfirmationBanques.DateTraitementCB = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ" 
	Set LaConfirmationBanques.DateTraitementTimeStampCB = ..GetDate()
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
			Set LaLigneJrnForex.DateRapprochement = ..GetDate()
			Set MajLigneJrnForexStatut =  LaLigneJrnForex.%Save()
			If ('MajLigneJrnForexStatut){
				Set ErrorBo = "WAR"
	    		Set ErrorBoDescription = ErrorBoDescription_"BNP - Erreur de mise a jour du statut rapporchement JrnForex pour ID Forex : "_IDForex_"!@@!"
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
	    Set ErrorBoDescription = ErrorBoDescription_"BNP - Erreur de sauvegarde de la confirmation pour le contrat: "_Contrat_"!@@!"
	}
	//FIN insert les données dans la tables des confirmations bancaires ***********************************************
	
	
	Set Banques = "BNP"
	//$$$LOGINFO("ErrorBo 3b :"_ErrorBo)
	If ErrorBo = "OK" {
		$$$LOGINFO("Fichier OK : "_NomDuFichierConfirmation_" Avec "_NbRapproche_" rapprochement")
		set pResponse.StringValue = "0!##!"_Banques_"!##!Aucune"
	}else{
		If ErrorBo = "WAR" {
			$$$LOGINFO("Fichier WAR :"_NomDuFichierConfirmation)
			set pResponse.StringValue = "1!##!"_Banques_"!##!"_ErrorBoDescription
		}
		If ErrorBo = "ERR" {
			$$$LOGINFO("Fichier ERR :"_NomDuFichierConfirmation)
			set pResponse.StringValue = "2!##!"_Banques_"!##!"_ErrorBoDescription
		}
	}
	//Identique pour tous les BO d'integration des confirmation de banques ===========================================================
	//================================================================================================================================
	
 	//$$$LOGINFO("FIN   ************************")
 	Quit $$$OK
}

Method GetDate() As %String
{
	Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ" 
	Set AnnéeSaisie = $extract(DateTraitement,1,4)
	Set MoisSaisie =  $extract(DateTraitement,5,6)
	Set jourSaisie =  $extract(DateTraitement,7,8)
	Set Htime=$PIECE($HOROLOG,",",2)
	Set ltime = $ZTIME(Htime,1) 
	Set DateTraitTIMESTAMP = AnnéeSaisie_"-"_MoisSaisie_"-"_jourSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"	
	
	return DateTraitTIMESTAMP
}

/// insert les données dans la tables des confirmations bancaires
Method InsertDataToConfirmationBanques(RefOperation, Contrat, USIUTI, DateNegoce, DateValeur, CoursChange, NousAchetonsMontant, NousAchetonsDevise, NousVendonsMontant, NousVendonsDevise, Sens, Devise, MontantDevise, TypeConfirmation, DateTraitement, DateTraitTIMESTAMP) As %Status
{
	// DEBUT insert les données dans la tables des confirmations bancaires
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
	Set LaConfirmationBanques.NomBanquesCB = "BNP" // Entité du journal forex
	Set LaConfirmationBanques.TypeConfirmationCB = TypeConfirmation	
	Set LaConfirmationBanques.DateTraitementCB = DateTraitement // format "YYYYMMJJ" 
	Set LaConfirmationBanques.DateTraitementTimeStampCB = DateTraitTIMESTAMP
	Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	Set LaConfirmationBanques.StatutEnvoiForexCB = "NON"
}

/// Récupere UTI dans la ligne traité
Method GetUTI(Ligne As %String) As %String
{
 	return USIUTI= $replace($piece(LaLigne,":",2)," ","")
}

Method GetDateOperation(Ligne As %String) As %String
{
	// Appel à la methode de mise en forme des date
	return ##class(BNPUtils).FormatDateEmir($piece(Ligne,":",2))
}

Method GetDateValeurMaturite(Ligne As %String) As %String
{
	// Appel à la methode de mise en forme des date
	return ##class(BNPUtils).FormatDateEmir($piece(LaLigne,":",2))
}

Method GetCoursChange(Ligne As %String) As %String
{
	Set CoursChange = $replace($piece(LaLigne,":",2)," ","")
	Set CoursChange = (CoursChange * 1)	
	if $Extract(CoursChange,1,1)="."{
		Set CoursChange = "0"_CoursChange
	}
	
	return CoursChange
}

Method GetMontantAchat(Ligne As %String) As %String
{
	Set NousAchetons = $replace($piece(LaLigne,":",2)," ","")
	if NousAchetons '= "" {
		Set NousAchetonsMontant = $extract(NousAchetons,4,*)
		Set NousAchetonsDevise = $extract(NousAchetons,1,3)
	}
	
	return NousAchetonsMontant
}

Method GetDeviseAchat(Ligne As %String) As %String
{
	Set NousAchetons = $replace($piece(LaLigne,":",2)," ","")
	if NousAchetons '= "" {
		Set NousAchetonsMontant = $extract(NousAchetons,4,*)
		Set NousAchetonsDevise = $extract(NousAchetons,1,3)
	}
	
	return NousAchetonsDevise
}

Method GetMontantVente(Ligne As %String) As %String
{
	Set NousVendons = $replace($piece(LaLigne,":",2)," ","")
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET MontantDevise = NousVendonsMontant
			SET Devise = NousVendonsDevise
		}else{
				SET Sens = "V"
				SET MontantDevise = NousAchetonsMontant
				SET Devise = NousAchetonsDevise
		}
	}
	
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDevise,"."){
		Set MontantDevise = $piece(MontantDevise,".",1)
	}  
		
	Set MontantDevise = $Replace(MontantDevise,",","")
	Set MontantDevise = $Replace(MontantDevise," ","")		
	
	return MontantDevise
}

Method GetDeviseVente(Ligne As %String) As %String
{
	Set NousVendons = $replace($piece(LaLigne,":",2)," ","")
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET MontantDevise = NousVendonsMontant
			SET Devise = NousVendonsDevise
		}else{
				SET Sens = "V"
				SET MontantDevise = NousAchetonsMontant
				SET Devise = NousAchetonsDevise
		}
	}
	return Devise
}

Method GetSens(Ligne As %String) As %String
{
		Set NousVendons = $replace($piece(LaLigne,":",2)," ","")
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET MontantDevise = NousVendonsMontant
			SET Devise = NousVendonsDevise
		}else{
				SET Sens = "V"
				SET MontantDevise = NousAchetonsMontant
				SET Devise = NousAchetonsDevise
		}
	}
	return Sens
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="%Stream.FileCharacter"> 
		<Method>EnregEtRapprochePJ</Method>
	</MapItem>
</MapItems>
}

}
