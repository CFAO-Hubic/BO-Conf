Class CFAO.HUBIC.BofficeConf.BO.SG.EnregTxtConfMEPterme Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

/// This is the default message handler.  All request types not declared in the message map are delivered here
Method EnregEtRapprochePJ(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	// Instanciation de la Response ***********************************************************************************
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = ""

	// Mise en variable de la date du jour ****************************************************************************
	set processDate = $ZDATETIME($h, 3)

	// Instanciation des variable
	set i = 0
	set errorStatus = 0
	set errorMesage = ""

	set bank		= "SG"
	set type		= "MEP Terme"
	set fileName	= ""
	set contrat		= ""
	set RefOpe		= ""
	set tradeDate	= ""
	set valueDate	= ""
	set maturityDate= ""
	set spot		= 0
	set sens 		= ""
	set amountBuy	= ""
	set deviseBuy	= ""
	set amountSell	= ""
	set deviseSell =  ""

	set IDForex = ""
    set IdEAI = ""
    set NbRapproche = "Aucun"

	Do pRequest.Rewind()
	While 'pRequest.AtEnd { 
		set i = i + 1
		set line = pRequest.ReadLine()		
		
		//Nom du fichier traité -------------------------------------
		If i = 1 {
			set fileName = $p(line, ".", 1)
			$$$LOGINFO("Passage MEP TERME : " _NomDuFichierConfirmation)
		}

		//Numero du Contrat -----------------------------------------
		if $Find(line,"Ref SG de Transaction") > 0 {
		   set contrat= $replace($piece(line,":",2)," ","")
		}

		//Réference de l'opération ----------------------------------
		if $Find(line ,"Ref SG de Transaction") > 0 {
			set RefOpe = $replace($piece(line,":",2)," ","")		   		
		}

		//DATE DE NÉGOCIATION ou TRADE DATE Format 03-MAR-2014 ------
		if $Find(line ,"Date de Conclusion") > 0 {
			set tradeDate = $piece(line,": ",2)		   		
		}

		//Date de Valeur --------------------------------------------
		if $Find(line ,"Date de Paiement") > 0 {
			set valueDate = $piece(line,": ",2)		   		
		}

		//Cours de Change ou SPOT -----------------------------------
		if $Find(line ,"Taux") > 0 {
			set CoursChange = $replace($piece(line,":",2)," ","")
			set CoursChange = (CoursChange * 1)	
			if $Extract(CoursChange,1,1)="."{
				set CoursChange = "0"_CoursChange
			}	   				   		
		}

		//NOUS ACHETONS + Sens --------------------------------------
		if $Find(line ,"Montant et Devise à verser par la Partie B") > 0 {
			set NousAchetons = $replace($piece(line,":",2)," ","")
			if NousAchetons '= "" {
				set NousAchetonsMontant = $extract(NousAchetons,1,*-3)
				set NousAchetonsDevise = $extract(NousAchetons,*-2,*)
			}			
		}

		//NOUS VENDONS ----------------------------------------------
		if $Find(line ,"Montant et Devise à verser par la Partie A") > 0 {
			set NousVendons = $replace($piece(line,":",2)," ","")
			if NousVendons '= "" {
				set NousVendonsMontant =  $extract(NousVendons,1,*-3)
				set NousVendonsDevise = $extract(NousVendons,*-2,*)
			}						
		}
	}

	// Modification pour trouver le sens avec la transco **************************************************************************************************	
	set Sens = ##class(CFAO.HUBIC.BofficeConf.Table.TranscoPourSensVouA).TouverLeSens(NomBanquesCB,TypeConfirmation,NousAchetonsDevise,NousVendonsDevise)
	If Sens = "V" SET MontantDevise = NousAchetonsMontant, Devise = NousAchetonsDevise
	If Sens = "A" SET MontantDevise = NousVendonsMontant,  Devise = NousVendonsDevise 
	if $Find(MontantDevise,"."){
		set MontantDevise = $piece(MontantDevise,".",1)
	}
	set MontantDevise = $Replace(MontantDevise,",","")
	set MontantDevise = $Replace(MontantDevise," ","")
	$$$LOGINFO("Table : " _Sens _ "-" _ MontantDevise _ "-" _ Devise)

	//Convert format : 01-JAN-2000 <==> 2000-01-01
	if tradeDate set tradeDate = ..FormatDate(tradeDate)
	if valueDate set valueDate = ..FormatDate(valueDate)
	if maturityDate set maturityDate = ..FormatDate(maturityDate)

    //On verifie que toutes les informations necessaires au rapprochement sont bien présentent ************************
    If 'valueDate || 'amountBuy || 'deviseBuy || 'amountSell || 'deviseSell || 'spot {
	    set errorStatus = 1
	    set errorMesage = "SGMEP - Valeur de rapprochement manquante"
    }

    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
	If 'error {
		&sql(
			SELECT
				COUNT(*),
				IDForex,
				ID,
				TypeConfirmation
			INTO
				:NbRapproche,
				:IDForex,
				:IdEAIJrnForex,
				:varTypeConfirmation
			FROM CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			WHERE 
				MATURITYDATE = :maturityDate    
				AND   CPTYSHORTNAME = 'SG' 
				AND   CURRENCY1SHORTNAME = :deviseBuy
				AND   AMOUNT1 = :amountBuy
				AND   CLIENTRATE = :spot
				AND   SensVouA = :sens
				AND   rapprocherOUINON = 0
		)
	}

	// ****************************************************************************************************************
	if NbRapproche = 0 {
	    // Requete de rapprochement entre la Confirmation et l'une des ligne du journal Forex *****************************
	    If ErrorBo = "OK" {           
	    	&sql(
	    		SELECT 
		    		COUNT(*),
		    		IdForex,
		    		ID,
		    		type
	    		INTO
	    			:nbMatch,
	    			:IdForex,
	    			:IdEaiForex,
	    			:type
		    	FROM CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
			    WHERE 
				    TRADEDATE = :tradeDate
				    AND valueDate = :valueDate
				    AND bank = 'SG'
				    AND deviseBuy = :deviseBuy
				    AND amountBuy = :amountBuy
				    AND spot = :spot
				    AND sens = :sens
				    AND matchStatus = 0
				    AND type like '%MEP%'
		    )
	    }
		// ****************************************************************************************************************
    }

    If NbRapproche = 0 set TypeConfirmation = "MEP"
    //$$$LOGINFO("varTypeConfirmation : "_varTypeConfirmation)
    //$$$LOGINFO("NbRapproche : "_NbRapproche)
    //$$$LOGINFO("IDForex : "_IDForex)
    
    
    // Enregistrement de la Conf avec Raprochement OUI ou NON *********************************************************
	If ErrorBo = "OK"{
		// insert des données dans la tables des confirmations bancaires
		set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).SaveConfBanque(
			NomDuFichierConfirmation,
			Contrat,DateNegoce,DateValeur,
			CoursChange,
			NousAchetonsMontant,
			NousVendonsMontant,
			NousAchetonsDevise,
			NousVendonsDevise,
			Sens,
			Devise,
			MontantDevise,
			NomBanquesCB,
			TypeConfirmation,
			DateTraitement,
			DateTraitTIMESTAMP,
			IDForex,
			IdEAIJrnForex,
			NbRapproche,
			ErrorBo
		)
		
		//$$$LOGINFO("EnregConfBanqueComptant : "_EnregConfBanqueComptant)
		If $Piece(EnregConfBanqueComptant,"!##!",1) '= "OK" {
			set ErrorBo = $Piece(EnregConfBanqueComptant,"!##!",1)
	    	set ErrorBoDescription = $Piece(EnregConfBanqueComptant,"!##!",2)	    	
		}else{
			set IdEAIconfbanque = $Piece(EnregConfBanqueComptant,"!##!",3)
		}
		
		If NbRapproche = 1 {
			set EnregConfBanqueComptant = ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).SaveRapproLigneJRN(DateTraitTIMESTAMP, IdEAIJrnForex, NbRapproche,NomDuFichierConfirmation,Contrat)
		}
	}
	// ****************************************************************************************************************
	
	
	
	// Envoi du mail a la banque **************************************************************************************		
	If NbRapproche = 1 {
		set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.Functionset.FctsetBoConf).BoConfConstructionMail(NomBanquesCB,NomDuFichierConfirmation,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanque,IdEAIJrnForex,Contrat)
		If SendEmailGeneric '= "OK"{
			 set ErrorBo = "WAR"
			 set ErrorBoDescription = SendEmailGeneric
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
	//$$$LOGINFO("Statut :"_pResponse.StringValue )
 	Quit $$$OK
}

/// Transfo des date dans le format attendu
ClassMethod FormatDate(DateConf As %String) As %Status
{
 
    set JourDate = ##class(Ens.Util.Functionset).Pad($piece(DateConf," ",1),"-2","0")
	set MoisDate = $piece(DateConf," ",2)
	set AnneeDate = $piece(DateConf," ",3)
	If MoisDate = "janvier" set MoisDate = "01"
	If MoisDate = "février" set MoisDate = "02"
	If MoisDate = "mars" set MoisDate = "03"
	If MoisDate = "avril" set MoisDate = "04"
	If MoisDate = "mai" set MoisDate = "05"
	If MoisDate = "juin" set MoisDate = "06"
	If MoisDate = "juillet" set MoisDate = "07"
	If MoisDate = "août" set MoisDate = "08"
	If MoisDate = "aout" set MoisDate = "08"
	If MoisDate = "septembre" set MoisDate = "09"
	If MoisDate = "octobre" set MoisDate = "10"
	If MoisDate = "novembre" set MoisDate = "11"
	If MoisDate = "décembre" set MoisDate = "12"	
    set DateBoConf =  AnneeDate_"-"_MoisDate_"-"_JourDate
    set DateBoConf = $Replace(DateBoConf," ","")
        
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
