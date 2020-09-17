Class CFAO.HUBIC.BofficeConf.BO.SG.EnregTxtConfLEVEE Extends Ens.BusinessOperation
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
	
	
	Set NomBanquesCB = "SG"
	Set TypeConfirmation= "LEVEE"
	Set IdentifiantFX = ""
	Set NomDuFichierConfirmation = ""
	Set Contrat = "", RefOperation = ""
	Set DateNegoce = "", DateValeur = ""
	Set CoursChange= 0, Sens = ""
	Set NousAchetons= "", NousAchetonsMontant = "", NousAchetonsDevise = ""
	Set NousVendons = "", NousVendonsMontant =  "", NousVendonsDevise = ""
	Set Devise = "", MontantDevise = ""	
	
	Set DebutLigne = ""	
	SET countDebutLigne=""		
	Set FinLigne = ""	
	Set UniteCoursChange = ""
	Set DecimalCoursChange = ""
	Set CoursChangeFinal =""
	
	Set LeMontantDevise= ""
	Set LeMontant= ""	
	Set LigneDuMontantCFAO = 0
	Set LigneDuMontantSG = 0
	
	Set IDForex = ""
    Set IdEAI = ""
    Set NbRapproche = "Aucun"
	
	
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()	
		
		if $Find(LaLigne ,"Paiement à CFAO") > 0 {
			Set LigneDuMontantCFAO = i + 1
		}		
		If LigneDuMontantCFAO = i {
				Set NousVendonsMontant =  $piece(LaLigne," ",1)
				Set NousVendonsDevise = $piece(LaLigne," ",2)
				/*If NousVendonsDevise '= "EUR"{					
					SET Sens = "V"
				}else{
					SET Sens = "A"
				}*/
		}		
		if $Find(LaLigne ,"Paiement à SOCIETE GENERALE") > 0 {
			Set LigneDuMontantSG = i + 1
		}
		If LigneDuMontantSG = i {
			Set NousAchetons= $extract(LaLigne,10,*)	
			If NousAchetons '= "" {
				Set NousAchetonsMontant = $piece(LaLigne," ",1)
				Set NousAchetonsDevise = $piece(LaLigne," ",2)
			}		
		}
		
	}
	Do pRequest.Rewind()
	
	/*$$$LOGINFO("NousVendonsMontant : " _NousVendonsMontant)
	$$$LOGINFO("NousVendonsDevise : " _NousVendonsDevise)
	$$$LOGINFO("NousAchetons : " _NousAchetons)
	$$$LOGINFO("NousAchetonsMontant : " _NousAchetonsMontant)
	$$$LOGINFO("NousAchetonsDevise : " _NousAchetonsDevise)*/
	
	$$$LOGINFO("" _NomBanquesCB _ "-" _ TypeConfirmation _ "-" _ NousAchetonsDevise _ "-" _ NousVendonsDevise)
	// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
	Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "A" 
	If Sens = "V" 
	$$$LOGINFO("Table : " _Sens)
	// **********************************************************************************************************************************************************
	
		
	//Recherche de l'information Identifiant . Transaction afin de savoir 
	//qu'elle ligne du tableau contient les données de confirmation
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()		
		if $Find(LaLigne,"La date de levée anticipée pour toutes les Opérations est fixée au") > 0 {
			Set LaDateLib= $piece(LaLigne,"au ",2)
			Set LaDateLib= $piece(LaDateLib," (",1)
			Set LeJourLib = $piece(LaDateLib," ",1)
			Set LeMoisLib = $piece(LaDateLib," ",2)
			Set LeAnneeLib = $piece(LaDateLib," ",3)
			If LeMoisLib = "janvier" Set LeMoisLib = "01"
			If LeMoisLib = "février" Set LeMoisLib = "02"
			If LeMoisLib = "mars" Set LeMoisLib = "03"
			If LeMoisLib = "avril" Set LeMoisLib = "04"
			If LeMoisLib = "mai" Set LeMoisLib = "05"
			If LeMoisLib = "juin" Set LeMoisLib = "06"
			If LeMoisLib = "juillet" Set LeMoisLib = "07"
			If LeMoisLib = "août" Set LeMoisLib = "08"
			If LeMoisLib = "aout" Set LeMoisLib = "08"
			If LeMoisLib = "septembre" Set LeMoisLib = "09"
			If LeMoisLib = "octobre" Set LeMoisLib = "10"
			If LeMoisLib = "novembre" Set LeMoisLib = "11"
			If LeMoisLib = "décembre" Set LeMoisLib = "12"
			Set IdentifiantFX =  LeJourLib_"/"_LeMoisLib_"/"_LeAnneeLib	   //Format 2014-03-03
	    	Set IdentifiantFX = $Replace(IdentifiantFX," ","")				
		}		
		If Sens = "V"{
			if $Find(LaLigne,"Paiement à SOCIETE GENERALE") > 0 {
				Set LeMontantDevise= NousAchetonsMontant
				Set LeMontant= NousAchetonsDevise
			}
		}
		If Sens = "A"{
			if $Find(LaLigne,"Paiement à CFAO") > 0 {
				Set LeMontantDevise= NousVendonsMontant
				Set LeMontant= NousVendonsDevise
			}
		}
	}	
	Do pRequest.Rewind()
	
	$$$LOGINFO("IdentifiantFX : " _IdentifiantFX)
	
	
		
	If IdentifiantFX = ""{
		Set ErrorBo = "ErrRetrouveInfo"
	    Set ErrorBoDescription = ErrorBoDescription_"SGLEVEE - le champ Identifiant . Transaction non renseigneé!@@!"		
	}	
	If LeMontant = ""{
		Set ErrorBo = "ErrRetrouveInfo"
	    Set ErrorBoDescription = ErrorBoDescription_"SGLEVEE - le champ Montant non renseigneé!@@!"		
	}
	
	Set i = 0
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()
		
		//Nom du fichier traité
		If i = 1 {
			//Set NomDuFichierConfirmation = $Replace(LaLigne," ","")
			//Set NomDuFichierConfirmation = $piece(NomDuFichierConfirmation,"/",1)_$piece(NomDuFichierConfirmation,"/",2)
			Set NomDuFichierConfirmation = LaLigne
			$$$LOGINFO("PAssage Levee : " _NomDuFichierConfirmation)
			
		}			
		//RefOperation + DateNegoce + DateValeur + CoursChange
		If ($Find(LaLigne,IdentifiantFX)>0) && ($Find(LaLigne,LeMontant)>0){	
			// Contrat ----------------------------------------------
			Set Contrat = $piece(LaLigne," ",1)
			//RefOperation ------------------------------------------
			Set RefOperation = $piece(LaLigne," ",1)
			//Cours de change ---------------------------------------
			Set CoursChange = $piece(LaLigne," ",7)			
			//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 --	
			Set DateNegoce = $piece(LaLigne," ",8)			
			//Date de Valeur ou MATURITE ----------------------------
			Set DateValeur = $piece(LaLigne," ",9)		  		
		}		
		
		
		// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
		/*Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
		If Sens = "A" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
		If Sens = "V" SET MontantDevise = NousVendonsMontant,  Devise = NousVendonsDevise 
		Set MontantDevise = $Replace($piece(MontantDevise,".",1)," ","")
		Set MontantDevise = $Replace(MontantDevise,",","")
		$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)*/
		// **********************************************************************************************************************************************************
		
		/*If NousVendonsDevise '= "EUR"{
			SET Sens = "V"
			SET MontantDevise = NousVendonsMontant
			SET Devise = NousVendonsDevise
		}else{
			SET Sens = "A"
			SET MontantDevise = NousAchetonsMontant
			SET Devise = NousAchetonsDevise
		}		
		//Mise en forme du montant de la devise en entier
		Set MontantDevise = $Replace($piece(MontantDevise,".",1)," ","")
		Set MontantDevise = $Replace(MontantDevise,",","")
		$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)*/
	} // Fin de While ('request.AtEnd = 0)
	// ****************************************************************************************************************
	
	
	
	// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
	Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "A" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
	If Sens = "V" SET MontantDevise = NousVendonsMontant,  Devise = NousVendonsDevise 
	Set MontantDevise = $Replace($piece(MontantDevise,".",1)," ","")
	Set MontantDevise = $Replace(MontantDevise,",","")
	$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)
	//**********************************************************************************************************************************************************
	
	
	
	//DEBUT Mise en forme des dates pour la clause where de la requete de rapprochement *******************************
    //Date de negoce et Tradedate   ==> (TRADEDATE:2014-03-25)=(Date de negoce 25/03/2014)
    if (DateNegoce '= ""){
	    Set JourDateNegoce = $piece(DateNegoce,"/",1)
	    Set MoisDateNegoce = $piece(DateNegoce,"/",2)
	    Set AnneeDateNegoce = $piece(DateNegoce,"/",3)
	    Set DateNegoce = AnneeDateNegoce_"-"_MoisDateNegoce_"-"_JourDateNegoce  //Format 2014-03-25
    }    
    //MATURITYDATE du JrnForex :2014-02-03 <==> Date de Valeur 03-FEV-2014 
    if (DateValeur '= ""){
	    Set JourDateValeur = $piece(DateValeur,"/",1)
	    Set MoisDateValeur = $piece(DateValeur,"/",2)
	    Set AnneeDateValeur = $piece(DateValeur,"/",3)
	    Set DateValeur = AnneeDateValeur_"-"_MoisDateValeur_"-"_JourDateValeur  //Format 2014-03-25
    }
	// ****************************************************************************************************************
	
	
    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent ************************
    If (DateValeur="") || (Devise="") || (MontantDevise="") || (CoursChange=0) {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "SGLEVEE - Valeur de rapprochement manquante!@@!"
    }
	// ****************************************************************************************************************
    
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
    If ErrorBo = "OK" {	    
	   
    	&sql(Select count(*),IDForex,ID into :NbRapproche, :IDForex, :IdEAIJrnForex 
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where VALUEDATE = :DateValeur    
	    and   CPTYSHORTNAME = 'SG' 
	    and   CURRENCY1SHORTNAME = :Devise
	    and   AMOUNT1 = :MontantDevise
	    and   SPOTRATE = :CoursChange
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
	$$$LOGINFO("USIUTI CB :"_USIUTIone_USIUTItwo)     
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
	
	
	//DEBUT insert les données dans la tables des confirmations bancaires ***********************************************
	If ErrorBo '= "ErrRetrouveInfo"{

		Set LaConfirmationBanques =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%New()
		Set LaConfirmationBanques.FilenameCB = NomDuFichierConfirmation
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
		Set LaConfirmationBanques.NomBanquesCB = "SG" // Entité du journal forex
		Set LaConfirmationBanques.TypeConfirmationCB = TypeConfirmation	
		Set LaConfirmationBanques.DateTraitementCB = DateTraitement // format "YYYYMMJJ" 
		Set LaConfirmationBanques.DateTraitementTimeStampCB = DateTraitTIMESTAMP
		Set LaConfirmationBanques.StatutRapprocherCB = "NON"
		Set LaConfirmationBanques.StatutEnvoiMailCB = "NON"
	}	
	
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
			Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(IdEAIJrnForex)
			Set LaLigneJrnForex.rapprocherOUINON = "OUI"
			Set LaLigneJrnForex.UTIbanques = USIUTI
			Set LaLigneJrnForex.TypeRapprochement = "AUTO"
			Set LaLigneJrnForex.DateRapprochement = DateTraitTIMESTAMP
			Set MajLigneJrnForexStatut =  LaLigneJrnForex.%Save()
			If ('MajLigneJrnForexStatut){
				Set ErrorBo = "WAR"
	    		Set ErrorBoDescription = ErrorBoDescription_"SGLEVEE - Erreur de mise a jour du statut rapporchement JrnForex pour ID Forex : "_IDForex_"!@@!"
			}
		}			
		//FIN MAJ des données dans la tables des lignes de Journaux Forex ***********************************************

		$$$LOGINFO("ErrorBo 2 :"_ErrorBo)	
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
	
	If ErrorBo '= "ErrRetrouveInfo"{		
		Set EnregConfBanquesStatut = LaConfirmationBanques.%Save()		
		If ('EnregConfBanquesStatut){
			Set ErrorBo = "ERR"
	    	Set ErrorBoDescription = ErrorBoDescription_"SGLEVEE - Erreur de sauvegarde de la confirmation pour le contrat: "_Contrat_"!@@!"
		}
	}
	//FIN insert les données dans la tables des confirmations bancaires ***********************************************
	*/
}
