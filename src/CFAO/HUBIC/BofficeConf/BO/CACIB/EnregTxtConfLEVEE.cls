Class CFAO.HUBIC.BofficeConf.BO.CACIB.EnregTxtConfLEVEE Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

/// /Method EnregEtRapprochePJ(pRequest As %Library.FileCharacterStream, Output pResponse As %Library.Persistent) As %Status
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
	Set TypeConfirmation= "LEVEE"
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
	Set AuComptant = "OUI"
    
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	While 'pRequest.AtEnd {
		Set i = i + 1
		Set LaLigne = pRequest.ReadLine()
		
		//Nom du fichier traité
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		}
		
		
		/*
		Les information sont celle du debut apres "AU Comptant"
		*/
		if $Find(LaLigne ,"Instructions de règlement 1 et 2:") > 0 Set AuComptant = "NON"
		
		If AuComptant = "OUI" {
		
			//Contrat et Réference de l'opération -----------------------
			if $Find(LaLigne ,"Notre référence") > 0 {
				Set RefOperation = $replace($piece(LaLigne,":",2)," ","")
				Set RefOperation = $Piece(RefOperation,"/",1)
				Set Contrat= $replace($piece(LaLigne,":",2)," ","")
				Set Contrat = $Piece(Contrat,"/",1)
			}
			//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 -------
			if $Find(LaLigne ,"Date d'opération") > 0 {
				Set DateNegoce = $piece(LaLigne,":",2)
			}
			//Date de Valeur ou MATURITE ---------------------------------
			if $Find(LaLigne ,"Date de valeur") > 0 {
				Set DateValeur = $piece(LaLigne,":",2)
			}
			//Cours de Change --------------------------------------------
			if $Find(LaLigne ,"Cours au comptant") > 0 {
				Set CoursChange = $replace($piece(LaLigne,":",2)," ","")
				Set CoursChange = (CoursChange * 1)
				if $Extract(CoursChange,1,1)="."{
					Set CoursChange = "0"_CoursChange
				}
			}
			//NOUS ACHETONS + Sens ---------------------------------------
			if $Find(LaLigne ,"Nous achetons") > 0 {
				Set NousAchetons = $replace($piece(LaLigne,":",2)," ","")
				if NousAchetons '= "" {
					Set NousAchetonsMontant = $extract(NousAchetons,4,*)
					Set NousAchetonsDevise = $extract(NousAchetons,1,3)
				}
			}
			//NOUS VENDONS ------------------------------------------------
			if $Find(LaLigne ,"Nous vendons") > 0 {
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
			
			//Mise en forme du montant de la devise en entier
			/*if $Find(MontantDevise,"."){
				Set MontantDevise = $piece(MontantDevise,".",1)
			}
			Set MontantDevise = $Replace(MontantDevise,",","")
			Set MontantDevise = $Replace(MontantDevise," ","")*/
		}
		
	} // Fin de While ('request.AtEnd = 0)
	// ****************************************************************************************************************
	
	// OK OK Modification pour trouver le sens avec la transco **************************************************************************************************	
	$$$LOGINFO("" _NomBanquesCB _ "-" _ TypeConfirmation _ "-" _ NousAchetonsDevise _ "-" _ NousVendonsDevise)
	Set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "V" SET MontantDevise = NousVendonsMontant, Devise = NousVendonsDevise
	If Sens = "A" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDevise,"."){
		Set MontantDevise = $piece(MontantDevise,".",1)
	}
	Set MontantDevise = $Replace(MontantDevise,",","")
	Set MontantDevise = $Replace(MontantDevise," ","")
	$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)
	// **********************************************************************************************************************************************************
	
	
	//DEBUT Mise en forme des dates pour la clause where de la requete de rapprochement *******************************
	//TRADEDATE
	if (DateNegoce '= ""){
	    Set DateNegoce = ..FormatDateConf(DateNegoce)
	}
	//MATURITYDATE / Date de Valeur
	if (DateValeur '= ""){
		Set DateValeur = ..FormatDateConf(DateValeur)
	}
	// ****************************************************************************************************************
    
    
    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent ************************
    If (DateValeur="") || (Devise="") || (MontantDevise="") || (CoursChange=0) {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "CACIBLEVEE - Valeur de rapprochement manquante"
    }
	// ****************************************************************************************************************
    
    
   
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
    If ErrorBo = "OK" {
        
    	&sql(Select count(*),IDForex,ID into :NbRapproche, :IDForex, :IdEAIJrnForex 
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where VALUEDATE = :DateValeur
	    and   CPTYSHORTNAME = 'CA' 
	    and   CURRENCY1SHORTNAME = :Devise
	    and   AMOUNT1 = :MontantDevise
	    and   SPOTRATE = :CoursChange
	    and   SensVouA = :Sens
	    and   rapprocherOUINON = 'NON')	        
    }
	// ****************************************************************************************************************
	//$$$LOGINFO("NbRapproche : "_NbRapproche)
	
	
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

}
