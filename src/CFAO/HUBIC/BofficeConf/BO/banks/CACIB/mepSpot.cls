Class CFAO.HUBIC.BofficeConf.BO.banks.CACIB.mepSpot Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "CACIB"
	set data.confType = "MEP Spot"
	set firstLine = 1

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	while 'pRequest.AtEnd {
		set line = pRequest.ReadLine()

		// Processed confFileName
		If firstLine = 1 {
			set data.confFileName = line
			set firstLine = 0
		}

		// Contract number and reference
		if $Find(line, "Notre référence") {
			set data.contrat = $p($replace($p(line,":",2)," ",""), "/", 1)
			set data.reference = data.contrat
		}

		// Trade date (03-MAR-2014)
		if $Find(line ,"Date d'opération") {
			set data.tradeDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($piece(line,": ",2), "-", 3)
		}

		// Value date
		if $Find(line ,"Date de valeur") {
			set data.valueDate = ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($piece(line,": ",2), "-", 3)
		}

		// Spot
		if $Find(line ,"Cours au comptant") {
			set data.spot = $replace($piece(line,":",2)," ","") * 1
			if $Extract(data.spot,1,1)="." set data.spot = "0" _ data.spot
		}

		// Received
		if $Find(line ,"Nous vendons") {
			set received = $p(line,": ",2)
			if received '= "" {
				set data.amountReceived = $p(received, " ", 2)
				set data.deviseReceived = $p(received, " ", 1)
			}
		}

		// Selled
		if $Find(line ,"Nous achetons") {
			set paid = $p(line,": ",2)
			if paid '= "" {
				set data.amountPaid = $p(paid, " ", 2)
				set data.devisePaid = $p(paid, " ", 1)
			}
		}
	}


    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 1) {
	    set pResponse.status = 0
	    set pResponse.message = data.bank _ " " _ data.confType _ " - Valeur de rapprochement manquante"
	    quit $$$OK
    }

	set resultMatch = ..match(data)

	if resultMatch.%IsDefined(0) {
		set data.idForex	= resultMatch.%Get(0).idForex
		set data.idEaiForex	= resultMatch.%Get(0).idEaiForex
		set match 			= resultMatch.%Get(0).match
	} else {
		set match = 0
	}

	set tSC = ..save(data, match)

	set pResponse.status = tSC.status
	set pResponse.message = tSC.message

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
