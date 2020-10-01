Class CFAO.HUBIC.BofficeConf.BO.banks.SG.swapTerm Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "SWAP Term"

	set i = 0
	set lineBuyed = ""
	set lineSelled = ""

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
			set data.contrat = $replace($piece(line,":",2)," ","")
			set data.opeRef = $replace($piece(line,":",2)," ","")
		}

		if $Find(line, "Date de Conclusion") {
			set data.tradeDate =  ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2))
		}

		// Term
		if $Find(line, data.contrat) {
			set lineBuyed = i + 2
			set lineSelled = i + 1
			set lineRate = i + 3
			set lineValueDate = i + 4
		}

		if i = lineBuyed {
			set buyed = $replace($piece(line,":",2)," ","")
			set data.amountBuy = $extract(buyed,1,*-3)
			set data.deviseBuy = $extract(buyed,*-2,*)
		}

		if i = lineSelled {
			set selled = $replace($piece(line,":",2)," ","")
			set data.amountSell = $extract(NousVendonsC,1,*-3)
			set data.deviseSell = $extract(NousVendonsC,*-2,*)
		}

		if i = lineRate {
			set data.spot = $replace($piece(line,":",2)," ","") * 1
			if $Extract(data.spot,1,1)="."{
				set data.spot = "0" _ data.spot
			}
		}

		if i = lineMaturityDate {
			set data.maturityDate =  ##class(CFAO.HUBIC.Outils).convertTextDate($piece(line,": ",2))
		}
	}

    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 2) {
	    set pResponse.status = 0
	    set pResponse.message = "SGSWAP - Valeur de rapprochement terme manquante"
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
