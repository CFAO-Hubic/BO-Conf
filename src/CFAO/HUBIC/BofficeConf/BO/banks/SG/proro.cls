Class CFAO.HUBIC.BofficeConf.BO.banks.SG.proro Extends CFAO.HUBIC.BofficeConf.BO.banks.masterClass
{

Parameter INVOCATION = "Queue";

Method saveAndCheckMatch(pRequest As %Stream.FileCharacter, Output pResponse As Ens.StringResponse) As %Status
{
	set data = {}
	set data.bank = "SG"
	set data.confType = "PRORO"

	set i = 0

	set (
		line,
		line1,
		line2,
		lineReceived,
		linePaid,
		lineInfos,
		lineOpeIni,
		lineProro
	) = ""


	set pResponse = ##class(CFAO.HUBIC.BofficeConf.messages.checkBankMsg).%New()
	set pResponse.bank = data.bank

	do pRequest.Rewind()

	// Read the txt file (converted from pdf) to find the relevant informations
	while 'pRequest.AtEnd {
		set i = i + 1

		// Store 3 last rows in order to read the line header of the matrice in the pdf
		set line2 = line1
		set line1 = line
		set line  = pRequest.ReadLine()

		// Processed confFileName
		If i = 1 {
			set data.confFileName = line
		}

		// First line of the matrice
		if line2 _ " " _ line1 _ " " _ line = "Opération initiale avec modifications" {
			set lineOpeIni = i + 1
		}

		If i = lineOpeIni {
			set data.contrat	= $e($p(line, " ", 1), 1, * - 4)
			set data.reference	= data.contrat
			set data.valueDate	= $zd($zdh($p(line," ",8), 4), 3)
			set data.spot = $p(line," ",6)
		}

		// Second line of the matrice
		if line1 _ " " _ line = "Opération prorogée" {
			set lineProro = i + 1
		}

		If i = lineProro {
			set data.contrat		= data.contrat _ " - " _ $e($p(line, " ", 1), 1, * - 4)
			set data.reference		= data.contrat
			set data.tradeDate		= $zd($zdh($p(line," ",7), 4), 3)
			set data.maturityDate	= $zd($zdh($p(line," ",8), 4), 3)
			set data.term = $p(line," ",6)
		}

		// Received
		if $Find(line ,"Paiement à CFAO") {
			set lineReceived = i + 1
		}

		if lineReceived = i {
			set data.amountReceived =  $p(line," ",1)
			set data.deviseReceived = $p(line," ",2)
		}

		// Paid
		if $Find(line ,"Paiement à SOCIETE GENERALE") {
			set linePaid = i + 1
		}

		If linePaid = i {
			set data.amountPaid =  $p(line," ",1)
			set data.devisePaid = $p(line," ",2)
		}
	}

    // Check if every requiered fields are provided
    If '..hasRequiredField(data, 2) {
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
