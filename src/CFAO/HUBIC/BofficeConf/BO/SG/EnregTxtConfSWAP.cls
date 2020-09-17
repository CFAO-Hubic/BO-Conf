Class CFAO.HUBIC.BofficeConf.BO.SG.EnregTxtConfSWAP Extends Ens.BusinessOperation
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
	
	//$$$LOGINFO("DEBUT ************************ DEBUT")	
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
	Set TypeConfirmationCB= "SWAP"
	Set TypeConfirmationC= "SWAP Comptant"
	Set TypeConfirmationT= "SWAP Terme"
	Set NomDuFichierConfirmation = ""
	
	Set Contrat = ""
	Set RefOperation = ""
	Set DateNegoce = ""
	
	// Variable pour le Comptant
	Set LigneNousVendonsC  = 0
	Set LigneNousAchetonsC = 0
	Set LigneCoursChangeC  = 0
	Set LigneDateValeurC   = 0	
	Set DateValeurC = ""
	Set CoursChangeC= 0
	Set NousAchetonsC= ""	
	Set NousAchetonsMontantC = ""
	Set NousAchetonsDeviseC = ""
	Set NousVendonsC = ""
	Set NousVendonsMontantC =  ""
	Set NousVendonsDeviseC = ""
	Set DeviseC = ""
	Set MontantDeviseC = ""
	SET SensC = ""
	
	// Variable pour le Terme
	Set LigneNousVendonsT  = 0
	Set LigneNousAchetonsT = 0
	Set LigneCoursChangeT  = 0
	Set LigneDateMaturiteT = 0	
	Set DateMaturiteT = ""
	Set CoursChangeT= 0
	Set NousAchetonsT= ""	
	Set NousAchetonsMontantT = ""
	Set NousAchetonsDeviseT = ""
	Set NousVendonsT = ""
	Set NousVendonsMontantT =  ""
	Set NousVendonsDeviseT = ""	
	Set DeviseT = ""
	Set MontantDeviseT = ""
	SET SensT = ""	
	
	Set NbRapproche = "Aucun"
    Set IDForex = ""
    Set IdEAI = ""	
	
	Set IDForexC = ""  
    Set IdEAIJrnForexC = ""  
    Set NbRapprocheComptant = "Aucun"
	
	Set IDForexT = "" 
    Set IdEAIJrnForexT = "" 
    Set NbRapprocheTerme = "Aucun"
    Set IdEAIconfbanqueT = ""
    Set IdEAIconfbanqueC = ""
	
	// Recherche des valeurs nécéssaires au rapprochement de la confirmation ******************************************
	While 'pRequest.AtEnd { 
		Set i = i + 1   
		Set LaLigne = pRequest.ReadLine()		
		
		// VALEUR POUR SWAP COMPTANT ET TERME =================================
		//Nom du fichier traité
		If i = 1 {
			Set NomDuFichierConfirmation = LaLigne
		}		
		//Numero du Contrat -----------------------------------------
		if $Find(LaLigne,"Ref SG de Transaction") > 0 {
		   Set Contrat= $replace($piece(LaLigne,":",2)," ","")
		}
		//Réference de l'opération ----------------------------------
		if $Find(LaLigne ,"Ref SG de Transaction") > 0 {
			Set RefOperation = $replace($piece(LaLigne,":",2)," ","")		   		
		}			
		//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 ------
		if $Find(LaLigne ,"Date de Conclusion") > 0 {
			Set DateNegoce = $piece(LaLigne,": ",2)		   		
		}
		
		//VALEUR POUR LE SWAP COMPTANT - SPOT ========================================
		if LaLigne = "Patte court terme du swap" {	
			Set LigneNousVendonsC  = i + 1
			Set LigneNousAchetonsC = i + 2
			Set LigneCoursChangeC  = i + 3
			Set LigneDateValeurC   = i + 4		   		
		}
		
		//NOUS VENDONS ----------------------------------------------		
		if i = LigneNousVendonsC  {
			Set NousVendonsC = $replace($piece(LaLigne,":",2)," ","")
			//$$$LOGINFO("LaLigne ven: "_LaLigne)
			If NousVendonsC '= "" {
				Set NousVendonsMontantC =  $extract(NousVendonsC,1,*-3)
				Set NousVendonsDeviseC = $extract(NousVendonsC,*-2,*)				
			}			
		}
		//NOUS ACHETONS + Sens --------------------------------------
		if i = LigneNousAchetonsC  {
			Set NousAchetonsC = $replace($piece(LaLigne,":",2)," ","")
			If NousAchetonsC '= "" {
				Set NousAchetonsMontantC = $extract(NousAchetonsC,1,*-3)
				Set NousAchetonsDeviseC = $extract(NousAchetonsC,*-2,*)
			}			
		}
		//Cours de Change Terme -------------------------------------
		if i = LigneCoursChangeC  {
			Set CoursChangeC = $replace($piece(LaLigne,":",2)," ","")
			Set CoursChangeC = (CoursChangeC * 1)	
			if $Extract(CoursChangeC,1,1)="."{
				Set CoursChangeC = "0"_CoursChangeC
			}	   		
		}		
		//Date de Valeur  -------------------------------------------
		if i = LigneDateValeurC  {
			Set DateValeurC = $piece(LaLigne,": ",2)	   		
		}
		
		//VALEUR POUR LE SWAP TERME ============================================
		//RefOperation
		//if LaLigne = "Patte long terme du swap" {
		if $Find(LaLigne ,RefOperation) > 0 {
			Set LigneNousVendonsT  = i + 1
			Set LigneNousAchetonsT = i + 2
			Set LigneCoursChangeT  = i + 3
			Set LigneDateMaturiteT = i + 4	  
		}
		//NOUS VENDONS ----------------------------------------------
		if i = LigneNousVendonsT  {
			Set NousVendonsT = $replace($piece(LaLigne,":",2)," ","")
			If NousVendonsT '= "" {
				Set NousVendonsMontantT =  $extract(NousVendonsT,1,*-3)
				Set NousVendonsDeviseT = $extract(NousVendonsT,*-2,*)				
			}			
		}
		//NOUS ACHETONS + Sens --------------------------------------
		if i = LigneNousAchetonsT  {
			Set NousAchetonsT = $replace($piece(LaLigne,":",2)," ","")
			If NousAchetonsT '= "" {
				Set NousAchetonsMontantT = $extract(NousAchetonsT,1,*-3)
				Set NousAchetonsDeviseT = $extract(NousAchetonsT,*-2,*)
			}			
		}
		//Cours de Change Terme -------------------------------------
		if i = LigneCoursChangeT  {
			Set CoursChangeT = $replace($piece(LaLigne,":",2)," ","")
			Set CoursChangeT = (CoursChangeT * 1)	
			if $Extract(CoursChangeT,1,1)="."{
				Set CoursChangeT = "0"_CoursChangeT
			}	   		
		}		
		//Date de Maturité  -------------------------------------------
		if i = LigneDateMaturiteT  {
			Set DateMaturiteT = $piece(LaLigne,": ",2)	   		
		}		
	} // Fin de While ('request.AtEnd = 0)
	
	
	
	/* On A Triché ici ***************************************************/
	// Devise et Sens pour le Comptant
	$$$LOGINFO("C : " _NomBanquesCB _ "-" _ TypeConfirmationCB _ "-" _ NousAchetonsDeviseC _ "-" _ NousVendonsDeviseC)
	// Modification pour trouver le sens avec la transco **************************************************************************************************	
	Set SensC = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmationC,NousAchetonsDeviseC,NousVendonsDeviseC)
	If SensC = "V" SET MontantDeviseC = NousVendonsMontantC, DeviseC = NousVendonsDeviseC
	If SensC = "A" SET MontantDeviseC = NousAchetonsMontantC,  DeviseC = NousAchetonsDeviseC 
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDeviseC,"."){
		Set MontantDeviseC = $piece(MontantDeviseC,".",1)
	}  
	Set MontantDeviseC = $Replace(MontantDeviseC,",","")
	Set MontantDeviseC = $Replace(MontantDeviseC," ","")	
	$$$LOGINFO("Table C: " _SensC _ "-" _ MontantDeviseC _ "-" _ DeviseC)
	//**********************************************************************************************************************************************************
	
	/*
	If NousVendonsDeviseC '= "EUR"{
		SET SensC = "V"
		SET MontantDeviseC = NousVendonsMontantC
		SET DeviseC = NousVendonsDeviseC
	}else{
		SET SensC = "A"
		SET MontantDeviseC = NousAchetonsMontantC
		SET DeviseC = NousAchetonsDeviseC
	}	
	// On A Triché ici **************************************************
	
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDeviseC,"."){
		Set MontantDeviseC = $piece(MontantDeviseC,".",1)
	}  
	Set MontantDeviseC = $Replace(MontantDeviseC,",","")
	Set MontantDeviseC = $Replace(MontantDeviseC," ","")		
	$$$LOGINFO("Codes C: " _SensC _ "-" _ MontantDeviseC _ "-" _ DeviseC)*/
	
	
	
	
	// Modification pour trouver le sens avec la transco **************************************************************************************************
	$$$LOGINFO("T : " _NomBanquesCB _ "-" _ TypeConfirmationCB _ "-" _ NousAchetonsDeviseT _ "-" _ NousVendonsDeviseT)	
	Set SensT = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmationT,NousAchetonsDeviseT,NousVendonsDeviseT)
	If SensT = "V" SET MontantDeviseT = NousAchetonsMontantT, DeviseT = NousAchetonsDeviseT
	If SensT = "A" SET MontantDeviseT = NousVendonsMontantT,  DeviseT = NousVendonsDeviseT 
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDeviseT,"."){
		Set MontantDeviseT = $piece(MontantDeviseT,".",1)
	}  
	Set MontantDeviseT = $Replace(MontantDeviseT,",","")
	Set MontantDeviseT = $Replace(MontantDeviseT," ","")	
	$$$LOGINFO("Table T: " _SensT _ "-" _ MontantDeviseT _ "-" _ DeviseT)
	//**********************************************************************************************************************************************************
	
	/*
	// Devise et Sens pour le Terme
	If NousVendonsDeviseT '= "EUR"{
		SET SensT = "A"
		SET MontantDeviseT = NousVendonsMontantT
		SET DeviseT = NousVendonsDeviseT
	}else{
		SET SensT = "V"
		SET MontantDeviseT = NousAchetonsMontantT
		SET DeviseT = NousAchetonsDeviseT
	}	
	
	//Mise en forme du montant de la devise en entier
	if $Find(MontantDeviseT,"."){
		Set MontantDeviseT = $piece(MontantDeviseT,".",1)
	}  
	Set MontantDeviseT = $Replace(MontantDeviseT,",","")
	Set MontantDeviseT = $Replace(MontantDeviseT," ","")
	$$$LOGINFO("Codes T: " _SensT _ "-" _ MontantDeviseT _ "-" _ DeviseT)*/	
	// ****************************************************************************************************************
	
	
	//DEBUT Mise en forme des dates pour la clause where de la requete de rapprochement *******************************
	//TRADEDATE
	if (DateNegoce '= ""){
		Set DateNegoce = ..FormatDateConf(DateNegoce)	       	   
	}	
    //Date de Valeur 
    if (DateValeurC '= ""){
	    Set DateValeurC = ..FormatDateConf(DateValeurC)	         
    } 
    //Maturity Date
    if (DateMaturiteT '= ""){
	    Set DateMaturiteT = ..FormatDateConf(DateMaturiteT)
    }    
	// ****************************************************************************************************************    
   
        
    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent ************************
    If (DateValeurC="") || (DeviseC="") || (MontantDeviseC="") || (CoursChangeC=0) || (DateMaturiteT="") || (DeviseT="") || (MontantDeviseT="") || (CoursChangeT=0) {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "SGSWAP - Valeur de rapprochement manquante!@@!"
    }       
	// ****************************************************************************************************************
    
    //on verifie que les deux jambes n'est pas le meme sens ***********************************************************
	/*If SensC = SensT {
	    Set ErrorBo = "ERR"
	    Set ErrorBoDescription = "SGSWAP - Meme Sens pour les deux jambes!@@!"
    }   */    
	// ****************************************************************************************************************
    
    
    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
    If ErrorBo = "OK" { 
    //Requete pour Le Comptant
    	       
    	&sql(Select count(*),IDForex,ID into :NbRapprocheComptant, :IDForexC, :IdEAIJrnForexC 
    	from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where VALUEDATE = :DateValeurC 
	    and   CPTYSHORTNAME = 'SG' 
	    and   CURRENCY1SHORTNAME = :DeviseC
	    and   AMOUNT1 = :MontantDeviseC
	    and   SPOTRATE = :CoursChangeC
	    and   SensVouA = :SensT
	    and   rapprocherOUINON = 'NON'
	    and TypeConfirmation like '%SWAP%')	    	
    	
    	//Requete pour Le Terme
    	
    	&sql(Select count(*),IDForex,ID into :NbRapprocheTerme, :IDForexT, :IdEAIJrnForexT from CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
	    where MATURITYDATE = :DateMaturiteT    
	    and   CPTYSHORTNAME = 'SG' 
	    and   CURRENCY1SHORTNAME = :DeviseT
	    and   AMOUNT1 = :MontantDeviseT
	    and   CLIENTRATE = :CoursChangeT
	    and   SensVouA = :SensT
	    and   rapprocherOUINON = 'NON'
	    and TypeConfirmation like '%SWAP%')	    
    }     
	// ****************************************************************************************************************
	 //$$$LOGINFO("NbRapprocheComptant :"_ NbRapprocheComptant)
	 //$$$LOGINFO("NbRapprocheTerme :"_ NbRapprocheTerme)
	 
	
	// Enregistrement de la Conf avec Raprochement OUI ou NON *********************************************************
	If ErrorBo = "OK"{
		Set TypeConfirmationTerme = "SWAP terme"
		Set TypeConfirmationComptant = "SWAP Comptant"	
		// insert des données dans la tables des confirmations bancaires	
		Set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).SaveConfBanque(
											NomDuFichierConfirmation ,Contrat,DateNegoce,DateValeurC,
											CoursChangeC,NousAchetonsMontantC,NousVendonsMontantC,
											NousAchetonsDeviseC,NousVendonsDeviseC,SensC,DeviseC,
											MontantDeviseC,NomBanquesCB,TypeConfirmationComptant,
											DateTraitement,DateTraitTIMESTAMP,IDForexC,IdEAIJrnForexC,NbRapprocheComptant,ErrorBo)
		
		If $Piece(EnregConfBanqueComptant,"!##!",1) '= "OK" {
			Set ErrorBo = $Piece(EnregConfBanqueComptant,"!##!",1)
	    	Set ErrorBoDescription = $Piece(EnregConfBanqueComptant,"!##!",2)
		}else{
			Set IdEAIconfbanqueC = $Piece(EnregConfBanqueComptant,"!##!",3)
		}
	
		// insert des données dans la tables des confirmations bancaires 	
		Set EnregConfBanqueTerme = ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).SaveConfBanque(
											NomDuFichierConfirmation ,Contrat,DateNegoce,DateMaturiteT,
											CoursChangeT,NousAchetonsMontantT,NousVendonsMontantT,
											NousAchetonsDeviseT,NousVendonsDeviseT,SensT,DeviseT,
											MontantDeviseT,NomBanquesCB,TypeConfirmationTerme,
											DateTraitement,DateTraitTIMESTAMP,IDForexT,IdEAIJrnForexT,NbRapprocheTerme,ErrorBo)
		If $Piece(EnregConfBanqueTerme,"!##!",1) '= "OK" {
			Set ErrorBo = $Piece(EnregConfBanqueTerme,"!##!",1)
	    	Set ErrorBoDescription = $Piece(EnregConfBanqueTerme,"!##!",2)
		}else{
			Set IdEAIconfbanqueT = $Piece(EnregConfBanqueTerme,"!##!",3)
		}
		
		If (NbRapprocheComptant = 1) &&  (NbRapprocheTerme) = 1 {
			set NbRapproche = 1
			Set EnregConfBanque = ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).SaveRapproLigneJRN(DateTraitTIMESTAMP, IdEAIJrnForexT, NbRapproche,NomDuFichierConfirmation,Contrat)
		}
		//$$$LOGINFO("EnregConfBanqueComptant :"_ EnregConfBanqueComptant)
		//$$$LOGINFO("EnregConfBanqueTerme :"_ EnregConfBanqueTerme)
		
		//$$$LOGINFO("IdEAIconfbanqueC :"_ IdEAIconfbanqueC)
		//$$$LOGINFO("IdEAIconfbanqueT :"_ IdEAIconfbanqueT)											
	}	
	// ****************************************************************************************************************
	
	
	
	
	// Envoi du mail a la banque **************************************************************************************		
	If NbRapproche = 1 {
		Set SendEmailGenericC = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(NomBanquesCB,NomDuFichierConfirmation,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanqueC,IdEAIJrnForexT,Contrat)
		If SendEmailGenericC '= "OK"{
			 Set ErrorBo = "WAR"
			 Set ErrorBoDescription = SendEmailGenericC
		}
		Set SendEmailGenericT = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(NomBanquesCB,NomDuFichierConfirmation,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanqueT,IdEAIJrnForexT,Contrat,"NON")
		If SendEmailGenericT '= "OK"{
			 Set ErrorBo = "WAR"
			 Set ErrorBoDescription = SendEmailGenericT
		}
	}	
	// ****************************************************************************************************************
	
	
	//$$$LOGINFO("ErrorBo 3 :"_ErrorBo)
	If ErrorBo = "OK" {
		$$$LOGINFO("Fichier OK : "_NomDuFichierConfirmation_" Avec "_NbRapprocheComptant_" rappro  Comptant et "_NbRapprocheTerme_" rappro Terme")
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
 	//$$$LOGINFO("FIN   ************************")
 	//$$$LOGINFO("Statut :"_pResponse.StringValue )
 	Quit $$$OK
}

/// cette methode fait le lien entre le BS et sa Cible target
ClassMethod FormatDateConf(DateConf As %String) As %Status
{
	Set JourDate = ##class(Ens.Util.FunctionSet).Pad($piece(DateConf," ",1),"-2","0")
    Set MoisDate = $piece(DateConf," ",2)
    Set AnneeDate = $piece(DateConf," ",3)
    //Jan Feb MAR APR MAY JUN JUL AUG SEP OCT NOV DEC
	If MoisDate = "January" Set MoisDate = "01"
	If MoisDate = "February" Set MoisDate = "02"
	If MoisDate = "March" Set MoisDate = "03"
	If MoisDate = "April" Set MoisDate = "04"
	If MoisDate = "May" Set MoisDate = "05"
	If MoisDate = "June" Set MoisDate = "06"
	If MoisDate = "July" Set MoisDate = "07"
	If MoisDate = "August" Set MoisDate = "08"
	If MoisDate = "September" Set MoisDate = "09"
	If MoisDate = "October" Set MoisDate = "10"
	If MoisDate = "November" Set MoisDate = "11"
	If MoisDate = "December" Set MoisDate = "12"	
    Set DateBoConf =  AnneeDate_"-"_MoisDate_"-"_JourDate	   //Format 2014-03-03  
    
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
