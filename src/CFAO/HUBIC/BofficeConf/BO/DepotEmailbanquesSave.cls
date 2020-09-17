Class CFAO.HUBIC.BofficeConf.BO.DepotEmailbanquesSave Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Property Adapter As EnsLib.File.OutboundAdapter;

Parameter INVOCATION = "Queue";

Property repertoirePDFtoTXT As %String;

Property repertoireSourcePJPDF As %String;

Property repertoireCiblePJTXT As %String;

/// Repertoire de dépôt des confirmations des banques pour le flux Bo Confirmation
Property repertoireBOCONF As %String(MAXLEN = 100);

Parameter SETTINGS = "repertoirePDFtoTXT,repertoireSourcePJPDF,repertoireCiblePJTXT,repertoireBOCONF";

Method OnMessage(pRequest As %Library.Persistent, Output pResponse As Ens.StringResponse) As %Status
{
	
	
	
	Set BanqueTraitée = ""
	set strMessage =  ""
	Set NomDuFichierTXT = "Generique"
	Set ListeNomFileError = ""
	Set ListeNomFileOK = ""
	Set RefOperation = ""
	// Instanciation de la Response
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = ""	
	
	
	Set ConfirmationTXT = ##class(%Stream.FileCharacter).%New()
	While 'pRequest.AtEnd {		
		Set Laligne = pRequest.ReadLine()_$CHAR(13)
		set strMessage =  Laligne
		//$$$LOGINFO("Laligne :"_Laligne)
		Do ConfirmationTXT.WriteLine(Laligne)	
		if $Find(Laligne,"FX">0){
			Set RefFXnum = $Replace($Piece(Laligne,"FX",2)," ","")
			Set RefFX = "BAR"_$Extract(RefFXnum,1,8)
			Set NomDuFichierTXT = RefFX_".txt"  
		}
		if $Find(Laligne,"Barclays") > 0 {
			Set BanqueTraitée = "BARCLAYS"
    		set strMessage = "BARCLAYS"
    		//Set NomDuFichierTXT = $Replace($Piece(Laligne,"Barclays",2)," ","")    		
    	}
    	if $Find(Laligne ,"Notre référence") > 0 {
			Set RefOperation = $replace($piece(Laligne,":",2)," ","")
			Set RefOperation = $replace(RefOperation,"/","")
		}	
    	
	}	
	Do ConfirmationTXT.%Save()		
	Do pRequest.Rewind()
      
     
    //$$$LOGINFO("NomDuFichierTXT :"_NomDuFichierTXT)
	//$$$LOGINFO("strMessage :"_strMessage)
	//$$$LOGINFO("RefOperation :"_RefOperation)
	
	
	
	If strMessage '= "BARCLAYS" {	//Si la confirmation est PDF
		SET NbPdfToRetrieve =$LENGTH(strMessage,"!@@!")

		For partno = 1:1:NbPdfToRetrieve{ 
		
			if $Find(strMessage,"!@@!"){
				Set NomPdfPieceJointe = $piece(strMessage,"!@@!",partno)
			}else{
				Set NomPdfPieceJointe = strMessage
			}
			
			//$$$LOGINFO("NomPdfPieceJointe :"_NomPdfPieceJointe)
			
			if $Find(NomPdfPieceJointe,"Confirmation."){
				Set BanqueTraitée  = "CACIB"
				//$$$LOGINFO("BanqueTraitée :"_BanqueTraitée)
			}			
			
			Set compteurPDF = ##class(CFAO.HUBIC.Outils).HCreateUniqueId("BoConfPDF")
			
			Set repertoirePDFtoTXT = ..repertoirePDFtoTXT
			Set repertoireSourcePJPDF  = ..repertoireSourcePJPDF_NomPdfPieceJointe
			Set repertoireCiblePJTXT  = ..repertoireCiblePJTXT_$piece(NomPdfPieceJointe,".",1)_ "!##!" _ compteurPDF _ ".txt"			
			if BanqueTraitée  = "CACIB"{
				Set repertoireCiblePJTXT  = ..repertoireCiblePJTXT_"CA"_RefOperation_".txt"	
				//$$$LOGINFO("repertoireCiblePJTXT :"_repertoireCiblePJTXT)			
			}
			
			
						
			Set command= repertoirePDFtoTXT_"pdftotext -f 1 -l 2 -layout -raw -eol dos """_repertoireSourcePJPDF_ """ """_repertoireCiblePJTXT_""""

			Set sc=$zf(-1,command)
			//$$$LOGINFO(command_" : "_sc)
			
			Set commandCopyPDF= "move """_repertoireSourcePJPDF_ """ """_..repertoireBOCONF_$piece(NomPdfPieceJointe,".",1)_"!##!"_compteurPDF_".PDF"_""""

			Set sc=$zf(-1,commandCopyPDF)
			$$$LOGINFO(commandCopyPDF_" : "_sc)
			
			// end of execute
			If sc '= 0 {
				if ListeNomFileError = ""{
					Set ListeNomFileError = NomPdfPieceJointe
				}else{
					Set ListeNomFileError = ListeNomFileError_"!@@!"_NomPdfPieceJointe
				}
				set pResponse.StringValue = "ERROR!##!"_ListeNomFileError			
			}else{
				if ListeNomFileOK = ""{
					Set ListeNomFileOK = NomPdfPieceJointe
				}else{
					Set ListeNomFileOK = ListeNomFileOK_"!@@!"_NomPdfPieceJointe
				}
				set pResponse.StringValue = "OK!##!"_ListeNomFileOK_"!##!"_BanqueTraitée
			}
			//$$$LOGINFO("sc : "_sc)
		}
		
 	}else{ 		//Sinon si la confirmation est dans le corps du texte
		Set scTwo = ..Adapter.PutStream(NomDuFichierTXT,ConfirmationTXT)
		$$$LOGINFO("scTwo : "_scTwo)
		If scTwo '= 0 {
			set pResponse.StringValue = "OK!##!"_NomDuFichierTXT_"!##!"_BanqueTraitée
		}else{
			set pResponse.StringValue = "ERROR!##!"_NomDuFichierTXT_"!##!"_BanqueTraitée
		}
	}
	
	
	$$$LOGINFO("pResponse.StringValue : "_pResponse.StringValue)
	
	
	Quit $$$OK
}

}
