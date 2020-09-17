Class CFAO.HUBIC.BofficeConf.BO.JrnForex.VerifExisteConfbanques Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property ServeurSMTP As %String;

/// Repertoire des pieces jointes pour l'envoi par mail
Property RepertoirePJ As %String;

Parameter SETTINGS = "ServeurSMTP,RepertoirePJ";

/// Oeprations : Enreg Back Order Confirmation Journal Forex
/// 
/// cette classe enregistre les lignes des journaux forex en attente de confirmation de banques
/// elle recherche aussi si une confirmation de banques existe deja 
/// si une confirmation de banques est trouver, la ligne est enregistrer avec un statut rapprocher
/// sinon le ligne est enregistrer avec un statut non rapprocher
/// 
/// /Method EnregEtRapprochePJ(pRequest As %Library.FileCharacterStream, Output pResponse As %Library.Persistent) As %Status
/// This is the default message handler.  All request types not declared in the message map are delivered here
/// Method EnregEtRapprochePJ(pRequest As CFAO.HUBIC.EMIRtools.recordMap.JournalForex.Batch, Output pResponse As Ens.StringResponse) As %Status
Method EnregEtRapproche(pRequest As CFAO.HUBIC.BofficeConf.Table.JrnForexTab, Output pResponse As Ens.StringResponse) As %Status
{
  
	
	Hang 1
	
	// Instanciation de la Response
	Set pResponse = ##class(Ens.StringResponse).%New()
	Set pResponse.StringValue = ""
	
	Set Banques = ""
	Set EnvoiMail = "PASOK"
	Set NbErrorBo = 0
	Set ErrorListeIdForex = ""
	Set ErrorListeConfBanques = ""
	Set ErrorBoMAJJrnForex = "Erreur de mise a jour du rapprochement des lignes Forex pour les couples IdForex : "
	Set ErrorBoMAJConfBanque = "Erreur de mise a jour du rapprochement des ligne de confirmation pour les couples IdForex : "
	
	
	// Mise en variable de la date du jour
	Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ" 
	Set AnnéeSaisie = $extract(DateTraitement,1,4)
	Set MoisSaisie =  $extract(DateTraitement,5,6)
	Set jourSaisie =  $extract(DateTraitement,7,8)
	Set Htime=$PIECE($HOROLOG,",",2)
	Set ltime = $ZTIME(Htime,1) 
	Set DateTraitTIMESTAMP = AnnéeSaisie_"-"_MoisSaisie_"-"_jourSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"
	
		
	//$$$LOGINFO("DEBUT ************************ DEBUT")	
	
	
	//initialisation de la key *************************
	Set key = pRequest.JrnForexRcds.Next()	
	
	
	//on bloucle sur toutes les lignes *****************
	while(key '= "") {			
		//Set FilenameJournalF = pRequest.JrnForexRcds.GetAt(key).Filename
		Set IdEAIJrnForex = pRequest.JrnForexRcds.GetAt(key).%Id()
		Set JrnForexIntOuExt = $extract(pRequest.JrnForexRcds.GetAt(key).TRADETYPESHORTNAME,1,1)		
		Set BanquesShortName = pRequest.JrnForexRcds.GetAt(key).CPTYSHORTNAME
		Set Banques =  pRequest.JrnForexRcds.GetAt(key).CPTYSHORTNAME		
		Set idkeyEAIforex = pRequest.JrnForexRcds.GetAt(key).%Id()
		Set IDForex = pRequest.JrnForexRcds.GetAt(key).IDForex
		Set TRADEDATE = pRequest.JrnForexRcds.GetAt(key).TRADEDATE    
		Set MATURITYDATE = pRequest.JrnForexRcds.GetAt(key).MATURITYDATE
		Set VALUEDATE = pRequest.JrnForexRcds.GetAt(key).VALUEDATE
		Set CURRENCY1SHORTNAME = pRequest.JrnForexRcds.GetAt(key).CURRENCY1SHORTNAME
		Set AMOUNT1 = pRequest.JrnForexRcds.GetAt(key).AMOUNT1
		Set CLIENTRATE = pRequest.JrnForexRcds.GetAt(key).CLIENTRATE
		Set SPOTRATE =  pRequest.JrnForexRcds.GetAt(key).SPOTRATE
		Set SensVouA = pRequest.JrnForexRcds.GetAt(key).SensVouA
		Set CPTYSHORTNAME = pRequest.JrnForexRcds.GetAt(key).CPTYSHORTNAME
		Set TypeConfirmation = pRequest.JrnForexRcds.GetAt(key).TypeConfirmation
		Set CURRENCY2SHORTNAME = pRequest.JrnForexRcds.GetAt(key).CURRENCY2SHORTNAME		 
		//Set UTIinterne = pRequest.JrnForexRcds.GetAt(key).UTICCI
	    
    	
    	/*$$$LOGINFO("TypeConfirmation : "_TypeConfirmation)
    	$$$LOGINFO("CPTYSHORTNAME : "_CPTYSHORTNAME)
    	$$$LOGINFO("TRADEDATE : "_TRADEDATE)
    	$$$LOGINFO("VALUEDATE : "_VALUEDATE)
    	$$$LOGINFO("MATURITYDATE : "_MATURITYDATE)
    	$$$LOGINFO("CURRENCY1SHORTNAME : "_CURRENCY1SHORTNAME)
    	$$$LOGINFO("AMOUNT1 : "_AMOUNT1)
    	$$$LOGINFO("SPOTRATE : "_SPOTRATE)
    	$$$LOGINFO("CLIENTRATE : "_CLIENTRATE)
    	$$$LOGINFO("SensVouA : "_SensVouA)*/
    	
	
    	Set NbRapproche = 0
    	set NbRapprocheSwapComptant = 0
    	set NbRapprocheSwapTerme = 0
    	set FilenameCB = ""
    	set NomPieceJointe = ""
    	set NomPieceJointeSpot = ""
    	set NomPieceJointeTerme = ""
    	Set ContratCB = ""
    	Set ContratSpot = ""
    	Set ContratTerme = ""
    	Set MajJrnForex = "NON"
    	Set DeuxConfirmation = "NON"
    	Set unSeulPDF = "NON"
    	Set FilenameCBComptant = "FilenameCBComptant"
    	Set FilenameCBTerme = "FilenameCBTerme"
		if (((TypeConfirmation = "LEVEE") || (TypeConfirmation = "LEVEE ANN")) && ((CPTYSHORTNAME = "NAT") || (CPTYSHORTNAME = "SG") || (CPTYSHORTNAME = "CA"))) 
		|| (((TypeConfirmation = "MEP SPOT ANN") || (TypeConfirmation = "MEP SPOT")) && ((CPTYSHORTNAME = "CA") || (CPTYSHORTNAME = "SG"))) 
		|| (((TypeConfirmation = "MEP SPOT ANN") || (TypeConfirmation = "MEP SPOT")) && (CPTYSHORTNAME = "BNP")) {
    		if (TypeConfirmation = "MEP SPOT") && (CPTYSHORTNAME = "SG"){
	    		//$$$LOGINFO("passage MEP SPOT SG")
	    		&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
	    		into :NbRapproche, :IdEAIconfbanque, :FilenameCB, :NomPieceJointe  , :ContratCB
	    		from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
		    	where DateValeurCB = :VALUEDATE
		    	and   NomBanquesCB = :CPTYSHORTNAME
		    	and   DeviseCB = :CURRENCY1SHORTNAME
		    	and   MontantDeviseCB = :AMOUNT1
		    	and   CoursDeChangeCB = :SPOTRATE
		    	and   SensCB = :SensVouA 
		    	and   StatutRapprocherCB = 'NON'
		    	and TypeConfirmationCB like '%MEP%')
    		}else{
	    		&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
	    		into :NbRapproche, :IdEAIconfbanque, :FilenameCB, :NomPieceJointe  , :ContratCB
	    		from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
		    	where DateValeurCB = :VALUEDATE
		    	and   NomBanquesCB = :CPTYSHORTNAME
		    	and   DeviseCB = :CURRENCY1SHORTNAME
		    	and   MontantDeviseCB = :AMOUNT1
		    	and   CoursDeChangeCB = :SPOTRATE
		    	and   SensCB = :SensVouA 
		    	and   StatutRapprocherCB = 'NON')
    		}	    	
		}elseif ((TypeConfirmation = "SWAP") && ((CPTYSHORTNAME = "CA") || (CPTYSHORTNAME = "SG"))) || ((TypeConfirmation = "PRORO") && (CPTYSHORTNAME = "NAT"))  {			
			//Pour les SWAP, la ligne forex doit trouver deux ligne de confirmation, Comptant et Terme    		
    		if (TypeConfirmation = "SWAP") && (CPTYSHORTNAME = "SG"){
	    		//$$$LOGINFO("passage SWAP SG")
	    		&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
	    		into :NbRapprocheSwapComptant, :IdEAIconfbanqueSwapC, :FilenameCBComptant, :NomPieceJointeSpot, :ContratSpot
	    		from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
		    	where DateValeurCB = :VALUEDATE
		    	and   NomBanquesCB = :CPTYSHORTNAME
		    	and   DeviseCB = :CURRENCY1SHORTNAME
		    	and   MontantDeviseCB = :AMOUNT1
		    	and   CoursDeChangeCB = :SPOTRATE
		    	and   SensCB = :SensVouA
		    	and   StatutRapprocherCB = 'NON'
		    	and TypeConfirmationCB like '%SWAP%')
		    	
		    	// TERME
		    	&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
		    	into :NbRapprocheSwapTerme, :IdEAIconfbanqueSwapT, :FilenameCBTerme, :NomPieceJointeTerme , :ContratTerme
		    	from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
		    	where DateValeurCB = :MATURITYDATE
		    	and   NomBanquesCB = :CPTYSHORTNAME
		    	and   DeviseCB = :CURRENCY1SHORTNAME
		    	and   MontantDeviseCB = :AMOUNT1
		    	and   CoursDeChangeCB = :CLIENTRATE
		    	and   SensCB = :SensVouA 
		    	and   StatutRapprocherCB = 'NON'
		    	and TypeConfirmationCB like '%SWAP%')
    		}else{
    		// SPOT
	    		&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
	    		into :NbRapprocheSwapComptant, :IdEAIconfbanqueSwapC, :FilenameCBComptant, :NomPieceJointeSpot  , :ContratSpot
	    		from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
		    	where DateValeurCB = :VALUEDATE
		    	and   NomBanquesCB = :CPTYSHORTNAME
		    	and   DeviseCB = :CURRENCY1SHORTNAME
		    	and   MontantDeviseCB = :AMOUNT1
		    	and   CoursDeChangeCB = :SPOTRATE
		    	and   SensCB = :SensVouA
		    	and   StatutRapprocherCB = 'NON')
		    	
		    	// TERME
		    	&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
		    	into :NbRapprocheSwapTerme, :IdEAIconfbanqueSwapT, :FilenameCBTerme, :NomPieceJointeTerme , :ContratTerme
		    	from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
		    	where DateValeurCB = :MATURITYDATE
		    	and   NomBanquesCB = :CPTYSHORTNAME
		    	and   DeviseCB = :CURRENCY1SHORTNAME
		    	and   MontantDeviseCB = :AMOUNT1
		    	and   CoursDeChangeCB = :CLIENTRATE
		    	and   SensCB = :SensVouA 
		    	and   StatutRapprocherCB = 'NON')
		    	
    		}
	    	//$$$LOGINFO("NbRapprocheSwapComptant : "_NbRapprocheSwapComptant)
	    	//$$$LOGINFO("NbRapprocheSwapTerme : "_NbRapprocheSwapTerme)
	    	If (NbRapprocheSwapComptant > 0) &&  (NbRapprocheSwapTerme) > 0 {
				set NbRapproche = NbRapprocheSwapComptant + NbRapprocheSwapTerme
				Set NomPieceJointe = NomPieceJointeSpot _ "-" _ NomPieceJointeTerme
				Set ContratCB = ContratSpot _ "-" _ ContratTerme
	    	}
	    	If (NbRapprocheSwapComptant > 0) &&  (NbRapprocheSwapTerme) = 0 {
				set NbRapproche = NbRapprocheSwapComptant
				Set NomPieceJointe = NomPieceJointeSpot
				Set ContratCB = ContratSpot
	    	}
	    	If (NbRapprocheSwapComptant = 0) &&  (NbRapprocheSwapTerme) > 0 {
				set NbRapproche = NbRapprocheSwapTerme
				Set NomPieceJointe = NomPieceJointeTerme
				Set ContratCB = ContratTerme
	    	}
	    	
	    	//y a t'il un seule PDF contenant deux confirmation
	    	If FilenameCBComptant = FilenameCBTerme Set unSeulPDF = "OUI"
	    	
	    	Set DeuxConfirmation = "OUI"
	    	//$$$LOGINFO("NbRapproche : "_NbRapproche)
		}elseif ((TypeConfirmation = "LEVEE") || (TypeConfirmation = "LEVEE ANN") || (TypeConfirmation = "PRORO")) && (CPTYSHORTNAME = "BNP") {	
	    	&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
    		into :NbRapproche, :IdEAIconfbanque, :FilenameCB, :NomPieceJointe , :ContratCB
    		from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
	    	where DateValeurCB = :MATURITYDATE
	    	and   NomBanquesCB = :CPTYSHORTNAME
	    	and   DeviseCB = :CURRENCY1SHORTNAME
	    	and   MontantDeviseCB = :AMOUNT1
	    	and   CoursDeChangeCB = :SPOTRATE
	    	and   SensCB = :SensVouA 
	    	and   StatutRapprocherCB = 'NON')
	    		
		}else{	
			//on verifie si une confirmation est deja presente pour les autres types
    		&sql(Select count(*),ID,FilenameCB,NomPieceJointe, ContratCB 
    		into :NbRapproche, :IdEAIconfbanque, :FilenameCB, :NomPieceJointe , :ContratCB
    		from CFAO_HUBIC_BofficeConf_Table.ConfirmationBanques 
	    	where DateValeurCB = :MATURITYDATE
	    	and   NomBanquesCB = :CPTYSHORTNAME
	    	and   DeviseCB = :CURRENCY1SHORTNAME
	    	and   MontantDeviseCB = :AMOUNT1
	    	and   CoursDeChangeCB = :CLIENTRATE
	    	and   SensCB = :SensVouA 
	    	and   StatutRapprocherCB = 'NON')	
			//$$$LOGINFO("requete 2 : ")
		}   	
    	
    	
    	
    	If NbRapproche > 0 { // si un raprochement est trouvé
	    	Set MajJrnForex = "OUI"
			//Mise a jour du raprochement pour la ligne du journal forex traiter
			if DeuxConfirmation = "OUI"{
				Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(idkeyEAIforex)
		    	If (NbRapprocheSwapComptant > 0) &&  (NbRapprocheSwapTerme) > 0 {			    	
					Set LaLigneJrnForex.rapprocherOUINON = "OUI"					
		    	}
		    	If (NbRapprocheSwapComptant > 0) &&  (NbRapprocheSwapTerme) = 0 {
					Set LaLigneJrnForex.rapprocherOUINON = "NON"
					Set LaLigneJrnForex.TypeRapprochement = "Premier"					
		    	}
		    	If (NbRapprocheSwapComptant = 0) &&  (NbRapprocheSwapTerme) > 0 {
					Set LaLigneJrnForex.rapprocherOUINON = "NON"
					Set LaLigneJrnForex.TypeRapprochement = "Premier"
	    		}
		    	Set LaLigneJrnForex.DateRapprochement = DateTraitTIMESTAMP
				Set LaLigneJrnForex.DateTraitement = "OUI"
				Set LaLigneJrnForex.NomConfirmation = NomPieceJointe
				Set LaLigneJrnForex.RefBanques = ContratCB
				
			}Else{
				Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(idkeyEAIforex)
				Set LaLigneJrnForex.rapprocherOUINON = "OUI"				
				Set LaLigneJrnForex.DateRapprochement = DateTraitTIMESTAMP
				Set LaLigneJrnForex.TypeRapprochement = "AUTO"
				Set LaLigneJrnForex.DateTraitement = "OUI"
				Set LaLigneJrnForex.NomConfirmation = NomPieceJointe
				Set LaLigneJrnForex.RefBanques = ContratCB
			}	
			Set StatutEnregRapproJrnForex =  LaLigneJrnForex.%Save()
			//$$$LOGINFO("StatutEnregRapproJrnForex : "_StatutEnregRapproJrnForex)
			If ('StatutEnregRapproJrnForex){
				Set NbErrorBo = NbErrorBo + 1					
				Set MajJrnForex = "NON"	 
					   			
	    		if ErrorListeIdForex = ""{
	    			Set ErrorListeIdForex = IDForex 
	    		}else{
		    		Set ErrorListeIdForex = ErrorListeIdForex_"!@@!"_IDForex
	    		}	    			
			}
									
			//$$$LOGINFO("MajJrnForex : "_MajJrnForex)
			if MajJrnForex = "OUI" { // si la ligne du JrnForex a été mise a jour sans erreur				
				//Mise a jour du raprochement pour la confirmation de banques trouvée
				If DeuxConfirmation = "OUI"{
					If (NbRapprocheSwapComptant > 0) {
						Set LaConfirmationBanques =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(IdEAIconfbanqueSwapC)
						Set LaConfirmationBanques.StatutRapprocherCB = "OUI"
						Set LaConfirmationBanques.IDforexCB = IDForex
						Set LaConfirmationBanques.IdEAIJrnForexCB = IdEAIJrnForex
						//Set LaConfirmationBanques.NomJournalForex = FilenameJournalF				
						Set StatutEnregRapproConfbanques =  LaConfirmationBanques.%Save()
					}
					If (NbRapprocheSwapTerme > 0) {
						Set LaConfirmationBanques =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(IdEAIconfbanqueSwapT)
						Set LaConfirmationBanques.StatutRapprocherCB = "OUI"
						Set LaConfirmationBanques.IDforexCB = IDForex
						Set LaConfirmationBanques.IdEAIJrnForexCB = IdEAIJrnForex
						//Set LaConfirmationBanques.NomJournalForex = FilenameJournalF				
						Set StatutEnregRapproConfbanques =  LaConfirmationBanques.%Save()
					}
				}else{	
					Set LaConfirmationBanques =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(IdEAIconfbanque)
					Set LaConfirmationBanques.StatutRapprocherCB = "OUI"
					Set LaConfirmationBanques.IDforexCB = IDForex
					Set LaConfirmationBanques.IdEAIJrnForexCB = IdEAIJrnForex
					Set LaConfirmationBanques.TypeConfirmationCB = TypeConfirmation
					//Set LaConfirmationBanques.NomJournalForex = FilenameJournalF				
					Set StatutEnregRapproConfbanques =  LaConfirmationBanques.%Save()					
				}
				If ('StatutEnregRapproConfbanques){
					Set NbErrorBo = NbErrorBo + 1
					Set EnvoiMail = "PASOK"
    				if ErrorListeConfBanques = ""{
    					Set ErrorListeConfBanques = IDForex //_"/"_USIUTICB
    				}else{
	    				Set ErrorListeConfBanques = ErrorListeConfBanques_"!@@!"_IDForex //_"/"_USIUTICB
    				}					
    			}else{
	    			Set EnvoiMail = "OK"	
    			}
			}
			//$$$LOGINFO("unSeulPDF : "_unSeulPDF)
			// Envoi du mail a la banque **************************************************************************************		
			If EnvoiMail = "OK" {
				If DeuxConfirmation = "OUI"{
					If (NbRapprocheSwapComptant > 0) &&  (NbRapprocheSwapTerme) > 0 {
						If unSeulPDF = "OUI" {
							Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(BanquesShortName,NomPieceJointeSpot,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanqueSwapC,IdEAIJrnForex,ContratCB)
							Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(BanquesShortName,NomPieceJointeTerme,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanqueSwapT,IdEAIJrnForex,ContratCB,"NON")	

						}else{
							Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(BanquesShortName,NomPieceJointeSpot,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanqueSwapC,IdEAIJrnForex,ContratCB)
							Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(BanquesShortName,NomPieceJointeTerme,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanqueSwapT,IdEAIJrnForex,ContratCB)	
						}
						If SendEmailGeneric '= "OK"{
						 	Set ErrorBo = "WAR"
						 	Set ErrorBoDescription = SendEmailGeneric
						}
					}					
				}else{
					Set SendEmailGeneric = ##class(CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf).BoConfConstructionMail(BanquesShortName,NomPieceJointe,..RepertoirePJ,..ServeurSMTP,IdEAIconfbanque,IdEAIJrnForex,ContratCB)
					If SendEmailGeneric '= "OK"{
						 Set ErrorBo = "WAR"
						 Set ErrorBoDescription = SendEmailGeneric
					}
				}
			}	
			// ****************************************************************************************************************
		} // If NbRapproche = 1		
		
		
		
		Set key = pRequest.JrnForexRcds.Next(key)
	}


	// Fin de while(key '= "")
	if ErrorListeIdForex '= ""{
		Set ErrorBoMAJJrnForex = ErrorBoMAJJrnForex_" "_ErrorListeIdForex
	}else{
		Set ErrorBoMAJJrnForex = ""
	}
	if ErrorListeConfBanques '= ""{
		Set ErrorBoMAJConfBanque = ErrorBoMAJConfBanque_"!@@!"_ErrorListeConfBanques
	}else{
		Set ErrorBoMAJConfBanque = ""
	}
	If NbErrorBo = 0 {
		set pResponse.StringValue = "0!##!"_Banques_"!##!!##!"
	}else{
		set pResponse.StringValue = "1!##!"_Banques_"!##!"_ErrorBoMAJJrnForex_"!##!"_ErrorBoMAJConfBanque
	}
	//$$$LOGINFO("FIN   ************************")
 	Quit $$$OK
}

/// Methode d'envoi généric d'un mail (D.DIOP)
ClassMethod SendEmailGeneric(ServeurSMTP As %String, DestinataireNom As %String, DestinataireMail As %String, ExpediteurMail As %String, ObjetMail As %String, ContenuDuMail As %Stream.GlobalCharacter)
{
    // Create an SMTP object and connect to a server
    Set Mailer = ##class(%Net.SMTP).%New()

    // Fill in the name of your mail server
    Set Mailer.smtpserver = ServeurSMTP

    // Create a Message object and fill in From, To, Subject
    Set Msg = ##class(%Net.MailMessage).%New()
    Set Msg.From=ExpediteurMail    
    Do Msg.To.Insert(DestinataireMail)    
    Set Msg.Subject = ObjetMail	
	
    // Add message content
    While (ContenuDuMail.AtEnd = 0) {        
		do Msg.TextData.Write(ContenuDuMail.Read())  
	}
    
    //Do Msg.AttachFile("D:\HUBIC\BackOrderConf\Confirmation PDFtraité",
    
    // Send the message and close objects
    Set EnvoiMailer = Mailer.Send(Msg)
    Quit EnvoiMailer
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="CFAO.HUBIC.BofficeConf.Table.JrnForexTab"> 
		<Method>EnregEtRapproche</Method>
	</MapItem>
</MapItems>
}

}
