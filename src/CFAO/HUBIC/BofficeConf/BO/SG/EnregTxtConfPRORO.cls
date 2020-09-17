Class CFAO.HUBIC.BofficeConf.BO.SG.EnregTxtConfPRORO Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method EnregEtRapprochePJ(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	
	
	// Instanciation de la Response *****************************************************************************
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = ""
	// ****************************************************************************************************************
		
	
	// Mise en variable de la date du jour **********************************************************************
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
	
	Set LigneIdentifiantFX = 5
	Set NomBanquesCB = "SG"
	Set TypeConfirmation= "PRORO"
	Set IdentifiantFX = ""	
	Set NomDuFichierConfirmation = ""
	Set Contrat = "", RefOperation = ""
	Set DateNegoce = "", DateValeur = ""
	Set CoursChange= 0, Sens = ""
	Set NousAchetons= "", NousAchetonsMontant = "", NousAchetonsDevise = ""
	Set NousVendons = "", NousVendonsMontant =  "", NousVendonsDevise = ""
	Set Devise = "", MontantDevise = ""
	
	Set LigneDuMontantSG = 0
	Set LigneDuMontantCFAO = 0
	
	Set IDForex = ""
    Set IdEAI = ""
    Set NbRapproche = "Aucun"
	
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	Do pRequest.Rewind()	
	Set i = 0
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()
		
		//Nom du fichier traité ---------------------------------
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		}		
		// Identifiant ------------------------------------------
		If i = 2 {
			if $Find(LaLigne,"VALIDATED") > 0 Set LigneIdentifiantFX = 6
			//Set IdentifiantFX= $replace($piece(LaLigne,"/",1)," ","")
			//Set Contrat= IdentifiantFX				
		}			
		If i = LigneIdentifiantFX {
			Set IdentifiantFX= $replace($piece(LaLigne,"/",1)," ","")
			Set Contrat= IdentifiantFX
		}			
		
		//Numero du Contrat -------------------------------------
		/////if $Find(LaLigne,"Reference") > 0 {
		/////   Set Contrat= IdentifiantFX			   
		/////}
		
		// Récuperation dans le tableau -------------------------
		if $Find(LaLigne,IdentifiantFX) > 0 {
			if $Find(LaLigne,"Page") = 0 {
				//RefOperation -----------------------------
				Set RefOperation = IdentifiantFX
				Set lesDatesNegoceEtValeur = $Extract(LaLigne, *-30,*)
				//DATE DE NÉGOCIATION ou TRADE DATE --------
				Set DateNegoce= $replace($piece(lesDatesNegoceEtValeur," ",3)," ","")					
				//Date de Valeur ou MATURITE --------------------
				Set DateValeur= $replace($piece(lesDatesNegoceEtValeur," ",4)," ","")
				//Cours de Change --------------------------
				Set CoursChange= $replace($piece(lesDatesNegoceEtValeur," ",2)," ","")
				Set CoursChange = (CoursChange * 1)
				if $Extract(CoursChange,1,1)="."{
					Set CoursChange = "0"_CoursChange
				}
			}					   		
		}
		//NOUS ACHETONS -----------------------------------------
		if $Find(LaLigne ,"Paiement à SOCIETE GENERALE") > 0 {
			Set LigneDuMontantSG = i + 1
		}
		If LigneDuMontantSG = i {
			Set NousAchetonsMontant = $piece(LaLigne," ",1)
			Set NousAchetonsDevise = $piece(LaLigne," ",2)
					
		}			
		//NOUS VENDONS ------------------------------------------------
		If $Find(LaLigne ,"Paiement à CFAO") > 0 {
			Set LigneDuMontantCFAO = i + 1
		}			
		If LigneDuMontantCFAO = i {
				Set NousVendonsMontant =  $piece(LaLigne," ",1)
				Set NousVendonsDevise = $piece(LaLigne," ",2)
		}				
	} // Fin de While ('request.AtEnd = 0)
	
	// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
	Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "A" SET MontantDevise = NousVendonsMontant, Devise = NousVendonsDevise
	If Sens = "V" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
	Set MontantDevise = $Replace($piece(MontantDevise,".",1),",","")
	$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)
	// **********************************************************************************************************************************************************
	
	/*If NousVendonsDevise '= "EUR"{
		SET Sens = "A"
		SET MontantDevise = NousVendonsMontant
		SET Devise = NousVendonsDevise
	}else{
		SET Sens = "V"
		SET MontantDevise = NousAchetonsMontant
		SET Devise = NousAchetonsDevise
	}	
	$$$LOGINFO("Codes : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)	
	Set MontantDevise = $Replace($piece(MontantDevise,".",1),",","")*/
	// ****************************************************************************************************************
	
	
	
	
		
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
	    Set ErrorBoDescription = "SGPRORO - Valeur de rapprochement manquante!@@!"
    }
	// ****************************************************************************************************************
    
    
    
    
    
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
    If ErrorBo = "OK" {	    
	    
    	&sql(Select count(*),IDForex,ID into :NbRapproche, :IDForex, :IdEAIJrnForex 
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where MATURITYDATE = :DateValeur    
	    and   CPTYSHORTNAME = 'SG' 
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
											NomDuFichierConfirmation ,IdentifiantFX,DateNegoce,DateValeur,
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
			Set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).SaveRapproLigneJRN(DateTraitTIMESTAMP, IdEAIJrnForex, NbRapproche,NomDuFichierConfirmation,IdentifiantFX)
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

}
