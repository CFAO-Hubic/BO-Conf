Class CFAO.HUBIC.BofficeConf.BO.Natixis.EnregTxtConfPROROcomptant Extends Ens.BusinessOperation
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
	
	Set LigneContrat = ""
	Set LignereferenceOP = ""  
	Set LigneUTI = ""
	Set Lignenegociation = ""	
	Set LigneDateValeur = ""
	Set LigneCoursChange = ""
	Set LigneNousAchetons = ""
	Set LigneNousVendons = ""
	
	Set NomBanquesCB = "NAT"
	Set TypeConfirmation= "PRORO SPOT"
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
    Set TypeRapprochement = ""
    Set IdEAIJrnForex = ""
      
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()
			  
		//Nom du fichier traité -------------------------------------
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		} 
		//Numero du Contrat -----------------------------------------
		if $Find(LaLigne,"Notre seconde Référence") > 0 {
			    Set RefOperation = $replace($piece(LaLigne,":",2)," ","")	
		}   
				
		//Réference de l'opération ----------------------------------
		if $Find(LaLigne,"Notre Référence") > 0 {
			    Set Contrat = $replace($piece(LaLigne,":",2)," ","")	
		}	
		
		//USI/UTI ---------------------------------------------------
		//if $Find(LaLigne,"UTI/USI") > 0 {
		//	Set USIUTI = $replace($piece(LaLigne,":",2)," ","")	
		//}	
		Set USIUTI = ""
		//DATE DE NÉGOCIATION ou TRADE DATE -------------------------
		if $Find(LaLigne ,"Date de négociation") > 0 {
			Set DateNegoce = $Piece($piece(LaLigne,":",2),",",1)
		}		
		
		//Date de Valeur ou MATURITE --------------------------------
		if $Find(LaLigne ,"Date de valeur") > 0 {
			Set DateValeur = $piece(LaLigne,":",2)
		}			
		
		//Cours de Change -------------------------------------------
		if $Find(LaLigne ,"Cours de change") > 0 {
			   if $Find(LaLigne ,":") > 0{
				Set CoursChange = $replace($piece(LaLigne,":",2)," ","")
				Set CoursChange = $replace(CoursChange,",",".")
				Set CoursChange = (CoursChange * 1)	
				if $Extract(CoursChange,1,1)="."{
					Set CoursChange = "0"_CoursChange
				}	   									
			}
		}	
		//NOUS ACHETONS + Sens --------------------------------------
		if $Find(LaLigne ,"Nous achetons") > 0 {				   	
			Set NousAchetons = $replace($piece(LaLigne,":",2)," ","")
			If NousAchetons '= "" {
				Set NousAchetonsDevise = $extract(NousAchetons,1,3)
				Set NousAchetonsMontant = $extract(NousAchetons,4,*) 
			}
		}
		//NOUS VENDONS ----------------------------------------------
		if $Find(LaLigne ,"Nous vendons") > 0 {
			Set NousVendons = $replace($piece(LaLigne,":",2)," ","")
			If NousVendons '= "" {
				Set NousVendonsDevise = $extract(NousVendons,1,3) 
				Set NousVendonsMontant = $extract(NousVendons,4,*)
			} 	
		}	 
	} // Fin de While ('request.AtEnd = 0)	
	
    //trouver la Devise pour cette confirmation
    If NousVendonsDevise '= ""{
	    If NousVendonsDevise '= "EUR"{
		    Set Sens = "V"
		    Set MontantDevise = NousVendonsMontant
		    Set Devise = NousVendonsDevise
	    }Else{
		    Set Sens = "A"
		    Set MontantDevise = NousAchetonsMontant
		    Set Devise = NousAchetonsDevise
	    }
    }    
    if $Find(MontantDevise,","){
		Set MontantDevise = $piece(MontantDevise,",",1)
	}   
	// ****************************************************************************************************************
        
    
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
	    Set ErrorBoDescription = "NATPRORO - Valeur de rapprochement manquante!@@!"
    }
	// ****************************************************************************************************************
    
    
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
    If ErrorBo = "OK" {	         
    	&sql(Select count(*),IDForex,ID,TypeRapprochement into :NbRapproche, :IDForex, :IdEAIJrnForex,:TypeRapprochement  
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where VALUEDATE = :DateValeur    
	    and   CPTYSHORTNAME = 'NAT' 
	    and   CURRENCY1SHORTNAME = :Devise
	    and   AMOUNT1 = :MontantDevise
	    and   SPOTRATE = :CoursChange
	    and   SensVouA = :Sens
	    and   rapprocherOUINON = 'NON')
    }  
	// ****************************************************************************************************************
    //$$$LOGINFO("NbRapproche : "_NbRapproche)
    //$$$LOGINFO("TypeRapprochement : "_TypeRapprochement)
    
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
			// Cas Particulier : Pour valider la ligne Forex il faut que la confirmation Proro SPOT et TERME Match
			// Ici Nous alons verifie si la Proro Terme a deja Matcher 
			// 		--> Si oui alors on met la ligne au statut rapprocher = "OUI"
			// 	--> Sinon on laisse la ligne au statut = "NON"
			If TypeRapprochement = "Premier" {
				Set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).SaveRapproLigneJRN(DateTraitTIMESTAMP, IdEAIJrnForex, NbRapproche,NomDuFichierConfirmation,Contrat)
			}else{
				Set NbRapprocheOne = 9999			
				Set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).SaveRapproLigneJRN(DateTraitTIMESTAMP, IdEAIJrnForex, NbRapprocheOne,NomDuFichierConfirmation,Contrat)
			}
		}
	}
	// ****************************************************************************************************************
	
	
	
	// ****************************************************************************************************************
	
	//$$$LOGINFO("NbRapproche : "_NbRapproche)
	//$$$LOGINFO("TypeRapprochement : "_TypeRapprochement)
	//$$$LOGINFO("IDForex : "_IDForex)
	// Envoi du mail a la banque **************************************************************************************		
	If NbRapproche = 1 {
		&sql(Select TypeRapprochement into :TypeRapprochementBis
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where ID = :IdEAIJrnForex )
		
		If TypeRapprochementBis = "AUTO" {		
			&SQL(DECLARE ConfBanque CURSOR FOR
				Select NomBanquesCB, FilenameCB, ID, ContratCB Into :NomBanquesCB, :NomDuFichierConfirmation, :IdEAIconfbanque, :Contrat
				FROM CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques Where IDforexCB = :IDForex)
			&sql(OPEN ConfBanque)
 			&sql(FETCH ConfBanque)
			While (SQLCODE = 0) {
				//$$$LOGINFO("NomBanquesCB : "_NomBanquesCB)
				//$$$LOGINFO("NomDuFichierConfirmation : "_NomDuFichierConfirmation)
				//$$$LOGINFO("IdEAIconfbanque : "_IdEAIconfbanque)
				//$$$LOGINFO("Contrat : "_Contrat)
     			Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(NomBanquesCB,NomDuFichierConfirmation,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanque,IdEAIJrnForex,Contrat)
				 				
 				If SendEmailGeneric '= "OK"{
			 		Set ErrorBo = "WAR"
			 		Set ErrorBoDescription = SendEmailGeneric
				}Else{
					&SQL(UPDATE CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques set StatutEnvoiMailCB = 'Mail Envoyé' WHERE IDforexCB = :IDForex)
				}
				
				&sql(FETCH ConfBanque)
 			}    
 			&sql(CLOSE ConfBanque)			
		
			
		
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
