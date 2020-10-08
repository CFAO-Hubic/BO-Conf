Class CFAO.HUBIC.BofficeConf.BO.banks.SG.mepTerm Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "MEP Term"
	set firstLine = 1

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	while 'pRequest.AtEnd {
		set line = pRequest.ReadLine()

		// Processed fileName
		If firstLine = 1 {
			set data.confFileName = $p(line, ".", 1)
			set firstLine = 0
		}

		// Contract number and reference
		if $Find(line, "Ref SG de Transaction") {
			set data.contrat= $replace($piece(line,":",2)," ","")
			set data.reference = $replace($piece(line,":",2)," ","")
		}

		// Trade date (03-MAR-2014)
		if $Find(line ,"Date de Conclusion") {
			set data.tradeDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($piece(line,": ",2), "-", 3)
		}

		// Maturity date
		if $Find(line ,"Date de Paiement") {
			set data.maturityDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($piece(line,": ",2), "-", 3)
		}

		// Term
		if $Find(line ,"Taux") {
			set data.term = $replace($piece(line,":",2)," ","") * 1
			if $Extract(data.term,1,1)="."{
				set data.term = "0" _ data.term
			}
		}

		// Received
		if $Find(line ,"Montant et Devise à verser par la Partie A") > 0 {
			set received = $replace($piece(line,":",2)," ","")
			if received {
				set data.amountReceived = $extract(received,1,*-3)
				set data.deviseReceived = $extract(received,*-2,*)
			}
		}

		// Paid
		if $Find(line ,"Montant et Devise à verser par la Partie B") {
			set paid = $replace($piece(line,":",2)," ","")
			if paid {
				set data.amountPaid =  $extract(paid,1,*-3)
				set data.devisePaid = $extract(paid,*-2,*)
			}
		}
	}

    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 0) {
	    set pResponse.status = 0
	    set pResponse.message = data.bank _ " " _ data.confType _ " - Valeur de rapprochement manquante"
	    quit $$$OK
    }

	// Match term between bank and forex
	set resultMatch = ..match(data)

	if resultMatch.%IsDefined(0) {
		set data.idForex	= resultMatch.%Get(0).idForex
		set data.idEaiForex	= resultMatch.%Get(0).idEaiForex
		set match 			= resultMatch.%Get(0).match
	} else {
		set match = 0
	}

	// There is no obvious distinction between spot and term MEP in the SG document provided.
	// So if no term forex line, searching for spot forex line
	if 'match {
		set data2 = {}.%FromJSON(data.%ToJSON())
		set data2.spot = data2.term
		set data2.term = ""
		set data2.valueDate = data2.maturityDate
		set data2.maturityDate = ""

		set resultMatch2 = ..match(data2)

		if resultMatch.%IsDefined(0) {
			set data2.idForex		= resultMatch.%Get(0).idForex
			set data2.idEaiForex	= resultMatch.%Get(0).idEaiForex
			set match 				= resultMatch.%Get(0).match

			set data = data2
		}
	}

	set resultSave = ..save(data, match)

	$$$LOGINFO(data.%ToJSON())

	set pResponse.status = resultSave.status
	set pResponse.message = resultSave.message

	quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="%Stream.FileCharacter"> 
		<Method>saveAndCheckMatch</Method>
	</MapItem>
</MapItems>
}

}
