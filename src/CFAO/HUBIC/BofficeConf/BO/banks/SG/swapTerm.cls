Class CFAO.HUBIC.BofficeConf.BO.banks.SG.swapTerm Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As CFAO.HUBIC.BofficeConf.messages.checkBankMsg) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "SWAP Term"

	set (
		i,
		lineInfo,
		lineReceived,
		linePaid,
		lineRate,
		lineMaturityDate
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
			set data.reference = $replace($p(line,":",2)," ","")
		}

		if $Find(line, "Date de Conclusion") {
			set data.tradeDate =  ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line," : ",2), "-", 3)
		}

		if line = "Patte long terme du swap" {	
			set lineInfo			= 1
			set lineReceived		= i
			set linePaid			= i + 1
			set lineRate			= i + 2
			set lineMaturityDate	= i + 3
		}

		// The informations can be in the next page, which is delimited by separator lines like *SIC20200930723815*.
		// The index must therefore be incremented each time the expected strings can't be find
		if lineInfo
		&& '$Find(line, "Montant et Devise à verser par la Partie A : ")
		&& '$Find(line, "Montant et Devise à verser par la Partie B : ")
		&& '$Find(line, "Taux : ")
		&& '$Find(line, "Date de Paiement : ")
		{
			set lineReceived		= lineReceived + 1
			set linePaid			= linePaid + 1
			set lineRate			= lineRate + 1
			set lineMaturityDate	= lineMaturityDate + 1
		}

		if i = lineReceived {
			set buyed = $replace($p(line,":",2)," ","")
			set data.amountReceived = ..normalize($extract(buyed,1,*-3))
			set data.deviseReceived = $extract(buyed,*-2,*)
			set lineReceived = 0
		}

		if i = linePaid {
			set selled = $replace($p(line,":",2)," ","")
			set data.amountPaid = ..normalize($extract(selled,1,*-3))
			set data.devisePaid = $extract(selled,*-2,*)
			set linePaid = 0
		}

		if i = lineRate {
			set data.spot = $replace($p(line,":",2)," ","") * 1
			if $Extract(data.spot,1,1)="."{
				set data.spot = "0" _ data.spot
			}
			set lineRate = 0
		}

		if i = lineMaturityDate {
			set data.maturityDate =  ##class(CFAO.HUBIC.Outils).convertDateDDMmmmYYYY($p(line,": ",2), "-", 3)
			set lineMaturityDate = 0
			set lineInfo = 0
		}
	}

    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 0) {
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
