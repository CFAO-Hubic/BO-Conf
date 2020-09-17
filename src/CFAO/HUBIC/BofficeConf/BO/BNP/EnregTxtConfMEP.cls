Class CFAO.HUBIC.BofficeConf.BO.BNP.EnregTxtConfMEP Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

Property Prefix As %String [ InitialExpression = "BNP" ];

Property FiltreReference As %String [ InitialExpression = "Référence de l'Opération de Change" ];

Property FiltreDateValeur As %String [ InitialExpression = "Date de Paiement" ];

Property FiltreTradeDate As %String [ InitialExpression = "Date de Conclusion" ];

Property FiltreUTI As %String [ InitialExpression = "UTI" ];

Property FiltreCours As %String [ InitialExpression = "Le cours de change appliqué est de" ];

Property FiltreVente As %String [ InitialExpression = "Montant et Devise payable par Partie A" ];

Property FiltreAchat As %String [ InitialExpression = "Montant et Devise payable par Partie B" ];

Property MontantDevise As %String;

Property Devise As %String;

/// /Method EnregEtRapprochePJ(pRequest As %Library.FileCharacterStream, Output pResponse As %Library.Persistent) As %Status
/// This is the default message handler.  All request types not declared in the message map are delivered here
Method EnregEtRapprochePJ(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	
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
	
	Set NomBanquesCB = "BNP"
	Set TypeConfirmation= "MEP"
	Set NomDuFichierConfirmation = ""
	Set Contrat = "", RefOperation = ""
	Set DateNegoce = "", DateValeur = ""
	Set CoursChange= 0, Sens = ""
	Set NousAchetons= "", NousAchetonsMontant = "", NousAchetonsDevise = ""
	Set NousVendons = "", NousVendonsMontant =  "", NousVendonsDevise = ""
	Set Devise = "", MontantDevise = ""
	Set USIUTI = ""

	Set IDForex = ""
    Set IdEAI = ""
    Set NbRapproche = "Aucun"
	
    
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	While 'pRequest.AtEnd {
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()		
		
		//Nom du fichier traité
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		}  	
		
		//	Contrat et Réference de l'opération ------------------------------------------------------------
		if $Find(LaLigne ,..FiltreReference) > 0 {
			//$$$LOGINFO(LaLigne)
			//  983774096 trn 1 prendre les chiffres
			set ref = $piece(LaLigne,":",2)
			Set RefOperation = $p(ref," ",2)
			Set Contrat= $p(ref," ",2)
					   		
		}
			
		//USI/UTI -----------------------------------------------------------------------------
		/*if $Find(LaLigne,..FiltreUTI) > 0 {
			//$$$LOGINFO(LaLigne)
			Set USIUTI = ..GetUTI(LaLigne)		 
		}*/		   
		
		//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 --------------------------------
		if $Find(LaLigne ,..FiltreTradeDate) > 0 {
			//$$$LOGINFO(LaLigne)
			Set DateNegoce = ..GetDateOperation(LaLigne)	   		
		}
		
		//Date de Valeur ou MATURITE ----------------------------------------------------------
		if $Find(LaLigne ,..FiltreDateValeur) > 0 {
			//$$$LOGINFO(LaLigne)
			Set DateValeur = ..GetDateValeurMaturite(LaLigne)	   		
		}
		
		//Cours de Change ---------------------------------------------------------------------	
		if $Find(LaLigne ,..FiltreCours) > 0 {
			//$$$LOGINFO(LaLigne)
			Set CoursChange = ..GetCoursChange(LaLigne)			   		
		}
		
		//NOUS ACHETONS + Sens ----------------------------------------------------------------
		if $Find(LaLigne , ..FiltreVente) > 0 {
			Set NousAchetons = $replace($piece(LaLigne,":",2)," ","")
			if NousAchetons '= "" {
				Set NousAchetonsMontant = $extract(NousAchetons,4,*)
				Set NousAchetonsDevise = $extract(NousAchetons,1,3)
			}			
		}
		//NOUS VENDONS ------------------------------------------------------------------------	
		if $Find(LaLigne ,..FiltreAchat) > 0 {
			Set NousVendons = $replace($piece(LaLigne,":",2)," ","")
			
			if NousVendons '= "" {
				Set NousVendonsMontant =  $extract(NousVendons,4,*)
				Set NousVendonsDevise = $extract(NousVendons,1,3)
				
				/*If NousVendonsDevise '= "EUR"{
					SET Sens = "V"
					SET MontantDevise = NousVendonsMontant
					SET Devise = NousVendonsDevise
				}else{
					SET Sens = "A"
					SET MontantDevise = NousAchetonsMontant
					SET Devise = NousAchetonsDevise
				}*/
			}	
		}					
		
	} // Fin de While ('request.AtEnd = 0)
	// ****************************************************************************************************************
	
	
	// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
	$$$LOGINFO("" _NomBanquesCB _ "-" _ TypeConfirmation _ "-" _ NousAchetonsDevise _ "-" _ NousVendonsDevise)
	Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "V" SET MontantDevise = NousVendonsMontant, Devise = NousVendonsDevise
	If Sens = "A" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDevise,","){
		Set MontantDevise = $Replace(MontantDevise,",",".")
		Set MontantDevise = $Replace(MontantDevise," ","")
		Set MontantDevise = $piece(MontantDevise,".",1)
	}  
	$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)
	// **********************************************************************************************************************************************************
	
	
	
	
     
		
     
    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent
    If (DateValeur="") || (Devise="") || (MontantDevise="") || (CoursChange=0) {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "BNP - Valeur de rapprochement manquante!@@!"
    }
    
    //On verifie que UTI est bien present
    /*If (USIUTI ="") {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = ErrorBoDescription_"BNP - La valeur UTI est non conforme!@@!"
    }*/
    
    
   
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
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
    }
	// ****************************************************************************************************************
	//$$$LOGINFO("NbRapproche : "_NbRapproche)
	
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
	$$$LOGINFO("Sens CB :"_Sens) 
	$$$LOGINFO("NomDuFichierConfirmation CB :"_NomDuFichierConfirmation) 
	$$$LOGINFO("NomBanquesCB CB :"_NomBanquesCB) 
	$$$LOGINFO("TypeConfirmation CB :"_TypeConfirmation) 
	$$$LOGINFO("DateTraitement CB :"_DateTraitement) 
	$$$LOGINFO("DateTraitTIMESTAMP CB :"_DateTraitTIMESTAMP) 
	$$$LOGINFO("IDForex CB :"_IDForex) 
	$$$LOGINFO("IdEAIJrnForex CB :"_IdEAIJrnForex) 
	$$$LOGINFO("ErrorBo CB :"_ErrorBo) 
	$$$LOGINFO("TypeConfirmation CB :"_TypeConfirmation) */
	
	
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
	
	
	
	
	
	
	
	
	
	// ****************************************************************************************************************
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
	Set LaConfirmationBanques.DateTraitementCB = DateTraitement // format "YYYYMMJJ" 
	Set LaConfirmationBanques.DateTraitementTimeStampCB = DateTraitTIMESTAMP
	Set LaConfirmationBanques.StatutRapprocherCB = "NON"
	Set LaConfirmationBanques.StatutEnvoiForexCB = "NON"
}

/// Récupere UTI dans la ligne traité
Method GetUTI(Ligne As %String) As %String
{
	// UTI:1030247694REVO.ZX9-IICZ-VL00-EVBR.0/Swap Data Repository : DTCC
	// Prendre tout avant le '/'
	set USIUTI = $replace($piece(Ligne,":",2)," ","")
	set USIUTI = $p(USIUTI,"/",1)
 	return USIUTI
}

Method GetDateOperation(Ligne As %String) As %String
{
	// Appel à la methode de mise en forme des date
	return ##class(BNPUtils).FormatDateEmir($piece(Ligne,":",2))
}

Method GetDateValeurMaturite(Ligne As %String) As %String
{
	// Appel à la methode de mise en forme des date
	return ##class(BNPUtils).FormatDateEmir($piece(Ligne,":",2))
}

Method GetCoursChange(Ligne As %String) As %String
{
	Set CoursChange = $piece(Ligne,":",2)
	set CoursChange = $piece(CoursChange," ",2)

	if $Extract(CoursChange,1,1)="."{
		Set CoursChange = "0"_CoursChange
	}
	
	Set CoursChange = $replace(CoursChange,",",".")
		
	return CoursChange
}

/// GetMontantAchat ===> Nous achetons Montant
Method GetMontantAchat(Ligne As %String) As %String
{
	Set MontantDevise = ""
	Set NousVendons = $replace($piece(Ligne,":",2)," ","")
	if NousVendons '= "" {
		
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET ..MontantDevise = NousVendonsMontant
			SET ..Devise = NousVendonsDevise
		}else{
				SET Sens = "V"
				SET ..MontantDevise = NousVendonsMontant
				SET ..Devise = NousVendonsDevise
		}
	}
	
	set MontantDevise = ..MontantDevise
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDevise,"."){
		Set MontantDevise = $piece(MontantDevise,".",1)
	}  
		
	Set MontantDevise = $Replace(MontantDevise,",",".")
	Set MontantDevise = $Replace(MontantDevise," ","")		
	
	return MontantDevise
}

/// GetDeviseAchat ===> Nous achetons Devise
Method GetDeviseAchat(Ligne As %String) As %String
{
	set Devise = "" 
	Set NousVendons = $replace($piece(Ligne,":",2)," ","")
	
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET MontantDevise = NousVendonsMontant
			SET Devise = NousVendonsDevise
		}
		
	}
	return NousVendonsDevise
}

Method GetMontantVente(Ligne As %String) As %String
{
	set MontantDevise = ""
	Set NousVendons = $replace($piece(Ligne,":",2)," ","")
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET ..MontantDevise = NousVendonsMontant
			SET ..Devise = NousVendonsDevise
		}else{
				SET Sens = "V"
				SET ..MontantDevise = NousVendonsMontant
				SET ..Devise = NousVendonsDevise
		}
	}
	
	
	set MontantDevise = ..MontantDevise
	
	/**
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDevise,"."){
		Set MontantDevise = $piece(MontantDevise,".",1)
	}  
	**/	
	Set MontantDevise = $Replace(MontantDevise,",",".")
	Set MontantDevise = $Replace(MontantDevise," ","")			
	
	return MontantDevise
}

Method GetDeviseVente(Ligne As %String) As %String
{
	set Devise = "" 
	
	Set NousVendons = $replace($piece(Ligne,":",2)," ","")
	
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		
		If NousVendonsDevise = "EUR"{
				SET Sens = "V"
				SET MontantDevise = NousVendonsMontant
				SET Devise = NousVendonsDevise
		}
	}
	return NousVendonsDevise
}

Method GetSens(Ligne As %String) As %String
{
	Set NousVendons = $replace($piece(Ligne,":",2)," ","")
	if NousVendons '= "" {
		Set NousVendonsMontant =  $extract(NousVendons,4,*)
		Set NousVendonsDevise = $extract(NousVendons,1,3)
		
		If NousVendonsDevise '= "EUR"{
			SET Sens = "A"
			SET MontantDevise = NousVendonsMontant
			SET Devise = NousVendonsDevise
		}else{
				SET Sens = "V"
				SET MontantDevise = NousVendonsMontant
				SET Devise = NousVendonsDevise
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
