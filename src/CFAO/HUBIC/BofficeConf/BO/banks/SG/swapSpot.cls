Class CFAO.HUBIC.BofficeConf.BO.banks.SG.swapSpot Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "SWAP Spot"

	set (
		i,
		lineReceived,
		linePaid,
		lineRate,
		lineValueDate
	) = 0

	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	while 'pRequest.AtEnd {
		set i = i + 1
		set line = pRequest.ReadLine()

		If i = 1 {
			set data.confFileName = line
		}

		if $Find(line,"Ref SG de Transaction") {
			set data.contrat = $replace($p(line,":",2)," ","")
			set data.opeRef = $replace($p(line,":",2)," ","")
		}

		if $Find(line, "Date de Conclusion") {
			set data.tradeDate =  ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line," : ",2), "-", 3)
		}

		if line = "Patte court terme du swap" {
			set lineReceived	= i + 2
			set linePaid		= i + 1
			set lineRate		= i + 3
			set lineValueDate	= i + 4
		}

		if i = lineReceived {
			set buyed = $replace($p(line,":",2)," ","")
			set data.amountReceived = ..normalize($e(buyed,1,*-3))
			set data.deviseReceived = $e(buyed,*-2,*)
		}

		if i = linePaid {
			set selled = $replace($p(line,":",2)," ","")
			set data.amountPaid = ..normalize($e(selled,1,*-3))
			set data.devisePaid = $e(selled,*-2,*)
		}

		if i = lineRate {
			set data.spot = $p(line,": ",2) * 1
		}

		if i = lineValueDate {
			set data.valueDate =  ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line,": ",2), "-", 3)
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

	set resultSave = ..save(data, match)

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
