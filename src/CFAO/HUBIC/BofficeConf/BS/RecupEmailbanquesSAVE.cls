Class CFAO.HUBIC.BofficeConf.BS.RecupEmailbanquesSAVE Extends (Ens.BusinessService, Ens.Adapter)
{

// Parameter ADAPTER = "CFAO.HUBIC.BofficeConf.Adapter.AdapterEmailBoConf";

Parameter ADAPTER = "EnsLib.SQL.InboundAdapter";

Property Adapter As EnsLib.SQL.InboundAdapter;

Method OnProcessInput(pInput As EnsLib.SQL.Snapshot, Output pOutput As %RegisteredObject) As %Status
{
	
	$$$LOGINFO( "DEBUT PROCESSUS==============================================================================")
	
	Set RecupMail = ..GetPJ("outlook.office365.com","995")
	
	/*
	$$$LOGINFO( "DEB Message details **********************************")
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
	$$$LOGINFO( "FIN Message details ***********************************")
	*/
	
	

	    Quit $$$OK
}

Method GetPJ(ServeurPOP3 As %String, PortPOP2 As %String)
{
  
  Set server=##class(%Net.POP3).%New()
  //Set CodeBanque = pInput.CodeBanque
 // Set LibBanque = pInput.LibBanque
  //Set EmailBanque = pInput.EmailBanque
  Set CredentialBanque = "HubicMailPF"
  
  //HotPOP POP3 server uses the default port
  //but let's set it anyway
  //Set server.port=110

  //just in case we plan to fetch any messages
  //that have attachments
  Set server.SSLConfiguration = "Office365"
  Set server.StoreAttachToFile=1
  Set server.StoreInlineToFile=1
  Set server.AttachDir="D:\hubic\BackOfficeConf\MailPJ"

  
  If '$IsObject(..%CredentialsObj) Do ..CredentialsSet(CredentialBanque) If '$IsObject(..%CredentialsObj) { Set tSC=$$$EnsError($$$EnsErrNoCredentials,CredentialBanque) Quit }
  $$$LOGINFO("Username : "_ ..%CredentialsObj.Username)
  $$$LOGINFO("Password : "_ ..%CredentialsObj.Password)
  Set status=server.ConnectPort(ServeurPOP3,PortPOP2,..%CredentialsObj.Username,..%CredentialsObj.Password)
  $$$LOGINFO("StatutConnect : "_status)
  Set status=server.GetMailBoxStatus(.count,.size)
  $$$LOGINFO("count : "_ count)
  $$$LOGINFO("size : "_ size)
  
  
  

	For msgno = 1:1:count
	{
		$$$LOGINFO("msgno : "_ msgno)
		Set statusPJ = ..GetMsg(server,msgno)
		$$$LOGINFO( "DEB Message details **********************************")
	    $$$LOGINFO( "To (count): "_ statusPJ.To.Count())
	    $$$LOGINFO( "From: "_ statusPJ.From)
	    $$$LOGINFO( "Cc (count): "_ statusPJ.Cc.Count())
	    $$$LOGINFO( "Bcc (count): "_ statusPJ.Bcc.Count())
	    $$$LOGINFO( "Date: "_ statusPJ.Date)
	    $$$LOGINFO( "Subject: "_ statusPJ.Subject)
	    $$$LOGINFO( "Sender: "_ statusPJ.Sender)
	    $$$LOGINFO( "IsMultipart: "_ statusPJ.IsMultiPart)
	    $$$LOGINFO( "Number of parts: "_ statusPJ.Parts.Count())
	    $$$LOGINFO( "Number of headers: "_ statusPJ.Headers.Count())
	    $$$LOGINFO( "IsBinary: "_ statusPJ.IsBinary)
	    $$$LOGINFO( "IsHTML: "_ statusPJ.IsHTML)
	    $$$LOGINFO( "TextData: "_ statusPJ.TextData.Read())
	    $$$LOGINFO( "BinaryDataRead: "_ statusPJ.BinaryData.Read()) 
	    $$$LOGINFO( "Charset "_ statusPJ.Charset)    
		$$$LOGINFO( "FIN Message details ***********************************")
		
	}  
  
  
  
  If $$$ISERR(status) 
  {
    Do $System.Status.DisplayError(status) 
    Quit $$$ERROR()
  }
  
  Quit server
}

Method GetMsg(server As %Net.POP3, msgno As %Integer) As %Net.MailMessage
{
    Set status=server.Fetch(msgno,.msg)
    //$$$LOGINFO("msg : "_ msg.From)
    
    If $$$ISERR(status) 
       {Do $System.Status.DisplayError(status) 
       Quit $$$ERROR()
       }
	
	set envoiMail = ..SendEmail(msg)
	
	Set status=server.Fetch(msgno,.msg,1)
    Set status=server.QuitAndCommit() 
    Quit msg
}

/// Methode d'envoi de mail pour les erreurs (D.DIOP)
ClassMethod SendEmail(Msg As %Net.MailMessage)
{
    
    
    $$$LOGINFO( "DEBUT Part")
    Set NbPartMAil = Msg.Parts.Count()
	$$$LOGINFO("NbPartMAil: "_ NbPartMAil)
	Set LignesdeConfirmation = ##class(%Stream.FileBinary).%New()
	For partno = 1:1:NbPartMAil{
		$$$LOGINFO("Trap 4 part : "_partno)
		Set part = ##class(%Net.MailMessagePart).%New()
		Set part=Msg.Parts.GetAt(partno)	
		Set nom = part.FileName		
		
		
		Set i = 0		
		
		While ('part.BinaryData.AtEnd) {
		    set i = i + 1			   
		    set ConfirmationTexte = part.BinaryData.ReadLine()			    
		    //$$$LOGINFO(" ConfirmationTexte"_ ConfirmationTexte)
		    if $Replace(ConfirmationTexte," ","") '= ""{
			    set ConfirmationTexte = $Replace(ConfirmationTexte,"&nbsp;"," ")
			    Set ConfirmationTexte = ConfirmationTexte_$CHAR(13)	    			
				Do LignesdeConfirmation.Write(ConfirmationTexte)
				//$$$LOGINFO("BinaryData Pour i :"_i_"ConfirmationTexte "_ ConfirmationTexte)			    	
		    }
		}	
		
		/*//$$$LOGINFO(partno_" - nom :"_nom)
	    While ('part.TextData.AtEnd) {
		    set i = i + 1			   
		    set ConfirmationTexte = part.TextData.ReadLine()			    
		    $$$LOGINFO(" ConfirmationTexte"_ ConfirmationTexte)
		    if $Replace(ConfirmationTexte," ","") '= ""{
			    set ConfirmationTexte = $Replace(ConfirmationTexte,"&nbsp;"," ")
			    Set ConfirmationTexte = ConfirmationTexte_$CHAR(13)	    			
				Do LignesdeConfirmation.Write(ConfirmationTexte)
				$$$LOGINFO("Pour i :"_i_"ConfirmationTexte "_ ConfirmationTexte)			    	
		    }
		}*/	
		
		    
		//$$$LOGINFO(" FIN partno TXT"_ partno _"--------------------------------------------")		    
	}	
	Do LignesdeConfirmation.%Save()	
	$$$LOGINFO( "FIN Part")
    
    
    
    
    
    
    // Create an SMTP object and connect to a server
    Set Mailer = ##class(%Net.SMTP).%New()

    // Fill in the name of your mail server
    Set Mailer.smtpserver = "10.0.241.3"

    // Create a Message object and fill in From, To, Subject
    Set Msgt = ##class(%Net.MailMessage).%New()
    
    set Msgt.Subject = "[EAI] test Envoi file par mail"		//Initiliastion du sujet du mail
	set Msgt.From = Msg.From					//Emeteur du mail
	do Msgt.To.Insert("dediop@cfao.com")					//Destinataire du mail	
	
	
	set Msgt.IsMultiPart = 1 								//ce mail comprendra plusieurs part
	set Msgt.MultiPartType = "mixed"						// ces part seront Mixer dans le mail final
	set Msgt.Charset = "UTF-8"
	// Création de la Part corps du message *******************************************************
	
	set mail1 = ##class(%Net.MailMessagePart).%New()
	set mail1.IsBinary = 0
	set mail1.IsHTML = 0
	set mail1.Charset = "UTF-8"
	set status=mail1.TextData.Write(LignesdeConfirmation.Read())
	
	Do Msgt.Parts.SetAt(mail1,1) // Mise en varible de la Part 1
	
	// ********************************************************************************************
   
    // Send the message and close objects
    Do Mailer.Send(Msgt)
    Quit $$$OK
}

/*
Method OnProcessInput(pInput As %Net.MailMessage, Output pOutput As %RegisteredObject) As %Status
{
	
	//Set ^BoConfDelMail = ^BoConfDelMail + 1
	Set tSC1 = 1
	
	$$$LOGINFO( "DEBUT PROCESSUS==============================================================================")
	
	
	
	$$$LOGINFO( "DEB Message details **********************************")
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
    $$$LOGINFO( "Charset "_ pInput.Charset) 
	$$$LOGINFO( "FIN Message details ***********************************")
	
	$$$LOGINFO( "Subject: "_ pInput.Subject)
	//now safe to get text of message
    
    
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
	$$$LOGINFO("NbPartMAil: "_ NbPartMAil)
	
		
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
	
	
	$$$LOGINFO( "DEBUT Part")
	Set LignesdeConfirmation = ##class(%Stream.GlobalCharacter).%New()
	For partno = 1:1:NbPartMAil{
		$$$LOGINFO("Trap 4 part : "_partno)
		Set part = ##class(%Net.MailMessagePart).%New()
		Set part=pInput.Parts.GetAt(partno)	
		Set nom = part.FileName				
		
		
		$$$LOGINFO("Message part details *****")
    	$$$LOGINFO( "Message part: " _ partno)
    	$$$LOGINFO( "IsMultipart: "_ part.IsMultiPart)
    	$$$LOGINFO( "Number of parts: "_ part.Parts.Count())
    	$$$LOGINFO( "Number of headers: "_ part.Headers.Count())
    	$$$LOGINFO( "IsBinary: "_ part.IsBinary)
    	$$$LOGINFO( "IsHTML: "_ part.IsHTML)
    	$$$LOGINFO( "TextData: "_ part.TextData.Read())
    	$$$LOGINFO( "BinaryData: "_ part.BinaryData.OpenStream())
		
		
		
		
		
		
		
		
		
		Set tt = part.BinaryData.Read()
		$$$LOGINFO(" tt "_ tt)
		Set tt2 = part.BinaryData.ReadLine()
		$$$LOGINFO(" tt2 "_ tt2)
		
		Set i = 0		
		//$$$LOGINFO(partno_" - nom :"_nom)
	    While ('part.TextData.AtEnd) {
		    set i = i + 1			   
		    set ConfirmationTexte = part.TextData.ReadLine()			    
		    $$$LOGINFO(" ConfirmationTexte"_ ConfirmationTexte)
		    if $Replace(ConfirmationTexte," ","") '= ""{
			    set ConfirmationTexte = $Replace(ConfirmationTexte,"&nbsp;"," ")
			    Set ConfirmationTexte = ConfirmationTexte_$CHAR(13)	    			
				Do LignesdeConfirmation.Write(ConfirmationTexte)
				$$$LOGINFO("Pour i :"_i_"ConfirmationTexte "_ ConfirmationTexte)			    	
		    }
		}	
		
		    
		//$$$LOGINFO(" FIN partno TXT"_ partno _"--------------------------------------------")		    
	}	
	Do LignesdeConfirmation.%Save()	
	$$$LOGINFO( "FIN Part")
	
	
	
		
	
		
	if PDFtouver = "OUI"{
		$$$LOGINFO("Confiramtion traitées:"_NomPdfstring)
		Set NomPDFstream = ##class(%Stream.GlobalCharacter).%New() 
		Do NomPDFstream.Write(NomPdfstring)
		Do NomPDFstream.%Save()	
		Set ^EffacerMail = "oui"
		//Set tSC1=..SendRequestSync("Routage BO Conf Email Banques",NomPDFstream)
	}else{	
		//$$$LOGINFO("Confiramtion Txt traitées:"_nom)	
		//Set tSC1=..SendRequestSync("Routage BO Conf Email Banques",LignesdeConfirmation)
		
	}
    $$$LOGINFO( "Recup ^EffacerMail BS : "_^EffacerMail)
    $$$LOGINFO( "FIN PROCESSUS==============================================================================")
    
    //if tSC1 {
    //	Quit tSC1
    //}else{
	    Quit $$$OK
   // }
}
*/

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
