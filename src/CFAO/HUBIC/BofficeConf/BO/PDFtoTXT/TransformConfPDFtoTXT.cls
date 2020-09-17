Class CFAO.HUBIC.BofficeConf.BO.PDFtoTXT.TransformConfPDFtoTXT Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Property repertoirePDFtoTXT As %String;

Property repertoireSourcePJPDF As %String;

Property repertoireCiblePJTXT As %String;

Parameter SETTINGS = "repertoirePDFtoTXT,repertoireSourcePJPDF,repertoireCiblePJTXT";

/// /Method EnregEtRapprochePJ(pRequest As %Library.FileCharacterStream, Output pResponse As %Library.Persistent) As %Status
/// This is the default message handler.  All request types not declared in the message map are delivered here
Method EnregConfTXT(pRequest As Ens.StreamContainer, Output pResponse As Ens.StringResponse) As %Status
{
	
	// Instanciation de la Response *****************************************************************************
	set pResponse = ##class(Ens.StringResponse).%New()
	set pResponse.StringValue = "OK"
	// **********************************************************************************************************

	Set NomPdfOriginal = $Piece(pRequest.OriginalFilename,"\",$LENGTH(pRequest.OriginalFilename,"\"))
	//$$$LOGINFO("NomPdfOriginal : "_NomPdfOriginal)
	Set compteurPDF = ##class(CFAO.HUBIC.Outils).HCreateUniqueId("BoConfPDF")	
	
	
	Set repertoirePDFtoTXT = ..repertoirePDFtoTXT
	Set repertoireSourcePJPDF  = ..repertoireSourcePJPDF_NomPdfOriginal
	Set repertoireCiblePJTXT  = ..repertoireCiblePJTXT_$piece(NomPdfOriginal,".",1)_ "!##!" _ compteurPDF _ ".txt"
	
	Set command= repertoirePDFtoTXT_"pdftotext -f 1 -l 2 -layout -raw -eol dos """_repertoireSourcePJPDF_ """ """_repertoireCiblePJTXT_""""
	Set sc=$zf(-1,command)
	//$$$LOGINFO(command_" : "_sc)
	If sc '= 0 {
		Set pResponse.StringValue = "Probleme de transformation en TXT du fichier " _ NomPdfOriginal	
		$$$LOGWARNING("Probleme de transformation en TXT du fichier " _ NomPdfOriginal)
	}else{
		Set pRequest.OriginalFilename = $piece(NomPdfOriginal,".",1)_ "!##!" _ compteurPDF _ ".pdf"
		//$$$LOGINFO("pRequest.OriginalFilename : "_pRequest.OriginalFilename)
		Do pRequest.%Save()
	}	
 	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StreamContainer"> 
		<Method>EnregConfTXT</Method>
	</MapItem>
</MapItems>
}

}
