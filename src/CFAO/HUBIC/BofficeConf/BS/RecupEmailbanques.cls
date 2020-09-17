Class CFAO.HUBIC.BofficeConf.BS.RecupEmailbanques Extends Ens.BusinessService
{

Parameter ADAPTER = "CFAO.HUBIC.BofficeConf.Adapter.AdapterEmailBoConf";

Method OnProcessInput(pInput As %Net.MailMessage, Output pOutput As %RegisteredObject) As %Status
{
	
	//Set ^BoConfDelMail = ^BoConfDelMail + 1
	Set tSC1 = 1
	
	$$$LOGINFO( "DEBUT PROCESSUS==============================================================================")
	
	
	
	/*$$$LOGINFO( "DEB Message details **********************************")
    $$$LOGINFO( "To (count): "_ pInput.To.Count())
    $$$LOGINFO( "From: "_ pInput.From)
    $$$LOGINFO( "Cc (count): "_ pInput.Cc.Count())
    $$$LOGINFO( "Bcc (count): "_ pInput.Bcc.Count())
    $$$LOGINFO( "Date: "_ pInput.Date)
    $$$LOGINFO( "Subject: "_ pInput.Subject)
    $$$LOGINFO( "Sender: "_ pInput.Sender)
    $$$LOGINFO( "IsMultipart: "_ pInput.IsMultiPart)
    $$$LOGINFO( "Number of parts: "_ pInput.Parts.Count())
    $$$LOGINFO( "Number of headers: "_ pInput.Headers.Count())
    $$$LOGINFO( "IsBinary: "_ pInput.IsBinary)
    $$$LOGINFO( "IsHTML: "_ pInput.IsHTML)
    $$$LOGINFO( "TextData: "_ pInput.TextData.Read())
    $$$LOGINFO( "BinaryDataRead: "_ pInput.BinaryData.Read()) 
	$$$LOGINFO( "FIN Message details ***********************************")*/
	
	$$$LOGINFO( "Subject: "_ pInput.Subject)
	/////Set BanqueTraiter = ""
	Set nom = ""
	Set PDFtouver = "NON"
	set ConfirmationTexte = ""
	
	Set NomPdfstring = ""
	Set NomPdf = ""
	
	Set binary = pInput.IsBinary
	Set multi=pInput.IsMultiPart
	
	
		
	//Tourver de quel banques provient le mail
	/////If $Find(pInput.Subject,"Barclays"){
	/////	Set BanqueTraiter = "Barclays"
	/////}
	
	//$$$LOGINFO("BanqueTraiter "_ BanqueTraiter)
	
	Set NbPartMAil = pInput.Parts.Count()
	//$$$LOGINFO("NbPartMAil: "_ NbPartMAil)
	
		
	//recherche d'une piece jointe en PDF
	For partno = 1:1:NbPartMAil{
		//$$$LOGINFO("Trap 1")
		//$$$LOGINFO(" Debut partno PDF "_ partno _"--------------------------------------------")
		Set part = ##class(%Net.MailMessagePart).%New()
		Set part=pInput.Parts.GetAt(partno)	
		Set nom = part.FileName		
		set i = 0
		$$$LOGINFO(partno_" - nom :"_nom)
		if ($Find(nom,"PDF")  > 0 ) || ($Find(nom,"pdf")  > 0) { //WORK WELL with adapter modifiy	
			//$$$LOGINFO("Trap 2 part : "_NbPartMAil)
			//on met le nom du PDF en variable instancier
			If NomPdfstring = ""{
				Set NomPdfstring = nom
			}else{
				Set NomPdfstring = NomPdfstring_"!@@!"_nom
			}			
			Set PDFtouver = "OUI"
		}
			    
		//$$$LOGINFO(" FIN partno PDF"_ partno _"--------------------------------------------")		    
	}
	
	
		
	//Si pas de piece joinate alors on prend le coprs de texte du message
	If PDFtouver = "NON"{
		
	}
		
	if PDFtouver = "OUI"{
		$$$LOGINFO("Confiramtion traitées:"_NomPdfstring)
		Set NomPDFstream = ##class(%Stream.GlobalCharacter).%New() 
		Do NomPDFstream.Write(NomPdfstring)
		Do NomPDFstream.%Save()	
		Set ^EffacerMail = "oui"
		Set tSC1=..SendRequestSync("Routage BO Conf Email Banques",NomPDFstream)
	}else{	
		//$$$LOGINFO("Confiramtion Txt traitées:"_nom)	
		//Set tSC1=..SendRequestSync("Routage BO Conf Email Banques",LignesdeConfirmation)
		
	}
    $$$LOGINFO( "Recup ^EffacerMail BS : "_^EffacerMail)
    $$$LOGINFO( "FIN PROCESSUS==============================================================================")
    
    if tSC1 {
    	Quit tSC1
    }else{
	    Quit $$$OK
    }
}

/*
HELP : http://docs.intersystems.com/ens20131/csp/docbook/DocBook.UI.Page.cls?KEY=EEMA_inbound
Message Contents
Once you know what the general message structure is, use the following techniques to retrieve the contents:
For a multipart message, use the Parts property, which is an array of the parts. Use the Count() method to get the number of parts. Use the GetAt() method to retrieve a given part; the key for each part is an integer, starting with 1 for the first part. 
For a binary message (or message part), use the BinaryData property. 
For a text message (or message part), use the TextData property. 
If IsHTML is 0, the TextData property is an ordinary text string. 
If IsHTML is 1, the TextData property is an HTML text string. 
Note that the email client that sends a message determines any wrapping in the message. The mail server has no control over this; nor does Caché.

*/

/*/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	
	Set ^ListeBoConfDelMail = ""
	Set ^BoConfDelMail = 0
	Quit $$$OK
}*/
}
