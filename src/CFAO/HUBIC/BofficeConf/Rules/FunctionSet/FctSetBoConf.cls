Class CFAO.HUBIC.BofficeConf.Rules.FunctionSet.FctSetBoConf Extends Ens.Rule.FunctionSet
{

// On verifie que le fichier ne contient que des statut Validated ou Cancelled sinon on rejete le fichier

ClassMethod BoConfVerifStatutName(doc As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch) As %Integer
{
	
	
	//Initialisation des variables *********************
	Set WarningCle = 0 
	Set varAPPLICATIVESTATUSNAME = ""    
    //set ^zCompteAlerteNoMoreUseHFM = ""
    
    
    //initialisation de la key *************************
	Set key = doc.Records.Next()	
		
	
	//on bloucle sur toutes les lignes *****************
	while(key '= "") {	
		Set record = doc.Records.GetAt(key)
		Set varAPPLICATIVESTATUSNAME = doc.Records.GetAt(key).APPLICATIVESTATUSNAME	
		
		If varAPPLICATIVESTATUSNAME '= "Validated" { //autre statut "cancelled"
			//If varAPPLICATIVESTATUSNAME '= "cancelled" {
				//$$$LOGINFO("varAPPLICATIVESTATUSNAME : "_varAPPLICATIVESTATUSNAME)			
				Set WarningCle = WarningCle + 1
			//}
		}
		Set key = doc.Records.Next(key)
	}	
	
	If (WarningCle = 0)
	{
		return 0
	}else{
		return 1    
	}
}

/// On verifie qu'aucun Idforex ne soit en doublons dans le fichier
ClassMethod BoConfVerifDoublonsInFile(doc As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch) As %Integer
{
	
	//Initialisation des variables *********************
	Set WarningCle = 0 
    Set ParentbatchNumber = ""
   
    
    //initialisation de la key *************************
	Set key = doc.Records.Next()	
	set ^zBoConfVerifDoublonsInFile = ""		
	
	
	//on bloucle sur toutes les lignes *****************
	while(key '= "") {	
		Set record = doc.Records.GetAt(key)
		Set varIDforex = doc.Records.GetAt(key).IDforex	
		Set varID = doc.Records.GetAt(key).%Id()	
		
		&sql(Select %ParentBatch Into :ParentbatchNumber 
	     From CFAO_HUBIC_BofficeConf_recordMap_JournalForex.Record 
		 Where ID = :varID)
		
		
		&sql(SELECT count(IDforex) INTO :NbIdIDforex 
		     FROM CFAO_HUBIC_BofficeConf_recordMap_JournalForex.Record  
		     where IDforex = :varIDforex and %ParentBatch = :ParentbatchNumber)
		     
		//$$$LOGINFO("NbIdIDforex : "_NbIdIDforex)
		if (NbIdIDforex > 1){
			//$$$LOGINFO("varIDforex : "_varIDforex)
			Set WarningCle = WarningCle + 1
			if $Find(^zBoConfVerifDoublonsInFile,varIDforex) = 0 {
				if ^zBoConfVerifDoublonsInFile = ""{
					set ^zBoConfVerifDoublonsInFile = varIDforex					
				}else{
					set ^zBoConfVerifDoublonsInFile = ^zBoConfVerifDoublonsInFile_"/"_varIDforex		
				}
			}
		}
		
		Set key = doc.Records.Next(key)
	}	
	//$$$LOGINFO("WarningCle : "_WarningCle)
	If (WarningCle = 0)
	{
		return 0
	}else{
		return 1    
	}
}

/// On verifie qu'aucun Idforex ne soit deja dans la liste des id en attente de rapprochement
/// Si renvoi d'envoi 
ClassMethod BoConfVerifDejalisteRappro(doc As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch) As %Integer
{
	
	
	//Initialisation des variables *********************
	Set WarningCle = 0 
    
    
    //initialisation de la key *************************
	Set key = doc.Records.Next()	
	set ^zBoConfVerifDejalisteRappro = ""	
	
	//on bloucle sur toutes les lignes *****************
	while(key '= "") {	
		Set record = doc.Records.GetAt(key)
		Set varIDforex = doc.Records.GetAt(key).IDforex	
		
		&sql(SELECT count(IDForex) INTO :NbIdForex 
		     FROM CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
		     where StatutHistoForex = 'NON' and IDForex = :varIDforex )
		     
		//$$$LOGINFO("NbIdForex : "_NbIdForex)
		
		if (NbIdForex > 0){
			Set WarningCle = WarningCle + 1
			if $Find(^zBoConfVerifDejalisteRappro,varIDforex) = 0 {
				if ^zBoConfVerifDejalisteRappro = ""{
					set ^zBoConfVerifDejalisteRappro = varIDforex					
				}else{
					if key < 10 {
						set ^zBoConfVerifDejalisteRappro = ^zBoConfVerifDejalisteRappro_"/"_varIDforex
					}		
				}
			}
		}
		
		Set key = doc.Records.Next(key)
	}	
	
	If (WarningCle = 0)
	{
		return 0
	}else{
		return 1    
	}
}

/// On verifie qu'aucun Idforex n'ai été deja traiter
ClassMethod BoConfVerifDejaTraiter(doc As CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch) As %Integer
{
	
	
	//Initialisation des variables *********************
	Set WarningCle = 0 
    
    
    //initialisation de la key *************************
	Set key = doc.Records.Next()	
	set ^zBoConfVerifDejaTraiter = ""		
	
	//on bloucle sur toutes les lignes *****************
	while(key '= "") {	
		Set record = doc.Records.GetAt(key)
		Set varIDforex = doc.Records.GetAt(key).IDforex	
		
		&sql(SELECT count(IDForex) INTO :NbIDForex 
		     FROM CFAO_HUBIC_BofficeConf_Table.JrnForexRecords 
		     where IDForex = :varIDforex and StatutHistoForex = 'OUI')
		     
		//$$$LOGINFO("NbIDForex  : "_NbIDForex )
		
		if (NbIDForex  > 0){
			Set WarningCle = WarningCle + 1
			if $Find(^zBoConfVerifDejaTraiter,varIDforex) = 0 {
				if ^zBoConfVerifDejaTraiter = ""{
					set ^zBoConfVerifDejaTraiter = varIDforex					
				}else{
					if key < 10 {
						set ^zBoConfVerifDejaTraiter = ^zBoConfVerifDejaTraiter_"/"_varIDforex		
					}
				}
			}
		}
		
		Set key = doc.Records.Next(key)
	}	
	
	If (WarningCle = 0)
	{
		return 0
	}else{
		return 1    
	}
}

ClassMethod BoConfConstructionMail(NomBanquesCB As %String, NomDuFichierConfirmation As %String, RepertoirePJ As %String, ServeurSMTP As %String, IdEAIconfbanque As %String, IdEAIJrnForex As %String, Contrat As %String, EnvoiMail As %String = "OUI") As %Status
{
	    
	    
	    // Mise en variable de la date du jour
		Set DateTraitement = $ZDATE($PIECE($HOROLOG,",",1),8) // format "YYYYMMJJ" 
		Set AnnéeSaisie = $extract(DateTraitement,1,4)
		Set MoisSaisie =  $extract(DateTraitement,5,6)
		Set jourSaisie =  $extract(DateTraitement,7,8)
		Set Htime=$PIECE($HOROLOG,",",2)
		Set ltime = $ZTIME(Htime,1) 
		Set DateTraitTIMESTAMP = AnnéeSaisie_"-"_MoisSaisie_"-"_jourSaisie_" "_ltime //format "YYYY-MM-DD HH:MM:SS"
	    
	    Set DestinataireNom = ""
		Set DestinataireMail = ""
		Set NomBanque = ""
		Set ExpediteurMail = "confirmationforex@cfao.com"	
		Set StatutMail = 1	
		Set SendEmailGeneric = 1
		&SQL(Select DestinataireNom, DestinataireMail, DestinataireMailCopy, NomBanque INTO :DestinataireNom, :DestinataireMail, :DestinataireMailCopy, :NomBanque
			FROM CFAO_HUBIC_BofficeConf_Table.ListeBanqueEtMail
			Where CodeBanque = :NomBanquesCB)
		$$$LOGINFO("DestinataireMail : "_DestinataireMail)
		If $Replace(DestinataireMail," ","") '= "" {
			// Objet du mail
			Set ObjetMail = "CFAO/"_ NomBanque _" - Transaction confirmation "_Contrat
			// Contenue du mail
			Set ContenuDuMail = ##class(%Stream.GlobalCharacter).%New()
			Do ContenuDuMail.Write("Bonjour,"_$CHAR(13)_$c(13,10))
			Do ContenuDuMail.Write("Nous confirmons l'opération dont la référence est "_Contrat_". Vous trouverez en pièce jointe la confirmation."_$c(13,10)_$c(13,10))
			Do ContenuDuMail.Write("Ceci est un mail automatique, merci de ne pas répondre. En cas de problème, adresser votre demande à confirmationforex@cfao.com."_$c(13,10)_$c(13,10))
			Do ContenuDuMail.Write("--"_$c(13,10)_$c(13,10))
			Do ContenuDuMail.Write("Good aftertoon,"_$c(13,10)_$c(13,10))
			Do ContenuDuMail.Write("We hereby confirm the deal under ref "_Contrat_". Please find attached the confirmation."_$c(13,10)_$c(13,10))
			Do ContenuDuMail.Write("This is an automatique email, please do not reply. If you have any issues, please contact us at confirmationforex@cfao.com."_$c(13,10)_$c(13,10))

			Do ContenuDuMail.Write("Service Back Office Forex"_$c(13,10))	
			Do ContenuDuMail.Write("Direction des Financements et de la Trésorerie"_$c(13,10))	
			Do ContenuDuMail.Write("Tél. : +33 (0) 1 46 23 56 08"_$c(13,10))	
			Do ContenuDuMail.Write("Fax : +33 (0) 1 46 23 56 97"_$c(13,10))	
			Do ContenuDuMail.Write("18, rue Troyon - 92 316 Sèvres Cedex - France"_$c(13,10))	
			Do ContenuDuMail.Write("confirmationforex@cfao.com  / www.cfaogroup.com"_$c(13,10))	
							
						
			Set PieceJointeRepertoire = RepertoirePJ
			Set PieceJointeNom = $Replace($Piece(NomDuFichierConfirmation,".",1) _ ".pdf"," ","_")
			If EnvoiMail = "OUI" {
				
				Set SendEmailGeneric = ##class(CFAO.HUBIC.Outils).SendEmailGeneric(ServeurSMTP,DestinataireMail,DestinataireMailCopy,ExpediteurMail,ObjetMail,ContenuDuMail,PieceJointeRepertoire,PieceJointeNom)
				$$$LOGINFO("SendEmailGeneric : "_SendEmailGeneric)
				
				set repertoireSourcePJPDF = PieceJointeRepertoire_PieceJointeNom
				set repertoireArchivePDF = "\\10.0.60.51\root\Comptabilite\EMIR\ArchiveConfirmationBanquePDF\"_PieceJointeNom
				Set commandCopyPDF= "copy """_repertoireSourcePJPDF_ """ """_repertoireArchivePDF_""""
				Set sc=$zf(-1,commandCopyPDF)
				
			}
			
			Set LaConfBanquesSansDest =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(IdEAIconfbanque)			
			Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(IdEAIJrnForex)	
			If ('SendEmailGeneric) {
				Set StatutMail = "Erreur envoi du mail"
				Set LaConfBanquesSansDest.DescErrorCB = "Erreur envoi du mail"
				Set LaConfBanquesSansDest.StatutEnvoiMailCB = "Erreur Envoi"
							
				Do LaConfBanquesSansDest.%Save()
				
				Set LaLigneJrnForex.ErreurJrnForex = "Erreur d'envoi du mail"
								Set StatutEnregRapproJrnForex =  LaLigneJrnForex.%Save()				
			}else{
				Set LaConfBanquesSansDest.DescErrorCB = "Aucune"
				Set LaConfBanquesSansDest.StatutEnvoiMailCB = "Mail Envoyé"
				Set LaConfBanquesSansDest.DateEnvoiMail = DateTraitTIMESTAMP			
				Do LaConfBanquesSansDest.%Save()
				
				Set LaLigneJrnForex.ErreurJrnForex = "Mail Envoyé"
				Set LaLigneJrnForex.DateEnvoiMail = DateTraitTIMESTAMP	
				Set StatutEnregRapproJrnForex =  LaLigneJrnForex.%Save()
			}		
		}else{ //Si pas de destinataire
			Set LaConfBanquesSansDest =  ##class(CFAO.HUBIC.BofficeConf.Table.ConfirmationBanques).%OpenId(IdEAIconfbanque)
			Set LaConfBanquesSansDest.DescErrorCB = "Aucune"
			Set LaConfBanquesSansDest.StatutEnvoiMailCB = "Pas de Destinataire"			
			Do LaConfBanquesSansDest.%Save()
			
			Set LaLigneJrnForex =  ##class(CFAO.HUBIC.BofficeConf.Table.JrnForexRecords).%OpenId(IdEAIJrnForex)
			Set LaLigneJrnForex.ErreurJrnForex = "Pas de Destinataire"	
			Set StatutEnregRapproJrnForex =  LaLigneJrnForex.%Save()
			
			Set StatutMail = "Pas de Destinataire"
		}
		//$$$LOGINFO("SendEmailGeneric : "_SendEmailGeneric)
		return StatutMail
}

}
