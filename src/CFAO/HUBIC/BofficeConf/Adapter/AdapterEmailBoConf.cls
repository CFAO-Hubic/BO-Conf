Class CFAO.HUBIC.BofficeConf.Adapter.AdapterEmailBoConf Extends EnsLib.EMail.InboundAdapter
{

Parameter SETTINGS = "AttachDir";

Property AttachDir As %String(MAXLEN = 200) [ InitialExpression = "D:\HUBIC\BackOfficeConf\MailPJ\" ];

Method OnInit() As %Status
{

 Set tSC=##super()
 
 $$$LOGINFO( "Passage INIT")
 Set ^EffacerMail = "non"
 If 'tSC Quit tSC 
 
 Set ..MailServer.AttachDir=..AttachDir
 //Hang 10
 Set ..MailServer.StoreAttachToFile=1
 //Hang 10
 Set ..MailServer.StoreInlineToFile=1
 //Hang 10
 Quit tSC
 
 //Recup BO Conf Email Banques
}

Method OnTask() As %Status
{
#define MsgTable(%msgid) $$$EnsRuntimeAppData(..BusinessHost.%ConfigName,%msgid)

	Set $ZT="Trap",tSC=$$$OK,tCurrMsgID="" 
	Do {
		$$$sysTRACE("..%UIDArray='"_..%UIDArray_"', ..%ILastMsg="_..%ILastMsg_", ..%UIDKey="_..%UIDKey_", ..%UIDArray.Count()="_$S($IsObject(..%UIDArray):..%UIDArray.Count(),1:0)_", ..MailServer.Connected="_..MailServer.Connected)

		#; (Re-)connect to the server if in clean state
		If '$IsObject(..%UIDArray) {
			$$$ASSERT(""=..%UIDKey&&(0=..%ILastMsg)&&'..MailServer.Connected)
			$$$sysTRACE("Connecting...")
			If '$IsObject(..%CredentialsObj) Do ..CredentialsSet(..Credentials) If '$IsObject(..%CredentialsObj) { Set tSC=$$$EnsError($$$EnsErrNoCredentials,..Credentials) Quit }
			Set tSC = ..MailServer.ConnectPort(..POP3Server,..POP3Port,..%CredentialsObj.Username,..%CredentialsObj.Password)
			$$$SetJobMonitor(..BusinessHost.%ConfigName,$$$SystemName_":"_$Job,$$$eMonitorConnected,..MailServer.Connected_"|"_$$$timeUTC_"|"_..POP3Server_":"_..POP3Port)
			Set:$$$ISOK(tSC) tSC = ..MailServer.GetMessageUIDArray("",.tUIDArray) ; get results from UIDL command
			If $$$ISERR(tSC) || '$IsObject(tUIDArray) || (0=tUIDArray.Count()) {
				$$$sysTRACE("No Messages - Disconnecting...")
				If ..MailServer.Connected { Set tSCQuit = ..MailServer.QuitAndCommit()  Set:$$$ISOK(tSC) tSC = tSCQuit }
				If $$$ISERR(tSC) $$$LOGSTATUS(tSC)
				Quit
			} Else {
				If (0'=tUIDArray.Count()) { $$$sysTRACE("POP3 server reports "_tUIDArray.Count()_" messages in mailbox on server") }
			}
			Set ..%UIDArray=tUIDArray
			Kill ..%MsgsFound
		}
		#; Find the next one that can be processed
		For {
			Set ..%UIDKey = ..%UIDArray.Next(..%UIDKey), ..%ILastMsg=..%ILastMsg+1  Quit:""=..%UIDKey  ; done finding them
			Set tOneUID = ..%UIDArray.GetAt(..%UIDKey)  $$$ASSERT(""'=tOneUID)
			#; Get header, test for matching From,To, and/or Subject header
			Set tSC = ..MailServer.FetchMessageHeaders(..%UIDKey,.taMsgHeaders)  Quit:$$$ISERR(tSC)
			Set tOneMsgID=$G(taMsgHeaders("message-id")) If ""=tOneMsgID $$$LOGWARNING("Received message "_..%UIDKey_" with no message-id (Unable to lock or mark it errored), From: "_$G(taMsgHeaders("from"))_", Subject: "_$G(taMsgHeaders("subject")))

			#; Check for a matching message we can deal with
			$$$sysTRACE("Got msg header '"_tOneMsgID_"', test for hdrs match") ; - From: "_$G(taMsgHeaders("from"))_", To: "_$G(taMsgHeaders("to"))_", Subject: "_$G(taMsgHeaders("subject")))
			Set tFromMatch=(""=..MatchFrom) For i=1:1:$L(..MatchFrom,";") If $G(taMsgHeaders("from"))[$P(..MatchFrom,";",i) Set tFromMatch=1 Quit
			Set tToMatch=(""=..MatchTo) For i=1:1:$L(..MatchTo,";") If $G(taMsgHeaders("to"))[$P(..MatchTo,";",i) Set tToMatch=1 Quit
			Set tSubjectMatch=(""=..MatchSubject) For i=1:1:$L(..MatchSubject,";") If $G(taMsgHeaders("subject"))[$P(..MatchSubject,";",i) Set tSubjectMatch=1 Quit
			If tFromMatch && tToMatch && tSubjectMatch {
				If ""'=tOneMsgID {
					Set ..%MsgsFound(tOneMsgID)=1
					#; Check for previously locked or errored messages	
					Lock +$$$MsgTable(tOneMsgID):0 Else  $$$LOGINFO("Skipping locked Message '"_tOneMsgID_"'") Continue
					If $G($$$MsgTable(tOneMsgID),0) If $G(^(tOneMsgID,"wrn")) { Kill ^("wrn") $$$LOGWARNING("Skipping previously errored message '"_tOneMsgID_"'") } Lock -$$$MsgTable(tOneMsgID) Continue
					$$$LOGINFO( "Passage Skip")
					Set ^EffacerMail = "non"
				}
				$$$sysTRACE("Got matching msg - header '"_tOneMsgID_"', From: "_$G(taMsgHeaders("from"))_", To: "_$G(taMsgHeaders("to"))_", Subject: "_$G(taMsgHeaders("subject")))
				Set:""'=tOneMsgID $$$MsgTable(tOneMsgID)=1, ^(tOneMsgID,"wrn")=1
				Set tCurrMsgID=$S(""'=tOneMsgID:tOneMsgID,1:"x")
				Quit ; found a good one
			}
		}
		If ""=..%UIDKey || $$$ISERR(tSC) {
			#; Done with this UIDArray now; Disconnect
			$$$ASSERT($$$ISERR(tSC)||(""=tCurrMsgID && (..%ILastMsg-1=..%UIDArray.Count())))

			$$$sysTRACE("Disconnecting...")
			If ..MailServer.Connected { Set tSCQuit = ..MailServer.QuitAndCommit()  Set:$$$ISOK(tSC) tSC = tSCQuit }

			#; Remove errored UIDs from global if they no longer exist
			Set m="" For  Set m=$Order($$$MsgTable(m))  Quit:m=""  If '$G(..%MsgsFound(m),0) Kill $$$MsgTable(m) $$$sysTRACE("Removed absent message '"_m_"' from errored list")
			Kill ..%MsgsFound
			Set ..%UIDArray= $$$NULLOREF, ..%UIDKey="", ..%ILastMsg=0
			Quit
		}
		$$$ASSERT(tCurrMsgID'="")

		#; call BusinessService for processing
		Set tSC = ..MailServer.Fetch(..%ILastMsg,.tMailMessage)  Quit:$$$ISERR(tSC) ; Get full message
		$$$LOGINFO("Processing Mail Message "_..%ILastMsg_"/"_..%UIDArray.Count()_":'"_tCurrMsgID_"' From: "_tMailMessage.From_", To: "_tMailMessage.To.GetAt(1)_", Subject: "_tMailMessage.Subject)
		Set tSC = ..BusinessHost.ProcessInput(tMailMessage)  Quit:$$$ISERR(tSC)
		#; Delete Message from Server
		$$$LOGINFO( "Delete Massage"_..%UIDKey)
		if ^EffacerMail = "oui" {			
			Set tSC = ..MailServer.DeleteMessage(..%UIDKey)  Quit:$$$ISERR(tSC)
		}
		
		//Set tSC = ..MailServer.DeleteMessage(..%UIDKey)  Quit:$$$ISERR(tSC)
		#; Mark the Message Not Errored
		Kill:"x"'=tCurrMsgID $$$MsgTable(tCurrMsgID)
	} While 0
Exit
	Lock:""'=tCurrMsgID&&("x"'=tCurrMsgID) -$$$MsgTable(tCurrMsgID)
	$$$SetJobMonitor(..BusinessHost.%ConfigName,$$$SystemName_":"_$Job,$$$eMonitorConnected,..MailServer.Connected_"|"_$$$timeUTC_"|"_..POP3Server_":"_..POP3Port)
	Quit tSC
Trap
	Set $ZT="",tSC=$$$EnsSystemError
	#; Disconnect if needed
	Do:..MailServer.Connected ..MailServer.QuitAndCommit()
	Goto Exit
}

}
